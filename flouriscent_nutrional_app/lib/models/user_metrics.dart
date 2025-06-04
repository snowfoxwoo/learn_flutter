import 'package:flutter/foundation.dart';

class UserMetrics {
  final int calories;
  final int calorieGoal;
  final double water;
  final double waterGoal;
  final Duration fastingTime;
  final Duration fastingGoal;
  final int steps;
  final int stepGoal;
  final Duration sleep;
  final Duration sleepGoal;
  final String mood;
  final double moodScore;
  final DateTime lastUpdated;

  UserMetrics({
    required this.calories,
    required this.calorieGoal,
    required this.water,
    required this.waterGoal,
    required this.fastingTime,
    required this.fastingGoal,
    required this.steps,
    required this.stepGoal,
    required this.sleep,
    required this.sleepGoal,
    required this.mood,
    required this.moodScore,
    required this.lastUpdated,
  });

  // Progress calculations
  double get calorieProgress => calories / calorieGoal;
  double get waterProgress => water / waterGoal;
  double get fastingProgress => fastingTime.inMinutes / fastingGoal.inMinutes;
  double get stepProgress => steps / stepGoal;
  double get sleepProgress => sleep.inMinutes / sleepGoal.inMinutes;
  double get moodProgress => moodScore / 10.0;

  // Helper methods
  bool get isFasting => fastingTime.inHours > 0;
  String get fastingTimeFormatted =>
      '${fastingTime.inHours}h ${fastingTime.inMinutes % 60}m';
  String get sleepTimeFormatted => '${sleep.inHours}h ${sleep.inMinutes % 60}m';

  UserMetrics copyWith({
    int? calories,
    int? calorieGoal,
    double? water,
    double? waterGoal,
    Duration? fastingTime,
    Duration? fastingGoal,
    int? steps,
    int? stepGoal,
    Duration? sleep,
    Duration? sleepGoal,
    String? mood,
    double? moodScore,
    DateTime? lastUpdated,
  }) {
    return UserMetrics(
      calories: calories ?? this.calories,
      calorieGoal: calorieGoal ?? this.calorieGoal,
      water: water ?? this.water,
      waterGoal: waterGoal ?? this.waterGoal,
      fastingTime: fastingTime ?? this.fastingTime,
      fastingGoal: fastingGoal ?? this.fastingGoal,
      steps: steps ?? this.steps,
      stepGoal: stepGoal ?? this.stepGoal,
      sleep: sleep ?? this.sleep,
      sleepGoal: sleepGoal ?? this.sleepGoal,
      mood: mood ?? this.mood,
      moodScore: moodScore ?? this.moodScore,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'calorieGoal': calorieGoal,
      'water': water,
      'waterGoal': waterGoal,
      'fastingTimeMinutes': fastingTime.inMinutes,
      'fastingGoalMinutes': fastingGoal.inMinutes,
      'steps': steps,
      'stepGoal': stepGoal,
      'sleepMinutes': sleep.inMinutes,
      'sleepGoalMinutes': sleepGoal.inMinutes,
      'mood': mood,
      'moodScore': moodScore,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  factory UserMetrics.fromJson(Map<String, dynamic> json) {
    return UserMetrics(
      calories: json['calories'] ?? 0,
      calorieGoal: json['calorieGoal'] ?? 2000,
      water: json['water'] ?? 0.0,
      waterGoal: json['waterGoal'] ?? 2.5,
      fastingTime: Duration(minutes: json['fastingTimeMinutes'] ?? 0),
      fastingGoal: Duration(
        minutes: json['fastingGoalMinutes'] ?? 960,
      ), // 16 hours
      steps: json['steps'] ?? 0,
      stepGoal: json['stepGoal'] ?? 10000,
      sleep: Duration(minutes: json['sleepMinutes'] ?? 0),
      sleepGoal: Duration(minutes: json['sleepGoalMinutes'] ?? 480), // 8 hours
      mood: json['mood'] ?? 'Neutral',
      moodScore: json['moodScore'] ?? 5.0,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(
        json['lastUpdated'] ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }
}
