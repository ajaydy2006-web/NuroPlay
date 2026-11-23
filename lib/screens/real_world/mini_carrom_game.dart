import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_typography.dart';
import 'realistic_game_components.dart';
import '../../services/storage_service.dart';

enum CarromGameMode {
  twoPlayer, // 2-Player Duel (White vs Black)
  solo,      // Solo High-Score Challenge
}

class MiniCarromGame extends StatefulWidget {
  const MiniCarromGame({super.key});

  @override
  State<MiniCarromGame> createState() => _MiniCarromGameState();
}

class _CarromPiece {
  Offset pos;
  Offset vel;
  final double radius;
  final Color color;
  final int points;
  final bool isWhite;
  final bool isQueen;
  bool isPocketed;

  _CarromPiece({
    required this.pos,
    this.vel = Offset.zero,
    required this.radius,
    required this.color,
    required this.points,
    this.isWhite = false,
    this.isQueen = false,
    this.isPocketed = false,
  });
}

class _MiniCarromGameState extends State<MiniCarromGame> with SingleTickerProviderStateMixin {
  late AnimationController _physicsController;

  CarromGameMode _mode = CarromGameMode.twoPlayer;

  // Board dimensions (scaled dynamically by screen)
  double _boardSize = 340.0;
  double _pocketRadius = 22.0;

  late List<_CarromPiece> _coins;
  late _CarromPiece _striker;

  // Baseline positioning
  double _strikerXPercent = 0.5; // 0.0 (left) to 1.0 (right)

  // 2-Player State
  int _activePlayer = 1; // 1 = Player 1 (White), 2 = Player 2 (Black)
  int _p1Score = 0;
  int _p2Score = 0;
  bool _extraTurn = false;
  String _turnFeedback = '';

  // Solo State
  int _soloScore = 0;
  int _shotsRemaining = 10;

  // Aim & Drag state
  Offset? _dragStart;
  Offset? _dragCurrent;
  bool _isShooting = false;
  bool _gameOver = false;
  String _winnerText = '';

  List<Offset> get _pockets => [
    const Offset(24, 24),                         // Top Left
    Offset(_boardSize - 24, 24),                  // Top Right
    Offset(24, _boardSize - 24),                  // Bottom Left
    Offset(_boardSize - 24, _boardSize - 24),     // Bottom Right
  ];

  @override
  void initState() {
    super.initState();
    _physicsController = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_updatePhysics)
      ..repeat();

