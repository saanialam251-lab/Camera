import 'package:flutter/material.dart';
import '../theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        backgroundColor: AppColors.nearBlack,
      ),
      body: const Center(
        child: Text(
          'No measurements yet',
          style: TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
