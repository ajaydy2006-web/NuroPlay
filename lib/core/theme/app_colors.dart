import 'package:flutter/material.dart';

/// NuroPlay Design Tokens — Electrifying Black & Cerulean Blue palette inspired by Matiks
class AppColors {
  AppColors._();

  // ─── Deep Obsidian Black & Midnight Backgrounds ───
  static const Color primaryBg = Color(0xFF06090F);      // Deep obsidian black
  static const Color secondaryBg = Color(0xFF0B101D);    // Midnight cyber slate
  static const Color cardBg = Color(0xFF0F172A);         // Deep cyber navy surface
  static const Color elevatedCard = Color(0xFF142036);   // Elevated cerulean surface
  static const Color cardHover = Color(0xFF1A2A48);      // Interactive hover surface

  // ─── High-Contrast Ice-White & Slate Typography ───
  static const Color creamText = Color(0xFFF1F5F9);      // Crisp luminous ice-white
  static const Color primaryText = Color(0xFFF8FAFC);    // Primary readable text
  static const Color secondaryText = Color(0xFF94A3B8);  // Slate cerulean secondary
  static const Color textMuted = Color(0xFF64748B);      // Cyber muted caption text
  static const Color textTertiary = Color(0xFF475569);

  // ─── Electrifying Cerulean Blue & Neon Accents (Matiks Style) ───
  static const Color primaryAccent = Color(0xFF0091FF);  // Vivid Electric Cerulean Blue
  static const Color secondaryAccent = Color(0xFF00D2FF);// Neon Ice Cerulean / Cyan
  static const Color neonCerulean = Color(0xFF0091FF);   // Pure Cerulean
  static const Color accentCyan = Color(0xFF00F0FF);     // Electric Retro Cyan
  static const Color accentLime = Color(0xFF00F5A0);     // Energetic Neon Emerald
  static const Color accentOrange = Color(0xFFFF7A00);   // Punchy Electric Tangerine
  static const Color accentYellow = Color(0xFFFFB800);   // Cyber Solar Amber Gold
  static const Color accentPink = Color(0xFFFF2A6D);     // Vivid Neon Rose / Duel Crimson
  static const Color accentPurple = Color(0xFF8B5CF6);   // Electric Cyber Violet
  static const Color neonRise = Color(0xFF0091FF);       // Neon Rise central aura color

  // ─── Status Colors ───
  static const Color success = Color(0xFF00F5A0);
  static const Color error = Color(0xFFFF2A6D);
  static const Color warning = Color(0xFFFFB800);

  // ─── Borders & Dividers ───
  static const Color divider = Color(0xFF16253D);
  static const Color borderHighlight = Color(0xFF0091FF);

  // ─── Signature Gradients ───
  static const LinearGradient accentGradient = LinearGradient(
    colors: [primaryAccent, Color(0xFF00E5FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient vibrantMixGradient = LinearGradient(
    colors: [primaryAccent, secondaryAccent, Color(0xFF7928CA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetMixGradient = LinearGradient(
    colors: [accentPink, accentOrange],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanLimeGradient = LinearGradient(
    colors: [accentCyan, success],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient purpleGradient = LinearGradient(
    colors: [accentPurple, Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [cardBg, elevatedCard],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundAmbientGradient = LinearGradient(
    colors: [Color(0xFF04060A), Color(0xFF080D1A), Color(0xFF060910)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const RadialGradient ceruleanRiseGradient = RadialGradient(
    center: Alignment.center,
    radius: 0.85,
    colors: [
      Color(0x380091FF), // Glowing Cerulean center
      Color(0x1200D2FF),
      Colors.transparent,
    ],
  );

  // ─── Compatibility Aliases ───
  static const Color backgroundDark = primaryBg;
  static const Color surfaceDark = cardBg;
  static const Color surfaceBorder = divider;
  static const Color textPrimary = primaryText;
  static const Color textSecondary = secondaryText;
}
