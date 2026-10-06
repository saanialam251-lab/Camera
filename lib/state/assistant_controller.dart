import '../measure/models.dart';

/// Guided assistant  Section 5.11 templates + "measure my table"
class AssistantStep {
  final String prompt;
  final String? hint;
  final MeasureMode? suggestedMode;

  const AssistantStep({
    required this.prompt,
    this.hint,
    this.suggestedMode,
  });
}

class AssistantTemplate {
  final String id;
  final String name;
  final String description;
  final List<AssistantStep> steps;

  const AssistantTemplate({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
  });
}

class AssistantController {
  AssistantTemplate? active;
  int stepIndex = 0;

  bool get isActive => active != null;
  bool get isLast =>
      active != null && stepIndex >= active!.steps.length - 1;
  AssistantStep? get currentStep => active == null
      ? null
      : active!.steps[stepIndex.clamp(0, active!.steps.length - 1)];

  void start(AssistantTemplate template) {
    active = template;
    stepIndex = 0;
  }

  void next() {
    if (active == null) return;
    if (!isLast) stepIndex++;
  }

  void previous() {
    if (stepIndex > 0) stepIndex--;
  }

  void cancel() {
    active = null;
    stepIndex = 0;
  }

  static const door = AssistantTemplate(
    id: 'door',
    name: 'Door',
    description: 'Measure door width and height',
    steps: [
      AssistantStep(
        prompt: 'Measure the door width',
        suggestedMode: MeasureMode.distance,
      ),
      AssistantStep(
        prompt: 'Measure the door height',
        suggestedMode: MeasureMode.height,
      ),
    ],
  );

  static const window = AssistantTemplate(
    id: 'window',
    name: 'Window',
    description: 'Measure window opening',
    steps: [
      AssistantStep(
        prompt: 'Measure window width',
        suggestedMode: MeasureMode.distance,
      ),
      AssistantStep(
        prompt: 'Measure window height',
        suggestedMode: MeasureMode.height,
      ),
    ],
  );

  static const table = AssistantTemplate(
    id: 'table',
    name: 'Table',
    description: 'Measure table length, width, height',
    steps: [
      AssistantStep(
        prompt: 'Measure table length',
        suggestedMode: MeasureMode.distance,
      ),
      AssistantStep(
        prompt: 'Measure table width',
        suggestedMode: MeasureMode.distance,
      ),
      AssistantStep(
        prompt: 'Measure table height',
        suggestedMode: MeasureMode.height,
      ),
    ],
  );

  static const wall = AssistantTemplate(
    id: 'wall',
    name: 'Wall',
    description: 'Measure wall for paint or wallpaper',
    steps: [
      AssistantStep(
        prompt: 'Measure wall width',
        suggestedMode: MeasureMode.distance,
      ),
      AssistantStep(
        prompt: 'Measure wall height',
        suggestedMode: MeasureMode.height,
      ),
      AssistantStep(
        prompt: 'Optional: measure windows/doors to subtract',
        hint: 'Use Area subtract later',
        suggestedMode: MeasureMode.area,
      ),
    ],
  );

  static const tv = AssistantTemplate(
    id: 'tv',
    name: 'TV',
    description: 'Measure TV or screen size',
    steps: [
      AssistantStep(
        prompt: 'Measure screen width',
        suggestedMode: MeasureMode.distance,
      ),
      AssistantStep(
        prompt: 'Measure screen height',
        suggestedMode: MeasureMode.distance,
      ),
    ],
  );

  static const couch = AssistantTemplate(
    id: 'couch',
    name: 'Couch',
    description: 'Measure sofa for delivery fit',
    steps: [
      AssistantStep(
        prompt: 'Measure couch length',
        suggestedMode: MeasureMode.distance,
      ),
      AssistantStep(
        prompt: 'Measure couch depth',
        suggestedMode: MeasureMode.distance,
      ),
      AssistantStep(
        prompt: 'Measure couch height',
        suggestedMode: MeasureMode.height,
      ),
    ],
  );

  static const all = [door, window, table, wall, tv, couch];
}
