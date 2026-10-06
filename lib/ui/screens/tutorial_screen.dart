import 'package:flutter/material.dart';
import '../../state/tutorial_controller.dart';
import '../../feedback/voice.dart';
import '../theme.dart';
import '../widgets/primary_button.dart';

/// Tutorial screen  step-by-step guided demos.
class TutorialScreen extends StatefulWidget {
  final List<TutorialStep> steps;
  final String title;

  const TutorialScreen({
    super.key,
    required this.steps,
    this.title = 'Tutorial',
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final controller = TutorialController();

  @override
  void initState() {
    super.initState();
    controller.start(widget.steps);
    _speakCurrent();
  }

  void _speakCurrent() {
    final step = controller.current;
    if (step?.voicePrompt != null) {
      VoiceGuidance.speak(step!.voicePrompt!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = controller.current;
    if (step == null) {
      return const Scaffold(body: Center(child: Text('No steps')));
    }

    return Scaffold(
      backgroundColor: AppColors.nearBlack,
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: AppColors.nearBlack,
        actions: [
          TextButton(
            onPressed: () {
              controller.skip();
              Navigator.pop(context);
            },
            child: const Text('Skip', style: TextStyle(color: AppColors.textSecondary)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Progress dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(controller.steps.length, (i) {
                final active = i == controller.currentIndex;
                return Container(
                  width: active ? 24 : 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: active ? AppColors.accentCyan : Colors.white24,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),

            // Placeholder for animated demo
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.glass,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: AppColors.accentCyan.withOpacity(0.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              step.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              step.body,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            Row(
              children: [
                if (!controller.isFirst)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          controller.previous();
                          _speakCurrent();
                        });
                      },
                      child: const Text('Back'),
                    ),
                  ),
                if (!controller.isFirst) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: PrimaryButton(
                    label: controller.isLast ? 'Done' : 'Next',
                    onPressed: () {
                      if (controller.isLast) {
                        controller.complete();
                        Navigator.pop(context);
                      } else {
                        setState(() {
                          controller.next();
                          _speakCurrent();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
    );
  }
}
