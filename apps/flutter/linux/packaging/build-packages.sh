#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 3 ]]; then
  echo "Usage: $0 <flutter-linux-bundle> <version> <output-directory>" >&2
  exit 2
fi

bundle="$(realpath "$1")"
version="$2"
output="$(mkdir -p "$3" && realpath "$3")"
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
work="$output/package-work"
binary="harmoney_community"

if [[ ! -x "$bundle/$binary" ]]; then
  echo "Flutter Linux executable not found: $bundle/$binary" >&2
  exit 1
fi

# jni_flutter links to libjvm.so. Avoid embedding the builder's home directory
# in the bundle and use the standard distro JRE location instead.
if [[ -f "$bundle/lib/libdartjni.so" ]]; then
  command -v patchelf >/dev/null || {
    echo "patchelf is required to make libdartjni.so portable" >&2
    exit 1
  }
  patchelf --set-rpath '$ORIGIN:/usr/lib/jvm/default-java/lib/server' "$bundle/lib/libdartjni.so"
fi

command -v rsvg-convert >/dev/null || {
  echo "rsvg-convert is required (install librsvg2-bin)." >&2
  exit 1
}

rm -rf "$work"
mkdir -p "$work"

desktop_file="$work/harmoney-vpn.desktop"
cat > "$desktop_file" <<'EOF'
[Desktop Entry]
Type=Application
Name=Harmoney VPN
Comment=Cross-platform VPN client
Exec=harmoney-vpn
Icon=harmoney-vpn
Terminal=false
Categories=Network;Security;
StartupWMClass=io.harmoney.client.github
EOF

icon_png="$work/harmoney-vpn.png"
rsvg-convert --width 256 --height 256 -o "$icon_png" "$script_dir/harmoney-vpn.svg"

# Debian package: install the complete Flutter bundle under /opt and provide a
# stable command and desktop entry for launching it.
deb_root="$work/deb-root"
install -d "$deb_root/opt/harmoney-vpn" \
  "$deb_root/usr/bin" \
  "$deb_root/usr/share/applications" \
  "$deb_root/usr/share/icons/hicolor/256x256/apps" \
  "$deb_root/DEBIAN"
cp -a "$bundle/." "$deb_root/opt/harmoney-vpn/"
cat > "$deb_root/usr/bin/harmoney-vpn" <<'EOF'
#!/bin/sh
cd /opt/harmoney-vpn
exec ./harmoney_community "$@"
EOF
chmod 0755 "$deb_root/usr/bin/harmoney-vpn"
install -m 0644 "$desktop_file" "$deb_root/usr/share/applications/harmoney-vpn.desktop"
install -m 0644 "$icon_png" "$deb_root/usr/share/icons/hicolor/256x256/apps/harmoney-vpn.png"
cat > "$deb_root/DEBIAN/control" <<EOF
Package: harmoney-vpn
Version: $version
Section: net
Priority: optional
Architecture: amd64
Maintainer: Harmoney VPN <harmoneyvpn@users.noreply.github.com>
Depends: default-jre-headless, libgtk-3-0, libayatana-appindicator3-1, libblkid1, liblzma5, libstdc++6
Description: Harmoney VPN Community client
 Cross-platform VPN client for Android, Windows, and Linux.
EOF
dpkg-deb --build --root-owner-group "$deb_root" "$output/HarmoneyVPN-${version}-amd64.deb"

# AppImage: keep the complete Flutter bundle together so its $ORIGIN/lib and
# data/ references resolve from the app's actual executable directory.
appdir="$work/AppDir"
install -d "$appdir/usr/lib/harmoney-vpn" \
  "$appdir/usr/bin" \
  "$appdir/usr/share/applications" \
  "$appdir/usr/share/icons/hicolor/256x256/apps"
cp -a "$bundle/." "$appdir/usr/lib/harmoney-vpn/"
ln -s ../lib/harmoney-vpn/"$binary" "$appdir/usr/bin/harmoney-vpn"
install -m 0644 "$desktop_file" "$appdir/usr/share/applications/harmoney-vpn.desktop"
install -m 0644 "$icon_png" "$appdir/usr/share/icons/hicolor/256x256/apps/harmoney-vpn.png"
cat > "$appdir/AppRun" <<'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/usr/bin/harmoney-vpn" "$@"
EOF
chmod 0755 "$appdir/AppRun"

linuxdeploy="$work/linuxdeploy-x86_64.AppImage"
curl --fail --location --retry 3 \
  https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage \
  --output "$linuxdeploy"
chmod 0755 "$linuxdeploy"
export LINUXDEPLOY_OUTPUT_VERSION="$version"
export LDAI_OUTPUT="$output/HarmoneyVPN-${version}-x86_64.AppImage"
export APPIMAGE_EXTRACT_AND_RUN=1
if command -v java >/dev/null 2>&1; then
  java_bin="$(readlink -f "$(command -v java)")"
  java_home="${JAVA_HOME:-$(dirname "$(dirname "$java_bin")")}"
  if [[ -d "$java_home/lib/server" ]]; then
    export LD_LIBRARY_PATH="$java_home/lib/server:$java_home/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  fi
fi
"$linuxdeploy" \
  --appdir "$appdir" \
  --executable "$appdir/usr/lib/harmoney-vpn/$binary" \
  --desktop-file "$appdir/usr/share/applications/harmoney-vpn.desktop" \
  --icon-file "$appdir/usr/share/icons/hicolor/256x256/apps/harmoney-vpn.png" \
  --output appimage

test -s "$output/HarmoneyVPN-${version}-amd64.deb"
test -s "$output/HarmoneyVPN-${version}-x86_64.AppImage"
echo "Created Linux installers in $output"
