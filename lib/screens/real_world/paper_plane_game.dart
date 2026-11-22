import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../services/storage_service.dart';
import 'realistic_game_components.dart';

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
      backgroundColor: const Color(0xFF2C1E14),
      body: RealisticWoodTableSurface(
        isDarkWood: false,
        child: SafeArea(
          child: Column(
            children: [
              // Custom Compact Header for Phone Screens
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2C2416), size: 18),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Paper Plane Challenge', style: AppTypography.heading3.copyWith(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(
                            'Tries: $_attemptsLeft • Score: $_totalScore pts',
                            style: AppTypography.captionSmall.copyWith(
                              color: const Color(0xFFFFD54F),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF5D4037), size: 18),
                        onPressed: _showInstructions,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: Color(0xFF7E52FF), size: 18),
                        onPressed: () {
                          setState(() {
                            _attemptsLeft = 5;
                            _totalScore = 0;
                            _resetPlane();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // Top HUD: Wind & Personal Best (Responsive)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                child: Row(
                  children: [
                    // Wind Indicator
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.air_rounded,
                              size: 16,
                              color: _windSpeed >= 0 ? const Color(0xFF22C55E) : const Color(0xFFEF4444),
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                '${_windSpeed.abs().toStringAsFixed(1)}m/s ${_windSpeed >= 0 ? "Tailwind" : "Headwind"}',
                                style: AppTypography.captionSmall.copyWith(
                                  color: const Color(0xFF2C2416),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Personal Best
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.emoji_events_rounded, size: 16, color: Color(0xFFFFB800)),
                          const SizedBox(width: 6),
                          Text(
                            'Best: ${_bestDistance.toStringAsFixed(1)}m',
                            style: AppTypography.captionSmall.copyWith(
                              color: const Color(0xFF2C2416),
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
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
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF7E52FF) : Colors.white.withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              model.name,
                              style: TextStyle(
                                color: isSel ? Colors.white : const Color(0xFF2C2416),
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
                    gradient: const LinearGradient(
                      colors: [Color(0xFFE0F2FE), Color(0xFFBAE6FD), Color(0xFFF1F5F9)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF5D4037), width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Dist: ${_planeX.toStringAsFixed(1)}m • Alt: ${_planeY.toStringAsFixed(1)}m • Speed: ${(_vx * 3.6).toStringAsFixed(0)} km/h',
                              style: const TextStyle(
                                color: Color(0xFFFFD54F),
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
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
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.flight_takeoff_rounded, color: Color(0xFF7E52FF), size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _flightComment,
                      style: AppTypography.bodySmall.copyWith(color: const Color(0xFF2C2416), fontWeight: FontWeight.bold),
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

    // Floor: Realistic Polished Hardwood Parquet Corridor Floor
    final floorRect = Rect.fromLTWH(0, floorY, 4000, 40);
    final floorPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF8B5A2B), Color(0xFF653E1B), Color(0xFF4A2C13)],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(floorRect);
    canvas.drawRect(floorRect, floorPaint);

    // Wood Floor Surface Line & Planks
    final linePaint = Paint()
      ..color = const Color(0xFFB8860B)
      ..strokeWidth = 2.0;
    canvas.drawLine(Offset(0, floorY), Offset(4000, floorY), linePaint);

    // Vertical Parquet Seams
    final seamPaint = Paint()
      ..color = const Color(0xFF3B200C).withOpacity(0.5)
      ..strokeWidth = 1.0;
    for (double sx = 0; sx <= 4000; sx += 45) {
      canvas.drawLine(Offset(sx, floorY), Offset(sx, floorY + 40), seamPaint);
    }

    // Distance Markers along floor every 10m with Inlaid Brass Badges
    final textPainter = TextPainter(textDirection: TextDirection.ltr);
    for (int d = 0; d <= 120; d += 10) {
      final markerX = d * 22.0 + 30.0;
      canvas.drawLine(
        Offset(markerX, floorY - 6),
        Offset(markerX, floorY + 6),
        Paint()..color = const Color(0xFFFFD700)..strokeWidth = 2.0,
      );

      textPainter.text = TextSpan(
        text: '${d}m',
        style: const TextStyle(color: Color(0xFFFFE082), fontSize: 10, fontWeight: FontWeight.bold, fontFamily: 'JetBrains Mono'),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(markerX - 10, floorY + 8));
    }

    // Target Rings in 3D perspective with Realistic Brass Lustre
    for (final ring in rings) {
      final ringScreenX = ring.distance * 22.0 + 30.0;
      final ringScreenY = floorY - (ring.height * 40.0);

      // Pole shadow on floor
      canvas.drawOval(
        Rect.fromCenter(center: Offset(ringScreenX + 4, floorY + 2), width: 14, height: 6),
        Paint()..color = Colors.black.withOpacity(0.3),
      );

      // Ring pole to floor
      canvas.drawLine(
        Offset(ringScreenX, ringScreenY + 21),
        Offset(ringScreenX, floorY),
        Paint()..color = const Color(0xFF78716C)..strokeWidth = 2.0,
      );

      // 3D Brass Target Ring
      final ringPaint = Paint()
        ..shader = LinearGradient(
          colors: ring.isCollected
              ? [const Color(0xFF4ADE80), const Color(0xFF16A34A)]
              : [const Color(0xFFFFE082), const Color(0xFFFFB300), const Color(0xFFB45309)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCenter(center: Offset(ringScreenX, ringScreenY), width: 16, height: 44))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0;

      canvas.drawOval(
        Rect.fromCenter(center: Offset(ringScreenX, ringScreenY), width: 16, height: 44),
        ringPaint,
      );
    }

    // Vapor / Aerodynamic Wind Draft Stream
    if (trail.isNotEmpty) {
      final trailPaint = Paint()
        ..color = const Color(0xFF7E52FF).withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;

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

    // Dynamic Cast Ground Shadow below the plane
    final planeScreenX = planeX * 22.0 + 30.0;
    final planeScreenY = floorY - (planeY * 40.0);
    final shadowScale = (1.0 - (planeY / 8.0).clamp(0.0, 0.7));
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(planeScreenX, floorY - 2),
        width: 24 * shadowScale,
        height: 7 * shadowScale,
      ),
      Paint()..color = Colors.black.withOpacity(0.35 * shadowScale),
    );

    // Realistic Folded 3D Paper Airplane
    canvas.save();
    canvas.translate(planeScreenX, planeScreenY);
    canvas.rotate(planeAngle);

    // Top illuminated wing
    final topWing = Path();
    topWing.moveTo(20, 0); // nose tip
    topWing.lineTo(-14, -10); // top wing tip
    topWing.lineTo(-7, 0); // crease root
    topWing.close();
    canvas.drawPath(topWing, Paint()..color = const Color(0xFFFFFFFF));

    // Bottom shadowed wing
    final bottomWing = Path();
    bottomWing.moveTo(20, 0); // nose tip
    bottomWing.lineTo(-7, 0); // crease root
    bottomWing.lineTo(-14, 10); // bottom wing tip
    bottomWing.close();
    canvas.drawPath(bottomWing, Paint()..color = const Color(0xFFCBD5E1));

    // Center Spine Crease
    final creasePaint = Paint()
      ..color = const Color(0xFF94A3B8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawLine(const Offset(20, 0), const Offset(-7, 0), creasePaint);

    canvas.restore();
    canvas.restore(); // view offset restore

    // Slingshot / Launch Drag Indicator
    if (dragStart != null && dragCurrent != null && !isInFlight) {
      final launchPaint = Paint()
        ..color = const Color(0xFF7E52FF)
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;

      canvas.drawLine(dragStart!, dragCurrent!, launchPaint);
      canvas.drawCircle(dragStart!, 7, Paint()..color = const Color(0xFF7E52FF));

      // Trajectory forecast arrow
      final pull = dragStart! - dragCurrent!;
      final forecast = dragStart! + Offset(pull.dx.abs() * 0.8, -pull.dy.abs() * 0.8);
      canvas.drawLine(
        dragStart!,
        forecast,
        Paint()
          ..color = const Color(0xFFFFB800)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PaperPlaneFlightPainter old) => true;
}
