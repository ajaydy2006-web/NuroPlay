import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../services/storage_service.dart';

class CupPongGame extends StatefulWidget {
  const CupPongGame({super.key});

  @override
  State<CupPongGame> createState() => _CupPongGameState();
}

class _PongCup {
  final int id;
  final Offset pos;
  bool isCleared;

  _PongCup({required this.id, required this.pos, this.isCleared = false});
}

class _CupPongGameState extends State<CupPongGame> with SingleTickerProviderStateMixin {
  late AnimationController _physicsTicker;

  // Virtual table dimensions for consistent physics & scaling on all phone screens
  static const double _vWidth = 340.0;
  static const double _vHeight = 520.0;

  // Ball 3D state: x, y (virtual coords), z (height/depth)
  Offset _ballScreenPos = const Offset(_vWidth / 2, 460);
  double _ballScale = 1.0;
  Offset _ballVel = Offset.zero;
  double _ballVelZ = 0.0;
  double _ballZ = 0.0;
  bool _isBallInAir = false;

  Offset? _dragStart;
  Offset? _dragCurrent;

  int _ballsRemaining = 10;
  int _score = 0;
  bool _isTwoPlayer = false;
  int _currentPlayer = 1;
  int _player1Score = 0;
  int _player2Score = 0;
  String _status = 'Swipe up or drag back to throw the ping pong ball!';

  late List<_PongCup> _cups;

  @override
  void initState() {
    super.initState();
    _physicsTicker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_updatePhysics)
      ..repeat();

