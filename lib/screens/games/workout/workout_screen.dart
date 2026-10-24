import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../widgets/game/game_widgets.dart';
import '../../../providers/game_provider.dart';
import '../../../models/game_models.dart';
import '../../../services/question_generator.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  int _currentStation = 1; // 1: Math, 2: Memory, 3: Logic
  int _stationQuestionIndex = 0;
  int _totalScore = 0;
  int _totalCorrect = 0;

  // Station 1: Math Questions (5 questions)
  late List<MathQuestion> _mathQuestions;

  // Station 2: Memory Sequence
  late MemorySequence _memorySeq;
  bool _isMemorizing = true;
  final List<int> _memoryInput = [];

  // Station 3: Logic Puzzles (3 questions)
  late List<LogicPuzzle> _logicPuzzles;

  // Feedback states
  dynamic _selectedAnswer;
  bool _showFeedback = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initStations();
  }

  void _initStations() {
    _mathQuestions = QuestionGenerator.generateQuestions(count: 5, difficulty: Difficulty.medium);
    _memorySeq = QuestionGenerator.generateMemorySequence(2, Difficulty.medium);
    _logicPuzzles = [
      QuestionGenerator.generateSequencePuzzle(1, Difficulty.medium),
      QuestionGenerator.generateMissingNumberPuzzle(2, Difficulty.medium),
      QuestionGenerator.generateSequencePuzzle(3, Difficulty.medium),
    ];
  }

  void _onMathAnswer(int answer) {
    if (_isProcessing) return;
    final q = _mathQuestions[_stationQuestionIndex];
    final isCorrect = answer == q.correctAnswer;

    setState(() {
      _isProcessing = true;
      _selectedAnswer = answer;
      _showFeedback = true;
      if (isCorrect) {
        _totalScore += 20;
        _totalCorrect++;
      }
    });

    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      if (_stationQuestionIndex + 1 < _mathQuestions.length) {
        setState(() {
          _stationQuestionIndex++;
          _selectedAnswer = null;
          _showFeedback = false;
          _isProcessing = false;
        });
      } else {
        // Advance to Station 2: Memory
        setState(() {
          _currentStation = 2;
          _stationQuestionIndex = 0;
          _selectedAnswer = null;
          _showFeedback = false;
          _isProcessing = false;
          _isMemorizing = true;
          _memoryInput.clear();
        });

        // Memorize timer for 2.5 seconds
        Future.delayed(const Duration(milliseconds: 2500), () {
          if (mounted && _currentStation == 2) {
            setState(() => _isMemorizing = false);
          }
        });
      }
    });
  }

  void _onMemoryTap(int n) {
    if (_isMemorizing) return;
    if (_memoryInput.length < _memorySeq.numbers.length) {
      setState(() => _memoryInput.add(n));

      if (_memoryInput.length == _memorySeq.numbers.length) {
        bool isCorrect = true;
        for (int i = 0; i < _memorySeq.numbers.length; i++) {
          if (_memoryInput[i] != _memorySeq.numbers[i]) {
            isCorrect = false;
            break;
          }
        }

        if (isCorrect) {
          _totalScore += 40;
          _totalCorrect++;
        }

        // Advance to Station 3: Logic
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          setState(() {
            _currentStation = 3;
            _stationQuestionIndex = 0;
            _selectedAnswer = null;
            _showFeedback = false;
            _isProcessing = false;
          });
        });
      }
    }
  }

  void _onLogicAnswer(dynamic answer) {
    if (_isProcessing) return;
    final p = _logicPuzzles[_stationQuestionIndex];
    final isCorrect = answer == p.correctAnswer;

    setState(() {
      _isProcessing = true;
      _selectedAnswer = answer;
      _showFeedback = true;
      if (isCorrect) {
        _totalScore += 30;
        _totalCorrect++;
      }
    });

    Future.delayed(const Duration(milliseconds: 400), () async {
      if (!mounted) return;

      if (_stationQuestionIndex + 1 < _logicPuzzles.length) {
        setState(() {
          _stationQuestionIndex++;
          _selectedAnswer = null;
          _showFeedback = false;
          _isProcessing = false;
        });
      } else {
        // Completed entire workout!
        final provider = context.read<GameProvider>();
        await provider.completeWorkout();

        final result = GameResult(
          gameId: DateTime.now().millisecondsSinceEpoch.toString(),
          gameType: 'workout',
          difficulty: Difficulty.medium,
          score: _totalScore,
          totalQuestions: 9,
          correctAnswers: _totalCorrect,
          incorrectAnswers: 9 - _totalCorrect,
          accuracy: _totalCorrect / 9,
          avgResponseTimeMs: 1600,
          bestStreakCount: _totalCorrect,
          totalTime: const Duration(minutes: 2),
          answers: [],
          questions: [],
          isPersonalBest: true,
          completedAt: DateTime.now(),
        );

        Navigator.of(context).pushReplacementNamed('/results', arguments: result);
      }
    });
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
        title: Text('5-Minute Brain Workout', style: AppTypography.heading4),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.secondaryAccent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                '$_totalScore pts',
                style: AppTypography.monoCaption.copyWith(
                  color: AppColors.secondaryAccent,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            children: [
              // ─── Circuit Station Tabs ───
              Row(
                children: [
                  _buildStationTab(1, 'Station 1: Math', Icons.calculate_rounded),
                  const SizedBox(width: 8),
                  _buildStationTab(2, 'Station 2: Memory', Icons.psychology_rounded),
                  const SizedBox(width: 8),
                  _buildStationTab(3, 'Station 3: Logic', Icons.extension_rounded),
                ],
              ),

              const SizedBox(height: 20),

              // ─── Active Station UI ───
              Expanded(
                child: _currentStation == 1
                    ? _buildMathStation()
                    : _currentStation == 2
                        ? _buildMemoryStation()
                        : _buildLogicStation(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStationTab(int station, String label, IconData icon) {
    final isActive = _currentStation == station;
    final isDone = _currentStation > station;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primaryAccent.withOpacity(0.15)
              : isDone
                  ? AppColors.success.withOpacity(0.15)
                  : AppColors.cardBg,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.primaryAccent
                : isDone
                    ? AppColors.success
                    : AppColors.divider,
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              isDone ? Icons.check_circle_rounded : icon,
              size: 16,
              color: isActive
                  ? AppColors.primaryAccent
                  : isDone
                      ? AppColors.success
                      : AppColors.secondaryText,
            ),
            const SizedBox(height: 4),
            Text(
              label.split(': ').last,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 10,
                color: isActive ? AppColors.primaryAccent : AppColors.secondaryText,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMathStation() {
    final q = _mathQuestions[_stationQuestionIndex];

    return Column(
      children: [
        QuestionProgress(current: _stationQuestionIndex, total: _mathQuestions.length),
        const Spacer(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _showFeedback
                  ? (_selectedAnswer == q.correctAnswer ? AppColors.success : AppColors.error)
                  : AppColors.divider,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(q.questionText, style: AppTypography.monoLarge.copyWith(fontSize: 40), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Speed Arithmetic Sprint', style: AppTypography.bodySmall),
            ],
          ),
        ),
        const Spacer(),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: q.options.map((opt) {
            final isSelected = _selectedAnswer == opt;
            final isCorrect = opt == q.correctAnswer;
            return AnswerOptionButton(
              label: '$opt',
              isSelected: isSelected,
              isCorrect: isCorrect,
              showResult: _showFeedback,
              onTap: () => _onMathAnswer(opt),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildMemoryStation() {
    final target = _memorySeq.numbers;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: _isMemorizing ? AppColors.warning.withOpacity(0.15) : AppColors.secondaryAccent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            _isMemorizing ? 'Memorize sequence!' : 'Reconstruct the sequence',
            style: AppTypography.labelSmall.copyWith(
              color: _isMemorizing ? AppColors.warning : AppColors.secondaryAccent,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.divider),
          ),
          child: _isMemorizing
              ? Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: target.map((n) {
                    return Container(
                      width: 52,
                      height: 58,
                      decoration: BoxDecoration(
                        gradient: AppColors.purpleGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('$n', style: AppTypography.monoLarge.copyWith(fontSize: 26)),
                      ),
                    );
                  }).toList(),
                )
              : Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: List.generate(target.length, (idx) {
                    final isFilled = idx < _memoryInput.length;
                    return Container(
                      width: 52,
                      height: 58,
                      decoration: BoxDecoration(
                        color: isFilled ? AppColors.elevatedCard : AppColors.primaryBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isFilled ? AppColors.secondaryAccent : AppColors.divider,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          isFilled ? '${_memoryInput[idx]}' : '?',
                          style: AppTypography.monoLarge.copyWith(
                            fontSize: 26,
                            color: isFilled ? AppColors.secondaryAccent : AppColors.secondaryText,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
        ),
        const Spacer(),
        IgnorePointer(
          ignoring: _isMemorizing,
          child: Opacity(
            opacity: _isMemorizing ? 0.3 : 1.0,
            child: GridView.count(
              crossAxisCount: 3,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1.8,
              children: [
                for (int i = 1; i <= 9; i++)
                  Material(
                    color: AppColors.elevatedCard,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: () => _onMemoryTap(i),
                      borderRadius: BorderRadius.circular(12),
                      child: Center(child: Text('$i', style: AppTypography.monoSmall)),
                    ),
                  ),
                Material(
                  color: AppColors.error.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () {
                      if (_memoryInput.isNotEmpty) setState(() => _memoryInput.removeLast());
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: const Center(child: Icon(Icons.backspace_rounded, color: AppColors.error)),
                  ),
                ),
                Material(
                  color: AppColors.elevatedCard,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => _onMemoryTap(0),
                    borderRadius: BorderRadius.circular(12),
                    child: Center(child: Text('0', style: AppTypography.monoSmall)),
                  ),
                ),
                Material(
                  color: AppColors.divider.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: () => setState(() => _memoryInput.clear()),
                    borderRadius: BorderRadius.circular(12),
                    child: Center(child: Text('Clear', style: AppTypography.labelSmall)),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildLogicStation() {
    final p = _logicPuzzles[_stationQuestionIndex];

    return Column(
      children: [
        QuestionProgress(current: _stationQuestionIndex, total: _logicPuzzles.length),
        const Spacer(),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: _showFeedback
                  ? (_selectedAnswer == p.correctAnswer ? AppColors.success : AppColors.error)
                  : AppColors.divider,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              Text(p.question, style: AppTypography.heading4, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              if (p.type == 'sequence')
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    ...p.sequence.map((n) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.elevatedCard,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text('$n', style: AppTypography.monoMedium.copyWith(fontSize: 20)),
                        )),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.success),
                      ),
                      child: Text('?', style: AppTypography.monoMedium.copyWith(fontSize: 20, color: AppColors.success)),
                    ),
                  ],
                )
              else
                Text(p.sequence.first.toString(), style: AppTypography.monoLarge.copyWith(fontSize: 32)),
            ],
          ),
        ),
        const Spacer(),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.8,
          children: p.options.map((opt) {
            final isSelected = _selectedAnswer == opt;
            final isCorrect = opt == p.correctAnswer;
            return AnswerOptionButton(
              label: '$opt',
              isSelected: isSelected,
              isCorrect: isCorrect,
              showResult: _showFeedback,
              onTap: () => _onLogicAnswer(opt),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}
