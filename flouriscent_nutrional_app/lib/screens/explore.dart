import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ExploreScreen extends StatelessWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: Colors.grey[100],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                            'assets/compass.svg',
                            height: 80,
                            color: Colors.grey[800],
                          )
                          .animate()
                          .fadeIn(duration: 500.ms)
                          .scale(begin: Offset(0.8, 0.8)),
                      const SizedBox(height: 16),
                      const Text(
                        'Discover Fasting',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final items = [
                  {
                    'icon': Icons.article_outlined,
                    'title': 'Guides',
                    'color': Colors.brown[300],
                  },
                  {
                    'icon': Icons.restaurant_outlined,
                    'title': 'Recipes',
                    'color': Colors.blueGrey[300],
                  },
                  {
                    'icon': Icons.schedule_outlined,
                    'title': 'Schedules',
                    'color': Colors.grey[400],
                  },
                  {
                    'icon': Icons.people_outline,
                    'title': 'Community',
                    'color': Colors.teal[200],
                  },
                ];

                return Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: items[index]['color'] as Color,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            items[index]['icon'] as IconData,
                            size: 28,
                            color: Colors.white,
                          ),
                        ).animate().scale(delay: (100 * index).ms).fadeIn(),
                        const SizedBox(height: 16),
                        Text(
                          items[index]['title'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ).animate().fadeIn(delay: (100 * index + 50).ms),
                      ],
                    ),
                  ),
                );
              }, childCount: 4),
            ),
          ),
        ],
      ),
    );
  }
}
