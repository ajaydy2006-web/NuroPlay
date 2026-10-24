import 'package:flutter/material.dart';

/// Difficulty levels for all game modes
enum Difficulty { easy, medium, hard, expert }

extension DifficultyExtension on Difficulty {
  String get label {
    switch (this) {
      case Difficulty.easy: return 'Easy';
      case Difficulty.medium: return 'Medium';
      case Difficulty.hard: return 'Hard';
      case Difficulty.expert: return 'Expert';
    }
  }

  Color get color {
    switch (this) {
      case Difficulty.easy: return const Color(0xFF4ADE80);
      case Difficulty.medium: return const Color(0xFFFFC857);
      case Difficulty.hard: return const Color(0xFFFF647C);
      case Difficulty.expert: return const Color(0xFF8A7CFF);
    }
  }

  IconData get icon {
    switch (this) {
      case Difficulty.easy: return Icons.sentiment_satisfied_rounded;
      case Difficulty.medium: return Icons.trending_up_rounded;
      case Difficulty.hard: return Icons.local_fire_department_rounded;
      case Difficulty.expert: return Icons.diamond_rounded;
    }
  }
}

/// Arithmetic operations
enum MathOperation { addition, subtraction, multiplication, division, mixed }

extension MathOperationExtension on MathOperation {
  String get symbol {
    switch (this) {
      case MathOperation.addition: return '+';
      case MathOperation.subtraction: return '−';
      case MathOperation.multiplication: return '×';
      case MathOperation.division: return '÷';
      case MathOperation.mixed: return '?';
    }
  }

  String get label {
    switch (this) {
      case MathOperation.addition: return 'Addition';
      case MathOperation.subtraction: return 'Subtraction';
      case MathOperation.multiplication: return 'Multiplication';
      case MathOperation.division: return 'Division';
      case MathOperation.mixed: return 'Mixed';
    }
  }
}

/// A single math question
class MathQuestion {
  final int id;
  final int operand1;
  final int operand2;
  final MathOperation operation;
  final int correctAnswer;
  final List<int> options;

  const MathQuestion({
    required this.id,
    required this.operand1,
    required this.operand2,
    required this.operation,
    required this.correctAnswer,
    required this.options,
  });

  String get questionText {
    return '$operand1 ${operation.symbol} $operand2 = ?';
  }
}

/// Player's answer to a question
class PlayerAnswer {
  final int questionId;
  final int? selectedAnswer;
  final bool isCorrect;
  final int responseTimeMs;
  final DateTime answeredAt;

  const PlayerAnswer({
    required this.questionId,
    required this.selectedAnswer,
    required this.isCorrect,
    required this.responseTimeMs,
    required this.answeredAt,
  });
}

/// Game session result
class GameResult {
  final String gameId;
  final String gameType;
  final Difficulty difficulty;
  final int score;
  final int totalQuestions;
  final int correctAnswers;
  final int incorrectAnswers;
  final double accuracy;
  final int avgResponseTimeMs;
  final int bestStreakCount;
  final Duration totalTime;
  final List<PlayerAnswer> answers;
  final List<MathQuestion> questions;
  final bool isPersonalBest;
  final int? ratingChange;
  final DateTime completedAt;
  // Duel-specific
  final int? opponentScore;
  final String? opponentName;
  final bool? isDuelWin;

  const GameResult({
    required this.gameId,
    required this.gameType,
    required this.difficulty,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.incorrectAnswers,
    required this.accuracy,
    required this.avgResponseTimeMs,
    required this.bestStreakCount,
    required this.totalTime,
    required this.answers,
    required this.questions,
    required this.isPersonalBest,
    this.ratingChange,
    required this.completedAt,
    this.opponentScore,
    this.opponentName,
    this.isDuelWin,
  });
}

/// Player profile model
class PlayerProfile {
  final String id;
  final String username;
  final String? avatarEmoji;
  final int rating;
  final int rank;
  final int xp;
  final int level;
  final int totalGames;
  final int wins;
  final int losses;
  final int draws;
  final double winRate;
  final int currentStreak;
  final int bestStreak;
  final double mathAccuracy;
  final int avgResponseTimeMs;
  final List<String> achievements;
  final DateTime joinedAt;
  final DateTime lastActiveAt;

  PlayerProfile({
    required this.id,
    required this.username,
    this.avatarEmoji,
    this.rating = 1000,
    this.rank = 0,
    this.xp = 0,
    this.level = 1,
    this.totalGames = 0,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.winRate = 0.0,
    this.currentStreak = 0,
    this.bestStreak = 0,
    this.mathAccuracy = 0.0,
    this.avgResponseTimeMs = 0,
    this.achievements = const [],
    required this.joinedAt,
    required this.lastActiveAt,
  });

  PlayerProfile copyWith({
    String? username,
    String? avatarEmoji,
    int? rating,
    int? rank,
    int? xp,
    int? level,
    int? totalGames,
    int? wins,
    int? losses,
    int? draws,
    double? winRate,
    int? currentStreak,
    int? bestStreak,
    double? mathAccuracy,
    int? avgResponseTimeMs,
    List<String>? achievements,
    DateTime? lastActiveAt,
  }) {
    return PlayerProfile(
      id: id,
      username: username ?? this.username,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      rating: rating ?? this.rating,
      rank: rank ?? this.rank,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      totalGames: totalGames ?? this.totalGames,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      winRate: winRate ?? this.winRate,
      currentStreak: currentStreak ?? this.currentStreak,
      bestStreak: bestStreak ?? this.bestStreak,
      mathAccuracy: mathAccuracy ?? this.mathAccuracy,
      avgResponseTimeMs: avgResponseTimeMs ?? this.avgResponseTimeMs,
      achievements: achievements ?? this.achievements,
      joinedAt: joinedAt,
      lastActiveAt: lastActiveAt ?? this.lastActiveAt,
    );
  }
}

/// Leaderboard entry
class LeaderboardEntry {
  final int rank;
  final String username;
  final String? avatarEmoji;
  final int rating;
  final int wins;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.rank,
    required this.username,
    this.avatarEmoji,
    required this.rating,
    required this.wins,
    this.isCurrentUser = false,
  });
}

/// Achievement definition
class Achievement {
  final String id;
  final String title;
  final String description;
  final String icon;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;
  final double progress;
  final int target;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
    this.progress = 0.0,
    this.target = 1,
  });
}

/// Daily challenge model
class DailyChallenge {
  final String id;
  final String title;
  final String description;
  final String type; // math, memory, logic, mixed
  final Difficulty difficulty;
  final int totalQuestions;
  final int xpReward;
  final bool isCompleted;
  final int? score;
  final DateTime date;

  const DailyChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.totalQuestions,
    required this.xpReward,
    this.isCompleted = false,
    this.score,
    required this.date,
  });
}

/// Memory game sequence item
class MemorySequence {
  final List<int> numbers;
  final int displayTimeMs;
  final int level;

  const MemorySequence({
    required this.numbers,
    required this.displayTimeMs,
    required this.level,
  });
}

/// Logic puzzle
class LogicPuzzle {
  final String id;
  final String type; // sequence, missing_number, pattern, grid
  final String question;
  final List<dynamic> sequence;
  final dynamic correctAnswer;
  final List<dynamic> options;
  final String? hint;
  final String explanation;
  final Difficulty difficulty;

  const LogicPuzzle({
    required this.id,
    required this.type,
    required this.question,
    required this.sequence,
    required this.correctAnswer,
    required this.options,
    this.hint,
    required this.explanation,
    required this.difficulty,
  });
}
