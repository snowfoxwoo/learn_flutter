// widgets/fasting_timer_banner.dart
import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
import '../providers/user_metrics_provider.dart';
import '../utils/dialog_helpers.dart';

class FastingTimerBanner extends StatelessWidget {
  final UserMetricsProvider provider;

  const FastingTimerBanner({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final metrics = provider.metrics;
    final isFasting = metrics.isFasting;

    return GestureDetector(
      onTap: () => DialogHelpers.showFastingDialog(context),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors:
                isFasting
                    ? [const Color(0xFFFF6B6B), const Color(0xFFEE5A52)]
                    : [const Color(0xFF4ECDC4), const Color(0xFF44A08D)],
          ),
          boxShadow: [
            BoxShadow(
              color: (isFasting
                      ? const Color(0xFFFF6B6B)
                      : const Color(0xFF4ECDC4))
                  .withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isFasting ? 'FASTING MODE' : 'EATING WINDOW',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                Icon(
                  isFasting ? Icons.timer_rounded : Icons.restaurant_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              metrics.fastingTimeFormatted,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            LinearProgressIndicator(
              value: metrics.fastingProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white.withValues(alpha: 0.8),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
          ],
        ),
      ),
    );
  }
}
