import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/game/game_widgets.dart';
import '../../../providers/game_provider.dart';
import '../../../models/game_models.dart';

class SoloMathScreen extends StatefulWidget {
  const SoloMathScreen({super.key});

  @override
  State<SoloMathScreen> createState() => _SoloMathScreenState();
}

class _SoloMathScreenState extends State<SoloMathScreen> {
  bool _useKeypad = false;
  String _keypadInput = '';
  Timer? _sessionTimer;
  int _elapsedSeconds = 0;
  bool _isStarted = false;
  int? _selectedAnswer;
  bool _showFeedback = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPractice();
    });
  }

  void _startPractice() {
    final provider = context.read<GameProvider>();
    provider.startSoloPractice(questionCount: 15);
    setState(() {
      _elapsedSeconds = 0;
      _isStarted = true;
      _keypadInput = '';
      _selectedAnswer = null;
      _showFeedback = false;
      _isProcessing = false;
    });

    _sessionTimer?.cancel();
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => _elapsedSeconds++);
      }
    });
  }

  void _submitAnswer(int answer) {
    if (_isProcessing) return;
    final provider = context.read<GameProvider>();

    setState(() {
      _isProcessing = true;
      _selectedAnswer = answer;
      _showFeedback = true;
    });

    final result = provider.submitSoloAnswer(answer);

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      if (result != null) {
        _sessionTimer?.cancel();
        Navigator.of(context).pushReplacementNamed('/results', arguments: result);
      } else {
        setState(() {
          _selectedAnswer = null;
          _showFeedback = false;
          _isProcessing = false;
          _keypadInput = '';
        });
      }
    });
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<GameProvider>(
      builder: (context, provider, _) {
        final currentQ = provider.currentQuestion;

        if (!_isStarted || currentQ == null) {
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
            title: Text('Speed Math Sprint', style: AppTypography.heading4),
            actions: [
              IconButton(
                icon: Icon(
                  _useKeypad ? Icons.grid_view_rounded : Icons.dialpad_rounded,
                  color: AppColors.primaryAccent,
                ),
                tooltip: _useKeypad ? 'Switch to Multiple Choice' : 'Switch to Numeric Keypad',
                onPressed: () => setState(() => _useKeypad = !_useKeypad),
              ),
            ],
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Column(
                children: [
                  // ─── Stats Row: Score, Streak, Timer ───
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
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: AppColors.warning),
                            const SizedBox(width: 4),
                            Text('${provider.score} pts', style: AppTypography.labelSmall),
                          ],
                        ),
                      ),
                      GameTimer(seconds: _elapsedSeconds),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.divider),
                        ),
                        child: Row(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 14)),
                            const SizedBox(width: 4),
                            Text('${provider.currentStreakCount}', style: AppTypography.labelSmall),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // ─── Progress ───
                  QuestionProgress(
                    current: provider.currentQuestionIndex,
                    total: provider.currentQuestions.length,
                  ),

                  const Spacer(),

                  // ─── Equation Card ───
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 16),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _showFeedback
                            ? (_selectedAnswer == currentQ.correctAnswer
                                ? AppColors.success
                                : AppColors.error)
                            : AppColors.divider,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          currentQ.questionText,
                          style: AppTypography.monoLarge.copyWith(fontSize: 40),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currentQ.operation.label,
                          style: AppTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // ─── Answer Input (Keypad or Multiple Choice) ───
                  if (_useKeypad) ...[
                    NumericKeypad(
                      currentInput: _keypadInput,
                      onNumberTap: (digit) {
                        if (_keypadInput.length < 6) {
                          setState(() => _keypadInput += '$digit');
                        }
                      },
                      onDelete: () {
                        if (_keypadInput.isNotEmpty) {
                          setState(() => _keypadInput = _keypadInput.substring(0, _keypadInput.length - 1));
                        }
                      },
                      onSubmit: () {
                        if (_keypadInput.isNotEmpty) {
                          final parsed = int.tryParse(_keypadInput);
                          if (parsed != null) _submitAnswer(parsed);
                        }
                      },
                    ),
                  ] else ...[
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.8,
                      children: currentQ.options.map((option) {
                        final isSelected = _selectedAnswer == option;
                        final isCorrect = option == currentQ.correctAnswer;

                        return AnswerOptionButton(
                          label: '$option',
                          isSelected: isSelected,
                          isCorrect: isCorrect,
                          showResult: _showFeedback,
                          onTap: () => _submitAnswer(option),
                        );
                      }).toList(),
                    ),
                  ],

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
