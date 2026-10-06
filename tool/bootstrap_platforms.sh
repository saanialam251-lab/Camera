#!/usr/bin/env bash
# Generate official Flutter android/ folder without wiping lib/
# Android-only project (iOS removed by design)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found. Install: https://docs.flutter.dev/get-started/install"
  exit 1
fi

echo "Generating Android platform..."
flutter create . \
  --project-name measure_reality \
  --org com.measurereality \
  --platforms=android

echo "Installing native Kotlin bridges..."
mkdir -p android/app/src/main/kotlin/com/measurereality
cp -f native/android/*.kt android/app/src/main/kotlin/com/measurereality/

echo "Done. Next:"
echo "  flutter pub get"
echo "  flutter test"
echo "  flutter build apk --release"
