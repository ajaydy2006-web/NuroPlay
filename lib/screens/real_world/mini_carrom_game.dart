import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../services/storage_service.dart';

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
  bool isPocketed;

  _CarromPiece({
    required this.pos,
    this.vel = Offset.zero,
    required this.radius,
    required this.color,
    required this.points,
    this.isPocketed = false,
  });
}

class _MiniCarromGameState extends State<MiniCarromGame> with SingleTickerProviderStateMixin {
  late AnimationController _physicsController;

  static const double _boardSize = 340.0;
  static const double _pocketRadius = 22.0;

  late List<_CarromPiece> _coins;
  late _CarromPiece _striker;

  Offset? _dragStart;
  Offset? _dragCurrent;
  bool _isShooting = false;
  int _score = 0;
  int _shotsRemaining = 8;
  bool _gameOver = false;

  final List<Offset> _pockets = const [
    Offset(24, 24), // Top Left
    Offset(_boardSize - 24, 24), // Top Right
    Offset(24, _boardSize - 24), // Bottom Left
    Offset(_boardSize - 24, _boardSize - 24), // Bottom Right
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
    final center = const Offset(_boardSize / 2, _boardSize / 2);
    _coins = [
      // Red Queen
      _CarromPiece(pos: center, radius: 11, color: const Color(0xFFEF4444), points: 25),
      // White coins (10 pts)
      _CarromPiece(pos: center + const Offset(-16, 0), radius: 11, color: Colors.white, points: 10),
      _CarromPiece(pos: center + const Offset(16, 0), radius: 11, color: Colors.white, points: 10),
      _CarromPiece(pos: center + const Offset(0, -16), radius: 11, color: Colors.white, points: 10),
      // Black coins (5 pts)
      _CarromPiece(pos: center + const Offset(0, 16), radius: 11, color: const Color(0xFF1E293B), points: 5),
      _CarromPiece(pos: center + const Offset(-12, -12), radius: 11, color: const Color(0xFF1E293B), points: 5),
      _CarromPiece(pos: center + const Offset(12, 12), radius: 11, color: const Color(0xFF1E293B), points: 5),
    ];

    _resetStriker();
    _score = 0;
    _shotsRemaining = 8;
    _gameOver = false;
  }

  void _resetStriker() {
    _striker = _CarromPiece(
      pos: const Offset(_boardSize / 2, _boardSize - 55),
      vel: Offset.zero,
      radius: 16,
      color: AppColors.primaryAccent,
      points: 0,
    );
    _isShooting = false;
  }

