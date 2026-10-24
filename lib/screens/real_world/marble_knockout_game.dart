import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../services/storage_service.dart';

class MarbleKnockoutGame extends StatefulWidget {
  const MarbleKnockoutGame({super.key});

  @override
  State<MarbleKnockoutGame> createState() => _MarbleKnockoutGameState();
}

class _Marble {
  Offset pos;
  Offset vel;
  final double radius;
  final Color color;
  bool isKnockedOut;
  final bool isShooter;

  _Marble({
    required this.pos,
    this.vel = Offset.zero,
    required this.radius,
    required this.color,
    this.isKnockedOut = false,
    this.isShooter = false,
  });
}

class _MarbleKnockoutGameState extends State<MarbleKnockoutGame> with SingleTickerProviderStateMixin {
  late AnimationController _physicsTicker;

  static const double _boardSize = 340.0;
  static const double _ringRadius = 130.0;
  final Offset _center = const Offset(_boardSize / 2, _boardSize / 2);

  late List<_Marble> _marbles;
  late _Marble _shooter;

  Offset? _dragStart;
  Offset? _dragCurrent;
  bool _isShooting = false;
  int _score = 0;
  int _shotsRemaining = 6;
  int _knockedCount = 0;
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _physicsTicker = AnimationController(vsync: this, duration: const Duration(seconds: 1))
      ..addListener(_updatePhysics)
      ..repeat();

