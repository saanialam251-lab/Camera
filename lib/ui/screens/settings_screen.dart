import 'package:flutter/material.dart';
import '../theme.dart';

/// Settings – Section 10 skeleton
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.nearBlack,
      ),
      body: ListView(
        children: const [
          _SectionHeader('Measurement'),
          ListTile(
            title: Text('Default unit'),
            subtitle: Text('Auto'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ),
          ListTile(
            title: Text('Precision'),
            subtitle: Text('2 decimals'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ),
          ListTile(
            title: Text('Snap'),
            subtitle: Text('On · Medium'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ),
          _SectionHeader('Camera'),
          ListTile(
            title: Text('Quality'),
            subtitle: Text('Auto'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ),
          _SectionHeader('Feedback'),
          ListTile(
            title: Text('Haptics'),
            subtitle: Text('Normal'),
            trailing: Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ),
          _SectionHeader('About'),
          ListTile(
            title: Text('Version'),
            subtitle: Text('1.0.0-p1'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.accentCyan,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}