  void _updatePhysics() {
    if (_gameOver) return;

    bool anyMoving = false;
    final allPieces = [_striker, ..._coins.where((c) => !c.isPocketed)];

    for (final p in allPieces) {
      if (p.vel.distance > 0.1) {
        anyMoving = true;
        p.pos += p.vel;
        p.vel *= 0.965; // Friction

        // Border bounce
        if (p.pos.dx < p.radius + 12) {
          p.pos = Offset(p.radius + 12, p.pos.dy);
          p.vel = Offset(-p.vel.dx * 0.75, p.vel.dy);
        } else if (p.pos.dx > _boardSize - p.radius - 12) {
          p.pos = Offset(_boardSize - p.radius - 12, p.pos.dy);
          p.vel = Offset(-p.vel.dx * 0.75, p.vel.dy);
        }

        if (p.pos.dy < p.radius + 12) {
          p.pos = Offset(p.pos.dx, p.radius + 12);
          p.vel = Offset(p.vel.dx, -p.vel.dy * 0.75);
        } else if (p.pos.dy > _boardSize - p.radius - 12) {
          p.pos = Offset(p.pos.dx, _boardSize - p.radius - 12);
          p.vel = Offset(p.vel.dx, -p.vel.dy * 0.75);
        }

        // Check pockets
        for (final pocket in _pockets) {
          if ((p.pos - pocket).distance < _pocketRadius) {
            p.vel = Offset.zero;
            p.pos = const Offset(-100, -100);
            p.isPocketed = true;
            if (p != _striker) {
              _score += p.points;
            }
          }
        }
      } else {
        p.vel = Offset.zero;
      }
    }

    // Pairwise elastic collisions
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
          // Separate pieces
          final overlap = minDist - dist;
          a.pos -= normal * (overlap / 2);
          b.pos += normal * (overlap / 2);

          // Elastic collision velocity swap along normal
          final k = a.vel - b.vel;
          final p = 2 * (normal.dx * k.dx + normal.dy * k.dy) / 2.0;

          a.vel -= normal * p * 0.85;
          b.vel += normal * p * 0.85;
        }
      }
    }

    if (_isShooting && !anyMoving) {
      _isShooting = false;
      _shotsRemaining--;
      if (_shotsRemaining <= 0 || _coins.every((c) => c.isPocketed)) {
        _gameOver = true;
        StorageService.setPersonalBest('mini_carrom', _score);
      } else {
        _resetStriker();
      }
    }

    setState(() {});
  }

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
    final speed = diff.distance.clamp(10.0, 150.0) * 0.16;
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
      backgroundColor: AppColors.primaryBg,
      body: NeonRiseBackground(
        showMiddleBeam: true,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                // Top Bar
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Text('Mini Carrom Tabletop', style: AppTypography.heading3, textAlign: TextAlign.center),
                    ),
                    IconButton(
                      icon: const Icon(Icons.replay_rounded, color: AppColors.primaryAccent),
                      onPressed: () => setState(_setupBoard),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Score & Shots
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
                      child: Text('Score: $_score pts', style: AppTypography.monoMedium.copyWith(color: AppColors.primaryAccent, fontSize: 15)),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                      ),
                      child: Text('Shots Left: $_shotsRemaining', style: AppTypography.labelSmall.copyWith(color: AppColors.warning)),
                    ),
                  ],
                ),

                const SizedBox(height: 6),
                Text(
                  'Pull back on striker to aim & power, release to strike!',
                  style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 6),

                // Responsive Carrom Board scaled to phone screen
                Expanded(
                  child: Center(
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: _boardSize,
                        height: _boardSize,
                        child: GestureDetector(
                          onPanStart: _onPanStart,
                          onPanUpdate: _onPanUpdate,
                          onPanEnd: _onPanEnd,
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFE2C9A1), // Plywood Carrom Surface
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: const Color(0xFF5D381E), width: 14), // Wooden Frame
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.6),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: AppColors.primaryAccent.withOpacity(0.18),
                                  blurRadius: 18,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                // Corner Pockets
                                ..._pockets.map((p) {
                                  return Positioned(
                                    left: p.dx - _pocketRadius,
                                    top: p.dy - _pocketRadius,
                                    child: Container(
                                      width: _pocketRadius * 2,
                                      height: _pocketRadius * 2,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Color(0xFF111827),
                                      ),
                                    ),
                                  );
                                }),

                                // Center Circle
                                Center(
                                  child: Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(color: const Color(0xFFB45309), width: 2),
                                    ),
                                  ),
                                ),

                                // Baseline
                                Positioned(
                                  left: 40,
                                  right: 40,
                                  bottom: 55,
                                  child: Container(height: 1.5, color: const Color(0xFFB45309)),
                                ),

                                // Aiming Vector Line
                                if (_dragStart != null && _dragCurrent != null && !_isShooting)
                                  CustomPaint(
                                    size: const Size(_boardSize, _boardSize),
                                    painter: _CarromAimPainter(
                                      strikerPos: _striker.pos,
                                      dragStart: _dragStart!,
                                      dragCurrent: _dragCurrent!,
                                    ),
                                  ),

                                // Carrom Coins
                                ..._coins.where((c) => !c.isPocketed).map((c) {
                                  return Positioned(
                                    left: c.pos.dx - c.radius,
                                    top: c.pos.dy - c.radius,
                                    child: Container(
                                      width: c.radius * 2,
                                      height: c.radius * 2,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: c.color,
                                        border: Border.all(color: Colors.black.withOpacity(0.4), width: 1),
                                        boxShadow: [
                                          BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 4),
                                        ],
                                      ),
                                    ),
                                  );
                                }),

                                // Striker
                                if (!_striker.isPocketed)
                                  Positioned(
                                    left: _striker.pos.dx - _striker.radius,
                                    top: _striker.pos.dy - _striker.radius,
                                    child: Container(
                                      width: _striker.radius * 2,
                                      height: _striker.radius * 2,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: AppColors.accentGradient,
                                        border: Border.all(color: Colors.white, width: 2),
                                        boxShadow: [
                                          BoxShadow(color: AppColors.primaryAccent.withOpacity(0.5), blurRadius: 8),
                                        ],
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

                if (_gameOver)
                  Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.elevatedCard,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryAccent),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Match Completed!', style: AppTypography.heading4),
                            Text('Final Score: $_score points', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryAccent)),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () => setState(_setupBoard),
                          child: const Text('Play Again'),
                        ),
                      ],
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

class _CarromAimPainter extends CustomPainter {
  final Offset strikerPos;
  final Offset dragStart;
  final Offset dragCurrent;

  _CarromAimPainter({
    required this.strikerPos,
    required this.dragStart,
    required this.dragCurrent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final diff = dragStart - dragCurrent;
    final length = diff.distance.clamp(10.0, 120.0);
    final angle = atan2(diff.dy, diff.dx);

    final target = strikerPos + Offset(cos(angle) * length, sin(angle) * length);

    final linePaint = Paint()
      ..color = AppColors.primaryAccent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(strikerPos, target, linePaint);
    canvas.drawCircle(target, 4, Paint()..color = AppColors.primaryAccent);
  }

  @override
  bool shouldRepaint(covariant _CarromAimPainter old) =>
      old.dragCurrent != dragCurrent || old.dragStart != dragStart;
}
