import 'dart:math';
import 'package:flutter/material.dart';

/// ─── 1. REALISTIC WOOD TABLETOP SURFACE ───
/// Renders authentic polished oak/teak wood planks with subtle wood grain,
/// plank seams, warm ambient room lighting, and gentle vignette.
class RealisticWoodTableSurface extends StatelessWidget {
  final Widget child;
  final bool isDarkWood;
  final Color? tintColor;

  const RealisticWoodTableSurface({
    super.key,
    required this.child,
    this.isDarkWood = false,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base Wood Color & Plank Grain
        CustomPaint(
          painter: _WoodGrainPainter(isDark: isDarkWood, tint: tintColor),
        ),

        // Ambient Top-Down Room Spotlight & Vignette
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.95,
              colors: [
                Colors.white.withOpacity(isDarkWood ? 0.08 : 0.18),
                Colors.transparent,
                Colors.black.withOpacity(isDarkWood ? 0.55 : 0.35),
              ],
              stops: const [0.0, 0.65, 1.0],
            ),
          ),
        ),

        // Foreground content
        child,
      ],
    );
  }
}

class _WoodGrainPainter extends CustomPainter {
  final bool isDark;
  final Color? tint;

  _WoodGrainPainter({required this.isDark, this.tint});

  @override
  void paint(Canvas canvas, Size size) {
    // Base wood tones
    final baseColor = tint ?? (isDark ? const Color(0xFF2C1810) : const Color(0xFFD4A373));
    final secondaryColor = isDark ? const Color(0xFF1E100A) : const Color(0xFFC5925F);
    final seamColor = isDark ? const Color(0xFF140B07) : const Color(0xFFA67546);

    final rect = Offset.zero & size;
    final basePaint = Paint()..color = baseColor;
    canvas.drawRect(rect, basePaint);

    // Draw horizontal wood planks (each ~80-100px)
    final plankHeight = size.height / 7;
    for (int i = 0; i < 8; i++) {
      final y = i * plankHeight;
      // Plank tone variation
      if (i % 2 == 1) {
        final plankPaint = Paint()
          ..color = secondaryColor.withOpacity(0.35);
        canvas.drawRect(Rect.fromLTWH(0, y, size.width, plankHeight), plankPaint);
      }

      // Plank seam line with highlight and shadow
      final seamPaint = Paint()
        ..color = seamColor.withOpacity(0.6)
        ..strokeWidth = 1.8;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), seamPaint);

      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.12)
        ..strokeWidth = 1.0;
      canvas.drawLine(Offset(0, y + 1.8), Offset(size.width, y + 1.8), highlightPaint);

      // Subtle natural wood grain curves on each plank
      final grainPaint = Paint()
        ..color = isDark ? Colors.black.withOpacity(0.08) : Colors.black.withOpacity(0.04)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke;

      final path = Path();
      path.moveTo(0, y + plankHeight * 0.35);
      path.cubicTo(
        size.width * 0.3,
        y + plankHeight * 0.2,
        size.width * 0.7,
        y + plankHeight * 0.5,
        size.width,
        y + plankHeight * 0.3,
      );
      canvas.drawPath(path, grainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ─── 2. REALISTIC GREEN BAIZE / FELT TOURNAMENT SURFACE ───
class RealisticFeltTableSurface extends StatelessWidget {
  final Widget child;

  const RealisticFeltTableSurface({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 0.9,
          colors: [
            Color(0xFF1B6B48),
            Color(0xFF135236),
            Color(0xFF0B3322),
          ],
        ),
      ),
      child: child,
    );
  }
}

/// ─── 3. REALISTIC FOLDED PAPER TRIANGLE FOOTBALL ───
/// Renders authentic origami folded loose-leaf notebook paper with lines and 3D creases
class RealisticPaperFootballTriangle extends StatelessWidget {
  final double size;

  const RealisticPaperFootballTriangle({super.key, this.size = 54});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PaperFootballPainter(),
      ),
    );
  }
}

