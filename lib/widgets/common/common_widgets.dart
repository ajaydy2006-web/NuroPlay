import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Primary accent button with vibrant clay purple gradient
typedef NuroPlayButton = MindRushButton;

class MindRushButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool isOutlined;
  final double? width;
  final EdgeInsets? padding;
  final Gradient? gradient;

  const MindRushButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.isOutlined = false,
    this.width,
    this.padding,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    if (isOutlined) {
      return SizedBox(
        width: width,
        child: OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.primaryAccent, width: 2),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _buildChild(AppColors.primaryAccent),
        ),
      );
    }

    final activeGradient = gradient ?? AppColors.accentGradient;

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          gradient: activeGradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withOpacity(0.35),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: _buildChild(Colors.white),
        ),
      ),
    );
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(color),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
        ],
        Text(label, style: AppTypography.button.copyWith(color: color)),
      ],
    );
  }
}

/// Claymorphic Game Card with soft 3D shadow and rounded corners
class GameCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final LinearGradient? gradient;
  final Color? borderColor;
  final double borderRadius;

  const GameCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.gradient,
    this.borderColor,
    this.borderRadius = 24,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: gradient == null ? Colors.white : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor ?? Colors.white,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0x1A7E52FF),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
            const BoxShadow(
              color: Colors.white,
              blurRadius: 6,
              offset: Offset(-2, -2),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Stat chip showing label + value in clay style
class StatChip extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final Color? valueColor;

  const StatChip({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null)
          Icon(icon, size: 22, color: valueColor ?? AppColors.primaryAccent),
        if (icon != null) const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.heading3.copyWith(
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.secondaryText,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

/// Section header with optional action
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: AppTypography.heading3.copyWith(
              color: AppColors.primaryText,
              fontWeight: FontWeight.w900,
              fontSize: 18,
            ),
          ),
          if (actionLabel != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.labelMedium.copyWith(
                  color: AppColors.primaryAccent,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Avatar circle widget
class AvatarCircle extends StatelessWidget {
  final String emoji;
  final double size;
  final Color? borderColor;

  const AvatarCircle({
    super.key,
    required this.emoji,
    this.size = 48,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFF0E8FF),
        borderRadius: BorderRadius.circular(size * 0.35),
        boxShadow: const [
          BoxShadow(
            color: Color(0x187E52FF),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 4,
            offset: Offset(-1, -1),
          ),
        ],
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.52),
        ),
      ),
    );
  }
}

/// Animated progress bar with clay track & vivid purple fill
class AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;
  final double height;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 10,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFEFEAF9),
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            color: color ?? AppColors.primaryAccent,
            borderRadius: BorderRadius.circular(height / 2),
            boxShadow: [
              BoxShadow(
                color: (color ?? AppColors.primaryAccent).withOpacity(0.35),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 3D Claymorphic Pastel Background with floating soft spheres (as in reference UI)
typedef NuroPlayBackground = NeonRiseBackground;

class NeonRiseBackground extends StatelessWidget {
  final Widget child;
  final bool showMiddleBeam;

  const NeonRiseBackground({
    super.key,
    required this.child,
    this.showMiddleBeam = true,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Base pastel lilac canvas
        Container(
          color: AppColors.primaryBg,
        ),

        // 1. Top-Left 3D Soft Yellow Clay Sphere
        Positioned(
          top: -30,
          left: -40,
          child: Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.35, -0.35),
                radius: 0.85,
                colors: [
                  Color(0xFFFFEA8D),
                  Color(0xFFFFD555),
                  Color(0xFFF7BD22),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFD555).withOpacity(0.4),
                  blurRadius: 30,
                  offset: const Offset(8, 12),
                ),
              ],
            ),
          ),
        ),

        // 2. Top-Right 3D Soft Warm Pink Clay Sphere
        Positioned(
          top: 60,
          right: -50,
          child: Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.3),
                radius: 0.85,
                colors: [
                  Color(0xFFFFC0D0),
                  Color(0xFFFFA5BA),
                  Color(0xFFFF7A97),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF8DA1).withOpacity(0.35),
                  blurRadius: 32,
                  offset: const Offset(-8, 14),
                ),
              ],
            ),
          ),
        ),

        // 3. Bottom-Left 3D Periwinkle Blue Sphere
        Positioned(
          bottom: 120,
          left: -60,
          child: Container(
            width: 150,
            height: 150,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                center: Alignment(-0.3, -0.3),
                radius: 0.85,
                colors: [
                  Color(0xFFB3D0FF),
                  Color(0xFF88AEFF),
                  Color(0xFF5A8EFF),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF74A8FF).withOpacity(0.35),
                  blurRadius: 30,
                  offset: const Offset(10, 10),
                ),
              ],
            ),
          ),
        ),

        // 4. Subtle ambient glow in center
        Center(
          child: Container(
            width: 400,
            height: 400,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  Colors.white.withOpacity(0.35),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Foreground content
        Positioned.fill(child: child),
      ],
    );
  }
}
