import 'package:flutter/material.dart';

class WaterTracker extends StatelessWidget {
  final double currentIntake;
  final double dailyGoal;
  final Function(double) onUpdateIntake;
  final VoidCallback onShowHistory;

  const WaterTracker({
    super.key,
    required this.currentIntake,
    required this.dailyGoal,
    required this.onUpdateIntake,
    required this.onShowHistory,
  });

  double get _completionPercentage =>
      (currentIntake / dailyGoal).clamp(0.0, 1.0);
  int get _completionPercent => (_completionPercentage * 100).toInt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _buildContainerDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(flex: 2, child: _buildIntakeDisplay()),
              Expanded(flex: 1, child: _buildWaterVisualization()),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildContainerDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Water Tracker',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        _buildHistoryButton(),
      ],
    );
  }

  Widget _buildHistoryButton() {
    return GestureDetector(
      onTap: onShowHistory,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.blue.shade400,
        ),
      ),
    );
  }

  Widget _buildIntakeDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${currentIntake.toInt()}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 6, left: 4),
              child: Text(
                'ml',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        Text(
          '/ ${dailyGoal.toInt()} ml',
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 8),
        Text(
          '$_completionPercent% completed',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildWaterVisualization() {
    return Column(
      children: [
        _buildWaterDropIndicator(),
        const SizedBox(height: 12),
        _buildControlButtons(),
      ],
    );
  }

  Widget _buildWaterDropIndicator() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200, width: 2),
            ),
            child: Stack(children: [_buildWaterFill(), _buildWaterDropIcon()]),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterFill() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        width: 56,
        height: 56 * _completionPercentage,
        decoration: BoxDecoration(
          color: Colors.blue.shade300,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(28),
            bottomRight: Radius.circular(28),
          ),
        ),
      ),
    );
  }

  Widget _buildWaterDropIcon() {
    return Center(
      child: Icon(
        Icons.water_drop,
        color:
            _completionPercentage > 0.5 ? Colors.white : Colors.blue.shade400,
        size: 24,
      ),
    );
  }

  Widget _buildControlButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildControlButton(
          icon: Icons.remove,
          onTap: () => onUpdateIntake(-250),
          isIncrement: false,
        ),
        const SizedBox(width: 16),
        _buildControlButton(
          icon: Icons.add,
          onTap: () => onUpdateIntake(250),
          isIncrement: true,
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isIncrement,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: isIncrement ? Colors.blue.shade400 : Colors.grey.shade100,
          shape: BoxShape.circle,
          border:
              isIncrement
                  ? null
                  : Border.all(color: Colors.grey.shade300, width: 1),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isIncrement ? Colors.white : Colors.grey,
        ),
      ),
    );
  }
}
