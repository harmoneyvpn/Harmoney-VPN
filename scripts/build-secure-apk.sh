#!/usr/bin/env bash
set -euo pipefail

# Use the Flutter and Android SDK installations configured by the build host.
# Flutter's standard per-user SDK location is used only when no SDK variable is
# set and that directory exists.
if [[ -z "${ANDROID_HOME:-}" && -z "${ANDROID_SDK_ROOT:-}" && -d "${HOME}/Android/Sdk" ]]; then
  export ANDROID_HOME="${HOME}/Android/Sdk"
fi

# Ensure compatible JDK (Java 21) is used for Gradle
if [[ -d "/usr/lib/jvm/java-1.21.0-openjdk-amd64" ]]; then
  export JAVA_HOME="/usr/lib/jvm/java-1.21.0-openjdk-amd64"
  export PATH="${JAVA_HOME}/bin:${PATH}"
elif [[ -d "/usr/lib/jvm/java-21-openjdk-amd64" ]]; then
  export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
  export PATH="${JAVA_HOME}/bin:${PATH}"
fi

if ! command -v flutter >/dev/null 2>&1; then
  if [[ -d "${HOME}/flutter/bin" ]]; then
    export PATH="${HOME}/flutter/bin:${PATH}"
  elif [[ -d "${HOME}/SDK/flutter/bin" ]]; then
    export PATH="${HOME}/SDK/flutter/bin:${PATH}"
  fi
fi

# Automated secure release APK build script with full Flutter obfuscation
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="${ROOT_DIR}/apps/flutter"
SYMBOLS_DIR="${ROOT_DIR}/build_symbols"
DIST_DIR="${ROOT_DIR}/dist/release"

MODE="${1:---all}"

echo "=== Building Hardened Release APK for Harmoney ==="
echo "Mode: ${MODE}"
echo "Working directory: ${APP_DIR}"
echo "Symbols destination: ${SYMBOLS_DIR}"
echo "Dist release destination: ${DIST_DIR}"

mkdir -p "${SYMBOLS_DIR}" "${DIST_DIR}"
cd "${APP_DIR}"

flutter pub get

build_split() {
  echo ""
  echo "--- Building Split per-ABI Hardened APKs (arm64-v8a, armeabi-v7a, x86_64) ---"
  flutter build apk --release \
    --split-per-abi \
    --obfuscate \
    --split-debug-info="${SYMBOLS_DIR}"

  OUTPUT_DIR="${APP_DIR}/build/app/outputs/flutter-apk"
  if [[ -f "${OUTPUT_DIR}/app-arm64-v8a-release.apk" ]]; then
    cp "${OUTPUT_DIR}/app-arm64-v8a-release.apk" "${DIST_DIR}/HarmoneyPro-Android-arm64-v8a.apk"
  fi
  if [[ -f "${OUTPUT_DIR}/app-armeabi-v7a-release.apk" ]]; then
    cp "${OUTPUT_DIR}/app-armeabi-v7a-release.apk" "${DIST_DIR}/HarmoneyPro-Android-armeabi-v7a.apk"
  fi
  if [[ -f "${OUTPUT_DIR}/app-x86_64-release.apk" ]]; then
    cp "${OUTPUT_DIR}/app-x86_64-release.apk" "${DIST_DIR}/HarmoneyPro-Android-x86_64.apk"
  fi
}

build_universal() {
  echo ""
  echo "--- Building Universal Fat APK (all architectures in one file) ---"
  flutter build apk --release \
    --obfuscate \
    --split-debug-info="${SYMBOLS_DIR}"

  OUTPUT_DIR="${APP_DIR}/build/app/outputs/flutter-apk"
  if [[ -f "${OUTPUT_DIR}/app-release.apk" ]]; then
    cp "${OUTPUT_DIR}/app-release.apk" "${DIST_DIR}/HarmoneyPro-Android-universal.apk"
  fi
}

case "${MODE}" in
  --split-per-abi)
    build_split
    ;;
  --universal)
    build_universal
    ;;
  --all)
    build_split
    build_universal
    ;;
  *)
    echo "Unknown mode: ${MODE}. Valid options: --split-per-abi, --universal, --all"
    exit 1
    ;;
esac

echo ""
echo ">>> SUCCESS: Android hardened builds completed!"
echo ">>> Staged APKs in: ${DIST_DIR}"
ls -lh "${DIST_DIR}"/HarmoneyPro-Android-*.apk 2>/dev/null || true
echo ">>> Keep ${SYMBOLS_DIR} private; do NOT publish it with the APK."

