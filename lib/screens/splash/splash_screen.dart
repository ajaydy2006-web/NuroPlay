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
  // Phase 1: Logo entrance (scale + fade in)
  late AnimationController _logoEntranceController;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  // Phase 2: Glow pulse around logo
  late AnimationController _glowController;
  late Animation<double> _glowRadius;

  // Phase 3: Brand text slide up + fade
  late AnimationController _brandController;
  late Animation<double> _brandSlide;
  late Animation<double> _brandOpacity;
  late Animation<double> _taglineOpacity;

  // Phase 4: Floating particles
  late AnimationController _particleController;

  // Phase 5: Exit transition — everything scales up and fades out
  late AnimationController _exitController;
  late Animation<double> _exitScale;
  late Animation<double> _exitOpacity;

  // Background gradient shift
  late AnimationController _bgController;
  late Animation<Color?> _bgColor1;
  late Animation<Color?> _bgColor2;

  // Sparkle particles data
  final List<_SparkleParticle> _sparkles = [];
  final _random = Random(42);

  @override
  void initState() {
    super.initState();

    // Generate sparkle particles
    for (int i = 0; i < 20; i++) {
      _sparkles.add(_SparkleParticle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 2.0 + _random.nextDouble() * 4.0,
        speed: 0.3 + _random.nextDouble() * 0.7,
        delay: _random.nextDouble() * 0.5,
      ));
    }

    // === Phase 1: Logo entrance ===
    _logoEntranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoEntranceController,
        curve: Curves.elasticOut,
      ),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoEntranceController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    // === Phase 2: Glow pulse ===
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _glowRadius = Tween<double>(begin: 0.0, end: 40.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // === Phase 3: Brand text ===
    _brandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _brandSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _brandController, curve: Curves.easeOutCubic),
    );
    _brandOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _brandController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );
    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _brandController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeIn),
      ),
    );

    // === Phase 4: Particles ===
    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // === Phase 5: Exit ===
    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _exitScale = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeInCubic),
    );

    // === Background gradient shift ===
    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _bgColor1 = ColorTween(
      begin: const Color(0xFF6B3EF5),
      end: const Color(0xFF8C61FF),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));
    _bgColor2 = ColorTween(
      begin: const Color(0xFF4A1DB8),
      end: const Color(0xFF7341FF),
    ).animate(CurvedAnimation(parent: _bgController, curve: Curves.easeInOut));

    _startSequence();
  }

  Future<void> _startSequence() async {
    // Start background gradient shift
    _bgController.forward();

    // Phase 1: Logo entrance with slight delay
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoEntranceController.forward();

    // Phase 2: Glow starts after logo lands
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    _glowController.forward();

    // Phase 3: Brand text slides up
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    _brandController.forward();

    // Wait for the full splash duration
    await Future.delayed(const Duration(milliseconds: 1200));
    if (!mounted) return;

    // Phase 5: Exit animation
    _exitController.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    _navigate();
  }

  void _navigate() {
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
    _logoEntranceController.dispose();
    _glowController.dispose();
    _brandController.dispose();
    _particleController.dispose();
    _exitController.dispose();
    _bgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _bgController,
          _logoEntranceController,
          _glowController,
          _brandController,
          _particleController,
          _exitController,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: _exitScale.value,
            child: Opacity(
              opacity: _exitOpacity.value,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _bgColor1.value ?? const Color(0xFF6B3EF5),
                      _bgColor2.value ?? const Color(0xFF4A1DB8),
                    ],
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // === Soft radial glow behind logo ===
                    Positioned(
                      top: size.height * 0.3,
                      child: Container(
                        width: 200 + _glowRadius.value * 4,
                        height: 200 + _glowRadius.value * 4,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Colors.white.withOpacity(0.12 * _logoOpacity.value),
                              Colors.white.withOpacity(0.04 * _logoOpacity.value),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                      ),
                    ),

                    // === Floating sparkle particles ===
                    ..._sparkles.map((s) => _buildSparkle(s, size)),

                    // === Main centered content ===
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 3),

                        // Logo with glow
                        Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Container(
                              width: 140,
                              height: 140,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(32),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(
                                      0.25 * _logoOpacity.value,
                                    ),
                                    blurRadius: 20 + _glowRadius.value,
                                    spreadRadius: _glowRadius.value * 0.3,
                                  ),
                                  BoxShadow(
                                    color: const Color(0xFF4A1DB8).withOpacity(0.5),
                                    blurRadius: 40,
                                    offset: const Offset(0, 15),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(32),
                                child: Image.asset(
                                  'assets/images/app_icon.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Splash logo silhouette (the white logo)
                        Opacity(
                          opacity: _logoOpacity.value * 0.9,
                          child: Transform.scale(
                            scale: _logoScale.value,
                            child: Image.asset(
                              'assets/images/splash_logo.png',
                              width: 80,
                              height: 80,
                              color: Colors.white.withOpacity(0.85),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Brand name
                        Transform.translate(
                          offset: Offset(0, _brandSlide.value),
                          child: Opacity(
                            opacity: _brandOpacity.value,
                            child: Text(
                              'NuroPlay',
                              style: TextStyle(
                                fontSize: 42,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 1.2,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 4),
                                  ),
                                  Shadow(
                                    color: Colors.white.withOpacity(0.3),
                                    blurRadius: 30,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        // Tagline
                        Opacity(
                          opacity: _taglineOpacity.value,
                          child: Text(
                            'Think Fast. Play Smart.',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.white.withOpacity(0.75),
                              letterSpacing: 2.5,
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),

                        // Animated loading dots
                        _AnimatedLoadingDots(
                          controller: _particleController,
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),

                    // === Top-left decorative circle ===
                    Positioned(
                      top: -40,
                      left: -40,
                      child: Opacity(
                        opacity: _logoOpacity.value * 0.3,
                        child: Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.08),
                          ),
                        ),
                      ),
                    ),

                    // === Bottom-right decorative circle ===
                    Positioned(
                      bottom: -60,
                      right: -60,
                      child: Opacity(
                        opacity: _logoOpacity.value * 0.2,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.06),
                          ),
                        ),
                      ),
                    ),

                    // === Mid-right decorative circle ===
                    Positioned(
                      top: size.height * 0.15,
                      right: -30,
                      child: Opacity(
                        opacity: _logoOpacity.value * 0.15,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSparkle(_SparkleParticle s, Size screenSize) {
    return AnimatedBuilder(
      animation: _particleController,
      builder: (context, child) {
        final t = (_particleController.value * s.speed + s.delay) % 1.0;
        final fadeIn = (t < 0.3) ? (t / 0.3) : 1.0;
        final fadeOut = (t > 0.7) ? ((1.0 - t) / 0.3) : 1.0;
        final alpha = fadeIn * fadeOut * _logoOpacity.value * 0.6;

        return Positioned(
          left: s.x * screenSize.width + sin(t * pi * 2) * 15,
          top: s.y * screenSize.height - t * 60,
          child: Opacity(
            opacity: alpha.clamp(0.0, 1.0),
            child: Container(
              width: s.size,
              height: s.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: s.size * 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SparkleParticle {
  final double x;
  final double y;
  final double size;
  final double speed;
  final double delay;

  _SparkleParticle({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.delay,
  });
}

/// Animated three-dot loading indicator
class _AnimatedLoadingDots extends StatelessWidget {
  final AnimationController controller;

  const _AnimatedLoadingDots({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final phase = (controller.value + i * 0.15) % 1.0;
            final bounce = sin(phase * pi * 2).abs();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.translate(
                offset: Offset(0, -bounce * 6),
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.4 + bounce * 0.4),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
