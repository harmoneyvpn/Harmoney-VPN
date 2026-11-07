import 'vpn_core.dart';

/// Apple native transport is outside the Android/Linux/Windows community build.
class MacOsVpnCore extends UnsupportedVpnCore {
  const MacOsVpnCore(VpnCore delegate);
}
