import 'package:flutter/material.dart';
import '../theme.dart';

/// Home Screen – Section 7
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              Text(
                'Measure Reality',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
              const SizedBox(height: 24),

              // Quick Measure – largest primary action
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/measure'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(64),
                ),
                child: const Text('Quick Measure', style: TextStyle(fontSize: 20)),
              ),
              const SizedBox(height: 12),

              OutlinedButton(
                onPressed: () => Navigator.pushNamed(context, '/measure'),
                child: const Text('Start Measuring'),
              ),
              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/history'),
                    child: const Text('History', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Tutorials', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/settings'),
                    child: const Text('Settings', style: TextStyle(color: AppColors.textSecondary)),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Device Analysis card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Device Analysis', style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      const Text('Depth: Checking…', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                      const Text('Typical ±1–2% at 1–3 m', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              Text('Recent', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              SizedBox(
                height: 80,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 3,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, __) => Container(
                    width: 120,
                    decoration: BoxDecoration(
                      color: AppColors.glass,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('—', style: TextStyle(color: AppColors.textSecondary)),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
