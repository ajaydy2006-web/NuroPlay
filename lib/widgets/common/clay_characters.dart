import 'dart:math';
import 'package:flutter/material.dart';

/// 3D Cute Game Controller with cute eyes, mouth, D-pad and sparkle rays (as in screenshot)
class CuteClayControllerWidget extends StatelessWidget {
  final double size;

  const CuteClayControllerWidget({super.key, this.size = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ClayControllerPainter(),
      ),
    );
  }
}

class _ClayControllerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // ─── 1. Yellow Sparkle Rays (above controller) ───
    final rayPaint = Paint()
      ..color = const Color(0xFFFFD53D)
      ..strokeWidth = w * 0.045
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Left ray
    canvas.drawLine(
      Offset(w * 0.40, h * 0.20),
      Offset(w * 0.35, h * 0.10),
      rayPaint,
    );
    // Center ray
    canvas.drawLine(
      Offset(w * 0.52, h * 0.17),
      Offset(w * 0.52, h * 0.06),
      rayPaint,
    );
    // Right ray
    canvas.drawLine(
      Offset(w * 0.65, h * 0.20),
      Offset(w * 0.72, h * 0.11),
      rayPaint,
    );

    // ─── 2. Controller Body (Lilac 3D Clay Gamepad) ───
    final bodyRect = Rect.fromCenter(
      center: Offset(w * 0.52, h * 0.60),
      width: w * 0.84,
      height: h * 0.62,
    );

    // Soft drop shadow
    final shadowPaint = Paint()
      ..color = const Color(0x33441B9B)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final rrect = RRect.fromRectAndRadius(bodyRect, Radius.circular(w * 0.26));
    canvas.drawRRect(rrect.shift(const Offset(0, 6)), shadowPaint);

    // Gamepad base gradient
    final baseGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: const [
        Color(0xFFD6C4FF),
        Color(0xFFBEA5FF),
        Color(0xFFA685FF),
      ],
    );

    final bodyPaint = Paint()
      ..shader = baseGradient.createShader(bodyRect);
    canvas.drawRRect(rrect, bodyPaint);

    // Subtle inner highlight on top rim
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawRRect(rrect, highlightPaint);

    // ─── 3. Left Yellow D-Pad ───
    final dpadCenter = Offset(w * 0.32, h * 0.58);
    final dpadSize = w * 0.10;
    final dpadPaint = Paint()..color = const Color(0xFFFFD53D);

    // Horizontal bar
    final dpadH = RRect.fromRectAndRadius(
      Rect.fromCenter(center: dpadCenter, width: dpadSize * 1.8, height: dpadSize * 0.75),
      const Radius.circular(4),
    );
    // Vertical bar
    final dpadV = RRect.fromRectAndRadius(
      Rect.fromCenter(center: dpadCenter, width: dpadSize * 0.75, height: dpadSize * 1.8),
      const Radius.circular(4),
    );
    canvas.drawRRect(dpadH, dpadPaint);
    canvas.drawRRect(dpadV, dpadPaint);

    // ─── 4. Face (Cute Black Eyes + Smile) ───
    final eyePaint = Paint()..color = const Color(0xFF1E1842);
    final eyeShinePaint = Paint()..color = Colors.white;

    // Left eye
    final leftEye = Offset(w * 0.49, h * 0.53);
    canvas.drawCircle(leftEye, w * 0.038, eyePaint);
    canvas.drawCircle(leftEye + Offset(-w * 0.012, -w * 0.012), w * 0.014, eyeShinePaint);

    // Right eye
    final rightEye = Offset(w * 0.58, h * 0.53);
    canvas.drawCircle(rightEye, w * 0.038, eyePaint);
    canvas.drawCircle(rightEye + Offset(-w * 0.012, -w * 0.012), w * 0.014, eyeShinePaint);

    // Cute smiling open mouth
    final mouthPaint = Paint()
      ..color = const Color(0xFF1E1842)
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.024
      ..strokeCap = StrokeCap.round;

    final mouthRect = Rect.fromCenter(
      center: Offset(w * 0.535, h * 0.61),
      width: w * 0.07,
      height: w * 0.05,
    );
    canvas.drawArc(mouthRect, 0.2, pi - 0.4, false, mouthPaint);

    // ─── 5. Right Action Buttons (Diamond cluster) ───
    final btnCenter = Offset(w * 0.73, h * 0.62);
    final btnRadius = w * 0.032;
    final btnPaint = Paint()..color = const Color(0xFF7E52FF);

    canvas.drawCircle(btnCenter + Offset(0, -btnRadius * 1.7), btnRadius, btnPaint);
    canvas.drawCircle(btnCenter + Offset(0, btnRadius * 1.7), btnRadius, btnPaint);
    canvas.drawCircle(btnCenter + Offset(-btnRadius * 1.7, 0), btnRadius, btnPaint);
    canvas.drawCircle(btnCenter + Offset(btnRadius * 1.7, 0), btnRadius, btnPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Category Clay Character Tile (Red Math Duel, Orange Logic, Yellow Memory, Green Reaction)
class ClayCategoryCharacter extends StatelessWidget {
  final String label;
  final Color baseColor;
  final String faceType; // 'duel', 'logic', 'memory', 'reaction'
  final VoidCallback onTap;

  const ClayCategoryCharacter({
    super.key,
    required this.label,
    required this.baseColor,
    required this.faceType,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x147E52FF),
                blurRadius: 16,
                offset: Offset(0, 6),
              ),
              BoxShadow(
                color: Colors.white,
                blurRadius: 4,
                offset: Offset(-1, -1),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Colorful 3D Clay Squircle with Face
              Container(
                width: 64,
                height: 54,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: baseColor.withOpacity(0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.4),
                      blurRadius: 3,
                      offset: const Offset(-1, -1),
                    ),
                  ],
                ),
                child: Center(
                  child: _buildFace(faceType),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1E1842),
                  fontWeight: FontWeight.w800,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFace(String type) {
    switch (type) {
      case 'duel':
        // Red: Two round white googly eyes looking forward
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildGooglyEye(),
            const SizedBox(width: 8),
            _buildGooglyEye(),
          ],
        );
      case 'logic':
        // Orange: Two cute closed happy sleeping curved eyes (◡ ◡)
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildCurvedEye(),
            const SizedBox(width: 10),
            _buildCurvedEye(),
          ],
        );
      case 'memory':
        // Yellow: Two cute sparkle diamond stars (✦ ✦)
        return const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('✦', style: TextStyle(color: Color(0xFF1E1842), fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(width: 10),
            Text('✦', style: TextStyle(color: Color(0xFF1E1842), fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        );
      case 'reaction':
        // Green: Two funny wide round eyes looking to the side
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSideEye(),
            const SizedBox(width: 8),
            _buildSideEye(),
          ],
        );
      default:
        return const SizedBox();
    }
  }

  Widget _buildGooglyEye() {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Container(
          width: 5.5,
          height: 5.5,
          decoration: const BoxDecoration(
            color: Color(0xFF1E1842),
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildCurvedEye() {
    return CustomPaint(
      size: const Size(12, 6),
      painter: _CurvedEyePainter(),
    );
  }

  Widget _buildSideEye() {
    return Container(
      width: 13,
      height: 11,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.elliptical(13, 11)),
      ),
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.only(left: 2),
      child: Container(
        width: 5,
        height: 5,
        decoration: const BoxDecoration(
          color: Color(0xFF1E1842),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CurvedEyePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1E1842)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(0, size.height * 0.2);
    path.quadraticBezierTo(size.width * 0.5, size.height * 1.1, size.width, size.height * 0.2);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

