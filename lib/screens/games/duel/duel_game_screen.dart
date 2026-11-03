import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/game/game_widgets.dart';
import '../../../widgets/common/common_widgets.dart';
import '../../../providers/game_provider.dart';
import '../../../models/game_models.dart';

class DuelGameScreen extends StatefulWidget {
  const DuelGameScreen({super.key});

  @override
  State<DuelGameScreen> createState() => _DuelGameScreenState();
}

class _DuelGameScreenState extends State<DuelGameScreen> {
  Timer? _questionTimer;
  int _secondsLeft = 10;
  static const int _maxQuestionSeconds = 10;

  int? _selectedAnswer;
  bool _showFeedback = false;
  bool _isProcessingAnswer = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _questionTimer?.cancel();
    setState(() => _secondsLeft = _maxQuestionSeconds);

    _questionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft > 0) {
        setState(() => _secondsLeft--);
      } else {
        // Time ran out for this question
        timer.cancel();
        _handleAnswerSelection(-999999); // Auto-fail
      }
    });
  }

  void _handleAnswerSelection(int answer) {
    if (_isProcessingAnswer) return;
    _questionTimer?.cancel();

    setState(() {
      _isProcessingAnswer = true;
      _selectedAnswer = answer;
      _showFeedback = true;
    });

    final provider = context.read<GameProvider>();
    final result = provider.submitAnswer(answer);

    // Short delay to show green/red visual response
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      if (result != null) {
        // Game finished!
        Navigator.of(context).pushReplacementNamed('/results', arguments: result);
      } else {
        // Next question
        setState(() {
          _selectedAnswer = null;
          _showFeedback = false;
          _isProcessingAnswer = false;
        });
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _questionTimer?.cancel();
    super.dispose();
  }

  void _confirmQuit() {
    _questionTimer?.cancel();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.secondaryBg,
        title: Text('Forfeit Match?', style: AppTypography.heading4),
        content: Text(
          'Leaving now will count as a loss and deduct rating points.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _startTimer();
            },
            child: const Text('Keep Playing'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<GameProvider>().resetGame();
              Navigator.of(context).pop();
            },
            child: const Text('Forfeit'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final currentQ = provider.currentQuestion;

        if (currentQ == null) {
          return const Scaffold(
            backgroundColor: AppColors.primaryBg,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final streak = provider.currentStreakCount;

        return WillPopScope(
          onWillPop: () async {
            _confirmQuit();
            return false;
          },
          child: Scaffold(
            backgroundColor: AppColors.primaryBg,
            body: NeonRiseBackground(
              child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  children: [
                    // ─── Header: Score Bar & Exit ───
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: AppColors.secondaryText),
                          onPressed: _confirmQuit,
                        ),
                        Expanded(
                          child: DuelScoreBar(
                            playerName: provider.profile.username,
                            playerScore: provider.score,
                            opponentName: provider.botName,
                            opponentScore: provider.botScore,
                            playerEmoji: provider.profile.avatarEmoji ?? '🧠',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ─── Progress & Question Timer ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        QuestionProgress(
                          current: provider.currentQuestionIndex,
                          total: provider.currentQuestions.length,
                        ),
                        GameTimer(
                          seconds: _secondsLeft,
                          maxSeconds: _maxQuestionSeconds,
                          color: _secondsLeft <= 3 ? AppColors.error : AppColors.primaryAccent,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // ─── Streak / Multiplier Pill ───
                    if (streak > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.error.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '$streak STREAK! (+${(streak - 1) * 5} bonus)',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      const SizedBox(height: 32),

                    const Spacer(),

                    // ─── Equation Card ───
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: _showFeedback
                              ? (_selectedAnswer == currentQ.correctAnswer
                                  ? AppColors.success
                                  : AppColors.error)
                              : AppColors.divider,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            currentQ.questionText,
                            style: AppTypography.monoLarge.copyWith(fontSize: 42),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            currentQ.operation.label,
                            style: AppTypography.labelSmall.copyWith(color: AppColors.secondaryText),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // ─── 4 Multiple Choice Options ───
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 1.8,
                      children: currentQ.options.map((option) {
                        final isSelected = _selectedAnswer == option;
                        final isCorrect = option == currentQ.correctAnswer;

                        return AnswerOptionButton(
                          label: '$option',
                          isSelected: isSelected,
                          isCorrect: isCorrect,
                          showResult: _showFeedback,
                          onTap: () => _handleAnswerSelection(option),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            ),
          ),
        );
      },
    );
  }
}