class _PaperFootballPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Outer soft drop shadow (giving physical elevation above desk)
    final shadowPath = Path()
      ..moveTo(w * 0.5, h * 0.05)
      ..lineTo(w * 0.95, h * 0.95)
      ..lineTo(w * 0.05, h * 0.95)
      ..close();

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(shadowPath.shift(const Offset(3, 5)), shadowPaint);

    // Main Paper Triangle Body
    final path = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    // Natural paper parchment gradient
    final paperGradient = const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFFBF8EE),
        Color(0xFFF1ECD9),
      ],
    );
    canvas.drawPath(
      path,
      Paint()..shader = paperGradient.createShader(Offset.zero & size),
    );

    // Notebook ruled blue lines across the triangle
    final linePaint = Paint()
      ..color = const Color(0xFF60A5FA).withOpacity(0.35)
      ..strokeWidth = 1.0;

    for (double y = h * 0.25; y < h; y += h * 0.22) {
      // Find x boundaries along triangle sides at this y
      final sideRatio = y / h;
      final xLeft = (w * 0.5) * (1 - sideRatio);
      final xRight = (w * 0.5) + (w * 0.5) * sideRatio;
      canvas.drawLine(Offset(xLeft + 2, y), Offset(xRight - 2, y), linePaint);
    }

    // Fold Crease Lines (Triangular origami tuck flaps)
    final foldPaint = Paint()
      ..color = const Color(0xFFD4C8B0)
      ..strokeWidth = 1.2;

    // Center diagonal fold
    canvas.drawLine(Offset(w * 0.5, 0), Offset(w * 0.72, h), foldPaint);
    // Secondary tuck fold
    canvas.drawLine(Offset(w * 0.26, h * 0.52), Offset(w * 0.85, h * 0.85), foldPaint);

    // Paper perimeter fold rim
    final rimPaint = Paint()
      ..color = const Color(0xFFC9BCA2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    canvas.drawPath(path, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ─── 4. REALISTIC RED SOLO CUP ───
/// Renders authentic party red solo cup with rolled white lip and depth
class RealisticRedSoloCup extends StatelessWidget {
  final double size;
  final bool isCleared;

  const RealisticRedSoloCup({
    super.key,
    this.size = 42,
    this.isCleared = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isCleared) return SizedBox(width: size, height: size);

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RedSoloCupPainter(),
      ),
    );
  }
}

class _RedSoloCupPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    // 1. Cast shadow on table
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawOval(
      Rect.fromCenter(center: center + const Offset(2, 4), width: w * 0.9, height: h * 0.85),
      shadowPaint,
    );

    // 2. Red Plastic Outer Rim (Bright classic Solo red)
    final rimPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.25),
        radius: 0.85,
        colors: [
          Color(0xFFFF3333),
          Color(0xFFE50914),
          Color(0xFF990000),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawCircle(center, w * 0.46, rimPaint);

    // 3. Characteristic White Rolled Lip Ring
    final whiteLipPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.07;
    canvas.drawCircle(center, w * 0.40, whiteLipPaint);

    // 4. Deep Dark Hollow Interior (Beer/Cup Depth)
    final interiorPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.2, 0.2),
        radius: 0.8,
        colors: [
          Color(0xFF5A0000),
          Color(0xFF280000),
          Color(0xFF0F0000),
        ],
      ).createShader(Rect.fromCenter(center: center, width: w * 0.7, height: h * 0.7));
    canvas.drawCircle(center, w * 0.36, interiorPaint);

    // 5. Specular highlight curve
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final arcRect = Rect.fromCircle(center: center, radius: w * 0.42);
    canvas.drawArc(arcRect, 3.8, 1.2, false, highlightPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ─── 5. REALISTIC PING PONG BALL ───
/// Renders 3D celluloid sphere with realistic specular glare and table cast shadow
class RealisticPingPongBall extends StatelessWidget {
  final double size;

  const RealisticPingPongBall({super.key, this.size = 28});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _PingPongBallPainter(),
      ),
    );
  }
}

