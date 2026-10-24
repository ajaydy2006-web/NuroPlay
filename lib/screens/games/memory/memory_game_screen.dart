import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/game_provider.dart';

class MemoryGameScreen extends StatefulWidget {
  const MemoryGameScreen({super.key});

  @override
  State<MemoryGameScreen> createState() => _MemoryGameScreenState();
}

class _MemoryGameScreenState extends State<MemoryGameScreen> {
  bool _isMemorizing = true;
  Timer? _memorizeTimer;
  int _memorizeCountdown = 3;
  final List<int> _userInput = [];
  int _lives = 3;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GameProvider>();
      provider.startMemoryGame();
      _startMemorizePhase();
    });
  }

  void _startMemorizePhase() {
    final provider = context.read<GameProvider>();
    final seq = provider.currentMemorySequence;
    if (seq == null) return;

    setState(() {
      _isMemorizing = true;
      _userInput.clear();
      _memorizeCountdown = (seq.displayTimeMs / 1000).ceil();
    });

    _memorizeTimer?.cancel();
    _memorizeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_memorizeCountdown > 1) {
        setState(() => _memorizeCountdown--);
      } else {
        timer.cancel();
        setState(() => _isMemorizing = false);
      }
    });
  }

  void _onNumberTap(int num) {
    if (_isMemorizing) return;
    final provider = context.read<GameProvider>();
    final targetLength = provider.currentMemorySequence?.numbers.length ?? 0;

    if (_userInput.length < targetLength) {
      setState(() => _userInput.add(num));

      // Auto-submit when user reaches exact target sequence length
      if (_userInput.length == targetLength) {
        _checkSubmission();
      }
    }
  }

  void _onBackspace() {
    if (_userInput.isNotEmpty && !_isMemorizing) {
      setState(() => _userInput.removeLast());
    }
  }

  void _checkSubmission() {
    final provider = context.read<GameProvider>();
    final isCorrect = provider.checkMemoryAnswer(_userInput);

    if (isCorrect) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Correct! Level Up! 🌟'),
          duration: Duration(milliseconds: 700),
          backgroundColor: AppColors.success,
        ),
      );
      Future.delayed(const Duration(milliseconds: 700), () {
        if (!mounted) return;
        _startMemorizePhase();
      });
    } else {
      setState(() => _lives--);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Wrong sequence! ${_lives > 0 ? "$_lives lives left" : "Game Over!"} ❌'),
          duration: const Duration(milliseconds: 1000),
          backgroundColor: AppColors.error,
        ),
      );

      if (_lives <= 0) {
        final result = provider.finishMemoryGame();
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          Navigator.of(context).pushReplacementNamed('/results', arguments: result);
        });
      } else {
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (!mounted) return;
          _startMemorizePhase();
        });
      }
    }
  }

  @override
  void dispose() {
    _memorizeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final seq = provider.currentMemorySequence;

        if (seq == null) {
          return const Scaffold(
            backgroundColor: AppColors.primaryBg,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final target = seq.numbers;

        return Scaffold(
          backgroundColor: AppColors.primaryBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
              onPressed: () {
                provider.resetGame();
                Navigator.of(context).pop();
              },
            ),
            title: Text('Memory Sequence', style: AppTypography.heading4),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Row(
                  children: List.generate(3, (i) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        i < _lives ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: AppColors.error,
                        size: 20,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // ─── Level & Score Header ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.secondaryAccent.withOpacity(0.4)),
                        ),
                        child: Text(
                          'Level ${provider.memoryLevel}',
                          style: AppTypography.labelMedium.copyWith(color: AppColors.secondaryAccent),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Text(
                          'Score: ${provider.memoryScore} pts',
                          style: AppTypography.monoBody.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ─── Status banner ───
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _isMemorizing
                          ? AppColors.warning.withOpacity(0.15)
                          : AppColors.primaryAccent.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isMemorizing ? Icons.visibility_rounded : Icons.edit_note_rounded,
                          size: 18,
                          color: _isMemorizing ? AppColors.warning : AppColors.primaryAccent,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isMemorizing
                              ? 'Memorize the sequence! ($_memorizeCountdown s)'
                              : 'Re-enter the sequence in order',
                          style: AppTypography.labelSmall.copyWith(
                            color: _isMemorizing ? AppColors.warning : AppColors.primaryAccent,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ─── Sequence Display Box ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: _isMemorizing
                        ? Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: target.map((n) {
                              return Container(
                                width: 56,
                                height: 64,
                                decoration: BoxDecoration(
                                  gradient: AppColors.purpleGradient,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.secondaryAccent.withOpacity(0.3),
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    '$n',
                                    style: AppTypography.monoLarge.copyWith(fontSize: 28),
                                  ),
                                ),
                              );
                            }).toList(),
                          )
                        : Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 12,
                            runSpacing: 12,
                            children: List.generate(target.length, (idx) {
                              final isFilled = idx < _userInput.length;
                              return Container(
                                width: 56,
                                height: 64,
                                decoration: BoxDecoration(
                                  color: isFilled ? AppColors.elevatedCard : AppColors.primaryBg,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(
                                    color: isFilled ? AppColors.primaryAccent : AppColors.divider,
                                    width: isFilled ? 2 : 1,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    isFilled ? '${_userInput[idx]}' : '?',
                                    style: AppTypography.monoLarge.copyWith(
                                      fontSize: 28,
                                      color: isFilled ? AppColors.primaryAccent : AppColors.secondaryText,
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                  ),

                  const Spacer(),

                  // ─── Input Grid (Active during recall phase) ───
                  Opacity(
                    opacity: _isMemorizing ? 0.3 : 1.0,
                    child: IgnorePointer(
                      ignoring: _isMemorizing,
                      child: Column(
                        children: [
                          GridView.count(
                            crossAxisCount: 3,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                            childAspectRatio: 1.8,
                            children: [
                              for (int i = 1; i <= 9; i++)
                                _MemoryPadKey(label: '$i', onTap: () => _onNumberTap(i)),
                              _MemoryPadKey(
                                label: '⌫',
                                onTap: _onBackspace,
                                color: AppColors.error.withOpacity(0.2),
                                textColor: AppColors.error,
                              ),
                              _MemoryPadKey(label: '0', onTap: () => _onNumberTap(0)),
                              _MemoryPadKey(
                                label: 'Clear',
                                onTap: () => setState(() => _userInput.clear()),
                                color: AppColors.divider.withOpacity(0.4),
                                textColor: AppColors.secondaryText,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _MemoryPadKey extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? color;
  final Color? textColor;

  const _MemoryPadKey({
    required this.label,
    required this.onTap,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color ?? AppColors.elevatedCard,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.monoSmall.copyWith(
                color: textColor ?? AppColors.primaryText,
                fontWeight: FontWeight.w700,
                fontSize: label.length > 2 ? 14 : 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
