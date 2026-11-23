import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────
// ENTRY WIDGET
// ─────────────────────────────────────────────
class MiniCarromGame extends StatefulWidget {
  const MiniCarromGame({super.key});

  @override
  State<MiniCarromGame> createState() => _MiniCarromGameState();
}

// ─────────────────────────────────────────────
// CARROM ROOM (online session, SharedPreferences-based)
// ─────────────────────────────────────────────
enum _CarromRoomStatus { waiting, joined, playing, closed }

class _CarromRoom {
  final String roomId;
  String host;
  String? guest;
  _CarromRoomStatus status;
  int createdAt;
  // board state: JSON snapshot exchanged between players
  Map<String, dynamic>? boardState;

  _CarromRoom({
    required this.roomId,
    required this.host,
    this.guest,
    this.status = _CarromRoomStatus.waiting,
    required this.createdAt,
    this.boardState,
  });
}

// ─────────────────────────────────────────────
// GAME SCREENS ENUM
// ─────────────────────────────────────────────
enum _Screen { menu, createRoom, joinRoom, localGame, onlineGame }

// ─────────────────────────────────────────────
// COIN DATA
// ─────────────────────────────────────────────
class _Coin {
  Offset pos;
  Offset vel;
  final double r;
  final bool isWhite; // true = P1, false = P2
  final bool isQueen;
  bool pocketed;

  _Coin({
    required this.pos,
    this.vel = Offset.zero,
    required this.r,
    required this.isWhite,
    this.isQueen = false,
    this.pocketed = false,
  });
}

