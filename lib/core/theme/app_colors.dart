import 'package:flutter/material.dart';

/// NuroPlay Design Tokens — Playful 3D Claymorphic Pastel Lilac & Purple Palette
class AppColors {
  AppColors._();

  // ─── Pastel Canvas & Backgrounds (Claymorphic) ───
  static const Color primaryBg = Color(0xFFEFEBFE);      // Soft pastel lavender/lilac
  static const Color secondaryBg = Color(0xFFF7F3FF);    // Lighter pastel surface
  static const Color cardBg = Color(0xFFFFFFFF);         // Pure white clay cards
  static const Color elevatedCard = Color(0xFFFFFFFF);   // Elevated clay card
  static const Color cardHover = Color(0xFFF5F0FF);      // Soft hover surface

  // ─── High-Contrast Typography ───
  static const Color primaryText = Color(0xFF1E1842);    // Deep dark indigo/navy
  static const Color creamText = Color(0xFF1E1842);      // Dark text for primary reading
  static const Color secondaryText = Color(0xFF8680A6);  // Soft slate-lavender
  static const Color textMuted = Color(0xFFA59FBD);      // Muted caption text
  static const Color textTertiary = Color(0xFFB8B3CE);

  // ─── Claymorphic Purples & Accents ───
  static const Color primaryAccent = Color(0xFF7E52FF);  // Vivid Clay Purple
  static const Color primaryPurpleDark = Color(0xFF6B3EF5);
  static const Color primaryPurpleLight = Color(0xFFEADBFF);
  static const Color secondaryAccent = Color(0xFF9E7CFF);// Medium Lilac Purple
  static const Color neonCerulean = Color(0xFF7E52FF);
  static const Color accentCyan = Color(0xFF389BFF);     // Sky Blue for Casual feed
  static const Color accentLime = Color(0xFF75D826);     // Lime Apple Green
  static const Color accentOrange = Color(0xFFFFA048);   // Warm Tangerine
  static const Color accentYellow = Color(0xFFFFD53D);   // Sunshine Gold
  static const Color accentPink = Color(0xFFFF5252);     // Coral Rose
  static const Color accentPurple = Color(0xFF7E52FF);   // Clay Purple
  static const Color neonRise = Color(0xFF7E52FF);

  // ─── 3D Clay Background Spheres ───
  static const Color blobYellow = Color(0xFFFFD555);
  static const Color blobPink = Color(0xFFFFA5BA);
  static const Color blobBlue = Color(0xFF88AEFF);

  // ─── Cute Category Clay Characters ───
  static const Color catMathRed = Color(0xFFFF5252);
  static const Color catLogicOrange = Color(0xFFFFA048);
  static const Color catMemoryYellow = Color(0xFFFFD53D);
  static const Color catReactionGreen = Color(0xFF75D826);

  // ─── Status Colors ───
  static const Color success = Color(0xFF75D826);
  static const Color error = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFD53D);

  // ─── Borders, Dividers & Shadows ───
  static const Color divider = Color(0xFFEFEAF9);
  static const Color borderHighlight = Color(0xFF7E52FF);
  static const Color clayShadow = Color(0x227E52FF);
  static const Color clayWhiteHighlight = Colors.white;

  // ─── Compatibility Aliases ───
  static const Color surfaceBorder = Color(0xFFEFEAF9);
  static const Color textPrimary = Color(0xFF1E1842);
  static const Color textSecondary = Color(0xFF8680A6);
  static const Color surfaceDark = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFFEFEBFE);
  static const LinearGradient purpleGradient = accentGradient;

  // ─── Signature Gradients ───
  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF8C61FF), Color(0xFF7341FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantMixGradient = LinearGradient(
    colors: [Color(0xFF8C61FF), Color(0xFF7341FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetMixGradient = LinearGradient(
    colors: [Color(0xFFFF5252), Color(0xFFFFA048)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFFAF7FF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient purpleFeaturedGradient = LinearGradient(
    colors: [Color(0xFF8C61FF), Color(0xFF7341FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
