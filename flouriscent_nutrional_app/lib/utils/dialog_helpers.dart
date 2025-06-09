// utils/dialog_helpers.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_metrics_provider.dart';

class DialogHelpers {
  static void showQuickAddDialog(BuildContext context, String type) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A237E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: Text(
              'Add ${type == 'calories' ? 'Calories' : 'Water'}',
              style: const TextStyle(color: Colors.white),
            ),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: type == 'calories' ? 'Calories (kcal)' : 'Water (L)',
                labelStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF6AE8DC)),
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                ),
              ),
              TextButton(
                onPressed: () {
                  final value = double.tryParse(controller.text);
                  if (value != null && value > 0) {
                    if (type == 'calories') {
                      context.read<UserMetricsProvider>().addCalories(
                        value.toInt(),
                      );
                    } else {
                      context.read<UserMetricsProvider>().addWater(value);
                    }
                  }
                  Navigator.pop(context);
                },
                child: const Text(
                  'Add',
                  style: TextStyle(color: Color(0xFF6AE8DC)),
                ),
              ),
            ],
          ),
    );
  }

  static void showFastingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A237E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'Fasting Options',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildFastingOption(
                  context,
                  'Start Fasting',
                  Icons.play_arrow_rounded,
                  const Color(0xFF6AE8DC),
                  () {
                    context.read<UserMetricsProvider>().startFasting();
                    Navigator.pop(context);
                  },
                ),
                _buildFastingOption(
                  context,
                  'End Fasting',
                  Icons.stop_rounded,
                  const Color(0xFFFF6B6B),
                  () {
                    context.read<UserMetricsProvider>().updateFastingTime(
                      const Duration(),
                    );
                    Navigator.pop(context);
                  },
                ),
                _buildFastingOption(
                  context,
                  'Join Group Fast',
                  Icons.group_rounded,
                  const Color(0xFFFFB74D),
                  () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/group-fast');
                  },
                ),
              ],
            ),
          ),
    );
  }

  static Widget _buildFastingOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }

  static void showMoodDialog(BuildContext context) {
    final moods = [
      {'mood': 'Excellent 😄', 'score': 10.0},
      {'mood': 'Happy 😊', 'score': 8.0},
      {'mood': 'Good 🙂', 'score': 7.0},
      {'mood': 'Okay 😐', 'score': 5.0},
      {'mood': 'Sad 😢', 'score': 3.0},
      {'mood': 'Tired 😴', 'score': 4.0},
    ];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: const Color(0xFF1A237E),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const Text(
              'How are you feeling?',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  moods
                      .map(
                        (mood) => ListTile(
                          title: Text(
                            mood['mood'] as String,
                            style: const TextStyle(color: Colors.white),
                          ),
                          onTap: () {
                            context.read<UserMetricsProvider>().updateMood(
                              mood['mood'] as String,
                              mood['score'] as double,
                            );
                            Navigator.pop(context);
                          },
                        ),
                      )
                      .toList(),
            ),
          ),
    );
  }
}