    _setupBoard();
  }

  void _setupBoard() {
    final center = Offset(_boardSize / 2, _boardSize / 2);
    final coinRadius = _boardSize * 0.033; // ~11px for 340 board

    // Authentic Carrom Pool Disc Layout (1 Queen, 4 White, 4 Black)
    final d = coinRadius * 2.1;
    _coins = [
      // 1. Red Queen (Center)
      _CarromPiece(
        pos: center,
        radius: coinRadius,
        color: const Color(0xFFEF4444),
        points: 25,
        isQueen: true,
      ),
      // 2. White Coins (Player 1)
      _CarromPiece(
        pos: center + Offset(-d, 0),
        radius: coinRadius,
        color: Colors.white,
        points: 10,
        isWhite: true,
      ),
      _CarromPiece(
        pos: center + Offset(d, 0),
        radius: coinRadius,
        color: Colors.white,
        points: 10,
        isWhite: true,
      ),
      _CarromPiece(
        pos: center + Offset(0, -d),
        radius: coinRadius,
        color: Colors.white,
        points: 10,
        isWhite: true,
      ),
      _CarromPiece(
        pos: center + Offset(0, d),
        radius: coinRadius,
        color: Colors.white,
        points: 10,
        isWhite: true,
      ),
      // 3. Black Coins (Player 2)
      _CarromPiece(
        pos: center + Offset(-d * 0.707, -d * 0.707),
        radius: coinRadius,
        color: const Color(0xFF1E293B),
        points: 10,
        isWhite: false,
      ),
      _CarromPiece(
        pos: center + Offset(d * 0.707, -d * 0.707),
        radius: coinRadius,
        color: const Color(0xFF1E293B),
        points: 10,
        isWhite: false,
      ),
      _CarromPiece(
        pos: center + Offset(-d * 0.707, d * 0.707),
        radius: coinRadius,
        color: const Color(0xFF1E293B),
        points: 10,
        isWhite: false,
      ),
      _CarromPiece(
        pos: center + Offset(d * 0.707, d * 0.707),
        radius: coinRadius,
        color: const Color(0xFF1E293B),
        points: 10,
        isWhite: false,
      ),
    ];

    _activePlayer = 1;
    _p1Score = 0;
    _p2Score = 0;
    _soloScore = 0;
    _shotsRemaining = 10;
    _extraTurn = false;
    _turnFeedback = _mode == CarromGameMode.twoPlayer
        ? 'Player 1 (White)\'s Turn — Slide baseline & aim!'
        : 'Solo Practice — Pocket coins to score high!';
    _gameOver = false;
    _winnerText = '';

    _resetStriker();
  }

  double _getStrikerY() {
    if (_mode == CarromGameMode.twoPlayer && _activePlayer == 2) {
      // Player 2 strikes from the top baseline
      return 56.0;
    }
    // Player 1 or Solo strikes from the bottom baseline
    return _boardSize - 56.0;
  }

  void _resetStriker() {
    final minX = 72.0;
    final maxX = _boardSize - 72.0;
    final posX = minX + (_strikerXPercent * (maxX - minX));
    final posY = _getStrikerY();

    _striker = _CarromPiece(
      pos: Offset(posX, posY),
      vel: Offset.zero,
      radius: _boardSize * 0.047, // ~16px
      color: _activePlayer == 1 ? const Color(0xFF7E52FF) : const Color(0xFFFF5252),
      points: 0,
    );
    _isShooting = false;
  }

  void _updatePhysics() {
    if (_gameOver) return;

    bool anyMoving = false;
    final allPieces = [_striker, ..._coins.where((c) => !c.isPocketed)];

    bool scoredThisTurn = false;
    bool foulThisTurn = false;

    for (final p in allPieces) {
      if (p.vel.distance > 0.08) {
        anyMoving = true;
        p.pos += p.vel;
        p.vel *= 0.968; // Smooth wooden surface friction

        // Cushion Border bounce (with elastic response)
        final margin = p.radius + 14.0;
        if (p.pos.dx < margin) {
          p.pos = Offset(margin, p.pos.dy);
          p.vel = Offset(-p.vel.dx * 0.78, p.vel.dy);
        } else if (p.pos.dx > _boardSize - margin) {
          p.pos = Offset(_boardSize - margin, p.pos.dy);
          p.vel = Offset(-p.vel.dx * 0.78, p.vel.dy);
        }

        if (p.pos.dy < margin) {
          p.pos = Offset(p.pos.dx, margin);
          p.vel = Offset(p.vel.dx, -p.vel.dy * 0.78);
        } else if (p.pos.dy > _boardSize - margin) {
          p.pos = Offset(p.pos.dx, _boardSize - margin);
          p.vel = Offset(p.vel.dx, -p.vel.dy * 0.78);
        }

        // Pocket checking
        for (final pocket in _pockets) {
          if ((p.pos - pocket).distance < _pocketRadius) {
            p.vel = Offset.zero;
            p.pos = const Offset(-200, -200);
            p.isPocketed = true;

            if (p == _striker) {
              foulThisTurn = true;
            } else {
              scoredThisTurn = true;
              _handleCoinPocketed(p);
            }
          }
        }
      } else {
        p.vel = Offset.zero;
      }
    }

    // Pairwise elastic coin collisions
    for (int i = 0; i < allPieces.length; i++) {
      for (int j = i + 1; j < allPieces.length; j++) {
        final a = allPieces[i];
        final b = allPieces[j];
        if (a.isPocketed || b.isPocketed) continue;

        final delta = b.pos - a.pos;
        final dist = delta.distance;
        final minDist = a.radius + b.radius;

        if (dist < minDist && dist > 0.001) {
          final normal = delta / dist;
          // Separation
          final overlap = minDist - dist;
          a.pos -= normal * (overlap / 2);
          b.pos += normal * (overlap / 2);

          // Elastic collision velocity swap
          final k = a.vel - b.vel;
          final p = 2 * (normal.dx * k.dx + normal.dy * k.dy) / 2.0;

          a.vel -= normal * p * 0.88;
          b.vel += normal * p * 0.88;
        }
      }
    }

    // Turn Completion & Switch logic
    if (_isShooting && !anyMoving) {
      _isShooting = false;
      _onShotFinished(scoredThisTurn, foulThisTurn);
    }

    setState(() {});
  }

  void _handleCoinPocketed(_CarromPiece coin) {
    if (_mode == CarromGameMode.solo) {
      _soloScore += coin.points;
      _turnFeedback = 'Sunk ${coin.isQueen ? "Queen 👑 (+25)!" : "Coin (+${coin.points})!"}';
      return;
    }

    // 2-Player rules
    if (coin.isQueen) {
      if (_activePlayer == 1) {
        _p1Score += 25;
        _turnFeedback = 'Player 1 pocketed the Queen 👑 (+25)!';
      } else {
        _p2Score += 25;
        _turnFeedback = 'Player 2 pocketed the Queen 👑 (+25)!';
      }
      _extraTurn = true;
    } else if (coin.isWhite) {
      // White coin
      _p1Score += 10;
      if (_activePlayer == 1) {
        _extraTurn = true;
        _turnFeedback = 'Player 1 scored White (+10)! Extra Turn 🎯';
      } else {
        _turnFeedback = 'Player 2 sank P1\'s White coin (+10 to P1)';
      }
    } else {
      // Black coin
      _p2Score += 10;
      if (_activePlayer == 2) {
        _extraTurn = true;
        _turnFeedback = 'Player 2 scored Black (+10)! Extra Turn 🎯';
      } else {
        _turnFeedback = 'Player 1 sank P2\'s Black coin (+10 to P2)';
      }
    }
  }

  void _onShotFinished(bool scored, bool foul) {
    if (_mode == CarromGameMode.solo) {
      _shotsRemaining--;
      if (_shotsRemaining <= 0 || _coins.every((c) => c.isPocketed)) {
        _gameOver = true;
        _winnerText = 'Challenge Complete! Score: $_soloScore pts';
        StorageService.setPersonalBest('mini_carrom', _soloScore);
      } else {
        _resetStriker();
      }
      return;
    }

    // 2-Player Mode handling
    if (foul) {
      // Striker sunk: Foul
      if (_activePlayer == 1) {
        _p1Score = max(0, _p1Score - 5);
        _turnFeedback = '⚠️ FOUL! P1 sank Striker (-5). Turn passes!';
      } else {
        _p2Score = max(0, _p2Score - 5);
        _turnFeedback = '⚠️ FOUL! P2 sank Striker (-5). Turn passes!';
      }
      _extraTurn = false;
    }

    // Check if match over
    final remainingCoins = _coins.where((c) => !c.isPocketed).toList();
    if (remainingCoins.isEmpty) {
      _gameOver = true;
      if (_p1Score > _p2Score) {
        _winnerText = '🏆 PLAYER 1 WINS! ($_p1Score - $_p2Score)';
      } else if (_p2Score > _p1Score) {
        _winnerText = '🏆 PLAYER 2 WINS! ($_p2Score - $_p1Score)';
      } else {
        _winnerText = '🤝 DRAW MATCH! ($_p1Score pts each)';
      }
      return;
    }

    // Check turns
    if (!_extraTurn) {
      // Pass turn to the other player
      _activePlayer = _activePlayer == 1 ? 2 : 1;
      _turnFeedback = _activePlayer == 1
          ? 'Player 1\'s Turn (White ⚪) — Place striker & shoot!'
          : 'Player 2\'s Turn (Black ⚫) — Place striker & shoot!';
    } else {
      _extraTurn = false; // Used the extra turn bonus
    }

    _resetStriker();
  }

  // ─── TOUCH & AIMING ──────────────────────────────────────────
  void _onPanStart(DragStartDetails details) {
    if (_isShooting || _gameOver) return;
    _dragStart = details.localPosition;
    _dragCurrent = details.localPosition;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_dragStart == null) return;
    setState(() => _dragCurrent = details.localPosition);
  }

  void _onPanEnd(DragEndDetails details) {
    if (_dragStart == null || _dragCurrent == null) return;

    final diff = _dragStart! - _dragCurrent!;
    final dist = diff.distance;

    if (dist < 8.0) {
      // Too small, ignore accidental tap
      setState(() {
        _dragStart = null;
        _dragCurrent = null;
      });
      return;
    }

    final speed = dist.clamp(10.0, 160.0) * 0.17;
    final angle = atan2(diff.dy, diff.dx);

    setState(() {
      _striker.vel = Offset(cos(angle) * speed, sin(angle) * speed);
      _isShooting = true;
      _dragStart = null;
      _dragCurrent = null;
    });
  }

  @override
  void dispose() {
    _physicsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF180D08),
      body: RealisticWoodTableSurface(
        isDarkWood: true,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              // Dynamically adapt board size to ANY screen without overflow
              final maxAllowedWidth = constraints.maxWidth - 24;
              final maxAllowedHeight = constraints.maxHeight - 210; // Leaves space for header, scores, sliders
              final boardDimension = min(maxAllowedWidth, maxAllowedHeight).clamp(270.0, 420.0);

              if ((_boardSize - boardDimension).abs() > 2.0) {
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (mounted) {
                    setState(() {
                      _boardSize = boardDimension;
                      _pocketRadius = _boardSize * 0.065;
                      _setupBoard();
                    });
                  }
                });
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  child: Column(
                    children: [
                      // ─── 1. TOP APP BAR & MODE SELECTOR ───
                      _buildTopBar(),

                      const SizedBox(height: 6),

                      // ─── 2. DUAL PLAYER SCOREBOARD / STATS ───
                      _mode == CarromGameMode.twoPlayer
                          ? _buildTwoPlayerScoreboard()
                          : _buildSoloScoreboard(),

                      const SizedBox(height: 6),

                      // ─── 3. TURN & STATUS BANNER ───
                      _buildStatusPill(),

                      const SizedBox(height: 6),

                      // ─── 4. CARROM POOL PLAYING BOARD ───
                      Center(
                        child: Container(
                          width: _boardSize,
                          height: _boardSize,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            child: RealisticCarromBoardWidget(
                              boardSize: _boardSize,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  // 4 Corner Deep Net Pockets
                                  ..._pockets.map((p) => Positioned(
                                    left: p.dx - _pocketRadius,
                                    top: p.dy - _pocketRadius,
                                    child: Container(
                                      width: _pocketRadius * 2,
                                      height: _pocketRadius * 2,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const RadialGradient(
                                          colors: [
                                            Color(0xFF000000),
                                            Color(0xFF160902),
                                            Color(0xFF2E170B),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.85),
                                            blurRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )),

                                  // Realistic Aiming & Reflection Laser Guideline
                                  if (_dragStart != null && _dragCurrent != null && !_isShooting)
                                    CustomPaint(
                                      size: Size(_boardSize, _boardSize),
                                      painter: _CarromLaserAimPainter(
                                        strikerPos: _striker.pos,
                                        dragStart: _dragStart!,
                                        dragCurrent: _dragCurrent!,
                                        boardSize: _boardSize,
                                      ),
                                    ),

                                  // Carrom Coins (Ivory White, Ebony Black & Red Queen)
                                  ..._coins.where((c) => !c.isPocketed).map((c) => Positioned(
                                    left: c.pos.dx - c.radius,
                                    top: c.pos.dy - c.radius,
                                    child: RealisticCarromCoin(
                                      radius: c.radius,
                                      isQueen: c.isQueen,
                                      isWhite: c.isWhite,
                                    ),
                                  )),

                                  // Realistic 3D Striker Puck
                                  if (!_striker.isPocketed)
                                    Positioned(
                                      left: _striker.pos.dx - _striker.radius,
                                      top: _striker.pos.dy - _striker.radius,
                                      child: RealisticCarromStriker(
                                        radius: _striker.radius,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // ─── 5. INTERACTIVE STRIKER BASELINE SLIDER ───
                      if (!_isShooting && !_gameOver)
                        _buildStrikerPositionSlider(),

                      // ─── 6. GAME OVER / WIN BANNER ───
                      if (_gameOver)
                        _buildGameOverBanner(),

                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ─── SUBWIDGETS ───────────────────────────────────────────────

  Widget _buildTopBar() {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        Expanded(
          child: Column(
            children: [
              Text(
                'Real Carrom Pool',
                style: AppTypography.heading3.copyWith(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 2),
              // Game Mode Toggle
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildModeButton(CarromGameMode.twoPlayer, '👥 2P Duel'),
                    _buildModeButton(CarromGameMode.solo, '🎯 Solo Practice'),
                  ],
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.replay_rounded, color: Color(0xFFFFD53D), size: 24),
          tooltip: 'Reset Board',
          onPressed: () => setState(_setupBoard),
        ),
      ],
    );
  }

  Widget _buildModeButton(CarromGameMode mode, String label) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () {
        if (_mode != mode) {
          setState(() {
            _mode = mode;
            _setupBoard();
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF7E52FF) : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : Colors.white70,
          ),
        ),
      ),
    );
  }

  Widget _buildTwoPlayerScoreboard() {
    final whiteLeft = _coins.where((c) => !c.isPocketed && c.isWhite).length;
    final blackLeft = _coins.where((c) => !c.isPocketed && !c.isWhite && !c.isQueen).length;
    final queenPocketed = _coins.any((c) => c.isPocketed && c.isQueen);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _activePlayer == 1 ? const Color(0xFF7E52FF) : const Color(0xFFFF5252),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Player 1 (White)
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(color: Colors.black45, width: 2),
                ),
                child: const Center(child: Text('⚪', style: TextStyle(fontSize: 10))),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Player 1 (White)',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      if (_activePlayer == 1)
                        const Text(' ⚡', style: TextStyle(fontSize: 12)),
                    ],
                  ),
                  Text(
                    '$_p1Score pts • $whiteLeft left',
                    style: const TextStyle(color: Color(0xFFFFD53D), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),

          // Queen indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: queenPocketed ? const Color(0xFF22C55E).withOpacity(0.2) : Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: queenPocketed ? const Color(0xFF22C55E) : Colors.red),
            ),
            child: Text(
              queenPocketed ? 'Queen Claimed 👑' : 'Queen Center 👑',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: queenPocketed ? const Color(0xFF22C55E) : const Color(0xFFFF8A80),
              ),
            ),
          ),

          // Player 2 (Black)
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      if (_activePlayer == 2)
                        const Text('⚡ ', style: TextStyle(fontSize: 12)),
                      const Text(
                        'Player 2 (Black)',
                        style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Text(
                    '$_p2Score pts • $blackLeft left',
                    style: const TextStyle(color: Color(0xFFFFD53D), fontSize: 11, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF1E293B),
                  border: Border.all(color: Colors.white54, width: 2),
                ),
                child: const Center(child: Text('⚫', style: TextStyle(fontSize: 10))),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSoloScoreboard() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white24),
          ),
          child: Text('Score: $_soloScore pts', style: AppTypography.monoMedium.copyWith(color: const Color(0xFFFFD53D), fontSize: 14)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFFFD53D)),
          ),
          child: Text('Shots Left: $_shotsRemaining', style: AppTypography.labelSmall.copyWith(color: const Color(0xFFFFD53D))),
        ),
      ],
    );
  }

  Widget _buildStatusPill() {
    final isP1 = _activePlayer == 1;
    final pillColor = _mode == CarromGameMode.solo
        ? const Color(0xFF7E52FF)
        : (isP1 ? const Color(0xFF7E52FF) : const Color(0xFFFF5252));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: pillColor.withOpacity(0.18),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: pillColor.withOpacity(0.5)),
      ),
      child: Text(
        _turnFeedback,
        style: TextStyle(
          color: Colors.white.withOpacity(0.95),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildStrikerPositionSlider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          const Icon(Icons.arrow_left_rounded, color: Colors.white70),
          const Text('Place Striker: ', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w600)),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: _activePlayer == 1 ? const Color(0xFF7E52FF) : const Color(0xFFFF5252),
                inactiveTrackColor: Colors.white24,
                thumbColor: Colors.white,
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              ),
              child: Slider(
                value: _strikerXPercent,
                min: 0.0,
                max: 1.0,
                onChanged: (val) {
                  setState(() {
                    _strikerXPercent = val;
                    _resetStriker();
                  });
                },
              ),
            ),
          ),
          const Icon(Icons.arrow_right_rounded, color: Colors.white70),
        ],
      ),
    );
  }

  Widget _buildGameOverBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFD53D), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFD53D).withOpacity(0.3),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _winnerText,
            style: const TextStyle(
              color: Color(0xFFFFD53D),
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            icon: const Icon(Icons.replay_rounded, color: Colors.black),
            label: const Text('Play Rematch', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD53D),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => setState(_setupBoard),
          ),
        ],
      ),
    );
  }
}

