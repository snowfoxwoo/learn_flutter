import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flouriscent_nutrional_app/providers/user_metrics_provider.dart';

// Separate widgets into different files for better organization
import '../widgets/home_header.dart';
import '../widgets/fasting_timer_banner.dart';
import '../widgets/main_actions.dart';
import '../widgets/bottom_nav.dart';
//TODO
// import '../widgets/community_section.dart';
// import '../widgets/blog_section.dart';
// import '../widgets/quick_stats.dart';
// import '../widgets/progress_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 248, 244, 244),
      body: SafeArea(
        child: Consumer<UserMetricsProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6AE8DC)),
                ),
              );
            }

            return CustomScrollView(
              slivers: [
                HomeHeader(provider: provider),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        FastingTimerBanner(provider: provider),
                        const SizedBox(height: 20),
                        const MainActions(),
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
}
