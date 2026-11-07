# Harmoney VPN — Community Edition

The Flutter application for the Harmoney community client on Android, Windows, and Linux. The app includes Harmoney Smart and FireTunnel; Harmoney Pro is distributed separately.

## Run locally

```sh
flutter pub get
flutter run
```

## Release builds

Build on a host with the matching platform toolchain:

```sh
flutter build apk --release       # Android
flutter build windows --release   # Windows
flutter build linux --release     # Linux
```

Linux requires GTK 3 and Ayatana AppIndicator development packages. The root README contains the full dependency command and feature overview.

## Harmoney Pro download page

```sh
flutter build apk --dart-define=HARMONEY_PRO_DOWNLOAD_URL=https://harmoneyvpn.github.io/Harmoney-VPN/
```

The public edition opens the platform-aware download page by default. Use the define above to override it for a custom distribution.