// ─────────────────────────────────────────────
// MAIN STATE
// ─────────────────────────────────────────────
class _MiniCarromGameState extends State<MiniCarromGame>
    with SingleTickerProviderStateMixin {
  // ── Screens ──────────────────────────────────
  _Screen _screen = _Screen.menu;

  // ── Online room ───────────────────────────────
  final _roomCodeController = TextEditingController();
  final _nameController     = TextEditingController();
  String _myName  = 'Player 1';
  String _oppName = 'Player 2';
  String _createdRoomId = '';
  Timer? _roomPollTimer;
  bool  _isHost = true;
  int   _waitSeconds = 0;
  Timer? _waitTimer;
  static final Map<String, _CarromRoom> _rooms = {}; // "server" (shared state in memory)

  // ── Board physics ─────────────────────────────
  late AnimationController _ticker;
  double _bs = 0; // board size (set by LayoutBuilder)
  late List<_Coin> _coins;
  late _Coin _striker;
  int _turn = 1; // 1 = P1 (bottom), 2 = P2 (top)
  int _p1Pocketed = 0; // how many of P1's coins pocketed
  int _p2Pocketed = 0;
  bool _queenPocketed = false;
  bool _queenCovered  = false; // queen is only counted if covered next shot
  bool _pendingQueenCover = false; // did we just pocket queen?
  String _msg = '';
  bool _gameOver = false;
  String _winner = '';

  // Striker drag / aim
  double _strikerPct = 0.5; // 0..1 horizontal on baseline
  Offset? _aimDragStart;
  Offset? _aimDragCurrent;
  bool _shooting = false;
  bool _settled = true;

  // Online mode
  bool _onlineMode = false;
  int _myPlayer = 1; // which player am I (1 or 2)

  // Total coins per player
  static const int _coinsPerPlayer = 9; // 9 each (standard carrom)

  @override
  void initState() {
    super.initState();
    _ticker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )
      ..addListener(_step)
      ..repeat();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _roomPollTimer?.cancel();
    _waitTimer?.cancel();
    _roomCodeController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // ─── BOARD SETUP ────────────────────────────
  void _setupBoard(double boardSize) {
    _bs = boardSize;
    final c = Offset(_bs / 2, _bs / 2);
    final r = _bs * 0.034; // coin radius

    // Classic 19-coin layout (9W + 9B + 1 Queen)
    _coins = [];
    // Build the alternating ring of 18 coins + center queen
    // Inner ring: 6 coins, outer ring: 12 coins
    final inner = _bs * 0.085;
    final outer = _bs * 0.165;

    // Center Queen
    _coins.add(_Coin(pos: c, r: r, isWhite: true, isQueen: true));

    // Inner ring: 6 alternating
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * pi / 180;
      final isW = (i % 2 == 0);
      _coins.add(_Coin(
        pos: c + Offset(cos(angle) * inner, sin(angle) * inner),
        r: r,
        isWhite: isW,
      ));
    }

    // Outer ring: 12 alternating
    for (int i = 0; i < 12; i++) {
      final angle = (i * 30) * pi / 180;
      final isW = (i % 2 == 0);
      _coins.add(_Coin(
        pos: c + Offset(cos(angle) * outer, sin(angle) * outer),
        r: r,
        isWhite: isW,
      ));
    }

    _p1Pocketed = 0;
    _p2Pocketed = 0;
    _queenPocketed = false;
    _queenCovered  = false;
    _pendingQueenCover = false;
    _turn = 1;
    _gameOver = false;
    _winner = '';
    _msg = _onlineMode && _myPlayer != 1
        ? 'Waiting for P1 to shoot…'
        : 'P1\'s turn — aim & shoot!';
    _settled = true;
    _shooting = false;
    _resetStriker();
  }

  List<Offset> _pocketPositions() {
    final margin = _bs * 0.065;
    return [
      Offset(margin, margin),
      Offset(_bs - margin, margin),
      Offset(margin, _bs - margin),
      Offset(_bs - margin, _bs - margin),
    ];
  }

  void _resetStriker() {
    final minX = _bs * 0.22;
    final maxX = _bs * 0.78;
    final x = minX + _strikerPct * (maxX - minX);
    // P1 at bottom, P2 at top
    final y = _turn == 1 ? _bs * 0.84 : _bs * 0.16;
    final sr = _bs * 0.048;
    _striker = _Coin(pos: Offset(x, y), r: sr, isWhite: _turn == 1);
  }

  // ─── PHYSICS STEP ────────────────────────────
  void _step() {
    if (!mounted || _gameOver || _settled) return;

    bool anyMoving = false;
    bool coinPocketed = false;
    bool strikerPocketed = false;
    bool queenJustPocketed = false;
    bool p1CoinPocketed = false;
    bool p2CoinPocketed = false;

    final pockets = _pocketPositions();
    final allPieces = [_striker, ..._coins.where((c) => !c.pocketed)];
    final pr = _bs * 0.072; // pocket radius

    // Move each piece
    for (final p in allPieces) {
      if (p.vel.distance > 0.5) {
        anyMoving = true;
        p.pos += p.vel;
        p.vel *= 0.973; // friction

        // Cushion bounce
        final margin = p.r + _bs * 0.038;
        if (p.pos.dx < margin) {
          p.pos = Offset(margin, p.pos.dy);
          p.vel = Offset(-p.vel.dx * 0.75, p.vel.dy);
        } else if (p.pos.dx > _bs - margin) {
          p.pos = Offset(_bs - margin, p.pos.dy);
          p.vel = Offset(-p.vel.dx * 0.75, p.vel.dy);
        }
        if (p.pos.dy < margin) {
          p.pos = Offset(p.pos.dx, margin);
          p.vel = Offset(p.vel.dx, -p.vel.dy * 0.75);
        } else if (p.pos.dy > _bs - margin) {
          p.pos = Offset(p.pos.dx, _bs - margin);
          p.vel = Offset(p.vel.dx, -p.vel.dy * 0.75);
        }

        // Pocket check
        for (final pocket in pockets) {
          if ((p.pos - pocket).distance < pr) {
            p.pocketed = true;
            p.vel = Offset.zero;
            p.pos = const Offset(-999, -999);

            if (p == _striker) {
              strikerPocketed = true;
            } else if (p.isQueen) {
              queenJustPocketed = true;
            } else if (p.isWhite) {
              p1CoinPocketed = true;
            } else {
              p2CoinPocketed = true;
            }
            coinPocketed = true;
          }
        }
      } else {
        p.vel = Offset.zero;
      }
    }

    // Elastic coin collisions
    for (int i = 0; i < allPieces.length; i++) {
      for (int j = i + 1; j < allPieces.length; j++) {
        final a = allPieces[i], b = allPieces[j];
        if (a.pocketed || b.pocketed) continue;
        final delta = b.pos - a.pos;
        final dist  = delta.distance;
        final minD  = a.r + b.r;
        if (dist < minD && dist > 0.001) {
          final n = delta / dist;
          final overlap = minD - dist;
          a.pos -= n * (overlap / 2);
          b.pos += n * (overlap / 2);
          final rel = a.vel - b.vel;
          final dot = rel.dx * n.dx + rel.dy * n.dy;
          if (dot > 0) {
            a.vel -= n * (dot * 0.85);
            b.vel += n * (dot * 0.85);
          }
        }
      }
    }

    // Handle queen pocketing
    if (queenJustPocketed) {
      _pendingQueenCover = true;
    }

    // After shot settles
    if (_shooting && !anyMoving) {
      _shooting = false;
      _settled = true;
      _onShotSettled(
        coinPocketed: coinPocketed,
        strikerPocketed: strikerPocketed,
        p1CoinPocketed: p1CoinPocketed,
        p2CoinPocketed: p2CoinPocketed,
        queenJustPocketed: queenJustPocketed,
      );
    }

    if (mounted) setState(() {});
  }

  void _onShotSettled({
    required bool coinPocketed,
    required bool strikerPocketed,
    required bool p1CoinPocketed,
    required bool p2CoinPocketed,
    required bool queenJustPocketed,
  }) {
    bool extraTurn = false;

    if (strikerPocketed) {
      // Foul — lose turn, opponent gets +1 coin back if any pocketed
      _msg = '⚠️ Foul! Striker pocketed — turn changes';
      _pendingQueenCover = false;
      // If queen was also pocketed on foul shot, return it
      if (queenJustPocketed) {
        _returnQueen();
      }
      _switchTurn();
      return;
    }

    // Count pocketed coins for current player
    if (_turn == 1 && p1CoinPocketed) {
      _p1Pocketed++;
      extraTurn = true;
      _msg = '✅ P1 pocketed! +1 — shoot again!';
    } else if (_turn == 2 && p2CoinPocketed) {
      _p2Pocketed++;
      extraTurn = true;
      _msg = '✅ P2 pocketed! +1 — shoot again!';
    } else if (coinPocketed && !strikerPocketed) {
      // Pocketed opponent's coin — foul
      _msg = '⚠️ Wrong coin! Turn changes';
    } else if (!coinPocketed) {
      _msg = 'No pocket — turn changes';
    }

    // Queen cover rule
    if (queenJustPocketed) {
      if (extraTurn) {
        // Queen is covered only if same player pockets one of their own coins AFTER queen
        // in this turn they already did — count queen
        _queenPocketed = true;
        _queenCovered  = true;
        _msg += ' 👑 Queen covered!';
      } else {
        // Queen not covered — return it
        _returnQueen();
        _msg += ' 👑 Queen returned (not covered)';
      }
    } else if (_pendingQueenCover && extraTurn) {
      _queenCovered = true;
      _pendingQueenCover = false;
      _msg += ' 👑 Queen covered!';
    } else {
      _pendingQueenCover = false;
    }

    // Win check: player pockets all 9 of their own coins
    if (_p1Pocketed >= _coinsPerPlayer) {
      _endGame('Player 1 Wins! 🎉');
      return;
    }
    if (_p2Pocketed >= _coinsPerPlayer) {
      _endGame('Player 2 Wins! 🎉');
      return;
    }

    if (!extraTurn) {
      _switchTurn();
    } else {
      _resetStriker();
      if (mounted) setState(() {});
    }
  }

  void _returnQueen() {
    final c = Offset(_bs / 2, _bs / 2);
    final qCoin = _coins.firstWhere((c) => c.isQueen, orElse: () => _coins.first);
    qCoin.pocketed = false;
    qCoin.pos = c;
    qCoin.vel = Offset.zero;
    _pendingQueenCover = false;
  }

  void _switchTurn() {
    // In online mode, only switch if it's currently my turn
    _turn = _turn == 1 ? 2 : 1;
    _msg = _turn == 1 ? 'P1\'s turn — aim!' : 'P2\'s turn — aim!';
    _resetStriker();
    if (mounted) setState(() {});
  }

  void _endGame(String winner) {
    _gameOver = true;
    _winner = winner;
    HapticFeedback.heavyImpact();
    if (mounted) setState(() {});
  }

  // ─── SHOOT ───────────────────────────────────
  void _shoot() {
    if (_aimDragStart == null || _aimDragCurrent == null) return;
    if (_shooting || !_settled) return;
    if (_gameOver) return;
    // In online mode, can only shoot on your turn
    if (_onlineMode && _myPlayer != _turn) return;

    final drag = _aimDragStart! - _aimDragCurrent!;
    final power = drag.distance.clamp(0, _bs * 0.35);
    if (power < _bs * 0.015) return;

    final dir = drag / drag.distance;
    final speed = power * 0.28;
    _striker.vel = dir * speed;
    _shooting = true;
    _settled = false;
    _aimDragStart = null;
    _aimDragCurrent = null;
    HapticFeedback.lightImpact();
    if (mounted) setState(() {});
  }

  bool get _isMyTurn => !_onlineMode || _myPlayer == _turn;

  // ─── ROOM MANAGEMENT (in-memory local server) ─
  String _generateRoomId() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rng = Random();
    return List.generate(6, (_) => chars[rng.nextInt(chars.length)]).join();
  }

  void _createRoom() {
    final id = _generateRoomId();
    _rooms[id] = _CarromRoom(
      roomId: id,
      host: _myName,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    _createdRoomId = id;
    _isHost = true;
    _myPlayer = 1;
    _oppName = 'Waiting…';
    setState(() => _screen = _Screen.createRoom);
    _startWaitTimer();
    _startRoomPoll(id);
  }

  void _joinRoom(String id) {
    id = id.trim().toUpperCase();
    final room = _rooms[id];
    if (room == null || room.status != _CarromRoomStatus.waiting) {
      _showSnack('Room "$id" not found or already started.');
      return;
    }
    room.guest = _myName;
    room.status = _CarromRoomStatus.joined;
    _isHost = false;
    _myPlayer = 2;
    _oppName = room.host;
    _createdRoomId = id;
    setState(() => _screen = _Screen.joinRoom);
    _startGameFromRoom(id);
  }

  void _startWaitTimer() {
    _waitSeconds = 0;
    _waitTimer?.cancel();
    _waitTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      setState(() => _waitSeconds++);
      if (_waitSeconds >= 60) {
        t.cancel();
        _rooms[_createdRoomId]?.status = _CarromRoomStatus.closed;
        _showSnack('No one joined in 60s — room closed.');
        setState(() => _screen = _Screen.menu);
      }
    });
  }

  void _startRoomPoll(String id) {
    _roomPollTimer?.cancel();
    _roomPollTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) { t.cancel(); return; }
      final room = _rooms[id];
      if (room != null && room.status == _CarromRoomStatus.joined) {
        t.cancel();
        _waitTimer?.cancel();
        _oppName = room.guest ?? 'Player 2';
        _startGameFromRoom(id);
      }
    });
  }

  void _startGameFromRoom(String id) {
    _rooms[id]?.status = _CarromRoomStatus.playing;
    _onlineMode = true;
    setState(() => _screen = _Screen.onlineGame);
  }

  void _cancelRoom() {
    _rooms.remove(_createdRoomId);
    _roomPollTimer?.cancel();
    _waitTimer?.cancel();
    setState(() => _screen = _Screen.menu);
  }

  void _showSnack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: const Color(0xFF6B3EF5)),
    );
  }

  // ─── BUILD ───────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF4A1E8A),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _buildScreen(),
        ),
      ),
    );
  }

  Widget _buildScreen() {
    switch (_screen) {
      case _Screen.menu:        return _buildMenu();
      case _Screen.createRoom:  return _buildWaitingRoom(isHost: _isHost);
      case _Screen.joinRoom:    return _buildWaitingRoom(isHost: _isHost);
      case _Screen.localGame:
      case _Screen.onlineGame:  return _buildGameScreen();
    }
  }

  // ─── MENU ─────────────────────────────────────
  Widget _buildMenu() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Board icon preview
            Container(
              width: 110, height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A86A),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 16, offset: Offset(0, 6))],
              ),
              child: const Center(
                child: Text('🎯', style: TextStyle(fontSize: 54)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Carrom Pool', style: TextStyle(
              color: Colors.white, fontSize: 32, fontWeight: FontWeight.w900,
              letterSpacing: 1,
            )),
            const SizedBox(height: 6),
            Text('Pocket all your 9 coins to win!',
              style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
            const SizedBox(height: 40),

            // Name field
            _buildTextField(_nameController, 'Your name', Icons.person),
            const SizedBox(height: 28),

            // Buttons
            _menuBtn('⚡ Local 2-Player', const Color(0xFF6B3EF5), () {
              _myName  = _nameController.text.trim().isEmpty ? 'Player 1' : _nameController.text.trim();
              _oppName = 'Player 2';
              _onlineMode = false;
              _myPlayer = 1;
              setState(() => _screen = _Screen.localGame);
            }),
            const SizedBox(height: 14),
            _menuBtn('🌐 Online — Create Room', const Color(0xFF22C55E), () {
              _myName = _nameController.text.trim().isEmpty ? 'Player 1' : _nameController.text.trim();
              _createRoom();
            }),
            const SizedBox(height: 14),
            _menuBtn('🔑 Online — Join Room', const Color(0xFFF59E0B), () {
              _myName = _nameController.text.trim().isEmpty ? 'Player 2' : _nameController.text.trim();
              _showJoinDialog();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon) {
    return TextField(
      controller: ctrl,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIcon: Icon(icon, color: Colors.white38),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _menuBtn(String label, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 6,
        ),
        onPressed: onTap,
        child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  void _showJoinDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF2D1060),
        title: const Text('Join Room', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: _roomCodeController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Enter 6-letter room code',
            hintStyle: TextStyle(color: Colors.white38),
          ),
          textCapitalization: TextCapitalization.characters,
          maxLength: 6,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B3EF5)),
            onPressed: () {
              Navigator.pop(context);
              _joinRoom(_roomCodeController.text);
            },
            child: const Text('Join', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ─── WAITING ROOM ─────────────────────────────
  Widget _buildWaitingRoom({required bool isHost}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🎮', style: TextStyle(fontSize: 60)),
            const SizedBox(height: 20),
            Text(isHost ? 'Share this Room Code' : 'Joining Room…',
              style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            if (isHost) ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B3EF5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(_createdRoomId,
                  style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w900, letterSpacing: 8)),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: _createdRoomId));
                  _showSnack('Room code copied!');
                },
                child: const Text('📋 Tap to copy',
                  style: TextStyle(color: Colors.white54, fontSize: 13)),
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 12),
              Text('Waiting for opponent… ($_waitSeconds / 60s)',
                style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14)),
            ] else ...[
              const CircularProgressIndicator(color: Colors.white),
              const SizedBox(height: 16),
              Text('Joining room $_createdRoomId…',
                style: const TextStyle(color: Colors.white70)),
            ],
            const SizedBox(height: 32),
            TextButton(
              onPressed: () {
                _cancelRoom();
              },
              child: const Text('Cancel', style: TextStyle(color: Colors.redAccent, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  // ─── GAME SCREEN ─────────────────────────────
  Widget _buildGameScreen() {
    return LayoutBuilder(builder: (ctx, cst) {
      final sw = cst.maxWidth;
      final sh = cst.maxHeight;

      // Board size: square, fits screen with room for HUD
      final hudH = sh * 0.14;
      final msgH = sh * 0.065;
      final ctrlH = sh * 0.14;
      final availH = sh - hudH - msgH - ctrlH;
      final bs = min(sw, availH) * 0.96;

      // Setup board on first build or size change
      if (_bs != bs) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _setupBoard(bs));
        });
      }

      return Column(
        children: [
          _buildHUD(sw),
          _buildMsgBar(),
          Expanded(
            child: Center(
              child: _bs > 0 ? _buildBoard(bs) : const CircularProgressIndicator(color: Colors.white),
            ),
          ),
          _buildControls(bs),
        ],
      );
    });
  }

  // ─── HUD ─────────────────────────────────────
  Widget _buildHUD(double sw) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _playerCard(
            name: _myPlayer == 1 ? _myName : _oppName,
            emoji: '⬜',
            coins: _p1Pocketed,
            active: _turn == 1,
            isLeft: true,
          ),
          Column(children: [
            Text(_onlineMode ? '🌐 Online' : '🎮 Local',
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
            const SizedBox(height: 4),
            GestureDetector(
              onTap: () => setState(() {
                _screen = _Screen.menu;
                _onlineMode = false;
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text('Menu', style: TextStyle(color: Colors.white60, fontSize: 12)),
              ),
            ),
          ]),
          _playerCard(
            name: _myPlayer == 2 ? _myName : _oppName,
            emoji: '⬛',
            coins: _p2Pocketed,
            active: _turn == 2,
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _playerCard({
    required String name,
    required String emoji,
    required int coins,
    required bool active,
    required bool isLeft,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF6B3EF5) : Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: active ? Colors.white : Colors.transparent,
          width: 2,
        ),
      ),
      child: Row(
        children: isLeft
            ? [Text(emoji), const SizedBox(width: 6), _playerInfo(name, coins)]
            : [_playerInfo(name, coins), const SizedBox(width: 6), Text(emoji)],
      ),
    );
  }

  Widget _playerInfo(String name, int coins) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        Text('Pocketed: $coins / $_coinsPerPlayer',
          style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  // ─── MSG BAR ─────────────────────────────────
  Widget _buildMsgBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: _gameOver
              ? const Color(0xFF22C55E).withOpacity(0.25)
              : Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          _gameOver ? _winner : _msg,
          style: TextStyle(
            color: _gameOver ? const Color(0xFF22C55E) : Colors.white,
            fontWeight: _gameOver ? FontWeight.w900 : FontWeight.normal,
            fontSize: _gameOver ? 16 : 13,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }

  // ─── BOARD ───────────────────────────────────
  Widget _buildBoard(double bs) {
    if (_bs == 0) return const SizedBox.shrink();

    final canShoot = _isMyTurn && _settled && !_gameOver;

    return GestureDetector(
      onPanStart: canShoot ? (d) {
        setState(() {
          _aimDragStart = d.localPosition;
          _aimDragCurrent = d.localPosition;
        });
      } : null,
      onPanUpdate: canShoot ? (d) {
        setState(() => _aimDragCurrent = d.localPosition);
      } : null,
      onPanEnd: canShoot ? (_) => _shoot() : null,
      child: CustomPaint(
        size: Size(bs, bs),
        painter: _CarromBoardPainter(
          bs: _bs,
          coins: _coins,
          striker: _striker,
          aimStart: _aimDragStart,
          aimCurrent: _aimDragCurrent,
          turn: _turn,
          gameOver: _gameOver,
          queenCovered: _queenCovered,
        ),
      ),
    );
  }

  // ─── CONTROLS ────────────────────────────────
  Widget _buildControls(double bs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        children: [
          // Striker position slider
          if (!_gameOver && _isMyTurn && _settled)
            Row(
              children: [
                const Text('⬅', style: TextStyle(color: Colors.white38, fontSize: 12)),
                Expanded(
                  child: Slider(
                    value: _strikerPct,
                    min: 0.0, max: 1.0,
                    activeColor: const Color(0xFF6B3EF5),
                    inactiveColor: Colors.white24,
                    onChanged: (v) => setState(() {
                      _strikerPct = v;
                      _resetStriker();
                    }),
                  ),
                ),
                const Text('➡', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ],
            ),

          // Action row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (_gameOver)
                ElevatedButton.icon(
                  icon: const Icon(Icons.refresh),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6B3EF5)),
                  onPressed: () => setState(() => _setupBoard(_bs)),
                )
              else if (_onlineMode && !_isMyTurn)
                Text('Waiting for ${_turn == 1 ? _myPlayer == 2 ? _myName : _oppName : _myPlayer == 1 ? _myName : _oppName}…',
                  style: const TextStyle(color: Colors.white54, fontSize: 13))
              else
                Text(_settled ? 'Drag on board to aim & shoot →' : 'Settling…',
                  style: const TextStyle(color: Colors.white38, fontSize: 12)),

              // Queen status indicator
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _queenCovered
                      ? const Color(0xFFEF4444).withOpacity(0.25)
                      : (_queenPocketed ? Colors.amber.withOpacity(0.25) : Colors.white.withOpacity(0.07)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _queenCovered
                      ? '👑 Covered'
                      : (_queenPocketed ? '👑 Cover needed' : '👑 Free'),
                  style: TextStyle(
                    color: _queenCovered
                        ? const Color(0xFFEF4444)
                        : (_queenPocketed ? Colors.amber : Colors.white38),
                    fontSize: 12, fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// CARROM BOARD PAINTER
// ─────────────────────────────────────────────
class _CarromBoardPainter extends CustomPainter {
  final double bs;
  final List<_Coin> coins;
  final _Coin striker;
  final Offset? aimStart;
  final Offset? aimCurrent;
  final int turn;
  final bool gameOver;
  final bool queenCovered;

  _CarromBoardPainter({
    required this.bs,
    required this.coins,
    required this.striker,
    required this.aimStart,
    required this.aimCurrent,
    required this.turn,
    required this.gameOver,
    required this.queenCovered,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // ── WOODEN BOARD BACKGROUND ──────────────────
    final boardRect = Rect.fromLTWH(0, 0, bs, bs);

    // Wood gradient
    paint.shader = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [Color(0xFFD4A86A), Color(0xFFC4934E), Color(0xFFB8853A), Color(0xFFD4A86A)],
    ).createShader(boardRect);
    canvas.drawRRect(RRect.fromRectAndRadius(boardRect, Radius.circular(bs * 0.03)), paint);

    // Wood grain lines
    paint
      ..shader = null
      ..color = const Color(0xFFB8853A).withOpacity(0.3)
      ..strokeWidth = 1;
    for (double y = 0; y < bs; y += bs * 0.04) {
      canvas.drawLine(Offset(0, y), Offset(bs, y), paint);
    }

    // ── BOARD BORDER / FRAME ──────────────────────
    final framePad = bs * 0.04;
    final frameRect = Rect.fromLTWH(framePad, framePad, bs - framePad * 2, bs - framePad * 2);
    paint
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF8B5A2B)
      ..strokeWidth = bs * 0.016;
    canvas.drawRRect(RRect.fromRectAndRadius(frameRect, Radius.circular(bs * 0.015)), paint);

    // Inner border line
    final innerPad = framePad + bs * 0.028;
    final innerRect = Rect.fromLTWH(innerPad, innerPad, bs - innerPad * 2, bs - innerPad * 2);
    paint.strokeWidth = bs * 0.005;
    paint.color = const Color(0xFF8B5A2B).withOpacity(0.5);
    canvas.drawRRect(RRect.fromRectAndRadius(innerRect, Radius.circular(bs * 0.01)), paint);

    // ── POCKETS ───────────────────────────────────
    final pocketR = bs * 0.072;
    final pocketMargin = bs * 0.065;
    final pocketPositions = [
      Offset(pocketMargin, pocketMargin),
      Offset(bs - pocketMargin, pocketMargin),
      Offset(pocketMargin, bs - pocketMargin),
      Offset(bs - pocketMargin, bs - pocketMargin),
    ];

    for (final pos in pocketPositions) {
      // Pocket shadow
      paint
        ..style = PaintingStyle.fill
        ..color = Colors.black.withOpacity(0.6);
      canvas.drawCircle(pos, pocketR, paint);
      // Pocket inner dark circle
      paint.color = const Color(0xFF1A0A00);
      canvas.drawCircle(pos, pocketR * 0.78, paint);
    }

    // ── CENTER CIRCLE ─────────────────────────────
    final center = Offset(bs / 2, bs / 2);
    paint
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFF8B5A2B).withOpacity(0.7)
      ..strokeWidth = bs * 0.007;
    canvas.drawCircle(center, bs * 0.19, paint);
    canvas.drawCircle(center, bs * 0.045, paint);

    // ── BASELINE LINES ────────────────────────────
    final baselineY1 = bs * 0.84; // P1 baseline (bottom)
    final baselineY2 = bs * 0.16; // P2 baseline (top)
    final baselineX1 = bs * 0.22;
    final baselineX2 = bs * 0.78;

    paint
      ..color = const Color(0xFF8B5A2B).withOpacity(0.5)
      ..strokeWidth = bs * 0.005;
    // P1 baseline
    canvas.drawLine(Offset(baselineX1, baselineY1), Offset(baselineX2, baselineY1), paint);
    // P2 baseline
    canvas.drawLine(Offset(baselineX1, baselineY2), Offset(baselineX2, baselineY2), paint);

    // ── AIM GUIDE (drag arrow) ────────────────────
    if (aimStart != null && aimCurrent != null) {
      final drag = aimStart! - aimCurrent!;
      final dragLen = drag.distance;
      if (dragLen > 5) {
        final dir = drag / dragLen;
        final lineEnd = striker.pos + dir * (dragLen.clamp(0, bs * 0.4));

        // Dotted aim line
        final dashPaint = Paint()
          ..color = Colors.white.withOpacity(0.6)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke;
        const dashLen = 8.0;
        const gapLen  = 5.0;
        double traveled = 0;
        final total = (lineEnd - striker.pos).distance;
        while (traveled < total) {
          final segStart = striker.pos + dir * traveled;
          final segEnd = striker.pos + dir * (traveled + dashLen).clamp(0, total);
          canvas.drawLine(segStart, segEnd, dashPaint);
          traveled += dashLen + gapLen;
        }

        // Power indicator dot at drag point
        paint
          ..style = PaintingStyle.fill
          ..color = Colors.white.withOpacity(0.4);
        canvas.drawCircle(lineEnd, 4, paint);
      }
    }

    // ── COINS ─────────────────────────────────────
    for (final coin in coins) {
      if (coin.pocketed) continue;
      _drawCoin(canvas, coin, bs);
    }

    // ── STRIKER ───────────────────────────────────
    _drawStriker(canvas, striker, turn, bs);
  }

  void _drawCoin(Canvas canvas, _Coin coin, double bs) {
    final paint = Paint();

    if (coin.isQueen) {
      // Red queen with gold border
      paint
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFDC2626);
      canvas.drawCircle(coin.pos, coin.r, paint);
      paint
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFFFD700)
        ..strokeWidth = coin.r * 0.25;
      canvas.drawCircle(coin.pos, coin.r, paint);
      // Crown mark
      final tp = TextPainter(
        text: const TextSpan(text: 'Q', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, coin.pos - Offset(tp.width / 2, tp.height / 2));
    } else {
      // Shadow
      paint
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3)
        ..color = Colors.black.withOpacity(0.3);
      canvas.drawCircle(coin.pos + const Offset(1.5, 2), coin.r, paint);
      paint.maskFilter = null;

      // Fill
      paint.color = coin.isWhite ? const Color(0xFFF5F0E8) : const Color(0xFF1C1410);
      canvas.drawCircle(coin.pos, coin.r, paint);

      // Rim
      paint
        ..style = PaintingStyle.stroke
        ..color = coin.isWhite ? const Color(0xFFD4C5A9) : const Color(0xFF3D2B1A)
        ..strokeWidth = coin.r * 0.18;
      canvas.drawCircle(coin.pos, coin.r * 0.85, paint);

      // Highlight
      paint
        ..style = PaintingStyle.fill
        ..color = Colors.white.withOpacity(0.35);
      canvas.drawCircle(coin.pos - Offset(coin.r * 0.28, coin.r * 0.3), coin.r * 0.3, paint);
    }
  }

  void _drawStriker(Canvas canvas, _Coin striker, int turn, double bs) {
    final paint = Paint();

    // Glow
    paint
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8)
      ..color = (turn == 1 ? const Color(0xFF6B3EF5) : const Color(0xFFEF4444)).withOpacity(0.6)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(striker.pos, striker.r * 1.3, paint);
    paint.maskFilter = null;

    // Fill
    paint.shader = RadialGradient(
      center: const Alignment(-0.3, -0.4),
      radius: 0.8,
      colors: turn == 1
          ? [const Color(0xFF9B6FFF), const Color(0xFF5B2EE5)]
          : [const Color(0xFFFF7070), const Color(0xFFCC2020)],
    ).createShader(Rect.fromCircle(center: striker.pos, radius: striker.r));
    canvas.drawCircle(striker.pos, striker.r, paint);
    paint.shader = null;

    // Rim
    paint
      ..style = PaintingStyle.stroke
      ..color = Colors.white.withOpacity(0.5)
      ..strokeWidth = striker.r * 0.12;
    canvas.drawCircle(striker.pos, striker.r * 0.88, paint);
  }

  @override
  bool shouldRepaint(covariant _CarromBoardPainter old) => true;
}
