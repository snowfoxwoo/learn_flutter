import 'package:flutter/material.dart';
import 'water_tracker/water_tracker.dart';
// import 'water_tracker/water_tracker_models.dart';
import 'weight_tracker/weight_tracker.dart';
import 'scan_button/camera_scan_button.dart';
import '../screens/water_history_screen.dart';
import '../screens/weight_history_screen.dart';
import '../models/weight_entry.dart';

class MainActions extends StatefulWidget {
  const MainActions({super.key});

  @override
  State<MainActions> createState() => _MainActionsState();
}

class _MainActionsState extends State<MainActions> {
  // Water tracking variables
  double waterIntake = 0.0;
  static const double dailyGoal = 2500.0;
  List<WaterEntry> waterHistory = [];

  // Weight tracking variables
  double currentWeight = 70.0; // Default weight
  double targetWeight = 65.0; // Default target
  String weightUnit = 'kg';
  List<WeightEntry> weightHistory = [];

  void _updateWaterIntake(double amount) {
    setState(() {
      waterIntake = (waterIntake + amount).clamp(0.0, dailyGoal);
      waterHistory.add(WaterEntry(amount: amount, timestamp: DateTime.now()));
    });
  }

  void _updateWeight(double newWeight) {
    setState(() {
      currentWeight = newWeight;
      weightHistory.add(
        WeightEntry(weight: newWeight, timestamp: DateTime.now()),
      );
    });
  }

  void _updateTargetWeight(double newTargetWeight) {
    setState(() {
      targetWeight = newTargetWeight;
    });
  }

  void _showWaterHistory(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WaterHistoryScreen(
              waterHistory: waterHistory,
              dailyGoal: dailyGoal,
            ),
      ),
    );
  }

  void _showWeightHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => WeightHistoryScreen(
              weightHistory: weightHistory,
              currentWeight: currentWeight,
              targetWeight: targetWeight,
              unit: weightUnit,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const CameraScanButton(),
        const SizedBox(height: 16),
        WaterTracker(
          currentIntake: waterIntake,
          dailyGoal: dailyGoal,
          onUpdateIntake: _updateWaterIntake,
          onShowHistory: () => _showWaterHistory(context),
        ),
        const SizedBox(height: 16),
        WeightTracker(
          currentWeight: currentWeight,
          targetWeight: targetWeight,
          unit: weightUnit,
          onUpdateWeight: _updateWeight,
          onUpdateTargetWeight: _updateTargetWeight, // Add this line
          onShowHistory: _showWeightHistory,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
