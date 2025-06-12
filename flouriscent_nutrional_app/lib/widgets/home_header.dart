// widgets/home_header.dart
import 'package:flutter/material.dart';
import '../providers/user_metrics_provider.dart';

class HomeHeader extends StatelessWidget {
  final UserMetricsProvider provider;
  const HomeHeader({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left icon - Menu
            GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                ),
                child: Icon(Icons.menu, color: Colors.grey[700], size: 20),
              ),
            ),

            // Center title
            Text(
              'Home',
              style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),

            // Right icon - Profile/Settings
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/profile'),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                ),
                child: Icon(Icons.person, color: Colors.grey[700], size: 20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
