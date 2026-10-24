import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class CasualFeedScreen extends StatefulWidget {
  const CasualFeedScreen({super.key});

  @override
  State<CasualFeedScreen> createState() => _CasualFeedScreenState();
}

class _CasualGameData {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String iconEmoji;
  final String category;
  final Color accentColor;
  final String route;
  final String playCount;
  final double rating;
  bool isFavorite;

  _CasualGameData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.iconEmoji,
    required this.category,
    required this.accentColor,
    required this.route,
    required this.playCount,
    required this.rating,
    this.isFavorite = false,
  });
}

class _CasualFeedScreenState extends State<CasualFeedScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _activeCategory = 'All';

  late List<_CasualGameData> _games;

  @override
  void initState() {
    super.initState();
    _games = [
      _CasualGameData(
        id: 'reaction_tap',
        title: 'Reaction Tap',
        subtitle: 'Test your millisecond reflexes',
        description: 'Wait for the screen to turn GREEN and tap instantly! Measures exact human reaction speed and penalizes premature taps.',
        iconEmoji: '⚡',
        category: 'Reflex',
        accentColor: AppColors.primaryAccent,
        route: '/casual-reaction-tap',
        playCount: '142K plays',
        rating: 4.9,
      ),
      _CasualGameData(
        id: 'memory_match',
        title: 'Memory Match',
        subtitle: 'Flip cards and find pairs',
        description: 'Classic memory pair challenge. Flip over hidden brain cards and match identical symbols in the fewest moves possible.',
        iconEmoji: '🃏',
        category: 'Memory',
        accentColor: const Color(0xFF38BDF8),
        route: '/casual-memory-match',
        playCount: '98K plays',
        rating: 4.8,
      ),
      _CasualGameData(
        id: 'color_switch',
        title: 'Color Switch Stroop',
        subtitle: 'The ultimate cognitive brain teaser',
        description: 'Match the ink color vs the written text under intense time pressure! Keeps switching rules to test your brain plasticity.',
        iconEmoji: '🎨',
        category: 'Attention',
        accentColor: AppColors.warning,
        route: '/casual-color-switch',
        playCount: '120K plays',
        rating: 4.9,
      ),
      _CasualGameData(
        id: 'number_merge',
        title: 'Number Merge 2048',
        subtitle: 'Slide and combine tiles',
        description: 'Swipe to slide number tiles across the 4x4 grid. Merge matching numbers to reach 2048 and beyond with unlimited undo.',
        iconEmoji: '🔢',
        category: 'Puzzle',
        accentColor: AppColors.secondaryAccent,
        route: '/casual-number-merge',
        playCount: '210K plays',
        rating: 5.0,
      ),
      _CasualGameData(
        id: 'sliding_puzzle',
        title: 'Sliding Number Puzzle',
        subtitle: '8-puzzle tile ordering',
        description: 'Classic sliding tile rearrangement. Shift numbers 1 through 8 into proper sequential order in record time.',
        iconEmoji: '🧩',
        category: 'Logic',
        accentColor: const Color(0xFFE879F9),
        route: '/casual-sliding-puzzle',
        playCount: '75K plays',
        rating: 4.7,
      ),
      _CasualGameData(
        id: 'pattern_recall',
        title: 'Pattern Recall',
        subtitle: 'Simon-Says lighting sequences',
        description: 'Watch the hypnotic lighting pattern and reproduce it step by step as sequences grow longer with each round.',
        iconEmoji: '💡',
        category: 'Memory',
        accentColor: AppColors.success,
        route: '/casual-pattern-recall',
        playCount: '86K plays',
        rating: 4.8,
      ),
    ];
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _showHowToPlay(BuildContext context, _CasualGameData game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.secondaryBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(game.iconEmoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(game.title, style: AppTypography.heading3),
                        Text(game.category, style: AppTypography.labelSmall.copyWith(color: game.accentColor)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(game.description, style: AppTypography.bodyMedium),
              const SizedBox(height: 24),
              MindRushButton(
                label: 'Play Game Now',
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).pushNamed(game.route);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredGames = _activeCategory == 'All'
        ? _games
        : _games.where((g) => g.category == _activeCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: SafeArea(
        child: Stack(
          children: [
            // Vertical Swipeable Feed
            PageView.builder(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              onPageChanged: (idx) => setState(() => _currentPage = idx),
              itemCount: filteredGames.length,
              itemBuilder: (context, index) {
                final game = filteredGames[index];
                return _buildFeedCard(game);
              },
            ),

            // Top Header Overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primaryBg, AppColors.primaryBg.withOpacity(0.0)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                            Text('Casual Discovery', style: AppTypography.heading3),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.divider),
                          ),
                          child: Text(
                            '${_currentPage + 1}/${filteredGames.length}',
                            style: AppTypography.labelSmall.copyWith(color: AppColors.secondaryText),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Filter Pills
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: ['All', 'Reflex', 'Memory', 'Attention', 'Puzzle', 'Logic'].map((cat) {
                          final isSel = _activeCategory == cat;
                          return GestureDetector(
                            onTap: () => setState(() => _activeCategory = cat),
                            child: Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSel ? AppColors.primaryAccent : AppColors.cardBg.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: isSel ? AppColors.primaryAccent : AppColors.divider),
                              ),
                              child: Text(
                                cat,
                                style: AppTypography.labelSmall.copyWith(
                                  color: isSel ? AppColors.primaryBg : AppColors.primaryText,
                                  fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedCard(_CasualGameData game) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 100, 16, 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: game.accentColor.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: game.accentColor.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and Category
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: game.accentColor.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: game.accentColor.withOpacity(0.5)),
                ),
                child: Center(
                  child: Text(game.iconEmoji, style: const TextStyle(fontSize: 38)),
                ),
              ),
              IconButton(
                icon: Icon(
                  game.isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: game.isFavorite ? AppColors.error : AppColors.secondaryText,
                  size: 28,
                ),
                onPressed: () => setState(() => game.isFavorite = !game.isFavorite),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Category pill + rating
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: game.accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  game.category.toUpperCase(),
                  style: AppTypography.labelSmall.copyWith(
                    color: game.accentColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Row(
                children: [
                  const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                  const SizedBox(width: 4),
                  Text('${game.rating}', style: AppTypography.labelSmall.copyWith(color: AppColors.warning)),
                  const SizedBox(width: 8),
                  Text('• ${game.playCount}', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(game.title, style: AppTypography.heading1.copyWith(fontSize: 30)),
          const SizedBox(height: 4),
          Text(game.subtitle, style: AppTypography.labelMedium.copyWith(color: AppColors.secondaryAccent)),
          const SizedBox(height: 14),

          Expanded(
            child: SingleChildScrollView(
              child: Text(
                game.description,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.secondaryText, height: 1.5),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: MindRushButton(
                  label: 'Play Game Now',
                  icon: Icons.play_arrow_rounded,
                  onPressed: () => Navigator.of(context).pushNamed(game.route),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.elevatedCard,
                  padding: const EdgeInsets.all(14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.info_outline_rounded, color: AppColors.secondaryText),
                onPressed: () => _showHowToPlay(context, game),
              ),
            ],
          ),

          const SizedBox(height: 10),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.keyboard_double_arrow_down_rounded, size: 16, color: AppColors.secondaryText),
                const SizedBox(width: 4),
                Text('Swipe down for next mini-game', style: AppTypography.bodySmall.copyWith(fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
