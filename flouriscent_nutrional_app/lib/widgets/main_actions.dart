import 'package:flutter/material.dart';
import 'water_tracker/water_tracker.dart';
// import 'water_tracker/water_tracker_models.dart';
import 'scan_button/camera_scan_button.dart';
import '../screens/water_history_screen.dart';

class MainActions extends StatefulWidget {
  const MainActions({super.key});

  @override
  State<MainActions> createState() => _MainActionsState();
}

class _MainActionsState extends State<MainActions> {
  double waterIntake = 0.0;
  static const double dailyGoal = 2500.0;
  List<WaterEntry> waterHistory = [];

  void _updateWaterIntake(double amount) {
    setState(() {
      waterIntake = (waterIntake + amount).clamp(0.0, dailyGoal);
      waterHistory.add(WaterEntry(amount: amount, timestamp: DateTime.now()));
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
      ],
    );
  }
}
