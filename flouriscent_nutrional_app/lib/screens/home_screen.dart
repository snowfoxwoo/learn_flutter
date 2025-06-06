import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flouriscent_nutrional_app/screens/food_scanner_screen.dart';
import 'package:flouriscent_nutrional_app/providers/user_metrics_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E27), // Deep space blue
      body: SafeArea(
        child: Consumer<UserMetricsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64FFDA)),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                _buildHeader(context, provider),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildMainActions(context),
                        const SizedBox(height: 30),
                        _buildQuickStats(context, provider),
                        const SizedBox(height: 30),
                        _buildProgressSection(context, provider),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserMetricsProvider provider) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF1A237E), // Deep purple
                Color(0xFF3949AB), // Medium purple
                Color(0xFF5C6BC0), // Light purple
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.getGreeting(),
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(0, 2),
                        blurRadius: 8,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Let's make today amazing! 🌟",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: GestureDetector(
            onTap: () => Navigator.pushNamed(context, '/settings'),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.tune, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMainActions(BuildContext context) {
    return Column(
      children: [
        // Primary action - Camera
        Container(
          width: double.infinity,
          height: 90,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF00BCD4), // Cyan
                Color(0xFF0097A7), // Dark cyan
                Color(0xFF006064), // Darker cyan
              ],
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
        ),

        const SizedBox(height: 16),

        // Secondary actions row
        Row(
          children: [
            Expanded(
              child: _buildSecondaryAction(
                context,
                'Food Diary',
                'Track meals',
                Icons.book_rounded,
                const LinearGradient(
                  colors: [Color(0xFFFF6B6B), Color(0xFFEE5A52)],
                ),
                () => Navigator.pushNamed(context, '/food-diary'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildSecondaryAction(
                context,
                'Recipes',
                'Get inspired',
                Icons.restaurant_rounded,
                const LinearGradient(
                  colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
                ),
                () {}, // Add your recipe navigation
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSecondaryAction(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Gradient gradient,
    VoidCallback onTap,
  ) {
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

  Widget _buildQuickStats(BuildContext context, UserMetricsProvider provider) {
    final metrics = provider.metrics;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF64FFDA).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Color(0xFF64FFDA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                "Today's Snapshot",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Calories',
                  metrics.calories.toString(),
                  'kcal',
                  Icons.local_fire_department_rounded,
                  const Color(0xFFFF6B6B),
                  metrics.calorieProgress,
                  () => _showQuickAddDialog(context, 'calories'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Water',
                  metrics.water.toStringAsFixed(1),
                  'L',
                  Icons.water_drop_rounded,
                  const Color(0xFF4FC3F7),
                  metrics.waterProgress,
                  () => _showQuickAddDialog(context, 'water'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            'Fasting',
            metrics.fastingTimeFormatted,
            metrics.isFasting ? 'active' : 'inactive',
            Icons.timer_rounded,
            const Color(0xFFFFB74D),
            metrics.fastingProgress,
            () => _showFastingDialog(context),
            isFullWidth: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String unit,
    IconData icon,
    Color color,
    double progress,
    VoidCallback onTap, {
    bool isFullWidth = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    unit,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              borderRadius: BorderRadius.circular(4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection(
    BuildContext context,
    UserMetricsProvider provider,
  ) {
    final metrics = provider.metrics;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFAB47BC).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: Color(0xFFAB47BC),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              "Your Progress",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        _buildProgressTile(
          'Steps',
          metrics.steps.toString(),
          'of ${metrics.stepGoal} steps',
          Icons.directions_walk_rounded,
          const Color(0xFF81C784),
          metrics.stepProgress,
        ),
        const SizedBox(height: 12),

        _buildProgressTile(
          'Sleep',
          metrics.sleepTimeFormatted,
          'last night',
          Icons.bedtime_rounded,
          const Color(0xFF9575CD),
          metrics.sleepProgress,
        ),
        const SizedBox(height: 12),

        _buildProgressTile(
          'Mood',
          metrics.mood,
          'feeling great today',
          Icons.emoji_emotions_rounded,
          const Color(0xFFFFB74D),
          metrics.moodProgress,
          onTap: () => _showMoodDialog(context),
        ),
      ],
    );
  }

  Widget _buildProgressTile(
    String title,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    double progress, {
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Colors.white.withValues(alpha: .1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.white.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Dialog methods (same functionality, updated styling)
  void _showQuickAddDialog(BuildContext context, String type) {
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
                  borderSide: BorderSide(color: Color(0xFF64FFDA)),
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
                  style: TextStyle(color: Color(0xFF64FFDA)),
                ),
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
                ListTile(
                  leading: const Icon(
                    Icons.play_arrow_rounded,
                    color: Color(0xFF64FFDA),
                  ),
                  title: const Text(
                    'Start Fasting',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    context.read<UserMetricsProvider>().startFasting();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.stop_rounded,
                    color: Color(0xFFFF6B6B),
                  ),
                  title: const Text(
                    'End Fasting',
                    style: TextStyle(color: Colors.white),
                  ),
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

  void _showMoodDialog(BuildContext context) {
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
