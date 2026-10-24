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

  // Ball 3D state: x, y (screen coords), z (height/depth)
  Offset _ballScreenPos = const Offset(170, 480);
  double _ballScale = 1.0;
  Offset _ballVel = Offset.zero;
  double _ballVelZ = 0.0;
  double _ballZ = 0.0;
  bool _isBallInAir = false;

  Offset? _dragStart;
  Offset? _dragCurrent;

  int _ballsRemaining = 10;
  int _score = 0;
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
    // 6 cups arranged in a triangle pyramid at the table top:
    // Row 1 (top): 3 cups
    // Row 2: 2 cups
    // Row 3: 1 cup
    _cups = [
      _PongCup(id: 1, pos: const Offset(130, 110)),
      _PongCup(id: 2, pos: const Offset(170, 110)),
      _PongCup(id: 3, pos: const Offset(210, 110)),
      _PongCup(id: 4, pos: const Offset(150, 150)),
      _PongCup(id: 5, pos: const Offset(190, 150)),
      _PongCup(id: 6, pos: const Offset(170, 190)),
    ];

    _resetBall();
    _ballsRemaining = 10;
    _score = 0;
  }

  void _resetBall() {
    setState(() {
      _ballScreenPos = const Offset(170, 480);
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
      _ballScale = (1.0 - (_ballScreenPos.dy < 480 ? (480 - _ballScreenPos.dy) * 0.0012 : 0)).clamp(0.4, 1.2);

      // When ball reaches table level at the top end (y < 230 and descending z)
      if (_ballVelZ <= 0 && _ballScreenPos.dy <= 230) {
        _checkCupCollision();
      }

      // Ball missed / landed past table
      if (_ballScreenPos.dy < 60 || _ballScreenPos.dy > 520 || _ballScreenPos.dx < 40 || _ballScreenPos.dx > 300) {
        _isBallInAir = false;
        _status = 'Missed! Try adjusting your angle & power.';
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
        StorageService.setPersonalBest('cup_pong', _score);
        _status = _cups.every((c) => c.isCleared)
            ? '🏆 ALL CUPS CLEARED! PERFECT GAME!'
            : 'Out of balls! Final Score: $_score';
        setState(() {});
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Cup Pong Tabletop', style: AppTypography.heading4),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_rounded, color: AppColors.primaryAccent),
            onPressed: () => setState(_setupCups),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
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
                    child: Text('Score: $_score pts', style: AppTypography.monoMedium.copyWith(color: AppColors.primaryAccent, fontSize: 16)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.error.withOpacity(0.5)),
                    ),
                    child: Text('Balls Left: $_ballsRemaining', style: AppTypography.labelSmall.copyWith(color: AppColors.error)),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Status Banner
              Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.elevatedCard,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(_status, style: AppTypography.bodySmall, textAlign: TextAlign.center),
              ),

              // Pong Table with 3D perspective
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return GestureDetector(
                      onPanStart: _onPanStart,
                      onPanUpdate: _onPanUpdate,
                      onPanEnd: _onPanEnd,
                      child: Container(
                        margin: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF065F46), Color(0xFF047857)], // Classic green pong table
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.white.withOpacity(0.4), width: 3),
                        ),
                        child: Stack(
                          children: [
                            // Center table line
                            Positioned(
                              top: 0,
                              bottom: 0,
                              left: constraints.maxWidth / 2 - 1,
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
                                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 6, offset: const Offset(0, 3)),
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
                                        color: Colors.black.withOpacity(0.4),
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
                    );
                  },
                ),
              ),

              if (_ballsRemaining <= 0 || _cups.every((c) => c.isCleared)) ...[
                MindRushButton(
                  label: 'Play Again',
                  icon: Icons.replay_rounded,
                  onPressed: () => setState(_setupCups),
                ),
                const SizedBox(height: 12),
              ],
            ],
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
