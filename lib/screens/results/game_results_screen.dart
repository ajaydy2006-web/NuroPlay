import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:confetti/confetti.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../providers/game_provider.dart';
import '../../models/game_models.dart';

class GameResultsScreen extends StatefulWidget {
  final GameResult? result;

  const GameResultsScreen({super.key, this.result});

  @override
  State<GameResultsScreen> createState() => _GameResultsScreenState();
}

class _GameResultsScreenState extends State<GameResultsScreen> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final res = widget.result ?? ModalRoute.of(context)?.settings.arguments as GameResult?;
      if (res != null && (res.isDuelWin == true || res.isPersonalBest || res.accuracy >= 0.8)) {
        _confettiController.play();
      }
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final GameResult result = widget.result ??
        (ModalRoute.of(context)?.settings.arguments as GameResult?) ??
        GameResult(
          gameId: 'fallback',
          gameType: 'duel',
          difficulty: Difficulty.medium,
          score: 120,
          totalQuestions: 10,
          correctAnswers: 8,
          incorrectAnswers: 2,
          accuracy: 0.8,
          avgResponseTimeMs: 1420,
          bestStreakCount: 5,
          totalTime: const Duration(seconds: 18),
          answers: [],
          questions: [],
          isPersonalBest: true,
          completedAt: DateTime.now(),
          ratingChange: 25,
          isDuelWin: true,
          opponentScore: 95,
          opponentName: 'MindBot',
        );

    final isDuel = result.gameType == 'duel';
    final isWin = isDuel ? (result.isDuelWin ?? false) : result.accuracy >= 0.7;

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 12),

                  // ─── Result Banner ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                    decoration: BoxDecoration(
                      gradient: isWin
                          ? LinearGradient(
                              colors: [
                                AppColors.success.withOpacity(0.2),
                                AppColors.cardBg,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : LinearGradient(
                              colors: [
                                AppColors.error.withOpacity(0.15),
                                AppColors.cardBg,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: isWin
                            ? AppColors.success.withOpacity(0.5)
                            : AppColors.error.withOpacity(0.4),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          isDuel
                              ? (isWin ? '🏆 VICTORY!' : '⚡ DEFEAT')
                              : (result.isPersonalBest ? '⭐ NEW RECORD!' : '🎯 SESSION COMPLETE'),
                          style: AppTypography.heading2.copyWith(
                            color: isWin ? AppColors.success : AppColors.error,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isDuel
                              ? (isWin ? 'You crushed the match!' : 'Good try! Keep pushing forward.')
                              : 'Here is your mental performance summary',
                          style: AppTypography.bodySmall,
                        ),
                        const SizedBox(height: 20),

                        // Large Score Display
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${result.score}',
                              style: AppTypography.monoLarge.copyWith(
                                color: AppColors.primaryAccent,
                                fontSize: 64,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'PTS',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.primaryAccent.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),

                        // Duel Opponent Comparison
                        if (isDuel && result.opponentScore != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.elevatedCard,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'You: ${result.score}',
                                  style: AppTypography.monoBody.copyWith(
                                    color: AppColors.primaryAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Text('vs', style: AppTypography.bodySmall),
                                const SizedBox(width: 12),
                                Text(
                                  '${result.opponentName ?? "Bot"}: ${result.opponentScore}',
                                  style: AppTypography.monoBody.copyWith(
                                    color: AppColors.secondaryAccent,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],

                        // Rating Change Badge
                        if (result.ratingChange != null && result.ratingChange != 0) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: (result.ratingChange! > 0 ? AppColors.success : AppColors.error)
                                  .withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: (result.ratingChange! > 0 ? AppColors.success : AppColors.error)
                                    .withOpacity(0.4),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  result.ratingChange! > 0
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  size: 16,
                                  color: result.ratingChange! > 0
                                      ? AppColors.success
                                      : AppColors.error,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${result.ratingChange! > 0 ? "+" : ""}${result.ratingChange} Rating points',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: result.ratingChange! > 0
                                        ? AppColors.success
                                        : AppColors.error,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ─── Key Metrics Grid ───
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.5,
                    children: [
                      _buildMetricCard(
                        'Accuracy',
                        '${(result.accuracy * 100).toInt()}%',
                        Icons.track_changes_rounded,
                        AppColors.primaryAccent,
                        '${result.correctAnswers}/${result.totalQuestions} correct',
                      ),
                      _buildMetricCard(
                        'Speed',
                        result.avgResponseTimeMs > 0
                            ? '${(result.avgResponseTimeMs / 1000).toStringAsFixed(1)}s'
                            : '—',
                        Icons.speed_rounded,
                        AppColors.warning,
                        'Avg answer time',
                      ),
                      _buildMetricCard(
                        'Best Streak',
                        '${result.bestStreakCount} 🔥',
                        Icons.local_fire_department_rounded,
                        AppColors.error,
                        'Consecutive correct',
                      ),
                      _buildMetricCard(
                        'XP Earned',
                        '+${10 + (result.correctAnswers * 2) + (result.isPersonalBest ? 20 : 0)} XP',
                        Icons.bolt_rounded,
                        AppColors.secondaryAccent,
                        'Level progression',
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // ─── Question Breakdown (if available) ───
                  if (result.questions.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Review Questions', style: AppTypography.heading4),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(result.questions.length, (idx) {
                      final q = result.questions[idx];
                      final ans = idx < result.answers.length ? result.answers[idx] : null;
                      final isCorrect = ans?.isCorrect ?? false;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isCorrect
                                ? AppColors.success.withOpacity(0.3)
                                : AppColors.error.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                              color: isCorrect ? AppColors.success : AppColors.error,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                '${q.operand1} ${q.operation.symbol} ${q.operand2} = ${q.correctAnswer}',
                                style: AppTypography.monoBody,
                              ),
                            ),
                            if (ans != null && !isCorrect)
                              Text(
                                'You: ${ans.selectedAnswer ?? "—"}',
                                style: AppTypography.monoCaption.copyWith(color: AppColors.error),
                              ),
                          ],
                        ),
                      );
                    }),
                    const SizedBox(height: 20),
                  ],

                  // ─── Actions ───
                  Row(
                    children: [
                      Expanded(
                        child: MindRushButton(
                          label: 'Play Again',
                          icon: Icons.replay_rounded,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MindRushButton(
                          label: 'Home',
                          icon: Icons.home_rounded,
                          isOutlined: true,
                          onPressed: () {
                            context.read<GameProvider>().setBottomNavIndex(0);
                            Navigator.of(context).pushNamedAndRemoveUntil('/main', (route) => false);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Result copied to clipboard! 📋')),
                      );
                    },
                    icon: const Icon(Icons.share_rounded, size: 18, color: AppColors.secondaryText),
                    label: Text(
                      'Share Results',
                      style: AppTypography.labelSmall.copyWith(color: AppColors.secondaryText),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),

          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                AppColors.primaryAccent,
                AppColors.secondaryAccent,
                AppColors.warning,
                AppColors.success,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(title, style: AppTypography.labelSmall.copyWith(fontSize: 11)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTypography.monoMedium.copyWith(fontSize: 22, color: color),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.secondaryText),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
