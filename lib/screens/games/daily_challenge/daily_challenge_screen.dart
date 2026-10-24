import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/game/game_widgets.dart';
import '../../../providers/game_provider.dart';
import '../../../models/game_models.dart';
import '../../../services/question_generator.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  late List<MathQuestion> _questions;
  int _currentIndex = 0;
  int _score = 0;
  int _correct = 0;
  int? _selectedAnswer;
  bool _showFeedback = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _questions = QuestionGenerator.generateQuestions(
      count: 10,
      difficulty: Difficulty.medium,
    );
  }

  void _onAnswer(int answer) {
    if (_isProcessing) return;

    final q = _questions[_currentIndex];
    final isCorrect = answer == q.correctAnswer;

    setState(() {
      _isProcessing = true;
      _selectedAnswer = answer;
      _showFeedback = true;
      if (isCorrect) {
        _correct++;
        _score += 15;
      }
    });

    Future.delayed(const Duration(milliseconds: 400), () async {
      if (!mounted) return;

      if (_currentIndex + 1 >= _questions.length) {
        // Complete challenge
        final provider = context.read<GameProvider>();
        await provider.completeDailyChallenge(_score);

        final result = GameResult(
          gameId: DateTime.now().millisecondsSinceEpoch.toString(),
          gameType: 'daily',
          difficulty: Difficulty.medium,
          score: _score,
          totalQuestions: _questions.length,
          correctAnswers: _correct,
          incorrectAnswers: _questions.length - _correct,
          accuracy: _correct / _questions.length,
          avgResponseTimeMs: 1500,
          bestStreakCount: _correct,
          totalTime: const Duration(seconds: 40),
          answers: [],
          questions: _questions,
          isPersonalBest: true,
          completedAt: DateTime.now(),
        );

        Navigator.of(context).pushReplacementNamed('/results', arguments: result);
      } else {
        setState(() {
          _currentIndex++;
          _selectedAnswer = null;
          _showFeedback = false;
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final q = _questions[_currentIndex];

        return Scaffold(
          backgroundColor: AppColors.primaryBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('Daily Challenge', style: AppTypography.heading4),
            actions: [
              Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.error.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${provider.dailyStreak}d Streak',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  // ─── Bonus XP Banner ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: AppColors.accentGradient,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.bolt_rounded, size: 18, color: AppColors.primaryBg),
                        const SizedBox(width: 6),
                        Text(
                          'Complete today\'s challenge to earn +50 XP and grow your streak!',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryBg,
                            fontWeight: FontWeight.w700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Progress ───
                  QuestionProgress(
                    current: _currentIndex,
                    total: _questions.length,
                  ),

                  const Spacer(),

                  // ─── Question Card ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: _showFeedback
                            ? (_selectedAnswer == q.correctAnswer ? AppColors.success : AppColors.error)
                            : AppColors.divider,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          q.questionText,
                          style: AppTypography.monoLarge.copyWith(fontSize: 40),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text('Daily Mission • ${q.operation.label}', style: AppTypography.bodySmall),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ─── Options Grid ───
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: q.options.map((opt) {
                      final isSelected = _selectedAnswer == opt;
                      final isCorrect = opt == q.correctAnswer;

                      return AnswerOptionButton(
                        label: '$opt',
                        isSelected: isSelected,
                        isCorrect: isCorrect,
                        showResult: _showFeedback,
                        onTap: () => _onAnswer(opt),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
