#!/usr/bin/env bash
set -euo pipefail

# ==============================================================================
# Harmoney Pro - Unified Multi-Platform Hardened Release Builder
# Automatically detects host platform and available toolchains, then builds
# all possible secure release packages with full obfuscation & symbol separation.
# ==============================================================================

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DIST_DIR="${ROOT_DIR}/dist/release"
SYMBOLS_DIR="${ROOT_DIR}/build_symbols"

# 1. Environment & PATH Auto-Detection
[[ -d "${HOME}/flutter/bin" ]] && export PATH="${HOME}/flutter/bin:${PATH}"
[[ -d "${HOME}/SDK/flutter/bin" ]] && export PATH="${HOME}/SDK/flutter/bin:${PATH}"
[[ -d "${HOME}/.cargo/bin" ]] && export PATH="${HOME}/.cargo/bin:${PATH}"

if [[ -d "/usr/lib/jvm/java-21-openjdk-amd64" ]]; then
  export JAVA_HOME="/usr/lib/jvm/java-21-openjdk-amd64"
  export PATH="${JAVA_HOME}/bin:${PATH}"
elif [[ -d "/usr/lib/jvm/java-1.21.0-openjdk-amd64" ]]; then
  export JAVA_HOME="/usr/lib/jvm/java-1.21.0-openjdk-amd64"
  export PATH="${JAVA_HOME}/bin:${PATH}"
fi

if command -v go >/dev/null 2>&1; then
  GOPATH="$(go env GOPATH 2>/dev/null || echo "${HOME}/go")"
  [[ -d "${GOPATH}/bin" ]] && export PATH="${GOPATH}/bin:${PATH}"
fi

if [[ -z "${ANDROID_HOME:-}" && -z "${ANDROID_SDK_ROOT:-}" && -d "${HOME}/Android/Sdk" ]]; then
  export ANDROID_HOME="${HOME}/Android/Sdk"
fi

mkdir -p "${DIST_DIR}" "${SYMBOLS_DIR}"

echo "===================================================================="
echo "   Harmoney Pro - All-in-One Automated Hardened Release Builder     "
echo "===================================================================="
echo "Host OS:         $(uname -s) ($(uname -m))"
echo "Output Dist:     ${DIST_DIR}"
echo "Symbols Dir:     ${SYMBOLS_DIR}"
echo "===================================================================="
echo ""

# Verify Flutter
if ! command -v flutter >/dev/null 2>&1; then
  echo "[-] ERROR: Flutter SDK was not found in PATH." >&2
  echo "    Please install Flutter or ensure ~/flutter/bin is accessible." >&2
  exit 1
fi

FLUTTER_VERSION="$(flutter --version | head -n 1)"
echo "[+] Detected: ${FLUTTER_VERSION}"
echo ""

HOST_OS="$(uname -s)"
BUILD_COUNT=0

# ------------------------------------------------------------------------------
# A. ANDROID TARGET (Can be built on Linux, macOS, and Windows)
# ------------------------------------------------------------------------------
if [[ -n "${ANDROID_HOME:-}" || -n "${ANDROID_SDK_ROOT:-}" || -d "${HOME}/Android/Sdk" ]]; then
  echo ">>> [1/2] Building Android Hardened Release APKs (Obfuscated)..."
  if [[ -f "${ROOT_DIR}/scripts/build-secure-apk.sh" ]]; then
    bash "${ROOT_DIR}/scripts/build-secure-apk.sh" --all
    BUILD_COUNT=$((BUILD_COUNT + 1))
  else
    echo "[-] Warning: scripts/build-secure-apk.sh not found, skipping Android build."
  fi
else
  echo "[!] Notice: Android SDK not detected; skipping Android builds."
fi

echo ""

# ------------------------------------------------------------------------------
# B. HOST-NATIVE DESKTOP TARGET
# ------------------------------------------------------------------------------
case "${HOST_OS}" in
  Linux)
    echo ">>> [2/2] Building Linux Hardened Desktop & Debian Package (.deb)..."
    
    # 1. Build Linux FFI native shared library + Flutter bundle
    if [[ -f "${ROOT_DIR}/scripts/build-flutter-linux-release.sh" ]]; then
      chmod +x "${ROOT_DIR}/scripts/build-flutter-linux-release.sh"
      bash "${ROOT_DIR}/scripts/build-flutter-linux-release.sh"
      
      if [[ -f "${ROOT_DIR}/dist/harmoney-vpn-flutter-linux.tar.gz" ]]; then
        cp -f "${ROOT_DIR}/dist/harmoney-vpn-flutter-linux.tar.gz" "${DIST_DIR}/"
      fi
    fi

    # 2. Package Debian .deb
    if [[ -f "${ROOT_DIR}/scripts/package-flutter-linux.sh" ]]; then
      chmod +x "${ROOT_DIR}/scripts/package-flutter-linux.sh"
      bash "${ROOT_DIR}/scripts/package-flutter-linux.sh"
      
      LATEST_DEB="$(find "${ROOT_DIR}/dist/packages" -name "*.deb" -type f -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -f2- -d" " || true)"
      if [[ -n "${LATEST_DEB}" && -f "${LATEST_DEB}" ]]; then
        cp -f "${LATEST_DEB}" "${DIST_DIR}/"
        echo "[+] Staged Linux DEB: ${DIST_DIR}/$(basename "${LATEST_DEB}")"
      fi
      BUILD_COUNT=$((BUILD_COUNT + 1))
    fi

    echo ""
    echo "--------------------------------------------------------------------"
    echo "[!] Windows & macOS notice on Linux host:"
    echo "    - Flutter requires a Windows host with MSVC for native Windows builds."
    echo "      -> To build Windows: Run .\\scripts\\build-all-releases.bat on Windows,"
    echo "         or trigger the GitHub Actions workflow (.github/workflows/windows-installer.yml)."
    echo "    - Flutter requires macOS with Xcode for macOS/iOS builds."
    echo "--------------------------------------------------------------------"
    ;;

  Darwin)
    echo ">>> Building macOS Hardened Release Package (DMG)..."
    if [[ -f "${ROOT_DIR}/scripts/package-flutter-macos.sh" ]]; then
      bash "${ROOT_DIR}/scripts/package-flutter-macos.sh"
      BUILD_COUNT=$((BUILD_COUNT + 1))
    fi
    ;;

  MINGW*|MSYS*|CYGWIN*)
    echo ">>> Building Windows Hardened Release Package (.exe)..."
    if [[ -f "${ROOT_DIR}/scripts/build-secure-windows.bat" ]]; then
      cmd.exe /c "${ROOT_DIR}/scripts/build-secure-windows.bat"
      BUILD_COUNT=$((BUILD_COUNT + 1))
    fi
    ;;

  *)
    echo "[!] Unknown host operating system: ${HOST_OS}"
    ;;
esac

echo ""
echo "===================================================================="
echo "                      BUILD SUMMARY & ARTIFACTS                     "
echo "===================================================================="
echo "Artifacts directory: ${DIST_DIR}"
echo ""
ls -lh "${DIST_DIR}" 2>/dev/null || true
echo ""
echo "Debug symbols preserved in: ${SYMBOLS_DIR}"
ls -lh "${SYMBOLS_DIR}" 2>/dev/null || true
echo ""
echo ">>> ALL ELIGIBLE BUILDS COMPLETED SUCCESSFULLY! <<<"
echo "===================================================================="