class _PingPongBallPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final center = Offset(w / 2, w / 2);

    // 1. Soft spherical gradient
    final ballGradient = const RadialGradient(
      center: Alignment(-0.35, -0.35),
      radius: 0.85,
      colors: [
        Color(0xFFFFFFFF),
        Color(0xFFF5F7FA),
        Color(0xFFE2E8F0),
        Color(0xFFCBD5E1),
      ],
      stops: [0.0, 0.4, 0.75, 1.0],
    );

    canvas.drawCircle(
      center,
      w * 0.46,
      Paint()..shader = ballGradient.createShader(Offset.zero & size),
    );

    // 2. Specular pinpoint glare (light glint)
    final glarePaint = Paint()..color = Colors.white;
    canvas.drawCircle(center + Offset(-w * 0.16, -w * 0.16), w * 0.08, glarePaint);

    // 3. Ambient rim shadow
    final rimPaint = Paint()
      ..color = const Color(0xFF94A3B8).withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawCircle(center, w * 0.46, rimPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ─── 6. REALISTIC CARROM BOARD MARKINGS & POCKETS ───
/// Authentic rosewood frame, center rosette, baseline arrows, and mesh net pockets
class RealisticCarromBoardWidget extends StatelessWidget {
  final double boardSize;
  final Widget child;

  const RealisticCarromBoardWidget({
    super.key,
    required this.boardSize,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        // Authentic Rosewood Outer Frame with Rounded Corners
        color: const Color(0xFF3E1F0F),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF241107), width: 14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.65),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.35),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          // Polished lacquered birch surface
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              radius: 0.85,
              colors: [
                Color(0xFFFFF6D6),
                Color(0xFFFBEBC0),
                Color(0xFFF3DE9F),
              ],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Board markings (rosette, arrows, baseline)
              CustomPaint(
                size: Size(boardSize, boardSize),
                painter: _CarromBoardMarkingsPainter(),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _CarromBoardMarkingsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    final linePaint = Paint()
      ..color = const Color(0xFF8B2500)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    final redPaint = Paint()
      ..color = const Color(0xFFDC2626)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;

    // 1. Center Circle (Inner & Outer)
    canvas.drawCircle(center, 38, linePaint);
    canvas.drawCircle(center, 12, Paint()..color = const Color(0xFFDC2626));
    canvas.drawCircle(center, 4, Paint()..color = Colors.white);

    // Decorative petals in center rosette
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi) / 4;
      final petalCenter = center + Offset(cos(angle) * 24, sin(angle) * 24);
      canvas.drawCircle(petalCenter, 5, redPaint);
    }

    // 2. Baselines on all 4 sides with end circles
    final margin = 48.0;
    _drawBaseline(canvas, Offset(margin, h - margin), Offset(w - margin, h - margin));
    _drawBaseline(canvas, Offset(margin, margin), Offset(w - margin, margin));
    _drawBaseline(canvas, Offset(margin, margin), Offset(margin, h - margin));
    _drawBaseline(canvas, Offset(w - margin, margin), Offset(w - margin, h - margin));

    // 3. Corner Arrow Markings
    _drawCornerArrow(canvas, Offset(margin * 0.7, margin * 0.7), center);
    _drawCornerArrow(canvas, Offset(w - margin * 0.7, margin * 0.7), center);
    _drawCornerArrow(canvas, Offset(margin * 0.7, h - margin * 0.7), center);
    _drawCornerArrow(canvas, Offset(w - margin * 0.7, h - margin * 0.7), center);
  }

  void _drawBaseline(Canvas canvas, Offset p1, Offset p2) {
    final paint = Paint()
      ..color = const Color(0xFF8B2500)
      ..strokeWidth = 1.4;
    canvas.drawLine(p1, p2, paint);

    // End circles (Red base circles)
    final redFill = Paint()..color = const Color(0xFFDC2626);
    canvas.drawCircle(p1, 6, redFill);
    canvas.drawCircle(p2, 6, redFill);
  }

  void _drawCornerArrow(Canvas canvas, Offset corner, Offset center) {
    final paint = Paint()
      ..color = const Color(0xFF8B2500)
      ..strokeWidth = 1.2;
    final dir = (center - corner);
    final target = corner + (dir / dir.distance) * 40;
    canvas.drawLine(corner, target, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ─── 7. REALISTIC 3D CARROM COIN ───
class RealisticCarromCoin extends StatelessWidget {
  final double radius;
  final bool isQueen;
  final bool isWhite;

  const RealisticCarromCoin({
    super.key,
    required this.radius,
    this.isQueen = false,
    this.isWhite = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.85,
          colors: isQueen
              ? const [Color(0xFFFF5252), Color(0xFFDC2626), Color(0xFF880000)]
              : isWhite
                  ? const [Color(0xFFFFFFFF), Color(0xFFF1ECD9), Color(0xFFC7BCA3)]
                  : const [Color(0xFF475569), Color(0xFF1E293B), Color(0xFF020617)],
        ),
        border: Border.all(
          color: isQueen
              ? const Color(0xFFFFD53D)
              : isWhite
                  ? const Color(0xFFB8AA91)
                  : const Color(0xFF0F172A),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 4,
            offset: const Offset(1, 3),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: radius * 0.9,
          height: radius * 0.9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isQueen ? Colors.white.withOpacity(0.7) : Colors.black.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: isQueen
              ? const Center(
                  child: Text('✦', style: TextStyle(color: Color(0xFFFFD53D), fontSize: 10, fontWeight: FontWeight.bold)),
                )
              : null,
        ),
      ),
    );
  }
}

