#!/usr/bin/env bash
# Generate app icons + splash from assets/icons/source.png (P4)
# Requires: flutter_launcher_icons / flutter_native_splash (add to pubspec when ready)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$ROOT/assets/icons/source.png"

if [ ! -f "$SRC" ]; then
  echo "Place a 1024x1024 PNG at assets/icons/source.png first."
  echo "Then re-run: ./tool/gen_icons.sh"
  exit 0
fi

echo "Generating launcher icons&"
# dart run flutter_launcher_icons
echo "Generating native splash&"
# dart run flutter_native_splash:create
echo "Done. (Uncomment the dart run lines after adding the packages to pubspec.yaml)"
