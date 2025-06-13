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

class FastingStage {
  final String name;
  final IconData icon;
  final double threshold;
  final String description;

  FastingStage({
    required this.name,
    required this.icon,
    required this.threshold,
    required this.description,
  });
}

class _FastingTimerBannerState extends State<FastingTimerBanner> {
  final List<FastingStage> fastingStages = [
    FastingStage(
      name: "Fed State",
      icon: Icons.restaurant,
      threshold: 0.0,
      description:
          "Your body is digesting food and absorbing nutrients. Blood sugar levels are elevated.",
    ),
    FastingStage(
      name: "Early Fasting",
      icon: Icons.energy_savings_leaf,
      threshold: 0.2,
      description:
          "Body starts using glucose from food for energy. Insulin levels begin to drop.",
    ),
    FastingStage(
      name: "Gluconeogenesis",
      icon: Icons.bloodtype,
      threshold: 0.4,
      description:
          "As glycogen stores are depleted during fasting, body shifts to producing glucose through gluconeogenesis. Liver starts producing glucose from non-carb sources to maintain blood sugar levels. This ensures that essential tissues, like the brain, have consistent supply of glucose. ",
    ),
    FastingStage(
      name: "Ketosis",
      icon: Icons.local_fire_department,
      threshold: 0.6,
      description:
          "As your body metabolizes fatty acids for energy, it produces ketone bodies as byproducts. When Ketone levels in the bloodstream rise above a certain threshold, your body enters a metabolic state called ketosis. In ketosis, ketone serve as an alternative fuel source to glucose, providing a steady supply of energy during fasting. Ketosis is characterized by increased fat burning, reduced appetite and enhanced mental clarity. Making it a hallmark of successful fasting.",
    ),
    FastingStage(
      name: "Autophagy",
      icon: Icons.cleaning_services,
      threshold: 0.8,
      description:
          "Autophagy is a cellular recylcing process that ivolves the removal of damaged of dysfunctional cells and cellular components. Through autophagy, your body breaks down and recycles old proteins, organelles, and other cellular debris, promoting cellular renwal and repair. This process helps maintain cellular health, optimize metabolic function and enhance overall longevity and resilience.",
    ),
    FastingStage(
      name: "Peak Growth Hormone",
      icon: Icons.self_improvement,
      threshold: 1.0,
      description:
          "Growth hormone peaks, promoting fat burning and muscle preservation.",
    ),
  ];

  final List<String> presets = [
    '12-12',
    '14-10',
    '16-8',
    '18-6',
    '20-4',
    '24-0',
  ];

