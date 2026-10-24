import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class PatternRecallGame extends StatefulWidget {
  const PatternRecallGame({super.key});

  @override
  State<PatternRecallGame> createState() => _PatternRecallGameState();
}

class _PatternRecallGameState extends State<PatternRecallGame> {
  final List<Color> _baseColors = [
    const Color(0xFF16A34A), // Green
    const Color(0xFFDC2626), // Red
    const Color(0xFFEAB308), // Yellow
    const Color(0xFF2563EB), // Blue
  ];

  final List<Color> _activeColors = [
    const Color(0xFF4ADE80), // Bright Green
    const Color(0xFFF87171), // Bright Red
    const Color(0xFFFDE047), // Bright Yellow
    const Color(0xFF60A5FA), // Bright Blue
  ];

  final List<int> _sequence = [];
  final List<int> _playerSequence = [];
  int? _flashingTile;
  bool _isDemonstrating = false;
  int _score = 0;
  int _highScore = 0;
  bool _isGameOver = false;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _startNewGame();
  }

  void _startNewGame() {
    setState(() {
      _sequence.clear();
      _playerSequence.clear();
      _score = 0;
      _isGameOver = false;
      _isDemonstrating = true;
    });
    _nextRound();
  }

  void _nextRound() {
    _sequence.add(_random.nextInt(4));
    _playerSequence.clear();
    _playSequence();
  }

  Future<void> _playSequence() async {
    setState(() => _isDemonstrating = true);
    await Future.delayed(const Duration(milliseconds: 600));

    for (int i = 0; i < _sequence.length; i++) {
      if (!mounted) return;
      final tile = _sequence[i];
      setState(() => _flashingTile = tile);
      await Future.delayed(const Duration(milliseconds: 450));
      if (!mounted) return;
      setState(() => _flashingTile = null);
      await Future.delayed(const Duration(milliseconds: 250));
    }

    if (mounted) {
      setState(() => _isDemonstrating = false);
    }
  }

  void _onTileTapped(int tile) {
    if (_isDemonstrating || _isGameOver) return;

    setState(() => _flashingTile = tile);
    Future.delayed(const Duration(milliseconds: 180), () {
      if (mounted) setState(() => _flashingTile = null);
    });

    _playerSequence.add(tile);
    final currentIndex = _playerSequence.length - 1;

    if (_playerSequence[currentIndex] != _sequence[currentIndex]) {
      // Wrong move!
      setState(() {
        _isGameOver = true;
      });
      return;
    }

    // Completed round!
    if (_playerSequence.length == _sequence.length) {
      _score++;
      if (_score > _highScore) _highScore = _score;
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) _nextRound();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Pattern Recall', style: AppTypography.heading4),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Score & Level
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text('Round: ${_sequence.length}', style: AppTypography.labelMedium.copyWith(color: AppColors.primaryAccent)),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text('Best: $_highScore', style: AppTypography.monoBody.copyWith(color: AppColors.warning)),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: _isDemonstrating ? AppColors.warning.withOpacity(0.15) : AppColors.success.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _isDemonstrating ? '👀 Watch the lighting pattern...' : '👉 Your turn! Tap the pattern in order',
                  style: AppTypography.labelSmall.copyWith(
                    color: _isDemonstrating ? AppColors.warning : AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const Spacer(),

              // 4 Quadrants
              Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.divider, width: 3),
                    ),
                    child: GridView.count(
                      crossAxisCount: 2,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      children: List.generate(4, (idx) {
                        final isLit = _flashingTile == idx;
                        final color = isLit ? _activeColors[idx] : _baseColors[idx];

                        return GestureDetector(
                          onTap: () => _onTileTapped(idx),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(idx == 0 ? 80 : 16),
                                topRight: Radius.circular(idx == 1 ? 80 : 16),
                                bottomLeft: Radius.circular(idx == 2 ? 80 : 16),
                                bottomRight: Radius.circular(idx == 3 ? 80 : 16),
                              ),
                              boxShadow: [
                                if (isLit)
                                  BoxShadow(
                                    color: color.withOpacity(0.8),
                                    blurRadius: 24,
                                    spreadRadius: 4,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              if (_isGameOver) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.error),
                  ),
                  child: Column(
                    children: [
                      Text('Pattern Failed! Final Score: $_score', style: AppTypography.heading4.copyWith(color: AppColors.error)),
                      const SizedBox(height: 8),
                      MindRushButton(
                        label: 'Try Again',
                        icon: Icons.replay_rounded,
                        onPressed: _startNewGame,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
