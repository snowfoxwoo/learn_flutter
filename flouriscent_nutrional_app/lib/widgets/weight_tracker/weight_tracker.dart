// weight_tracker/weight_tracker.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WeightTracker extends StatelessWidget {
  final double currentWeight;
  final double targetWeight;
  final String unit;
  final Function(double) onUpdateWeight;
  final VoidCallback onShowHistory;

  const WeightTracker({
    super.key,
    required this.currentWeight,
    required this.targetWeight,
    required this.unit,
    required this.onUpdateWeight,
    required this.onShowHistory,
  });

  @override
  Widget build(BuildContext context) {
    double progress = _calculateProgress();
    String progressText = _getProgressText();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weight Tracker',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.history),
                onPressed: onShowHistory,
                color: Colors.grey.shade600,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Weight Display
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.monitor_weight,
                  color: Colors.blue.shade400,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Weight',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  Text(
                    '${currentWeight.toStringAsFixed(1)} $unit',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Target and Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Target: ${targetWeight.toStringAsFixed(1)} $unit',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progressText,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _getProgressColor(),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed: () => _showWeightEntryDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade400,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Update Weight'),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Progress Bar
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(4),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: _getProgressColor(),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  double _calculateProgress() {
    // Simple progress calculation - you can adjust this logic based on your needs
    double diff = (currentWeight - targetWeight).abs();
    if (diff <= 2) return 1.0; // Very close to target
    if (diff <= 5) return 0.7; // Moderately close
    if (diff <= 10) return 0.4; // Some progress
    return 0.1; // Just started
  }

  String _getProgressText() {
    double diff = currentWeight - targetWeight;
    if (diff.abs() <= 2) {
      return 'Goal achieved! 🎉';
    } else if (diff > 0) {
      return '${diff.toStringAsFixed(1)} $unit to lose';
    } else {
      return '${diff.abs().toStringAsFixed(1)} $unit to gain';
    }
  }

  Color _getProgressColor() {
    double diff = (currentWeight - targetWeight).abs();
    if (diff <= 2) return Colors.green;
    if (diff <= 5) return Colors.orange;
    return Colors.red;
  }

  void _showWeightEntryDialog(BuildContext context) {
    final TextEditingController weightController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Update Weight'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weight ($unit)',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.monitor_weight),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 16),
              Text(
                'Current: ${currentWeight.toStringAsFixed(1)} $unit',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final double? newWeight = double.tryParse(
                  weightController.text,
                );
                if (newWeight != null && newWeight > 0) {
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
}
