import 'package:shared_preferences/shared_preferences.dart';
import '../core/units.dart';

/// Persistent settings – Section 10 skeleton
class AppSettings {
  LengthUnit defaultUnit = LengthUnit.m;
  bool autoUnit = true;
  int precision = 2; // 0–3 or fractions later
  bool snapEnabled = true;
  String snapStrength = 'medium'; // low / medium / high
  String smoothing = 'medium';
  bool precisionModeDefault = false;
  bool autoSave = true;
  String defaultMode = 'distance';
  bool axisLockDefault = false;

  String cameraQuality = 'auto';
  bool leftHanded = false;
  String haptics = 'normal';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    precision = prefs.getInt('precision') ?? 2;
    snapEnabled = prefs.getBool('snapEnabled') ?? true;
    autoUnit = prefs.getBool('autoUnit') ?? true;
    leftHanded = prefs.getBool('leftHanded') ?? false;
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('precision', precision);
    await prefs.setBool('snapEnabled', snapEnabled);
    await prefs.setBool('autoUnit', autoUnit);
    await prefs.setBool('leftHanded', leftHanded);
  }
}
