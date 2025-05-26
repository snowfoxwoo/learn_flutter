import 'package:flouriscent_nutrional_app/screens/food_scanner_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Good Morning!"),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/settings');
              },
              child: const CircleAvatar(
                backgroundColor: Colors.deepPurple,
                child: Icon(
                  Icons.settings,
                  color: Colors.white,
                ), // Changed to settings icon
              ),
            ),
          ),
        ],
      ),
      body: const Padding(padding: EdgeInsets.all(16), child: _HomeContent()),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overview Cards
        const Row(
          children: [
            Expanded(
              child: _OverviewCard(
                icon: Icons.local_fire_department,
                title: 'Calories',
                value: '1160kcal',
                color: Colors.orange,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: _OverviewCard(
                icon: Icons.water_drop,
                title: 'Water',
                value: '1.2 L',
                color: Colors.blue,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const _OverviewCard(
          icon: Icons.timer,
          title: 'Fasting',
          value: '12h 30m',
          color: Colors.purple,
          isFullWidth: true,
        ),

        // Camera Button
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () async {
                // Add camera functionality here
                final imagePath = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => FoodScannerScreen()),
                );

                if (imagePath != null) {
                  // Here you would pass the image to your TFLite model
                  debugPrint('Image captured at: $imagePath');
                  // Add your TensorFlow Lite processing here
                }
              },
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.camera_alt, size: 24),
              label: const Text('Scan Food', style: TextStyle(fontSize: 18)),
            ),
          ),
        ),

        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamed(context, '/food-diary');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.lightGreen,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: const Icon(Icons.book, color: Colors.white),
            label: const Text(
              'Food Diary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
          ),
        ),
        SizedBox(height: 16),
        const Text(
          "Today's Progress",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _ProgressTile(
          title: 'Steps',
          value: '6,200 / 10,000',
          icon: Icons.directions_walk,
          color: Colors.green,
        ),
        SizedBox(height: 12),
        _ProgressTile(
          title: 'Sleep',
          value: '7h 45m',
          icon: Icons.bedtime,
          color: Colors.teal,
        ),
        SizedBox(height: 12),
        _ProgressTile(
          title: 'Mood',
          value: 'Happy 😊',
          icon: Icons.emoji_emotions,
          color: Colors.amber,
        ),
      ],
    );
  }
}

class _ProgressTile extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ProgressTile({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}

class _OverviewCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;
  final bool isFullWidth;

  const _OverviewCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
    this.isFullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: color.withValues(alpha: 0.1),
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment:
              isFullWidth ? MainAxisAlignment.start : MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
