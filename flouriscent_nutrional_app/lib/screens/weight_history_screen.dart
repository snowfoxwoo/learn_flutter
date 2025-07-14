// screens/weight_history_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/weight_entry.dart';

class WeightHistoryScreen extends StatelessWidget {
  final List<WeightEntry> weightHistory;
  final double currentWeight;
  final double targetWeight;
  final String unit;

  const WeightHistoryScreen({
    super.key,
    required this.weightHistory,
    required this.currentWeight,
    required this.targetWeight,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Weight History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: weightHistory.isEmpty ? _buildEmptyState() : _buildHistoryList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.monitor_weight_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No weight history yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start tracking your weight to see progress',
            style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList() {
    // Group entries by date
    Map<String, List<WeightEntry>> groupedEntries = {};
    for (var entry in weightHistory) {
      String dateKey = DateFormat('yyyy-MM-dd').format(entry.timestamp);
      if (!groupedEntries.containsKey(dateKey)) {
        groupedEntries[dateKey] = [];
      }
      groupedEntries[dateKey]!.add(entry);
    }

    // Sort dates in descending order
    List<String> sortedDates =
        groupedEntries.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      children: [
        _buildStatsHeader(),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sortedDates.length,
            itemBuilder: (context, index) {
              String date = sortedDates[index];
              List<WeightEntry> dayEntries = groupedEntries[date]!;

              return _buildDateGroup(date, dayEntries);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStatsHeader() {
    double weightDiff = currentWeight - targetWeight;
    String diffText =
        weightDiff >= 0
            ? '+${weightDiff.toStringAsFixed(1)}'
            : weightDiff.toStringAsFixed(1);
    Color diffColor =
        weightDiff.abs() <= 2
            ? Colors.green
            : (weightDiff.abs() <= 5 ? Colors.orange : Colors.red);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Current',
            '${currentWeight.toStringAsFixed(1)} $unit',
            Colors.blue,
            Icons.monitor_weight,
          ),
          _buildStatItem(
            'Target',
            '${targetWeight.toStringAsFixed(1)} $unit',
            Colors.green,
            Icons.gps_fixed,
          ),
          _buildStatItem(
            'Difference',
            '$diffText $unit',
            diffColor,
            Icons.trending_up,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    Color color,
    IconData icon,
  ) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildDateGroup(String date, List<WeightEntry> entries) {
    DateTime dateTime = DateTime.parse(date);
    String formattedDate = DateFormat('EEEE, MMM d').format(dateTime);

    // Get the latest entry for the day
    WeightEntry latestEntry = entries.reduce(
      (a, b) => a.timestamp.isAfter(b.timestamp) ? a : b,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('h:mm a').format(latestEntry.timestamp),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Text(
                      '${latestEntry.weight.toStringAsFixed(1)} $unit',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.monitor_weight,
                        color: Colors.blue.shade400,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (entries.length > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Text(
                '${entries.length} entries recorded',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ),
        ],
      ),
    );
  }
}
