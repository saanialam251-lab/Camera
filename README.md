# Measure Reality – AR Precision Measurement App

**Expanded Build Spec v2** implementation in Flutter.

## Golden Rules (apply to everything)

1. The endpoint is **never** auto-locked. Only the SET END POINT button (or a deliberate tap) commits it.
2. One obvious primary action on screen at every state. Secondary actions stay small.
3. Never show fake precision. Every number carries a confidence level and an error range.
4. UI never touches the AR render loop. Heavy work runs off the main thread / isolates.
5. Every feature works offline.

## Architecture

```
lib/
├── core/          units, fractions, perf governor, logger
├── measure/       pure Dart (geometry, filters, confidence, models)
├── ar/            native channel provider + mock
├── state/         measure_controller + mode handlers
├── data/          settings, repositories, exporters
├── feedback/      haptics, sound, voice
└── ui/            theme, painters, screens, sheets, widgets
```

Native bridges live in `native/android/` and `native/ios/` and are copied into the platform folders by `tool/patch_platforms.sh`.

## Phases

| Phase | Scope |
|-------|-------|
| **P1** | Core engine, Distance + basic modes, Home, Measure, History, Settings, CI |
| **P2** | Snap, Grid, Level/Vertical, mode handlers split, sensor fusion |
| **P3** | Room scan, Object mode, calibration, plane fitting, depth |
| **P4** | Tutorial, help sheets, haptics/sound/voice, quality governor, debug |
| **P5** | Export (PDF/CSV/JSON/PNG/SVG), projects, compare, estimators, video |
| **P6** | Replay tests, device matrix, release workflow |

**Build Phase 1 and validate accuracy + FPS before adding visual polish or advanced modes.**

## Getting Started

```bash
flutter pub get
./tool/patch_platforms.sh
flutter run
```

## CI

- `.github/workflows/android-apk.yml` – build + test + APK
- `.github/workflows/ios-build.yml` – unsigned + signed IPA
- `.github/workflows/release.yml` – tagged release (P6)

## Accuracy Notes (shown in-app)

Phone AR measurement is typically within 1–3 % in good conditions.  
LiDAR/ToF devices are better; depth-less devices are worse at long range.  
The app labels “Estimate” for trig height, room scans, and any measurement without depth or plane support.  
Not a replacement for certified instruments where legal/safety-critical accuracy is required.
