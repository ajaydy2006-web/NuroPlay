import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class ColorSwitchGame extends StatefulWidget {
  const ColorSwitchGame({super.key});

  @override
  State<ColorSwitchGame> createState() => _ColorSwitchGameState();
}

class _ColorSwitchGameState extends State<ColorSwitchGame> {
  final List<Map<String, dynamic>> _colorPalette = [
    {'name': 'RED', 'color': const Color(0xFFEF4444)},
    {'name': 'BLUE', 'color': const Color(0xFF3B82F6)},
    {'name': 'GREEN', 'color': const Color(0xFF22C55E)},
    {'name': 'YELLOW', 'color': const Color(0xFFEAB308)},
  ];

  late String _displayedWord;
  late Color _displayedColor;
  late bool _matchInkColor; // true: choose ink color; false: choose word name
  late Color _correctColor;

  int _score = 0;
  int _lives = 3;
  int _streak = 0;
  Timer? _questionTimer;
  double _timeProgress = 1.0;
  static const int _maxMs = 2500;
  final Random _random = Random();
  bool _gameOver = false;

  @override
  void initState() {
    super.initState();
    _nextRound();
  }

  void _nextRound() {
    if (_lives <= 0) {
      setState(() => _gameOver = true);
      _questionTimer?.cancel();
      return;
    }

    final wordObj = _colorPalette[_random.nextInt(_colorPalette.length)];
    final colorObj = _colorPalette[_random.nextInt(_colorPalette.length)];
    _matchInkColor = _random.nextBool();

    _displayedWord = wordObj['name'];
    _displayedColor = colorObj['color'];
    _correctColor = _matchInkColor ? _displayedColor : wordObj['color'];

    setState(() {
      _timeProgress = 1.0;
    });

    _questionTimer?.cancel();
    final startTime = DateTime.now();
    _questionTimer = Timer.periodic(const Duration(milliseconds: 30), (timer) {
      final elapsed = DateTime.now().difference(startTime).inMilliseconds;
      final remaining = (_maxMs - elapsed) / _maxMs;
      if (remaining <= 0) {
        timer.cancel();
        _onFail();
      } else {
        if (mounted) setState(() => _timeProgress = remaining);
      }
    });
  }

  void _onColorSelected(Color selected) {
    if (_gameOver) return;

    if (selected == _correctColor) {
      _streak++;
      _score += 10 + (_streak * 2);
      _nextRound();
    } else {
      _onFail();
    }
  }

  void _onFail() {
    _questionTimer?.cancel();
    setState(() {
      _lives--;
      _streak = 0;
      if (_lives <= 0) {
        _gameOver = true;
      }
    });

    if (!_gameOver) {
      _nextRound();
    }
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    super.dispose();
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
        title: Text('Color Switch Stroop', style: AppTypography.heading4),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Row(
              children: List.generate(3, (idx) {
                return Icon(
                  idx < _lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: AppColors.error,
                  size: 20,
                );
              }),
            ),
          ),
        ],
      ),
      body: NeonRiseBackground(
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Score & Streak
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
                    child: Text('Score: $_score', style: AppTypography.monoBody.copyWith(color: AppColors.warning)),
                  ),
                  if (_streak > 2)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text('🔥 x${_streak ~/ 3 + 1} Multiplier', style: AppTypography.labelSmall.copyWith(color: AppColors.error)),
                    ),
                ],
              ),

              const SizedBox(height: 14),

              // Countdown Bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: _timeProgress,
                  backgroundColor: AppColors.divider,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _timeProgress < 0.3 ? AppColors.error : AppColors.primaryAccent,
                  ),
                  minHeight: 6,
                ),
              ),

              const SizedBox(height: 24),

              // Rule Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: _matchInkColor
                      ? AppColors.secondaryAccent.withOpacity(0.15)
                      : AppColors.primaryAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _matchInkColor ? AppColors.secondaryAccent : AppColors.primaryAccent,
                  ),
                ),
                child: Text(
                  _matchInkColor ? '👉 TAP THE INK COLOR!' : '👉 TAP THE WRITTEN WORD!',
                  style: AppTypography.labelMedium.copyWith(
                    color: _matchInkColor ? AppColors.secondaryAccent : AppColors.primaryAccent,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              const Spacer(),

              // Word Display Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider, width: 2),
                ),
                child: Center(
                  child: Text(
                    _displayedWord,
                    style: AppTypography.heading1.copyWith(
                      color: _displayedColor,
                      fontSize: 48,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // 4 Color Tap Buttons
              if (!_gameOver)
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 2.0,
                  children: _colorPalette.map((item) {
                    final color = item['color'] as Color;
                    final name = item['name'] as String;

                    return GestureDetector(
                      onTap: () => _onColorSelected(color),
                      child: Container(
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: color, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            name,
                            style: AppTypography.heading4.copyWith(color: color),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )
              else
                Column(
                  children: [
                    Text('Game Over!', style: AppTypography.heading2.copyWith(color: AppColors.error)),
                    const SizedBox(height: 6),
                    Text('Final Score: $_score pts', style: AppTypography.monoMedium),
                    const SizedBox(height: 16),
                    MindRushButton(
                      label: 'Try Again',
                      icon: Icons.replay_rounded,
                      onPressed: () {
                        setState(() {
                          _score = 0;
                          _lives = 3;
                          _streak = 0;
                          _gameOver = false;
                        });
                        _nextRound();
                      },
                    ),
                  ],
                ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      ),
    );
  }
}
