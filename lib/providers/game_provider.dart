import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/game_models.dart';
import '../services/storage_service.dart';
import '../services/question_generator.dart';

/// Central state management for the entire app
class GameProvider extends ChangeNotifier {
  // Player profile
  late PlayerProfile _profile;
  PlayerProfile get profile => _profile;

  // Game state
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  List<MathQuestion> _currentQuestions = [];
  List<MathQuestion> get currentQuestions => _currentQuestions;

  int _currentQuestionIndex = 0;
  int get currentQuestionIndex => _currentQuestionIndex;

  MathQuestion? get currentQuestion =>
      _currentQuestions.isNotEmpty && _currentQuestionIndex < _currentQuestions.length
          ? _currentQuestions[_currentQuestionIndex]
          : null;

  int _score = 0;
  int get score => _score;

  int _correctCount = 0;
  int get correctCount => _correctCount;

  int _incorrectCount = 0;
  int get incorrectCount => _incorrectCount;

  int _currentStreakCount = 0;
  int get currentStreakCount => _currentStreakCount;

  int _bestGameStreak = 0;
  int get bestGameStreak => _bestGameStreak;

  List<PlayerAnswer> _answers = [];
  List<PlayerAnswer> get answers => _answers;

  Difficulty _selectedDifficulty = Difficulty.medium;
  Difficulty get selectedDifficulty => _selectedDifficulty;

  // Bot opponent (duel)
  int _botScore = 0;
  int get botScore => _botScore;
  String _botName = 'MindBot';
  String get botName => _botName;

  // Daily challenge
  bool _dailyChallengeCompleted = false;
  bool get dailyChallengeCompleted => _dailyChallengeCompleted;

  int _dailyStreak = 0;
  int get dailyStreak => _dailyStreak;

  // Workout
  bool _workoutCompleted = false;
  bool get workoutCompleted => _workoutCompleted;

  // Game history
  List<GameResult> _recentResults = [];
  List<GameResult> get recentResults => _recentResults;

  // Achievements
  List<Achievement> _achievements = [];
  List<Achievement> get achievements => _achievements;

  // Memory game state
  MemorySequence? _currentMemorySequence;
  MemorySequence? get currentMemorySequence => _currentMemorySequence;
  int _memoryLevel = 1;
  int get memoryLevel => _memoryLevel;
  int _memoryScore = 0;
  int get memoryScore => _memoryScore;

  // Logic puzzle state
  List<LogicPuzzle> _currentPuzzles = [];
  List<LogicPuzzle> get currentPuzzles => _currentPuzzles;
  int _puzzleIndex = 0;
  int get puzzleIndex => _puzzleIndex;
  int _puzzleScore = 0;
  int get puzzleScore => _puzzleScore;

  // Navigation
  int _bottomNavIndex = 0;
  int get bottomNavIndex => _bottomNavIndex;

  void setBottomNavIndex(int index) {
    _bottomNavIndex = index;
    notifyListeners();
  }

  /// Initialize provider with stored data
  Future<void> init() async {
    await StorageService.init();
    _loadProfile();
    _loadDailyState();
    _initAchievements();
    notifyListeners();
  }

  void _loadProfile() {
    _profile = PlayerProfile(
      id: 'local_user',
      username: StorageService.username,
      avatarEmoji: StorageService.avatarEmoji,
      rating: StorageService.rating,
      xp: StorageService.xp,
      level: _calculateLevel(StorageService.xp),
      totalGames: StorageService.totalGames,
      wins: StorageService.totalWins,
      losses: StorageService.totalLosses,
      winRate: StorageService.totalGames > 0
          ? StorageService.totalWins / StorageService.totalGames
          : 0.0,
      currentStreak: StorageService.currentStreak,
      bestStreak: StorageService.bestStreak,
      mathAccuracy: StorageService.mathAccuracy,
      avgResponseTimeMs: StorageService.avgResponseTime,
      achievements: StorageService.unlockedAchievements,
      joinedAt: DateTime.now(),
      lastActiveAt: DateTime.now(),
    );
  }

  void _loadDailyState() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    if (StorageService.lastDailyChallengeDate != today) {
      _dailyChallengeCompleted = false;
    } else {
      _dailyChallengeCompleted = StorageService.dailyChallengeCompleted;
    }
    _dailyStreak = StorageService.dailyStreak;

