import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/game/game_widgets.dart';
import '../../../providers/game_provider.dart';

class LogicPuzzlesScreen extends StatefulWidget {
  const LogicPuzzlesScreen({super.key});

  @override
  State<LogicPuzzlesScreen> createState() => _LogicPuzzlesScreenState();
}

class _LogicPuzzlesScreenState extends State<LogicPuzzlesScreen> {
  bool _showHint = false;
  dynamic _selectedOption;
  bool _showResult = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<GameProvider>();
      provider.startLogicPuzzles(count: 10);
    });
  }

  void _onOptionSelected(dynamic opt) {
    if (_isProcessing) return;
    final provider = context.read<GameProvider>();
    final puzzle = provider.currentPuzzle;
    if (puzzle == null) return;

    setState(() {
      _isProcessing = true;
      _selectedOption = opt;
      _showResult = true;
    });

    final result = provider.submitPuzzleAnswer(opt);

    // Show explanation modal or delay
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;

      if (result != null) {
        Navigator.of(context).pushReplacementNamed('/results', arguments: result);
      } else {
        setState(() {
          _selectedOption = null;
          _showResult = false;
          _showHint = false;
          _isProcessing = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final puzzle = provider.currentPuzzle;

        if (puzzle == null) {
          return const Scaffold(
            backgroundColor: AppColors.primaryBg,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.primaryBg,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
              onPressed: () {
                provider.resetGame();
                Navigator.of(context).pop();
              },
            ),
            title: Text('Logic & Pattern Puzzles', style: AppTypography.heading4),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Header: Score & Progress ───
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Text(
                          'Puzzle ${provider.puzzleIndex + 1} / ${provider.currentPuzzles.length}',
                          style: AppTypography.labelSmall.copyWith(color: AppColors.primaryAccent),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Text(
                          'Score: ${provider.puzzleScore} pts',
                          style: AppTypography.monoBody.copyWith(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Progress bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (provider.puzzleIndex + 1) / provider.currentPuzzles.length,
                      backgroundColor: AppColors.divider,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
                      minHeight: 4,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ─── Question Text ───
                  Text(puzzle.question, style: AppTypography.heading3),
                  const SizedBox(height: 16),

                  // ─── Sequence / Formula Display Box ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Column(
                      children: [
                        if (puzzle.type == 'sequence') ...[
                          Wrap(
                            alignment: WrapAlignment.center,
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              ...puzzle.sequence.map((item) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.elevatedCard,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.divider),
                                  ),
                                  child: Text(
                                    '$item',
                                    style: AppTypography.monoMedium.copyWith(fontSize: 24),
                                  ),
                                );
                              }),
                              // Mystery question mark slot
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryAccent.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppColors.primaryAccent, width: 2),
                                ),
                                child: Text(
                                  '?',
                                  style: AppTypography.monoMedium.copyWith(
                                    fontSize: 24,
                                    color: AppColors.primaryAccent,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ] else ...[
                          // Missing number equation
                          Text(
                            puzzle.sequence.first.toString(),
                            style: AppTypography.monoLarge.copyWith(fontSize: 34),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Hint Toggle Card ───
                  if (puzzle.hint != null) ...[
                    GestureDetector(
                      onTap: () => setState(() => _showHint = !_showHint),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.elevatedCard,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppColors.warning),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _showHint ? puzzle.hint! : 'Need a hint? Tap to reveal',
                                style: AppTypography.bodySmall.copyWith(
                                  color: _showHint ? AppColors.warning : AppColors.secondaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // ─── 4 Multiple Choice Options ───
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.8,
                    children: puzzle.options.map((option) {
                      final isSelected = _selectedOption == option;
                      final isCorrect = option == puzzle.correctAnswer;

                      return AnswerOptionButton(
                        label: '$option',
                        isSelected: isSelected,
                        isCorrect: isCorrect,
                        showResult: _showResult,
                        onTap: () => _onOptionSelected(option),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
