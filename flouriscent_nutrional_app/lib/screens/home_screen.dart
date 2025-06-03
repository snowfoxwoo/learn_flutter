import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flouriscent_nutrional_app/screens/food_scanner_screen.dart';
import 'package:flouriscent_nutrional_app/providers/user_metrics_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Consumer<UserMetricsProvider>(
          builder: (context, provider, child) {
            return Text(
              provider.getGreeting(),
              style: const TextStyle(fontWeight: FontWeight.w600),
            );
          },
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: CircleAvatar(
                backgroundColor: Colors.grey.shade200,
                child: Icon(Icons.settings, color: Colors.grey.shade700),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<UserMetricsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return const Padding(
            padding: EdgeInsets.all(20),
            child: _HomeContent(),
          );
        },
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Action Buttons - Primary Feature
          const _MainActionButtons(),

          const SizedBox(height: 32),

          // Overview Cards
          const _OverviewSection(),

          const SizedBox(height: 32),

          // Progress Section
          const _ProgressSection(),
        ],
      ),
    );
  }
}

class _MainActionButtons extends StatelessWidget {
  const _MainActionButtons();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Camera Button - Primary Action
        Container(
          width: double.infinity,
          height: 80,
          child: ElevatedButton(
            onPressed: () async {
              final imagePath = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => FoodScannerScreen()),
              );

              if (imagePath != null) {
                debugPrint('Image captured at: $imagePath');
                // Here you could add calories based on scanned food
                // context.read<UserMetricsProvider>().addCalories(estimatedCalories);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade800,
              foregroundColor: Colors.white,
              elevation: 4,
              shadowColor: Colors.grey.shade400,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.camera_alt, size: 28),
                ),
                const SizedBox(width: 16),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan Food',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Identify meals instantly',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Food Diary Button - Secondary Action
        Container(
          width: double.infinity,
          height: 70,
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/food-diary');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.grey.shade800,
              elevation: 2,
              shadowColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.book,
                    size: 24,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 16),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Food Diary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Track your meals',
                      style: TextStyle(fontSize: 13, color: Colors.black54),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OverviewSection extends StatelessWidget {
  const _OverviewSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserMetricsProvider>(
      builder: (context, provider, child) {
        final metrics = provider.metrics;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Overview",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),

            // Top row - Calories and Water
            Row(
              children: [
                Expanded(
                  child: _OverviewCard(
                    icon: Icons.local_fire_department,
                    title: 'Calories',
                    value: metrics.calories.toString(),
                    unit: 'kcal',
                    progress: metrics.calorieProgress.clamp(0.0, 1.0),
                    onTap: () => _showQuickAddDialog(context, 'calories'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _OverviewCard(
                    icon: Icons.water_drop,
                    title: 'Water',
                    value: metrics.water.toStringAsFixed(1),
                    unit: 'L',
                    progress: metrics.waterProgress.clamp(0.0, 1.0),
                    onTap: () => _showQuickAddDialog(context, 'water'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Full width - Fasting
            _OverviewCard(
              icon: Icons.timer,
              title: 'Fasting',
              value: metrics.fastingTimeFormatted,
              unit: metrics.isFasting ? 'active' : 'inactive',
              progress: metrics.fastingProgress.clamp(0.0, 1.0),
              isFullWidth: true,
              onTap: () => _showFastingDialog(context),
            ),
          ],
        );
      },
    );
  }

  void _showQuickAddDialog(BuildContext context, String type) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Add ${type == 'calories' ? 'Calories' : 'Water'}'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: type == 'calories' ? 'Calories (kcal)' : 'Water (L)',
                border: const OutlineInputBorder(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
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
                child: const Text('Add'),
              ),
            ],
          ),
    );
  }

  void _showFastingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Fasting Options'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.play_arrow),
                  title: const Text('Start Fasting'),
                  onTap: () {
                    context.read<UserMetricsProvider>().startFasting();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.stop),
                  title: const Text('End Fasting'),
                  onTap: () {
                    context.read<UserMetricsProvider>().updateFastingTime(
                      const Duration(),
                    );
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
    );
  }
}

class _ProgressSection extends StatelessWidget {
  const _ProgressSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<UserMetricsProvider>(
      builder: (context, provider, child) {
        final metrics = provider.metrics;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Today's Progress",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 16),

            _ProgressTile(
              title: 'Steps',
              value: metrics.steps.toString(),
              subtitle: 'of ${metrics.stepGoal} steps',
              icon: Icons.directions_walk,
              progress: metrics.stepProgress.clamp(0.0, 1.0),
            ),
            const SizedBox(height: 12),
            _ProgressTile(
              title: 'Sleep',
              value: metrics.sleepTimeFormatted,
              subtitle: 'last night',
              icon: Icons.bedtime,
              progress: metrics.sleepProgress.clamp(0.0, 1.0),
            ),
            const SizedBox(height: 12),
            _ProgressTile(
              title: 'Mood',
              value: metrics.mood,
              subtitle: 'feeling great today',
              icon: Icons.emoji_emotions,
              progress: metrics.moodProgress.clamp(0.0, 1.0),
              onTap: () => _showMoodDialog(context),
            ),
          ],
        );
      },
    );
  }

  void _showMoodDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('How are you feeling?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  [
                        _MoodOption('Excellent 😄', 10.0),
                        _MoodOption('Happy 😊', 8.0),
                        _MoodOption('Good 🙂', 7.0),
                        _MoodOption('Okay 😐', 5.0),
                        _MoodOption('Sad 😢', 3.0),
                        _MoodOption('Tired 😴', 4.0),
                      ]
                      .map(
                        (option) => ListTile(
                          title: Text(option.mood),
                          onTap: () {
                            context.read<UserMetricsProvider>().updateMood(
                              option.mood,
                              option.score,
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

class _MoodOption {
  final String mood;
  final double score;

  _MoodOption(this.mood, this.score);
}

class _ProgressTile extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final double progress;
  final VoidCallback? onTap;

  const _ProgressTile({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.grey.shade700, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.grey.shade600,
                    ),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final String unit;
  final double progress;
  final bool isFullWidth;
  final VoidCallback? onTap;

  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.unit,
    required this.progress,
    this.isFullWidth = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: Colors.grey.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade300,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey.shade600),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }
}
