import 'package:flutter/material.dart';
import '../../screens/food_scanner_screen.dart';

class CameraScanButton extends StatelessWidget {
  const CameraScanButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: _buildContainerDecoration(),
      child: Column(
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildScanButton(context),
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
          'Quick Scan',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        _buildAIPoweredBadge(),
      ],
    );
  }

  Widget _buildAIPoweredBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'AI Powered',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.blue.shade600,
        ),
      ),
    );
  }

  Widget _buildScanButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleScanTap(context),
      child: Container(
        width: double.infinity,
        height: 70,
        decoration: _buildScanButtonDecoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCameraIcon(),
            const SizedBox(width: 12),
            const Text(
              'Scan Food',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildScanButtonDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Colors.blue.shade400, Colors.blue.shade600],
      ),
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.blue.shade400.withValues(alpha: 0.3),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    );
  }

  Widget _buildCameraIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.camera_alt_rounded,
        size: 24,
        color: Colors.white,
      ),
    );
  }

  Future<void> _handleScanTap(BuildContext context) async {
    final imagePath = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodScannerScreen()),
    );
    if (imagePath != null) {
      debugPrint('Image captured at: $imagePath');
    }
  }
}