    _setupMarbles();
  }

  void _setupMarbles() {
    final colors = [
      const Color(0xFF38BDF8),
      const Color(0xFFF43F5E),
      const Color(0xFFEAB308),
      const Color(0xFF22C55E),
      const Color(0xFFA855F7),
      const Color(0xFFFB923C),
    ];

    _marbles = [];
    // Cluster 6 marbles around center
    for (int i = 0; i < 6; i++) {
      final angle = (i * pi / 3);
      _marbles.add(_Marble(
        pos: _center + Offset(cos(angle) * 28, sin(angle) * 28),
        radius: 12,
        color: colors[i],
      ));
    }
    // 1 center marble
    _marbles.add(_Marble(pos: _center, radius: 12, color: Colors.white));

    _resetShooter();
    _score = 0;
    _shotsRemaining = 6;
    _knockedCount = 0;
    _gameOver = false;
  }

  void _resetShooter() {
    _shooter = _Marble(
      pos: _center + const Offset(0, 110),
      radius: 15,
      color: AppColors.primaryAccent,
      isShooter: true,
    );
    _isShooting = false;
  }

  void _updatePhysics() {
    if (_gameOver) return;

    bool anyMoving = false;
    final all = [_shooter, ..._marbles.where((m) => !m.isKnockedOut)];

    for (final m in all) {
      if (m.vel.distance > 0.1) {
        anyMoving = true;
        m.pos += m.vel;
        m.vel *= 0.96; // Rolling friction

        // Check if target marble was knocked outside the ring!
        if (!m.isShooter && !m.isKnockedOut) {
          if ((m.pos - _center).distance > _ringRadius) {
            m.isKnockedOut = true;
            _knockedCount++;
            _score += 50;
          }
        }
      } else {
        m.vel = Offset.zero;
      }
    }

    // Elastic Collisions between marbles
    for (int i = 0; i < all.length; i++) {
      for (int j = i + 1; j < all.length; j++) {
        final a = all[i];
        final b = all[j];
        if (a.isKnockedOut || b.isKnockedOut) continue;

        final delta = b.pos - a.pos;
        final dist = delta.distance;
        final minDist = a.radius + b.radius;

        if (dist < minDist && dist > 0.001) {
          final normal = delta / dist;
          final overlap = minDist - dist;
          a.pos -= normal * (overlap / 2);
          b.pos += normal * (overlap / 2);

          // Momentum transfer
          final k = a.vel - b.vel;
          final p = (normal.dx * k.dx + normal.dy * k.dy);

          a.vel -= normal * p * 0.9;
          b.vel += normal * p * 0.9;
        }
      }
    }

    if (_isShooting && !anyMoving) {
      _isShooting = false;
      _shotsRemaining--;
      if (_shotsRemaining <= 0 || _marbles.every((m) => m.isKnockedOut)) {
        _gameOver = true;
        StorageService.setPersonalBest('marble_knockout', _score);
      } else {
        _resetShooter();
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
    final speed = diff.distance.clamp(10.0, 150.0) * 0.18;
    final angle = atan2(diff.dy, diff.dx);

    setState(() {
      _shooter.vel = Offset(cos(angle) * speed, sin(angle) * speed);
      _isShooting = true;
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
        title: Text('Marble Knockout', style: AppTypography.heading4),
        actions: [
          IconButton(
            icon: const Icon(Icons.replay_rounded, color: AppColors.primaryAccent),
            onPressed: () => setState(_setupMarbles),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Score row
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
                    ),
                    child: Text('Knocked: $_knockedCount/7', style: AppTypography.labelSmall.copyWith(color: AppColors.success)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.warning.withOpacity(0.5)),
                    ),
                    child: Text('Shots: $_shotsRemaining', style: AppTypography.labelSmall.copyWith(color: AppColors.warning)),
                  ),
                ],
              ),

              const SizedBox(height: 10),
              Text('Pull back on your shooter marble to knock targets out of the ring!', style: AppTypography.bodySmall, textAlign: TextAlign.center),

              const Spacer(),

              // Marble Ring Arena
              Center(
                child: GestureDetector(
                  onPanStart: _onPanStart,
                  onPanUpdate: _onPanUpdate,
                  onPanEnd: _onPanEnd,
                  child: Container(
                    width: _boardSize,
                    height: _boardSize,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.divider, width: 2),
                    ),
                    child: Stack(
                      children: [
                        // Chalk Ring Circle
                        Center(
                          child: Container(
                            width: _ringRadius * 2,
                            height: _ringRadius * 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 2.5,
                              ),
                            ),
                          ),
                        ),

                        // Aiming line
                        if (_dragStart != null && _dragCurrent != null && !_isShooting)
                          CustomPaint(
                            painter: _MarbleAimPainter(
                              shooterPos: _shooter.pos,
                              dragStart: _dragStart!,
                              dragCurrent: _dragCurrent!,
                            ),
                          ),

                        // Target Marbles
                        ..._marbles.where((m) => !m.isKnockedOut).map((m) {
                          return Positioned(
                            left: m.pos.dx - m.radius,
                            top: m.pos.dy - m.radius,
                            child: Container(
                              width: m.radius * 2,
                              height: m.radius * 2,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: m.color,
                                boxShadow: [
                                  BoxShadow(color: m.color.withOpacity(0.5), blurRadius: 6),
                                ],
                              ),
                            ),
                          );
                        }),

                        // Shooter Marble
                        Positioned(
                          left: _shooter.pos.dx - _shooter.radius,
                          top: _shooter.pos.dy - _shooter.radius,
                          child: Container(
                            width: _shooter.radius * 2,
                            height: _shooter.radius * 2,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _shooter.color,
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(color: AppColors.primaryAccent.withOpacity(0.6), blurRadius: 10),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const Spacer(),

              if (_gameOver) ...[
                MindRushButton(
                  label: 'Play Again',
                  icon: Icons.replay_rounded,
                  onPressed: () => setState(_setupMarbles),
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

class _MarbleAimPainter extends CustomPainter {
  final Offset shooterPos;
  final Offset dragStart;
  final Offset dragCurrent;

  _MarbleAimPainter({
    required this.shooterPos,
    required this.dragStart,
    required this.dragCurrent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final diff = dragStart - dragCurrent;
    final length = diff.distance.clamp(10.0, 130.0);
    final angle = atan2(diff.dy, diff.dx);

    final target = shooterPos + Offset(cos(angle) * length, sin(angle) * length);

    final paint = Paint()
      ..color = AppColors.primaryAccent
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(shooterPos, target, paint);
    canvas.drawCircle(target, 4, Paint()..color = AppColors.primaryAccent);
  }

  @override
  bool shouldRepaint(covariant _MarbleAimPainter old) =>
      old.dragCurrent != dragCurrent || old.dragStart != dragStart;
}
