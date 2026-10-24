import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class MiniSudokuScreen extends StatefulWidget {
  const MiniSudokuScreen({super.key});

  @override
  State<MiniSudokuScreen> createState() => _MiniSudokuScreenState();
}

class _MiniSudokuScreenState extends State<MiniSudokuScreen> {
  // 4x4 Sudoku
  // Initial board (0 is empty):
  // [1] [0] | [0] [4]
  // [0] [0] | [3] [0]
  // --------+--------
  // [0] [1] | [0] [0]
  // [4] [0] | [0] [2]
  final List<List<int>> _initial = [
    [1, 0, 0, 4],
    [0, 0, 3, 0],
    [0, 1, 0, 0],
    [4, 0, 0, 2],
  ];

  final List<List<int>> _solution = [
    [1, 3, 2, 4],
    [2, 4, 3, 1],
    [3, 1, 4, 2],
    [4, 2, 1, 3],
  ];

  late List<List<int>> _current;
  int _selectedRow = 0;
  int _selectedCol = 1;
  bool _isSolved = false;

  @override
  void initState() {
    super.initState();
    _current = List.generate(4, (r) => List.generate(4, (c) => _initial[r][c]));
  }

  void _onNumberTap(int num) {
    if (_isSolved) return;
    if (_initial[_selectedRow][_selectedCol] != 0) return; // Cannot edit fixed cells

    setState(() {
      _current[_selectedRow][_selectedCol] = num;
      _checkSolved();
    });
  }

  void _onErase() {
    if (_isSolved) return;
    if (_initial[_selectedRow][_selectedCol] == 0) {
      setState(() {
        _current[_selectedRow][_selectedCol] = 0;
      });
    }
  }

  void _checkSolved() {
    for (int r = 0; r < 4; r++) {
      for (int c = 0; c < 4; c++) {
        if (_current[r][c] != _solution[r][c]) return;
      }
    }
    setState(() => _isSolved = true);
  }

  bool _hasConflict(int r, int c) {
    final val = _current[r][c];
    if (val == 0) return false;

    // Check row
    for (int col = 0; col < 4; col++) {
      if (col != c && _current[r][col] == val) return true;
    }
    // Check col
    for (int row = 0; row < 4; row++) {
      if (row != r && _current[row][c] == val) return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppColors.primaryText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Mini 4×4 Sudoku', style: AppTypography.heading4),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              Text('Fill numbers 1 to 4 in every row, column and 2×2 box', style: AppTypography.bodySmall, textAlign: TextAlign.center),
              const SizedBox(height: 16),

              if (_isSolved) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text('🎉 4×4 SUDOKU COMPLETED!', style: AppTypography.heading3.copyWith(color: AppColors.primaryBg)),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              const Spacer(),

              // Sudoku Grid
              Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.divider, width: 2),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: List.generate(4, (r) {
                        return Expanded(
                          child: Row(
                            children: List.generate(4, (c) {
                              final isSelected = _selectedRow == r && _selectedCol == c;
                              final val = _current[r][c];
                              final isFixed = _initial[r][c] != 0;
                              final isConflict = _hasConflict(r, c);

                              return Expanded(
                                child: GestureDetector(
                                  onTap: () => setState(() {
                                    _selectedRow = r;
                                    _selectedCol = c;
                                  }),
                                  child: Container(
                                    margin: EdgeInsets.fromLTRB(
                                      c == 2 ? 4 : 2,
                                      r == 2 ? 4 : 2,
                                      2,
                                      2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isConflict
                                          ? AppColors.error.withOpacity(0.2)
                                          : isSelected
                                              ? AppColors.primaryAccent.withOpacity(0.2)
                                              : AppColors.elevatedCard,
                                      borderRadius: BorderRadius.circular(10),
                                      border: Border.all(
                                        color: isConflict
                                            ? AppColors.error
                                            : isSelected
                                                ? AppColors.primaryAccent
                                                : AppColors.divider,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        val != 0 ? '$val' : '',
                                        style: AppTypography.monoLarge.copyWith(
                                          fontSize: 26,
                                          color: isFixed
                                              ? AppColors.secondaryAccent
                                              : isConflict
                                                  ? AppColors.error
                                                  : AppColors.primaryAccent,
                                          fontWeight: isFixed ? FontWeight.w700 : FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // Input Pad 1, 2, 3, 4, Erase
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (int i = 1; i <= 4; i++)
                    _buildInputKey('$i', () => _onNumberTap(i)),
                  _buildInputKey('⌫', _onErase, color: AppColors.error.withOpacity(0.2), textColor: AppColors.error),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputKey(String label, VoidCallback onTap, {Color? color, Color? textColor}) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: color ?? AppColors.elevatedCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: Text(
              label,
              style: AppTypography.monoMedium.copyWith(
                color: textColor ?? AppColors.primaryText,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