    _setupCups();
  }

  void _setupCups() {
    _cups = [
      _PongCup(id: 1, pos: const Offset(_vWidth / 2 - 46, 110)),
      _PongCup(id: 2, pos: const Offset(_vWidth / 2, 110)),
      _PongCup(id: 3, pos: const Offset(_vWidth / 2 + 46, 110)),
      _PongCup(id: 4, pos: const Offset(_vWidth / 2 - 23, 150)),
      _PongCup(id: 5, pos: const Offset(_vWidth / 2 + 23, 150)),
      _PongCup(id: 6, pos: const Offset(_vWidth / 2, 190)),
    ];

    _resetBall();
    _ballsRemaining = _isTwoPlayer ? 6 : 10;
    _score = 0;
    _currentPlayer = 1;
    _player1Score = 0;
    _player2Score = 0;
    _status = _isTwoPlayer
        ? 'Player 1 Turn! Sink cups with 6 balls!'
        : 'Swipe up or drag back to throw the ping pong ball!';
  }

  void _setupCupsForPlayer2() {
    setState(() {
      _cups = [
        _PongCup(id: 1, pos: const Offset(_vWidth / 2 - 46, 110)),
        _PongCup(id: 2, pos: const Offset(_vWidth / 2, 110)),
        _PongCup(id: 3, pos: const Offset(_vWidth / 2 + 46, 110)),
        _PongCup(id: 4, pos: const Offset(_vWidth / 2 - 23, 150)),
        _PongCup(id: 5, pos: const Offset(_vWidth / 2 + 23, 150)),
        _PongCup(id: 6, pos: const Offset(_vWidth / 2, 190)),
      ];
      _ballsRemaining = 6;
      _score = 0;
      _resetBall();
      _status = 'Player 2 Turn! Sink cups to beat $_player1Score pts!';
    });
  }

  void _resetBall() {
    setState(() {
      _ballScreenPos = const Offset(_vWidth / 2, 460);
      _ballScale = 1.0;
      _ballVel = Offset.zero;
      _ballVelZ = 0.0;
      _ballZ = 0.0;
      _isBallInAir = false;
      _dragStart = null;
      _dragCurrent = null;
    });
  }

  void _updatePhysics() {
    if (!_isBallInAir) return;

    setState(() {
      _ballScreenPos += _ballVel;
      _ballZ += _ballVelZ;
      _ballVelZ -= 0.6; // Gravity acting on height
      _ballScale = (1.0 - (_ballScreenPos.dy < 460 ? (460 - _ballScreenPos.dy) * 0.0013 : 0)).clamp(0.4, 1.2);

      // When ball reaches table level at the top end (y <= 220 and descending z)
      if (_ballVelZ <= 0 && _ballScreenPos.dy <= 220) {
        _checkCupCollision();
      }

      // Ball missed / landed past virtual bounds
      if (_ballScreenPos.dy < 40 || _ballScreenPos.dy > 510 || _ballScreenPos.dx < 30 || _ballScreenPos.dx > 310) {
        _isBallInAir = false;
        _status = 'Missed! Adjust angle & power.';
        _decrementBall();
      }
    });
  }

  void _checkCupCollision() {
    for (final cup in _cups.where((c) => !c.isCleared)) {
      final dist = (_ballScreenPos - cup.pos).distance;
      if (dist < 26.0) {
        _isBallInAir = false;
        cup.isCleared = true;
        _score += 100;
        _status = 'SPLASH! CUP SUNK! +100 PTS! 🥤🎉';
        _decrementBall();
        return;
      }
    }
  }

  void _decrementBall() {
    _ballsRemaining--;
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_cups.every((c) => c.isCleared) || _ballsRemaining <= 0) {
        if (_isTwoPlayer) {
          if (_currentPlayer == 1) {
            _player1Score = _score;
            _currentPlayer = 2;
            _status = 'Player 1 finished: $_player1Score pts! Pass to Player 2!';
            setState(() {});
            Future.delayed(const Duration(milliseconds: 1800), () {
              if (!mounted) return;
              _setupCupsForPlayer2();
            });
          } else {
            _player2Score = _score;
            final winnerText = _player1Score > _player2Score
                ? '🏆 PLAYER 1 WINS THE DUEL! ($_player1Score vs $_player2Score)'
                : _player2Score > _player1Score
                    ? '🏆 PLAYER 2 WINS THE DUEL! ($_player2Score vs $_player1Score)'
                    : '🤝 IT\'S A TIE! ($_player1Score pts each)';
            _status = winnerText;
            setState(() {});
          }
        } else {
          StorageService.setPersonalBest('cup_pong', _score);
          _status = _cups.every((c) => c.isCleared)
              ? '🏆 ALL CUPS CLEARED! PERFECT GAME!'
              : 'Out of balls! Final Score: $_score';
          setState(() {});
        }
      } else {
        _resetBall();
      }
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_isBallInAir || _ballsRemaining <= 0) return;
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
    // Forward swipe or pull-back
    final launchVelY = -diff.dy.abs().clamp(30.0, 160.0) * 0.085;
    final launchVelX = -diff.dx * 0.06;

    setState(() {
      _ballVel = Offset(launchVelX, launchVelY);
      _ballVelZ = 10.0;
      _isBallInAir = true;
      _dragStart = null;
      _dragCurrent = null;
    });
  }

  @override
  void dispose() {
    _physicsTicker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: NeonRiseBackground(
        showMiddleBeam: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Top App Bar
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Cup Pong', style: AppTypography.heading3.copyWith(fontSize: 16)),
                          Text(
                            _isTwoPlayer ? '2P Cup Duel: Player $_currentPlayer' : 'Solo Target Arc',
                            style: AppTypography.captionSmall.copyWith(
                              color: _isTwoPlayer ? AppColors.secondaryAccent : AppColors.primaryAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mode Toggle (Solo / 2P)
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (_isTwoPlayer) {
                                setState(() {
                                  _isTwoPlayer = false;
                                  _setupCups();
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: !_isTwoPlayer ? AppColors.primaryAccent : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Solo',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: !_isTwoPlayer ? Colors.white : AppColors.secondaryText,
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (!_isTwoPlayer) {
                                setState(() {
                                  _isTwoPlayer = true;
                                  _setupCups();
                                });
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _isTwoPlayer ? AppColors.secondaryAccent : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '2P',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: _isTwoPlayer ? Colors.white : AppColors.secondaryText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay_rounded, color: AppColors.primaryAccent),
                      onPressed: () => setState(_setupCups),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Score & Balls row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        _isTwoPlayer
                            ? 'P1: $_player1Score  •  P2: ${_currentPlayer == 2 ? _score : _player2Score}'
                            : 'Score: $_score pts',
                        style: AppTypography.monoMedium.copyWith(color: AppColors.primaryAccent, fontSize: 13),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.error.withOpacity(0.5)),
                      ),
                      child: Text(
                        'Balls Left: $_ballsRemaining',
                        style: AppTypography.labelSmall.copyWith(color: AppColors.error),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                // Status Banner
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 2),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.elevatedCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.divider),
                  ),
                  child: Text(
                    _status,
                    style: AppTypography.bodySmall.copyWith(color: AppColors.primaryText),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 8),

                // Responsive Pong Table scaled to any phone screen size
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: _vWidth,
                        height: _vHeight,
                        child: GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF042F2E), Color(0xFF0D4B44), Color(0xFF06332D)],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.primaryAccent.withOpacity(0.5), width: 3),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryAccent.withOpacity(0.15),
                                  blurRadius: 20,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Center table line
                                Positioned(
                                  top: 0,
                                  bottom: 0,
                                  left: _vWidth / 2 - 1,
                                  child: Container(width: 2, color: Colors.white.withOpacity(0.3)),
                                ),

                                // Red Solo Cups
                                ..._cups.where((c) => !c.isCleared).map((c) {
                                  return Positioned(
                                    left: c.pos.dx - 18,
                                    top: c.pos.dy - 18,
                                    child: Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFDC2626), // Solo cup red rim
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.5),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Center(
                                        child: Container(
                                          width: 22,
                                          height: 22,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF7F1D1D),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }),

                                // Aiming line
                                if (_dragStart != null && _dragCurrent != null && !_isBallInAir)
                                  CustomPaint(
                                    size: const Size(_vWidth, _vHeight),
                                    painter: _PongAimPainter(start: _dragStart!, current: _dragCurrent!),
                                  ),

                                // Ping Pong Ball
                                Positioned(
                                  left: _ballScreenPos.dx - (14 * _ballScale),
                                  top: _ballScreenPos.dy - (14 * _ballScale),
                                  child: Transform.scale(
                                    scale: _ballScale,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color(0xFFF8FAFC),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.5),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                if (_ballsRemaining <= 0 || _cups.every((c) => c.isCleared))
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: MindRushButton(
                      label: 'Play Again',
                      icon: Icons.replay_rounded,
                      onPressed: () => setState(_setupCups),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PongAimPainter extends CustomPainter {
  final Offset start;
  final Offset current;

  _PongAimPainter({required this.start, required this.current});

  @override
  void paint(Canvas canvas, Size size) {
    final diff = start - current;
    final target = start + Offset(-diff.dx * 1.5, -diff.dy.abs() * 1.5);

    final paint = Paint()
      ..color = AppColors.primaryAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(start, target, paint);
    canvas.drawCircle(target, 4, Paint()..color = AppColors.primaryAccent);
  }

  @override
  bool shouldRepaint(covariant _PongAimPainter old) => old.start != start || old.current != current;
}
