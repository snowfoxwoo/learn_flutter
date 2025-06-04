import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// import '../../theme_provider.dart';
import 'package:flouriscent_nutrional_app/providers/user_metrics_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _nameController = TextEditingController();
  final _calorieGoalController = TextEditingController();
  final _waterGoalController = TextEditingController();
  final _stepGoalController = TextEditingController();
  int _fastingHours = 16;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<UserMetricsProvider>();
      final metrics = provider.metrics;

      _nameController.text = provider.userName;
      _calorieGoalController.text = metrics.calorieGoal.toString();
      _waterGoalController.text = metrics.waterGoal.toString();
      _stepGoalController.text = metrics.stepGoal.toString();
      _fastingHours = metrics.fastingGoal.inHours;
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection('Personal Information', [
              _buildTextField('Name', _nameController, 'Enter your name'),
            ]),
            const SizedBox(height: 32),
            _buildSection('Daily Goals', [
              _buildTextField(
                'Calorie Goal',
                _calorieGoalController,
                'e.g., 2000',
                TextInputType.number,
              ),
              _buildTextField(
                'Water Goal (L)',
                _waterGoalController,
                'e.g., 2.5',
                TextInputType.number,
              ),
              _buildTextField(
                'Step Goal',
                _stepGoalController,
                'e.g., 10000',
                TextInputType.number,
              ),
              _buildFastingGoalSelector(),
            ]),
            const SizedBox(height: 32),
            _buildSection('Actions', [
              _buildActionButton(
                'Reset Today\'s Data',
                Icons.refresh,
                Colors.orange,
                _resetTodayData,
              ),
              _buildActionButton(
                'Export Data',
                Icons.download,
                Colors.blue,
                _exportData,
              ),
            ]),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade800,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Settings',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    String hint, [
    TextInputType? keyboardType,
  ]) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey.shade50,
        ),
      ),
    );
  }

  Widget _buildFastingGoalSelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fasting Goal: ${_fastingHours}h',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Slider(
              value: _fastingHours.toDouble(),
              min: 12,
              max: 24,
              divisions: 12,
              label: '${_fastingHours}h',
              onChanged: (value) {
                setState(() {
                  _fastingHours = value.round();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    String title,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: color,
            side: BorderSide(color: color),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Icon(icon), const SizedBox(width: 8), Text(title)],
          ),
        ),
      ),
    );
  }

  void _saveSettings() async {
    final provider = context.read<UserMetricsProvider>();

    // Save name
    await provider.setUserName(_nameController.text.trim());

    // Save goals
    await provider.updateGoals(
      calorieGoal: int.tryParse(_calorieGoalController.text),
      waterGoal: double.tryParse(_waterGoalController.text),
      fastingGoal: Duration(hours: _fastingHours),
      stepGoal: int.tryParse(_stepGoalController.text),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Settings saved successfully!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context);
    }
  }

  void _resetTodayData() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Reset Today\'s Data'),
            content: const Text(
              'This will reset all your progress for today. Are you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  await context.read<UserMetricsProvider>().resetDailyData();
                  Navigator.pop(context);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Today\'s data has been reset'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                child: const Text('Reset'),
              ),
            ],
          ),
    );
  }

  void _exportData() {
    // Placeholder for data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Export feature coming soon!'),
        backgroundColor: Colors.blue,
      ),
    );
  }
}
