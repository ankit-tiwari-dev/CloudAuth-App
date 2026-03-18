#!/usr/bin/env bash
set -euo pipefail
set -x

# Vercel doesn't ship with Flutter.
# Install Flutter SDK and build the web bundle into build/web.

FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
FLUTTER_GIT_REF="${FLUTTER_GIT_REF:-stable}"

if [ ! -d "flutter" ]; then
  # Installing from git avoids Flutter's internal git-dependent version checks
  # failing on some CI environments.
  git clone --depth 1 --branch "${FLUTTER_GIT_REF}" https://github.com/flutter/flutter.git flutter
fi

export PATH="$PWD/flutter/bin:$PATH"

flutter --version
flutter config --enable-web
flutter pub get

# Ensure correct relative paths when hosted at root.
flutter build web --release --base-href /

