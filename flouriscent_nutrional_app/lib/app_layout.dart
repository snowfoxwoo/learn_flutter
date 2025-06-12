// lib/screens/app_layout.dart
import 'package:flouriscent_nutrional_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import '../widgets/bottom_nav.dart'; // Your BottomNavWidget

class AppLayout extends StatefulWidget {
  const AppLayout({super.key});

  @override
  State<AppLayout> createState() => _AppLayoutState();
}

class _AppLayoutState extends State<AppLayout> {
  int _currentIndex = 0; // Tracks active tab

  // Screens for each tab (replace with your actual screens)
  final List<Widget> _screens = [
    const HomeScreen(), // Index 0
    // const ExploreScreen(), // Index 1
    // const ReportScreen(),  // Index 2
    // const AchievementsScreen(), // Index 3
    // const ProfileScreen(), // Index 4
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex], // Shows the current tab's screen
      bottomNavigationBar: BottomNavWidget(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
