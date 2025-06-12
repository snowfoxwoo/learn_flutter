// widgets/fasting_timer_banner.dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../providers/user_metrics_provider.dart';
import '../utils/dialog_helpers.dart';

class FastingTimerBanner extends StatefulWidget {
  final UserMetricsProvider provider;
  const FastingTimerBanner({super.key, required this.provider});

  @override
  State<FastingTimerBanner> createState() => _FastingTimerBannerState();
}

class _FastingTimerBannerState extends State<FastingTimerBanner> {
  final List<String> presets = [
    '12-12',
    '14-10',
    '16-8',
    '18-6',
    '20-4',
    '24-0',
  ];

  @override
  Widget build(BuildContext context) {
    final metrics = widget.provider.metrics;
    final isFasting = widget.provider.isFasting;
    final selectedPreset = widget.provider.selectedPreset;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          const SizedBox(height: 32),

          // Circular Timer
          SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Circle
                Container(
                  width: 280,
                  height: 280,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[50],
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                  ),
                ),

                // Progress Circle
                CustomPaint(
                  size: Size(280, 280),
                  painter: CircularProgressPainter(
                    progress: metrics.fastingProgress.clamp(0.0, 1.0),
                    color: Color(0xFFFF4757),
                  ),
                ),

                // Hour Markers
                ...List.generate(12, (index) {
                  final angle = (index * 30) * (math.pi / 180);
                  final x = 120 * math.cos(angle - math.pi / 2);
                  final y = 120 * math.sin(angle - math.pi / 2);

                  return Positioned(
                    left: 140 + x - 2,
                    top: 140 + y - 2,
                    child: Container(
                      width: 4,
                      height: 4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[400],
                      ),
                    ),
                  );
                }),

                // Center Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      isFasting
                          ? 'Fasting in progress'
                          : 'Time since last fast',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      metrics.fastingTimeFormatted,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isFasting
                          ? 'Fast will end at'
                          : 'Your next fast begins on',
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                    Text(
                      isFasting
                          ? 'Tomorrow 06:00 AM'
                          : widget.provider.getNextFastTimeFormatted(),
                      style: TextStyle(
                        color: Colors.grey[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 16),
                    // Preset Selection Button
                    GestureDetector(
                      onTap: () => _showPresetsDialog(context),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFFF4757),
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFFFF4757).withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedPreset,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // History Button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                ),
                child: Icon(Icons.history, color: Colors.grey[600], size: 24),
              ),

              // Start Fasting Button
              GestureDetector(
                onTap: () {
                  if (isFasting) {
                    widget.provider.stopFasting();
                  } else {
                    widget.provider.startFasting();
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  decoration: BoxDecoration(
                    color: Color(0xFFFF4757),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Color(0xFFFF4757).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Text(
                    isFasting ? 'Stop Fasting' : 'Start Fasting',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Share Button
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[100],
                ),
                child: Icon(Icons.share, color: Colors.grey[600], size: 24),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPresetsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 20),

                // Title
                Text(
                  'Select Fasting Plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),

                // Preset options
                ...presets.map((preset) {
                  final isSelected = preset == widget.provider.selectedPreset;
                  final fastingHours = preset.split('-')[0];
                  final eatingHours = preset.split('-')[1];

                  return GestureDetector(
                    onTap: () {
                      widget.provider.setFastingPreset(preset);
                      Navigator.pop(context);
                    },
                    child: Container(
                      width: double.infinity,
                      margin: EdgeInsets.only(bottom: 12),
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? Color(0xFFFF4757).withValues(alpha: 0.1)
                                : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? Color(0xFFFF4757)
                                  : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  preset,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color:
                                        isSelected
                                            ? Color(0xFFFF4757)
                                            : Colors.black,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  '${fastingHours}h fasting, ${eatingHours}h eating',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle,
                              color: Color(0xFFFF4757),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                }),

                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background arc
    final backgroundPaint =
        Paint()
          ..color = Colors.grey[200]!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8
          ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint =
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
