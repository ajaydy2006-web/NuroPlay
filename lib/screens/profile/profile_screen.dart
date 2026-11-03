import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../providers/game_provider.dart';
import '../../models/game_models.dart';
import '../../services/storage_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final profile = provider.profile;
        final title = _getTitleForRating(profile.rating);

        return Scaffold(
          backgroundColor: AppColors.primaryBg,
          body: NeonRiseBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Header ───
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Player Profile', style: AppTypography.heading2),
                        IconButton(
                          onPressed: () => _showSettingsSheet(context, provider),
                          icon: const Icon(Icons.settings_outlined, color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ─── Profile Card ───
                    _buildProfileCard(context, profile, provider, title),
                    const SizedBox(height: 20),

                    // ─── Pro Banner ───
                    _buildProBanner(context),
                    const SizedBox(height: 24),

                    // ─── Performance Stats Grid ───
                    const SectionHeader(title: 'Cognitive Stats'),
                    _buildStatsGrid(profile, provider),
                    const SizedBox(height: 24),

                    // ─── Performance Chart ───
                    const SectionHeader(title: 'Rating History'),
                    _buildRatingChart(profile),
                    const SizedBox(height: 24),

                    // ─── Achievements ───
                    SectionHeader(
                      title: 'Achievements',
                      actionLabel: '${profile.achievements.length}/${provider.achievements.length} Unlocked',
                    ),
                    _buildAchievementsList(provider),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  String _getTitleForRating(int rating) {
    if (rating >= 2000) return '🧠 Grandmaster Prodigy';
    if (rating >= 1600) return '⚡ Master Calculator';
    if (rating >= 1300) return '🎯 Sharp Analyst';
    if (rating >= 1100) return '🔢 Rapid Thinker';
    return '🌱 Brain Novice';
  }

  Widget _buildProfileCard(
    BuildContext context,
    PlayerProfile profile,
    GameProvider provider,
    String title,
  ) {
    return GameCard(
      gradient: AppColors.cardGradient,
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => _showAvatarPicker(context, provider),
                child: Stack(
                  children: [
                    AvatarCircle(
                      emoji: profile.avatarEmoji ?? '🧠',
                      size: 68,
                      borderColor: AppColors.primaryAccent,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primaryAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.edit, size: 12, color: AppColors.primaryBg),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            profile.username,
                            style: AppTypography.heading3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.secondaryText),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _showEditUsernameDialog(context, provider, profile.username),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: AppTypography.labelSmall.copyWith(color: AppColors.secondaryAccent),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Rating: ${profile.rating}',
                            style: AppTypography.monoCaption.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            'Level ${profile.level}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primaryAccent,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Level progress bar
          Row(
            children: [
              Text('XP: ${profile.xp}', style: AppTypography.bodySmall),
              const Spacer(),
              Text('Next: ${provider.xpForNextLevel} XP', style: AppTypography.bodySmall),
            ],
          ),
          const SizedBox(height: 6),
          AnimatedProgressBar(progress: provider.levelProgress, color: AppColors.primaryAccent),
        ],
      ),
    );
  }

  Widget _buildProBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/premium'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3B1E54), Color(0xFF1E1035)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondaryAccent.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.secondaryAccent.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('✨', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Unlock NuroPlay PRO', style: AppTypography.labelLarge),
                  const SizedBox(height: 2),
                  Text(
                    'Unlimited workouts, deep cognitive stats & custom themes',
                    style: AppTypography.bodySmall.copyWith(fontSize: 11),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.secondaryAccent),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(PlayerProfile profile, GameProvider provider) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.45,
      children: [
        _buildStatCard('Games Played', '${profile.totalGames}', Icons.games_rounded, AppColors.primaryAccent),
        _buildStatCard(
          'Win Rate',
          profile.totalGames > 0 ? '${(profile.winRate * 100).toInt()}%' : '0%',
          Icons.emoji_events_rounded,
          AppColors.warning,
          subtitle: '${profile.wins}W / ${profile.losses}L',
        ),
        _buildStatCard(
          'Math Accuracy',
          profile.mathAccuracy > 0 ? '${(profile.mathAccuracy * 100).toInt()}%' : '—',
          Icons.track_changes_rounded,
          AppColors.success,
        ),
        _buildStatCard(
          'Reaction Time',
          profile.avgResponseTimeMs > 0 ? '${profile.avgResponseTimeMs}ms' : '—',
          Icons.speed_rounded,
          const Color(0xFF38BDF8),
        ),
        _buildStatCard('Best Streak', '${profile.bestStreak} 🔥', Icons.local_fire_department_rounded, AppColors.error),
        _buildStatCard('Daily Streak', '${provider.dailyStreak} Days', Icons.calendar_today_rounded, const Color(0xFFE879F9)),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, {String? subtitle}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
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
          Text(value, style: AppTypography.monoMedium.copyWith(fontSize: 20, color: color)),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(subtitle, style: AppTypography.bodySmall.copyWith(fontSize: 10, color: AppColors.secondaryText)),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingChart(PlayerProfile profile) {
    // Generate recent rating curve
    final base = profile.rating - 60;
    final spots = [
      FlSpot(0, (base).toDouble()),
      FlSpot(1, (base + 20).toDouble()),
      FlSpot(2, (base + 10).toDouble()),
      FlSpot(3, (base + 35).toDouble()),
      FlSpot(4, (base + 45).toDouble()),
      FlSpot(5, (profile.rating).toDouble()),
    ];

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => const FlLine(color: AppColors.divider, strokeWidth: 0.5),
          ),
          titlesData: const FlTitlesData(
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primaryAccent,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryAccent.withOpacity(0.3),
                    AppColors.primaryAccent.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAchievementsList(GameProvider provider) {
    return Column(
      children: provider.achievements.map((ach) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: ach.isUnlocked
                  ? AppColors.primaryAccent.withOpacity(0.4)
                  : AppColors.divider,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: (ach.isUnlocked ? AppColors.primaryAccent : AppColors.secondaryText)
                      .withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(ach.icon, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(ach.title, style: AppTypography.labelMedium),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: (ach.isUnlocked ? AppColors.success : AppColors.divider)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            ach.isUnlocked ? 'UNLOCKED' : '+${ach.xpReward} XP',
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              color: ach.isUnlocked ? AppColors.success : AppColors.secondaryText,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      ach.description,
                      style: AppTypography.bodySmall.copyWith(fontSize: 11),
                    ),
                    if (!ach.isUnlocked) ...[
                      const SizedBox(height: 6),
                      AnimatedProgressBar(progress: ach.progress, height: 4),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _showAvatarPicker(BuildContext context, GameProvider provider) {
    final avatars = ['🧠', '⚡', '👑', '🔢', '🤖', '🦊', '🐯', '🦁', '🦉', '🏎️', '🚀', '🥋'];

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Choose Avatar', style: AppTypography.heading3),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemCount: avatars.length,
                itemBuilder: (ctx, idx) {
                  final em = avatars[idx];
                  return GestureDetector(
                    onTap: () {
                      provider.updateAvatar(em);
                      Navigator.of(ctx).pop();
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Center(
                        child: Text(em, style: const TextStyle(fontSize: 32)),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  void _showEditUsernameDialog(BuildContext context, GameProvider provider, String currentName) {
    final controller = TextEditingController(text: currentName);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.secondaryBg,
          title: Text('Edit Username', style: AppTypography.heading4),
          content: TextField(
            controller: controller,
            maxLength: 15,
            style: AppTypography.bodyMedium,
            decoration: const InputDecoration(hintText: 'Enter new username'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  provider.updateUsername(controller.text.trim());
                }
                Navigator.of(ctx).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showSettingsSheet(BuildContext context, GameProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Settings', style: AppTypography.heading3),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.volume_up_rounded, color: AppColors.primaryAccent),
                title: Text('Sound Effects', style: AppTypography.bodyMedium),
                trailing: Switch(
                  value: true,
                  activeColor: AppColors.primaryAccent,
                  onChanged: (val) {},
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.vibration_rounded, color: AppColors.primaryAccent),
                title: Text('Haptic Vibration', style: AppTypography.bodyMedium),
                trailing: Switch(
                  value: true,
                  activeColor: AppColors.primaryAccent,
                  onChanged: (val) {},
                ),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.restart_alt_rounded, color: AppColors.warning),
                title: Text('Reset Progress', style: AppTypography.bodyMedium.copyWith(color: AppColors.warning)),
                onTap: () async {
                  await StorageService.clearAll();
                  await provider.init();
                  Navigator.of(ctx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Progress has been reset')),
                  );
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.logout_rounded, color: AppColors.error),
                title: Text('Sign Out', style: AppTypography.bodyMedium.copyWith(color: AppColors.error)),
                onTap: () async {
                  await provider.logout();
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushNamedAndRemoveUntil('/auth', (r) => false);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
