import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.settings, color: Colors.deepPurple),
          ),
        ],
      ),
      body: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final themeMode = themeProvider.themeMode;
          final activeThemeName = _getActiveThemeName(themeMode);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildAppearanceSection(context, themeProvider, activeThemeName),
              const SizedBox(height: 24),
              _buildAboutSection(),
              const SizedBox(height: 24),
              _buildDataPrivacySection(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppearanceSection(
    BuildContext context,
    ThemeProvider themeProvider,
    String activeThemeName,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: ' Appearance'),
        const SizedBox(height: 12),
        _ThemeSettingsCard(
          themeProvider: themeProvider,
          activeThemeName: activeThemeName,
        ),
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'About'),
        const SizedBox(height: 12),
        _AboutTile(Icons.apps, 'App Version', '1.0.0'),
        _AboutTile(Icons.build, 'Build Type', 'Testing'),
        _AboutTile(Icons.person, 'Developer', 'Flouriscent Team'),
      ],
    );
  }

  Widget _buildDataPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionHeader(title: 'Data & Privacy'),
        // Add your data privacy content here
      ],
    );
  }

  // Helper Methods
  static String _getActiveThemeName(ThemeMode mode) {
    return mode == ThemeMode.dark
        ? "Dark Mode"
        : mode == ThemeMode.light
        ? "Light Mode"
        : "System Default";
  }
}

// Custom Widgets
class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
    );
  }
}

class _ThemeSettingsCard extends StatelessWidget {
  final ThemeProvider themeProvider;
  final String activeThemeName;

  const _ThemeSettingsCard({
    required this.themeProvider,
    required this.activeThemeName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = themeProvider.themeMode == ThemeMode.dark;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Theme Mode',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text("Choose how Flouriscent looks on your device"),
          const SizedBox(height: 16),
          _ThemeOptionsRow(themeProvider: themeProvider),
          const SizedBox(height: 20),
          _ActiveThemeIndicator(
            isDark: isDark,
            activeThemeName: activeThemeName,
          ),
        ],
      ),
    );
  }
}

class _ThemeOptionsRow extends StatelessWidget {
  final ThemeProvider themeProvider;

  const _ThemeOptionsRow({required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ThemeOption(
          context: context,
          title: 'System',
          icon: Icons.settings_suggest,
          selected: themeProvider.themeMode == ThemeMode.system,
          onTap: () => themeProvider.toggleTheme(ThemeMode.system),
        ),
        const SizedBox(width: 12),
        _ThemeOption(
          context: context,
          title: 'Light',
          icon: Icons.light_mode,
          selected: themeProvider.themeMode == ThemeMode.light,
          onTap: () => themeProvider.toggleTheme(ThemeMode.light),
        ),
        const SizedBox(width: 12),
        _ThemeOption(
          context: context,
          title: 'Dark',
          icon: Icons.dark_mode,
          selected: themeProvider.themeMode == ThemeMode.dark,
          onTap: () => themeProvider.toggleTheme(ThemeMode.dark),
        ),
      ],
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final BuildContext context;
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOption({
    required this.context,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color:
                selected
                    ? Colors.deepPurple.withValues(alpha: 0.2)
                    : Theme.of(context).cardColor.withValues(alpha: 0.05),
            border: Border.all(
              color: selected ? Colors.deepPurpleAccent : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 28,
                color: selected ? Colors.deepPurpleAccent : Colors.grey,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.deepPurpleAccent : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActiveThemeIndicator extends StatelessWidget {
  final bool isDark;
  final String activeThemeName;

  const _ActiveThemeIndicator({
    required this.isDark,
    required this.activeThemeName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Colors.teal.shade700 : Colors.teal.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.dark_mode,
            color: isDark ? Colors.white : Colors.teal.shade800,
          ),
          const SizedBox(width: 10),
          Text(
            "Currently Active\n$activeThemeName",
            style: TextStyle(
              color: isDark ? Colors.white : Colors.teal.shade800,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AboutTile(this.icon, this.title, this.subtitle);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
      leading: Icon(icon, color: Colors.deepPurple),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
    );
  }
}
