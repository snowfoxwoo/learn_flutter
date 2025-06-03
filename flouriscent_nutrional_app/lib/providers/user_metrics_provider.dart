import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:flouriscent_nutrional_app/models/user_metrics.dart';

class UserMetricsProvider extends ChangeNotifier {
  UserMetrics _metrics = UserMetrics(
    calories: 1160,
    calorieGoal: 2000,
    water: 1.2,
    waterGoal: 2.5,
    fastingTime: const Duration(hours: 12, minutes: 30),
    fastingGoal: const Duration(hours: 16),
    steps: 6200,
    stepGoal: 10000,
    sleep: const Duration(hours: 7, minutes: 45),
    sleepGoal: const Duration(hours: 8),
    mood: 'Happy 😊',
    moodScore: 9.0,
    lastUpdated: DateTime.now(),
  );

  UserMetrics get metrics => _metrics;
  String get userName => _userName;

  String _userName = 'User';
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  UserMetricsProvider() {
    _loadData();
  }

  // Greeting based on time of day
  String getGreeting() {
    final hour = DateTime.now().hour;
    String timeGreeting;

    if (hour < 12) {
      timeGreeting = "Good Morning";
    } else if (hour < 17) {
      timeGreeting = "Good Afternoon";
    } else {
      timeGreeting = "Good Evening";
    }

    return "$timeGreeting, $_userName!";
  }

  // Load data from SharedPreferences
  Future<void> _loadData() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsJson = prefs.getString('user_metrics');
      _userName = prefs.getString('user_name') ?? 'User';

      if (metricsJson != null) {
        final Map<String, dynamic> data = json.decode(metricsJson);
        _metrics = UserMetrics.fromJson(data);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Save data to SharedPreferences
  Future<void> _saveData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final metricsJson = json.encode(_metrics.toJson());
      await prefs.setString('user_metrics', metricsJson);
      await prefs.setString('user_name', _userName);
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  // Update methods
  Future<void> updateCalories(int calories) async {
    _metrics = _metrics.copyWith(
      calories: calories,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveData();
  }

  Future<void> addCalories(int additionalCalories) async {
    _metrics = _metrics.copyWith(
      calories: _metrics.calories + additionalCalories,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveData();
  }

  Future<void> updateWater(double water) async {
    _metrics = _metrics.copyWith(water: water, lastUpdated: DateTime.now());
    notifyListeners();
    await _saveData();
  }

  Future<void> addWater(double additionalWater) async {
    _metrics = _metrics.copyWith(
      water: _metrics.water + additionalWater,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveData();
  }

  Future<void> updateSteps(int steps) async {
    _metrics = _metrics.copyWith(steps: steps, lastUpdated: DateTime.now());
    notifyListeners();
    await _saveData();
  }

  Future<void> updateSleep(Duration sleep) async {
    _metrics = _metrics.copyWith(sleep: sleep, lastUpdated: DateTime.now());
    notifyListeners();
    await _saveData();
  }

  Future<void> updateMood(String mood, double score) async {
    _metrics = _metrics.copyWith(
      mood: mood,
      moodScore: score,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveData();
  }

  Future<void> startFasting() async {
    _metrics = _metrics.copyWith(
      fastingTime: const Duration(minutes: 1), // Just started
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveData();
  }

  Future<void> updateFastingTime(Duration fastingTime) async {
    _metrics = _metrics.copyWith(
      fastingTime: fastingTime,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveData();
  }

  Future<void> setUserName(String name) async {
    _userName = name;
    notifyListeners();
    await _saveData();
  }

  Future<void> updateGoals({
    int? calorieGoal,
    double? waterGoal,
    Duration? fastingGoal,
    int? stepGoal,
    Duration? sleepGoal,
  }) async {
    _metrics = _metrics.copyWith(
      calorieGoal: calorieGoal,
      waterGoal: waterGoal,
      fastingGoal: fastingGoal,
      stepGoal: stepGoal,
      sleepGoal: sleepGoal,
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveData();
  }

  // Reset daily data (call this at midnight)
  Future<void> resetDailyData() async {
    _metrics = _metrics.copyWith(
      calories: 0,
      water: 0.0,
      steps: 0,
      fastingTime: const Duration(),
      lastUpdated: DateTime.now(),
    );
    notifyListeners();
    await _saveData();
  }
}