/// ─── 8. REALISTIC 3D CARROM STRIKER ───
class RealisticCarromStriker extends StatelessWidget {
  final double radius;

  const RealisticCarromStriker({super.key, required this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          center: Alignment(-0.35, -0.35),
          radius: 0.85,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFF7E52FF),
            Color(0xFF4E21D4),
            Color(0xFF2A0D85),
          ],
          stops: [0.0, 0.4, 0.75, 1.0],
        ),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E52FF).withOpacity(0.6),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 6,
            offset: const Offset(2, 4),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: radius * 0.8,
          height: radius * 0.8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFFFD53D), width: 1.5),
          ),
          child: const Center(
            child: Text('⚡', style: TextStyle(fontSize: 12, color: Colors.white)),
          ),
        ),
      ),
    );
  }
}

/// ─── 9. REALISTIC 3D TIC-TAC-TOE BOARD & TOKENS ───
class RealisticTttToken extends StatelessWidget {
  final String player; // 'X' or 'O'
  final double size;

  const RealisticTttToken({super.key, required this.player, this.size = 56});

  @override
  Widget build(BuildContext context) {
    final isX = player == 'X';

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _TttPiecePainter(isX: isX),
      ),
    );
  }
}

class _TttPiecePainter extends CustomPainter {
  final bool isX;

  _TttPiecePainter({required this.isX});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final center = Offset(w / 2, w / 2);

