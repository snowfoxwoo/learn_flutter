import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:flouriscent_nutrional_app/models/user_metrics.dart';

class FastingRecord {
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final Duration targetDuration;

  FastingRecord({
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.targetDuration,
  });

  // Convert to Map for JSON serialization
  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'targetDuration': targetDuration.inMinutes,
  };

  // Create from Map for JSON deserialization
  factory FastingRecord.fromJson(Map<String, dynamic> json) => FastingRecord(
    date: DateTime.parse(json['date']),
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    targetDuration: Duration(minutes: json['targetDuration']),
  );

  String get formattedPeriod {
    return '${_formatTime(startTime)} - ${_formatTime(endTime)}';
  }

  String get formattedDuration {
    final actualDuration = endTime.difference(startTime);
    final hours = actualDuration.inHours;
    final minutes = actualDuration.inMinutes % 60;
    final targetHours = targetDuration.inHours;
    return '${hours}h ${minutes}m / ${targetHours}h';
  }

  String _formatTime(DateTime time) {
    final hour = time.hour % 12 == 0 ? 12 : time.hour % 12;
    final period = time.hour < 12 ? 'AM' : 'PM';
    return '${hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} $period';
  }
}

class UserMetricsProvider extends ChangeNotifier {
  List<FastingRecord> fastingHistory = [];

  void addToHistory(FastingRecord record) {
    fastingHistory.add(record);
    // You might want to persist this to local storage
    notifyListeners();
  }

  DateTime? get fastingStartTime => _fastingStartTime;
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
  bool _isFasting = false;
  DateTime? _fastingStartTime;
  Timer? _fastingTimer;
  String _selectedPreset = '16-8';

  bool get isLoading => _isLoading;
  bool get isFasting => _isFasting;
  String get selectedPreset => _selectedPreset;

  // Available fasting presets
  final Map<String, Duration> _fastingPresets = {
    '12-12': const Duration(hours: 12),
    '14-10': const Duration(hours: 14),
    '16-8': const Duration(hours: 16),
    '18-6': const Duration(hours: 18),
    '20-4': const Duration(hours: 20),
    '24-0': const Duration(hours: 24),
  };

  Map<String, Duration> get fastingPresets => _fastingPresets;

  UserMetricsProvider() {
    _loadData();
  }

  @override
  void dispose() {
    _fastingTimer?.cancel();
    super.dispose();
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
      _isFasting = prefs.getBool('is_fasting') ?? false;
      _selectedPreset = prefs.getString('selected_preset') ?? '16-8';

      final fastingStartTimeMs = prefs.getInt('fasting_start_time');
      if (fastingStartTimeMs != null) {
        _fastingStartTime = DateTime.fromMillisecondsSinceEpoch(
          fastingStartTimeMs,
        );
      }

      if (metricsJson != null) {
        final Map<String, dynamic> data = json.decode(metricsJson);
        _metrics = UserMetrics.fromJson(data);

        final historyJson = prefs.getString('fasting_history');
        if (historyJson != null) {
          final List<dynamic> historyData = json.decode(historyJson);
          fastingHistory =
              historyData.map((item) => FastingRecord.fromJson(item)).toList();
        }
      }

      // Update fasting goal based on selected preset
      _updateFastingGoalFromPreset();

      // Resume fasting timer if was fasting
      if (_isFasting && _fastingStartTime != null) {
        _startFastingTimer();
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
      await prefs.setBool('is_fasting', _isFasting);
      await prefs.setString('selected_preset', _selectedPreset);

      if (_fastingStartTime != null) {
        await prefs.setInt(
          'fasting_start_time',
          _fastingStartTime!.millisecondsSinceEpoch,
        );
      } else {
        await prefs.remove('fasting_start_time');
      }

      final historyJson = json.encode(
        fastingHistory.map((record) => record.toJson()).toList(),
      );
      await prefs.setString('fasting_history', historyJson);
    } catch (e) {
      debugPrint('Error saving user data: $e');
    }
  }

  // Update fasting goal based on selected preset
  void _updateFastingGoalFromPreset() {
    final goalDuration = _fastingPresets[_selectedPreset];
    if (goalDuration != null) {
      _metrics = _metrics.copyWith(fastingGoal: goalDuration);
    }
  }

  // Set selected fasting preset
  Future<void> setFastingPreset(String preset) async {
    if (_fastingPresets.containsKey(preset)) {
      _selectedPreset = preset;
      _updateFastingGoalFromPreset();
      notifyListeners();
      await _saveData();
    }
  }

  // Start fasting timer
  void _startFastingTimer() {
    _fastingTimer?.cancel();
    _fastingTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_fastingStartTime != null) {
        final currentDuration = DateTime.now().difference(_fastingStartTime!);
        _metrics = _metrics.copyWith(
          fastingTime: currentDuration,
          lastUpdated: DateTime.now(),
        );
        notifyListeners();
        _saveData();
      }
    });
  }

  // Start fasting
  Future<void> startFasting() async {
    _isFasting = true;
    _fastingStartTime = DateTime.now();
    _metrics = _metrics.copyWith(
      fastingTime: const Duration(minutes: 0),
      lastUpdated: DateTime.now(),
    );

    _startFastingTimer();
    notifyListeners();
    await _saveData();
  }

  // Stop fasting
  Future<void> stopFasting() async {
    if (!_isFasting || _fastingStartTime == null) return;

    final endTime = DateTime.now();
    final targetDuration =
        _fastingPresets[_selectedPreset] ?? const Duration(hours: 16);

    // Create and add the new record
    addToHistory(
      FastingRecord(
        date: DateTime.now(),
        startTime: _fastingStartTime!,
        endTime: endTime,
        targetDuration: targetDuration,
      ),
    );

    // Reset fasting state
    _isFasting = false;
    _fastingStartTime = null;
    _fastingTimer?.cancel();
    _fastingTimer = null;

    notifyListeners();
    await _saveData();
  }

  // Add this method to clear history if needed
  Future<void> clearFastingHistory() async {
    fastingHistory.clear();
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('fasting_history');
  }

  // Get next fast start time (for display purposes)
  DateTime getNextFastStartTime() {
    final now = DateTime.now();
    // Assuming next fast starts at 6 AM tomorrow if not currently fasting
    final tomorrow = DateTime(now.year, now.month, now.day + 1, 6, 0);
    return tomorrow;
  }

  // Get formatted next fast time
  String getNextFastTimeFormatted() {
    final nextFast = getNextFastStartTime();
    final now = DateTime.now();

    if (nextFast.day == now.day) {
      return 'Today ${_formatTime(nextFast)}';
    } else {
      return 'Tomorrow ${_formatTime(nextFast)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    return '${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
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
      lastUpdated: DateTime.now(),
    );

    // Don't reset fasting if currently fasting
    if (!_isFasting) {
      _metrics = _metrics.copyWith(fastingTime: const Duration());
    }

    notifyListeners();
    await _saveData();
  }
}
