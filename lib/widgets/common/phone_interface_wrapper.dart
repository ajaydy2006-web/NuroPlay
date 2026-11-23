import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

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
          backgroundColor: const Color(0xFFE2D6F5),
          body: Stack(
            children: [
              // Ambient soft 3D background orbs on desktop canvas
              Positioned(
                top: -60,
                left: 60,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFFE177),
                        Color(0xFFFFD555),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD555).withOpacity(0.3),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                ),
              ),

              Positioned(
                bottom: -80,
                right: 80,
                child: Container(
                  width: 340,
                  height: 340,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(
                      colors: [
                        Color(0xFFFF9DB4),
                        Color(0xFFFFA5BA),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFF8DA1).withOpacity(0.3),
                        blurRadius: 40,
                      ),
                    ],
                  ),
                ),
              ),

              // Main Desktop Stage
              SafeArea(
                child: Column(
                  children: [
                    // Top Desktop Device Switcher Bar (White Clay Pill)
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x147E52FF),
                            blurRadius: 16,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  gradient: AppColors.accentGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.phone_iphone_rounded, size: 16, color: Colors.white),
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                'NuroPlay 3D Clay UI',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF1E1842),
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          // Presets Selector
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3EEFD),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: DevicePreset.values.map((preset) {
                                final isSel = _activePreset == preset;
                                return GestureDetector(
                                  onTap: () => setState(() => _activePreset = preset),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: isSel ? const Color(0xFF7E52FF) : Colors.transparent,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: isSel
                                          ? const [
                                              BoxShadow(
                                                color: Color(0x337E52FF),
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    child: Text(
                                      preset.label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                        color: isSel ? Colors.white : const Color(0xFF8680A6),
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
                          margin: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBg,
                            borderRadius: BorderRadius.circular(_activePreset.radius),
                            border: Border.all(
                              color: const Color(0xFF1E1538),
                              width: 8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0x3A441B9B),
                                blurRadius: 40,
                                spreadRadius: 4,
                                offset: const Offset(0, 16),
                              ),
                              BoxShadow(
                                color: AppColors.primaryAccent.withOpacity(0.18),
                                blurRadius: 28,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(_activePreset.radius - 8),
                            child: Stack(
                              children: [
                                // Inner App with simulated SafeArea insets
                                Positioned.fill(
                                  child: MediaQuery(
                                    data: MediaQuery.of(context).copyWith(
                                      padding: const EdgeInsets.only(top: 44, bottom: 20),
                                      viewPadding: const EdgeInsets.only(top: 44, bottom: 20),
                                    ),
                                    child: widget.child,
                                  ),
                                ),

                                // Top Status Bar (8:48, WiFi, Signal, 77% Battery as in screenshot)
                                Positioned(
                                  top: 8,
                                  left: 24,
                                  right: 24,
                                  child: IgnorePointer(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          '8:48',
                                          style: TextStyle(
                                            color: Color(0xFF1E1842),
                                            fontWeight: FontWeight.w900,
                                            fontSize: 13,
                                          ),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
                                            Icon(Icons.signal_cellular_alt_rounded, size: 14, color: Color(0xFF1E1842)),
                                            SizedBox(width: 4),
                                            Icon(Icons.wifi_rounded, size: 14, color: Color(0xFF1E1842)),
                                            SizedBox(width: 4),
                                            Icon(Icons.battery_5_bar_rounded, size: 16, color: Color(0xFF1E1842)),
                                            SizedBox(width: 2),
                                            Text(
                                              '77',
                                              style: TextStyle(
                                                color: Color(0xFF1E1842),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),

                                // Bottom Home Gesture Pill
                                Positioned(
                                  bottom: 6,
                                  left: 0,
                                  right: 0,
                                  child: IgnorePointer(
                                    child: Center(
                                      child: Container(
                                        width: 120,
                                        height: 4,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF1E1842).withOpacity(0.3),
                                          borderRadius: BorderRadius.circular(2),
                                        ),
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
