import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Local persistence service using SharedPreferences
class StorageService {
  static SharedPreferences? _prefs;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Onboarding
  static bool get hasSeenOnboarding => _prefs?.getBool('has_seen_onboarding') ?? false;
  static Future<void> setOnboardingSeen() => _prefs!.setBool('has_seen_onboarding', true);

  // Auth
  static bool get isLoggedIn => _prefs?.getBool('is_logged_in') ?? false;
  static Future<void> setLoggedIn(bool value) => _prefs!.setBool('is_logged_in', value);

  static bool get isGuest => _prefs?.getBool('is_guest') ?? false;
  static Future<void> setGuest(bool value) => _prefs!.setBool('is_guest', value);

  // Profile
  static String get username => _prefs?.getString('username') ?? 'Player';
  static Future<void> setUsername(String value) => _prefs!.setString('username', value);

  static String get avatarEmoji => _prefs?.getString('avatar_emoji') ?? '🧠';
  static Future<void> setAvatarEmoji(String value) => _prefs!.setString('avatar_emoji', value);

  static String get difficulty => _prefs?.getString('difficulty') ?? 'medium';
  static Future<void> setDifficulty(String value) => _prefs!.setString('difficulty', value);

  // Stats
  static int get totalGames => _prefs?.getInt('total_games') ?? 0;
  static Future<void> setTotalGames(int value) => _prefs!.setInt('total_games', value);

  static int get totalWins => _prefs?.getInt('total_wins') ?? 0;
  static Future<void> setTotalWins(int value) => _prefs!.setInt('total_wins', value);

  static int get totalLosses => _prefs?.getInt('total_losses') ?? 0;
  static Future<void> setTotalLosses(int value) => _prefs!.setInt('total_losses', value);

  static int get currentStreak => _prefs?.getInt('current_streak') ?? 0;
  static Future<void> setCurrentStreak(int value) => _prefs!.setInt('current_streak', value);

  static int get bestStreak => _prefs?.getInt('best_streak') ?? 0;
  static Future<void> setBestStreak(int value) => _prefs!.setInt('best_streak', value);

  static int get rating => _prefs?.getInt('rating') ?? 1000;
  static Future<void> setRating(int value) => _prefs!.setInt('rating', value);

  static int get xp => _prefs?.getInt('xp') ?? 0;
  static Future<void> setXp(int value) => _prefs!.setInt('xp', value);

  static double get mathAccuracy => _prefs?.getDouble('math_accuracy') ?? 0.0;
  static Future<void> setMathAccuracy(double value) => _prefs!.setDouble('math_accuracy', value);

  static int get avgResponseTime => _prefs?.getInt('avg_response_time') ?? 0;
  static Future<void> setAvgResponseTime(int value) => _prefs!.setInt('avg_response_time', value);

  // Daily challenge
  static String get lastDailyChallengeDate => _prefs?.getString('last_daily_date') ?? '';
  static Future<void> setLastDailyChallengeDate(String value) =>
      _prefs!.setString('last_daily_date', value);

  static bool get dailyChallengeCompleted => _prefs?.getBool('daily_completed') ?? false;
  static Future<void> setDailyChallengeCompleted(bool value) =>
      _prefs!.setBool('daily_completed', value);

  static int get dailyStreak => _prefs?.getInt('daily_streak') ?? 0;
  static Future<void> setDailyStreak(int value) => _prefs!.setInt('daily_streak', value);

  // Achievements
  static List<String> get unlockedAchievements {
    final data = _prefs?.getString('achievements') ?? '[]';
    return List<String>.from(json.decode(data));
  }

  static Future<void> setUnlockedAchievements(List<String> value) =>
      _prefs!.setString('achievements', json.encode(value));

  // Game history
  static List<Map<String, dynamic>> get gameHistory {
    final data = _prefs?.getString('game_history') ?? '[]';
    return List<Map<String, dynamic>>.from(json.decode(data));
  }

  static Future<void> addGameToHistory(Map<String, dynamic> game) async {
    final history = gameHistory;
    history.insert(0, game);
    if (history.length > 50) history.removeLast();
    await _prefs!.setString('game_history', json.encode(history));
  }

  // Personal bests
  static int getPersonalBest(String gameType) =>
      _prefs?.getInt('pb_$gameType') ?? 0;

  static Future<void> setPersonalBest(String gameType, int score) =>
      _prefs!.setInt('pb_$gameType', score);

  // Workout
  static String get lastWorkoutDate => _prefs?.getString('last_workout_date') ?? '';
  static Future<void> setLastWorkoutDate(String value) =>
      _prefs!.setString('last_workout_date', value);

  static bool get workoutCompleted => _prefs?.getBool('workout_completed') ?? false;
  static Future<void> setWorkoutCompleted(bool value) =>
      _prefs!.setBool('workout_completed', value);

  // Total correct answers (for achievements)
  static int get totalCorrectAnswers => _prefs?.getInt('total_correct') ?? 0;
  static Future<void> setTotalCorrectAnswers(int value) =>
      _prefs!.setInt('total_correct', value);

  // Total play time in seconds
  static int get totalPlayTime => _prefs?.getInt('total_play_time') ?? 0;
  static Future<void> setTotalPlayTime(int value) =>
      _prefs!.setInt('total_play_time', value);

  // Clear all data
  static Future<void> clearAll() => _prefs!.clear();
}
