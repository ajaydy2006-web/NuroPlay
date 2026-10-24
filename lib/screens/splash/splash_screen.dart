import 'package:flutter/material.dart';
import 'dart:math';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _symbolsController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _taglineOpacity;

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _symbolsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
      ),
    );

    _logoController.forward();

    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    if (StorageService.hasSeenOnboarding && StorageService.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed('/main');
    } else if (StorageService.hasSeenOnboarding) {
      Navigator.of(context).pushReplacementNamed('/auth');
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _symbolsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: Stack(
        children: [
          // Animated math symbols background
          ...List.generate(15, (index) => _FloatingSymbol(
            controller: _symbolsController,
            index: index,
          )),

          // Main content
          Center(
            child: AnimatedBuilder(
              animation: _logoController,
              builder: (context, child) {
                return Opacity(
                  opacity: _logoOpacity.value,
                  child: Transform.scale(
                    scale: _logoScale.value,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo icon
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: AppColors.accentGradient,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryAccent.withOpacity(0.4),
                                blurRadius: 30,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              '⚡',
                              style: TextStyle(fontSize: 48),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // App name
                        Text(
                          'NuroPlay',
                          style: AppTypography.brandHero.copyWith(
                            fontSize: 44,
                            color: AppColors.creamText,
                            shadows: [
                              Shadow(
                                color: AppColors.primaryAccent.withOpacity(0.6),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Tagline
                        Opacity(
                          opacity: _taglineOpacity.value,
                          child: Text(
                            'Think Fast. Play Smart.',
                            style: AppTypography.labelLarge.copyWith(
                              color: AppColors.primaryAccent,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Loading indicator at bottom
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppColors.primaryAccent.withOpacity(0.5),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Floating math symbol for splash background
class _FloatingSymbol extends StatelessWidget {
  final AnimationController controller;
  final int index;

  const _FloatingSymbol({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    final symbols = ['+', '−', '×', '÷', '=', '∑', 'π', '√', '%', '∞',
                     '±', '≠', '<', '>', '∫'];
    final random = Random(index * 42);
    final size = MediaQuery.of(context).size;

    final startX = random.nextDouble() * size.width;
    final startY = random.nextDouble() * size.height;
    final fontSize = 16.0 + random.nextDouble() * 20;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final t = (controller.value + index * 0.07) % 1.0;
        return Positioned(
          left: startX + sin(t * 2 * pi) * 20,
          top: startY + cos(t * 2 * pi) * 15 - (t * 50),
          child: Opacity(
            opacity: (0.08 + sin(t * pi) * 0.07).clamp(0.0, 1.0),
            child: Text(
              symbols[index % symbols.length],
              style: TextStyle(
                fontSize: fontSize,
                color: AppColors.primaryAccent,
                fontWeight: FontWeight.w300,
              ),
            ),
          ),
        );
      },
    );
  }
}
