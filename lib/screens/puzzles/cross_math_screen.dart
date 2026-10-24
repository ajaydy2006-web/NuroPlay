import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../widgets/common/common_widgets.dart';

class CrossMathScreen extends StatefulWidget {
  const CrossMathScreen({super.key});

  @override
  State<CrossMathScreen> createState() => _CrossMathScreenState();
}

class _CrossMathScreenState extends State<CrossMathScreen> {
  // Puzzle:
  // Row 1: [a] + [b] = 14
  // Col 1:  ×     +
  // Row 2: [c] - [d] = 2
  //        =     =
  //        18    9
  // Solution: a=6, b=8, c=3, d=1
  // (6+8=14, 3-1=2, 6*3=18, 8+1=9)
  final Map<String, int> _solution = {
    'a': 6,
    'b': 8,
    'c': 3,
    'd': 1,
  };

  final Map<String, int?> _userInputs = {
    'a': null,
    'b': null,
    'c': null,
    'd': null,
  };

  String? _selectedCell = 'a';
  bool _isSolved = false;
  int _hintsUsed = 0;

  void _onNumberTap(int num) {
    if (_isSolved || _selectedCell == null) return;

    setState(() {
      _userInputs[_selectedCell!] = num;
      _checkCompletion();
    });
  }

  void _clearSelected() {
    if (_selectedCell != null) {
      setState(() => _userInputs[_selectedCell!] = null);
    }
  }

  void _checkCompletion() {
    bool allFilled = true;
    bool allCorrect = true;

    for (final key in _solution.keys) {
      if (_userInputs[key] == null) {
        allFilled = false;
        break;
      }
      if (_userInputs[key] != _solution[key]) {
        allCorrect = false;
      }
    }

    if (allFilled && allCorrect) {
      setState(() => _isSolved = true);
    }
  }

  void _useHint() {
    if (_isSolved) return;
    for (final key in _solution.keys) {
      if (_userInputs[key] != _solution[key]) {
        setState(() {
          _userInputs[key] = _solution[key];
          _hintsUsed++;
          _checkCompletion();
        });
        break;
      }
    }
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
        title: Text('Cross Math Puzzle', style: AppTypography.heading4),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline_rounded, color: AppColors.warning),
            tooltip: 'Get Hint',
            onPressed: _useHint,
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // Header description
              Text('Fill empty cells so all horizontal & vertical equations are true', style: AppTypography.bodySmall, textAlign: TextAlign.center),
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
                    child: Text('🎉 CROSS MATH SOLVED!', style: AppTypography.heading3.copyWith(color: AppColors.primaryBg)),
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Grid Equation Area
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.divider),
                ),
                child: Column(
                  children: [
                    // Row 1: [A] + [B] = 14
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCell('a'),
                        _buildOp('+'),
                        _buildCell('b'),
                        _buildOp('='),
                        _buildResult(14),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Middle Op Row: [×]   [+]
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildOp('×'),
                        const SizedBox(width: 44),
                        _buildOp('+'),
                        const SizedBox(width: 88),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Row 2: [C] - [D] = 2
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildCell('c'),
                        _buildOp('−'),
                        _buildCell('d'),
                        _buildOp('='),
                        _buildResult(2),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Equals Row: [=]   [=]
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildOp('='),
                        const SizedBox(width: 44),
                        _buildOp('='),
                        const SizedBox(width: 88),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Bottom Result Row: 18   9
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildResult(18),
                        const SizedBox(width: 44),
                        _buildResult(9),
                        const SizedBox(width: 88),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Numeric Keypad
              GridView.count(
                crossAxisCount: 5,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 1.2,
                children: [
                  for (int i = 1; i <= 9; i++)
                    _buildKey('$i', () => _onNumberTap(i)),
                  _buildKey('⌫', _clearSelected, color: AppColors.error.withOpacity(0.2), textColor: AppColors.error),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCell(String key) {
    final val = _userInputs[key];
    final isSelected = _selectedCell == key;

    return GestureDetector(
      onTap: () => setState(() => _selectedCell = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent.withOpacity(0.2) : AppColors.elevatedCard,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? AppColors.primaryAccent : AppColors.divider,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            val != null ? '$val' : '?',
            style: AppTypography.monoMedium.copyWith(
              fontSize: 20,
              color: val != null ? AppColors.primaryAccent : AppColors.secondaryText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOp(String op) {
    return SizedBox(
      width: 44,
      child: Center(
        child: Text(op, style: AppTypography.monoMedium.copyWith(color: AppColors.secondaryText, fontSize: 22)),
      ),
    );
  }

  Widget _buildResult(int res) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.primaryBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.divider),
      ),
      child: Center(
        child: Text('$res', style: AppTypography.monoMedium.copyWith(fontSize: 18, color: AppColors.warning)),
      ),
    );
  }

  Widget _buildKey(String label, VoidCallback onTap, {Color? color, Color? textColor}) {
    return Material(
      color: color ?? AppColors.elevatedCard,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Center(
          child: Text(
            label,
            style: AppTypography.monoSmall.copyWith(
              color: textColor ?? AppColors.primaryText,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}
