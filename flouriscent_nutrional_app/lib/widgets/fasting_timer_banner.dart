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
  bool _showCompletion = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkFastingCompletion();
    });
  }

  void _checkFastingCompletion() {
    if (widget.provider.isFasting &&
        widget.provider.metrics.fastingProgress >= 1.0) {
      widget.provider.stopFasting();
      setState(() => _showCompletion = true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() => _showCompletion = false);
      });
    }
  }

  final List<FastingStage> fastingStages = [
    FastingStage(
      name: "Fed State",
      icon: Icons.restaurant,
      threshold: 0.0,
      description: "Your body is digesting food and absorbing nutrients.",
    ),
    FastingStage(
      name: "Early Fasting",
      icon: Icons.energy_savings_leaf,
      threshold: 0.2,
      description: "Body starts using glucose from food for energy.",
    ),
    FastingStage(
      name: "Gluconeogenesis",
      icon: Icons.bloodtype,
      threshold: 0.4,
      description: "Body shifts to producing glucose through gluconeogenesis.",
    ),
    FastingStage(
      name: "Ketosis",
      icon: Icons.local_fire_department,
      threshold: 0.6,
      description: "Your body enters ketosis, using ketones as fuel.",
    ),
    FastingStage(
      name: "Autophagy",
      icon: Icons.cleaning_services,
      threshold: 0.8,
      description: "Cellular recycling process begins.",
    ),
    FastingStage(
      name: "Peak Growth Hormone",
      icon: Icons.self_improvement,
      threshold: 1.0,
      description: "Growth hormone peaks, promoting fat burning.",
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
  Widget build(BuildContext context) {
    final metrics = widget.provider.metrics;
    final isFasting = widget.provider.isFasting;
    final selectedPreset = widget.provider.selectedPreset;
    final isCompleted = metrics.fastingProgress >= 1.0;
    final primaryColor =
        _showCompletion ? Colors.green : const Color(0xFFFF4757);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color:
                  isCompleted
                      ? Colors.green.withOpacity(0.1)
                      : isFasting
                      ? primaryColor.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isCompleted
                      ? Icons.check_circle
                      : isFasting
                      ? Icons.timer
                      : Icons.access_time,
                  size: 16,
                  color:
                      isCompleted
                          ? Colors.green
                          : isFasting
                          ? primaryColor
                          : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  isCompleted
                      ? 'Fasting Complete! 🎉'
                      : isFasting
                      ? 'Fasting in Progress'
                      : 'Ready to Fast',
                  style: TextStyle(
                    color:
                        isCompleted
                            ? Colors.green
                            : isFasting
                            ? primaryColor
                            : Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Circular Timer
          SizedBox(
            width: 300,
            height: 300,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background Circle
                Container(
                  width: 300,
                  height: 300,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.grey[50]!, Colors.grey[100]!],
                    ),
                    border: Border.all(color: Colors.grey[200]!, width: 2),
                  ),
                ),

                // Progress Circle
                CustomPaint(
                  size: const Size(300, 300),
                  painter: _CircularProgressPainter(
                    progress: metrics.fastingProgress.clamp(0.0, 1.0),
                    color: primaryColor,
                    fastingStages: fastingStages,
                  ),
                ),

                // Stage Indicators
                ...fastingStages.asMap().entries.map((entry) {
                  final stage = entry.value;
                  if (stage.threshold > 0 && stage.threshold <= 1.0) {
                    final angle =
                        (stage.threshold * 360 - 90) * (math.pi / 180);
                    final x = 140 * math.cos(angle);
                    final y = 140 * math.sin(angle);
                    final isPassed = metrics.fastingProgress >= stage.threshold;

                    return Positioned(
                      left: 150 + x - 20,
                      top: 150 + y - 20,
                      child: GestureDetector(
                        onTap: () => _showStageInfo(context, stage),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color:
                                  isPassed ? primaryColor : Colors.grey[300]!,
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Icon(
                            stage.icon,
                            color: isPassed ? primaryColor : Colors.grey[400],
                            size: 20,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),

                // Center Content
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Center Content
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Timer Display
                        Text(
                          metrics.fastingTimeFormatted,
                          style: TextStyle(
                            color: Colors.black, // Changed to black
                            fontSize: 42,
                            fontWeight:
                                FontWeight
                                    .w500, // Medium weight instead of bold
                            letterSpacing: -1,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Progress Percentage
                        Text(
                          '${(metrics.fastingProgress * 100).toInt()}%',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Preset Selection Button
                        GestureDetector(
                          onTap: () => _showPresetsDialog(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withOpacity(0.3),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  selectedPreset,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
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
                    // Timer Display
                    Text(
                      metrics.fastingTimeFormatted,
                      style: TextStyle(
                        color: primaryColor,
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Progress Percentage
                    Text(
                      '${(metrics.fastingProgress * 100).toInt()}%',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Preset Selection Button
                    GestureDetector(
                      onTap: () => _showPresetsDialog(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              selectedPreset,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
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
              _buildActionButton(
                icon: Icons.history,
                onTap: () => _showFastingHistory(context),
                tooltip: 'Fasting History',
              ),

              // Main Action Button
              GestureDetector(
                onTap: () {
                  if (isFasting) {
                    widget.provider.stopFasting();
                  } else {
                    widget.provider.startFasting();
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: isFasting ? Colors.red[400] : primaryColor,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: (isFasting ? Colors.red : primaryColor)
                            .withOpacity(0.4),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Text(
                    isFasting ? 'Stop Fasting' : 'Start Fasting',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              // Stages Overview Button
              _buildActionButton(
                icon: Icons.insights,
                onTap: () => _showStagesOverview(context),
                tooltip: 'Fasting Stages',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[200]!),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(icon, color: Colors.grey[600], size: 24),
        ),
      ),
    );
  }

  void _showPresetsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
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
                const SizedBox(height: 20),

                // Title
                Text(
                  'Select Fasting Plan',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),

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
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color:
                            isSelected
                                ? const Color(0xFFFF4757).withOpacity(0.1)
                                : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color:
                              isSelected
                                  ? const Color(0xFFFF4757)
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
                                            ? const Color(0xFFFF4757)
                                            : Colors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
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
                            const Icon(
                              Icons.check_circle,
                              color: Color(0xFFFF4757),
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFastingHistory(BuildContext context) {
    final history = widget.provider.fastingHistory;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
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
                    const SizedBox(height: 20),

                    // Title
                    const Text(
                      'Fasting History',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // History list
                    if (history.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text(
                          'No fasting history yet',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    else
                      ...history.map((record) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: Column(
                            children: [
                              // Date and duration
                              Row(
                                children: [
                                  Text(
                                    '${record.date.month}/${record.date.day}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    record.formattedDuration,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Time period
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 18,
                                      color: Colors.grey[600],
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      record.formattedPeriod,
                                      style: const TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _showStageInfo(BuildContext context, FastingStage stage) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4757).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(stage.icon, color: const Color(0xFFFF4757)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(stage.name)),
              ],
            ),
            content: Text(
              stage.description,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Got it',
                  style: TextStyle(color: Color(0xFFFF4757)),
                ),
              ),
            ],
          ),
    );
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
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
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
                    const SizedBox(height: 20),

                    // Title
                    Text(
                      'Fasting Stages Overview',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),

                    // Current stage
                    Text(
                      'You are currently in: ${currentStage.name}',
                      style: TextStyle(
                        fontSize: 16,
                        color: const Color(0xFFFF4757),
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),

                    // Stages list
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        children:
                            fastingStages.map((stage) {
                              final isCurrent = stage == currentStage;
                              return Container(
                                margin: const EdgeInsets.only(bottom: 15),
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  color:
                                      isCurrent
                                          ? const Color(
                                            0xFFFF4757,
                                          ).withOpacity(0.1)
                                          : Colors.grey[50],
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color:
                                        isCurrent
                                            ? const Color(0xFFFF4757)
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
                                          color: const Color(0xFFFF4757),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Text(
                                            stage.name,
                                            style: const TextStyle(
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
                                    const SizedBox(height: 10),
                                    Text(
                                      stage.description,
                                      style: const TextStyle(fontSize: 14),
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
                      padding: const EdgeInsets.only(top: 20),
                      child: ElevatedButton(
                        onPressed: () {
                          _shareFastingProgress(context);
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF4757),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        child: const Text(
                          'Share My Progress',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  void _shareFastingProgress(BuildContext context) {
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
}

class _CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;
  final List<FastingStage> fastingStages;

  const _CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.fastingStages,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 15;

    // Background track
    final backgroundPaint =
        Paint()
          ..shader = LinearGradient(
            colors: [Colors.grey[100]!, Colors.grey[200]!],
          ).createShader(Rect.fromCircle(center: center, radius: radius))
          ..style = PaintingStyle.stroke
          ..strokeWidth = 8;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (progress > 0) {
      final progressPaint =
          Paint()
            ..color = color
            ..style = PaintingStyle.stroke
            ..strokeWidth = 12
            ..strokeCap = StrokeCap.round;

      final sweepAngle = 2 * math.pi * progress;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -math.pi / 2,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
