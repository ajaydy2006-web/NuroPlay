import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../providers/game_provider.dart';
import '../../models/game_models.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final entries = provider.getLeaderboard(
          type: _tabController.index == 0 ? 'global' : _tabController.index == 1 ? 'weekly' : 'friends',
        );

        final top3 = entries.take(3).toList();
        final rest = entries.skip(3).toList();
        final currentUserEntry = entries.firstWhere(
          (e) => e.isCurrentUser,
          orElse: () => LeaderboardEntry(
            rank: 99,
            username: provider.profile.username,
            avatarEmoji: provider.profile.avatarEmoji,
            rating: provider.profile.rating,
            wins: provider.profile.wins,
            isCurrentUser: true,
          ),
        );

        return Scaffold(
          backgroundColor: AppColors.primaryBg,
          body: SafeArea(
            child: Column(
              children: [
                // ─── Header ───
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Leaderboard', style: AppTypography.heading2),
                          const SizedBox(height: 2),
                          Text(
                            'Compete with math minds worldwide',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 6),
                            Text(
                              'Rank #${currentUserEntry.rank}',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ─── Tab Bar ───
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    onTap: (_) => setState(() {}),
                    indicator: BoxDecoration(
                      color: AppColors.elevatedCard,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.primaryAccent.withOpacity(0.4)),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    dividerColor: Colors.transparent,
                    labelColor: AppColors.primaryAccent,
                    unselectedLabelColor: AppColors.secondaryText,
                    labelStyle: AppTypography.labelSmall.copyWith(fontWeight: FontWeight.w700),
                    tabs: const [
                      Tab(text: 'Global'),
                      Tab(text: 'Weekly'),
                      Tab(text: 'Friends'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ─── Main Content ───
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // ─── Top 3 Podium ───
                        if (top3.length >= 3) _buildPodium(top3),
                        const SizedBox(height: 20),

                        // ─── Rest of Ranks ───
                        ...rest.map((entry) => _buildRankRow(entry)),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                ),

                // ─── Sticky Current User Banner ───
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBg,
                    border: const Border(
                      top: BorderSide(color: AppColors.primaryAccent, width: 1.5),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryAccent.withOpacity(0.15),
                        blurRadius: 16,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            '#${currentUserEntry.rank}',
                            style: AppTypography.monoSmall.copyWith(
                              fontSize: 14,
                              color: AppColors.primaryAccent,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AvatarCircle(
                        emoji: currentUserEntry.avatarEmoji ?? '🧠',
                        size: 38,
                        borderColor: AppColors.primaryAccent,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Text(
                                  currentUserEntry.username,
                                  style: AppTypography.labelMedium.copyWith(
                                    color: AppColors.primaryAccent,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryAccent.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'YOU',
                                    style: AppTypography.labelSmall.copyWith(
                                      color: AppColors.primaryAccent,
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Text(
                              '${currentUserEntry.wins} Wins',
                              style: AppTypography.bodySmall.copyWith(fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${currentUserEntry.rating}',
                            style: AppTypography.monoBody.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            'Rating',
                            style: AppTypography.bodySmall.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPodium(List<LeaderboardEntry> top3) {
    // top3[0] is 1st, top3[1] is 2nd, top3[2] is 3rd
    final first = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2nd Place (Silver)
          if (second != null)
            Expanded(
              child: _buildPodiumColumn(
                entry: second,
                height: 120,
                podiumColor: const Color(0xFF94A3B8),
                badgeText: '2nd 🥈',
                avatarBorder: const Color(0xFFCBD5E1),
              ),
            ),
          const SizedBox(width: 8),

          // 1st Place (Gold)
          Expanded(
            child: _buildPodiumColumn(
              entry: first,
              height: 150,
              podiumColor: AppColors.warning,
              badgeText: '1st 👑',
              avatarBorder: AppColors.warning,
              isFirst: true,
            ),
          ),
          const SizedBox(width: 8),

          // 3rd Place (Bronze)
          if (third != null)
            Expanded(
              child: _buildPodiumColumn(
                entry: third,
                height: 100,
                podiumColor: const Color(0xFFD97706),
                badgeText: '3rd 🥉',
                avatarBorder: const Color(0xFFF59E0B),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPodiumColumn({
    required LeaderboardEntry entry,
    required double height,
    required Color podiumColor,
    required String badgeText,
    required Color avatarBorder,
    bool isFirst = false,
  }) {
    return Column(
      children: [
        if (isFirst)
          const Text('👑', style: TextStyle(fontSize: 22)),
        AvatarCircle(
          emoji: entry.avatarEmoji ?? '🧠',
          size: isFirst ? 56 : 46,
          borderColor: avatarBorder,
        ),
        const SizedBox(height: 6),
        Text(
          entry.username,
          style: AppTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: isFirst ? 13 : 11,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        ),
        Text(
          '${entry.rating}',
          style: AppTypography.monoCaption.copyWith(
            color: podiumColor,
            fontWeight: FontWeight.w700,
            fontSize: isFirst ? 14 : 12,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                podiumColor.withOpacity(0.35),
                podiumColor.withOpacity(0.1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
            ),
            border: Border.all(color: podiumColor.withOpacity(0.4)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                badgeText,
                style: AppTypography.labelSmall.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                  color: podiumColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${entry.wins}W',
                style: AppTypography.bodySmall.copyWith(fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRankRow(LeaderboardEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppColors.primaryAccent.withOpacity(0.1)
            : AppColors.cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isCurrentUser
              ? AppColors.primaryAccent
              : AppColors.divider,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: Text(
              '#${entry.rank}',
              style: AppTypography.monoSmall.copyWith(
                fontSize: 13,
                color: entry.isCurrentUser
                    ? AppColors.primaryAccent
                    : AppColors.secondaryText,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AvatarCircle(
            emoji: entry.avatarEmoji ?? '🧠',
            size: 38,
            borderColor: entry.isCurrentUser ? AppColors.primaryAccent : AppColors.divider,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.username,
                      style: AppTypography.labelMedium.copyWith(
                        color: entry.isCurrentUser
                            ? AppColors.primaryAccent
                            : AppColors.primaryText,
                      ),
                    ),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primaryAccent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'YOU',
                          style: AppTypography.labelSmall.copyWith(
                            color: AppColors.primaryAccent,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  '${entry.wins} Wins',
                  style: AppTypography.bodySmall.copyWith(fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.rating}',
                style: AppTypography.monoBody.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                'Rating',
                style: AppTypography.bodySmall.copyWith(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
