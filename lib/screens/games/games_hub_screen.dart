import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../providers/game_provider.dart';
import '../../models/game_models.dart';
import '../../services/storage_service.dart';

class GamesHubScreen extends StatefulWidget {
  const GamesHubScreen({super.key});

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen> {
  String _selectedCategory = 'all';

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final currentDiff = provider.selectedDifficulty;

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Game Arena', style: AppTypography.heading2),
                          const SizedBox(height: 2),
                          Text(
                            'Train your brain with quick competitive games',
                            style: AppTypography.bodySmall,
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.elevatedCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.bolt_rounded, size: 16, color: AppColors.primaryAccent),
                            const SizedBox(width: 4),
                            Text(
                              '${provider.profile.xp} XP',
                              style: AppTypography.labelSmall.copyWith(color: AppColors.primaryAccent),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // ─── Difficulty Selector ───
                  Text('Difficulty Level', style: AppTypography.labelMedium),
                  const SizedBox(height: 10),
                  Row(
                    children: Difficulty.values.map((d) {
                      final isSelected = d == currentDiff;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => provider.setDifficulty(d),
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? d.color.withOpacity(0.2)
                                  : AppColors.cardBg,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected ? d.color : AppColors.divider,
                                width: isSelected ? 1.5 : 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                Icon(
                                  d.icon,
                                  size: 18,
                                  color: isSelected ? d.color : AppColors.secondaryText,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  d.label,
                                  style: AppTypography.labelSmall.copyWith(
                                    fontSize: 11,
                                    color: isSelected ? d.color : AppColors.secondaryText,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // ─── Filter Categories ───
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('All Games', 'all'),
                          _buildFilterChip('🎯 Real-World (10)', 'real_world'),
                          _buildFilterChip('Math Duels', 'math'),
                          _buildFilterChip('Memory', 'memory'),
                          _buildFilterChip('Reflex & Speed', 'reflex'),
                          _buildFilterChip('Logic & Puzzles', 'logic'),
                        ],
                      ),
                    ),
                  const SizedBox(height: 20),

                  // ─── Games List ───
                  ..._buildFilteredGames(context, provider),

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

  Widget _buildFilterChip(String label, String categoryId) {
    final isSelected = _selectedCategory == categoryId;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = categoryId),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : AppColors.elevatedCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.divider,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: isSelected ? AppColors.primaryBg : AppColors.secondaryText,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFilteredGames(BuildContext context, GameProvider provider) {
    final games = <_GameItem>[
      _GameItem(
        id: 'duel',
        category: 'math',
        title: 'Math Duel 1v1',
        subtitle: 'Real-time mental math battle against AI or players',
        iconEmoji: '⚔️',
        accentColor: AppColors.primaryAccent,
        route: '/duel-setup',
        tag: 'COMPETITIVE',
        personalBest: StorageService.getPersonalBest('duel'),
        roundsLabel: '10 questions',
      ),
      _GameItem(
        id: 'solo_math',
        category: 'math',
        title: 'Speed Math Sprint',
        subtitle: 'Rapid arithmetic test. Solve equations before time expires!',
        iconEmoji: '🔢',
        accentColor: const Color(0xFF38BDF8),
        route: '/solo-math',
        tag: 'RAPID FIRE',
        personalBest: StorageService.getPersonalBest('solo_math'),
        roundsLabel: '15 questions',
      ),
      _GameItem(
        id: 'memory',
        category: 'memory',
        title: 'Memory Sequence',
        subtitle: 'Memorize number sequences with increasing length and speed',
        iconEmoji: '🧠',
        accentColor: AppColors.secondaryAccent,
        route: '/memory-game',
        tag: 'COGNITIVE',
        personalBest: StorageService.getPersonalBest('memory'),
        roundsLabel: 'Endless levels',
      ),
      _GameItem(
        id: 'mind_snap',
        category: 'reflex',
        title: 'Mind Snap',
        subtitle: 'High-speed true/false equation & symbol reflex challenges',
        iconEmoji: '⚡',
        accentColor: AppColors.warning,
        route: '/mind-snap',
        tag: 'REFLEX',
        personalBest: StorageService.getPersonalBest('mind_snap'),
        roundsLabel: '60 seconds',
      ),
      _GameItem(
        id: 'logic',
        category: 'logic',
        title: 'Pattern & Logic Puzzles',
        subtitle: 'Sequence completion, missing number discovery, and deduction',
        iconEmoji: '🧩',
        accentColor: AppColors.success,
        route: '/logic-puzzles',
        tag: 'PROBLEM SOLVING',
        personalBest: StorageService.getPersonalBest('logic'),
        roundsLabel: '10 puzzles',
      ),
      _GameItem(
        id: 'flash_anzan',
        category: 'math',
        title: 'Flash Anzan (Soroban)',
        subtitle: 'Mentally sum numbers flashed rapidly on the screen',
        iconEmoji: '⚡',
        accentColor: AppColors.warning,
        route: '/flash-anzan',
        tag: 'SOROBAN SPEED',
        personalBest: 0,
        roundsLabel: 'Rapid flash',
      ),
      _GameItem(
        id: 'cross_math',
        category: 'logic',
        title: 'Cross Math Puzzle',
        subtitle: 'Fill intersecting arithmetic equation grid correctly',
        iconEmoji: '➕',
        accentColor: AppColors.primaryAccent,
        route: '/puzzle-crossmath',
        tag: 'CROSSWORD MATH',
        personalBest: 0,
        roundsLabel: 'Grid puzzle',
      ),
      _GameItem(
        id: 'mini_sudoku',
        category: 'logic',
        title: 'Mini 4×4 Sudoku',
        subtitle: 'Compact Sudoku deduction with notes and conflict detection',
        iconEmoji: '🔢',
        accentColor: const Color(0xFF38BDF8),
        route: '/puzzle-sudoku',
        tag: 'DEDUCTION',
        personalBest: 0,
        roundsLabel: '4×4 board',
      ),
      _GameItem(
        id: 'casual_feed',
        category: 'reflex',
        title: 'Casual Mini-Games Feed',
        subtitle: 'Swipeable interactive feed: Reaction Tap, 2048, Memory Match & more',
        iconEmoji: '🎮',
        accentColor: const Color(0xFFE879F9),
        route: '/casual-games',
        tag: 'CASUAL DISCOVERY',
        personalBest: 0,
        roundsLabel: '6+ Mini-games',
      ),
      _GameItem(
        id: 'room_duel',
        category: 'math',
        title: 'Private Friend Match Room',
        subtitle: 'Host or join a custom 1v1 duel using a 6-digit PIN code',
        iconEmoji: '🔑',
        accentColor: AppColors.secondaryAccent,
        route: '/room-duel',
        tag: 'MULTIPLAYER',
        personalBest: 0,
        roundsLabel: 'Private room',
      ),
      _GameItem(
        id: 'daily_challenge',
        category: 'math',
        title: 'Daily Challenge',
        subtitle: 'Daily brain test to maintain streak and earn bonus XP',
        iconEmoji: '📅',
        accentColor: const Color(0xFFFB923C),
        route: '/daily-challenge',
        tag: 'DAILY',
        personalBest: StorageService.dailyStreak,
        roundsLabel: '10 questions',
      ),
      _GameItem(
        id: 'workout',
        category: 'logic',
        title: '5-Minute Brain Workout',
        subtitle: 'Full mental circuit: Math + Memory + Logic in 3 quick rounds',
        iconEmoji: '🏋️',
        accentColor: const Color(0xFFE879F9),
        route: '/workout',
        tag: 'DAILY CIRCUIT',
        personalBest: 0,
        roundsLabel: '3 rounds',
      ),
      _GameItem(
        id: 'real_world_arcade',
        category: 'real_world',
        title: 'Real-World Games Arcade',
        subtitle: '10 tabletop & physics games: Carrom, Jenga, Cup Pong, Paper Football & more',
        iconEmoji: '🎯',
        accentColor: AppColors.primaryAccent,
        route: '/arcade',
        tag: '10 GAMES ARCADE',
        personalBest: 0,
        roundsLabel: 'Full collection',
      ),
      _GameItem(
        id: 'paper_football',
        category: 'real_world',
        title: 'Paper Football',
        subtitle: 'Slide triangle to desk edge for touchdown and flick field goals',
        iconEmoji: '🏈',
        accentColor: const Color(0xFF52E0C0),
        route: '/game-paper-football',
        tag: 'PHYSICS',
        personalBest: StorageService.getPersonalBest('paper_football'),
        roundsLabel: 'vs AI or 2P',
      ),
      _GameItem(
        id: 'mini_carrom',
        category: 'real_world',
        title: 'Mini Carrom',
        subtitle: 'Flick striker, rebound off cushions, and pocket white, black & Queen',
        iconEmoji: '🔴',
        accentColor: const Color(0xFFF59E0B),
        route: '/game-mini-carrom',
        tag: 'TABLETOP',
        personalBest: StorageService.getPersonalBest('mini_carrom'),
        roundsLabel: 'Board game',
      ),
      _GameItem(
        id: 'cup_pong',
        category: 'real_world',
        title: 'Cup Pong',
        subtitle: 'Toss ping pong balls in realistic 3D gravity arcs to clear cup pyramid',
        iconEmoji: '🥤',
        accentColor: const Color(0xFFEF4444),
        route: '/game-cup-pong',
        tag: '3D TRAJECTORY',
        personalBest: StorageService.getPersonalBest('cup_pong'),
        roundsLabel: '10 balls',
      ),
      _GameItem(
        id: 'jenga_tower',
        category: 'real_world',
        title: 'Jenga Tower',
        subtitle: 'Slide blocks out of lower floors and stack them on top without toppling',
        iconEmoji: '🧱',
        accentColor: const Color(0xFFD97706),
        route: '/game-jenga',
        tag: 'BALANCE & SWAY',
        personalBest: StorageService.getPersonalBest('jenga_tower'),
        roundsLabel: 'Endless height',
      ),
      _GameItem(
        id: 'reflex_duel',
        category: 'real_world',
        title: 'Reflex Duel',
        subtitle: 'Split-screen face-to-face reaction duel! First to tap green wins',
        iconEmoji: '⚡',
        accentColor: AppColors.secondaryAccent,
        route: '/game-reflex-duel',
        tag: '2P SPLIT SCREEN',
        personalBest: 0,
        roundsLabel: 'Best of 5',
      ),
    ];

    final filtered = _selectedCategory == 'all'
        ? games
        : games.where((g) => g.category == _selectedCategory).toList();

    return filtered.map((game) {
      return Container(
        margin: const EdgeInsets.only(bottom: 14),
        child: GameCard(
          onTap: () => Navigator.of(context).pushNamed(game.route),
          borderColor: game.accentColor.withOpacity(0.3),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: game.accentColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: game.accentColor.withOpacity(0.3)),
                    ),
                    child: Center(
                      child: Text(game.iconEmoji, style: const TextStyle(fontSize: 28)),
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
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: game.accentColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                game.tag,
                                style: AppTypography.labelSmall.copyWith(
                                  color: game.accentColor,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (game.personalBest > 0)
                              Text(
                                'Best: ${game.personalBest} pts',
                                style: AppTypography.monoCaption.copyWith(
                                  color: AppColors.warning,
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(game.title, style: AppTypography.heading4),
                        const SizedBox(height: 4),
                        Text(
                          game.subtitle,
                          style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBg.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.timer_outlined, size: 14, color: AppColors.secondaryText),
                        const SizedBox(width: 4),
                        Text(game.roundsLabel, style: AppTypography.bodySmall.copyWith(fontSize: 11)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          'Play',
                          style: AppTypography.labelSmall.copyWith(
                            color: game.accentColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Icon(Icons.arrow_forward_rounded, size: 14, color: game.accentColor),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }
}

class _GameItem {
  final String id;
  final String category;
  final String title;
  final String subtitle;
  final String iconEmoji;
  final Color accentColor;
  final String route;
  final String tag;
  final int personalBest;
  final String roundsLabel;

  _GameItem({
    required this.id,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.iconEmoji,
    required this.accentColor,
    required this.route,
    required this.tag,
    required this.personalBest,
    required this.roundsLabel,
  });
}
