import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/common/common_widgets.dart';
import '../../../providers/game_provider.dart';
import '../../../models/game_models.dart';

class DuelSetupScreen extends StatefulWidget {
  const DuelSetupScreen({super.key});

  @override
  State<DuelSetupScreen> createState() => _DuelSetupScreenState();
}

class _DuelSetupScreenState extends State<DuelSetupScreen> {
  int _questionCount = 10;
  bool _isSearching = false;

  void _startMatchmaking(BuildContext context) {
    setState(() => _isSearching = true);

    // Simulate matchmaking animation for 1.2 seconds
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      final provider = context.read<GameProvider>();
      provider.startDuel(questionCount: _questionCount);
      Navigator.of(context).pushReplacementNamed('/duel-game');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        final selectedDiff = provider.selectedDifficulty;

        return Scaffold(
          backgroundColor: AppColors.primaryBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text('1v1 Math Duel', style: AppTypography.heading3),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Matchup Preview Card ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.cardGradient,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        // Player
                        Column(
                          children: [
                            AvatarCircle(
                              emoji: profile.avatarEmoji ?? '🧠',
                              size: 64,
                              borderColor: AppColors.primaryAccent,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              profile.username,
                              style: AppTypography.labelMedium,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              '${profile.rating} Rating',
                              style: AppTypography.monoCaption.copyWith(color: AppColors.warning),
                            ),
                          ],
                        ),

                        // VS
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.primaryAccent.withOpacity(0.4)),
                          ),
                          child: Text(
                            'VS',
                            style: AppTypography.heading3.copyWith(
                              color: AppColors.primaryAccent,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),

                        // Opponent
                        Column(
                          children: [
                            AvatarCircle(
                              emoji: '🤖',
                              size: 64,
                              borderColor: AppColors.secondaryAccent,
                            ),
                            const SizedBox(height: 8),
                            Text('MindBot AI', style: AppTypography.labelMedium),
                            Text(
                              '${(profile.rating + 25)} Rating',
                              style: AppTypography.monoCaption.copyWith(color: AppColors.warning),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── Difficulty Selector ───
                  Text('Select Difficulty', style: AppTypography.labelLarge),
                  const SizedBox(height: 10),
                  Row(
                    children: Difficulty.values.map((d) {
                      final isSelected = d == selectedDiff;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => provider.setDifficulty(d),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? d.color.withOpacity(0.2) : AppColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? d.color : AppColors.divider,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(d.icon, color: isSelected ? d.color : AppColors.secondaryText, size: 20),
                                const SizedBox(height: 6),
                                Text(
                                  d.label,
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isSelected ? d.color : AppColors.secondaryText,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 24),

                  // ─── Number of Questions ───
                  Text('Rounds', style: AppTypography.labelLarge),
                  const SizedBox(height: 10),
                  Row(
                    children: [5, 10, 15].map((count) {
                      final isSelected = _questionCount == count;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _questionCount = count),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.primaryAccent.withOpacity(0.15)
                                  : AppColors.cardBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected ? AppColors.primaryAccent : AppColors.divider,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '$count Questions',
                                style: AppTypography.labelMedium.copyWith(
                                  color: isSelected ? AppColors.primaryAccent : AppColors.secondaryText,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const Spacer(),

                  // ─── Stakes Notice ───
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.elevatedCard,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline_rounded, size: 18, color: AppColors.warning),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Ranked match: Win +25 Elo / Loss -15 Elo. Streaks earn bonus points!',
                            style: AppTypography.bodySmall.copyWith(fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Start Match Button ───
                  MindRushButton(
                    label: _isSearching ? 'Finding Opponent...' : 'Find Match & Start Duel ⚔️',
                    isLoading: _isSearching,
                    onPressed: () => _startMatchmaking(context),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