/// Precise Laser Guideline with Cushion Wall-Bounce Reflection
class _CarromLaserAimPainter extends CustomPainter {
  final Offset strikerPos;
  final Offset dragStart;
  final Offset dragCurrent;
  final double boardSize;

  _CarromLaserAimPainter({
    required this.strikerPos,
    required this.dragStart,
    required this.dragCurrent,
    required this.boardSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final diff = dragStart - dragCurrent;
    final power = diff.distance.clamp(10.0, 160.0);
    final angle = atan2(diff.dy, diff.dx);

    // Primary Aim Trajectory
    final directLength = power * 1.8;
    final primaryTarget = strikerPos + Offset(cos(angle) * directLength, sin(angle) * directLength);

    // Guideline styling: Glow laser with power color
    final powerRatio = (power / 160.0).clamp(0.0, 1.0);
    final aimColor = Color.lerp(const Color(0xFF22C55E), const Color(0xFFFF5252), powerRatio)!;

    final laserPaint = Paint()
      ..color = aimColor.withOpacity(0.85)
      ..strokeWidth = 2.4
      ..style = PaintingStyle.stroke;

    final dashPaint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 1.5;

    // Draw main aim line
    canvas.drawLine(strikerPos, primaryTarget, laserPaint);

    // Draw target sight circle
    canvas.drawCircle(primaryTarget, 5, Paint()..color = aimColor);
    canvas.drawCircle(primaryTarget, 2, dashPaint);

    // Compute wall reflection if aiming toward edges
    const margin = 20.0;
    if (primaryTarget.dx < margin || primaryTarget.dx > boardSize - margin ||
        primaryTarget.dy < margin || primaryTarget.dy > boardSize - margin) {
      // Wall bounce ray
      double reflectAngle = angle;
      if (primaryTarget.dx < margin || primaryTarget.dx > boardSize - margin) {
        reflectAngle = pi - angle;
      } else {
        reflectAngle = -angle;
      }

      final bounceTarget = primaryTarget + Offset(cos(reflectAngle) * 50, sin(reflectAngle) * 50);
      final bouncePaint = Paint()
        ..color = aimColor.withOpacity(0.4)
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke;

      canvas.drawLine(primaryTarget, bounceTarget, bouncePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _CarromLaserAimPainter old) =>
      old.dragCurrent != dragCurrent || old.dragStart != dragStart || old.boardSize != boardSize;
}
