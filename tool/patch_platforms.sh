#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
echo "Patching platform folders from native/ …"

# Android
if [ -d "$ROOT/android" ]; then
  mkdir -p "$ROOT/android/app/src/main/kotlin/com/measurereality"
  cp -v "$ROOT/native/android/"*.kt "$ROOT/android/app/src/main/kotlin/com/measurereality/" 2>/dev/null || true
  echo "Android native sources copied."
fi

# iOS
if [ -d "$ROOT/ios" ]; then
  mkdir -p "$ROOT/ios/Runner"
  cp -v "$ROOT/native/ios/"*.swift "$ROOT/ios/Runner/" 2>/dev/null || true
  echo "iOS native sources copied."
fi

echo "Done. Remember to declare MethodChannel 'measure_reality/ar' in the native MainActivity / AppDelegate."
