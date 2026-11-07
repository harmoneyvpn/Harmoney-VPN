// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Harmoney VPN';

  @override
  String get splashSubtitle => 'Crafted for secure internet access,\ndesigned for everyone, everywhere';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get connecting => 'Connecting';

  @override
  String connectingVia(String groupName) {
    return 'CONNECTING VIA $groupName';
  }

  @override
  String get switchingMethod => 'SWITCHING METHOD';

  @override
  String get speedTest => 'Speed Test';

  @override
  String get download => 'DOWNLOAD';

  @override
  String get upload => 'UPLOAD';

  @override
  String get ping => 'PING';

  @override
  String get latency => 'LATENCY';

  @override
  String get jitter => 'JITTER';

  @override
  String get packetLoss => 'P.LOSS';

  @override
  String get tapHere => 'TAP HERE';

  @override
  String get settings => 'Settings';

  @override
  String get introduction => 'Introduction';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get termsAndConditions => 'Terms & Conditions';

  @override
  String get ourWebsite => 'Our Website';

  @override
  String get marketplace => 'Marketplace';

  @override
  String get telegramBot => 'Telegram Bot';

  @override
  String get sourceCode => 'Source code';

  @override
  String get openSourceLicenses => 'Open source licenses';

  @override
  String get betaCommunity => 'Beta Community';

  @override
  String get close => 'Close';

  @override
  String get copyLogs => 'Copy Logs';

  @override
  String get logsCopied => 'Logs copied to clipboard';

  @override
  String get appLogs => 'App Logs';

  @override
  String get autoRefresh => 'Auto-refresh';

  @override
  String get clear => 'Clear';

  @override
  String get quickMenu => 'Quick Menu';

  @override
  String get noInternet => 'No Internet';

  @override
  String get error => 'Error';

  @override
  String get loading => 'Loading';

  @override
  String get analyzing => 'Analyzing';

  @override
  String get mbps => 'Mbps';

  @override
  String get ms => 'ms';

  @override
  String get language => 'Language';

  @override
  String get tips => 'TIPS';

  @override
  String get english => 'English';

  @override
  String get chinese => '中文 (Chinese)';

  @override
  String get gotIt => 'Got it';

  @override
  String get learnMore => 'LEARN MORE';

  @override
  String get harmoneyGoal => 'The goal of Harmoney is to ensure secure access to public information and provide a free browsing experience.';

  @override
  String get statusIsChilling => 'is chilling.';

  @override
  String get statusIs => 'is';

  @override
  String get statusFailed => 'failed.';

  @override
  String get statusHas => 'has';

  @override
  String get statusIsReturning => 'is returning';

  @override
  String get statusToStandbyMode => 'to standby mode.';

  @override
  String get statusPluggingIn => 'plugging in ...';

  @override
  String get statusPoweredUp => 'powered up';

  @override
  String get statusDoingScience => 'doing science ...';

  @override
  String get statusExitedMatrix => 'exited the matrix';

  @override
  String get statusSorry => 'we\'re sorry :(';

  @override
  String get statusConnectAlready => 'Connect already';

  @override
  String get statusTestingSpeed => 'testing speed ...';

  @override
  String get statusIsReady => 'is ready';

  @override
  String get statusIsInTrouble => 'is in trouble.';

  @override
  String get statusDXcoreDown => 'DXcore down.';

  @override
  String get statusToSpeedTest => 'to speed test';

  @override
  String get statusYoursToShape => 'yours to shape';

  @override
  String get settingsConnectionMethod => 'CONNECTION METHOD';

  @override
  String get settingsEscapeMode => 'ESCAPE MODE';

  @override
  String get settingsDestination => 'DESTINATION';

  @override
  String get settingsSplitTunnel => 'SPLIT TUNNEL';

  @override
  String get settingsKillSwitch => 'KILL SWITCH';

  @override
  String get settingsDeepScan => 'DEEP SCAN';

  @override
  String get settingsHealthCheck => 'HEALTH CHECK';

  @override
  String get settingsIncluded => 'INCLUDED';

  @override
  String get settingsAtLeastOneCoreRequired => 'At least one core must remain enabled';

  @override
  String get settingsResetToDefault => 'RESET';

  @override
  String get offlineFlowlineMessage => 'Flowline updates have been paused because the offline version is currently being used.';

  @override
  String get offlineFlowlineUndo => 'UNDO';

  @override
  String get updateAvailable => 'Update available';

  @override
  String get updateRequired => 'Update required';

  @override
  String get updateOptionalMessage => 'To get the most out of the app and enjoy the latest improvements, please update to the newest version.';

  @override
  String get updateRequiredMessage => 'To continue using Harmoney, please update to the latest version. This update includes critical improvements and is required for app functionality.';

  @override
  String get updateNow => 'Update now';

  @override
  String get notNow => 'Not now';

  @override
  String get updateMethods => 'Update Methods';

  @override
  String get importConfig => 'Import Config';

  @override
  String get synchronization => 'Synchronization';

  @override
  String get settingsDonation => 'Donation';

  @override
  String get settingsDonationDescription => 'Help us break down the walls of digital censorship and internet filtering.';

  @override
  String get authenticationRequired => 'Authentication Required';

  @override
  String get premiumLoginDescription => 'To access your Premium subscription(s), you need to login or create an account through the Harmoney website.';

  @override
  String get email => 'Email';

  @override
  String get emailHint => 'example@domain.com';

  @override
  String get emailValidation => 'Please enter your email';

  @override
  String get password => 'Password';

  @override
  String get passwordHint => 'Enter your password';

  @override
  String get passwordValidation => 'Please enter your password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get login => 'Login';

  @override
  String get noAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign up';

  @override
  String get loginFailed => 'Login failed. Please check your credentials and try again.';

  @override
  String get loginSuccess => 'Login successful!';

  @override
  String get code => 'Code';

  @override
  String get codeHint => 'Enter your access code';

  @override
  String get codeValidation => 'Please enter your code';

  @override
  String get premiumLoginByCodeDescription => 'To access your Premium subscription(s), enter the access code provided to you.';

  @override
  String get havingTrouble => 'Having trouble?';

  @override
  String get signedInAs => 'You are currently signed in with the email address';

  @override
  String get premiumImportDescription => 'If your Premium subscriptions cannot be loaded due to internet restrictions and you\'re unable to connect using the available methods, you can import the file obtained from the Marketplace into the app.';

  @override
  String get planningToExit => 'Planning to exit?';

  @override
  String get signOut => 'Sign out';

  @override
  String get signOutSuccess => 'Signed out successfully!';

  @override
  String get settingsMarketplace => 'Marketplace';

  @override
  String get marketplaceDescription => 'Browse secure VPN configurations from trusted suppliers.';

  @override
  String get loggedIn => 'LOGGED IN';

  @override
  String get loginOrRegister => 'LOGIN OR REGISTER';

  @override
  String get loginByCode => 'Login by code';

  @override
  String get backToLoginByEmail => 'Back to login by email';

  @override
  String get connectionRequired => 'Connection Required';

  @override
  String get connectionRequiredDescription => 'To complete a secure login or registration process, you must first establish a connection using one of the available connection methods.';

  @override
  String get inlineText_a5998db73b68af63 => 'تنظیمات سرور';

  @override
  String get inlineText_3305ac4300665f71 => 'اسکن خودکار این دستگاه';

  @override
  String get inlineText_fa7af603d430b209 => 'انصراف';

  @override
  String get inlineText_9de2a0d933190a40 => 'Harmoney Pro';

  @override
  String get inlineText_9fd728c66c9a256b => 'Add';

  @override
  String get inlineText_8450d81a2ef331f0 => 'Not supported on this platform.';

  @override
  String get inlineText_6f759aed280d8ae1 => 'شناسه سخت‌افزاری به مقدار پیش‌فرض سرور بازنشانی شد.';

  @override
  String get inlineText_10ae58fbb5984f6e => 'On Android and Linux the selected subscription is used, but the VPN core may choose a different node from it.';

  @override
  String get inlineText_c01c4324f1fa14fc => 'Importing…';

  @override
  String get inlineText_ef207787e1f5054a => 'Per-app bypass is not supported on this platform.';

  @override
  String get inlineText_543264e2f45dd255 => 'Bypass VPN';

  @override
  String get inlineText_034fc31b30e178f0 => 'Firefox VPN protocol';

  @override
  String get inlineText_4fcf7e0d90445713 => 'Disabled: all traffic routes securely through encrypted VPN tunnel.';

  @override
  String get inlineText_272a96114c7af32f => 'Custom Bypass Rules';

  @override
  String get inlineText_7b547a5ae60b2f38 => 'Firefox VPN';

  @override
  String get inlineText_4b42c738a9185fc5 => 'Hotspot Active';

  @override
  String get inlineText_fa174cea0ac4357d => 'Save preference';

  @override
  String get inlineText_5474eef8d0f179c7 => 'Working…';

  @override
  String get inlineText_e6f7f8ccc059e5c7 => 'No applications selected.';

  @override
  String get inlineText_df8748e19fc6ee2b => 'Disconnect is taking longer than expected. You can try again.';

  @override
  String get inlineText_c0bd827e34b175ab => 'Block Internet Access';

  @override
  String get inlineText_7af2f7454f3b55aa => 'Refresh status & quota';

  @override
  String get inlineText_eea2745e2867a677 => 'Verify';

  @override
  String get inlineText_88712c434b491bce => 'Login Required';

  @override
  String get inlineText_7d9eb7acb13e2462 => 'Close';

  @override
  String get inlineText_46b5d935b82dd8e0 => 'Select connection service';

  @override
  String get inlineText_8035283793ddc0b5 => 'Query latest session and traffic quota';

  @override
  String get inlineText_64a985f51e17518b => 'No custom bypass rules.';

  @override
  String get inlineText_90e0e260530759ce => 'Host machine only';

  @override
  String get inlineText_fa1cf54705b7a6ea => 'تولید شناسه سخت‌افزاری دستگاه';

  @override
  String get inlineText_8693a5d72c6b23fa => 'Share secure encrypted tunnel with phones & tablets';

  @override
  String get inlineText_0d21bd52022ca7f7 => 'Online';

  @override
  String get inlineText_7d096ae1ecf2a8cc => 'Bypassing';

  @override
  String get inlineText_2fc9fc3695f14892 => 'Disable Optimization';

  @override
  String get inlineText_6405b0129cf5a714 => 'شناسه نهایی تولیدشده (SHA-256):';

  @override
  String get inlineText_5f65ccdf701bd499 => 'ذخیره تنظیمات';

  @override
  String get inlineText_c90fdfab474bdd3e => 'Log in to account';

  @override
  String get inlineText_1c114a72bff7ecbc => 'Repair ICS';

  @override
  String get inlineText_c3a6d1c87fa8d4bb => 'Speed Test History';

  @override
  String get inlineText_4d9bfca28655ee45 => 'Session Upload:';

  @override
  String get inlineText_1a095c79818885e4 => 'Start Guest';

  @override
  String get inlineText_d18f4156fea49644 => 'Checking account…';

  @override
  String get inlineText_ac7c949f1211b781 => 'Inactive';

  @override
  String get inlineText_9c1ff072196e2d26 => 'Ready to perform live routing and security audits.';

  @override
  String get inlineText_df578dfdf0dafa9a => 'No speed tests recorded yet.';

  @override
  String get inlineText_5d6529256c6c68f0 => 'Launch direct';

  @override
  String get inlineText_23d5d93cf5f11e17 => 'Unlimited quota';

  @override
  String get inlineText_1228cd974a4510cf => 'Export Servers';

  @override
  String get inlineText_0323bbb0e3e24d50 => 'Allow IPv6';

  @override
  String get inlineText_58e27854800bc94b => 'Network unjammed: Kill switch, routes, and XFRM interfaces restored to normal.';

  @override
  String get inlineText_d71035f8d7c85940 => 'Protected Hotspot Options';

  @override
  String get inlineText_14bd9f9fb68a5859 => 'Select VPN Provider';

  @override
  String get inlineText_cbca739d8ccd07e1 => 'Inspect XFRM interface, table 220, IP rules, and verify live connectivity safely.';

  @override
  String get inlineText_d0527e4b3d658351 => 'Logout';

  @override
  String get inlineText_f7fa281a488a9a0d => '50 GB';

  @override
  String get inlineText_a38c71d45d21c4ab => 'Notify only';

  @override
  String get inlineText_b8352b44a588721c => 'App language';

  @override
  String get inlineText_e55142a1acfd8059 => 'نام کاربری (Username)';

  @override
  String get inlineText_f2b10ce04701badc => 'Load apps';

  @override
  String get inlineText_b1fe69e5cd48a270 => '-- ms';

  @override
  String get inlineText_989961ec7fc20bdd => 'Android app bypass applies after reconnecting the VPN.';

  @override
  String get inlineText_039b675cbfc3719c => 'HTTP/2 CONNECT';

  @override
  String get inlineText_7366b74aba11b666 => 'Console output copied to clipboard.';

  @override
  String get inlineText_0173658e5af8698d => 'Support bundle exported and copied to clipboard.';

  @override
  String get inlineText_9f658c229a11bef6 => 'Configures Windows ICS for the VPN adapter when Mobile Hotspot is active. The app verifies the ICS binding; client Internet traffic still needs an end-to-end check.';

  @override
  String get inlineText_73997b80ca90ece7 => 'No devices currently connected to hotspot.';

  @override
  String get inlineText_ebf5f31bd3fa8cf4 => 'Cancel Test';

  @override
  String get inlineText_4bfa799fae21b467 => 'Traffic Analytics';

  @override
  String get inlineText_b28b26cf1cc18caf => 'A calmer connection. A brighter world.';

  @override
  String get inlineText_ed95556c5c93ded1 => 'Country & App Bypass';

  @override
  String get inlineText_4cf9134d1c9ed485 => 'خروجی‌گرفتن از پروفایل‌های اتصال';

  @override
  String get inlineText_2a78025de6aae5e7 => 'Select';

  @override
  String get inlineText_cbbea9d808ebfe70 => 'Surfshark';

  @override
  String get inlineText_88921e28030e4255 => 'Service Password / Private Key';

  @override
  String get inlineText_39c3183ee0cbb997 => 'No advanced policy rules configured.';

  @override
  String get inlineText_6cb8a5b3137a00c3 => 'Selected country IP ranges bypass the VPN. Reconnect after changing rules. Domain-only rules need DNS-aware routing.';

  @override
  String get inlineText_8bb1de2dfce6294f => 'Starting connection…';

  @override
  String get inlineText_22965568d22a14ee => 'Connected';

  @override
  String get inlineText_e7e2af717bdfb964 => 'Auto (Fallback)';

  @override
  String get inlineText_42b5bc901ede1799 => '100 GB';

  @override
  String get inlineText_24ef681c569b5c42 => 'System Apps';

  @override
  String get inlineText_3e2421c56094293c => 'Route Table & XFRM Verification';

  @override
  String get inlineText_5d7cd082fc9987e9 => 'Force VPN Encrypted';

  @override
  String get inlineText_1159717463f1ebc3 => 'Service Username / Key ID';

  @override
  String get inlineText_0e76960093379060 => 'History';

  @override
  String get inlineText_cb0bf46bf1e385db => 'Import ZIP';

  @override
  String get inlineText_2da236423b3b5ad5 => 'Always-on and Lockdown cover supported VPN connections. DNS and IPv6 policies are enforced by the active tunnel.';

  @override
  String get inlineText_50829e8639527356 => 'Add application (.exe)';

  @override
  String get inlineText_f6f39fe075ffa5de => 'Add an application before enabling app bypass.';

  @override
  String get inlineText_5a99f6fa7e98657a => 'Scan QR';

  @override
  String get inlineText_c4b6bf5634f8ce91 => 'Explain why a destination routes via VPN or Direct ISP, with rule priority matching.';

  @override
  String get inlineText_cf0883343f4abef7 => 'Protocol';

  @override
  String get inlineText_adec3733feabdc2d => 'فایل‌ها با موفقیت استخراج شدند.';

  @override
  String get inlineText_0c567745c63c57bc => 'Android supports IPv4 and IPv6 CIDR bypass. Reconnect the VPN after changing these routes; app bypass also takes effect after reconnect.';

  @override
  String get inlineText_cb0544450e1be874 => 'Auditing…';

  @override
  String get inlineText_9e19b3ae1edc6135 => 'Android Lockdown is active';

  @override
  String get inlineText_0acb9208ef119b21 => 'Open Mobile Hotspot';

  @override
  String get inlineText_61118b57b609e8fd => 'Manage connection, security, and appearance';

  @override
  String get inlineText_ed077f3d8125d60d => 'Open';

  @override
  String get inlineText_bbf3d191d555c872 => 'Locations & Routes';

  @override
  String get inlineText_c01d52ac9ed5701a => 'Harmoney Pro Connection Error';

  @override
  String get inlineText_25a76b0a4ba5c39d => 'Safe Apply & LKG';

  @override
  String get inlineText_967549497036d513 => 'Deselect all';

  @override
  String get inlineText_72a47f8e322a40de => 'Protection HUD';

  @override
  String get inlineText_2398cc05005cca7f => 'Offline cache ready';

  @override
  String get inlineText_469f27ad0a12c557 => 'این شناسه به عنوان اثرانگشت سخت‌افزاری (Hardware Device ID) برای احراز هویت دستگاه در سرور استفاده می‌شود. می‌توانید مقادیر را تغییر دهید یا خودکار دریافت کنید:';

  @override
  String get inlineText_783547972fe4ca08 => 'IKEv2';

  @override
  String get inlineText_03f15c48644862ae => 'Default Hotspot Route';

  @override
  String get inlineText_bd5a05ddab828e6d => 'Start Guest Wi-Fi';

  @override
  String get inlineText_4968fc7fef5ea571 => 'Remaining traffic:';

  @override
  String get inlineText_52a0bc5a1f46b6a1 => 'Firefox Account';

  @override
  String get inlineText_bb93f3cc26e28600 => 'Temporary isolated guest Wi-Fi with automatic expiry and subnet isolation.';

  @override
  String get inlineText_b361f42b64c263d8 => 'Checking secure credential vault…';

  @override
  String get inlineText_7d037fcb85b5a1eb => 'Direct (Bypass VPN)';

  @override
  String get inlineText_e65731cec92db7d5 => 'A VPN operation is already running. Please wait for its status to update.';

  @override
  String get inlineText_f24d839a275e6eaa => 'Enable Hotspot Sharing (ICS)';

  @override
  String get inlineText_03a71a235bfb6b30 => 'ورود با موفقیت انجام شد و فهرست سرورها به‌روزرسانی گردید.';

  @override
  String get inlineText_52933373144828ee => 'Firefox Account Email / User';

  @override
  String get inlineText_d86322c4ceb937de => 'Country IPv4 ranges bypass the VPN after reconnecting. App bypass uses the Windows physical interface and requires the Harmoney service.';

  @override
  String get inlineText_77f0b86ebfb47aa6 => 'شناسه سخت‌افزاری دستگاه با موفقیت تنظیم شد.';

  @override
  String get inlineText_35d7442440a55ab9 => 'To prevent Android from killing the VPN connection in background, disable battery optimization for this app.';

  @override
  String get inlineText_3da7d703985421ec => 'Firefox data allowance';

  @override
  String get inlineText_316f766fb0bc3a72 => 'Manage Firefox VPN Account';

  @override
  String get inlineText_69b95013a9101213 => 'Advanced Policy Rules';

  @override
  String get inlineText_9d0c59a66cf45b32 => 'VPN-to-hotspot ICS binding verified.';

  @override
  String get inlineText_7ae00a283ea9b728 => 'Session Expired';

  @override
  String get inlineText_0dd786510199ca80 => 'تنظیمات اتصال سرویس';

  @override
  String get inlineText_708e318e0225bc88 => 'Stop Guest';

  @override
  String get inlineText_ad4b77a68783ec24 => 'Session Duration';

  @override
  String get inlineText_25dcc872936aab98 => 'Firefox Account credentials are sent directly to Mozilla by the local Windows helper. The password is not saved; only the account tokens needed for future connections are stored locally.';

  @override
  String get inlineText_219113c4bbe2e98c => 'Windows per-app bypass routes selected apps directly through the physical adapter, independent of the active VPN protocol. Windows build support and the privileged Harmoney service are required.';

  @override
  String get inlineText_21e3324fcec20e63 => '0 GB (Off)';

  @override
  String get inlineText_20636a0c41a3f954 => 'Advanced Routing & Protection';

  @override
  String get inlineText_dc8bf418d2bb68a6 => 'Secure VPN DNS';

  @override
  String get inlineText_a0b16ccf9021fc82 => 'Live Active';

  @override
  String get inlineText_abff5572a370fab7 => 'Queued…';

  @override
  String get inlineText_b666d8596482e260 => 'Xray routes selected IPv4/IPv6 ranges and the bundled Iranian domain list directly. Reconnect after changing rules.';

  @override
  String get inlineText_df74ccb45d0e395d => 'Route specific destinations through Direct, Force VPN, or Block.';

  @override
  String get inlineText_1509f561f2416598 => 'Save';

  @override
  String get inlineText_7122ed800123d8e7 => 'Force Hotspot VPN DNS';

  @override
  String get inlineText_6b97c41651da98ce => 'دریافت خودکار از سخت‌افزار سیستم';

  @override
  String get inlineText_6f98676a0a7b4953 => 'Private connection service';

  @override
  String get inlineText_0fb48c86db0c3f8f => 'Block connections without VPN';

  @override
  String get inlineText_2427a4a9d7993571 => 'Talker Logs';

  @override
  String get inlineText_da223b83cdddd9db => 'Run Hotspot Doctor';

  @override
  String get inlineText_a899ea0cfb536e60 => 'Renew session tokens or switch account';

  @override
  String get inlineText_70e3135873ca12f3 => 'برای بارگذاری سرورها، اشتراک خود را وارد کنید';

  @override
  String get inlineText_98e33b0f3104fcf1 => 'Applications';

  @override
  String get inlineText_c6c2daab1f7d2fe5 => 'Live Real-Time Speed';

  @override
  String get inlineText_81e9f4e64a840785 => 'Add at least one application to turn this on.';

  @override
  String get inlineText_942087cc2d41e013 => 'Retry';

  @override
  String get inlineText_3fb9aa9bdbb56bb6 => 'Create new list';

  @override
  String get inlineText_47e52e5e678a2248 => 'Logs copied to clipboard (secrets redacted).';

  @override
  String get inlineText_cf406ea597d7a11b => 'Diagnostic Terminal Output';

  @override
  String get inlineText_5c8925f30317c4ae => 'Block IPv6 (Leak Protection)';

  @override
  String get inlineText_d69fa3897fde1fd7 => 'Service username and password required for handshakes';

  @override
  String get inlineText_f98a2522000fbae8 => '200 GB';

  @override
  String get inlineText_30dc86f4e57e4278 => 'اعمال در تنظیمات';

  @override
  String get inlineText_14eee0b522b0a07f => 'Block all internet leaks when the VPN drops unexpectedly';

  @override
  String get inlineText_b813ec3c634e571c => 'Route chosen applications or network subnets outside the VPN.';

  @override
  String get inlineText_d21cca3751709e6f => 'Hardware-backed encryption: Credentials are encrypted in platform vault.';

  @override
  String get inlineText_ff4fcf35e586d0ca => 'Endpoint Candidates';

  @override
  String get inlineText_85455433f68a0eea => 'Route Explain';

  @override
  String get inlineText_e6e283499c38fe99 => 'Test all';

  @override
  String get inlineText_df8bb62c5262aace => 'باز کردن پوشه';

  @override
  String get inlineText_ca4ce07eeab21f24 => 'Personal subscriptions';

  @override
  String get inlineText_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineText_fbfd8ce759281a7c => 'Re-login';

  @override
  String get inlineText_48a39c950b733f9d => 'Repair Hotspot Routing';

  @override
  String get inlineText_1f914c4386c0676e => 'CONNECTED';

  @override
  String get inlineText_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineText_5e0104e1d0dd6cc2 => 'Start Speed Test';

  @override
  String get inlineText_9225ef77a358de37 => 'Always-on and Lockdown cover Firefox, WireGuard, IKEv2 and OpenVPN. DNS and IPv6 policies are enforced by each active tunnel profile.';

  @override
  String get inlineText_04b476ffe80f996f => 'Enable per-app bypass';

  @override
  String get inlineText_e0b8edec85fbec56 => 'پیکربندی سرور (پیش‌فرض سورس کد - فقط در حالت Debug)';

  @override
  String get inlineText_a47e46554344d955 => 'جهت اتصال آسان‌تر از خط فرمان (رمز عبور متن آشکار ذخیره می‌شود)';

  @override
  String get inlineText_23be2e66d9c671b4 => 'Load installed applications to configure per-app bypass.';

  @override
  String get inlineText_60cc8000034bbcc6 => 'ورود مقادیر و ساخت دستی';

  @override
  String get inlineText_14ea6d8e1758ce8f => 'ورود به حساب Harmoney Pro';

  @override
  String get inlineText_b764cdc0eab71374 => 'Unknown';

  @override
  String get inlineText_55b98eedd56ac65c => 'More protocols and connection options';

  @override
  String get inlineText_aa669b285cc133bf => 'Cisco';

  @override
  String get inlineText_5e414ee0c5da2dde => 'Ping All';

  @override
  String get inlineText_e281f68dc29144b2 => 'Add an HTTP or HTTPS subscription URL. Links are stored securely on this device.';

  @override
  String get inlineText_90f46423c0074765 => 'Session Download:';

  @override
  String get inlineText_36230e6a755f25c0 => 'Selected apps use the physical network directly. Other apps continue using the VPN.';

  @override
  String get inlineText_e0166a69e70a0063 => 'Enabled for Harmoney';

  @override
  String get inlineText_68eda25757c8e549 => 'Saved subscriptions';

  @override
  String get inlineText_639a40e82b9a96f0 => 'Connection';

  @override
  String get inlineText_2a5c4cf3cff579c9 => 'Select applications to bypass the VPN tunnel and connect directly to the internet.';

  @override
  String get inlineText_229b05d20a6d2706 => 'Firefox VPN Account';

  @override
  String get inlineText_e1f42d830cee8336 => 'Connection service';

  @override
  String get inlineText_69cd3590300a68c6 => 'Check status';

  @override
  String get inlineText_79f4939f31f74600 => 'Android Protection';

  @override
  String get inlineText_e9f61c5ca23f266f => 'Live connection events from all providers and protocols';

  @override
  String get inlineText_a0610c3d3b91cb4f => 'Harmoney Smart';

  @override
  String get inlineText_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineText_1a938f00d128e40c => 'Live Speed & Traffic';

  @override
  String get inlineText_74ca300a6cadb68a => 'Hotspot IPv6 Policy';

  @override
  String get inlineText_c2ed1ff176791192 => 'Routing Policy:';

  @override
  String get inlineText_b8b960fef99adfb1 => 'Harmoney Pro Sign In Required';

  @override
  String get inlineText_a23e527773f02a67 => 'Harmoney';

  @override
  String get inlineText_2067e249c2b1e5de => 'Quota Exceeded Action:';

  @override
  String get inlineText_3b61e4e936523550 => 'Explain';

  @override
  String get inlineText_bd8256cb9d1b917f => 'Rules apply to the active VPN route. UDP relay is not complete yet; apps requiring UDP may not be fully bypassed.';

  @override
  String get inlineText_664479f12348ca20 => 'شروع استخراج';

  @override
  String get inlineText_2fd1a96a8b9a93c0 => 'Surfshark Service Account';

  @override
  String get inlineText_37d1bd40cc9b7ba7 => 'Uses Windows native per-process routing to send selected apps directly over your physical network adapter. Requires a compatible Windows build and the Harmoney VPN service.';

  @override
  String get inlineText_e2419bb6585fdf13 => 'Country destinations bypass the VPN directly through the ISP; other traffic remains inside the VPN.';

  @override
  String get inlineText_566bd7ec6c74731b => 'No active hotspot interface detected on system.';

  @override
  String get inlineText_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineText_9e4a7faff61f59aa => 'Hardware Profile: Dell Latitude 7210 & Intel / Cellular LTE';

  @override
  String get inlineText_515c0e6425c1c144 => 'No CIDR rules yet.';

  @override
  String get inlineText_60c5a84642b61c53 => 'Enable Lockdown in Android VPN settings';

  @override
  String get inlineText_cb222670e743b957 => 'رمز عبور (Password)';

  @override
  String get inlineText_d1ad5bbe561caba5 => 'Block Destination';

  @override
  String get inlineText_54b8e0c0c268c154 => 'Copy Report';

  @override
  String get inlineText_7539a050c6489953 => 'The Harmoney Pro download link is not available yet.';

  @override
  String get inlineText_4759498ac2a719c6 => 'Create';

  @override
  String get inlineText_089899b425d4bcda => 'Add subscription';

  @override
  String get inlineText_838c8e30c9aeac8a => 'Guest Hotspot';

  @override
  String get inlineText_475e433587200d99 => 'Keep domestic services and banking reachable when the VPN drops';

  @override
  String get inlineText_0b4666b1dcc9f6f9 => 'Enable Split Tunneling';

  @override
  String get inlineText_cb2b6a572a8588d8 => 'Disconnecting…';

  @override
  String get inlineText_fb94fc702eb62ab7 => 'Download Harmoney Pro';

  @override
  String get inlineText_ad7b66a913a46286 => 'DISCONNECTING';

  @override
  String get inlineText_74a883a037bc227f => 'Settings';

  @override
  String get inlineText_6c2a96757bb1ab31 => 'API Settings';

  @override
  String get inlineText_a63b3bb0ad3689a0 => 'The previous VPN operation timed out. You can try again.';

  @override
  String get inlineText_b11e1aa7421b52e2 => 'Route test';

  @override
  String get inlineText_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineText_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineText_fa488105cb65db88 => 'Security session expired; please sign in again to use servers.';

  @override
  String get inlineText_4bd0e4ba0e817d11 => 'Unlimited (Off)';

  @override
  String get inlineText_690dbe9dc0993c42 => 'Recent';

  @override
  String get inlineText_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineText_92723a5ff9689c3d => 'Routes from Xray, WARP and MASQUE configurations. Connection is shown after traffic verification.';

  @override
  String get inlineText_c5842271209f9ff7 => 'Protocol coverage';

  @override
  String get inlineText_1fc9a387654d410f => 'Select all';

  @override
  String get inlineText_b0e17c2810653b13 => 'Install Now';

  @override
  String get inlineText_5aa9ef74c967df76 => 'Custom Location Lists';

  @override
  String get inlineText_ad208643ab98407d => 'Hotspot sharing preference saved.';

  @override
  String get inlineText_5e1133591cfeb5b0 => 'Hotspot clients only';

  @override
  String get inlineText_d636391ee4236395 => 'No matching events yet. Start a VPN connection to collect logs.';

  @override
  String get inlineText_ebbe7ab0b58e10be => 'Scan subscription QR';

  @override
  String get inlineText_092283a13b34e9ed => 'Show servers';

  @override
  String get inlineText_e548577f0fd46659 => 'Firefox Account credentials are sent directly to Mozilla by the native Android engine. Encrypted tokens never enter Flutter storage.';

  @override
  String get inlineText_a836bff92bbc5af0 => 'Re-login to account';

  @override
  String get inlineText_50688e3917acdfec => 'Export the selected server list as JSON and TXT files.';

  @override
  String get inlineText_9b13e877e4aa90a7 => 'Logged In';

  @override
  String get inlineText_854d3eab6d8d5d33 => 'ورود و بارگذاری سرورها';

  @override
  String get inlineText_c0d31ce834b82a7e => 'No favorite servers.';

  @override
  String get inlineText_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineText_76b23f49c19a08d8 => 'Redirect all device DNS queries to Surfshark DNS.';

  @override
  String get inlineText_5a23444828db654a => 'Manage';

  @override
  String get inlineText_5fedacfb015245b7 => 'Live Connection Logs (Stream)';

  @override
  String get inlineText_7446eabf9cf13622 => 'IPv6 leak protection';

  @override
  String get inlineText_2de8796023cbb4c7 => 'No Limit Set';

  @override
  String get inlineText_7a7832e87a88a9c7 => 'WFP applies the rules independently of IKEv2, WireGuard, OpenVPN, and Xray. UDP relay is not complete yet, so apps requiring UDP will not be fully bypassed.';

  @override
  String get inlineText_a0e1a519f04a9b3e => 'CONNECTING';

  @override
  String get inlineText_289afa804e34a45f => 'Allow Iran traffic during Lockdown';

  @override
  String get inlineText_ce13fbfce966190e => 'No subscriptions added yet.';

  @override
  String get inlineText_893e490d64407b8e => 'Quota information unavailable';

  @override
  String get inlineText_9b89006aec802e94 => 'Live Logs';

  @override
  String get inlineText_630c2f1c0ee1b8d7 => 'ACTIVE';

  @override
  String get inlineText_92340695899bd2d8 => 'Active';

  @override
  String get inlineText_203229774cceb5f3 => 'Manage Account';

  @override
  String get inlineText_bf6ccf81398eed34 => 'Add Policy';

  @override
  String get inlineText_a9884f2d7e028e02 => 'No imported profiles found.\\nImport a ZIP archive from Surfshark Manual Setup.';

  @override
  String get inlineText_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineText_94f105a3d269670f => 'Select a location or use fastest server';

  @override
  String get inlineText_472590ae974d4c1f => 'Provider';

  @override
  String get inlineText_5541de9515522b98 => 'DISCONNECTED';

  @override
  String get inlineText_0e223795fafb578e => 'Protection settings are applied by Android VpnService and take effect after reconnecting.';

  @override
  String get inlineText_bfd402b2f6f38125 => 'Sign in';

  @override
  String get inlineText_970c6a41454fa6ee => 'Overall Tunnel Health';

  @override
  String get inlineText_f4c3265a274f6fa8 => 'Route IPv6 through supported tunnels; reconnect to apply';

  @override
  String get inlineText_ecf1d7c868ee46fc => 'Mbps';

  @override
  String get inlineText_f9f60b474c0c751b => 'Start Guest Hotspot';

  @override
  String get inlineText_a840a9de3127ef53 => 'FireTunnel authenticates with Firefox Accounts. Credentials are sent only to the root-isolated native helper; tokens never enter Flutter storage.';

  @override
  String get inlineText_dcbf414d58c417be => 'Emergency Stop';

  @override
  String get inlineText_4f5845ea70794fc8 => 'Harmoney Anti-Censorship Core';

  @override
  String get inlineText_0234c7f3ac8b5b71 => 'Enable app bypass';

  @override
  String get inlineText_24b8d9733417f7f2 => 'Establishing secure tunnel…';

  @override
  String get inlineText_ec963ffc911b8401 => 'Checking…';

  @override
  String get inlineText_c46c2996102a4b2c => 'Encrypted tunnel verified with zero packet leakage.';

  @override
  String get inlineText_c0bf75bd78bf9572 => 'Change';

  @override
  String get inlineText_bcc0bcc9140b0c97 => 'Sign In';

  @override
  String get inlineText_e7977ed18b1df209 => 'Per-app bypass';

  @override
  String get inlineText_0e91610117029a62 => 'Refresh';

  @override
  String get inlineText_6defafa2caa65304 => 'Configure';

  @override
  String get inlineText_651f94aafffed603 => 'Disconnect is still being processed…';

  @override
  String get inlineText_8b9d3de8ae00c89c => 'Signing in…';

  @override
  String get inlineText_58b2c361864f4c09 => 'Always-on VPN';

  @override
  String get inlineText_8aa2064e8f385ad3 => 'Service Credentials & Keys';

  @override
  String get inlineText_7bcc95e0b5bd34c6 => 'Per-app VPN bypass';

  @override
  String get inlineText_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineText_67865eaee364dcbe => 'Force HTTPS traffic through TCP/TLS for consistent filtering.';

  @override
  String get inlineText_a52ace420f2175d0 => 'All';

  @override
  String get inlineText_2eb0c5a3ce65868c => 'Live bandwidth, data accounting & quota';

  @override
  String get inlineText_54386d5a6b84b6e8 => 'Battery Optimization Active (Doze Mode)';

  @override
  String get inlineText_d0e13ceb47c44a7f => 'Smart routing and personal subscriptions';

  @override
  String get inlineText_1924fc22b6e86d49 => 'Active Surfshark Protocol';

  @override
  String get inlineText_1eecb5c3f3e93223 => 'Reconnect the VPN to apply Android CIDR routes.';

  @override
  String get inlineText_0ef1d485c68962e3 => 'پیش‌فرض سرور';

  @override
  String get inlineText_1e77e9d04f19d6d9 => 'Host and Hotspot clients';

  @override
  String get inlineText_f5af9ab211b447cd => 'Speed report copied to clipboard!';

  @override
  String get inlineText_edb18cd663b5e4de => 'Block QUIC (UDP 443)';

  @override
  String get inlineText_ea32ef00138d4d85 => 'Manage connected devices, bandwidth quotas, guest Wi-Fi, and routing policies.';

  @override
  String get inlineText_46ff63176dfa61e2 => 'Force VPN';

  @override
  String get inlineText_f6f75ce9317a16db => 'Enforce Quota';

  @override
  String get inlineText_72fe71cb37d209d2 => 'Refresh Status';

  @override
  String get inlineText_56b598dee4ddc136 => 'FASTEST ⚡';

  @override
  String get inlineText_19766ed6ccb2f4a3 => 'Cancel';

  @override
  String get inlineText_7a1f2a83aca9a081 => 'Favorites';

  @override
  String get inlineText_876662d1d94ad13b => 'Live Verification';

  @override
  String get inlineText_bf26c2ac087da6ff => 'Bypass';

  @override
  String get inlineText_dfe40efe921fe88e => 'Updating…';

  @override
  String get inlineText_247ea0cd6733f4fc => 'Emergency Stop executed: Processes terminated and physical network unjammed.';

  @override
  String get inlineText_7207233f2b0688ac => 'Quick connect';

  @override
  String get inlineText_3c4846f1083e22ec => 'Split Tunneling';

  @override
  String get inlineText_ec93679622950c2c => 'محل ذخیره پیش‌فرض:';

  @override
  String get inlineText_a76e13b9839270eb => 'Restore';

  @override
  String get inlineText_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineText_c4b662bd95db40f1 => 'Clear stored credentials from this device';

  @override
  String get inlineText_adde42042c5c3caa => 'Pause Device Connection';

  @override
  String get inlineText_200bc33c838b6604 => 'شناسه پیش‌فرض سرور';

  @override
  String get inlineText_ea61bc15688d1e48 => 'Copied!';

  @override
  String get inlineText_d3ee5446e626ae8f => 'Network Subnets (CIDRs)';

  @override
  String get inlineText_1640ef1a61f9a5ee => 'Country bypass DAT rules updated. Reconnect VPN to apply.';

  @override
  String get inlineText_d403c686f6a10480 => 'Connecting';

  @override
  String get inlineText_351d257b580bc419 => 'Choose your desired VPN network provider';

  @override
  String get inlineText_1b4154057e37a0ff => 'Sign In to Harmoney Pro';

  @override
  String get inlineText_ae4e9b1ef2aa3860 => 'Select Surfshark Protocol';

  @override
  String get inlineText_83b12c2216efb4fd => 'Clear';

  @override
  String get inlineText_269f0582347dbdf6 => 'Recommended Fast Routes';

  @override
  String get inlineText_9918aaf803c54fcf => 'Choose QR image';

  @override
  String get inlineText_307e253c39bae652 => 'تست اتصال';

  @override
  String get inlineText_337db382095ce88d => 'Redirect device DNS queries through the selected VPN.';

  @override
  String get inlineText_5bb6d1b367fc7674 => 'WireGuard';

  @override
  String get inlineText_e8696f00501ad45a => 'No imported profiles found.\nImport a ZIP archive from Surfshark Manual Setup.';

  @override
  String get inlineText_b0230c537ca88c85 => 'User Apps';

  @override
  String get inlineText_e9d51941d0c1f37b => 'VPN Hotspot Sharing (Windows ICS)';

  @override
  String get inlineText_6bcc8512de553613 => 'Show All Servers';

  @override
  String get inlineText_9d4be9539f27c657 => 'No custom lists created yet.';

  @override
  String get inlineText_782ec78be81185c6 => 'FireTunnel Token / Password';

  @override
  String get inlineText_8a76134e54b9cfac => 'KEY REQUIRED';

  @override
  String get inlineText_75081b593d15cf6e => 'Disabled';

  @override
  String get inlineText_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineText_471354282a521dd1 => 'New Custom List';

  @override
  String get inlineText_c7a43600b2a6507c => 'Sign In / Account';

  @override
  String get inlineText_a919cfce15c49685 => 'Lockdown mode (Kill Switch)';

  @override
  String get inlineText_dd9e7664f013c1e5 => 'Credentials encrypted in privileged platform keystore';

  @override
  String get inlineText_f50e254cf57f39fd => 'Throttle to 128kbit/s';

  @override
  String get inlineText_4e1af7c74096cf0a => 'Operation failed';

  @override
  String get inlineText_43e3ece73ff8f4eb => 'remaining';

  @override
  String get inlineText_e94356112ce4c59c => 'Hotspot & Devices';

  @override
  String get inlineText_313cbecb4dd35728 => 'بستن';

  @override
  String get inlineText_d6eafe8235910042 => 'Download';

  @override
  String get inlineText_06bacdb5d18b0261 => 'Block internet';

  @override
  String get inlineText_8200a83deae2141b => 'Add CIDR rule';

  @override
  String get inlineText_a429cd15905e58a5 => 'Set Quota';

  @override
  String get inlineText_57c95945cb8fe988 => 'VPN service credentials saved securely.';

  @override
  String get inlineText_4ff946afb073da91 => 'Manage VPN Profiles';

  @override
  String get inlineText_9bf1e054ed4cbacb => 'ذخیره نام کاربری و رمز عبور در فایل متنی';

  @override
  String get inlineText_6cb535909a7f3875 => 'Run Full Audit';

  @override
  String get inlineText_8fcbf6bb3bf0b5a0 => 'Sort by latency';

  @override
  String get inlineText_45ee3e003650a75f => 'Add Routing Policy Rule';

  @override
  String get inlineText_04b93833872cc896 => 'Disconnect requested…';

  @override
  String get inlineText_ad3d9699142e5339 => 'Save securely';

  @override
  String get inlineText_c63e407525237f8d => 'VPN Debug Logs';

  @override
  String get inlineText_530692d19626e11a => 'Xray routes selected IPv4/IPv6 ranges and the bundled Iranian domain list directly. Windows IKEv2 route injection remains IPv4-only. Reconnect after changing rules.';

  @override
  String get inlineText_7c147e122ed7eeac => 'OpenVPN';

  @override
  String get inlineText_e17b6227325e1a8d => 'Smart Service Suitability';

  @override
  String get inlineText_73bfa58718abc908 => 'Tunnel path audits, leak tests, latency probes, and runtime telemetry';

  @override
  String get inlineText_659e50811965fe84 => 'Monthly Allowance';

  @override
  String get inlineText_6a4c3a4483b04488 => 'Ping';

  @override
  String get inlineText_11a6767d5674c7e4 => 'Done';

  @override
  String get inlineText_acfc5be785a9bb3d => 'Disconnect';

  @override
  String get inlineText_c3812fc4acb861d5 => 'Remove';

  @override
  String get inlineText_fe4f5f9fd7be7d92 => 'Client Isolation';

  @override
  String get inlineText_865e89de78d94c74 => 'Upload';

  @override
  String get inlineText_0004bf6db9f12d54 => 'Update Country Rules';

  @override
  String get inlineText_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineText_a8b3ef62feba073f => 'No servers found.';

  @override
  String get inlineText_9ef0f877893218f3 => 'Firefox VPN Token & Auth';

  @override
  String get inlineText_23759997b3c59884 => 'UNKNOWN';

  @override
  String get inlineText_e3b78e09863c99ac => 'Hotspot Doctor & Diagnostics';

  @override
  String get inlineText_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineText_54a0e8c17ebb21a1 => 'Error';

  @override
  String get inlineText_c8fd5b73d111ee1d => 'by Harmoney';

  @override
  String get inlineText_44e1911932d93644 => 'Harmoney Pro Service';

  @override
  String get inlineText_f6be68de3c8d5e7d => 'Monthly Data Quota';

  @override
  String get inlineText_51452219a8542052 => 'No endpoint candidates configured.';

  @override
  String get inlineText_f493cd9c7ae396ec => 'Sign in to activate Firefox tunnel and view data quota.';

  @override
  String get inlineText_8e1b786c7913210c => 'Save Quota';

  @override
  String get inlineText_efb52e7172b77731 => 'Theme';

  @override
  String get inlineText_2c2648394a4fe357 => 'Add split-tunnel CIDR';

  @override
  String get inlineText_ff6d5def69d21f32 => 'Prevent connected hotspot clients from communicating directly.';

  @override
  String get inlineText_532eaabd9574880d => 'Test';

  @override
  String get inlineText_02a2c8aa276c0c36 => 'Tunnel-managed DNS; reconnect to apply';

  @override
  String get inlineText_abaf4ed786bb9340 => 'Domains, IPv4 addresses or CIDRs that always bypass the VPN';

  @override
  String get inlineText_49a2fc4df1b8bad5 => 'Lightweight Firefox VPN tunnel';

  @override
  String get inlineText_2faba03e2b8726a9 => 'Last Speed Benchmark:';

  @override
  String get inlineText_5bb4dc6f47d4c040 => 'CONNECT';

  @override
  String get inlineText_9d4ad0b61b2359e9 => 'Import ZIP Archive';

  @override
  String get inlineText_243a20f9ba6c2892 => 'You will receive visual alerts when reaching this limit.';

  @override
  String get inlineText_d3ae19164d4f0f44 => 'Diagnostics & Health';

  @override
  String get inlineText_3dd7fcefed0e482c => 'Hotspot Inactive';

  @override
  String get inlineAttribute_a4282e4b2298b90b => ' of ';

  @override
  String get inlineAttribute_1a765360a12ba19c => 'Search countries…';

  @override
  String get inlineAttribute_74c8361a4a1ca4c4 => 'Route action';

  @override
  String get inlineAttribute_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineAttribute_440488e7af1a1602 => 'Domain, IPv4 or CIDR';

  @override
  String get inlineAttribute_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineAttribute_372167bb30249862 => 'Data Quota (MB, 0 = unlimited)';

  @override
  String get inlineAttribute_4b329f46e3e4aa50 => 'باقیمانده';

  @override
  String get inlineAttribute_8d634757de9d475f => '✓ Verified: All checks passed (XFRM, table 220, HTTPS trace)';

  @override
  String get inlineAttribute_b9893538a61f89ed => 'نام کاربری اشتراک';

  @override
  String get inlineAttribute_2c80752638d7bd54 => 'چسباندن';

  @override
  String get inlineAttribute_df3b5afaf2778138 => 'Domain or IP';

  @override
  String get inlineAttribute_1803685bb41d1d8d => 'Subscription URL';

  @override
  String get inlineAttribute_09231cb8338a0158 => 'Target Domain or CIDR (e.g. 1.1.1.1/32)';

  @override
  String get inlineAttribute_474276a023bed5d8 => 'نام دلخواه (اختیاری)';

  @override
  String get inlineAttribute_69612b885a0aff86 => 'سرور محبوب';

  @override
  String get inlineAttribute_e7cf3ef4f17c3999 => 'Password';

  @override
  String get inlineAttribute_f3380f7b44bd70af => 'Paste';

  @override
  String get inlineAttribute_ad0eae0c2cd935dc => 'armoney';

  @override
  String get inlineAttribute_3c128b5436b6d704 => 'Refresh all';

  @override
  String get inlineAttribute_969ccbd3cf6300ec => 'Email';

  @override
  String get inlineAttribute_1b37568c4311efeb => 'جستجو در نام یا پکیج برنامه‌ها';

  @override
  String get inlineAttribute_4524cd31be7128c2 => 'e.g. 192.168.1.0/24 or 10.0.0.1/32';

  @override
  String get inlineAttribute_6077b2acb8754468 => 'Enable endpoint';

  @override
  String get inlineAttribute_b84364651ab4f422 => 'CIDR or IP';

  @override
  String get inlineAttribute_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineAttribute_be420e2629f2ebfa => 'Email verification code';

  @override
  String get inlineAttribute_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineAttribute_b29904a25f1802a7 => 'Duration (Minutes, 5-1440)';

  @override
  String get inlineAttribute_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineAttribute_428ffb88a815b9be => 'Clear view';

  @override
  String get inlineAttribute_6016fb957fe261cc => 'بروزرسانی همه';

  @override
  String get inlineAttribute_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineAttribute_a1ab6eca52db1b3b => 'آزمون سرور';

  @override
  String get inlineAttribute_4504b2c82bef3d20 => 'Copy logs';

  @override
  String get inlineAttribute_356c851e4ec59a3d => 'Configure device';

  @override
  String get inlineAttribute_c2ef8dd2545d2b04 => 'List name (e.g. European Fast)';

  @override
  String get inlineAttribute_f69c34c2fc4b9667 => 'Favorite server';

  @override
  String get inlineAttribute_00ea6b3b42dfb4b5 => 'شخصی‌سازی و ساخت دستی شناسه سخت‌افزاری';

  @override
  String get inlineAttribute_b073f6c68ef87211 => 'Scope';

  @override
  String get inlineAttribute_59ca629220a63ede => 'حذف';

  @override
  String get inlineAttribute_47311af432a79c40 => 'Delete profile';

  @override
  String get inlineAttribute_80884fb559e05bd9 => 'Disable endpoint';

  @override
  String get inlineAttribute_b0e17c2810653b13 => 'Install Now';

  @override
  String get inlineAttribute_6769ff871d28e2ce => 'Close Output';

  @override
  String get inlineAttribute_01e8ee2044c91ec5 => '••••••••••••••••';

  @override
  String get inlineAttribute_cdf0cf9ecdfecba8 => 'Custom Lists';

  @override
  String get inlineAttribute_05eccbc907509b4b => 'Speed limit (kbit/s, 0 = unlimited)';

  @override
  String get inlineAttribute_d4e54f76384bf545 => 'Retry probe';

  @override
  String get inlineAttribute_d3a8a299660b14d0 => 'Clear logs';

  @override
  String get inlineAttribute_7a3517625d7f32a6 => 'Copy Output';

  @override
  String get inlineAttribute_96f681e1e0e80f53 => 'Filter by provider, protocol, status, or error';

  @override
  String get inlineAttribute_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineAttribute_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineAttribute_842d8e425ecb5b64 => ' ?? ';

  @override
  String get inlineAttribute_ce21ed09a64c529b => 'Copied subscription link detected.';

  @override
  String get inlineAttribute_1e5a5a18ae04113a => 'Quick Menu';

  @override
  String get inlineAttribute_c611981fab983bc6 => 'Policy';

  @override
  String get inlineAttribute_43e3ece73ff8f4eb => 'remaining';

  @override
  String get inlineAttribute_a624a1e41ffdc6d6 => ' از ';

  @override
  String get inlineAttribute_fb156130b17c4be3 => 'Account options';

  @override
  String get inlineAttribute_0e08705e56eb56d8 => 'Copy visible logs';

  @override
  String get inlineAttribute_c16db1ad02461665 => 'Debug Logs';

  @override
  String get inlineAttribute_f16edb7443f05225 => 'Refresh Guest Status';

  @override
  String get inlineAttribute_ca4ce07eeab21f24 => 'Personal subscriptions';

  @override
  String get inlineAttribute_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineAttribute_0b33748029674d12 => 'Search country, city, IP...';

  @override
  String get inlineAttribute_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineAttribute_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineAttribute_a291d1863aeedb00 => 'لینک کپی‌شده پیدا شد.';

  @override
  String get inlineAttribute_44bd7ae60f478fae => 'H';

  @override
  String get inlineAttribute_c97f606c82316bc1 => 'Export log file';

  @override
  String get inlineAttribute_e09b37bcc4f301f4 => 'Name (optional)';

  @override
  String get inlineAttribute_0ca0dfe5e1ff7a8e => 'عملیات حساب';

  @override
  String get inlineAttribute_c3812fc4acb861d5 => 'Remove';

  @override
  String get inlineAttribute_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineAttribute_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineAttribute_9b64398e9f8fef53 => 'Test server';

  @override
  String get inlineAttribute_ea9d303a5e54fb42 => 'Filter by phase (PREPARING, IKE, AUTHENTICATING, VERIFYING, CONNECTED, FAILED) or keyword…';

  @override
  String get inlineAttribute_d640c7421da06661 => 'Resume';

  @override
  String get inlineAttribute_140669bdb031e927 => 'لینک اشتراک';

  @override
  String get inlineAttribute_16f78a7d6317f102 => 'username';

  @override
  String get inlineAttribute_e1a0ff7a5353c7fe => 'Guest SSID';

  @override
  String get inlineAttribute_e098b630f04d6d69 => 'Domain or IP to explain';

  @override
  String get inlineAttribute_0f39d38fb65968d0 => 'رمز عبور اشتراک';

  @override
  String get inlineAttribute_858e4ba7a29fd38b => 'Pause';

  @override
  String get inlineAttribute_3dea43271fc3f002 => 'Search installed apps or packages';

  @override
  String get inlineAttribute_ac8619ca1957889c => 'اشتراک‌های شخصی';

  @override
  String get inlineAttribute_f8a5decc321d9f7a => 'جستجوی کشور، شهر، آی‌پی...';

  @override
  String get inlineAttribute_82ab1760fe92313f => 'Waiting for engine connection log stream events?';

  @override
  String get inlineAttribute_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineTextTemplate_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineTextTemplate_4b5e556c141daca0 => 'Failed to update app rule: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_fe5115c86ab563dd => 'QZXVAR0QZX CIDRs';

  @override
  String get inlineTextTemplate_f6fd414931d6a430 => 'Latency test failed: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineTextTemplate_fe4eac0d19b1f8b2 => 'Export failed: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_846aa6f62acf906c => 'Failed to delete: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineTextTemplate_0b59208593d747ad => 'Could not add application: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_bfafae05cba5bb86 => 'Could not load servers: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_1a1e3bf73b281b6d => 'Could not load app bypass settings: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_3c17c68905f8856a => 'Error: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_e52ff58d5b3af8f0 => 'Country Bypass: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_8bc4d9b4f92c60ab => 'Could not update app bypass: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_8df4368ecb09de86 => 'Unjam failed: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_0d1e9be15aed1231 => 'Connected Devices (QZXVAR0QZX)';

  @override
  String get inlineTextTemplate_601fcd78f13053e1 => '↓ QZXVAR0QZX Mbps';

  @override
  String get inlineTextTemplate_972ff659f6e27b76 => 'شناسه سخت‌افزاری از QZXVAR0QZX (QZXVAR1QZX) دریافت شد.';

  @override
  String get inlineTextTemplate_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineTextTemplate_a170e1c90b9a1695 => 'Saved to QZXVAR0QZX';

  @override
  String get inlineTextTemplate_7e941c183788df69 => 'Ping: QZXVAR0QZXms · Jitter: QZXVAR1QZXms · QZXVAR2QZX';

  @override
  String get inlineTextTemplate_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineTextTemplate_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineTextTemplate_e100a78e26906915 => 'QZXVAR0QZX left';

  @override
  String get inlineTextTemplate_e24a324bdb714d54 => 'Updated: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_a8f0cc53b0dca9ef => 'Could not remove application: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_2347df78592d100a => 'QZXVAR0QZX countries selected (QZXVAR1QZX CIDRs)';

  @override
  String get inlineTextTemplate_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineTextTemplate_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineTextTemplate_2b5bf24f64089836 => 'Emergency Stop error: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineTextTemplate_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineTextTemplate_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineTextTemplate_e416fbfd7a91ed9f => 'Imported QZXVAR0QZX WireGuard and QZXVAR1QZX OpenVPN profiles securely.';

  @override
  String get inlineTextTemplate_892b097363290e03 => 'Status: QZXVAR0QZX · Latency: QZXVAR1QZX';

  @override
  String get inlineTextTemplate_876c1a21e4aca06e => 'Version: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineTextTemplate_a1868bb4d6de7026 => 'Configure Device: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_df0ea8d18fa1b297 => 'Not supported on QZXVAR0QZX';

  @override
  String get inlineTextTemplate_d437f3d2dc2207b4 => 'Failed to update autostart: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_8e339613f844cd3f => 'QZXVAR0QZX Mbps (Ping QZXVAR1QZXms)';

  @override
  String get inlineTextTemplate_b0e17c2810653b13 => 'Install Now';

  @override
  String get inlineTextTemplate_251f8b3bcb3ff541 => 'No imported QZXVAR0QZX profile matches the selected Surfshark locations.';

  @override
  String get inlineTextTemplate_b027e90663d6b737 => 'QZXVAR0QZX locations';

  @override
  String get inlineTextTemplate_732cc46253cae40a => 'QZXVAR0QZXms';

  @override
  String get inlineTextTemplate_169e482cbbd960b7 => 'QZXVAR0QZX added';

  @override
  String get inlineTextTemplate_10d0ba33ae09b3a4 => 'Policy: QZXVAR0QZX · Today: QZXVAR1QZX';

  @override
  String get inlineTextTemplate_1ec56334a0b24b7c => '↑ QZXVAR0QZX Mbps';

  @override
  String get inlineTextTemplate_e61e185de8f8a9d7 => 'Disconnect failed: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_d6975653ba21c6a2 => 'Failed to update Always-on VPN: QZXVAR0QZX';

  @override
  String get inlineTextTemplate_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineTextTemplate_94fa013c0e7b11f3 => 'Advanced System Routing on QZXVAR0QZX';

  @override
  String get inlineTextTemplate_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineAttributeTemplate_73b6e48a1b552d11 => 'Later';

  @override
  String get inlineAttributeTemplate_2e5f79bb94a8c40b => 'Checking...';

  @override
  String get inlineAttributeTemplate_c1c1009d3f37ec05 => 'Update';

  @override
  String get inlineAttributeTemplate_a4738b604a205c2e => 'Check Updates';

  @override
  String get inlineAttributeTemplate_ccccab7c5d91fcc1 => 'Release Highlights';

  @override
  String get inlineAttributeTemplate_3e695daee969126c => 'Package installer launched. Tap below if you need to relaunch.';

  @override
  String get inlineAttributeTemplate_be6ee118f6ce86a8 => 'Downloading Update...';

  @override
  String get inlineAttributeTemplate_2f1118ed7cdb58dc => 'No log lines matched the filter \"QZXVAR0QZX\" [QZXVAR1QZX].';

  @override
  String get inlineAttributeTemplate_005ef7725a64c7ed => 'New Version Available';

  @override
  String get inlineAttributeTemplate_fd67fb8b214d0251 => 'Harmoney Update Available';

  @override
  String get inlineAttributeTemplate_0c16e4802957bf2a => 'Update Interrupted';

  @override
  String get inlineAttributeTemplate_1d653fc4503ec979 => 'The update will download and install directly inside Harmoney.';

  @override
  String get inlineAttributeTemplate_48845bff334a50a5 => 'Dismiss';

  @override
  String get inlineAttributeTemplate_c0671aa2f2dd814a => 'Download & Update';

  @override
  String get inlineAttributeTemplate_4a4177e796293af3 => '⚠ Notice: QZXVAR0QZX';

  @override
  String get inlineAttributeTemplate_fede49e2e980819c => 'Wi-Fi QR URI: QZXVAR0QZX';

  @override
  String get inlineAttributeTemplate_4511036a54304f80 => 'Update Download Complete';

  @override
  String get inlineAttributeTemplate_b0e17c2810653b13 => 'Install Now';

  @override
  String get appString_AboutUs => 'About us';

  @override
  String get appString_AboutDescription => 'Harmoney is built by Harmoney, providing a secure, high-speed, and resilient way to access the open internet.';

  @override
  String get appString_Connect => 'Connect';

  @override
  String get appString_Disconnect => 'Disconnect';

  @override
  String get appString_Connected => 'Connected';

  @override
  String get appString_Disconnected => 'Disconnected';

  @override
  String get appString_Locations => 'Locations';

  @override
  String get appString_Statistics => 'Speed';

  @override
  String get appString_SplitTunnel => 'Split Tunnel';

  @override
  String get appString_Hotspot => 'Hotspot';

  @override
  String get appString_Protection => 'Security';

  @override
  String get appString_LeakProtection => 'Leak protection';

  @override
  String get appString_SystemSafeguards => 'System safeguards';

  @override
  String get appString_CountryBypass => 'Country bypass';

  @override
  String get appString_Diagnostics => 'Diagnostics';

  @override
  String get appString_Settings => 'Settings';

  @override
  String get appString_Connection => 'Connection';

  @override
  String get appString_AutoConnect => 'Auto-connect';

  @override
  String get appString_AutoConnectSubtitle => 'Connect automatically on supported networks';

  @override
  String get appString_KillSwitch => 'Kill switch';

  @override
  String get appString_KillSwitchSubtitle => 'Block traffic if the VPN connection drops';

  @override
  String get appString_Protocol => 'Protocol';

  @override
  String get appString_VpnProvider => 'VPN provider';

  @override
  String get appString_ProviderSeparated => 'Provider layer is optimized for speed and isolation';

  @override
  String get appString_Privacy => 'Privacy';

  @override
  String get appString_DnsLeakProtection => 'DNS leak protection';

  @override
  String get appString_Ipv6LeakProtection => 'IPv6 leak protection';

  @override
  String get appString_Appearance => 'Appearance';

  @override
  String get appString_System => 'System';

  @override
  String get appString_Light => 'Light';

  @override
  String get appString_Dark => 'Dark';

  @override
  String get appString_Language => 'Language';

  @override
  String get appString_LoadApps => 'Load apps';

  @override
  String get appString_SearchingApps => 'Search apps...';

  @override
  String get appString_BypassIran => 'Bypass Domestic Websites';

  @override
  String get appString_ConnectedTo => 'Connected to';

  @override
  String get directFa_26fc31773fa51ad0 => 'Split Tunnel & Bypass';

  @override
  String get directEn_c982c0c4cfe9c935 => 'Split Tunnel & Bypass';

  @override
  String get directFa_1017a10a74fc8b4c => 'Country & App Bypass';

  @override
  String get directEn_ed95556c5c93ded1 => 'Country & App Bypass';

  @override
  String get directFa_39dbd18df3aa1b73 => 'Security & Kill Switch';

  @override
  String get directEn_0efd36b42d93a9cf => 'Security & Kill Switch';

  @override
  String get directFa_fceec8184bae394a => 'Hotspot Shield';

  @override
  String get directEn_affe75e7c781f044 => 'Hotspot Shield';

  @override
  String get directFa_6a291c533e65eac9 => 'Traffic Analytics';

  @override
  String get directEn_26bce86e894398f0 => 'Traffic Stats';

  @override
  String get directFa_149bc72261ed557a => 'VPN Hotspot Sharing (Windows ICS)';

  @override
  String get directEn_e9d51941d0c1f37b => 'VPN Hotspot Sharing (Windows ICS)';

  @override
  String get directFa_ffc1a00b2cd1bd6a => 'Share secure encrypted tunnel with phones & tablets';

  @override
  String get directEn_8693a5d72c6b23fa => 'Share secure encrypted tunnel with phones & tablets';

  @override
  String get directFa_6889a68d04894859 => 'Enable Hotspot Sharing (ICS)';

  @override
  String get directEn_f24d839a275e6eaa => 'Enable Hotspot Sharing (ICS)';

  @override
  String get directFa_3bcda1eec5106a5d => 'Configures Windows ICS for the VPN adapter when Mobile Hotspot is active. The app verifies the ICS binding; client Internet traffic still needs an end-to-end check.';

  @override
  String get directEn_9f658c229a11bef6 => 'Configures Windows ICS for the VPN adapter when Mobile Hotspot is active. The app verifies the ICS binding; client Internet traffic still needs an end-to-end check.';

  @override
  String get directFa_9bbd9bac026872c1 => 'Hardware Profile: Dell Latitude 7210 & Intel / Cellular LTE';

  @override
  String get directEn_9e4a7faff61f59aa => 'Hardware Profile: Dell Latitude 7210 & Intel / Cellular LTE';

  @override
  String get directFa_50c65a3d13ee268a => '• Automatic MTU optimization to 1350 preventing packet fragmentation.\n• Intelligent dual-uplink support (Intel Wi-Fi + Cellular LTE).\n• Zero client-side software configuration needed on connected devices.';

  @override
  String get directEn_0aa0eafed86db230 => '• Automatic MTU optimization to 1350 preventing packet fragmentation.\n• Intelligent dual-uplink support (Intel Wi-Fi + Cellular LTE).\n• Zero client-side software configuration needed on connected devices.';

  @override
  String get directFa_62610231d271d134 => 'Open Mobile Hotspot';

  @override
  String get directEn_0acb9208ef119b21 => 'Open Mobile Hotspot';

  @override
  String get directFa_3a920a034280df3b => 'Hotspot sharing preference saved.';

  @override
  String get directEn_ad208643ab98407d => 'Hotspot sharing preference saved.';

  @override
  String get directFa_674da212761c9897 => 'Save preference';

  @override
  String get directEn_fa174cea0ac4357d => 'Save preference';

  @override
  String get directFa_0b29754285a30eb5 => 'servers';

  @override
  String get directEn_8e3dc1afbc3ec556 => 'servers';

  @override
  String get directFa_7b7b1f9f056db6a2 => 'Tap to view and select';

  @override
  String get directEn_2cc9305c93b06b14 => 'Tap to view and select';

  @override
  String get directFa_3f513f6f165abe3a => 'Pinging';

  @override
  String get directEn_1575703aa4004510 => 'Pinging';

  @override
  String get directFa_bfe619723f7415af => 'Run a manual latency check';

  @override
  String get directEn_ee7ff7f0b25192c5 => 'Run a manual latency check';

  @override
  String get directFa_047e26dc40ad2e6c => 'Ping all';

  @override
  String get directEn_c749d615571ec59b => 'Ping all';

  @override
  String get directFa_9eb2b971b235433d => ' · No response';

  @override
  String get directEn_52d81add0d0bba64 => ' · No response';

  @override
  String get directFa_490a4c57bf7ab538 => 'CONNECTED';

  @override
  String get directEn_22965568d22a14ee => 'Connected';

  @override
  String get directFa_c5ddc53614e359dd => 'Not compatible with this device';

  @override
  String get directEn_5de8c3898d69b278 => 'Not compatible with this device';

  @override
  String get directFa_631b37d4472bc4af => 'Locations & Routes';

  @override
  String get directEn_bbf3d191d555c872 => 'Locations & Routes';

  @override
  String get directFa_19062eabc808d3cb => 'Smart routing and personal subscriptions';

  @override
  String get directEn_d0e13ceb47c44a7f => 'Smart routing and personal subscriptions';

  @override
  String get directFa_dfb5490308844c12 => 'Lightweight Firefox VPN tunnel';

  @override
  String get directEn_49a2fc4df1b8bad5 => 'Lightweight Firefox VPN tunnel';

  @override
  String get directFa_0aad2895c1e3bafe => 'Select connection service';

  @override
  String get directEn_46b5d935b82dd8e0 => 'Select connection service';

  @override
  String get directFa_8f4835903634041e => 'Firefox VPN protocol';

  @override
  String get directEn_034fc31b30e178f0 => 'Firefox VPN protocol';

  @override
  String get directFa_1a192f60ba3a8289 => 'Fetching & validating feeds…';

  @override
  String get directEn_13e340711e620242 => 'Fetching & validating feeds…';

  @override
  String get directFa_82fc0e4970c24375 => 'Offline; preserved last healthy config';

  @override
  String get directEn_4b55315990907923 => 'Offline; preserved last healthy config';

  @override
  String get directFa_19df9dbf599af948 => 'Harmoney bundled sources';

  @override
  String get directEn_622490dc634188e3 => 'Harmoney bundled sources';

  @override
  String get directFa_72eadf7b1642b492 => 'Refresh';

  @override
  String get directEn_0e91610117029a62 => 'Refresh';

  @override
  String get directFa_d129f6c328ebc070 => 'Never';

  @override
  String get directEn_6300ef800bb88429 => 'Never';

  @override
  String get directFa_bd917b26118b13c4 => 'Just now';

  @override
  String get directEn_66f53417d3b7797a => 'Just now';

  @override
  String get directFa_d2a9c0e9a77e362f => 'Ping all visible';

  @override
  String get directEn_49ee72faa5b743f7 => 'Ping all visible';

  @override
  String get directFa_54a0cc043e8b2469 => 'Ping All';

  @override
  String get directEn_5e414ee0c5da2dde => 'Ping All';

  @override
  String get directFa_cc03494b29df4f8b => 'Refresh Catalog';

  @override
  String get directEn_a7a480dfb660e610 => 'Refresh Catalog';

  @override
  String get directFa_15270886eaddc37f => 'All';

  @override
  String get directEn_a52ace420f2175d0 => 'All';

  @override
  String get directFa_bbe41ad560aa142b => 'Recent';

  @override
  String get directEn_690dbe9dc0993c42 => 'Recent';

  @override
  String get directFa_5f2e4ba5353998cd => 'Smart & Warp';

  @override
  String get directEn_e96958fdea5d076e => 'Smart & Warp';

  @override
  String get directFa_52ae64718fc96a07 => 'Stealth';

  @override
  String get directEn_526a40a447ddd7aa => 'Stealth';

  @override
  String get directFa_d49e29aa06fa679a => 'Favorites';

  @override
  String get directEn_7a1f2a83aca9a081 => 'Favorites';

  @override
  String get directFa_be1aa9e3bcbefea8 => 'Lowest Ping';

  @override
  String get directEn_d96e4d444648ad39 => 'Lowest Ping';

  @override
  String get directFa_b7280ab58d1ef0d3 => 'Online Only';

  @override
  String get directEn_39abe2a6fc13b2b2 => 'Online Only';

  @override
  String get directEn_630c2f1c0ee1b8d7 => 'ACTIVE';

  @override
  String get directFa_c6bdd72afead66be => 'Recent';

  @override
  String get directFa_b1fc7e540a30aaf8 => 'No favorite servers yet';

  @override
  String get directEn_dc70c82d78d1c0e8 => 'No favorite servers yet';

  @override
  String get directFa_49320fa08539eb81 => 'Star servers to pin them here for fast access';

  @override
  String get directEn_9571e3d9d6f0c728 => 'Star servers to pin them here for fast access';

  @override
  String get directFa_42527803296e602f => 'No recent connection history';

  @override
  String get directEn_d09e302f1c0274ba => 'No recent connection history';

  @override
  String get directFa_0fc8187b4a7f9368 => 'Servers you connect to will appear here for 1-tap reconnect';

  @override
  String get directEn_f30337f6760cbc52 => 'Servers you connect to will appear here for 1-tap reconnect';

  @override
  String get directFa_1fe15ae1e09b6e2c => 'No servers match your criteria';

  @override
  String get directEn_5833dd21953633eb => 'No servers match your criteria';

  @override
  String get directFa_2b63b2b0981c49df => 'Clear search term or reset filters';

  @override
  String get directEn_920eea58ed6b97ac => 'Clear search term or reset filters';

  @override
  String get directFa_3b855c73b085a016 => 'Show All Servers';

  @override
  String get directEn_6bcc8512de553613 => 'Show All Servers';

  @override
  String get directFa_d5b3c30550d09e4c => 'Country IPv4 ranges bypass the VPN after reconnecting. App bypass uses the Windows physical interface and requires the Harmoney service.';

  @override
  String get directEn_d86322c4ceb937de => 'Country IPv4 ranges bypass the VPN after reconnecting. App bypass uses the Windows physical interface and requires the Harmoney service.';

  @override
  String get directFa_df9d57a055ecc92b => 'Per-app bypass';

  @override
  String get directEn_e7977ed18b1df209 => 'Per-app bypass';

  @override
  String get directFa_a94787ee2df7791b => 'Selected apps use the physical network directly. Other apps continue using the VPN.';

  @override
  String get directEn_36230e6a755f25c0 => 'Selected apps use the physical network directly. Other apps continue using the VPN.';

  @override
  String get directFa_6e26cf4eaf584275 => 'Enable app bypass';

  @override
  String get directEn_0234c7f3ac8b5b71 => 'Enable app bypass';

  @override
  String get directFa_be1c8cef94eaf799 => 'Add at least one application to turn this on.';

  @override
  String get directEn_81e9f4e64a840785 => 'Add at least one application to turn this on.';

  @override
  String get directFa_1ab679752901fb30 => 'Add application (.exe)';

  @override
  String get directEn_50829e8639527356 => 'Add application (.exe)';

  @override
  String get directFa_6badcac8c181d253 => 'Settings';

  @override
  String get directEn_74a883a037bc227f => 'Settings';

  @override
  String get directFa_3b1a615eb46d3552 => 'Manage connection, security, and appearance';

  @override
  String get directEn_61118b57b609e8fd => 'Manage connection, security, and appearance';

  @override
  String get directFa_3f50db43516612df => 'Connection & network';

  @override
  String get directEn_30df82f8484e7683 => 'Connection & network';

  @override
  String get directFa_e107b6a1c6237873 => 'Choose the VPN service for your connection';

  @override
  String get directEn_910a1f4713f13d8e => 'Choose the VPN service for your connection';

  @override
  String get directFa_58315650533b0b3b => 'VPN protocol';

  @override
  String get directEn_7686b2c38e140183 => 'VPN protocol';

  @override
  String get directFa_2a5bdeae1adad66c => 'Available options for this service';

  @override
  String get directEn_cedbc131160b33f1 => 'Available options for this service';

  @override
  String get directFa_16aebe854ffb5f38 => 'Privacy & security';

  @override
  String get directEn_f38d325999eb36a6 => 'Privacy & security';

  @override
  String get directFa_a89854802b5f20cf => 'Network protections configured for this device';

  @override
  String get directEn_be15fa8563e40cba => 'Network protections configured for this device';

  @override
  String get directFa_1409b5d4b2651bab => 'Routes DNS requests through the VPN tunnel';

  @override
  String get directEn_b613c94bf91b3fc9 => 'Routes DNS requests through the VPN tunnel';

  @override
  String get directFa_8195f49a5b2e17b2 => 'Prevents unrouted IPv6 traffic from bypassing the tunnel';

  @override
  String get directEn_1cdef3c7ac0432a7 => 'Prevents unrouted IPv6 traffic from bypassing the tunnel';

  @override
  String get directFa_0e983de7a97d3ebc => 'Restore network';

  @override
  String get directEn_8bd8660e60b766d4 => 'Restore network';

  @override
  String get directFa_be441169827bd41f => 'Restore routes and traffic rules if the network is stuck';

  @override
  String get directEn_0af7a160977315f6 => 'Restore routes and traffic rules if the network is stuck';

  @override
  String get directFa_7598b46f5cf1fc09 => 'Restore';

  @override
  String get directEn_a76e13b9839270eb => 'Restore';

  @override
  String get directFa_ba59a5c62a44328b => 'Automation & profiles';

  @override
  String get directEn_e59064ae08e6a067 => 'Automation & profiles';

  @override
  String get directFa_48fd53e2af663b4a => 'Startup behavior and imported VPN configurations';

  @override
  String get directEn_97bcdad71573d6c3 => 'Startup behavior and imported VPN configurations';

  @override
  String get directFa_69a843018034c170 => 'Launch at system startup';

  @override
  String get directEn_3f1c0972eed8648e => 'Launch at system startup';

  @override
  String get directFa_47133f15d25244d1 => 'Start Harmoney when you sign in';

  @override
  String get directEn_0d5ac9a1f2d12cde => 'Start Harmoney when you sign in';

  @override
  String get directFa_daf6a3deef1f3b02 => 'Always-on VPN';

  @override
  String get directEn_58b2c361864f4c09 => 'Always-on VPN';

  @override
  String get directFa_70bbad1ef3799c29 => 'Reconnect through the system watchdog';

  @override
  String get directEn_22e25c3212f145b0 => 'Reconnect through the system watchdog';

  @override
  String get directFa_9229a87b05a54019 => 'Opens Android VPN settings to configure Always-on';

  @override
  String get directEn_bce686c9ff4b4f85 => 'Opens Android VPN settings to configure Always-on';

  @override
  String get directFa_ad7388a14026319e => 'Appearance';

  @override
  String get directEn_3907fa7f80722a6f => 'Appearance';

  @override
  String get directFa_486db8686a654fbe => 'Choose the app theme and language';

  @override
  String get directEn_cb0d1cffba7882cc => 'Choose the app theme and language';

  @override
  String get directFa_90ec529f45409145 => 'Theme';

  @override
  String get directEn_efb52e7172b77731 => 'Theme';

  @override
  String get directFa_bcbedc248a089ce8 => 'App language';

  @override
  String get directEn_b8352b44a588721c => 'App language';

  @override
  String get directFa_88acd614f1d3e7b2 => 'Diagnostics';

  @override
  String get directEn_268f14bbfe119c1e => 'Diagnostics';

  @override
  String get directFa_9891a6dacb577296 => 'Connection events, network errors, and technical logs';

  @override
  String get directEn_2cd958314044a442 => 'Connection events, network errors, and technical logs';

  @override
  String get directFa_3c77e77837fbd3a5 => 'Technical logs';

  @override
  String get directEn_1c3d7cf2bec01443 => 'Technical logs';

  @override
  String get directFa_fb0c92377fa9ebf2 => 'View and filter application logs';

  @override
  String get directEn_1a06ce3cb511774e => 'View and filter application logs';

  @override
  String get directFa_d2c8a80d171eaac0 => 'Open';

  @override
  String get directEn_ed077f3d8125d60d => 'Open';

  @override
  String get directFa_84bf1721cbaf0414 => 'Harmoney Anti-Censorship Core';

  @override
  String get directEn_4f5845ea70794fc8 => 'Harmoney Anti-Censorship Core';

  @override
  String get directEn_1f914c4386c0676e => 'CONNECTED';

  @override
  String get directFa_9dbd12e5e9f378e2 => 'DISCONNECTED';

  @override
  String get directEn_5541de9515522b98 => 'DISCONNECTED';

  @override
  String get directFa_5391ea668eee238e => 'Routes from Xray, WARP and MASQUE configurations. Connection is shown after traffic verification.';

  @override
  String get directEn_92723a5ff9689c3d => 'Routes from Xray, WARP and MASQUE configurations. Connection is shown after traffic verification.';

  @override
  String get directFa_feb86040674f19da => 'Manage Firefox VPN Account';

  @override
  String get directEn_316f766fb0bc3a72 => 'Manage Firefox VPN Account';

  @override
  String get directFa_da40aa3623e41c95 => 'Remaining traffic:';

  @override
  String get directEn_4968fc7fef5ea571 => 'Remaining traffic:';

  @override
  String get directFa_da8c51e206680bba => 'Refresh status & quota';

  @override
  String get directEn_7af2f7454f3b55aa => 'Refresh status & quota';

  @override
  String get directFa_f5afe95a8fd7ddc6 => 'Query latest session and traffic quota';

  @override
  String get directEn_8035283793ddc0b5 => 'Query latest session and traffic quota';

  @override
  String get directFa_42337406cedc1429 => 'Re-login to account';

  @override
  String get directEn_a836bff92bbc5af0 => 'Re-login to account';

  @override
  String get directFa_e61fefa6ad7996d4 => 'Renew session tokens or switch account';

  @override
  String get directEn_a899ea0cfb536e60 => 'Renew session tokens or switch account';

  @override
  String get directFa_bf5696ba3389269b => 'Logout';

  @override
  String get directEn_d0527e4b3d658351 => 'Logout';

  @override
  String get directFa_ad503541892485c7 => 'Clear stored credentials from this device';

  @override
  String get directEn_c4b662bd95db40f1 => 'Clear stored credentials from this device';

  @override
  String get directFa_3ed02792f04eb5b4 => 'Firefox VPN Account';

  @override
  String get directEn_229b05d20a6d2706 => 'Firefox VPN Account';

  @override
  String get directFa_25384e5227763ffa => 'Checking…';

  @override
  String get directEn_ec963ffc911b8401 => 'Checking…';

  @override
  String get directFa_f14154be5d9988d7 => 'Session Expired';

  @override
  String get directEn_7ae00a283ea9b728 => 'Session Expired';

  @override
  String get directFa_45aa400fa5168a7b => 'Logged In';

  @override
  String get directEn_9b13e877e4aa90a7 => 'Logged In';

  @override
  String get directFa_55217fc0011924d2 => 'Login Required';

  @override
  String get directEn_88712c434b491bce => 'Login Required';

  @override
  String get directFa_44fb79ae8debab9c => 'Checking account…';

  @override
  String get directEn_d18f4156fea49644 => 'Checking account…';

  @override
  String get directFa_1e5f5243758c6f38 => 'Security session expired; please sign in again to use servers.';

  @override
  String get directEn_fa488105cb65db88 => 'Security session expired; please sign in again to use servers.';

  @override
  String get directFa_0b8e3e351c70fd58 => 'Sign in to activate Firefox tunnel and view data quota.';

  @override
  String get directEn_f493cd9c7ae396ec => 'Sign in to activate Firefox tunnel and view data quota.';

  @override
  String get directFa_65f6ae6ff5ae8280 => 'Establishing secure tunnel…';

  @override
  String get directEn_24b8d9733417f7f2 => 'Establishing secure tunnel…';

  @override
  String get directFa_2825bd47934b892f => 'VPN tunnel inactive · Ready to connect';

  @override
  String get directEn_ee73ed2931582286 => 'VPN tunnel inactive · Ready to connect';

  @override
  String get directFa_a032c52ee18734be => 'Traffic Quota';

  @override
  String get directEn_afdd44031ab46f34 => 'Traffic Quota';

  @override
  String get directFa_61a760cc9666bc9b => 'Monthly Allowance';

  @override
  String get directEn_659e50811965fe84 => 'Monthly Allowance';

  @override
  String get directFa_b160cc84c236bc55 => 'Quota information unavailable';

  @override
  String get directEn_893e490d64407b8e => 'Quota information unavailable';

  @override
  String get directFa_06922cd515293cd4 => 'Unlimited quota';

  @override
  String get directEn_23d5d93cf5f11e17 => 'Unlimited quota';

  @override
  String get directFa_80a85438cf023e19 => 'GiB';

  @override
  String get directEn_66a1561b84b46372 => 'GiB';

  @override
  String get directFa_a624a1e41ffdc6d6 => ' of ';

  @override
  String get directEn_a4282e4b2298b90b => ' of ';

  @override
  String get directFa_4b329f46e3e4aa50 => 'remaining';

  @override
  String get directEn_43e3ece73ff8f4eb => 'remaining';

  @override
  String get directFa_6d2ae6f38c3f09cd => 'Sign In';

  @override
  String get directEn_c90fdfab474bdd3e => 'Log in to account';

  @override
  String get directFa_9b009e657294963a => 'Re-login';

  @override
  String get directEn_fbfd8ce759281a7c => 'Re-login';

  @override
  String get directFa_47018eca7a6a198e => 'Manage Account';

  @override
  String get directEn_203229774cceb5f3 => 'Manage Account';

  @override
  String get directFa_39db927c23ae2f24 => 'Logout';

  @override
  String get directFa_447aac2e6e36c632 => 'Refresh Status';

  @override
  String get directEn_72fe71cb37d209d2 => 'Refresh Status';

  @override
  String get directEn_bcc0bcc9140b0c97 => 'Sign In';

  @override
  String get directFa_8ac2798171b7f59a => 'Check status';

  @override
  String get directEn_69cd3590300a68c6 => 'Check status';

  @override
  String get directFa_fe9c7660a2b6752a => 'Automatic';

  @override
  String get directEn_d461a493a3753877 => 'Automatic';

  @override
  String get directFa_65feb3156825dbc3 => 'Automatic provider-managed routing';

  @override
  String get directEn_3e5404c2c8a5d4f7 => 'Automatic provider-managed routing';

  @override
  String get directFa_0728ba5430a590a1 => 'Monthly Data Quota';

  @override
  String get directEn_f6be68de3c8d5e7d => 'Monthly Data Quota';

  @override
  String get directFa_b496c7ee3eea90bc => 'You will receive visual alerts when reaching this limit.';

  @override
  String get directEn_243a20f9ba6c2892 => 'You will receive visual alerts when reaching this limit.';

  @override
  String get directFa_3aa40b685220c3cb => 'Unlimited (Off)';

  @override
  String get directEn_4bd0e4ba0e817d11 => 'Unlimited (Off)';

  @override
  String get directFa_fa7af603d430b209 => 'Cancel';

  @override
  String get directEn_19766ed6ccb2f4a3 => 'Cancel';

  @override
  String get directFa_609b20177a3148b2 => 'Save Quota';

  @override
  String get directEn_8e1b786c7913210c => 'Save Quota';

  @override
  String get directEn_4bfa799fae21b467 => 'Traffic Analytics';

  @override
  String get directFa_b8b979fad05a28d9 => 'Live bandwidth, data accounting & quota';

  @override
  String get directEn_2eb0c5a3ce65868c => 'Live bandwidth, data accounting & quota';

  @override
  String get directFa_e6522eb9b3c2254c => 'Live Active';

  @override
  String get directEn_a0b16ccf9021fc82 => 'Live Active';

  @override
  String get directFa_08914752d2e02ff9 => 'Waiting for VPN';

  @override
  String get directEn_2693034906c0e6f9 => 'Waiting for VPN';

  @override
  String get directFa_38a3d2526a8bcc84 => 'Live Real-Time Speed';

  @override
  String get directEn_c6c2daab1f7d2fe5 => 'Live Real-Time Speed';

  @override
  String get directFa_9bf13dfa15fb680e => 'Download';

  @override
  String get directEn_2eb993f9bc93c5ff => 'DL';

  @override
  String get directFa_2ce1cec62671ae15 => 'Upload';

  @override
  String get directEn_6138f40c9673bed1 => 'UL';

  @override
  String get directFa_cc361d9901ffdf37 => 'Monthly Data Quota';

  @override
  String get directFa_b0de3b412705cb35 => 'Set Quota';

  @override
  String get directEn_a429cd15905e58a5 => 'Set Quota';

  @override
  String get directFa_c25fdb7da6c13c3a => 'used';

  @override
  String get directEn_f839161355091fcd => 'used';

  @override
  String get directFa_c17283824713e914 => 'No Limit Set';

  @override
  String get directEn_2de8796023cbb4c7 => 'No Limit Set';

  @override
  String get directFa_61b4fadd6541d1c0 => 'Today';

  @override
  String get directEn_2b065c7c9ce466e5 => 'Today';

  @override
  String get directFa_fc454815fc7e587d => 'Peak Speed';

  @override
  String get directEn_ccbb73524b4bd4ee => 'Peak Speed';

  @override
  String get directFa_d39fe430fa149d24 => 'Highest recorded';

  @override
  String get directEn_0debfca2599549f2 => 'Highest recorded';

  @override
  String get directFa_ad9ba5d4f5d3620f => 'This Month';

  @override
  String get directEn_64367736022306e3 => 'This Month';

  @override
  String get directFa_d7efa0cd9804f3a3 => 'Lifetime Total';

  @override
  String get directEn_722808dd53ec1823 => 'Lifetime Total';

  @override
  String get directFa_ee086cbab6feeb75 => 'All-time volume';

  @override
  String get directEn_20e93f7caa1a7a5c => 'All-time volume';

  @override
  String get directFa_c709d51a733c7d0b => 'Session Duration';

  @override
  String get directEn_ad4b77a68783ec24 => 'Session Duration';

  @override
  String get directFa_3ed03a3af2ebf355 => 'Session Download:';

  @override
  String get directEn_90f46423c0074765 => 'Session Download:';

  @override
  String get directFa_bca2becadd374c69 => 'Session Upload:';

  @override
  String get directEn_4d9bfca28655ee45 => 'Session Upload:';

  @override
  String get directFa_048be696dea10d04 => 'Last Speed Benchmark:';

  @override
  String get directEn_2faba03e2b8726a9 => 'Last Speed Benchmark:';

  @override
  String get directFa_f07a81a062535ff7 => 'Unknown';

  @override
  String get directEn_b764cdc0eab71374 => 'Unknown';

  @override
  String get directFa_b8d890311eb66f8b => 'Automatic route';

  @override
  String get directEn_58f885c3d5750c90 => 'Automatic route';

  @override
  String get directFa_627f8d2a81499747 => 'Verified Secure Tunnel';

  @override
  String get directEn_435483eb4a848f87 => 'Verified Secure Tunnel';

  @override
  String get directFa_d115b5686b17f628 => 'Exit IP';

  @override
  String get directEn_cea9bb520a68321d => 'Exit IP';

  @override
  String get directFa_a3fa2a3ffcb94859 => 'Online';

  @override
  String get directEn_0d21bd52022ca7f7 => 'Online';

  @override
  String get directFa_b883b4839aacf6e7 => 'Measuring...';

  @override
  String get directEn_e7c955a5ec17dda2 => 'Measuring...';

  @override
  String get directFa_01fff4b387cb6493 => 'Excellent';

  @override
  String get directEn_0dc8ee555c28ec1b => 'Excellent';

  @override
  String get directFa_056e4427b316f2c7 => 'Good';

  @override
  String get directEn_c939327ca16dcf97 => 'Good';

  @override
  String get directFa_42a5dadf6e451488 => 'Fair';

  @override
  String get directEn_f7b19afcde965ea4 => 'Fair';

  @override
  String get directFa_3865275fd105a5b8 => 'Tap to run full speed test';

  @override
  String get directEn_b8d5e190fa4127c4 => 'Tap to run full speed test';

  @override
  String get directEn_d6eafe8235910042 => 'Download';

  @override
  String get directEn_865e89de78d94c74 => 'Upload';

  @override
  String get directFa_ff9d6eaa4d416020 => 'Tap to re-test latency';

  @override
  String get directEn_9ef6777f1d140309 => 'Tap to re-test latency';

  @override
  String get directFa_6c85ce5d5c3eb500 => 'Copy Public IP';

  @override
  String get directEn_caf4d6e51756401d => 'Copy Public IP';

  @override
  String get directFa_a47a3ca2c3fb77ce => 'Copied!';

  @override
  String get directEn_ea61bc15688d1e48 => 'Copied!';

  @override
  String get directFa_b6cd8e356ae4de3e => 'Domestic Bypass';

  @override
  String get directEn_1214c275435c3c13 => 'Domestic Bypass';

  @override
  String get directFa_2841f70e40d3118f => 'Direct IR routes';

  @override
  String get directEn_179a9a0e2cfce115 => 'Direct IR routes';

  @override
  String get directFa_b4cab70060e554b3 => 'Kill Switch';

  @override
  String get directEn_006b49290aa86bfe => 'Kill Switch';

  @override
  String get directFa_1633c46938431a54 => 'Active';

  @override
  String get directEn_92340695899bd2d8 => 'Active';

  @override
  String get directFa_4e67bd8e348260b0 => 'Disabled';

  @override
  String get directEn_75081b593d15cf6e => 'Disabled';

  @override
  String get directFa_120c9c6bd8826c8b => 'Speed Test';

  @override
  String get directEn_d23ced7772a783f3 => 'Speed Test';

  @override
  String get directFa_3e67ba9b0445249e => 'Measure latency & speed';

  @override
  String get directEn_948111705a82a507 => 'Measure latency & speed';

  @override
  String get directFa_d5c66bbea9d37a9c => 'Connection service';

  @override
  String get directEn_e1f42d830cee8336 => 'Connection service';

  @override
  String get directFa_48c1182b09375569 => 'Connected & Protected';

  @override
  String get directEn_105e6388aad6ff7f => 'Connected & Protected';

  @override
  String get directFa_e2c8f657fd596d7d => 'Connecting...';

  @override
  String get directEn_5f04ae9ed6a865bb => 'Connecting...';

  @override
  String get directFa_1a8adc1da26270cc => 'Authenticating & Bypassing...';

  @override
  String get directEn_1d18406321d2db26 => 'Authenticating & Bypassing...';

  @override
  String get directFa_12df5a9cc276f2c3 => 'Connection Failed';

  @override
  String get directEn_42aa4e7bc5d2c21a => 'Connection Failed';

  @override
  String get directFa_cd85b4ceda3cc131 => 'Disconnecting...';

  @override
  String get directEn_cb5a85cad9bd34c5 => 'Disconnecting...';

  @override
  String get directFa_9b54440688493c0e => 'Ready to Connect';

  @override
  String get directEn_5883e493fc35afe6 => 'Ready to Connect';

  @override
  String get directFa_f941f415804ba6bc => 'All your traffic is encrypted and anonymous';

  @override
  String get directEn_cd289597cdb36a8e => 'All your traffic is encrypted and anonymous';

  @override
  String get directFa_c1c8e35e7a1e6ab5 => 'Finding the fastest censorship-resistant route...';

  @override
  String get directEn_fc7f3ba24f1e9374 => 'Finding the fastest censorship-resistant route...';

  @override
  String get directFa_545c3b36cf6a9b19 => 'Tap the button to reconnect';

  @override
  String get directEn_c00c5efaa984cbb0 => 'Tap the button to reconnect';

  @override
  String get directFa_19b98ac54207bf43 => 'Tap the shield button to secure your internet';

  @override
  String get directEn_dc50817ae538ef68 => 'Tap the shield button to secure your internet';

  @override
  String get directFa_ea55a64adb57f89d => 'Automatic Firefox VPN server';

  @override
  String get directEn_a84cdc7941aa150d => 'Automatic Firefox VPN server';

  @override
  String get directFa_3c408aa10a3a59a2 => 'Harmoney Smart Route';

  @override
  String get directEn_17910d2c8cda2576 => 'Harmoney Smart Route';

  @override
  String get directFa_8f195663090dbd82 => 'An available server is chosen when you connect';

  @override
  String get directEn_0666050624c4726b => 'An available server is chosen when you connect';

  @override
  String get directFa_787659ec3bcfb8a4 => 'Speed report copied to clipboard!';

  @override
  String get directEn_f5af9ab211b447cd => 'Speed report copied to clipboard!';

  @override
  String get directFa_6d3beddaa5bcf6ea => 'Speed Test History';

  @override
  String get directEn_c3a6d1c87fa8d4bb => 'Speed Test History';

  @override
  String get directFa_f2730ebc51f8b5f4 => 'Clear';

  @override
  String get directEn_83b12c2216efb4fd => 'Clear';

  @override
  String get directFa_0a48e042ec0bc4e0 => 'No speed tests recorded yet.';

  @override
  String get directEn_df578dfdf0dafa9a => 'No speed tests recorded yet.';

  @override
  String get directFa_147f59b73fb11974 => 'Speed & Grade';

  @override
  String get directEn_f6e4e9eb494ae1e4 => 'Speed & Grade';

  @override
  String get directFa_cad272ec0da708d2 => 'Live Traffic';

  @override
  String get directEn_4e053f26797a1b12 => 'Live Traffic';

  @override
  String get directFa_1b248f96a0d6123f => 'Diagnostics';

  @override
  String get directFa_afc81625f67a81d4 => 'Ping';

  @override
  String get directEn_6a4c3a4483b04488 => 'Ping';

  @override
  String get directFa_3381d5e424186c39 => 'Jitter';

  @override
  String get directEn_91fbe4c855fbe075 => 'Jitter';

  @override
  String get directFa_b31ec87c31b48943 => 'Smart Service Suitability';

  @override
  String get directEn_e17b6227325e1a8d => 'Smart Service Suitability';

  @override
  String get directFa_1d79e493a5f0af51 => 'Gaming';

  @override
  String get directEn_0fadfa22881467dc => 'Gaming';

  @override
  String get directFa_e8622ea6a8536d1c => 'Streaming';

  @override
  String get directEn_a951c5945635e2d3 => 'Streaming';

  @override
  String get directFa_9dbabd2760d00055 => 'No Buffering';

  @override
  String get directEn_7c2521637f81edab => 'No Buffering';

  @override
  String get directFa_ecae75dec1191127 => 'Calls (VoIP)';

  @override
  String get directEn_17ea7be09dfd3486 => 'Calls (VoIP)';

  @override
  String get directFa_023848907db873a8 => 'Zoom & Telegram';

  @override
  String get directEn_48eed22fd9e942cd => 'Zoom & Telegram';

  @override
  String get directFa_d712411ba5c95ecd => 'Stability Index';

  @override
  String get directEn_07561925e24ab3c5 => 'Stability Index';

  @override
  String get directFa_ceb05c63bfc2664a => 'Zero packet loss';

  @override
  String get directEn_2e7e5a988d7ff138 => 'Zero packet loss';

  @override
  String get directFa_45f41f3ef10068e9 => 'Cancel Test';

  @override
  String get directEn_ebf5f31bd3fa8cf4 => 'Cancel Test';

  @override
  String get directFa_b9460b16f1ed426c => 'Start Speed Test';

  @override
  String get directEn_5e0104e1d0dd6cc2 => 'Start Speed Test';

  @override
  String get directFa_ec2855c996f9cbd2 => 'Copy Report';

  @override
  String get directEn_54b8e0c0c268c154 => 'Copy Report';

  @override
  String get directFa_e82a1c223cbe97b6 => 'History';

  @override
  String get directEn_0e76960093379060 => 'History';

  @override
  String get directFaTemplate_994633c2bcedc4a9 => 'Feeds updated & verified (QZXVAR0QZX active)';

  @override
  String get directEnTemplate_b828e6d7441cc143 => 'Feeds updated & verified (QZXVAR0QZX active)';

  @override
  String get directFaTemplate_5239746315c0eb65 => 'QZXVAR0QZX of QZXVAR1QZX feeds verified';

  @override
  String get directEnTemplate_8f43f1183a17a9ee => 'QZXVAR0QZX of QZXVAR1QZX feeds verified';

  @override
  String get directFaTemplate_30d97df5d076bd85 => 'QZXVAR0QZX active feeds ready';

  @override
  String get directEnTemplate_96826d3bc31aa276 => 'QZXVAR0QZX active feeds ready';

  @override
  String get directFaTemplate_fee1d797c43cc69d => 'Last successful update: QZXVAR0QZX';

  @override
  String get directEnTemplate_fded5aac30f3cd2a => 'Last successful update: QZXVAR0QZX';

  @override
  String get directFaTemplate_3c0e143206c640a7 => 'QZXVAR0QZXm ago';

  @override
  String get directEnTemplate_36d18ca5012e48ca => 'QZXVAR0QZXm ago';

  @override
  String get directFaTemplate_c5e58f11bda2617f => 'QZXVAR0QZXh ago';

  @override
  String get directEnTemplate_24aa4c9a230529bd => 'QZXVAR0QZXh ago';

  @override
  String get directFaTemplate_77f98929af010686 => 'QZXVAR0QZX application(s) selected';

  @override
  String get directEnTemplate_d15393d3ecf8ed01 => 'QZXVAR0QZX application(s) selected';

  @override
  String get directFaTemplate_6cb5f3a91c97ab58 => 'QZXVAR0QZX of QZXVAR1QZX GiB';

  @override
  String get directEnTemplate_23034a0887d70ad4 => 'QZXVAR0QZX of QZXVAR1QZX GiB';

  @override
  String get directFaTemplate_827e6929ed952562 => 'Resets: QZXVAR0QZX';

  @override
  String get directEnTemplate_d566a16d104214f0 => 'Resets: QZXVAR0QZX';

  @override
  String get directFa_4767f95a766acad9 => 'profiles imported';

  @override
  String get directEn_fa3e465bd04c98ce => 'profiles imported';

  @override
  String get directFa_6a94bd2919a75602 => 'Importing?';

  @override
  String get directEn_186483a47635ef8b => 'Importing?';

  @override
  String get directFa_7bd1e551fd0c73d1 => 'Import ZIP';

  @override
  String get directEn_cb0bf46bf1e385db => 'Import ZIP';

  @override
  String get directFa_2c0b4ee2a03c434e => 'Manage';

  @override
  String get directEn_5a23444828db654a => 'Manage';

  @override
  String get desktopTrayOpenApplication => 'Open Application';

  @override
  String get desktopTrayChooseServer => 'Choose server…';

  @override
  String get desktopTrayPreferences => 'Preferences / Settings';

  @override
  String get desktopTrayStartupOptions => 'Startup Options';

  @override
  String get desktopTrayLaunchOnStartup => 'Launch on startup';

  @override
  String get desktopTraySoundEffect => 'Sound effect';

  @override
  String get desktopTrayStartMinimized => 'Start minimized';

  @override
  String get desktopTrayForceClose => 'Force close';

  @override
  String get desktopTrayServiceMode => 'Service Mode';

  @override
  String get desktopTrayProxyService => 'Proxy Service';

  @override
  String get desktopTraySystemProxy => 'System Proxy';

  @override
  String get desktopTrayVpnModeUnavailable => 'VPN (Unavailable)';

  @override
  String get desktopTrayExit => 'Exit';

  @override
  String get desktopTrayReady => 'Ready';

  @override
  String get desktopTrayDisconnecting => 'Disconnecting…';

  @override
  String get desktopTrayCancelConnection => 'Cancel connection';

  @override
  String get desktopTrayAutomatic => 'Automatic';

  @override
  String get desktopTrayError => 'Error';
}
