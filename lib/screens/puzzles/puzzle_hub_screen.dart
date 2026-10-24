import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class PuzzleHubScreen extends StatelessWidget {
  const PuzzleHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final puzzles = [
      _PuzzleItem(
        title: 'Cross Math',
        subtitle: 'Grid of intersecting arithmetic equations',
        icon: '➕',
        color: AppColors.primaryAccent,
        route: '/puzzle-crossmath',
        badge: 'ARITHMETIC GRID',
      ),
      _PuzzleItem(
        title: 'Mini 4×4 Sudoku',
        subtitle: 'Compact Sudoku with number logic & notes mode',
        icon: '🔢',
        color: const Color(0xFF38BDF8),
        route: '/puzzle-sudoku',
        badge: 'LOGIC DEDUCTION',
      ),
      _PuzzleItem(
        title: 'Number Sequence Puzzles',
        subtitle: 'Arithmetic, geometric & quadratic number series',
        icon: '🧩',
        color: AppColors.secondaryAccent,
        route: '/logic-puzzles',
        badge: 'SERIES & PATTERNS',
      ),
      _PuzzleItem(
        title: 'Flash Anzan Soroban',
        subtitle: 'Fast mental addition of flashed number series',
        icon: '⚡',
        color: AppColors.warning,
        route: '/flash-anzan',
        badge: 'SOROBAN SPEED',
      ),
    ];

    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Puzzle Collection', style: AppTypography.heading3),
      ),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: puzzles.length,
          itemBuilder: (context, idx) {
            final p = puzzles[idx];
            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: GameCard(
                onTap: () => Navigator.of(context).pushNamed(p.route),
                borderColor: p.color.withOpacity(0.4),
                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        color: p.color.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: p.color.withOpacity(0.4)),
                      ),
                      child: Center(
                        child: Text(p.icon, style: const TextStyle(fontSize: 28)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: p.color.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.badge,
                              style: AppTypography.labelSmall.copyWith(
                                color: p.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(p.title, style: AppTypography.heading4),
                          const SizedBox(height: 2),
                          Text(p.subtitle, style: AppTypography.bodySmall),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios_rounded, size: 16, color: p.color),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PuzzleItem {
  final String title;
  final String subtitle;
  final String icon;
  final Color color;
  final String route;
  final String badge;

  _PuzzleItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.route,
    required this.badge,
  });
}
