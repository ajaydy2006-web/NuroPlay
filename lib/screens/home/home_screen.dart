import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../providers/game_provider.dart';
import '../../models/game_models.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        return Scaffold(
          backgroundColor: AppColors.primaryBg,
          body: NuroPlayBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Header ───
                  _buildHeader(context, profile),
                  const SizedBox(height: 20),

                  // ─── Player Summary ───
                  _buildPlayerSummary(profile, provider),
                  const SizedBox(height: 20),

                  // ─── Quick Duel & Friend Room Card ───
                  _buildQuickDuelCard(context),
                  const SizedBox(height: 16),

                  // ─── Casual Games Discovery Banner ───
                  _buildCasualFeedBanner(context),
                  const SizedBox(height: 20),

                  // ─── Game Categories ───
                  const SectionHeader(title: 'Game Categories'),
                  _buildGameCategories(context),
                  const SizedBox(height: 20),

                  // ─── B.Tech Engineering Mathematics Module ───
                  _buildEngineeringMathBanner(context),
                  const SizedBox(height: 20),

                  // ─── Daily Challenge ───
                  _buildDailyChallenge(context, provider),
                  const SizedBox(height: 16),

                  // ─── Brain Workout ───
                  _buildBrainWorkout(context, provider),
                  const SizedBox(height: 20),

                  // ─── Recent Activity ───
                  if (provider.recentResults.isNotEmpty) ...[
                    const SectionHeader(title: 'Recent Activity'),
                    _buildRecentActivity(provider),
                    const SizedBox(height: 20),
                  ],

                  // ─── Weekly Leaderboard Preview ───
                  SectionHeader(
                    title: 'Leaderboard',
                    actionLabel: 'View All',
                    onAction: () => provider.setBottomNavIndex(2),
                  ),
                  _buildLeaderboardPreview(provider),

                  const SizedBox(height: 80), // Space for bottom nav
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

  Widget _buildHeader(BuildContext context, PlayerProfile profile) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning' : hour < 17 ? 'Good Afternoon' : 'Good Evening';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    gradient: AppColors.vibrantMixGradient,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryAccent.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text('⚡', style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(width: 10),
                Text(
                  'NuroPlay',
                  style: AppTypography.brandHero.copyWith(
                    fontSize: 26,
                    color: AppColors.creamText,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No new notifications')),
                    );
                  },
                  icon: const Icon(Icons.notifications_outlined, color: AppColors.secondaryText),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pushNamed('/settings'),
                  icon: const Icon(Icons.settings_outlined, color: AppColors.secondaryText),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            AvatarCircle(
              emoji: profile.avatarEmoji ?? '🧠',
              size: 46,
              borderColor: AppColors.primaryAccent,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$greeting,',
                    style: AppTypography.bodySmall,
                  ),
                  Text(
                    profile.username,
                    style: AppTypography.heading3.copyWith(fontSize: 18),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerSummary(PlayerProfile profile, GameProvider provider) {
    return GameCard(
      gradient: AppColors.cardGradient,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              StatChip(
                label: 'Rating',
                value: '${profile.rating}',
                icon: Icons.star_rounded,
                valueColor: AppColors.warning,
              ),
              StatChip(
                label: 'Streak',
                value: '${provider.dailyStreak}d',
                icon: Icons.local_fire_department_rounded,
                valueColor: AppColors.error,
              ),
              StatChip(
                label: 'Level',
                value: '${profile.level}',
                icon: Icons.diamond_rounded,
                valueColor: AppColors.secondaryAccent,
              ),
              StatChip(
                label: 'XP',
                value: '${profile.xp}',
                icon: Icons.bolt_rounded,
                valueColor: AppColors.primaryAccent,
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Level progress bar
          Row(
            children: [
              Text('Lv.${profile.level}', style: AppTypography.labelSmall),
              const SizedBox(width: 8),
              Expanded(
                child: AnimatedProgressBar(
                  progress: provider.levelProgress,
                  color: AppColors.secondaryAccent,
                ),
              ),
              const SizedBox(width: 8),
              Text('Lv.${profile.level + 1}', style: AppTypography.labelSmall),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickDuelCard(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/duel-setup'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1E3A5F), Color(0xFF0F2847)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.primaryAccent.withOpacity(0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryAccent.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '⚡ FEATURED',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryAccent,
                        fontSize: 10,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('Quick Duel', style: AppTypography.heading2),
                  const SizedBox(height: 4),
                  Text(
                    'Challenge a bot opponent in fast-paced math!',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.secondaryText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/duel-setup'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            decoration: BoxDecoration(
                              gradient: AppColors.accentGradient,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primaryAccent.withOpacity(0.3),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Quick Duel →',
                                style: AppTypography.buttonSmall.copyWith(
                                  color: AppColors.primaryBg,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pushNamed('/room-duel'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.elevatedCard,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Row(
                            children: [
                              const Text('🔑', style: TextStyle(fontSize: 14)),
                              const SizedBox(width: 4),
                              Text('Room', style: AppTypography.labelSmall.copyWith(color: AppColors.primaryText)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Text('⚔️', style: TextStyle(fontSize: 40)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCasualFeedBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/casual-games'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2C1654), Color(0xFF16233B)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.secondaryAccent.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.secondaryAccent.withOpacity(0.15),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.secondaryAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Text('🎮', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'MINI-GAMES FEED',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.secondaryAccent,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('• 6+ Playable Games', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Casual Games Feed', style: AppTypography.heading3.copyWith(fontSize: 18)),
                  Text(
                    'Swipe through Reaction Tap, 2048, Memory Match & more',
                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.secondaryAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildRealWorldArcadeBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/arcade'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF064E3B), Color(0xFF0F172A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.primaryAccent.withOpacity(0.5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryAccent.withOpacity(0.18),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryAccent.withOpacity(0.4)),
              ),
              child: const Center(
                child: Text('🎯', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ARCADE EXPANSION',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryAccent,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text('• 10 Playable Games', style: AppTypography.bodySmall.copyWith(fontSize: 10)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text('Real-World Games Arcade', style: AppTypography.heading3.copyWith(fontSize: 18)),
                  Text(
                    'Carrom, Paper Football, Cup Pong, Jenga, Reflex Duel & more',
                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppColors.primaryAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildEngineeringMathBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/engineering-math'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF38BDF8).withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: const Color(0xFF38BDF8).withOpacity(0.15),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text('🎓', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('B.Tech Engineering Mathematics', style: AppTypography.labelLarge),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text('JNTUA / R23', style: AppTypography.labelSmall.copyWith(fontSize: 9, color: AppColors.success)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Eng. Math I, II, III • Formulas, verified solutions & practice',
                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Color(0xFF38BDF8)),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCategories(BuildContext context) {
    final categories = [
      _GameCategory('🔢', 'Math', AppColors.primaryAccent, '/solo-math'),
      _GameCategory('🧠', 'Memory', AppColors.secondaryAccent, '/memory-game'),
      _GameCategory('🧩', 'Puzzles', AppColors.success, '/puzzles'),
      _GameCategory('⚡', 'Anzan', AppColors.warning, '/flash-anzan'),
    ];

    return Row(
      children: categories.map((cat) {
        return Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).pushNamed(cat.route),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.divider),
              ),
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: cat.color.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(cat.emoji, style: const TextStyle(fontSize: 22)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat.label,
                    style: AppTypography.labelSmall.copyWith(color: AppColors.primaryText),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDailyChallenge(BuildContext context, GameProvider provider) {
    final challenge = provider.getTodaysChallenge();
    return GameCard(
      onTap: () => Navigator.of(context).pushNamed('/daily-challenge'),
      borderColor: challenge.isCompleted
          ? AppColors.success.withOpacity(0.5)
          : AppColors.warning.withOpacity(0.5),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (challenge.isCompleted ? AppColors.success : AppColors.warning)
                  .withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                challenge.isCompleted ? '✅' : '📅',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Daily Challenge', style: AppTypography.labelLarge),
                Text(
                  challenge.isCompleted
                      ? 'Completed! +${challenge.xpReward} XP'
                      : '${challenge.totalQuestions} questions • +${challenge.xpReward} XP',
                  style: AppTypography.bodySmall.copyWith(
                    color: challenge.isCompleted
                        ? AppColors.success
                        : AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            challenge.isCompleted
                ? Icons.check_circle_rounded
                : Icons.play_circle_filled_rounded,
            color: challenge.isCompleted ? AppColors.success : AppColors.warning,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildBrainWorkout(BuildContext context, GameProvider provider) {
    return GameCard(
      onTap: () => Navigator.of(context).pushNamed('/workout'),
      borderColor: provider.workoutCompleted
          ? AppColors.success.withOpacity(0.5)
          : AppColors.secondaryAccent.withOpacity(0.5),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.secondaryAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                provider.workoutCompleted ? '💪' : '🏋️',
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Brain Workout', style: AppTypography.labelLarge),
                Text(
                  provider.workoutCompleted
                      ? 'Completed for today!'
                      : '~5 min • Math, Memory & Logic',
                  style: AppTypography.bodySmall.copyWith(
                    color: provider.workoutCompleted
                        ? AppColors.success
                        : AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            provider.workoutCompleted
                ? Icons.check_circle_rounded
                : Icons.play_circle_filled_rounded,
            color: provider.workoutCompleted
                ? AppColors.success
                : AppColors.secondaryAccent,
            size: 28,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(GameProvider provider) {
    return Column(
      children: provider.recentResults.take(3).map((result) {
        final icon = result.gameType == 'duel' ? '⚔️'
            : result.gameType == 'memory' ? '🧠'
            : result.gameType == 'logic' ? '🧩'
            : '🔢';
        final typeLabel = result.gameType == 'duel' ? 'Quick Duel'
            : result.gameType == 'memory' ? 'Memory'
            : result.gameType == 'logic' ? 'Logic'
            : 'Math Practice';

        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.divider, width: 0.5),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(typeLabel, style: AppTypography.labelMedium),
                    Text(
                      '${(result.accuracy * 100).toInt()}% accuracy',
                      style: AppTypography.bodySmall,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${result.score} pts',
                    style: AppTypography.monoCaption.copyWith(
                      color: AppColors.primaryAccent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (result.isDuelWin != null)
                    Text(
                      result.isDuelWin! ? 'WIN' : 'LOSS',
                      style: AppTypography.labelSmall.copyWith(
                        color: result.isDuelWin! ? AppColors.success : AppColors.error,
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildLeaderboardPreview(GameProvider provider) {
    final entries = provider.getLeaderboard().take(5).toList();

    return GameCard(
      child: Column(
        children: entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: entry.rank < 5
                    ? const BorderSide(color: AppColors.divider, width: 0.5)
                    : BorderSide.none,
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 28,
                  child: Text(
                    entry.rank <= 3
                        ? ['🥇', '🥈', '🥉'][entry.rank - 1]
                        : '#${entry.rank}',
                    style: entry.rank <= 3
                        ? const TextStyle(fontSize: 18)
                        : AppTypography.labelSmall,
                  ),
                ),
                const SizedBox(width: 8),
                Text(entry.avatarEmoji ?? '👤', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.username,
                    style: AppTypography.labelMedium.copyWith(
                      color: entry.isCurrentUser
                          ? AppColors.primaryAccent
                          : AppColors.primaryText,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${entry.rating}',
                  style: AppTypography.monoCaption.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _GameCategory {
  final String emoji;
  final String label;
  final Color color;
  final String route;

  const _GameCategory(this.emoji, this.label, this.color, this.route);
}
