import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../services/storage_service.dart';

enum PlaneModel {
  dart('Dart', 'High speed, piercing aerodynamics', 1.2, 0.85),
  glider('Glider', 'Maximum lift, floats gracefully on drafts', 0.9, 1.35),
  acrobat('Acrobat', 'Balanced weight, loops through hoops', 1.05, 1.05);

  final String name;
  final String desc;
  final double speedFactor;
  final double liftFactor;

  const PlaneModel(this.name, this.desc, this.speedFactor, this.liftFactor);
}

class _FlightRing {
  final double distance; // meters down range
  final double height; // meters above floor
  final int points;
  bool isCollected;

  _FlightRing({
    required this.distance,
    required this.height,
    required this.points,
    this.isCollected = false,
  });
}

class PaperPlaneGame extends StatefulWidget {
  const PaperPlaneGame({super.key});

  @override
  State<PaperPlaneGame> createState() => _PaperPlaneGameState();
}

class _PaperPlaneGameState extends State<PaperPlaneGame>
    with SingleTickerProviderStateMixin {
  late AnimationController _flightTicker;

  PlaneModel _selectedModel = PlaneModel.dart;

  // Launch state
  Offset? _launchDragStart;
  Offset? _launchDragCurrent;
  bool _isInFlight = false;
  bool _flightFinished = false;

  // Flight Physics State (world coordinates in meters)
  double _planeX = 0.0; // distance (meters)
  double _planeY = 1.6; // altitude (meters above floor)
  double _vx = 0.0;
  double _vy = 0.0;
  double _planeAngle = 0.0; // radians

  // Environmental wind
  double _windSpeed = 1.5; // positive = tailwind, negative = headwind

  // Scoring
  int _attemptsLeft = 5;
  double _bestDistance = 0.0;
  int _totalScore = 0;
  String _flightComment = 'Pull back and aim upward to launch your paper plane!';

  // Floating targets along the corridor
  late List<_FlightRing> _targetRings;
  final List<Offset> _flightTrail = [];

  @override
  void initState() {
    super.initState();
    _flightTicker = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..addListener(_updateFlight)..repeat();

    _setupFlightRings();
    _randomizeWind();
    _loadPersonalBest();
  }

  void _loadPersonalBest() {
    final best = StorageService.getPersonalBest('paper_plane');
    setState(() {
      _bestDistance = best.toDouble();
    });
  }

  @override
  void dispose() {
    _flightTicker.dispose();
    super.dispose();
  }

  void _setupFlightRings() {
    _targetRings = [
      _FlightRing(distance: 8.0, height: 2.2, points: 50),
      _FlightRing(distance: 18.0, height: 3.1, points: 100),
      _FlightRing(distance: 30.0, height: 2.5, points: 150),
      _FlightRing(distance: 45.0, height: 3.8, points: 250),
      _FlightRing(distance: 60.0, height: 2.0, points: 400),
    ];
  }

  void _randomizeWind() {
    final r = Random();
    _windSpeed = (r.nextDouble() * 5.0 - 2.0); // -2.0 m/s to +3.0 m/s
  }

  void _resetPlane() {
    setState(() {
      _isInFlight = false;
      _flightFinished = false;
      _planeX = 0.0;
      _planeY = 1.6;
      _vx = 0.0;
      _vy = 0.0;
      _planeAngle = 0.0;
      _flightTrail.clear();
      _setupFlightRings();
      _randomizeWind();
      _flightComment = 'Swipe back & launch plane #$_attemptsLeft!';
    });
  }

  void _onPanStart(DragStartDetails details) {
    if (_isInFlight || _attemptsLeft <= 0) return;
    setState(() {
      _launchDragStart = details.localPosition;
      _launchDragCurrent = details.localPosition;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isInFlight || _launchDragStart == null) return;
    setState(() {
      _launchDragCurrent = details.localPosition;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    if (_isInFlight || _launchDragStart == null || _launchDragCurrent == null) return;

    final dragVector = _launchDragStart! - _launchDragCurrent!;
    final dragDist = dragVector.distance.clamp(15.0, 180.0);

    // Launch angle between 10 deg and 60 deg
    final angle = atan2(dragVector.dy.abs(), dragVector.dx.abs()).clamp(0.15, 1.1);

    final basePower = (dragDist / 180.0) * 22.0 * _selectedModel.speedFactor;

    setState(() {
      _launchDragStart = null;
      _launchDragCurrent = null;
      _isInFlight = true;
      _flightFinished = false;
      _attemptsLeft--;

      _vx = cos(angle) * basePower + (_windSpeed * 0.4);
      _vy = sin(angle) * basePower;
      _planeAngle = -angle;
      _flightComment = 'Gliding through the air...';
    });
  }

  void _updateFlight() {
    if (!_isInFlight || _flightFinished) return;

    setState(() {
      // Aerodynamic forces
      const dt = 0.035;
      const gravity = 9.8;
      const airResistance = 0.08;

      final lift = (_vx * _vx * 0.045) * _selectedModel.liftFactor;
      final drag = (_vx * airResistance) + (_vy.abs() * airResistance * 0.5);

      // Accelerations
      final ax = -drag + (_windSpeed * 0.06);
      final ay = -gravity + lift;

      _vx += ax * dt;
      _vy += ay * dt;

      _planeX += _vx * dt;
      _planeY += _vy * dt;

      // Update orientation
      _planeAngle = atan2(-_vy, _vx);

      // Track trail
      _flightTrail.add(Offset(_planeX, _planeY));
      if (_flightTrail.length > 50) _flightTrail.removeAt(0);

      // Ring collisions
      for (final ring in _targetRings) {
        if (!ring.isCollected) {
          final dx = (ring.distance - _planeX).abs();
          final dy = (ring.height - _planeY).abs();
          if (dx < 1.2 && dy < 1.0) {
            ring.isCollected = true;
            _totalScore += ring.points;
            _flightComment = '🎯 Clean Ring Pass! +${ring.points} pts!';
          }
        }
      }

      // Check ground landing
      if (_planeY <= 0.0) {
        _planeY = 0.0;
        _isInFlight = false;
        _flightFinished = true;

        // Distance points
        final distPoints = (_planeX * 10).toInt();
        _totalScore += distPoints;

        if (_planeX > _bestDistance) {
          _bestDistance = _planeX;
          StorageService.setPersonalBest('paper_plane', _bestDistance.toInt());
          _flightComment = '🏆 NEW RECORD! Glided ${_planeX.toStringAsFixed(1)}m!';
        } else {
          _flightComment = 'Landed safely at ${_planeX.toStringAsFixed(1)}m (+${distPoints}pts)';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            Text('Paper Plane Challenge', style: AppTypography.headingMedium),
            Text(
              'Attempts Left: $_attemptsLeft • Total: $_totalScore pts',
              style: AppTypography.captionSmall.copyWith(
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline_rounded, color: AppColors.textSecondary),
            onPressed: _showInstructions,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
            onPressed: () {
              setState(() {
                _attemptsLeft = 5;
                _totalScore = 0;
                _resetPlane();
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Top HUD: Wind & Plane Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  // Wind Indicator
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.air_rounded,
                          size: 16,
                          color: _windSpeed >= 0 ? AppColors.primaryAccent : AppColors.error,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_windSpeed.abs().toStringAsFixed(1)} m/s ${_windSpeed >= 0 ? "Tailwind" : "Headwind"}',
                          style: AppTypography.captionSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  // Personal Best
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.surfaceBorder),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.emoji_events_rounded, size: 16, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Text(
                          'Best: ${_bestDistance.toStringAsFixed(1)}m',
                          style: AppTypography.captionSmall.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Plane Fold Model Tabs
            if (!_isInFlight && !_flightFinished)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: PlaneModel.values.map((model) {
                    final isSel = _selectedModel == model;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedModel = model),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          decoration: BoxDecoration(
                            color: isSel ? AppColors.primaryAccent : AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSel ? AppColors.primaryAccent : AppColors.surfaceBorder,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              model.name,
                              style: TextStyle(
                                color: isSel ? Colors.black : Colors.white70,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),

            // Flight Arena Canvas
            Expanded(
              child: GestureDetector(
                onPanStart: _onPanStart,
                onPanUpdate: _onPanUpdate,
                onPanEnd: _onPanEnd,
                child: Container(
                  margin: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surfaceBorder, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Stack(
                      children: [
                        // Flight World Painter (Corridor, distance grid, rings, plane, trail)
                        CustomPaint(
                          size: Size.infinite,
                          painter: _PaperPlaneFlightPainter(
                            planeX: _planeX,
                            planeY: _planeY,
                            planeAngle: _planeAngle,
                            rings: _targetRings,
                            trail: _flightTrail,
                            dragStart: _launchDragStart,
                            dragCurrent: _launchDragCurrent,
                            isInFlight: _isInFlight,
                          ),
                        ),

                        // Live Speed & Distance Telemetry Overlay
                        Positioned(
                          top: 12,
                          left: 14,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Dist: ${_planeX.toStringAsFixed(1)}m • Alt: ${_planeY.toStringAsFixed(1)}m • Speed: ${(_vx * 3.6).toStringAsFixed(0)} km/h',
                              style: const TextStyle(
                                color: AppColors.primaryAccent,
                                fontSize: 11,
                                fontFamily: 'JetBrains Mono',
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

            // Status & Feedback Banner
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.surfaceBorder),
              ),
              child: Row(
                children: [
                  const Icon(Icons.flight_takeoff_rounded, color: AppColors.primaryAccent, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _flightComment,
                      style: AppTypography.bodySmall.copyWith(color: AppColors.textPrimary),
                    ),
                  ),
                ],
              ),
            ),

            // Controls or Next Flight button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: _flightFinished
                  ? (_attemptsLeft > 0
                      ? MindRushButton(
                          label: 'Launch Next Plane ($_attemptsLeft remaining)',
                          icon: Icons.flight_rounded,
                          onPressed: _resetPlane,
                        )
                      : MindRushButton(
                          label: 'Challenge Complete! Play Again',
                          icon: Icons.replay_rounded,
                          onPressed: () {
                            setState(() {
                              _attemptsLeft = 5;
                              _totalScore = 0;
                              _resetPlane();
                            });
                          },
                        ))
                  : const SizedBox(height: 8),
            ),
          ],
        ),
      ),
    );
  }

  void _showInstructions() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.flight_rounded, color: AppColors.primaryAccent),
            const SizedBox(width: 8),
            Text('Paper Plane Challenge', style: AppTypography.headingMedium),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildRuleItem('1. Choose your fold model: Dart (fast), Glider (lift), Acrobat (balanced).'),
            _buildRuleItem('2. Touch the launch pad, drag back to build thrust, and angle upward to aim.'),
            _buildRuleItem('3. Release to launch your paper plane down the classroom hallway!'),
            _buildRuleItem('4. Steer through glowing Target Hoops to earn massive bonus points.'),
            _buildRuleItem('5. Mind the wind gusts — tailwinds boost distance, headwinds push back!'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Let\'s Fly!', style: TextStyle(color: AppColors.primaryAccent)),
          ),
        ],
      ),
    );
  }

  Widget _buildRuleItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(text, style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary)),
    );
  }
}

class _PaperPlaneFlightPainter extends CustomPainter {
  final double planeX;
  final double planeY;
  final double planeAngle;
  final List<_FlightRing> rings;
  final List<Offset> trail;
  final Offset? dragStart;
  final Offset? dragCurrent;
  final bool isInFlight;

  _PaperPlaneFlightPainter({
    required this.planeX,
    required this.planeY,
    required this.planeAngle,
    required this.rings,
    required this.trail,
    required this.dragStart,
    required this.dragCurrent,
    required this.isInFlight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final floorY = size.height - 35.0;

    // Camera follow: offset view as plane flies further
    final cameraX = (planeX * 22.0) - (size.width * 0.25);
    final viewOffsetX = cameraX.clamp(0.0, 3000.0);

    canvas.save();
    canvas.translate(-viewOffsetX, 0);

    // Floor / Classroom Corridor
    final floorPaint = Paint()..color = const Color(0xFF1E293B);
    canvas.drawRect(Rect.fromLTWH(0, floorY, 4000, 40), floorPaint);

    final linePaint = Paint()
      ..color = const Color(0xFF334155)
      ..strokeWidth = 2.0;
    canvas.drawLine(const Offset(0, 0), Offset(4000, 0), linePaint);

    // Distance Markers along floor every 10m
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int d = 0; d <= 120; d += 10) {
      final markerX = d * 22.0 + 30.0;
      canvas.drawLine(
        Offset(markerX, floorY - 6),
        Offset(markerX, floorY + 6),
        Paint()..color = AppColors.primaryAccent.withOpacity(0.5)..strokeWidth = 1.5,
      );

      textPainter.text = TextSpan(
        text: '${d}m',
        style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'JetBrains Mono'),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(markerX - 10, floorY + 8));
    }

    // Target Rings in 3D perspective
    for (final ring in rings) {
      final ringScreenX = ring.distance * 22.0 + 30.0;
      final ringScreenY = floorY - (ring.height * 40.0);

      final ringPaint = Paint()
        ..color = ring.isCollected ? AppColors.primaryAccent.withOpacity(0.3) : AppColors.warning
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;

      canvas.drawOval(
        Rect.fromCenter(center: Offset(ringScreenX, ringScreenY), width: 14, height: 42),
        ringPaint,
      );

      // Ring pole to floor
      canvas.drawLine(
        Offset(ringScreenX, ringScreenY + 21),
        Offset(ringScreenX, floorY),
        Paint()..color = const Color(0xFF475569)..strokeWidth = 1.5,
      );
    }

    // Vapor / Smoke Trail
    if (trail.isNotEmpty) {
      final trailPaint = Paint()
        ..color = AppColors.primaryAccent.withOpacity(0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;

      final path = Path();
      for (int i = 0; i < trail.length; i++) {
        final screenPt = Offset(trail[i].dx * 22.0 + 30.0, floorY - (trail[i].dy * 40.0));
        if (i == 0) {
          path.moveTo(screenPt.dx, screenPt.dy);
        } else {
          path.lineTo(screenPt.dx, screenPt.dy);
        }
      }
      canvas.drawPath(path, trailPaint);
    }

    // Paper Airplane
    final planeScreenX = planeX * 22.0 + 30.0;
    final planeScreenY = floorY - (planeY * 40.0);

    canvas.save();
    canvas.translate(planeScreenX, planeScreenY);
    canvas.rotate(planeAngle);

    // Origami Paper Plane Polygon
    final planePath = Path();
    planePath.moveTo(16, 0); // nose tip
    planePath.lineTo(-14, -8); // top wing tip
    planePath.lineTo(-8, 0); // crease
    planePath.lineTo(-14, 8); // bottom wing tip
    planePath.close();

    final planeBodyPaint = Paint()..color = Colors.white;
    canvas.drawPath(planePath, planeBodyPaint);

    final creasePaint = Paint()
      ..color = const Color(0xFFCBD5E1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawLine(const Offset(16, 0), const Offset(-8, 0), creasePaint);

    canvas.restore();
    canvas.restore(); // view offset restore

    // Slingshot / Launch Drag Indicator
    if (dragStart != null && dragCurrent != null && !isInFlight) {
      final launchPaint = Paint()
        ..color = AppColors.primaryAccent
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(dragStart!, dragCurrent!, launchPaint);
      canvas.drawCircle(dragStart!, 6, Paint()..color = AppColors.primaryAccent);

      // Trajectory forecast arrow
      final pull = dragStart! - dragCurrent!;
      final forecast = dragStart! + Offset(pull.dx.abs() * 0.8, -pull.dy.abs() * 0.8);
      canvas.drawLine(
        dragStart!,
        forecast,
        Paint()
          ..color = AppColors.primaryAccent.withOpacity(0.5)
          ..strokeWidth = 1.5
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PaperPlaneFlightPainter old) => true;
}