  @override
  void initState() {
    super.initState();
    // Check fasting status periodically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFastingCompletion();
    });
  }

  void _showStagesOverview(BuildContext context) {
    final currentProgress = widget.provider.metrics.fastingProgress;
    final currentStage = fastingStages.lastWhere(
      (stage) => currentProgress >= stage.threshold,
      orElse: () => fastingStages.first,
    );

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight:
                  MediaQuery.of(context).size.height *
                  0.85, // Use 85% of screen height
            ),
            child: SingleChildScrollView(
              // Make content scrollable
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Title
                    Text(
                      'Fasting Stages Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),

                    // Current stage
                    Text(
                      'You are currently in: ${currentStage.name}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFFFF4757),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 20),

                    // Stages list - wrapped in Flexible to prevent overflow
                    Flexible(
                      child: ListView(
                        shrinkWrap: true, // Important for nested scrolling
                        physics:
                            ClampingScrollPhysics(), // Better physics for bottom sheet
                        children:
                            fastingStages.map((stage) {
                              final isCurrent = stage == currentStage;
                              return Container(
                                margin: EdgeInsets.only(bottom: 15),
                                padding: EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color:
                                      isCurrent
                                          ? Color(
                                            0xFFFF4757,
                                          ).withValues(alpha: 0.1)
                                          : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isCurrent
                                            ? Color(0xFFFF4757)
                                            : Colors.grey[200]!,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          stage.icon,
                                          color: Color(0xFFFF4757),
                                        ),
                                        SizedBox(width: 10),
                                        Expanded(
                                          // Ensure text doesn't overflow
                                          child: Text(
                                            stage.name,
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          '${(stage.threshold * 100).toInt()}%',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Text(
                                      stage.description,
                                      style: TextStyle(fontSize: 14),
                                      maxLines: 4,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                      ),
                    ),

                    // Share button
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          _shareFastingProgress(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFFF4757),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          minimumSize: Size(double.infinity, 50), // Full width
                        ),
                        child: Text(
                          'Share My Progress',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).padding.bottom,
                    ), // Safe area padding
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _shareFastingProgress(BuildContext context) {
    // Implement your sharing logic here
    // This could use the share plugin: https://pub.dev/packages/share
    final progress = widget.provider.metrics.fastingProgress;
    final currentStage = fastingStages.lastWhere(
      (stage) => progress >= stage.threshold,
      orElse: () => fastingStages.first,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Sharing your fasting progress at ${(progress * 100).toInt()}% - ${currentStage.name}',
        ),
      ),
    );
  }

  void _showStageInfo(BuildContext context, FastingStage stage) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(stage.icon, color: Color(0xFFFF4757)),
                SizedBox(width: 10),
                Text(stage.name),
              ],
            ),
            content: Text(stage.description),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  void _checkFastingCompletion() {
    if (widget.provider.isFasting &&
        widget.provider.metrics.fastingProgress >= 1.0) {
      // Fasting completed
      widget.provider.stopFasting();
      _showCompletionNotification();
    }

    // Check again in 1 second
    Future.delayed(Duration(seconds: 1), _checkFastingCompletion);
  }

  void _showCompletionNotification() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Fasting Complete!'),
            content: Text(
              'Congratulations! You\'ve completed your fasting period.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          ),
    );

    // Optional: Add vibration or sound
    // HapticFeedback.vibrate();
  }

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
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (metrics.fastingProgress >= 1.0 && isFasting)
            Text(
              'Fasting Complete!',
              style: TextStyle(
                color: Colors.green,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            )
          else
            Text(
              isFasting ? 'Fasting in progress' : 'Time since last fast',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
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
                    fastingStages: fastingStages,
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

                // Inside your Stack widget, after the hour markers
                ...fastingStages.map((stage) {
                  if (stage.threshold > 0 && stage.threshold <= 1.0) {
                    final angle =
                        (stage.threshold * 360 - 90) * (math.pi / 180);
                    final x = 130 * math.cos(angle);
                    final y = 130 * math.sin(angle);

                    return Positioned(
                      left: 140 + x - 16,
                      top: 140 + y - 16,
                      child: GestureDetector(
                        onTap: () => _showStageInfo(context, stage),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            stage.icon,
                            color: Color(0xFFFF4757),
                            size: 18,
                          ),
                        ),
                      ),
                    );
                  }
                  return SizedBox.shrink();
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
              // Replace the existing share button with this
              GestureDetector(
                onTap: () => _showStagesOverview(context),
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                  ),
                  child: Icon(Icons.share, color: Colors.grey[600], size: 24),
                ),
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
  final List<FastingStage> fastingStages;

  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.fastingStages,
  });

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
      final currentStage = fastingStages.lastWhere(
        (stage) => progress >= stage.threshold,
        orElse: () => fastingStages.first,
      );
      final progressPaint =
          Paint()
            ..color = progress >= 1.0 ? Colors.green : Color(0xFFFF4757)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 8
            ..strokeCap = StrokeCap.round;

      if (progress >= 1.0) {
        progressPaint.strokeWidth = 10;
      }

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2, // Start from top
        sweepAngle,
        false,
        progressPaint,
      );

      //small indicators for each stage
      for (final stage in fastingStages) {
        if (stage.threshold > 0 && stage.threshold <= 1.0) {
          final stageAngle = (stage.threshold * 360 - 90) * (math.pi / 180);
          final stageX = (radius - 5) * math.cos(stageAngle);
          final stageY = (radius - 5) * math.sin(stageAngle);
          final isCurrent = stage == currentStage;

          canvas.drawCircle(
            Offset(center.dx + stageX, center.dy + stageY),
            isCurrent ? 6 : 3,
            Paint()..color = isCurrent ? Colors.white : Color(0xFFFF4757),
          );
        }
      }
      if (progress >= 1.0) {
        final checkmarkPaint =
            Paint()
              ..color = Colors.green
              ..style = PaintingStyle.fill;

        final path =
            Path()
              ..moveTo(center.dx - 20, center.dy)
              ..lineTo(center.dx - 5, center.dy + 15)
              ..lineTo(center.dx, center.dy - 15);

        canvas.drawPath(path, checkmarkPaint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
