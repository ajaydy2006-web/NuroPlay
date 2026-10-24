import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// NuroPlay Typography System
/// Inspired by the Pearl Jean handwritten display aesthetic (retro, chunky, playful, curvaceous)
class AppTypography {
  AppTypography._();

  // ─── Display & Brand Titles (Pearl Jean Inspired Display) ───
  static TextStyle brandHero = GoogleFonts.titanOne(
    fontSize: 40,
    color: AppColors.primaryText,
    letterSpacing: 0.5,
    height: 1.15,
  );

  static TextStyle displayLarge = GoogleFonts.titanOne(
    fontSize: 32,
    color: AppColors.primaryText,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle displayMedium = GoogleFonts.titanOne(
    fontSize: 26,
    color: AppColors.primaryText,
    letterSpacing: 0.5,
    height: 1.25,
  );

  static TextStyle displaySmall = GoogleFonts.titanOne(
    fontSize: 20,
    color: AppColors.primaryText,
    letterSpacing: 0.4,
    height: 1.3,
  );

  // ─── Headings (Stylized Retro Chunky) ───
  static TextStyle heading1 = GoogleFonts.titanOne(
    fontSize: 30,
    color: AppColors.primaryText,
    letterSpacing: 0.5,
    height: 1.2,
  );

  static TextStyle heading2 = GoogleFonts.titanOne(
    fontSize: 22,
    color: AppColors.primaryText,
    letterSpacing: 0.4,
    height: 1.25,
  );

  static TextStyle heading3 = GoogleFonts.titanOne(
    fontSize: 18,
    color: AppColors.primaryText,
    letterSpacing: 0.3,
    height: 1.3,
  );

  static TextStyle heading4 = GoogleFonts.titanOne(
    fontSize: 16,
    color: AppColors.primaryText,
    letterSpacing: 0.3,
    height: 1.3,
  );

  // ─── Body Text (Inter / Plus Jakarta for crisp readability) ───
  static TextStyle bodyLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryText,
    height: 1.4,
  );

  // ─── UI Labels ───
  static TextStyle labelLarge = GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    height: 1.3,
  );

  static TextStyle labelMedium = GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    height: 1.3,
  );

  static TextStyle labelSmall = GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.secondaryText,
    height: 1.3,
  );

  // ─── Numbers, Timers, Soroban & Math (JetBrains Mono) ───
  static TextStyle monoLarge = GoogleFonts.jetBrainsMono(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryText,
    height: 1.1,
  );

  static TextStyle monoMedium = GoogleFonts.jetBrainsMono(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: AppColors.primaryText,
    height: 1.2,
  );

  static TextStyle monoSmall = GoogleFonts.jetBrainsMono(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.primaryText,
    height: 1.3,
  );

  static TextStyle monoBody = GoogleFonts.jetBrainsMono(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.primaryText,
    height: 1.4,
  );

  static TextStyle monoCaption = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.secondaryText,
    height: 1.3,
  );

  // ─── Buttons ───
  static TextStyle button = GoogleFonts.titanOne(
    fontSize: 16,
    color: AppColors.primaryBg,
    letterSpacing: 0.5,
    height: 1.3,
  );

  static TextStyle buttonSmall = GoogleFonts.titanOne(
    fontSize: 14,
    color: AppColors.primaryBg,
    letterSpacing: 0.4,
    height: 1.3,
  );

  // ─── Compatibility Aliases ───
  static TextStyle get headingLarge => heading1;
  static TextStyle get headingMedium => heading2;
  static TextStyle get headingSmall => heading3;
  static TextStyle get captionSmall => labelSmall;
}
