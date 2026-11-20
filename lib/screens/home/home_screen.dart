import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../widgets/common/clay_characters.dart';
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
              bottom: false,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Top Header (NuroPlay + Bell & Settings) ───
                    _buildHeader(context, profile),
                    const SizedBox(height: 16),

                    // ─── Player Greeting (3D Brain Squircle + Good Morning Player) ───
                    _buildGreeting(profile),
                    const SizedBox(height: 18),

                    // ─── Player Summary Card (Rating, Streak, Level, XP + Progress Bar) ───
                    _buildPlayerSummary(profile, provider),
                    const SizedBox(height: 18),

                    // ─── Featured Quick Duel Banner with 3D Cute Game Controller ───
                    _buildFeaturedQuickDuelCard(context),
                    const SizedBox(height: 18),

                    // ─── Casual Games Feed Banner ───
                    _buildCasualFeedBanner(context),
                    const SizedBox(height: 22),

                    // ─── Game Categories with 4 Adorable Clay Characters ───
                    _buildGameCategoriesSection(context),
                    const SizedBox(height: 22),

                    // ─── Real-World Games Arcade Banner ───
                    _buildRealWorldArcadeBanner(context),
                    const SizedBox(height: 18),

                    // ─── B.Tech Engineering Mathematics Module ───
                    _buildEngineeringMathBanner(context),
                    const SizedBox(height: 18),

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
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── 1. Header (Brand Logo + Notifications & Settings) ───
  Widget _buildHeader(BuildContext context, PlayerProfile profile) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Left: Purple Squircle with Lightning + NuroPlay text
        Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8C61FF), Color(0xFF7341FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x337E52FF),
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('⚡', style: TextStyle(fontSize: 22, color: Colors.white)),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'NuroPlay',
              style: AppTypography.brandHero.copyWith(
                fontSize: 28,
                color: const Color(0xFF1E1842),
                fontWeight: FontWeight.w900,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),

        // Right: White Clay Action Buttons (Bell with dot + Settings)
        Row(
          children: [
            // Bell Button with Notification Dot
            _buildClayIconButton(
              icon: Icons.notifications_none_rounded,
              showDot: true,
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No new notifications')),
                );
              },
            ),
            const SizedBox(width: 10),
            // Settings Button
            _buildClayIconButton(
              icon: Icons.settings_outlined,
              showDot: false,
              onTap: () => Navigator.of(context).pushNamed('/settings'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClayIconButton({
    required IconData icon,
    required bool showDot,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white, width: 1.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x187E52FF),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.white,
              blurRadius: 4,
              offset: Offset(-1, -1),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 22, color: const Color(0xFF1E1842)),
            if (showDot)
              Positioned(
                top: 9,
                right: 9,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF5252),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── 2. Greeting Section (3D Brain Squircle + Good Morning Player) ───
  Widget _buildGreeting(PlayerProfile profile) {
    final hour = DateTime.now().hour;
    final greeting = hour < 12 ? 'Good Morning,' : hour < 17 ? 'Good Afternoon,' : 'Good Evening,';

    return Row(
      children: [
        // Pink/Lilac Clay Squircle with 3D Brain
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF3E7FF),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x147E52FF),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: const Center(
            child: Text('🧠', style: TextStyle(fontSize: 26)),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: Color(0xFF8680A6),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                profile.username,
                style: const TextStyle(
                  color: Color(0xFF1E1842),
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── 3. Player Summary Card (Stats + Progress Bar) ───
  Widget _buildPlayerSummary(PlayerProfile profile, GameProvider provider) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x187E52FF),
            blurRadius: 22,
            offset: Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white,
            blurRadius: 6,
            offset: Offset(-2, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Row of 4 stats
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSummaryStatItem(
                emoji: '⭐',
                value: '${profile.rating}',
                label: 'Rating',
              ),
              _buildVerticalDivider(),
              _buildSummaryStatItem(
                emoji: '🔥',
                value: '${provider.dailyStreak}d',
                label: 'Streak',
              ),
              _buildVerticalDivider(),
              _buildSummaryStatItem(
                emoji: '💎',
                value: '${profile.level}',
                label: 'Level',
              ),
              _buildVerticalDivider(),
              _buildSummaryStatItem(
                emoji: '⚡',
                value: '${profile.xp}',
                label: 'XP',
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Level progress bar row
          Row(
            children: [
              Text(
                'Lv.${profile.level}',
                style: const TextStyle(
                  color: Color(0xFF1E1842),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFEAF9),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: provider.levelProgress.clamp(0.05, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF7E52FF),
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x447E52FF),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Lv.${profile.level + 1}',
                style: const TextStyle(
                  color: Color(0xFF1E1842),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryStatItem({
    required String emoji,
    required String value,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(emoji, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Color(0xFF1E1842),
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF8680A6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildVerticalDivider() {
    return Container(
      width: 1,
      height: 38,
      color: const Color(0xFFEFEAF9),
    );
  }

  // ─── 4. Featured Card (Quick Duel with Cute Game Controller) ───
  Widget _buildFeaturedQuickDuelCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 14, 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF885FFF), Color(0xFF7341FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x447341FF),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Row(
            children: [
              Expanded(
                flex: 6,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // FEATURED Pill Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Text('⚡', style: TextStyle(fontSize: 11, color: Colors.white)),
                          SizedBox(width: 4),
                          Text(
                            'FEATURED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Quick Duel Title
                    const Text(
                      'Quick Duel',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Subtitle
                    Text(
                      'Challenge a bot opponent in fast-paced math!',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Buttons: Play Duel ▶ and 👥 Room
                    Row(
                      children: [
                        // Play Duel ▶ Button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/duel-setup'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33000000),
                                  blurRadius: 10,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Text(
                                  'Play Duel',
                                  style: TextStyle(
                                    color: Color(0xFF7341FF),
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.play_arrow_rounded,
                                  color: Color(0xFF7341FF),
                                  size: 18,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // 👥 Room Button
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushNamed('/room-duel'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.22),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.group_outlined, color: Colors.white, size: 16),
                                SizedBox(width: 5),
                                Text(
                                  'Room',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Right: Adorable Cute 3D Lilac Game Controller
              Expanded(
                flex: 4,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: const CuteClayControllerWidget(size: 116),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── 5. Casual Games Feed Banner ───
  Widget _buildCasualFeedBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/casual-games'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x187E52FF),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
            BoxShadow(
              color: Colors.white,
              blurRadius: 6,
              offset: Offset(-2, -2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Blue Clay Squircle with 3D Controller
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5AB1FF), Color(0xFF2C8FFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x332C8FFF),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.sports_esports_rounded, color: Colors.white, size: 30),
              ),
            ),
            const SizedBox(width: 14),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Casual Games Feed',
                    style: TextStyle(
                      color: Color(0xFF1E1842),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Swipe through Reaction Tap, 2048, Memory Match & more',
                    style: TextStyle(
                      color: Color(0xFF8680A6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Circular Lavender Clay Arrow Button →
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFF3EEFD),
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x107E52FF),
                    blurRadius: 6,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_forward_rounded,
                  color: Color(0xFF1E1842),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── 6. Game Categories with 4 Cute Clay Characters ───
  Widget _buildGameCategoriesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header (Game Categories + View All →)
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Game Categories',
              style: TextStyle(
                color: Color(0xFF1E1842),
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),
            GestureDetector(
              onTap: () => Navigator.of(context).pushNamed('/arcade'),
              child: const Text(
                'View All →',
                style: TextStyle(
                  color: Color(0xFF7E52FF),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),

        // 4 Adorable Clay Characters
        Row(
          children: [
            ClayCategoryCharacter(
              label: 'Math Duel',
              baseColor: const Color(0xFFFF5252),
              faceType: 'duel',
              onTap: () => Navigator.of(context).pushNamed('/solo-math'),
            ),
            ClayCategoryCharacter(
              label: 'Logic',
              baseColor: const Color(0xFFFFA048),
              faceType: 'logic',
              onTap: () => Navigator.of(context).pushNamed('/logic-puzzles'),
            ),
            ClayCategoryCharacter(
              label: 'Memory',
              baseColor: const Color(0xFFFFD53D),
              faceType: 'memory',
              onTap: () => Navigator.of(context).pushNamed('/memory-game'),
            ),
            ClayCategoryCharacter(
              label: 'Reaction',
              baseColor: const Color(0xFF75D826),
              faceType: 'reaction',
              onTap: () => Navigator.of(context).pushNamed('/casual-reaction-tap'),
            ),
          ],
        ),
      ],
    );
  }

  // ─── 7. Real-World Arcade Banner ───
  Widget _buildRealWorldArcadeBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/arcade'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x187E52FF),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF26DE81), Color(0xFF10AC84)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x3310AC84),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎯', style: TextStyle(fontSize: 26)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Real-World Arcade (10 Games)',
                    style: TextStyle(
                      color: Color(0xFF1E1842),
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Carrom, Paper Football, Cup Pong, Jenga & more with 2P mode!',
                    style: TextStyle(
                      color: Color(0xFF8680A6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF7E52FF)),
          ],
        ),
      ),
    );
  }

  // ─── 8. Engineering Math Banner ───
  Widget _buildEngineeringMathBanner(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pushNamed('/engineering-math'),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: const [
            BoxShadow(
              color: Color(0x187E52FF),
              blurRadius: 20,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFFFB86C), Color(0xFFFF9234)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x33FF9234),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: Text('🎓', style: TextStyle(fontSize: 24)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'B.Tech Engineering Mathematics',
                    style: TextStyle(
                      color: Color(0xFF1E1842),
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Eng. Math I, II, III • Formulas, verified solutions & practice',
                    style: TextStyle(
                      color: Color(0xFF8680A6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Color(0xFF7E52FF)),
          ],
        ),
      ),
    );
  }

  // ─── 9. Daily Challenge ───
  Widget _buildDailyChallenge(BuildContext context, GameProvider provider) {
    final challenge = provider.getTodaysChallenge();
    return GameCard(
      onTap: () => Navigator.of(context).pushNamed('/daily-challenge'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EEFD),
              borderRadius: BorderRadius.circular(16),
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
                const Text(
                  'Daily Challenge',
                  style: TextStyle(
                    color: Color(0xFF1E1842),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  challenge.isCompleted
                      ? 'Completed! +${challenge.xpReward} XP'
                      : '${challenge.totalQuestions} questions • +${challenge.xpReward} XP',
                  style: TextStyle(
                    color: challenge.isCompleted
                        ? const Color(0xFF75D826)
                        : const Color(0xFF8680A6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            challenge.isCompleted
                ? Icons.check_circle_rounded
                : Icons.play_circle_filled_rounded,
            color: challenge.isCompleted ? const Color(0xFF75D826) : const Color(0xFF7E52FF),
            size: 28,
          ),
        ],
      ),
    );
  }

  // ─── 10. Brain Workout ───
  Widget _buildBrainWorkout(BuildContext context, GameProvider provider) {
    return GameCard(
      onTap: () => Navigator.of(context).pushNamed('/workout'),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF3EEFD),
              borderRadius: BorderRadius.circular(16),
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
                const Text(
                  'Brain Workout',
                  style: TextStyle(
                    color: Color(0xFF1E1842),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  provider.workoutCompleted
                      ? 'Completed for today!'
                      : '~5 min • Math, Memory & Logic',
                  style: TextStyle(
                    color: provider.workoutCompleted
                        ? const Color(0xFF75D826)
                        : const Color(0xFF8680A6),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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
                ? const Color(0xFF75D826)
                : const Color(0xFF7E52FF),
            size: 28,
          ),
        ],
      ),
    );
  }

  // ─── 11. Recent Activity ───
  Widget _buildRecentActivity(GameProvider provider) {
    return Column(
      children: provider.recentResults.take(3).map((result) {
        final icon = result.gameType == 'duel'
            ? '⚔️'
            : result.gameType == 'memory'
                ? '🧠'
                : result.gameType == 'logic'
                    ? '🧩'
                    : '🔢';
        final typeLabel = result.gameType == 'duel'
            ? 'Quick Duel'
            : result.gameType == 'memory'
                ? 'Memory'
                : result.gameType == 'logic'
                    ? 'Logic'
                    : 'Math Practice';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white, width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x147E52FF),
                blurRadius: 14,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 22)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeLabel,
                      style: const TextStyle(
                        color: Color(0xFF1E1842),
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${(result.accuracy * 100).toInt()}% accuracy',
                      style: const TextStyle(
                        color: Color(0xFF8680A6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${result.score} pts',
                    style: const TextStyle(
                      color: Color(0xFF7E52FF),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                  if (result.isDuelWin != null)
                    Text(
                      result.isDuelWin! ? 'WIN' : 'LOSS',
                      style: TextStyle(
                        color: result.isDuelWin! ? const Color(0xFF75D826) : const Color(0xFFFF5252),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
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

  // ─── 12. Leaderboard Preview ───
  Widget _buildLeaderboardPreview(GameProvider provider) {
    final entries = provider.getLeaderboard().take(5).toList();

    return GameCard(
      child: Column(
        children: entries.map((entry) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              border: Border(
                bottom: entry.rank < 5
                    ? const BorderSide(color: Color(0xFFEFEAF9), width: 1)
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
                        : const TextStyle(
                            color: Color(0xFF8680A6),
                            fontWeight: FontWeight.w700,
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(entry.avatarEmoji ?? '👤', style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    entry.username,
                    style: TextStyle(
                      color: entry.isCurrentUser
                          ? const Color(0xFF7E52FF)
                          : const Color(0xFF1E1842),
                      fontWeight: entry.isCurrentUser ? FontWeight.w800 : FontWeight.w600,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${entry.rating}',
                  style: const TextStyle(
                    color: Color(0xFFFFA048),
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
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
