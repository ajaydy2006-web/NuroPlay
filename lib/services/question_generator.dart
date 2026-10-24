import 'dart:math';
import '../models/game_models.dart';

/// Generates math questions with verified correct answers
class QuestionGenerator {
  static final _random = Random();

  /// Generate a batch of math questions for a game session
  static List<MathQuestion> generateQuestions({
    required int count,
    required Difficulty difficulty,
    MathOperation operation = MathOperation.mixed,
  }) {
    final questions = <MathQuestion>[];
    for (int i = 0; i < count; i++) {
      final op = operation == MathOperation.mixed
          ? MathOperation.values[_random.nextInt(4)]
          : operation;
      questions.add(_generateQuestion(i, difficulty, op));
    }
    return questions;
  }

  static MathQuestion _generateQuestion(int id, Difficulty difficulty, MathOperation op) {
    int a, b, answer;
    final range = _getRange(difficulty);

    switch (op) {
      case MathOperation.addition:
        a = _random.nextInt(range) + 1;
        b = _random.nextInt(range) + 1;
        answer = a + b;
        break;
      case MathOperation.subtraction:
        a = _random.nextInt(range) + range ~/ 2;
        b = _random.nextInt(a) + 1;
        answer = a - b;
        break;
      case MathOperation.multiplication:
        final mRange = _getMulRange(difficulty);
        a = _random.nextInt(mRange) + 2;
        b = _random.nextInt(mRange) + 2;
        answer = a * b;
        break;
      case MathOperation.division:
        final dRange = _getMulRange(difficulty);
        b = _random.nextInt(dRange) + 2;
        answer = _random.nextInt(dRange) + 1;
        a = b * answer; // Ensures clean division
        break;
      case MathOperation.mixed:
        // Should not reach here; handled above
        a = 1; b = 1; answer = 2;
        break;
    }

    final options = _generateOptions(answer, difficulty);

    return MathQuestion(
      id: id,
      operand1: a,
      operand2: b,
      operation: op,
      correctAnswer: answer,
      options: options,
    );
  }

  static int _getRange(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy: return 20;
      case Difficulty.medium: return 50;
      case Difficulty.hard: return 100;
      case Difficulty.expert: return 500;
    }
  }

  static int _getMulRange(Difficulty difficulty) {
    switch (difficulty) {
      case Difficulty.easy: return 10;
      case Difficulty.medium: return 15;
      case Difficulty.hard: return 25;
      case Difficulty.expert: return 50;
    }
  }

  static List<int> _generateOptions(int correct, Difficulty difficulty) {
    final options = <int>{correct};
    final spread = difficulty == Difficulty.easy ? 5
        : difficulty == Difficulty.medium ? 10
        : difficulty == Difficulty.hard ? 20
        : 50;

    while (options.length < 4) {
      int wrong = correct + _random.nextInt(spread * 2 + 1) - spread;
      if (wrong != correct && wrong >= 0) {
        options.add(wrong);
      }
    }

    final list = options.toList();
    list.shuffle(_random);
    return list;
  }

  /// Generate a number sequence puzzle
  static LogicPuzzle generateSequencePuzzle(int id, Difficulty difficulty) {
    final patterns = <Map<String, dynamic>>[];

    // Arithmetic sequences
    final diff = _random.nextInt(difficulty == Difficulty.easy ? 5 : 15) + 2;
    final start = _random.nextInt(20) + 1;
    patterns.add({
      'sequence': List.generate(6, (i) => start + diff * i),
      'explanation': 'Each number increases by $diff',
    });

    // Geometric sequences
    final ratio = _random.nextInt(3) + 2;
    final gStart = _random.nextInt(5) + 1;
    patterns.add({
      'sequence': List.generate(6, (i) => gStart * pow(ratio, i).toInt()),
      'explanation': 'Each number is multiplied by $ratio',
    });

    // Square numbers
    final sStart = _random.nextInt(5) + 1;
    patterns.add({
      'sequence': List.generate(6, (i) => (sStart + i) * (sStart + i)),
      'explanation': 'Square numbers: ${sStart}², ${sStart + 1}², ${sStart + 2}²...',
    });

    final pattern = patterns[_random.nextInt(patterns.length)];
    final seq = pattern['sequence'] as List<int>;
    final answerIndex = seq.length - 1;
    final answer = seq[answerIndex];

    final visibleSeq = List<int>.from(seq.sublist(0, answerIndex));
    final opts = _generateOptions(answer, difficulty);

    return LogicPuzzle(
      id: 'seq_$id',
      type: 'sequence',
      question: 'What comes next in the sequence?',
      sequence: visibleSeq,
      correctAnswer: answer,
      options: opts,
      explanation: pattern['explanation'] as String,
      difficulty: difficulty,
      hint: 'Look at the difference between consecutive numbers.',
    );
  }

  /// Generate a missing number puzzle
  static LogicPuzzle generateMissingNumberPuzzle(int id, Difficulty difficulty) {
    // Create equation: a ○ b = c, hide one
    final op = MathOperation.values[_random.nextInt(4)];
    int a, b, c;
    final range = _getRange(difficulty);

    switch (op) {
      case MathOperation.addition:
        a = _random.nextInt(range) + 1;
        b = _random.nextInt(range) + 1;
        c = a + b;
        break;
      case MathOperation.subtraction:
        a = _random.nextInt(range) + range ~/ 2;
        b = _random.nextInt(a) + 1;
        c = a - b;
        break;
      case MathOperation.multiplication:
        final mRange = _getMulRange(difficulty);
        a = _random.nextInt(mRange) + 2;
        b = _random.nextInt(mRange) + 2;
        c = a * b;
        break;
      case MathOperation.division:
        final dRange = _getMulRange(difficulty);
        b = _random.nextInt(dRange) + 2;
        c = _random.nextInt(dRange) + 1;
        a = b * c;
        break;
      default:
        a = 1; b = 1; c = 2;
    }

    // Randomly choose which to hide
    final hideIndex = _random.nextInt(3);
    int answer;
    String question;

    switch (hideIndex) {
      case 0:
        answer = a;
        question = '? ${op.symbol} $b = $c';
        break;
      case 1:
        answer = b;
        question = '$a ${op.symbol} ? = $c';
        break;
      default:
        answer = c;
        question = '$a ${op.symbol} $b = ?';
    }

    return LogicPuzzle(
      id: 'miss_$id',
      type: 'missing_number',
      question: 'Find the missing number:',
      sequence: [question],
      correctAnswer: answer,
      options: _generateOptions(answer, difficulty),
      explanation: '$a ${op.symbol} $b = $c',
      difficulty: difficulty,
    );
  }

  /// Generate a memory sequence
  static MemorySequence generateMemorySequence(int level, Difficulty difficulty) {
    final baseLength = difficulty == Difficulty.easy ? 3
        : difficulty == Difficulty.medium ? 4
        : difficulty == Difficulty.hard ? 5
        : 6;
    final length = baseLength + (level ~/ 2);
    final maxNum = difficulty == Difficulty.easy ? 9
        : difficulty == Difficulty.medium ? 20
        : difficulty == Difficulty.hard ? 50
        : 99;

    final numbers = List.generate(length, (_) => _random.nextInt(maxNum) + 1);
    final displayTime = difficulty == Difficulty.easy ? 3000
        : difficulty == Difficulty.medium ? 2500
        : difficulty == Difficulty.hard ? 2000
        : 1500;

    return MemorySequence(
      numbers: numbers,
      displayTimeMs: displayTime - (level * 100).clamp(0, 1000),
      level: level,
    );
  }
}