    if (StorageService.lastWorkoutDate != today) {
      _workoutCompleted = false;
    } else {
      _workoutCompleted = StorageService.workoutCompleted;
    }
  }

  int _calculateLevel(int xp) {
    // Each level requires progressively more XP
    int level = 1;
    int required = 100;
    int total = 0;
    while (total + required <= xp) {
      total += required;
      level++;
      required = (required * 1.2).toInt();
    }
    return level;
  }

  int get xpForNextLevel {
    int required = 100;
    int total = 0;
    for (int i = 1; i < _profile.level; i++) {
      total += required;
      required = (required * 1.2).toInt();
    }
    return total + required;
  }

  double get levelProgress {
    int required = 100;
    int total = 0;
    for (int i = 1; i < _profile.level; i++) {
      total += required;
      required = (required * 1.2).toInt();
    }
    final progress = (_profile.xp - total) / required;
    return progress.clamp(0.0, 1.0);
  }

  void setDifficulty(Difficulty d) {
    _selectedDifficulty = d;
    notifyListeners();
  }

  // ─── MATH DUEL ───────────────────────────────────────────────

  /// Start a new math duel game
  void startDuel({int questionCount = 10}) {
    _isPlaying = true;
    _score = 0;
    _botScore = 0;
    _correctCount = 0;
    _incorrectCount = 0;
    _currentStreakCount = 0;
    _bestGameStreak = 0;
    _currentQuestionIndex = 0;
    _answers = [];
    _botName = _generateBotName();

    _currentQuestions = QuestionGenerator.generateQuestions(
      count: questionCount,
      difficulty: _selectedDifficulty,
    );

    notifyListeners();
  }

  String _generateBotName() {
    final names = [
      'MindBot', 'CalcuBot', 'MathWiz', 'BrainAI',
      'NumBot', 'QuickCalc', 'ThinkBot', 'LogicAI',
    ];
    names.shuffle();
    return names.first;
  }

  /// Submit answer for current question
  GameResult? submitAnswer(int selectedAnswer) {
    if (!_isPlaying || currentQuestion == null) return null;

    final question = currentQuestion!;
    final isCorrect = selectedAnswer == question.correctAnswer;

    final answer = PlayerAnswer(
      questionId: question.id,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
      responseTimeMs: 2000 + (500 * _currentQuestionIndex), // Simulated
      answeredAt: DateTime.now(),
    );

    _answers.add(answer);

    if (isCorrect) {
      _correctCount++;
      _currentStreakCount++;
      if (_currentStreakCount > _bestGameStreak) {
        _bestGameStreak = _currentStreakCount;
      }
      // Score: base points + streak bonus + speed bonus
      final basePoints = _selectedDifficulty == Difficulty.easy ? 10
          : _selectedDifficulty == Difficulty.medium ? 15
          : _selectedDifficulty == Difficulty.hard ? 25
          : 40;
      final streakBonus = _currentStreakCount > 1 ? (_currentStreakCount - 1) * 5 : 0;
      _score += basePoints + streakBonus;
    } else {
      _currentStreakCount = 0;
      _incorrectCount++;
    }

    // Bot answer simulation
    _simulateBotAnswer(question);

    _currentQuestionIndex++;

    if (_currentQuestionIndex >= _currentQuestions.length) {
      return _finishDuel();
    }

    notifyListeners();
    return null;
  }

  void _simulateBotAnswer(MathQuestion question) {
    // Bot accuracy based on difficulty
    final botAccuracy = _selectedDifficulty == Difficulty.easy ? 0.6
        : _selectedDifficulty == Difficulty.medium ? 0.7
        : _selectedDifficulty == Difficulty.hard ? 0.8
        : 0.85;

    final rand = DateTime.now().microsecondsSinceEpoch % 100 / 100.0;
    if (rand < botAccuracy) {
      final basePoints = _selectedDifficulty == Difficulty.easy ? 10
          : _selectedDifficulty == Difficulty.medium ? 15
          : _selectedDifficulty == Difficulty.hard ? 25
          : 40;
      _botScore += basePoints;
    }
  }

  GameResult _finishDuel() {
    _isPlaying = false;

    final totalTime = _answers.fold<int>(0, (sum, a) => sum + a.responseTimeMs);
    final accuracy = _currentQuestions.isNotEmpty
        ? _correctCount / _currentQuestions.length
        : 0.0;
    final avgTime = _answers.isNotEmpty
        ? totalTime ~/ _answers.length
        : 0;

    final isDuelWin = _score > _botScore;
    final isDraw = _score == _botScore;

    // Rating change
    final ratingChange = isDuelWin ? 25 : (isDraw ? 0 : -15);
    final isPersonalBest = _score > StorageService.getPersonalBest('duel');

    final result = GameResult(
      gameId: DateTime.now().millisecondsSinceEpoch.toString(),
      gameType: 'duel',
      difficulty: _selectedDifficulty,
      score: _score,
      totalQuestions: _currentQuestions.length,
      correctAnswers: _correctCount,
      incorrectAnswers: _incorrectCount,
      accuracy: accuracy,
      avgResponseTimeMs: avgTime,
      bestStreakCount: _bestGameStreak,
      totalTime: Duration(milliseconds: totalTime),
      answers: _answers,
      questions: _currentQuestions,
      isPersonalBest: isPersonalBest,
      ratingChange: ratingChange,
      completedAt: DateTime.now(),
      opponentScore: _botScore,
      opponentName: '$_botName (Bot)',
      isDuelWin: isDuelWin,
    );

    _updateStats(result);
    _recentResults.insert(0, result);
    if (_recentResults.length > 20) _recentResults.removeLast();

    notifyListeners();
    return result;
  }

  // ─── SOLO PRACTICE ──────────────────────────────────────────

  void startSoloPractice({int questionCount = 15}) {
    _isPlaying = true;
    _score = 0;
    _correctCount = 0;
    _incorrectCount = 0;
    _currentStreakCount = 0;
    _bestGameStreak = 0;
    _currentQuestionIndex = 0;
    _answers = [];

    _currentQuestions = QuestionGenerator.generateQuestions(
      count: questionCount,
      difficulty: _selectedDifficulty,
    );

    notifyListeners();
  }

  GameResult? submitSoloAnswer(int selectedAnswer) {
    if (!_isPlaying || currentQuestion == null) return null;

    final question = currentQuestion!;
    final isCorrect = selectedAnswer == question.correctAnswer;

    final answer = PlayerAnswer(
      questionId: question.id,
      selectedAnswer: selectedAnswer,
      isCorrect: isCorrect,
      responseTimeMs: 1500 + (300 * _currentQuestionIndex),
      answeredAt: DateTime.now(),
    );

    _answers.add(answer);

    if (isCorrect) {
      _correctCount++;
      _currentStreakCount++;
      if (_currentStreakCount > _bestGameStreak) {
        _bestGameStreak = _currentStreakCount;
      }
      final basePoints = _selectedDifficulty == Difficulty.easy ? 10
          : _selectedDifficulty == Difficulty.medium ? 15
          : _selectedDifficulty == Difficulty.hard ? 25
          : 40;
      _score += basePoints + (_currentStreakCount > 1 ? (_currentStreakCount - 1) * 3 : 0);
    } else {
      _currentStreakCount = 0;
      _incorrectCount++;
    }

    _currentQuestionIndex++;

    if (_currentQuestionIndex >= _currentQuestions.length) {
      return _finishSolo();
    }

    notifyListeners();
    return null;
  }

  GameResult _finishSolo() {
    _isPlaying = false;
    final totalTime = _answers.fold<int>(0, (sum, a) => sum + a.responseTimeMs);
    final accuracy = _currentQuestions.isNotEmpty
        ? _correctCount / _currentQuestions.length
        : 0.0;
    final avgTime = _answers.isNotEmpty ? totalTime ~/ _answers.length : 0;
    final isPersonalBest = _score > StorageService.getPersonalBest('solo_math');

    final result = GameResult(
      gameId: DateTime.now().millisecondsSinceEpoch.toString(),
      gameType: 'solo_math',
      difficulty: _selectedDifficulty,
      score: _score,
      totalQuestions: _currentQuestions.length,
      correctAnswers: _correctCount,
      incorrectAnswers: _incorrectCount,
      accuracy: accuracy,
      avgResponseTimeMs: avgTime,
      bestStreakCount: _bestGameStreak,
      totalTime: Duration(milliseconds: totalTime),
      answers: _answers,
      questions: _currentQuestions,
      isPersonalBest: isPersonalBest,
      completedAt: DateTime.now(),
    );

    _updateStats(result);
    _recentResults.insert(0, result);
    if (_recentResults.length > 20) _recentResults.removeLast();

    notifyListeners();
    return result;
  }

  // ─── MEMORY GAME ────────────────────────────────────────────

  void startMemoryGame() {
    _isPlaying = true;
    _memoryLevel = 1;
    _memoryScore = 0;
    _correctCount = 0;
    _incorrectCount = 0;
    _answers = [];
    _generateNextMemorySequence();
    notifyListeners();
  }

  void _generateNextMemorySequence() {
    _currentMemorySequence = QuestionGenerator.generateMemorySequence(
      _memoryLevel,
      _selectedDifficulty,
    );
  }

  bool checkMemoryAnswer(List<int> userSequence) {
    if (_currentMemorySequence == null) return false;

    final correct = _currentMemorySequence!.numbers;
    bool isCorrect = userSequence.length == correct.length;
    if (isCorrect) {
      for (int i = 0; i < correct.length; i++) {
        if (userSequence[i] != correct[i]) {
          isCorrect = false;
          break;
        }
      }
    }

    if (isCorrect) {
      _correctCount++;
      _memoryScore += _memoryLevel * 10;
      _memoryLevel++;
      _generateNextMemorySequence();
    } else {
      _incorrectCount++;
    }

    notifyListeners();
    return isCorrect;
  }

  GameResult finishMemoryGame() {
    _isPlaying = false;
    final accuracy = (_correctCount + _incorrectCount) > 0
        ? _correctCount / (_correctCount + _incorrectCount)
        : 0.0;
    final isPersonalBest = _memoryScore > StorageService.getPersonalBest('memory');

    final result = GameResult(
      gameId: DateTime.now().millisecondsSinceEpoch.toString(),
      gameType: 'memory',
      difficulty: _selectedDifficulty,
      score: _memoryScore,
      totalQuestions: _correctCount + _incorrectCount,
      correctAnswers: _correctCount,
      incorrectAnswers: _incorrectCount,
      accuracy: accuracy,
      avgResponseTimeMs: 0,
      bestStreakCount: _memoryLevel - 1,
      totalTime: Duration.zero,
      answers: [],
      questions: [],
      isPersonalBest: isPersonalBest,
      completedAt: DateTime.now(),
    );

    _updateStats(result);
    _recentResults.insert(0, result);
    notifyListeners();
    return result;
  }

  // ─── LOGIC PUZZLES ──────────────────────────────────────────

  void startLogicPuzzles({int count = 10}) {
    _isPlaying = true;
    _puzzleIndex = 0;
    _puzzleScore = 0;
    _correctCount = 0;
    _incorrectCount = 0;
    _answers = [];

    _currentPuzzles = [];
    for (int i = 0; i < count; i++) {
      if (i % 2 == 0) {
        _currentPuzzles.add(
          QuestionGenerator.generateSequencePuzzle(i, _selectedDifficulty),
        );
      } else {
        _currentPuzzles.add(
          QuestionGenerator.generateMissingNumberPuzzle(i, _selectedDifficulty),
        );
      }
    }

    notifyListeners();
  }

  LogicPuzzle? get currentPuzzle =>
      _currentPuzzles.isNotEmpty && _puzzleIndex < _currentPuzzles.length
          ? _currentPuzzles[_puzzleIndex]
          : null;

  GameResult? submitPuzzleAnswer(dynamic selectedAnswer) {
    if (!_isPlaying || currentPuzzle == null) return null;

    final puzzle = currentPuzzle!;
    final isCorrect = selectedAnswer == puzzle.correctAnswer;

    if (isCorrect) {
      _correctCount++;
      _puzzleScore += 20;
    } else {
      _incorrectCount++;
    }

    _puzzleIndex++;

    if (_puzzleIndex >= _currentPuzzles.length) {
      return _finishLogicPuzzles();
    }

    notifyListeners();
    return null;
  }

  GameResult _finishLogicPuzzles() {
    _isPlaying = false;
    final accuracy = _currentPuzzles.isNotEmpty
        ? _correctCount / _currentPuzzles.length
        : 0.0;
    final isPersonalBest = _puzzleScore > StorageService.getPersonalBest('logic');

    final result = GameResult(
      gameId: DateTime.now().millisecondsSinceEpoch.toString(),
      gameType: 'logic',
      difficulty: _selectedDifficulty,
      score: _puzzleScore,
      totalQuestions: _currentPuzzles.length,
      correctAnswers: _correctCount,
      incorrectAnswers: _incorrectCount,
      accuracy: accuracy,
      avgResponseTimeMs: 0,
      bestStreakCount: 0,
      totalTime: Duration.zero,
      answers: [],
      questions: [],
      isPersonalBest: isPersonalBest,
      completedAt: DateTime.now(),
    );

    _updateStats(result);
    _recentResults.insert(0, result);
    notifyListeners();
    return result;
  }

  // ─── DAILY CHALLENGE ────────────────────────────────────────

  DailyChallenge getTodaysChallenge() {
    final today = DateTime.now();
    // Deterministic daily challenge based on date
    final seed = today.year * 10000 + today.month * 100 + today.day;
    final types = ['math', 'memory', 'logic', 'mixed'];
    final type = types[seed % types.length];

    return DailyChallenge(
      id: 'daily_$seed',
      title: 'Daily ${type == 'math' ? 'Math' : type == 'memory' ? 'Memory' : type == 'logic' ? 'Logic' : 'Mixed'} Challenge',
      description: 'Complete today\'s challenge to maintain your streak!',
      type: type,
      difficulty: Difficulty.medium,
      totalQuestions: 10,
      xpReward: 50,
      isCompleted: _dailyChallengeCompleted,
      date: today,
    );
  }

  Future<void> completeDailyChallenge(int score) async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final yesterday = DateFormat('yyyy-MM-dd')
        .format(DateTime.now().subtract(const Duration(days: 1)));

    _dailyChallengeCompleted = true;

    // Update streak
    if (StorageService.lastDailyChallengeDate == yesterday ||
        StorageService.lastDailyChallengeDate.isEmpty) {
      _dailyStreak++;
    } else if (StorageService.lastDailyChallengeDate != today) {
      _dailyStreak = 1;
    }

    await StorageService.setLastDailyChallengeDate(today);
    await StorageService.setDailyChallengeCompleted(true);
    await StorageService.setDailyStreak(_dailyStreak);

    // Award XP
    await _addXp(50);

    // Check streak achievements
    _checkAchievements();

    notifyListeners();
  }

  // ─── WORKOUT ────────────────────────────────────────────────

  Future<void> completeWorkout() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _workoutCompleted = true;
    await StorageService.setLastWorkoutDate(today);
    await StorageService.setWorkoutCompleted(true);
    await _addXp(75);
    notifyListeners();
  }

  // ─── STATS UPDATE ──────────────────────────────────────────

  Future<void> _updateStats(GameResult result) async {
    // Update total games
    final newTotal = StorageService.totalGames + 1;
    await StorageService.setTotalGames(newTotal);

    // Update wins/losses for duel
    if (result.gameType == 'duel') {
      if (result.isDuelWin == true) {
        await StorageService.setTotalWins(StorageService.totalWins + 1);
        final newStreak = StorageService.currentStreak + 1;
        await StorageService.setCurrentStreak(newStreak);
        if (newStreak > StorageService.bestStreak) {
          await StorageService.setBestStreak(newStreak);
        }
      } else if (result.isDuelWin == false) {
        await StorageService.setTotalLosses(StorageService.totalLosses + 1);
        await StorageService.setCurrentStreak(0);
      }

      // Rating
      final newRating = StorageService.rating + (result.ratingChange ?? 0);
      await StorageService.setRating(newRating.clamp(0, 9999));
    }

    // Update accuracy
    final totalCorrect = StorageService.totalCorrectAnswers + result.correctAnswers;
    await StorageService.setTotalCorrectAnswers(totalCorrect);

    if (result.accuracy > 0) {
      final oldAcc = StorageService.mathAccuracy;
      final newAcc = oldAcc == 0 ? result.accuracy : (oldAcc * 0.8 + result.accuracy * 0.2);
      await StorageService.setMathAccuracy(newAcc);
    }

    if (result.avgResponseTimeMs > 0) {
      final oldTime = StorageService.avgResponseTime;
      final newTime = oldTime == 0
          ? result.avgResponseTimeMs
          : ((oldTime * 0.7 + result.avgResponseTimeMs * 0.3).toInt());
      await StorageService.setAvgResponseTime(newTime);
    }

    // Personal best
    if (result.isPersonalBest) {
      await StorageService.setPersonalBest(result.gameType, result.score);
    }

    // XP
    final xpGain = 10 + (result.correctAnswers * 2) + (result.isPersonalBest ? 20 : 0);
    await _addXp(xpGain);

    // Game history
    await StorageService.addGameToHistory({
      'type': result.gameType,
      'score': result.score,
      'accuracy': result.accuracy,
      'date': result.completedAt.toIso8601String(),
      'difficulty': result.difficulty.name,
      'won': result.isDuelWin,
    });

    _loadProfile();
    _checkAchievements();
  }

  Future<void> _addXp(int amount) async {
    final newXp = StorageService.xp + amount;
    await StorageService.setXp(newXp);
  }

  // ─── ACHIEVEMENTS ──────────────────────────────────────────

  void _initAchievements() {
    final unlocked = StorageService.unlockedAchievements;
    _achievements = [
      Achievement(
        id: 'first_game',
        title: 'First Steps',
        description: 'Complete your first game',
        icon: '🎮',
        xpReward: 50,
        isUnlocked: unlocked.contains('first_game'),
        target: 1,
        progress: StorageService.totalGames >= 1 ? 1.0 : 0.0,
      ),
      Achievement(
        id: 'first_win',
        title: 'First Victory',
        description: 'Win your first duel',
        icon: '🏆',
        xpReward: 100,
        isUnlocked: unlocked.contains('first_win'),
        target: 1,
        progress: StorageService.totalWins >= 1 ? 1.0 : 0.0,
      ),
      Achievement(
        id: 'streak_10',
        title: 'On Fire',
        description: 'Get 10 correct answers in a row',
        icon: '🔥',
        xpReward: 150,
        isUnlocked: unlocked.contains('streak_10'),
        target: 10,
        progress: (StorageService.bestStreak / 10).clamp(0.0, 1.0),
      ),
      Achievement(
        id: 'daily_7',
        title: 'Weekly Warrior',
        description: 'Complete daily challenges for 7 days',
        icon: '📅',
        xpReward: 200,
        isUnlocked: unlocked.contains('daily_7'),
        target: 7,
        progress: (_dailyStreak / 7).clamp(0.0, 1.0),
      ),
      Achievement(
        id: 'games_50',
        title: 'Dedicated Player',
        description: 'Play 50 games',
        icon: '⭐',
        xpReward: 250,
        isUnlocked: unlocked.contains('games_50'),
        target: 50,
        progress: (StorageService.totalGames / 50).clamp(0.0, 1.0),
      ),
      Achievement(
        id: 'accuracy_90',
        title: 'Sharpshooter',
        description: 'Achieve 90% accuracy in a game',
        icon: '🎯',
        xpReward: 150,
        isUnlocked: unlocked.contains('accuracy_90'),
        target: 1,
        progress: StorageService.mathAccuracy >= 0.9 ? 1.0 : StorageService.mathAccuracy / 0.9,
      ),
      Achievement(
        id: 'rating_1500',
        title: 'Rising Star',
        description: 'Reach a rating of 1500',
        icon: '🌟',
        xpReward: 300,
        isUnlocked: unlocked.contains('rating_1500'),
        target: 1500,
        progress: (StorageService.rating / 1500).clamp(0.0, 1.0),
      ),
      Achievement(
        id: 'puzzle_master',
        title: 'Puzzle Master',
        description: 'Complete 100 logic puzzles',
        icon: '🧩',
        xpReward: 250,
        isUnlocked: unlocked.contains('puzzle_master'),
        target: 100,
        progress: 0.0,
      ),
    ];
  }

  Future<void> _checkAchievements() async {
    final unlocked = StorageService.unlockedAchievements;
    bool changed = false;

    for (final achievement in _achievements) {
      if (!achievement.isUnlocked && achievement.progress >= 1.0) {
        unlocked.add(achievement.id);
        changed = true;
        await _addXp(achievement.xpReward);
      }
    }

    if (changed) {
      await StorageService.setUnlockedAchievements(unlocked);
      _initAchievements();
      _loadProfile();
      notifyListeners();
    }
  }

  // ─── PROFILE MANAGEMENT ────────────────────────────────────

  Future<void> updateUsername(String name) async {
    if (name.trim().isEmpty || name.length > 20) return;
    await StorageService.setUsername(name.trim());
    _loadProfile();
    notifyListeners();
  }

  Future<void> updateAvatar(String emoji) async {
    await StorageService.setAvatarEmoji(emoji);
    _loadProfile();
    notifyListeners();
  }

  Future<void> setPreferredDifficulty(Difficulty d) async {
    _selectedDifficulty = d;
    await StorageService.setDifficulty(d.name);
    notifyListeners();
  }

  // ─── AUTH ──────────────────────────────────────────────────

  Future<void> loginAsGuest() async {
    await StorageService.setGuest(true);
    await StorageService.setLoggedIn(true);
    await StorageService.setOnboardingSeen();
    notifyListeners();
  }

  Future<void> login(String username) async {
    await StorageService.setUsername(username);
    await StorageService.setGuest(false);
    await StorageService.setLoggedIn(true);
    await StorageService.setOnboardingSeen();
    _loadProfile();
    notifyListeners();
  }

  Future<void> logout() async {
    await StorageService.setLoggedIn(false);
    await StorageService.setGuest(false);
    notifyListeners();
  }

  // ─── LEADERBOARD ───────────────────────────────────────────

  List<LeaderboardEntry> getLeaderboard({String type = 'global'}) {
    // Generate demo leaderboard with current user included
    final entries = <LeaderboardEntry>[
      LeaderboardEntry(rank: 1, username: 'MathKing', avatarEmoji: '👑', rating: 2150, wins: 342),
      LeaderboardEntry(rank: 2, username: 'BrainStorm', avatarEmoji: '⚡', rating: 2080, wins: 298),
      LeaderboardEntry(rank: 3, username: 'QuickMind', avatarEmoji: '🧠', rating: 1975, wins: 276),
      LeaderboardEntry(rank: 4, username: 'NumNinja', avatarEmoji: '🥷', rating: 1890, wins: 251),
      LeaderboardEntry(rank: 5, username: 'CalcPro', avatarEmoji: '🔢', rating: 1820, wins: 234),
      LeaderboardEntry(rank: 6, username: 'PuzzleMaster', avatarEmoji: '🧩', rating: 1760, wins: 218),
      LeaderboardEntry(rank: 7, username: 'ThinkFast', avatarEmoji: '💨', rating: 1695, wins: 195),
      LeaderboardEntry(rank: 8, username: 'MindRacer', avatarEmoji: '🏎️', rating: 1640, wins: 178),
      LeaderboardEntry(rank: 9, username: 'LogicLord', avatarEmoji: '🎓', rating: 1580, wins: 162),
      LeaderboardEntry(rank: 10, username: 'NumberCrunch', avatarEmoji: '💪', rating: 1520, wins: 145),
    ];

    // Insert current user at their rating position
    final userRating = _profile.rating;
    int userRank = entries.length + 1;
    for (int i = 0; i < entries.length; i++) {
      if (userRating >= entries[i].rating) {
        userRank = entries[i].rank;
        break;
      }
    }

    entries.add(LeaderboardEntry(
      rank: userRank,
      username: _profile.username,
      avatarEmoji: _profile.avatarEmoji,
      rating: _profile.rating,
      wins: _profile.wins,
      isCurrentUser: true,
    ));

    entries.sort((a, b) => b.rating.compareTo(a.rating));
    for (int i = 0; i < entries.length; i++) {
      entries[i] = LeaderboardEntry(
        rank: i + 1,
        username: entries[i].username,
        avatarEmoji: entries[i].avatarEmoji,
        rating: entries[i].rating,
        wins: entries[i].wins,
        isCurrentUser: entries[i].isCurrentUser,
      );
    }

    return entries;
  }

  // ─── CLEANUP ───────────────────────────────────────────────

  void resetGame() {
    _isPlaying = false;
    _currentQuestions = [];
    _currentQuestionIndex = 0;
    _score = 0;
    _botScore = 0;
    _correctCount = 0;
    _incorrectCount = 0;
    _currentStreakCount = 0;
    _bestGameStreak = 0;
    _answers = [];
    _currentPuzzles = [];
    _puzzleIndex = 0;
    _puzzleScore = 0;
    _memoryLevel = 1;
    _memoryScore = 0;
    _currentMemorySequence = null;
    notifyListeners();
  }
}
