// weight_tracker/weight_tracker.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class WeightTracker extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;
  final String unit;
  final Function(double) onUpdateWeight;
  final Function(double) onUpdateTargetWeight;
  final VoidCallback onShowHistory;

  const WeightTracker({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.unit,
    required this.onUpdateWeight,
    required this.onUpdateTargetWeight,
    required this.onShowHistory,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(colorScheme),
          const SizedBox(height: 20),
          _buildCurrentWeightDisplay(colorScheme),
          const SizedBox(height: 20),
          _buildTargetAndProgress(context, colorScheme),
          const SizedBox(height: 16),
          _buildProgressBar(colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeader(ColorScheme colorScheme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Weight Tracker',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.history),
          onPressed: onShowHistory,
          color: colorScheme.onSurfaceVariant,
          tooltip: 'View History',
        ),
      ],
    );
  }

  Widget _buildCurrentWeightDisplay(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.monitor_weight,
              color: colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Weight',
                  style: TextStyle(
                    fontSize: 14,
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.7,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_formatWeight(currentWeight)} $unit',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTargetAndProgress(
    BuildContext context,
    ColorScheme colorScheme,
  ) {
    final progressInfo = _getProgressInfo();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => _showTargetWeightDialog(context),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Target: ${_formatWeight(targetWeight)} $unit',
                        style: TextStyle(
                          fontSize: 14,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.edit,
                        size: 16,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: progressInfo.color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  progressInfo.text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: progressInfo.color,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: () => _showWeightEntryDialog(context),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Update'),
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar(ColorScheme colorScheme) {
    final progressInfo = _getProgressInfo();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Progress',
          style: TextStyle(
            fontSize: 12,
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progressInfo.progress.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: progressInfo.color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${(progressInfo.progress * 100).toInt()}% to goal',
          style: TextStyle(fontSize: 12, color: colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }

  String _formatWeight(double weight) {
    return weight % 1 == 0
        ? weight.toInt().toString()
        : weight.toStringAsFixed(1);
  }

  ProgressInfo _getProgressInfo() {
    final difference = currentWeight - targetWeight;
    final absDifference = difference.abs();

    // Calculate progress based on how close we are to target
    final double progress;
    final Color color;
    final String text;

    if (absDifference <= 1) {
      progress = 1.0;
      color = Colors.green;
      text = 'Goal achieved! 🎉';
    } else if (absDifference <= 3) {
      progress = 0.8;
      color = Colors.lightGreen;
      text = 'Almost there! ${_formatWeight(absDifference)} $unit to go';
    } else if (absDifference <= 5) {
      progress = 0.6;
      color = Colors.orange;
      text =
          '${_formatWeight(absDifference)} $unit ${difference > 0 ? 'to lose' : 'to gain'}';
    } else if (absDifference <= 10) {
      progress = 0.4;
      color = Colors.deepOrange;
      text =
          '${_formatWeight(absDifference)} $unit ${difference > 0 ? 'to lose' : 'to gain'}';
    } else {
      progress = 0.2;
      color = Colors.red;
      text =
          '${_formatWeight(absDifference)} $unit ${difference > 0 ? 'to lose' : 'to gain'}';
    }

    return ProgressInfo(progress: progress, color: color, text: text);
  }

  void _showWeightEntryDialog(BuildContext context) {
    final weightController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Weight'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: weightController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Weight ($unit)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.monitor_weight),
                    suffixText: unit,
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a weight';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0) {
                      return 'Please enter a valid weight';
                    }
                    if (weight > 1000) {
                      return 'Weight seems too high';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current: ${_formatWeight(currentWeight)} $unit',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newWeight = double.parse(weightController.text);
                  onUpdateWeight(newWeight);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  void _showTargetWeightDialog(BuildContext context) {
    final targetController = TextEditingController(
      text: _formatWeight(targetWeight),
    );
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Update Target Weight'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: targetController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Target Weight ($unit)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.flag),
                    suffixText: unit,
                  ),
                  autofocus: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a target weight';
                    }
                    final weight = double.tryParse(value);
                    if (weight == null || weight <= 0) {
                      return 'Please enter a valid weight';
                    }
                    if (weight > 1000) {
                      return 'Weight seems too high';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Current target: ${_formatWeight(targetWeight)} $unit',
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final newTarget = double.parse(targetController.text);
                  onUpdateTargetWeight(newTarget);
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }
}

// Helper class for progress information
class ProgressInfo {
  final double progress;
  final Color color;
  final String text;

  ProgressInfo({
    required this.progress,
    required this.color,
    required this.text,
  });
}
