// widgets/main_actions.dart
// import 'package:flouriscent_nutrional_app/screens/food_diary_screen.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import '../screens/food_scanner_screen.dart';

class MainActions extends StatefulWidget {
  const MainActions({super.key});

  @override
  State<MainActions> createState() => _MainActionsState();
}

class _MainActionsState extends State<MainActions> {
  double waterIntake = 0.0; // Current water intake in ml
  final double dailyGoal = 2500.0; // Daily goal in ml

  void _updateWaterIntake(double amount) {
    setState(() {
      waterIntake = (waterIntake + amount).clamp(0.0, dailyGoal);
    });
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
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class WaterTracker extends StatelessWidget {
  final double currentIntake;
  final double dailyGoal;
  final Function(double) onUpdateIntake;

  const WaterTracker({
    super.key,
    required this.currentIntake,
    required this.dailyGoal,
    required this.onUpdateIntake,
  });

  @override
  Widget build(BuildContext context) {
    final completionPercentage = (currentIntake / dailyGoal).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Water Tracker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.blue.shade400,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Water intake display
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${currentIntake.toInt()}',
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6, left: 4),
                          child: Text(
                            'ml',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '/ ${dailyGoal.toInt()} ml',
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(completionPercentage * 100).toInt()}% completed',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              // Water drop visualization and controls
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    // Water drop container
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(40),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Water level indicator
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade50,
                              border: Border.all(
                                color: Colors.blue.shade200,
                                width: 2,
                              ),
                            ),
                            child: Stack(
                              children: [
                                // Water fill
                                Align(
                                  alignment: Alignment.bottomCenter,
                                  child: Container(
                                    width: 56,
                                    height: 56 * completionPercentage,
                                    decoration: BoxDecoration(
                                      color: Colors.blue.shade300,
                                      borderRadius: const BorderRadius.only(
                                        bottomLeft: Radius.circular(28),
                                        bottomRight: Radius.circular(28),
                                      ),
                                    ),
                                  ),
                                ),
                                // Water drop icon
                                Center(
                                  child: Icon(
                                    Icons.water_drop,
                                    color:
                                        completionPercentage > 0.5
                                            ? Colors.white
                                            : Colors.blue.shade400,
                                    size: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Control buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Decrease button
                        GestureDetector(
                          onTap: () => onUpdateIntake(-250),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            child: const Icon(
                              Icons.remove,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Increase button
                        GestureDetector(
                          onTap: () => onUpdateIntake(250),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Colors.blue.shade400,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.add,
                              size: 18,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class CameraScanButton extends StatelessWidget {
  const CameraScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF00BCD4), Color(0xFF0097A7)],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BCD4).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () async {
          final imagePath = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FoodScannerScreen()),
          );
          if (imagePath != null) {
            debugPrint('Image captured at: $imagePath');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 20),
            const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Scan Your Food',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'AI-powered nutrition analysis',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class SecondaryActionButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const SecondaryActionButton({
    super.key,
    required this.title,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 75,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
