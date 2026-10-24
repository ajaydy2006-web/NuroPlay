import 'package:flutter/material.dart';

/// NuroPlay Design Tokens — vibrant, organic forest & retro display color palette
class AppColors {
  AppColors._();

  // ─── Deep Organic Forest & Pine Backgrounds ───
  static const Color primaryBg = Color(0xFF0E1812);      // Deep pine obsidian
  static const Color secondaryBg = Color(0xFF14241B);    // Dark moss slate
  static const Color cardBg = Color(0xFF1A2E23);         // Lush forest surface
  static const Color elevatedCard = Color(0xFF233D2F);   // Elevated moss surface
  static const Color cardHover = Color(0xFF2B4A3A);      // Interactive hover surface

  // ─── Signature Pearl Jean Cream & Text ───
  static const Color creamText = Color(0xFFFBF2D8);      // Signature Pearl Jean warm butter cream
  static const Color primaryText = Color(0xFFFBF2D8);    // Primary readable text
  static const Color secondaryText = Color(0xFFB0C6B8);  // Soft sage mint secondary
  static const Color textMuted = Color(0xFF7A9484);      // Darker sage caption text
  static const Color textTertiary = Color(0xFF7A9484);

  // ─── Vibrant Pop Color Mix ───
  static const Color primaryAccent = Color(0xFF4EFA8B);  // Electric lime / neon mint pop
  static const Color secondaryAccent = Color(0xFFFF7A45);// Vibrant sunset coral / tangerine
  static const Color accentLime = Color(0xFFA3E635);     // Energetic chartreuse
  static const Color accentOrange = Color(0xFFFF7A45);   // Punchy retro orange
  static const Color accentYellow = Color(0xFFFFD15C);   // Warm solar butter gold
  static const Color accentPink = Color(0xFFFF3366);     // Vivid neon rose
  static const Color accentCyan = Color(0xFF00E5FF);     // Electric retro cyan
  static const Color accentPurple = Color(0xFFA855F7);   // Electric cyber violet

  // ─── Status Colors ───
  static const Color success = Color(0xFF4EFA8B);
  static const Color error = Color(0xFFFF3366);
  static const Color warning = Color(0xFFFFD15C);

  // ─── Borders & Dividers ───
  static const Color divider = Color(0xFF284435);
  static const Color borderHighlight = Color(0xFF3D634E);

  // ─── Signature Gradients ───
  static const LinearGradient accentGradient = LinearGradient(
    colors: [primaryAccent, Color(0xFF28C76F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantMixGradient = LinearGradient(
    colors: [primaryAccent, accentYellow, secondaryAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetMixGradient = LinearGradient(
    colors: [secondaryAccent, accentPink],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanLimeGradient = LinearGradient(
    colors: [accentCyan, primaryAccent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [accentPurple, Color(0xFF7C3AED)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardBg, elevatedCard],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundAmbientGradient = LinearGradient(
    colors: [Color(0xFF0B140F), Color(0xFF132219), Color(0xFF0E1A13)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // ─── Compatibility Aliases ───
  static const Color backgroundDark = primaryBg;
  static const Color surfaceDark = cardBg;
  static const Color surfaceBorder = divider;
  static const Color textPrimary = primaryText;
  static const Color textSecondary = secondaryText;
}
