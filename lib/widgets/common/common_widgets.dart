import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Primary accent button with vibrant gradient background
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
            side: const BorderSide(color: AppColors.primaryAccent, width: 1.5),
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _buildChild(AppColors.primaryAccent),
        ),
      );
    }

    final activeGradient = gradient ?? AppColors.vibrantMixGradient;

    return SizedBox(
      width: width,
      child: Container(
        decoration: BoxDecoration(
          gradient: activeGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withOpacity(0.35),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          child: _buildChild(AppColors.primaryBg),
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

/// Game card widget with border and optional gradient
class GameCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets? padding;
  final LinearGradient? gradient;
  final Color? borderColor;

  const GameCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
    this.gradient,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: gradient == null ? AppColors.cardBg : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor ?? AppColors.divider,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

/// Stat chip showing label + value
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.elevatedCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        children: [
          if (icon != null)
            Icon(icon, size: 16, color: valueColor ?? AppColors.primaryAccent),
          if (icon != null) const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.monoBody.copyWith(
              color: valueColor ?? AppColors.primaryAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppTypography.bodySmall),
        ],
      ),
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
          Text(title, style: AppTypography.heading4),
          if (actionLabel != null)
            TextButton(
              onPressed: onAction,
              child: Text(
                actionLabel!,
                style: AppTypography.labelSmall.copyWith(color: AppColors.primaryAccent),
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
        shape: BoxShape.circle,
        color: AppColors.elevatedCard,
        border: Border.all(
          color: borderColor ?? AppColors.primaryAccent.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          emoji,
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
}

/// Animated progress bar
class AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;
  final double height;

  const AnimatedProgressBar({
    super.key,
    required this.progress,
    this.color,
    this.height = 6,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: progress.clamp(0.0, 1.0),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                color ?? AppColors.primaryAccent,
                (color ?? AppColors.primaryAccent).withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(height / 2),
          ),
        ),
      ),
    );
  }
}

/// Ambient vibrant background with organic forest base and glowing mesh orbs
class NuroPlayBackground extends StatelessWidget {
  final Widget child;

  const NuroPlayBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Base dark organic pine background
        Positioned.fill(
          child: Container(
            color: AppColors.primaryBg,
          ),
        ),

        // Glowing Top-Left Neon Lime Orb
        Positioned(
          top: -120,
          left: -100,
          child: Container(
            width: 320,
            height: 320,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.primaryAccent.withOpacity(0.12),
                  AppColors.primaryAccent.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // Glowing Top-Right Sunset Coral Orb
        Positioned(
          top: 40,
          right: -120,
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.secondaryAccent.withOpacity(0.10),
                  AppColors.secondaryAccent.withOpacity(0.0),
                ],
              ),
            ),
          ),
        ),

        // Glowing Bottom-Center Cyan / Violet Orb
        Positioned(
          bottom: -100,
          left: 40,
          child: Container(
            width: 360,
            height: 360,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.accentCyan.withOpacity(0.08),
                  AppColors.accentPurple.withOpacity(0.0),
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
