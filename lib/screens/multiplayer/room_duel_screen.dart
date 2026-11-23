import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/game_provider.dart';
import '../../models/game_models.dart';
import '../../services/room_service.dart';

class RoomDuelScreen extends StatefulWidget {
  const RoomDuelScreen({super.key});

  @override
  State<RoomDuelScreen> createState() => _RoomDuelScreenState();
}

class _RoomDuelScreenState extends State<RoomDuelScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _codeController = TextEditingController();

  // Hosting state
  DuelRoom? _activeRoom;
  bool _isWaiting = false;
  int _secondsRemaining = 60;
  Timer? _countdownTimer;
  Timer? _pollingTimer;

  // Match transition state
  bool _matchStarting = false;
  int _startCountdown = 3;
  Timer? _matchStartTimer;
  DuelRoom? _connectedRoom;

  // Settings for hosting
  Difficulty _roomDifficulty = Difficulty.medium;
  int _questionCount = 10;
  bool _isCreatingRoom = false;
  bool _isJoiningRoom = false;

  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();
    _matchStartTimer?.cancel();
    _pulseController.dispose();
    _codeController.dispose();

    // If host leaves with an open waiting room, close it
    if (_activeRoom != null && _isWaiting) {
      RoomService.closeRoom(_activeRoom!.roomId);
    }
    super.dispose();
  }

  // ─── 1. HOST: CREATE PRIVATE ROOM ───────────────────────────
  Future<void> _createRoom() async {
    if (_isCreatingRoom) return;
    setState(() => _isCreatingRoom = true);

    final provider = context.read<GameProvider>();
    final hostName = provider.profile.username.isNotEmpty ? provider.profile.username : 'Player 1';
    final hostAvatar = provider.profile.avatarEmoji ?? '🧠';

    try {
      final room = await RoomService.createRoom(
        hostName: hostName,
        hostAvatar: hostAvatar,
        difficulty: _roomDifficulty,
        questionCount: _questionCount,
        timeoutSeconds: 60,
      );

      setState(() {
        _activeRoom = room;
        _isWaiting = true;
        _secondsRemaining = 60;
        _isCreatingRoom = false;
      });

      _startHostWaitingLoops(room.roomId);
    } catch (e) {
      setState(() => _isCreatingRoom = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create room: $e')),
        );
      }
    }
  }

  void _startHostWaitingLoops(String roomId) {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();

    // Countdown timer (60s)
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_secondsRemaining > 1) {
        setState(() => _secondsRemaining--);
      } else {
        // TIMEOUT: No opponent joined!
        timer.cancel();
        _pollingTimer?.cancel();
        _handleRoomTimeout(roomId);
      }
    });

    // Polling loop to detect when a real opponent enters the Room ID (every 750ms)
    _pollingTimer = Timer.periodic(const Duration(milliseconds: 750), (timer) async {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final room = await RoomService.getRoom(roomId);
      if (room == null || !mounted) return;

      if (room.status == RoomStatus.joined && room.guestName != null) {
        // OPPONENT JOINED VIA ROOM ID!
        timer.cancel();
        _countdownTimer?.cancel();
        _startMatchCountdown(room);
      } else if (room.status == RoomStatus.closed || room.status == RoomStatus.expired) {
        timer.cancel();
        _countdownTimer?.cancel();
        if (_isWaiting) {
          _handleRoomTimeout(roomId);
        }
      }
    });
  }

  void _handleRoomTimeout(String roomId) {
    RoomService.closeRoom(roomId, isTimeout: true);

    setState(() {
      _isWaiting = false;
      _activeRoom = null;
    });

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Text('⏰', style: TextStyle(fontSize: 28)),
            SizedBox(width: 10),
            Text('Room Closed', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1842))),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'No opponent joined room $roomId within 60 seconds.',
              style: const TextStyle(fontSize: 15, color: Color(0xFF1E1842), height: 1.4),
            ),
            const SizedBox(height: 10),
            const Text(
              'The room has been safely closed. Share the Room ID with your friend first so they can join promptly.',
              style: TextStyle(fontSize: 13, color: Color(0xFF8680A6)),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7E52FF),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _cancelAndCloseRoom() {
    _countdownTimer?.cancel();
    _pollingTimer?.cancel();

    if (_activeRoom != null) {
      RoomService.closeRoom(_activeRoom!.roomId);
    }

    setState(() {
      _isWaiting = false;
      _activeRoom = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Room cancelled and closed.')),
    );
  }

  // ─── 2. GUEST: JOIN EXISTING ROOM ───────────────────────────
  Future<void> _joinRoom() async {
    final inputCode = _codeController.text.trim();
    if (inputCode.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a 4-digit Room ID to join.')),
      );
      return;
    }

    setState(() => _isJoiningRoom = true);
    final provider = context.read<GameProvider>();
    final guestName = provider.profile.username.isNotEmpty ? provider.profile.username : 'Player 2';
    final guestAvatar = provider.profile.avatarEmoji ?? '⚡';

    final result = await RoomService.joinRoom(
      rawRoomId: inputCode,
      guestName: guestName,
      guestAvatar: guestAvatar,
    );

    setState(() => _isJoiningRoom = false);

    if (!mounted) return;

    if (!result.success || result.room == null) {
      // Show error dialog
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: const [
              Text('⚠️', style: TextStyle(fontSize: 26)),
              SizedBox(width: 10),
              Text('Cannot Join Room', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E1842))),
            ],
          ),
          content: Text(
            result.errorMessage ?? 'Unable to connect to room. Please check the code.',
            style: const TextStyle(color: Color(0xFF1E1842), fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7E52FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('OK', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      );
      return;
    }

    // Successfully connected to host!
    _startMatchCountdown(result.room!);
  }

  // ─── 3. MATCH READY COUNTDOWN (Both Players) ────────────────
  void _startMatchCountdown(DuelRoom room) {
    setState(() {
      _connectedRoom = room;
      _matchStarting = true;
      _startCountdown = 3;
    });

    _matchStartTimer?.cancel();
    _matchStartTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_startCountdown > 1) {
        setState(() => _startCountdown--);
      } else {
        timer.cancel();
        _launchDuelGame(room);
      }
    });
  }

  void _launchDuelGame(DuelRoom room) {
    final provider = context.read<GameProvider>();
    final myName = provider.profile.username;

    // Determine opponent's name & avatar (never AI / bot!)
    final isHost = myName == room.hostName;
    final opponentName = isHost ? (room.guestName ?? 'Opponent') : room.hostName;
    final opponentAvatar = isHost ? (room.guestAvatar ?? '⚡') : room.hostAvatar;

    provider.startDuel(
      questionCount: room.questionCount,
      isRoomMatch: true,
      opponentName: opponentName,
      opponentEmoji: opponentAvatar,
      roomId: room.roomId,
      seed: room.seed,
      difficulty: room.difficulty,
    );

    Navigator.of(context).pushReplacementNamed('/duel-game');
  }

  void _copyRoomCode(String code) {
    Clipboard.setData(ClipboardData(text: code));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Room ID $code copied to clipboard! Share it with your friend.'),
        backgroundColor: const Color(0xFF7E52FF),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppColors.primaryBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
              onPressed: () {
                if (_isWaiting && _activeRoom != null) {
                  _cancelAndCloseRoom();
                }
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              '1v1 Room Duel',
              style: AppTypography.heading4.copyWith(color: AppColors.primaryText, fontWeight: FontWeight.w800),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Notice Header
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF7E52FF).withOpacity(0.06),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('🔑', style: TextStyle(fontSize: 22)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Play against real friends! Share your Room ID or enter a friend\'s code to join.',
                            style: AppTypography.bodySmall.copyWith(
                              color: const Color(0xFF1E1842),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // If match is starting countdown (both players)
                  if (_matchStarting && _connectedRoom != null)
                    _buildMatchStartingCard(_connectedRoom!)
                  // If host is waiting for guest
                  else if (_isWaiting && _activeRoom != null)
                    _buildHostWaitingCard(_activeRoom!)
                  // Normal State: Option to Host or Join
                  else ...[
                    _buildHostCard(provider),
                    const SizedBox(height: 22),
                    _buildJoinCard(),
                  ],

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── CARD A: MATCH STARTING OVERLAY ──────────────────────────
  Widget _buildMatchStartingCard(DuelRoom room) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF75D826), width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF75D826).withOpacity(0.2),
            blurRadius: 25,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF75D826).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'OPPONENT CONNECTED! ⚔️',
              style: const TextStyle(
                color: Color(0xFF4CA010),
                fontWeight: FontWeight.w800,
                fontSize: 12,
                letterSpacing: 1,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // VS Matchup Avatars
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Host
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFEADBFF),
                      border: Border.all(color: const Color(0xFF7E52FF), width: 3),
                    ),
                    child: Center(child: Text(room.hostAvatar, style: const TextStyle(fontSize: 32))),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.hostName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E1842)),
                  ),
                  const Text('Host', style: TextStyle(fontSize: 11, color: Color(0xFF8680A6))),
                ],
              ),

              // VS Badge
              Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFFFF5252),
                ),
                child: const Text('VS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
              ),

              // Guest
              Column(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFFFE5EC),
                      border: Border.all(color: const Color(0xFFFF5252), width: 3),
                    ),
                    child: Center(child: Text(room.guestAvatar ?? '⚡', style: const TextStyle(fontSize: 32))),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    room.guestName ?? 'Opponent',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF1E1842)),
                  ),
                  const Text('Opponent', style: TextStyle(fontSize: 11, color: Color(0xFF8680A6))),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Countdown Pill
          Text(
            'Duel starting in',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 6),
          Text(
            '$_startCountdown',
            style: const TextStyle(
              fontSize: 52,
              fontWeight: FontWeight.w900,
              color: Color(0xFF7E52FF),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Room ID: ${room.roomId} Verified ✓',
            style: const TextStyle(color: Color(0xFF75D826), fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── CARD B: HOST WAITING FOR OPPONENT ───────────────────────
  Widget _buildHostWaitingCard(DuelRoom room) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7E52FF).withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E52FF).withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, _) => Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF7E52FF),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF7E52FF).withOpacity(0.4 + _pulseController.value * 0.4),
                            blurRadius: 8 + _pulseController.value * 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'WAITING FOR OPPONENT',
                    style: TextStyle(
                      color: Color(0xFF7E52FF),
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),

              // Countdown badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _secondsRemaining <= 10 ? const Color(0xFFFFECEC) : const Color(0xFFEFEBFE),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 14,
                      color: _secondsRemaining <= 10 ? const Color(0xFFFF5252) : const Color(0xFF7E52FF),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${_secondsRemaining}s',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: _secondsRemaining <= 10 ? const Color(0xFFFF5252) : const Color(0xFF7E52FF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Big Room ID Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF7F3FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF7E52FF).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Text(
                  'YOUR ROOM ID',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF8680A6), letterSpacing: 1.5),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      room.roomId,
                      style: const TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF7E52FF),
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton(
                      icon: const Icon(Icons.copy_rounded, color: Color(0xFF7E52FF), size: 26),
                      tooltip: 'Copy Room ID',
                      onPressed: () => _copyRoomCode(room.roomId),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tell your friend to enter this Room ID in their app',
                  style: TextStyle(fontSize: 12, color: Color(0xFF8680A6)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Radar indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7E52FF)),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Waiting for friend to join with Room ID...',
                style: AppTypography.bodySmall.copyWith(
                  color: const Color(0xFF1E1842),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Action Buttons: Share & Cancel
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.share_rounded, size: 18, color: Color(0xFF7E52FF)),
                  label: const Text('Share Code', style: TextStyle(color: Color(0xFF7E52FF), fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: Color(0xFF7E52FF)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () => _copyRoomCode(room.roomId),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.close_rounded, size: 18, color: Colors.white),
                  label: const Text('Cancel & Close', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFFFF5252),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _cancelAndCloseRoom,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Developer Quick Test Shortcut (Allows instant test of join flow on 1 device)
          InkWell(
            onTap: () async {
              await RoomService.simulateRivalJoin(room.roomId, rivalName: 'Alex (Rival) ⚡');
            },
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEFEBFE),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF7E52FF).withOpacity(0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🧪', style: TextStyle(fontSize: 14)),
                  SizedBox(width: 6),
                  Text(
                    'Test: Simulate Rival Player Join (Instant Test)',
                    style: TextStyle(fontSize: 11, color: Color(0xFF7E52FF), fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── CARD C: HOST SETUP FORM ─────────────────────────────────
  Widget _buildHostCard(GameProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF7E52FF).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E52FF).withOpacity(0.08),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEBFE),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('⚔️', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Host Private Duel Room',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E1842),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Get a 4-digit Room ID for your opponent to join.',
                      style: AppTypography.bodySmall.copyWith(color: const Color(0xFF8680A6)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFEFEAF9)),
          const SizedBox(height: 16),

          // Difficulty Selector
          const Text(
            'Match Difficulty',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E1842)),
          ),
          const SizedBox(height: 8),
          Row(
            children: Difficulty.values.map((d) {
              final isSel = d == _roomDifficulty;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _roomDifficulty = d),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF7E52FF) : const Color(0xFFF7F3FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel ? const Color(0xFF7E52FF) : const Color(0xFFEFEAF9),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        d.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : const Color(0xFF1E1842),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),

          // Rounds Selector
          const Text(
            'Number of Questions',
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E1842)),
          ),
          const SizedBox(height: 8),
          Row(
            children: [5, 10, 15].map((cnt) {
              final isSel = cnt == _questionCount;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _questionCount = cnt),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: isSel ? const Color(0xFF7E52FF) : const Color(0xFFF7F3FF),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel ? const Color(0xFF7E52FF) : const Color(0xFFEFEAF9),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$cnt Qs',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: isSel ? Colors.white : const Color(0xFF1E1842),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 22),

          // Host Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: _isCreatingRoom
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.add_circle_outline_rounded, color: Colors.white),
              label: Text(
                _isCreatingRoom ? 'Generating Room...' : 'Create Room Code ⚔️',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7E52FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: const Color(0xFF7E52FF).withOpacity(0.4),
              ),
              onPressed: _isCreatingRoom ? null : _createRoom,
            ),
          ),
        ],
      ),
    );
  }

  // ─── CARD D: JOIN EXISTING ROOM ─────────────────────────────
  Widget _buildJoinCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFF5252).withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5252).withOpacity(0.06),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFECEC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Text('🔑', style: TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Join Room with Code',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF1E1842),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Enter your friend\'s Room ID to join their duel.',
                      style: AppTypography.bodySmall.copyWith(color: const Color(0xFF8680A6)),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Text Field for Room ID
          TextField(
            controller: _codeController,
            textCapitalization: TextCapitalization.characters,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: Color(0xFF1E1842),
            ),
            decoration: InputDecoration(
              hintText: 'e.g. NURO-4892',
              hintStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.normal,
                letterSpacing: 0,
                color: Colors.grey.shade400,
              ),
              prefixIcon: const Icon(Icons.pin_rounded, color: Color(0xFFFF5252)),
              suffixIcon: IconButton(
                icon: const Icon(Icons.paste_rounded, color: Color(0xFF8680A6)),
                tooltip: 'Paste from Clipboard',
                onPressed: () async {
                  final data = await Clipboard.getData('text/plain');
                  if (data?.text != null) {
                    setState(() {
                      _codeController.text = data!.text!.trim();
                    });
                  }
                },
              ),
              filled: true,
              fillColor: const Color(0xFFF7F3FF),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Color(0xFFFF5252), width: 2),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Join Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              icon: _isJoiningRoom
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.login_rounded, color: Colors.white),
              label: Text(
                _isJoiningRoom ? 'Connecting to Room...' : 'Join Duel Room 🔑',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5252),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                shadowColor: const Color(0xFFFF5252).withOpacity(0.4),
              ),
              onPressed: _isJoiningRoom ? null : _joinRoom,
            ),
          ),
        ],
      ),
    );
  }
}
