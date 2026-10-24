import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

enum DevicePreset {
  iphone('iPhone 15 Pro', 400, 850, 48),
  pixel('Pixel 8', 390, 840, 36),
  compact('Compact Phone', 360, 780, 32),
  fullView('Full Screen', 0, 0, 0);

  final String label;
  final double width;
  final double height;
  final double radius;

  const DevicePreset(this.label, this.width, this.height, this.radius);
}

class PhoneInterfaceWrapper extends StatefulWidget {
  final Widget child;

  const PhoneInterfaceWrapper({super.key, required this.child});

  @override
  State<PhoneInterfaceWrapper> createState() => _PhoneInterfaceWrapperState();
}

class _PhoneInterfaceWrapperState extends State<PhoneInterfaceWrapper> {
  DevicePreset _activePreset = DevicePreset.iphone;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // If screen is already mobile phone width (<= 500px) or user selected Full View:
        if (constraints.maxWidth <= 500 || _activePreset == DevicePreset.fullView) {
          return widget.child;
        }

        // On desktop/tablet screen: Show the centered Smartphone Interface
        final targetWidth = _activePreset.width;
        final targetHeight = min(_activePreset.height, constraints.maxHeight - 50);

        return Scaffold(
          backgroundColor: const Color(0xFF070D09),
          body: Stack(
            children: [
              // Subtle background mesh orbs on desktop canvas
              Positioned(
                top: -80,
                left: 100,
                child: Container(
                  width: 380,
                  height: 380,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primaryAccent.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                right: 120,
                child: Container(
                  width: 420,
                  height: 420,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.secondaryAccent.withOpacity(0.07),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              // Main Desktop Stage
              SafeArea(
                child: Column(
                  children: [
                    // Top Desktop Device Switcher Bar
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg.withOpacity(0.85),
                        border: const Border(
                          bottom: BorderSide(color: AppColors.divider, width: 0.8),
                        ),
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: AppColors.vibrantMixGradient,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.phone_iphone_rounded, size: 16, color: Colors.black),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'NuroPlay Phone View',
                                style: AppTypography.heading3.copyWith(
                                  fontSize: 16,
                                  color: AppColors.creamText,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Presets Selector
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.cardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.divider),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: DevicePreset.values.map((preset) {
                                final isSel = _activePreset == preset;
                                return GestureDetector(
                                  onTap: () => setState(() => _activePreset = preset),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: isSel ? AppColors.primaryAccent : Colors.transparent,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      preset.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        color: isSel ? Colors.black : AppColors.secondaryText,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Centered Phone Frame Stage
                    Expanded(
                      child: Center(
                        child: Container(
                          width: targetWidth,
                          height: targetHeight,
                          margin: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBg,
                            borderRadius: BorderRadius.circular(_activePreset.radius),
                            border: Border.all(
                              color: const Color(0xFF2C4535),
                              width: 8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.75),
                                blurRadius: 40,
                                spreadRadius: 4,
                                offset: const Offset(0, 16),
                              ),
                              BoxShadow(
                                color: AppColors.primaryAccent.withOpacity(0.12),
                                blurRadius: 24,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(_activePreset.radius - 8),
                            child: Stack(
                              children: [
                                // Inner App Application
                                Positioned.fill(child: widget.child),

                                // Phone Notch / Dynamic Island at top
                                Positioned(
                                  top: 10,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      width: 120,
                                      height: 26,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Container(
                                            width: 10,
                                            height: 10,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF1E293B),
                                            ),
                                          ),
                                          Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFF0F172A),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),

                                // Bottom Home Bar Gesture Pill
                                Positioned(
                                  bottom: 6,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      width: 120,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.35),
                                        borderRadius: BorderRadius.circular(2),
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
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
