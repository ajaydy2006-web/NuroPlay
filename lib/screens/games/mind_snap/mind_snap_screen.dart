import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/game/game_widgets.dart';
import '../../../models/game_models.dart';
import '../../../services/storage_service.dart';

class MindSnapScreen extends StatefulWidget {
  const MindSnapScreen({super.key});

  @override
  State<MindSnapScreen> createState() => _MindSnapScreenState();
}

class _MindSnapScreenState extends State<MindSnapScreen> {
  static const int _gameDurationSeconds = 45;
  int _secondsRemaining = _gameDurationSeconds;
  Timer? _gameTimer;

  int _score = 0;
  int _correct = 0;
  int _wrong = 0;
  int _streak = 0;
  int _bestStreak = 0;

  late _SnapQuestion _currentQuestion;
  bool _feedbackShowing = false;
  bool _lastAnswerCorrect = false;

  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateNextQuestion();
    _startTimer();
  }

  void _startTimer() {
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _finishGame();
      }
    });
  }

  void _generateNextQuestion() {
    final ops = ['+', '−', '×', '>'];
    final op = ops[_random.nextInt(ops.length)];
    final a = _random.nextInt(30) + 2;
    final b = _random.nextInt(20) + 2;

    int realAnswer;
    bool isTrue;

    switch (op) {
      case '+':
        realAnswer = a + b;
        isTrue = _random.nextBool();
        final displayed = isTrue ? realAnswer : realAnswer + (_random.nextBool() ? 1 : -1) * (_random.nextInt(4) + 1);
        _currentQuestion = _SnapQuestion(
          text: '$a + $b = $displayed',
          isTrue: displayed == realAnswer,
        );
        break;
      case '−':
        final bigger = a > b ? a : b + 5;
        final smaller = a > b ? b : a;
        realAnswer = bigger - smaller;
        isTrue = _random.nextBool();
        final displayed = isTrue ? realAnswer : (realAnswer + (_random.nextBool() ? 1 : -1) * (_random.nextInt(3) + 1)).clamp(0, 999);
        _currentQuestion = _SnapQuestion(
          text: '$bigger − $smaller = $displayed',
          isTrue: displayed == realAnswer,
        );
        break;
      case '×':
        final ma = _random.nextInt(10) + 2;
        final mb = _random.nextInt(9) + 2;
        realAnswer = ma * mb;
        isTrue = _random.nextBool();
        final displayed = isTrue ? realAnswer : realAnswer + (_random.nextBool() ? 2 : -2) * (_random.nextInt(3) + 1);
        _currentQuestion = _SnapQuestion(
          text: '$ma × $mb = $displayed',
          isTrue: displayed == realAnswer,
        );
        break;
      default:
        isTrue = a > b;
        _currentQuestion = _SnapQuestion(
          text: '$a > $b',
          isTrue: isTrue,
        );
        break;
    }
  }

  void _answer(bool userChoice) {
    if (_feedbackShowing) return;

    final isCorrect = userChoice == _currentQuestion.isTrue;

    setState(() {
      _feedbackShowing = true;
      _lastAnswerCorrect = isCorrect;
      if (isCorrect) {
        _correct++;
        _streak++;
        if (_streak > _bestStreak) _bestStreak = _streak;
        final multiplier = (_streak ~/ 3) + 1;
        _score += 10 * multiplier;
      } else {
        _wrong++;
        _streak = 0;
      }
    });

    Future.delayed(const Duration(milliseconds: 220), () {
      if (!mounted) return;
      setState(() {
        _feedbackShowing = false;
        _generateNextQuestion();
      });
    });
  }

  void _finishGame() {
    _gameTimer?.cancel();
    final total = _correct + _wrong;
    final accuracy = total > 0 ? _correct / total : 0.0;
    final isPb = _score > StorageService.getPersonalBest('mind_snap');

    final result = GameResult(
      gameId: DateTime.now().millisecondsSinceEpoch.toString(),
      gameType: 'mind_snap',
      difficulty: Difficulty.medium,
      score: _score,
      totalQuestions: total,
      correctAnswers: _correct,
      incorrectAnswers: _wrong,
      accuracy: accuracy,
      avgResponseTimeMs: 0,
      bestStreakCount: _bestStreak,
      totalTime: const Duration(seconds: _gameDurationSeconds),
      answers: [],
      questions: [],
      isPersonalBest: isPb,
      completedAt: DateTime.now(),
    );

    StorageService.setTotalGames(StorageService.totalGames + 1);
    if (isPb) StorageService.setPersonalBest('mind_snap', _score);

    Navigator.of(context).pushReplacementNamed('/results', arguments: result);
  }

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.primaryText),
          onPressed: () {
            _gameTimer?.cancel();
            Navigator.of(context).pop();
          },
        ),
        title: Text('Mind Snap Reflex', style: AppTypography.heading4),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // ─── Top Stats: Timer & Score ───
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GameTimer(
                    seconds: _secondsRemaining,
                    maxSeconds: _gameDurationSeconds,
                    color: _secondsRemaining <= 10 ? AppColors.error : AppColors.warning,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: Text(
                      'Score: $_score',
                      style: AppTypography.monoBody.copyWith(
                        color: AppColors.primaryAccent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ─── Streak / Fever Pill ───
              if (_streak > 2)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: AppColors.accentGradient,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '⚡ FEVER x${(_streak ~/ 3) + 1} MULTIPLIER! ($_streak streak)',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.primaryBg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                )
              else
                Text(
                  'Verify the statement before time expires!',
                  style: AppTypography.bodySmall,
                ),

              const Spacer(),

              // ─── Main Statement Display ───
              AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                decoration: BoxDecoration(
                  color: _feedbackShowing
                      ? (_lastAnswerCorrect
                          ? AppColors.success.withOpacity(0.2)
                          : AppColors.error.withOpacity(0.2))
                      : AppColors.cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: _feedbackShowing
                        ? (_lastAnswerCorrect ? AppColors.success : AppColors.error)
                        : AppColors.divider,
                    width: 2.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    _currentQuestion.text,
                    style: AppTypography.monoLarge.copyWith(fontSize: 44),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),

              const Spacer(),

              // ─── Large True / False Buttons ───
              Row(
                children: [
                  // False Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _answer(false),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.error, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.error.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.close_rounded, size: 40, color: AppColors.error),
                            const SizedBox(height: 6),
                            Text(
                              'FALSE',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 16),

                  // True Button
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _answer(true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.success, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.success.withOpacity(0.2),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Icon(Icons.check_rounded, size: 40, color: AppColors.success),
                            const SizedBox(height: 6),
                            Text(
                              'TRUE',
                              style: AppTypography.labelLarge.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _SnapQuestion {
  final String text;
  final bool isTrue;

  _SnapQuestion({required this.text, required this.isTrue});
}
