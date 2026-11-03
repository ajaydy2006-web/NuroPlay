import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';
import '../../services/storage_service.dart';

class RealWorldGameInfo {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String categoryName;
  final IconData icon;
  final List<String> tags;
  final String route;
  final Color accentColor;
  final String rules;
  final bool hasMultiplayer;
  final String multiplayerMode;
  final String multiplayerDetails;

  const RealWorldGameInfo({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.categoryName,
    required this.icon,
    required this.tags,
    required this.route,
    required this.accentColor,
    required this.rules,
    this.hasMultiplayer = true,
    this.multiplayerMode = '2-Player Duel',
    this.multiplayerDetails = 'Pass & Play on this device with a friend',
  });
}

class RealWorldArcadeScreen extends StatefulWidget {
  const RealWorldArcadeScreen({super.key});

  @override
  State<RealWorldArcadeScreen> createState() => _RealWorldArcadeScreenState();
}

class _RealWorldArcadeScreenState extends State<RealWorldArcadeScreen> {
  String _selectedCategory = 'all';
  String _searchQuery = '';

  final List<RealWorldGameInfo> _games = const [
    RealWorldGameInfo(
      id: 'paper_football',
      title: 'Paper Football',
      subtitle: 'Flick the folded triangle across the desk to score touchdowns & field goals!',
      category: 'classroom',
      categoryName: 'Classroom Classics',
      icon: Icons.sports_football_rounded,
      tags: ['Physics', 'Touchdown', 'Field Goal', 'vs AI / 2P'],
      route: '/game-paper-football',
      accentColor: Color(0xFF00D2FF),
      rules: '• Slide the paper triangle across the table so it hangs over the opposite edge without falling off for a Touchdown (6 pts)!\n• Complete the extra point / field goal by flicking through the goal posts!',
      hasMultiplayer: true,
      multiplayerMode: '2P Pass & Play',
      multiplayerDetails: 'Two players take turns flicking from opposite table edges',
    ),
    RealWorldGameInfo(
      id: 'paper_plane',
      title: 'Paper Plane Challenge',
      subtitle: 'Fold, aim, and glide your paper airplane down the hallway through target rings!',
      category: 'classroom',
      categoryName: 'Classroom Classics',
      icon: Icons.flight_takeoff_rounded,
      tags: ['Aerodynamics', 'Wind Vectors', 'Rings', '3 Fold Styles'],
      route: '/game-paper-plane',
      accentColor: Color(0xFF0091FF),
      rules: '• Choose Dart (speed), Glider (lift), or Acrobat (balanced).\n• Drag back to charge launch thrust and set pitch angle.\n• Ride tailwinds, avoid headwinds, and fly through glowing rings for bonus multipliers!',
      hasMultiplayer: true,
      multiplayerMode: '2P Flight Contest',
      multiplayerDetails: 'Alternate throws to see whose plane glides the furthest',
    ),
    RealWorldGameInfo(
      id: 'mini_carrom',
      title: 'Mini Carrom',
      subtitle: 'Place your striker on the baseline, charge flick power, and pocket carrom men & Queen!',
      category: 'tabletop',
      categoryName: 'Tabletop Games',
      icon: Icons.lens_blur_rounded,
      tags: ['Billiard Physics', 'Rebound Cushions', 'Queen Cover', 'Striker Aim'],
      route: '/game-mini-carrom',
      accentColor: Color(0xFF00E5FF),
      rules: '• Position striker along the baseline with the horizontal slider.\n• Drag back from the striker to aim and charge shot power.\n• Pocket white (10pts), black (5pts), and the Queen (25pts) with a subsequent cover!',
      hasMultiplayer: true,
      multiplayerMode: '2P Pass & Play',
      multiplayerDetails: 'Player 1 (White) vs Player 2 (Black) alternate shots',
    ),
    RealWorldGameInfo(
      id: 'cup_pong',
      title: 'Cup Pong',
      subtitle: 'Toss ping pong balls in realistic 3D gravity arcs to clear the red solo cup pyramid!',
      category: 'tabletop',
      categoryName: 'Tabletop Games',
      icon: Icons.sports_baseball_rounded,
      tags: ['3D Trajectory', 'Gravity Arc', 'Pyramid Cups', 'Streak Bonus'],
      route: '/game-cup-pong',
      accentColor: Color(0xFFFF2A6D),
      rules: '• Drag back or flick forward from the bottom of the screen to throw.\n• Land inside red cups to eliminate them from the table.\n• Clear all 6 cups with remaining balls to set high scores!',
      hasMultiplayer: true,
      multiplayerMode: '2P Cup Duel',
      multiplayerDetails: 'Head-to-head toss competition: sink more cups in 5 throws',
    ),
    RealWorldGameInfo(
      id: 'marble_knockout',
      title: 'Marble Knockout',
      subtitle: 'Flick your shooter marble into the circle to blast target marbles out of the ring!',
      category: 'tabletop',
      categoryName: 'Tabletop Games',
      icon: Icons.circle_outlined,
      tags: ['Elastic Collisions', 'Ring Boundary', 'Momentum', 'Precision Flick'],
      route: '/game-marble-knockout',
      accentColor: Color(0xFF0091FF),
      rules: '• Aim and release your shooter marble into the ring.\n• Transfer momentum upon collision to knock colored target marbles over the boundary line.\n• Keep your shooter inside the ring to retain your turn!',
      hasMultiplayer: true,
      multiplayerMode: '2P Ring Battle',
      multiplayerDetails: 'Alternate turns blasting marbles out of the circle',
    ),
    RealWorldGameInfo(
      id: 'jenga_tower',
      title: 'Jenga Tower',
      subtitle: 'Delicately slide wooden blocks from lower floors and stack them on top without toppling!',
      category: 'tabletop',
      categoryName: 'Tabletop Games',
      icon: Icons.domain_rounded,
      tags: ['Center of Mass', 'Instability Sway', '2P / vs WoodBot', 'High-Rise'],
      route: '/game-jenga',
      accentColor: Color(0xFFFFB800),
      rules: '• Tap any wooden block on floors below the top 2.\n• Drag the extraction slider steadily—removing key corner blocks increases tower sway and instability!\n• Successfully extracted blocks are stacked on top.\n• The player who topples the tower loses!',
      hasMultiplayer: true,
      multiplayerMode: '2P Pass & Play',
      multiplayerDetails: 'Take turns pulling blocks until someone topples the tower',
    ),
    RealWorldGameInfo(
      id: 'tic_tac_toe',
      title: 'Tic-Tac-Toe Arena',
      subtitle: 'Classic 3x3 duel with Minimax AI difficulty levels and Pass & Play local 2P!',
      category: 'duels',
      categoryName: 'Quick Duels',
      icon: Icons.grid_3x3_rounded,
      tags: ['Minimax AI', 'Pass & Play', 'Win Streaks', 'Turn Tactics'],
      route: '/game-tictactoe',
      accentColor: Color(0xFF0091FF),
      rules: '• Align 3 of your marks horizontally, vertically, or diagonally.\n• Test your strategies against Smart Minimax AI or battle a friend locally in 2P mode!',
      hasMultiplayer: true,
      multiplayerMode: '2P Pass & Play',
      multiplayerDetails: 'Turn-based X vs O duel on the same screen',
    ),
    RealWorldGameInfo(
      id: 'rps_showdown',
      title: 'Rock Paper Scissors',
      subtitle: 'Psychological best-of showdown with pattern-predicting AI and animated card reveals!',
      category: 'duels',
      categoryName: 'Quick Duels',
      icon: Icons.front_hand_rounded,
      tags: ['Pattern AI', 'Best of 3/5/7', 'Psychology', 'Streaks'],
      route: '/game-rps',
      accentColor: Color(0xFFFF2A6D),
      rules: '• Rock crushes Scissors, Scissors cuts Paper, Paper covers Rock.\n• The AI tracks your recent tendencies and adjusts its predictions in Best-of series!',
      hasMultiplayer: true,
      multiplayerMode: '2P Secret Duel',
      multiplayerDetails: 'Secret selection showdown with animated card reveal',
    ),
    RealWorldGameInfo(
      id: 'four_in_row',
      title: 'Four in a Row',
      subtitle: 'Drop colored chips into the 7x6 grid and connect 4 horizontally, vertically, or diagonally!',
      category: 'duels',
      categoryName: 'Quick Duels',
      icon: Icons.view_column_rounded,
      tags: ['Gravity Drop', 'Heuristic AI', 'Pass & Play', 'Tactical Blocking'],
      route: '/game-four-in-row',
      accentColor: Color(0xFF00D2FF),
      rules: '• Tap any of the 7 columns to drop your color disc into the lowest available slot.\n• Connect 4 discs in a row in any direction to win.\n• Block your opponent before they set up unblockable dual-threat lines!',
      hasMultiplayer: true,
      multiplayerMode: '2P Pass & Play',
      multiplayerDetails: 'Player 1 (Cyan) vs Player 2 (Purple) alternate drops',
    ),
    RealWorldGameInfo(
      id: 'reflex_duel',
      title: 'Reflex Duel',
      subtitle: 'Split-screen face-to-face reaction showdown! Tap instantly when the screen turns green!',
      category: 'reaction',
      categoryName: 'Reaction Games',
      icon: Icons.bolt_rounded,
      tags: ['Face-to-Face 2P', 'Millisecond Timer', 'False-Start Penalty', 'vs AI'],
      route: '/game-reflex-duel',
      accentColor: Color(0xFF00F5A0),
      rules: '• Hold device flat between two players (or play against ReflexBot).\n• Wait through the red anticipation phase.\n• The INSTANT the screen flashes GREEN, tap your button!\n• Beware: false starts award a point to your opponent!',
      hasMultiplayer: true,
      multiplayerMode: 'Face-to-Face 2P',
      multiplayerDetails: 'Inverted split-screen instant millisecond reflex battle',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final filteredGames = _games.where((g) {
      final matchesCategory = _selectedCategory == 'all'
          ? true
          : _selectedCategory == 'multiplayer'
              ? g.hasMultiplayer
              : g.category == _selectedCategory;
      final matchesQuery = _searchQuery.isEmpty ||
          g.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g.subtitle.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          g.tags.any((t) => t.toLowerCase().contains(_searchQuery.toLowerCase()));
      return matchesCategory && matchesQuery;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      body: NuroPlayBackground(
        child: SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
            // Top App Bar
            SliverAppBar(
              backgroundColor: AppColors.primaryBg,
              elevation: 0,
              pinned: true,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.primaryText),
                onPressed: () => Navigator.pop(context),
              ),
              title: Text('Real-World Arcade', style: AppTypography.heading2),
              centerTitle: true,
              actions: [
                IconButton(
                  icon: const Icon(Icons.sports_esports_rounded, color: AppColors.primaryAccent),
                  onPressed: () {},
                ),
              ],
            ),

            // Hero Banner
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryAccent.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryAccent.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryAccent.withOpacity(0.4)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.auto_awesome_rounded, size: 14, color: AppColors.primaryAccent),
                              const SizedBox(width: 6),
                              Text(
                                '10 Playable Games',
                                style: AppTypography.labelSmall.copyWith(
                                  color: AppColors.primaryAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryAccent.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.secondaryAccent.withOpacity(0.4)),
                          ),
                          child: Text(
                            'Physics & 2P Duels',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.secondaryAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Tabletop & Physical Classics',
                      style: AppTypography.heading3.copyWith(color: AppColors.primaryText),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Experience tactile physics, pass & play local duels, and smart AI opponents inspired by classroom games and tabletop legends.',
                      style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: TextField(
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  onChanged: (q) => setState(() => _searchQuery = q),
                  decoration: InputDecoration(
                    hintText: 'Search games, mechanics, or categories...',
                    hintStyle: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                    prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryAccent, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, color: AppColors.secondaryText, size: 18),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.cardBg,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.divider),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primaryAccent),
                    ),
                  ),
                ),
              ),
            ),

            // Category Filter Tabs
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildCategoryChip('all', 'All Games (10)', Icons.apps_rounded),
                    const SizedBox(width: 8),
                    _buildCategoryChip('multiplayer', '👥 2P Multiplayer', Icons.people_alt_rounded),
                    const SizedBox(width: 8),
                    _buildCategoryChip('classroom', '🏫 Classroom', Icons.school_rounded),
                    const SizedBox(width: 8),
                    _buildCategoryChip('tabletop', '🎯 Tabletop', Icons.table_restaurant_rounded),
                    const SizedBox(width: 8),
                    _buildCategoryChip('duels', '⚔️ Quick Duels', Icons.flash_on_rounded),
                    const SizedBox(width: 8),
                    _buildCategoryChip('reaction', '⚡ Reaction', Icons.bolt_rounded),
                  ],
                ),
              ),
            ),

            // Games Grid / List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final game = filteredGames[index];
                    return _buildGameCard(game);
                  },
                  childCount: filteredGames.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildCategoryChip(String id, String label, IconData icon) {
    final isSelected = _selectedCategory == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.divider,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryAccent.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? AppColors.primaryBg : AppColors.secondaryText,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryBg : AppColors.primaryText,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameCard(RealWorldGameInfo game) {
    final personalBest = StorageService.getPersonalBest(game.id);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showGameOptionsModal(game),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Icon, Title, Category & Badges, and Info Icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            game.accentColor.withOpacity(0.25),
                            game.accentColor.withOpacity(0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: game.accentColor.withOpacity(0.4)),
                      ),
                      child: Icon(game.icon, color: game.accentColor, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  game.title,
                                  style: AppTypography.heading3.copyWith(fontSize: 18),
                                ),
                              ),
                              if (personalBest > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.emoji_events_rounded, size: 12, color: AppColors.warning),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Best: $personalBest',
                                        style: const TextStyle(
                                          color: AppColors.warning,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Text(
                                game.categoryName,
                                style: AppTypography.captionSmall.copyWith(
                                  color: game.accentColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (game.hasMultiplayer) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.secondaryAccent.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.secondaryAccent.withOpacity(0.4)),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.people_alt_rounded, size: 11, color: AppColors.secondaryAccent),
                                      const SizedBox(width: 4),
                                      Text(
                                        game.multiplayerMode,
                                        style: const TextStyle(
                                          color: AppColors.secondaryAccent,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, color: AppColors.secondaryText, size: 20),
                      onPressed: () => _showGameRules(game),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  game.subtitle,
                  style: AppTypography.bodySmall.copyWith(color: AppColors.secondaryText, height: 1.4),
                ),
                const SizedBox(height: 12),
                // Tags
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: game.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          color: AppColors.primaryText,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                // Game Mode Action Buttons
                Row(
                  children: [
                    // Solo / Options Button
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          side: BorderSide(color: AppColors.primaryAccent.withOpacity(0.6)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          backgroundColor: AppColors.primaryAccent.withOpacity(0.08),
                        ),
                        onPressed: () => _showGameOptionsModal(game),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.tune_rounded, size: 16, color: AppColors.primaryAccent),
                            SizedBox(width: 6),
                            Text(
                              'Game Options',
                              style: TextStyle(
                                color: AppColors.primaryAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Quick 2P Multiplayer Launch Button
                    if (game.hasMultiplayer)
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: AppColors.secondaryAccent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 3,
                          ),
                          onPressed: () => Navigator.pushNamed(context, game.route),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.people_alt_rounded, size: 16, color: Colors.white),
                              SizedBox(width: 6),
                              Text(
                                '👥 2P Duel',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    else
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            backgroundColor: game.accentColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                          onPressed: () => Navigator.pushNamed(context, game.route),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Play Solo',
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.play_arrow_rounded, color: Colors.white, size: 16),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGameOptionsModal(RealWorldGameInfo game) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag Handle Bar
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.divider,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  // Header
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: game.accentColor.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: game.accentColor.withOpacity(0.4)),
                        ),
                        child: Icon(game.icon, color: game.accentColor, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(game.title, style: AppTypography.heading3.copyWith(fontSize: 19)),
                            const SizedBox(height: 2),
                            Text(
                              game.subtitle,
                              style: AppTypography.captionSmall.copyWith(color: AppColors.secondaryText),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SELECT GAME MODE',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.secondaryText,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Option 1: Solo vs AI
                  _buildOptionTile(
                    title: 'Solo Practice / vs AI',
                    subtitle: 'Play against smart bot algorithms or practice physics aiming',
                    icon: Icons.smart_toy_rounded,
                    accent: game.accentColor,
                    badge: 'SOLO / AI',
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, game.route);
                    },
                  ),
                  const SizedBox(height: 10),

                  // Option 2: 2-Player Local Multiplayer
                  if (game.hasMultiplayer)
                    _buildOptionTile(
                      title: '2-Player Multiplayer (${game.multiplayerMode})',
                      subtitle: game.multiplayerDetails,
                      icon: Icons.people_alt_rounded,
                      accent: AppColors.secondaryAccent,
                      badge: 'LOCAL 2P',
                      isHighlighted: true,
                      onTap: () {
                        Navigator.pop(ctx);
                        Navigator.pushNamed(context, game.route);
                      },
                    ),
                  if (game.hasMultiplayer) const SizedBox(height: 10),

                  // Option 3: Online 1v1 Room
                  _buildOptionTile(
                    title: 'Online 1v1 Room (Room Code)',
                    subtitle: 'Create a private multiplayer room or join with a 4-digit PIN',
                    icon: Icons.wifi_tethering_rounded,
                    accent: const Color(0xFF00F5A0),
                    badge: 'ONLINE 1v1',
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.pushNamed(context, '/room-duel');
                    },
                  ),
                  const SizedBox(height: 14),

                  // Rules & How to Play Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: const BorderSide(color: AppColors.divider),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _showGameRules(game);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.menu_book_rounded, size: 16, color: AppColors.primaryText),
                          SizedBox(width: 8),
                          Text(
                            'View Rules & How to Play',
                            style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
    required String badge,
    required VoidCallback onTap,
    bool isHighlighted = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isHighlighted ? accent.withOpacity(0.12) : AppColors.primaryBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isHighlighted ? accent.withOpacity(0.5) : AppColors.divider,
          width: isHighlighted ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: accent, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              badge,
                              style: TextStyle(
                                color: accent,
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppColors.secondaryText,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.secondaryText, size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showGameRules(RealWorldGameInfo game) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: game.accentColor.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(game.icon, color: game.accentColor, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                game.title,
                style: AppTypography.heading3,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How to Play',
              style: AppTypography.labelLarge.copyWith(color: AppColors.primaryAccent),
            ),
            const SizedBox(height: 8),
            Text(
              game.rules,
              style: AppTypography.bodySmall.copyWith(color: AppColors.primaryText, height: 1.5),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.secondaryText)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: game.accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushNamed(context, game.route);
            },
            child: const Text('Play Now', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}