    if (isX) {
      // 3D Beveled Red/Coral Cross Piece with drop shadow
      final shadowPaint = Paint()
        ..color = const Color(0x66000000)
        ..strokeWidth = w * 0.22
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

      final p1 = Offset(w * 0.2, w * 0.2);
      final p2 = Offset(w * 0.8, w * 0.8);
      final p3 = Offset(w * 0.8, w * 0.2);
      final p4 = Offset(w * 0.2, w * 0.8);

      canvas.drawLine(p1 + const Offset(2, 3), p2 + const Offset(2, 3), shadowPaint);
      canvas.drawLine(p3 + const Offset(2, 3), p4 + const Offset(2, 3), shadowPaint);

      // Main Cross body
      final mainPaint = Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6B6B), Color(0xFFEE5253), Color(0xFFC23616)],
        ).createShader(Offset.zero & size)
        ..strokeWidth = w * 0.20
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1, p2, mainPaint);
      canvas.drawLine(p3, p4, mainPaint);

      // Highlight line
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.5)
        ..strokeWidth = w * 0.06
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(p1 + Offset(w * 0.05, 0), p2 - Offset(w * 0.05, 0), highlightPaint);
    } else {
      // 3D Beveled Blue/Cyan Torus Ring with drop shadow
      final shadowPaint = Paint()
        ..color = const Color(0x66000000)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.20
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
      canvas.drawCircle(center + const Offset(2, 3), w * 0.32, shadowPaint);

      final mainPaint = Paint()
        ..shader = const RadialGradient(
          center: Alignment(-0.35, -0.35),
          radius: 0.85,
          colors: [Color(0xFF54A0FF), Color(0xFF2E86DE), Color(0xFF0A3D62)],
        ).createShader(Offset.zero & size)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.20;
      canvas.drawCircle(center, w * 0.32, mainPaint);

      // Gloss arc highlight
      final highlightPaint = Paint()
        ..color = Colors.white.withOpacity(0.55)
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.05
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(Rect.fromCircle(center: center, radius: w * 0.33), 3.6, 1.4, false, highlightPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ─── 10. REALISTIC 3D GLASS MARBLE ───
class RealisticGlassMarble extends StatelessWidget {
  final double radius;
  final Color? color;
  final Color swirlColor;
  final bool isShooter;

  const RealisticGlassMarble({
    super.key,
    required this.radius,
    this.color,
    required this.swirlColor,
    this.isShooter = false,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? swirlColor;
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.35),
          radius: 0.85,
          colors: [
            Colors.white.withOpacity(0.9),
            effectiveColor.withOpacity(0.85),
            effectiveColor,
            const Color(0xFF0F172A),
          ],
          stops: const [0.0, 0.35, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
            blurRadius: 6,
            offset: const Offset(1, 3),
          ),
          if (isShooter)
            BoxShadow(
              color: swirlColor.withOpacity(0.6),
              blurRadius: 10,
              spreadRadius: 1,
            ),
        ],
      ),
      child: Center(
        child: Container(
          width: radius * 0.4,
          height: radius * 0.4,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}

/// ─── 11. REALISTIC 3D CONNECT 4 DISC ───
class RealisticConnect4Disc extends StatelessWidget {
  final int player; // 0: empty, 1: red, 2: yellow
  final double size;
  final bool isWinning;

  const RealisticConnect4Disc({
    super.key,
    required this.player,
    this.size = 36,
    this.isWinning = false,
  });

  @override
  Widget build(BuildContext context) {
    if (player == 0) {
      // Hollow slot hole into deep backboard
      return Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            center: Alignment(0.1, 0.1),
            radius: 0.85,
            colors: [Color(0xFF0F172A), Color(0xFF020617)],
          ),
          border: Border.all(color: const Color(0xFF1E293B), width: 1.5),
        ),
      );
    }

    final isRed = player == 1;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.3, -0.3),
          radius: 0.85,
          colors: isRed
              ? const [Color(0xFFFF6B6B), Color(0xFFEE5253), Color(0xFFC23616)]
              : const [Color(0xFFFECA57), Color(0xFFFF9F43), Color(0xFFEE5A24)],
        ),
        border: Border.all(
          color: isWinning ? Colors.white : (isRed ? const Color(0xFF990000) : const Color(0xFFC77700)),
          width: isWinning ? 3 : 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: isWinning ? 12 : 5,
            offset: const Offset(1, 3),
          ),
          if (isWinning)
            BoxShadow(
              color: (isRed ? const Color(0xFFFF5252) : const Color(0xFFFFD53D)).withOpacity(0.6),
              blurRadius: 14,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Center(
        child: Container(
          width: size * 0.55,
          height: size * 0.55,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.35),
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }
}
