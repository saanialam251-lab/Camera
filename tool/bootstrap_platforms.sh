#!/usr/bin/env bash
# Generate official Flutter ios/ + android/ folders without wiping lib/
# Run once after clone if you see: "Application not configured for iOS"
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found. Install Flutter first: https://docs.flutter.dev/get-started/install"
  exit 1
fi

echo "Generating ios + android platform folders..."
flutter create . \
  --project-name measure_reality \
  --org com.measurereality \
  --platforms=ios,android \
  --overwrite

# Re-apply native bridge copies into generated trees
echo "Installing native bridges..."
mkdir -p android/app/src/main/kotlin/com/measurereality
cp -f native/android/*.kt android/app/src/main/kotlin/com/measurereality/ 2>/dev/null || true
cp -f native/ios/*.swift ios/Runner/ 2>/dev/null || true

# Ensure camera + AR permissions (Android)
if [ -f android/app/src/main/AndroidManifest.xml ]; then
  if ! grep -q "android.permission.CAMERA" android/app/src/main/AndroidManifest.xml; then
    echo "NOTE: Add CAMERA permission to AndroidManifest.xml (see native docs)"
  fi
fi

# Ensure iOS camera usage string
if [ -f ios/Runner/Info.plist ]; then
  if ! grep -q "NSCameraUsageDescription" ios/Runner/Info.plist; then
    echo "NOTE: Add NSCameraUsageDescription to Info.plist"
  fi
fi

echo "Done. Next:"
echo "  flutter pub get"
echo "  flutter build ios --release --no-codesign"
echo "  flutter build apk --release"
