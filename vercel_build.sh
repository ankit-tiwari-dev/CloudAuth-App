#!/usr/bin/env bash
set -euo pipefail

# Vercel doesn't ship with Flutter. This script downloads Flutter SDK,
# builds the web bundle, and leaves the output in build/web.

FLUTTER_VERSION="${FLUTTER_VERSION:-3.38.5}"
FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
FLUTTER_ARCHIVE="flutter_linux_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.tar.xz"
FLUTTER_URL="https://storage.googleapis.com/flutter_infra_release/releases/${FLUTTER_CHANNEL}/linux/${FLUTTER_ARCHIVE}"

if [ ! -d "flutter" ]; then
  echo "Downloading Flutter SDK (${FLUTTER_VERSION} ${FLUTTER_CHANNEL})..."
  curl -fsSL "$FLUTTER_URL" -o "$FLUTTER_ARCHIVE"
  tar -xf "$FLUTTER_ARCHIVE"
  rm -f "$FLUTTER_ARCHIVE"
fi

export PATH="$PWD/flutter/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get

# Ensure correct relative paths when hosted at root.
flutter build web --release --base-href /

