import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fa.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fa'),
    Locale('fr'),
    Locale('it'),
    Locale('ru'),
    Locale('tr'),
    Locale('zh')
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Harmoney VPN'**
  String get appTitle;

  /// Subtitle shown on splash screen
  ///
  /// In en, this message translates to:
  /// **'Crafted for secure internet access,\ndesigned for everyone, everywhere'**
  String get splashSubtitle;

  /// Connect button text
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// Disconnect button text
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// Connected status text
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Disconnected status text
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// Connecting status text
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get connecting;

  /// Connecting status with group name
  ///
  /// In en, this message translates to:
  /// **'CONNECTING VIA {groupName}'**
  String connectingVia(String groupName);

  /// Status shown when switching connection method
  ///
  /// In en, this message translates to:
  /// **'SWITCHING METHOD'**
  String get switchingMethod;

  /// Speed test feature label
  ///
  /// In en, this message translates to:
  /// **'Speed Test'**
  String get speedTest;

  /// Download speed label
  ///
  /// In en, this message translates to:
  /// **'DOWNLOAD'**
  String get download;

  /// Upload speed label
  ///
  /// In en, this message translates to:
  /// **'UPLOAD'**
  String get upload;

  /// Ping label
  ///
  /// In en, this message translates to:
  /// **'PING'**
  String get ping;

  /// Latency label
  ///
  /// In en, this message translates to:
  /// **'LATENCY'**
  String get latency;

  /// Jitter label
  ///
  /// In en, this message translates to:
  /// **'JITTER'**
  String get jitter;

  /// Packet loss label
  ///
  /// In en, this message translates to:
  /// **'P.LOSS'**
  String get packetLoss;

  /// Instruction to tap to start speed test
  ///
  /// In en, this message translates to:
  /// **'TAP HERE'**
  String get tapHere;

  /// Settings menu label
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Introduction menu item
  ///
  /// In en, this message translates to:
  /// **'Introduction'**
  String get introduction;

  /// Privacy policy menu item
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Terms and conditions menu item
  ///
  /// In en, this message translates to:
  /// **'Terms & Conditions'**
  String get termsAndConditions;

  /// Our website menu item
  ///
  /// In en, this message translates to:
  /// **'Our Website'**
  String get ourWebsite;

  /// Marketplace menu item
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get marketplace;

  /// Telegram bot menu item
  ///
  /// In en, this message translates to:
  /// **'Telegram Bot'**
  String get telegramBot;

  /// Source code link
  ///
  /// In en, this message translates to:
  /// **'Source code'**
  String get sourceCode;

  /// Open source licenses link
  ///
  /// In en, this message translates to:
  /// **'Open source licenses'**
  String get openSourceLicenses;

  /// Beta community link
  ///
  /// In en, this message translates to:
  /// **'Beta Community'**
  String get betaCommunity;

  /// Close button text
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Copy logs button text
  ///
  /// In en, this message translates to:
  /// **'Copy Logs'**
  String get copyLogs;

  /// Message shown when logs are copied
  ///
  /// In en, this message translates to:
  /// **'Logs copied to clipboard'**
  String get logsCopied;

  /// App logs panel title
  ///
  /// In en, this message translates to:
  /// **'App Logs'**
  String get appLogs;

  /// Auto-refresh toggle label
  ///
  /// In en, this message translates to:
  /// **'Auto-refresh'**
  String get autoRefresh;

  /// Clear logs button text
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// Quick menu label
  ///
  /// In en, this message translates to:
  /// **'Quick Menu'**
  String get quickMenu;

  /// No internet connection status
  ///
  /// In en, this message translates to:
  /// **'No Internet'**
  String get noInternet;

  /// Error status
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Loading status
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// Analyzing status
  ///
  /// In en, this message translates to:
  /// **'Analyzing'**
  String get analyzing;

  /// Megabits per second unit
  ///
  /// In en, this message translates to:
  /// **'Mbps'**
  String get mbps;

  /// Milliseconds unit
  ///
  /// In en, this message translates to:
  /// **'ms'**
  String get ms;

  /// Language setting label
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Tips section header
  ///
  /// In en, this message translates to:
  /// **'TIPS'**
  String get tips;

  /// English language name
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// Chinese language name
  ///
  /// In en, this message translates to:
  /// **'中文 (Chinese)'**
  String get chinese;

  /// Got it button text
  ///
  /// In en, this message translates to:
  /// **'Got it'**
  String get gotIt;

  /// Learn more section title
  ///
  /// In en, this message translates to:
  /// **'LEARN MORE'**
  String get learnMore;

  /// Description of Harmoney goal
  ///
  /// In en, this message translates to:
  /// **'The goal of Harmoney is to ensure secure access to public information and provide a free browsing experience.'**
  String get harmoneyGoal;

  /// Status message - chilling state
  ///
  /// In en, this message translates to:
  /// **'is chilling.'**
  String get statusIsChilling;

  /// Status connector word
  ///
  /// In en, this message translates to:
  /// **'is'**
  String get statusIs;

  /// Status message - failed state
  ///
  /// In en, this message translates to:
  /// **'failed.'**
  String get statusFailed;

  /// Status connector word
  ///
  /// In en, this message translates to:
  /// **'has'**
  String get statusHas;

  /// Status message - returning state
  ///
  /// In en, this message translates to:
  /// **'is returning'**
  String get statusIsReturning;

  /// Status message - standby mode text
  ///
  /// In en, this message translates to:
  /// **'to standby mode.'**
  String get statusToStandbyMode;

  /// Status message - plugging in state
  ///
  /// In en, this message translates to:
  /// **'plugging in ...'**
  String get statusPluggingIn;

  /// Status message - powered up state
  ///
  /// In en, this message translates to:
  /// **'powered up'**
  String get statusPoweredUp;

  /// Status message - working state
  ///
  /// In en, this message translates to:
  /// **'doing science ...'**
  String get statusDoingScience;

  /// Status message - disconnected state
  ///
  /// In en, this message translates to:
  /// **'exited the matrix'**
  String get statusExitedMatrix;

  /// Status message - apology
  ///
  /// In en, this message translates to:
  /// **'we\'re sorry :('**
  String get statusSorry;

  /// Status message - connect prompt
  ///
  /// In en, this message translates to:
  /// **'Connect already'**
  String get statusConnectAlready;

  /// Status message - speed test in progress
  ///
  /// In en, this message translates to:
  /// **'testing speed ...'**
  String get statusTestingSpeed;

  /// Status message - ready state
  ///
  /// In en, this message translates to:
  /// **'is ready'**
  String get statusIsReady;

  /// Status connector word when DXcore handshake fails
  ///
  /// In en, this message translates to:
  /// **'is in trouble.'**
  String get statusIsInTrouble;

  /// Status message shown when DXcore cannot be verified
  ///
  /// In en, this message translates to:
  /// **'DXcore down.'**
  String get statusDXcoreDown;

  /// Status message - ready for speed test
  ///
  /// In en, this message translates to:
  /// **'to speed test'**
  String get statusToSpeedTest;

  /// Settings status message
  ///
  /// In en, this message translates to:
  /// **'yours to shape'**
  String get statusYoursToShape;

  /// Settings section - connection method
  ///
  /// In en, this message translates to:
  /// **'CONNECTION METHOD'**
  String get settingsConnectionMethod;

  /// Settings section - escape mode
  ///
  /// In en, this message translates to:
  /// **'ESCAPE MODE'**
  String get settingsEscapeMode;

  /// Settings section - destination
  ///
  /// In en, this message translates to:
  /// **'DESTINATION'**
  String get settingsDestination;

  /// Settings section - split tunnel
  ///
  /// In en, this message translates to:
  /// **'SPLIT TUNNEL'**
  String get settingsSplitTunnel;

  /// Settings section - kill switch
  ///
  /// In en, this message translates to:
  /// **'KILL SWITCH'**
  String get settingsKillSwitch;

  /// Settings section - deep scan
  ///
  /// In en, this message translates to:
  /// **'DEEP SCAN'**
  String get settingsDeepScan;

  /// Settings section - health check
  ///
  /// In en, this message translates to:
  /// **'HEALTH CHECK'**
  String get settingsHealthCheck;

  /// Settings label - included items
  ///
  /// In en, this message translates to:
  /// **'INCLUDED'**
  String get settingsIncluded;

  /// Settings error message - core requirement
  ///
  /// In en, this message translates to:
  /// **'At least one core must remain enabled'**
  String get settingsAtLeastOneCoreRequired;

  /// Settings button - reset to default
  ///
  /// In en, this message translates to:
  /// **'RESET'**
  String get settingsResetToDefault;

  /// Offline flowline notification message
  ///
  /// In en, this message translates to:
  /// **'Flowline updates have been paused because the offline version is currently being used.'**
  String get offlineFlowlineMessage;

  /// Offline flowline undo button
  ///
  /// In en, this message translates to:
  /// **'UNDO'**
  String get offlineFlowlineUndo;

  /// Update dialog title - optional update
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailable;

  /// Update dialog title - mandatory update
  ///
  /// In en, this message translates to:
  /// **'Update required'**
  String get updateRequired;

  /// Update dialog message - optional update
  ///
  /// In en, this message translates to:
  /// **'To get the most out of the app and enjoy the latest improvements, please update to the newest version.'**
  String get updateOptionalMessage;

  /// Update dialog message - mandatory update
  ///
  /// In en, this message translates to:
  /// **'To continue using Harmoney, please update to the latest version. This update includes critical improvements and is required for app functionality.'**
  String get updateRequiredMessage;

  /// Update dialog button - update action
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// Update dialog button - dismiss action
  ///
  /// In en, this message translates to:
  /// **'Not now'**
  String get notNow;

  /// Sync menu - update methods option
  ///
  /// In en, this message translates to:
  /// **'Update Methods'**
  String get updateMethods;

  /// Sync menu - import configuration file option
  ///
  /// In en, this message translates to:
  /// **'Import Config'**
  String get importConfig;

  /// Sync menu label
  ///
  /// In en, this message translates to:
  /// **'Synchronization'**
  String get synchronization;

  /// Donation widget title
  ///
  /// In en, this message translates to:
  /// **'Donation'**
  String get settingsDonation;

  /// Donation widget description text
  ///
  /// In en, this message translates to:
  /// **'Help us break down the walls of digital censorship and internet filtering.'**
  String get settingsDonationDescription;

  /// Premium login dialog title
  ///
  /// In en, this message translates to:
  /// **'Authentication Required'**
  String get authenticationRequired;

  /// Premium login dialog description
  ///
  /// In en, this message translates to:
  /// **'To access your Premium subscription(s), you need to login or create an account through the Harmoney website.'**
  String get premiumLoginDescription;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Email field hint text
  ///
  /// In en, this message translates to:
  /// **'example@domain.com'**
  String get emailHint;

  /// Email validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get emailValidation;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Password field hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your password'**
  String get passwordHint;

  /// Password validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get passwordValidation;

  /// Password minimum length validation error
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMinLength;

  /// Login button text
  ///
  /// In en, this message translates to:
  /// **'Login'**
  String get login;

  /// Sign up prompt text
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get noAccount;

  /// Sign up link text
  ///
  /// In en, this message translates to:
  /// **'Sign up'**
  String get signUp;

  /// Login failed toast message
  ///
  /// In en, this message translates to:
  /// **'Login failed. Please check your credentials and try again.'**
  String get loginFailed;

  /// Login success toast message
  ///
  /// In en, this message translates to:
  /// **'Login successful!'**
  String get loginSuccess;

  /// Code field label
  ///
  /// In en, this message translates to:
  /// **'Code'**
  String get code;

  /// Code field hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your access code'**
  String get codeHint;

  /// Code validation error message
  ///
  /// In en, this message translates to:
  /// **'Please enter your code'**
  String get codeValidation;

  /// Premium login by code dialog description
  ///
  /// In en, this message translates to:
  /// **'To access your Premium subscription(s), enter the access code provided to you.'**
  String get premiumLoginByCodeDescription;

  /// Premium trouble dialog title
  ///
  /// In en, this message translates to:
  /// **'Having trouble?'**
  String get havingTrouble;

  /// Premium trouble dialog - signed in message prefix
  ///
  /// In en, this message translates to:
  /// **'You are currently signed in with the email address'**
  String get signedInAs;

  /// Premium trouble dialog - import instructions
  ///
  /// In en, this message translates to:
  /// **'If your Premium subscriptions cannot be loaded due to internet restrictions and you\'re unable to connect using the available methods, you can import the file obtained from the Marketplace into the app.'**
  String get premiumImportDescription;

  /// Premium trouble dialog - sign out prompt
  ///
  /// In en, this message translates to:
  /// **'Planning to exit?'**
  String get planningToExit;

  /// Sign out link text
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get signOut;

  /// Sign out success toast message
  ///
  /// In en, this message translates to:
  /// **'Signed out successfully!'**
  String get signOutSuccess;

  /// Premium widget - marketplace title
  ///
  /// In en, this message translates to:
  /// **'Marketplace'**
  String get settingsMarketplace;

  /// Premium widget - marketplace description
  ///
  /// In en, this message translates to:
  /// **'Browse secure VPN configurations from trusted suppliers.'**
  String get marketplaceDescription;

  /// Premium widget - logged in status
  ///
  /// In en, this message translates to:
  /// **'LOGGED IN'**
  String get loggedIn;

  /// Premium widget - login/register prompt
  ///
  /// In en, this message translates to:
  /// **'LOGIN OR REGISTER'**
  String get loginOrRegister;

  /// Login by code button text
  ///
  /// In en, this message translates to:
  /// **'Login by code'**
  String get loginByCode;

  /// Back to email login button text
  ///
  /// In en, this message translates to:
  /// **'Back to login by email'**
  String get backToLoginByEmail;

  /// Connection required dialog title
  ///
  /// In en, this message translates to:
  /// **'Connection Required'**
  String get connectionRequired;

  /// Connection required dialog description
  ///
  /// In en, this message translates to:
  /// **'To complete a secure login or registration process, you must first establish a connection using one of the available connection methods.'**
  String get connectionRequiredDescription;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'تنظیمات سرور'**
  String get inlineText_a5998db73b68af63;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'اسکن خودکار این دستگاه'**
  String get inlineText_3305ac4300665f71;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'انصراف'**
  String get inlineText_fa7af603d430b209;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Pro'**
  String get inlineText_9de2a0d933190a40;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get inlineText_9fd728c66c9a256b;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Not supported on this platform.'**
  String get inlineText_8450d81a2ef331f0;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'شناسه سخت‌افزاری به مقدار پیش‌فرض سرور بازنشانی شد.'**
  String get inlineText_6f759aed280d8ae1;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'On Android and Linux the selected subscription is used, but the VPN core may choose a different node from it.'**
  String get inlineText_10ae58fbb5984f6e;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Importing…'**
  String get inlineText_c01c4324f1fa14fc;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Per-app bypass is not supported on this platform.'**
  String get inlineText_ef207787e1f5054a;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Bypass VPN'**
  String get inlineText_543264e2f45dd255;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Firefox VPN protocol'**
  String get inlineText_034fc31b30e178f0;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Disabled: all traffic routes securely through encrypted VPN tunnel.'**
  String get inlineText_4fcf7e0d90445713;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Custom Bypass Rules'**
  String get inlineText_272a96114c7af32f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Firefox VPN'**
  String get inlineText_7b547a5ae60b2f38;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Hotspot Active'**
  String get inlineText_4b42c738a9185fc5;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Save preference'**
  String get inlineText_fa174cea0ac4357d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Working…'**
  String get inlineText_5474eef8d0f179c7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No applications selected.'**
  String get inlineText_e6f7f8ccc059e5c7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Disconnect is taking longer than expected. You can try again.'**
  String get inlineText_df8748e19fc6ee2b;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Block Internet Access'**
  String get inlineText_c0bd827e34b175ab;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Refresh status & quota'**
  String get inlineText_7af2f7454f3b55aa;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get inlineText_eea2745e2867a677;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get inlineText_88712c434b491bce;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get inlineText_7d9eb7acb13e2462;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Select connection service'**
  String get inlineText_46b5d935b82dd8e0;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Query latest session and traffic quota'**
  String get inlineText_8035283793ddc0b5;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No custom bypass rules.'**
  String get inlineText_64a985f51e17518b;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Host machine only'**
  String get inlineText_90e0e260530759ce;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'تولید شناسه سخت‌افزاری دستگاه'**
  String get inlineText_fa1cf54705b7a6ea;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Share secure encrypted tunnel with phones & tablets'**
  String get inlineText_8693a5d72c6b23fa;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get inlineText_0d21bd52022ca7f7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Bypassing'**
  String get inlineText_7d096ae1ecf2a8cc;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Disable Optimization'**
  String get inlineText_2fc9fc3695f14892;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'شناسه نهایی تولیدشده (SHA-256):'**
  String get inlineText_6405b0129cf5a714;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'ذخیره تنظیمات'**
  String get inlineText_5f65ccdf701bd499;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Log in to account'**
  String get inlineText_c90fdfab474bdd3e;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Repair ICS'**
  String get inlineText_1c114a72bff7ecbc;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Speed Test History'**
  String get inlineText_c3a6d1c87fa8d4bb;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Session Upload:'**
  String get inlineText_4d9bfca28655ee45;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Start Guest'**
  String get inlineText_1a095c79818885e4;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Checking account…'**
  String get inlineText_d18f4156fea49644;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inlineText_ac7c949f1211b781;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Ready to perform live routing and security audits.'**
  String get inlineText_9c1ff072196e2d26;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No speed tests recorded yet.'**
  String get inlineText_df578dfdf0dafa9a;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Launch direct'**
  String get inlineText_5d6529256c6c68f0;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Unlimited quota'**
  String get inlineText_23d5d93cf5f11e17;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Export Servers'**
  String get inlineText_1228cd974a4510cf;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Allow IPv6'**
  String get inlineText_0323bbb0e3e24d50;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Network unjammed: Kill switch, routes, and XFRM interfaces restored to normal.'**
  String get inlineText_58e27854800bc94b;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Protected Hotspot Options'**
  String get inlineText_d71035f8d7c85940;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Select VPN Provider'**
  String get inlineText_14bd9f9fb68a5859;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Inspect XFRM interface, table 220, IP rules, and verify live connectivity safely.'**
  String get inlineText_cbca739d8ccd07e1;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get inlineText_d0527e4b3d658351;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'50 GB'**
  String get inlineText_f7fa281a488a9a0d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Notify only'**
  String get inlineText_a38c71d45d21c4ab;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get inlineText_b8352b44a588721c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'نام کاربری (Username)'**
  String get inlineText_e55142a1acfd8059;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Load apps'**
  String get inlineText_f2b10ce04701badc;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'-- ms'**
  String get inlineText_b1fe69e5cd48a270;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Android app bypass applies after reconnecting the VPN.'**
  String get inlineText_989961ec7fc20bdd;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'HTTP/2 CONNECT'**
  String get inlineText_039b675cbfc3719c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Console output copied to clipboard.'**
  String get inlineText_7366b74aba11b666;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Support bundle exported and copied to clipboard.'**
  String get inlineText_0173658e5af8698d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Configures Windows ICS for the VPN adapter when Mobile Hotspot is active. The app verifies the ICS binding; client Internet traffic still needs an end-to-end check.'**
  String get inlineText_9f658c229a11bef6;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No devices currently connected to hotspot.'**
  String get inlineText_73997b80ca90ece7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Cancel Test'**
  String get inlineText_ebf5f31bd3fa8cf4;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Traffic Analytics'**
  String get inlineText_4bfa799fae21b467;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'A calmer connection. A brighter world.'**
  String get inlineText_b28b26cf1cc18caf;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Country & App Bypass'**
  String get inlineText_ed95556c5c93ded1;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'خروجی‌گرفتن از پروفایل‌های اتصال'**
  String get inlineText_4cf9134d1c9ed485;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get inlineText_2a78025de6aae5e7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Surfshark'**
  String get inlineText_cbbea9d808ebfe70;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Service Password / Private Key'**
  String get inlineText_88921e28030e4255;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No advanced policy rules configured.'**
  String get inlineText_39c3183ee0cbb997;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Selected country IP ranges bypass the VPN. Reconnect after changing rules. Domain-only rules need DNS-aware routing.'**
  String get inlineText_6cb8a5b3137a00c3;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Starting connection…'**
  String get inlineText_8bb1de2dfce6294f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get inlineText_22965568d22a14ee;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Auto (Fallback)'**
  String get inlineText_e7e2af717bdfb964;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'100 GB'**
  String get inlineText_42b5bc901ede1799;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'System Apps'**
  String get inlineText_24ef681c569b5c42;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Route Table & XFRM Verification'**
  String get inlineText_3e2421c56094293c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Force VPN Encrypted'**
  String get inlineText_5d7cd082fc9987e9;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Service Username / Key ID'**
  String get inlineText_1159717463f1ebc3;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get inlineText_0e76960093379060;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Import ZIP'**
  String get inlineText_cb0bf46bf1e385db;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Always-on and Lockdown cover supported VPN connections. DNS and IPv6 policies are enforced by the active tunnel.'**
  String get inlineText_2da236423b3b5ad5;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Add application (.exe)'**
  String get inlineText_50829e8639527356;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Add an application before enabling app bypass.'**
  String get inlineText_f6f39fe075ffa5de;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Scan QR'**
  String get inlineText_5a99f6fa7e98657a;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Explain why a destination routes via VPN or Direct ISP, with rule priority matching.'**
  String get inlineText_c4b6bf5634f8ce91;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get inlineText_cf0883343f4abef7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'فایل‌ها با موفقیت استخراج شدند.'**
  String get inlineText_adec3733feabdc2d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Android supports IPv4 and IPv6 CIDR bypass. Reconnect the VPN after changing these routes; app bypass also takes effect after reconnect.'**
  String get inlineText_0c567745c63c57bc;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Auditing…'**
  String get inlineText_cb0544450e1be874;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Android Lockdown is active'**
  String get inlineText_9e19b3ae1edc6135;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Open Mobile Hotspot'**
  String get inlineText_0acb9208ef119b21;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Manage connection, security, and appearance'**
  String get inlineText_61118b57b609e8fd;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get inlineText_ed077f3d8125d60d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Locations & Routes'**
  String get inlineText_bbf3d191d555c872;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Pro Connection Error'**
  String get inlineText_c01d52ac9ed5701a;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Safe Apply & LKG'**
  String get inlineText_25a76b0a4ba5c39d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Deselect all'**
  String get inlineText_967549497036d513;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Protection HUD'**
  String get inlineText_72a47f8e322a40de;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Offline cache ready'**
  String get inlineText_2398cc05005cca7f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'این شناسه به عنوان اثرانگشت سخت‌افزاری (Hardware Device ID) برای احراز هویت دستگاه در سرور استفاده می‌شود. می‌توانید مقادیر را تغییر دهید یا خودکار دریافت کنید:'**
  String get inlineText_469f27ad0a12c557;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'IKEv2'**
  String get inlineText_783547972fe4ca08;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Default Hotspot Route'**
  String get inlineText_03f15c48644862ae;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Start Guest Wi-Fi'**
  String get inlineText_bd5a05ddab828e6d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Remaining traffic:'**
  String get inlineText_4968fc7fef5ea571;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Firefox Account'**
  String get inlineText_52a0bc5a1f46b6a1;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Temporary isolated guest Wi-Fi with automatic expiry and subnet isolation.'**
  String get inlineText_bb93f3cc26e28600;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Checking secure credential vault…'**
  String get inlineText_b361f42b64c263d8;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Direct (Bypass VPN)'**
  String get inlineText_7d037fcb85b5a1eb;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'A VPN operation is already running. Please wait for its status to update.'**
  String get inlineText_e65731cec92db7d5;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Enable Hotspot Sharing (ICS)'**
  String get inlineText_f24d839a275e6eaa;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'ورود با موفقیت انجام شد و فهرست سرورها به‌روزرسانی گردید.'**
  String get inlineText_03a71a235bfb6b30;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Firefox Account Email / User'**
  String get inlineText_52933373144828ee;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Country IPv4 ranges bypass the VPN after reconnecting. App bypass uses the Windows physical interface and requires the Harmoney service.'**
  String get inlineText_d86322c4ceb937de;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'شناسه سخت‌افزاری دستگاه با موفقیت تنظیم شد.'**
  String get inlineText_77f0b86ebfb47aa6;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'To prevent Android from killing the VPN connection in background, disable battery optimization for this app.'**
  String get inlineText_35d7442440a55ab9;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Firefox data allowance'**
  String get inlineText_3da7d703985421ec;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Manage Firefox VPN Account'**
  String get inlineText_316f766fb0bc3a72;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Advanced Policy Rules'**
  String get inlineText_69b95013a9101213;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'VPN-to-hotspot ICS binding verified.'**
  String get inlineText_9d0c59a66cf45b32;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get inlineText_7ae00a283ea9b728;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'تنظیمات اتصال سرویس'**
  String get inlineText_0dd786510199ca80;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Stop Guest'**
  String get inlineText_708e318e0225bc88;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Session Duration'**
  String get inlineText_ad4b77a68783ec24;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Firefox Account credentials are sent directly to Mozilla by the local Windows helper. The password is not saved; only the account tokens needed for future connections are stored locally.'**
  String get inlineText_25dcc872936aab98;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Windows per-app bypass routes selected apps directly through the physical adapter, independent of the active VPN protocol. Windows build support and the privileged Harmoney service are required.'**
  String get inlineText_219113c4bbe2e98c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'0 GB (Off)'**
  String get inlineText_21e3324fcec20e63;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Advanced Routing & Protection'**
  String get inlineText_20636a0c41a3f954;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Secure VPN DNS'**
  String get inlineText_dc8bf418d2bb68a6;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Live Active'**
  String get inlineText_a0b16ccf9021fc82;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Queued…'**
  String get inlineText_abff5572a370fab7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Xray routes selected IPv4/IPv6 ranges and the bundled Iranian domain list directly. Reconnect after changing rules.'**
  String get inlineText_b666d8596482e260;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Route specific destinations through Direct, Force VPN, or Block.'**
  String get inlineText_df74ccb45d0e395d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get inlineText_1509f561f2416598;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Force Hotspot VPN DNS'**
  String get inlineText_7122ed800123d8e7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'دریافت خودکار از سخت‌افزار سیستم'**
  String get inlineText_6b97c41651da98ce;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Private connection service'**
  String get inlineText_6f98676a0a7b4953;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Block connections without VPN'**
  String get inlineText_0fb48c86db0c3f8f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Talker Logs'**
  String get inlineText_2427a4a9d7993571;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Run Hotspot Doctor'**
  String get inlineText_da223b83cdddd9db;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Renew session tokens or switch account'**
  String get inlineText_a899ea0cfb536e60;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'برای بارگذاری سرورها، اشتراک خود را وارد کنید'**
  String get inlineText_70e3135873ca12f3;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get inlineText_98e33b0f3104fcf1;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Live Real-Time Speed'**
  String get inlineText_c6c2daab1f7d2fe5;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Add at least one application to turn this on.'**
  String get inlineText_81e9f4e64a840785;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get inlineText_942087cc2d41e013;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Create new list'**
  String get inlineText_3fb9aa9bdbb56bb6;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Logs copied to clipboard (secrets redacted).'**
  String get inlineText_47e52e5e678a2248;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Diagnostic Terminal Output'**
  String get inlineText_cf406ea597d7a11b;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Block IPv6 (Leak Protection)'**
  String get inlineText_5c8925f30317c4ae;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Service username and password required for handshakes'**
  String get inlineText_d69fa3897fde1fd7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'200 GB'**
  String get inlineText_f98a2522000fbae8;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'اعمال در تنظیمات'**
  String get inlineText_30dc86f4e57e4278;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Block all internet leaks when the VPN drops unexpectedly'**
  String get inlineText_14eee0b522b0a07f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Route chosen applications or network subnets outside the VPN.'**
  String get inlineText_b813ec3c634e571c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Hardware-backed encryption: Credentials are encrypted in platform vault.'**
  String get inlineText_d21cca3751709e6f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Endpoint Candidates'**
  String get inlineText_ff4fcf35e586d0ca;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Route Explain'**
  String get inlineText_85455433f68a0eea;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Test all'**
  String get inlineText_e6e283499c38fe99;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'باز کردن پوشه'**
  String get inlineText_df8bb62c5262aace;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Personal subscriptions'**
  String get inlineText_ca4ce07eeab21f24;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Release Highlights'**
  String get inlineText_ccccab7c5d91fcc1;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Re-login'**
  String get inlineText_fbfd8ce759281a7c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Repair Hotspot Routing'**
  String get inlineText_48a39c950b733f9d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED'**
  String get inlineText_1f914c4386c0676e;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Update Available'**
  String get inlineText_fd67fb8b214d0251;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Start Speed Test'**
  String get inlineText_5e0104e1d0dd6cc2;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Always-on and Lockdown cover Firefox, WireGuard, IKEv2 and OpenVPN. DNS and IPv6 policies are enforced by each active tunnel profile.'**
  String get inlineText_9225ef77a358de37;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Enable per-app bypass'**
  String get inlineText_04b476ffe80f996f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'پیکربندی سرور (پیش‌فرض سورس کد - فقط در حالت Debug)'**
  String get inlineText_e0b8edec85fbec56;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'جهت اتصال آسان‌تر از خط فرمان (رمز عبور متن آشکار ذخیره می‌شود)'**
  String get inlineText_a47e46554344d955;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Load installed applications to configure per-app bypass.'**
  String get inlineText_23be2e66d9c671b4;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'ورود مقادیر و ساخت دستی'**
  String get inlineText_60cc8000034bbcc6;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'ورود به حساب Harmoney Pro'**
  String get inlineText_14ea6d8e1758ce8f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get inlineText_b764cdc0eab71374;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'More protocols and connection options'**
  String get inlineText_55b98eedd56ac65c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Cisco'**
  String get inlineText_aa669b285cc133bf;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Ping All'**
  String get inlineText_5e414ee0c5da2dde;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Add an HTTP or HTTPS subscription URL. Links are stored securely on this device.'**
  String get inlineText_e281f68dc29144b2;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Session Download:'**
  String get inlineText_90f46423c0074765;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Selected apps use the physical network directly. Other apps continue using the VPN.'**
  String get inlineText_36230e6a755f25c0;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Enabled for Harmoney'**
  String get inlineText_e0166a69e70a0063;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Saved subscriptions'**
  String get inlineText_68eda25757c8e549;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get inlineText_639a40e82b9a96f0;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Select applications to bypass the VPN tunnel and connect directly to the internet.'**
  String get inlineText_2a5c4cf3cff579c9;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Firefox VPN Account'**
  String get inlineText_229b05d20a6d2706;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Connection service'**
  String get inlineText_e1f42d830cee8336;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get inlineText_69cd3590300a68c6;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Android Protection'**
  String get inlineText_79f4939f31f74600;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Live connection events from all providers and protocols'**
  String get inlineText_e9f61c5ca23f266f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Smart'**
  String get inlineText_a0610c3d3b91cb4f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Download & Update'**
  String get inlineText_c0671aa2f2dd814a;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Live Speed & Traffic'**
  String get inlineText_1a938f00d128e40c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Hotspot IPv6 Policy'**
  String get inlineText_74ca300a6cadb68a;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Routing Policy:'**
  String get inlineText_c2ed1ff176791192;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Pro Sign In Required'**
  String get inlineText_b8b960fef99adfb1;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Harmoney'**
  String get inlineText_a23e527773f02a67;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Quota Exceeded Action:'**
  String get inlineText_2067e249c2b1e5de;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Explain'**
  String get inlineText_3b61e4e936523550;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Rules apply to the active VPN route. UDP relay is not complete yet; apps requiring UDP may not be fully bypassed.'**
  String get inlineText_bd8256cb9d1b917f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'شروع استخراج'**
  String get inlineText_664479f12348ca20;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Surfshark Service Account'**
  String get inlineText_2fd1a96a8b9a93c0;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Uses Windows native per-process routing to send selected apps directly over your physical network adapter. Requires a compatible Windows build and the Harmoney VPN service.'**
  String get inlineText_37d1bd40cc9b7ba7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Country destinations bypass the VPN directly through the ISP; other traffic remains inside the VPN.'**
  String get inlineText_e2419bb6585fdf13;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No active hotspot interface detected on system.'**
  String get inlineText_566bd7ec6c74731b;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'The update will download and install directly inside Harmoney.'**
  String get inlineText_1d653fc4503ec979;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Hardware Profile: Dell Latitude 7210 & Intel / Cellular LTE'**
  String get inlineText_9e4a7faff61f59aa;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No CIDR rules yet.'**
  String get inlineText_515c0e6425c1c144;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Enable Lockdown in Android VPN settings'**
  String get inlineText_60c5a84642b61c53;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'رمز عبور (Password)'**
  String get inlineText_cb222670e743b957;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Block Destination'**
  String get inlineText_d1ad5bbe561caba5;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Copy Report'**
  String get inlineText_54b8e0c0c268c154;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'The Harmoney Pro download link is not available yet.'**
  String get inlineText_7539a050c6489953;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get inlineText_4759498ac2a719c6;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Add subscription'**
  String get inlineText_089899b425d4bcda;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Guest Hotspot'**
  String get inlineText_838c8e30c9aeac8a;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Keep domestic services and banking reachable when the VPN drops'**
  String get inlineText_475e433587200d99;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Enable Split Tunneling'**
  String get inlineText_0b4666b1dcc9f6f9;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Disconnecting…'**
  String get inlineText_cb2b6a572a8588d8;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Download Harmoney Pro'**
  String get inlineText_fb94fc702eb62ab7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'DISCONNECTING'**
  String get inlineText_ad7b66a913a46286;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get inlineText_74a883a037bc227f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'API Settings'**
  String get inlineText_6c2a96757bb1ab31;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'The previous VPN operation timed out. You can try again.'**
  String get inlineText_a63b3bb0ad3689a0;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Route test'**
  String get inlineText_b11e1aa7421b52e2;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get inlineText_73b6e48a1b552d11;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get inlineText_c1c1009d3f37ec05;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Security session expired; please sign in again to use servers.'**
  String get inlineText_fa488105cb65db88;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Unlimited (Off)'**
  String get inlineText_4bd0e4ba0e817d11;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get inlineText_690dbe9dc0993c42;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'New Version Available'**
  String get inlineText_005ef7725a64c7ed;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Routes from Xray, WARP and MASQUE configurations. Connection is shown after traffic verification.'**
  String get inlineText_92723a5ff9689c3d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Protocol coverage'**
  String get inlineText_c5842271209f9ff7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Select all'**
  String get inlineText_1fc9a387654d410f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Install Now'**
  String get inlineText_b0e17c2810653b13;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Custom Location Lists'**
  String get inlineText_5aa9ef74c967df76;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Hotspot sharing preference saved.'**
  String get inlineText_ad208643ab98407d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Hotspot clients only'**
  String get inlineText_5e1133591cfeb5b0;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No matching events yet. Start a VPN connection to collect logs.'**
  String get inlineText_d636391ee4236395;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Scan subscription QR'**
  String get inlineText_ebbe7ab0b58e10be;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Show servers'**
  String get inlineText_092283a13b34e9ed;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Firefox Account credentials are sent directly to Mozilla by the native Android engine. Encrypted tokens never enter Flutter storage.'**
  String get inlineText_e548577f0fd46659;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Re-login to account'**
  String get inlineText_a836bff92bbc5af0;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Export the selected server list as JSON and TXT files.'**
  String get inlineText_50688e3917acdfec;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Logged In'**
  String get inlineText_9b13e877e4aa90a7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'ورود و بارگذاری سرورها'**
  String get inlineText_854d3eab6d8d5d33;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No favorite servers.'**
  String get inlineText_c0d31ce834b82a7e;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Update Download Complete'**
  String get inlineText_4511036a54304f80;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Redirect all device DNS queries to Surfshark DNS.'**
  String get inlineText_76b23f49c19a08d8;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get inlineText_5a23444828db654a;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Live Connection Logs (Stream)'**
  String get inlineText_5fedacfb015245b7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'IPv6 leak protection'**
  String get inlineText_7446eabf9cf13622;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No Limit Set'**
  String get inlineText_2de8796023cbb4c7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'WFP applies the rules independently of IKEv2, WireGuard, OpenVPN, and Xray. UDP relay is not complete yet, so apps requiring UDP will not be fully bypassed.'**
  String get inlineText_7a7832e87a88a9c7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'CONNECTING'**
  String get inlineText_a0e1a519f04a9b3e;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Allow Iran traffic during Lockdown'**
  String get inlineText_289afa804e34a45f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No subscriptions added yet.'**
  String get inlineText_ce13fbfce966190e;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Quota information unavailable'**
  String get inlineText_893e490d64407b8e;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Live Logs'**
  String get inlineText_9b89006aec802e94;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get inlineText_630c2f1c0ee1b8d7;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get inlineText_92340695899bd2d8;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Manage Account'**
  String get inlineText_203229774cceb5f3;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Add Policy'**
  String get inlineText_bf6ccf81398eed34;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No imported profiles found.\\nImport a ZIP archive from Surfshark Manual Setup.'**
  String get inlineText_a9884f2d7e028e02;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Update Interrupted'**
  String get inlineText_0c16e4802957bf2a;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Select a location or use fastest server'**
  String get inlineText_94f105a3d269670f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Provider'**
  String get inlineText_472590ae974d4c1f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'DISCONNECTED'**
  String get inlineText_5541de9515522b98;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Protection settings are applied by Android VpnService and take effect after reconnecting.'**
  String get inlineText_0e223795fafb578e;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get inlineText_bfd402b2f6f38125;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Overall Tunnel Health'**
  String get inlineText_970c6a41454fa6ee;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Route IPv6 through supported tunnels; reconnect to apply'**
  String get inlineText_f4c3265a274f6fa8;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Mbps'**
  String get inlineText_ecf1d7c868ee46fc;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Start Guest Hotspot'**
  String get inlineText_f9f60b474c0c751b;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'FireTunnel authenticates with Firefox Accounts. Credentials are sent only to the root-isolated native helper; tokens never enter Flutter storage.'**
  String get inlineText_a840a9de3127ef53;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Emergency Stop'**
  String get inlineText_dcbf414d58c417be;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Anti-Censorship Core'**
  String get inlineText_4f5845ea70794fc8;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Enable app bypass'**
  String get inlineText_0234c7f3ac8b5b71;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Establishing secure tunnel…'**
  String get inlineText_24b8d9733417f7f2;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get inlineText_ec963ffc911b8401;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Encrypted tunnel verified with zero packet leakage.'**
  String get inlineText_c46c2996102a4b2c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Change'**
  String get inlineText_c0bf75bd78bf9572;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get inlineText_bcc0bcc9140b0c97;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Per-app bypass'**
  String get inlineText_e7977ed18b1df209;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get inlineText_0e91610117029a62;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Configure'**
  String get inlineText_6defafa2caa65304;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Disconnect is still being processed…'**
  String get inlineText_651f94aafffed603;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Signing in…'**
  String get inlineText_8b9d3de8ae00c89c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Always-on VPN'**
  String get inlineText_58b2c361864f4c09;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Service Credentials & Keys'**
  String get inlineText_8aa2064e8f385ad3;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Per-app VPN bypass'**
  String get inlineText_7bcc95e0b5bd34c6;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Downloading Update...'**
  String get inlineText_be6ee118f6ce86a8;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Force HTTPS traffic through TCP/TLS for consistent filtering.'**
  String get inlineText_67865eaee364dcbe;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get inlineText_a52ace420f2175d0;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Live bandwidth, data accounting & quota'**
  String get inlineText_2eb0c5a3ce65868c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Battery Optimization Active (Doze Mode)'**
  String get inlineText_54386d5a6b84b6e8;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Smart routing and personal subscriptions'**
  String get inlineText_d0e13ceb47c44a7f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Active Surfshark Protocol'**
  String get inlineText_1924fc22b6e86d49;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Reconnect the VPN to apply Android CIDR routes.'**
  String get inlineText_1eecb5c3f3e93223;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'پیش‌فرض سرور'**
  String get inlineText_0ef1d485c68962e3;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Host and Hotspot clients'**
  String get inlineText_1e77e9d04f19d6d9;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Speed report copied to clipboard!'**
  String get inlineText_f5af9ab211b447cd;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Block QUIC (UDP 443)'**
  String get inlineText_edb18cd663b5e4de;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Manage connected devices, bandwidth quotas, guest Wi-Fi, and routing policies.'**
  String get inlineText_ea32ef00138d4d85;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Force VPN'**
  String get inlineText_46ff63176dfa61e2;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Enforce Quota'**
  String get inlineText_f6f75ce9317a16db;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get inlineText_72fe71cb37d209d2;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'FASTEST ⚡'**
  String get inlineText_56b598dee4ddc136;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get inlineText_19766ed6ccb2f4a3;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get inlineText_7a1f2a83aca9a081;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Live Verification'**
  String get inlineText_876662d1d94ad13b;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Bypass'**
  String get inlineText_bf26c2ac087da6ff;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Updating…'**
  String get inlineText_dfe40efe921fe88e;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Emergency Stop executed: Processes terminated and physical network unjammed.'**
  String get inlineText_247ea0cd6733f4fc;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Quick connect'**
  String get inlineText_7207233f2b0688ac;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Split Tunneling'**
  String get inlineText_3c4846f1083e22ec;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'محل ذخیره پیش‌فرض:'**
  String get inlineText_ec93679622950c2c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get inlineText_a76e13b9839270eb;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Check Updates'**
  String get inlineText_a4738b604a205c2e;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Clear stored credentials from this device'**
  String get inlineText_c4b662bd95db40f1;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Pause Device Connection'**
  String get inlineText_adde42042c5c3caa;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'شناسه پیش‌فرض سرور'**
  String get inlineText_200bc33c838b6604;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get inlineText_ea61bc15688d1e48;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Network Subnets (CIDRs)'**
  String get inlineText_d3ee5446e626ae8f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Country bypass DAT rules updated. Reconnect VPN to apply.'**
  String get inlineText_1640ef1a61f9a5ee;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Connecting'**
  String get inlineText_d403c686f6a10480;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Choose your desired VPN network provider'**
  String get inlineText_351d257b580bc419;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Sign In to Harmoney Pro'**
  String get inlineText_1b4154057e37a0ff;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Select Surfshark Protocol'**
  String get inlineText_ae4e9b1ef2aa3860;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get inlineText_83b12c2216efb4fd;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Recommended Fast Routes'**
  String get inlineText_269f0582347dbdf6;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Choose QR image'**
  String get inlineText_9918aaf803c54fcf;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'تست اتصال'**
  String get inlineText_307e253c39bae652;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Redirect device DNS queries through the selected VPN.'**
  String get inlineText_337db382095ce88d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'WireGuard'**
  String get inlineText_5bb6d1b367fc7674;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No imported profiles found.\nImport a ZIP archive from Surfshark Manual Setup.'**
  String get inlineText_e8696f00501ad45a;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'User Apps'**
  String get inlineText_b0230c537ca88c85;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'VPN Hotspot Sharing (Windows ICS)'**
  String get inlineText_e9d51941d0c1f37b;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Show All Servers'**
  String get inlineText_6bcc8512de553613;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No custom lists created yet.'**
  String get inlineText_9d4be9539f27c657;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'FireTunnel Token / Password'**
  String get inlineText_782ec78be81185c6;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'KEY REQUIRED'**
  String get inlineText_8a76134e54b9cfac;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get inlineText_75081b593d15cf6e;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get inlineText_2e5f79bb94a8c40b;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'New Custom List'**
  String get inlineText_471354282a521dd1;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Sign In / Account'**
  String get inlineText_c7a43600b2a6507c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Lockdown mode (Kill Switch)'**
  String get inlineText_a919cfce15c49685;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Credentials encrypted in privileged platform keystore'**
  String get inlineText_dd9e7664f013c1e5;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Throttle to 128kbit/s'**
  String get inlineText_f50e254cf57f39fd;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Operation failed'**
  String get inlineText_4e1af7c74096cf0a;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get inlineText_43e3ece73ff8f4eb;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Hotspot & Devices'**
  String get inlineText_e94356112ce4c59c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'بستن'**
  String get inlineText_313cbecb4dd35728;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get inlineText_d6eafe8235910042;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Block internet'**
  String get inlineText_06bacdb5d18b0261;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Add CIDR rule'**
  String get inlineText_8200a83deae2141b;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Set Quota'**
  String get inlineText_a429cd15905e58a5;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'VPN service credentials saved securely.'**
  String get inlineText_57c95945cb8fe988;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Manage VPN Profiles'**
  String get inlineText_4ff946afb073da91;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'ذخیره نام کاربری و رمز عبور در فایل متنی'**
  String get inlineText_9bf1e054ed4cbacb;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Run Full Audit'**
  String get inlineText_6cb535909a7f3875;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Sort by latency'**
  String get inlineText_8fcbf6bb3bf0b5a0;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Add Routing Policy Rule'**
  String get inlineText_45ee3e003650a75f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Disconnect requested…'**
  String get inlineText_04b93833872cc896;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Save securely'**
  String get inlineText_ad3d9699142e5339;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'VPN Debug Logs'**
  String get inlineText_c63e407525237f8d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Xray routes selected IPv4/IPv6 ranges and the bundled Iranian domain list directly. Windows IKEv2 route injection remains IPv4-only. Reconnect after changing rules.'**
  String get inlineText_530692d19626e11a;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'OpenVPN'**
  String get inlineText_7c147e122ed7eeac;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Smart Service Suitability'**
  String get inlineText_e17b6227325e1a8d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Tunnel path audits, leak tests, latency probes, and runtime telemetry'**
  String get inlineText_73bfa58718abc908;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Monthly Allowance'**
  String get inlineText_659e50811965fe84;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Ping'**
  String get inlineText_6a4c3a4483b04488;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get inlineText_11a6767d5674c7e4;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get inlineText_acfc5be785a9bb3d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get inlineText_c3812fc4acb861d5;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Client Isolation'**
  String get inlineText_fe4f5f9fd7be7d92;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get inlineText_865e89de78d94c74;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Update Country Rules'**
  String get inlineText_0004bf6db9f12d54;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Package installer launched. Tap below if you need to relaunch.'**
  String get inlineText_3e695daee969126c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No servers found.'**
  String get inlineText_a8b3ef62feba073f;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Firefox VPN Token & Auth'**
  String get inlineText_9ef0f877893218f3;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'UNKNOWN'**
  String get inlineText_23759997b3c59884;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Hotspot Doctor & Diagnostics'**
  String get inlineText_e3b78e09863c99ac;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get inlineText_48845bff334a50a5;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get inlineText_54a0e8c17ebb21a1;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'by Harmoney'**
  String get inlineText_c8fd5b73d111ee1d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Pro Service'**
  String get inlineText_44e1911932d93644;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Monthly Data Quota'**
  String get inlineText_f6be68de3c8d5e7d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No endpoint candidates configured.'**
  String get inlineText_51452219a8542052;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Sign in to activate Firefox tunnel and view data quota.'**
  String get inlineText_f493cd9c7ae396ec;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Save Quota'**
  String get inlineText_8e1b786c7913210c;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get inlineText_efb52e7172b77731;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Add split-tunnel CIDR'**
  String get inlineText_2c2648394a4fe357;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Prevent connected hotspot clients from communicating directly.'**
  String get inlineText_ff6d5def69d21f32;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Test'**
  String get inlineText_532eaabd9574880d;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Tunnel-managed DNS; reconnect to apply'**
  String get inlineText_02a2c8aa276c0c36;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Domains, IPv4 addresses or CIDRs that always bypass the VPN'**
  String get inlineText_abaf4ed786bb9340;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Lightweight Firefox VPN tunnel'**
  String get inlineText_49a2fc4df1b8bad5;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Last Speed Benchmark:'**
  String get inlineText_2faba03e2b8726a9;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'CONNECT'**
  String get inlineText_5bb4dc6f47d4c040;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Import ZIP Archive'**
  String get inlineText_9d4ad0b61b2359e9;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'You will receive visual alerts when reaching this limit.'**
  String get inlineText_243a20f9ba6c2892;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics & Health'**
  String get inlineText_d3ae19164d4f0f44;

  /// Legacy inlineText translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Hotspot Inactive'**
  String get inlineText_3dd7fcefed0e482c;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **' of '**
  String get inlineAttribute_a4282e4b2298b90b;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Search countries…'**
  String get inlineAttribute_1a765360a12ba19c;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Route action'**
  String get inlineAttribute_74c8361a4a1ca4c4;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Downloading Update...'**
  String get inlineAttribute_be6ee118f6ce86a8;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Domain, IPv4 or CIDR'**
  String get inlineAttribute_440488e7af1a1602;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'The update will download and install directly inside Harmoney.'**
  String get inlineAttribute_1d653fc4503ec979;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Data Quota (MB, 0 = unlimited)'**
  String get inlineAttribute_372167bb30249862;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'باقیمانده'**
  String get inlineAttribute_4b329f46e3e4aa50;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'✓ Verified: All checks passed (XFRM, table 220, HTTPS trace)'**
  String get inlineAttribute_8d634757de9d475f;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'نام کاربری اشتراک'**
  String get inlineAttribute_b9893538a61f89ed;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'چسباندن'**
  String get inlineAttribute_2c80752638d7bd54;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Domain or IP'**
  String get inlineAttribute_df3b5afaf2778138;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Subscription URL'**
  String get inlineAttribute_1803685bb41d1d8d;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Target Domain or CIDR (e.g. 1.1.1.1/32)'**
  String get inlineAttribute_09231cb8338a0158;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'نام دلخواه (اختیاری)'**
  String get inlineAttribute_474276a023bed5d8;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'سرور محبوب'**
  String get inlineAttribute_69612b885a0aff86;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get inlineAttribute_e7cf3ef4f17c3999;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Paste'**
  String get inlineAttribute_f3380f7b44bd70af;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'armoney'**
  String get inlineAttribute_ad0eae0c2cd935dc;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Refresh all'**
  String get inlineAttribute_3c128b5436b6d704;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get inlineAttribute_969ccbd3cf6300ec;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'جستجو در نام یا پکیج برنامه‌ها'**
  String get inlineAttribute_1b37568c4311efeb;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'e.g. 192.168.1.0/24 or 10.0.0.1/32'**
  String get inlineAttribute_4524cd31be7128c2;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Enable endpoint'**
  String get inlineAttribute_6077b2acb8754468;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'CIDR or IP'**
  String get inlineAttribute_b84364651ab4f422;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get inlineAttribute_73b6e48a1b552d11;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Email verification code'**
  String get inlineAttribute_be420e2629f2ebfa;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get inlineAttribute_c1c1009d3f37ec05;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Duration (Minutes, 5-1440)'**
  String get inlineAttribute_b29904a25f1802a7;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Check Updates'**
  String get inlineAttribute_a4738b604a205c2e;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Clear view'**
  String get inlineAttribute_428ffb88a815b9be;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'بروزرسانی همه'**
  String get inlineAttribute_6016fb957fe261cc;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'New Version Available'**
  String get inlineAttribute_005ef7725a64c7ed;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'آزمون سرور'**
  String get inlineAttribute_a1ab6eca52db1b3b;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Copy logs'**
  String get inlineAttribute_4504b2c82bef3d20;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Configure device'**
  String get inlineAttribute_356c851e4ec59a3d;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'List name (e.g. European Fast)'**
  String get inlineAttribute_c2ef8dd2545d2b04;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Favorite server'**
  String get inlineAttribute_f69c34c2fc4b9667;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'شخصی‌سازی و ساخت دستی شناسه سخت‌افزاری'**
  String get inlineAttribute_00ea6b3b42dfb4b5;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Scope'**
  String get inlineAttribute_b073f6c68ef87211;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'حذف'**
  String get inlineAttribute_59ca629220a63ede;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Delete profile'**
  String get inlineAttribute_47311af432a79c40;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Disable endpoint'**
  String get inlineAttribute_80884fb559e05bd9;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Install Now'**
  String get inlineAttribute_b0e17c2810653b13;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Close Output'**
  String get inlineAttribute_6769ff871d28e2ce;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'••••••••••••••••'**
  String get inlineAttribute_01e8ee2044c91ec5;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Custom Lists'**
  String get inlineAttribute_cdf0cf9ecdfecba8;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Speed limit (kbit/s, 0 = unlimited)'**
  String get inlineAttribute_05eccbc907509b4b;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Retry probe'**
  String get inlineAttribute_d4e54f76384bf545;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Clear logs'**
  String get inlineAttribute_d3a8a299660b14d0;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Copy Output'**
  String get inlineAttribute_7a3517625d7f32a6;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Filter by provider, protocol, status, or error'**
  String get inlineAttribute_96f681e1e0e80f53;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Update Download Complete'**
  String get inlineAttribute_4511036a54304f80;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get inlineAttribute_2e5f79bb94a8c40b;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **' ?? '**
  String get inlineAttribute_842d8e425ecb5b64;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Copied subscription link detected.'**
  String get inlineAttribute_ce21ed09a64c529b;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Quick Menu'**
  String get inlineAttribute_1e5a5a18ae04113a;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Policy'**
  String get inlineAttribute_c611981fab983bc6;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get inlineAttribute_43e3ece73ff8f4eb;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **' از '**
  String get inlineAttribute_a624a1e41ffdc6d6;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Account options'**
  String get inlineAttribute_fb156130b17c4be3;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Copy visible logs'**
  String get inlineAttribute_0e08705e56eb56d8;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Debug Logs'**
  String get inlineAttribute_c16db1ad02461665;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Refresh Guest Status'**
  String get inlineAttribute_f16edb7443f05225;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Personal subscriptions'**
  String get inlineAttribute_ca4ce07eeab21f24;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Release Highlights'**
  String get inlineAttribute_ccccab7c5d91fcc1;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Search country, city, IP...'**
  String get inlineAttribute_0b33748029674d12;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Update Available'**
  String get inlineAttribute_fd67fb8b214d0251;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Update Interrupted'**
  String get inlineAttribute_0c16e4802957bf2a;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'لینک کپی‌شده پیدا شد.'**
  String get inlineAttribute_a291d1863aeedb00;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'H'**
  String get inlineAttribute_44bd7ae60f478fae;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Export log file'**
  String get inlineAttribute_c97f606c82316bc1;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Name (optional)'**
  String get inlineAttribute_e09b37bcc4f301f4;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'عملیات حساب'**
  String get inlineAttribute_0ca0dfe5e1ff7a8e;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get inlineAttribute_c3812fc4acb861d5;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Package installer launched. Tap below if you need to relaunch.'**
  String get inlineAttribute_3e695daee969126c;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get inlineAttribute_48845bff334a50a5;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Test server'**
  String get inlineAttribute_9b64398e9f8fef53;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Filter by phase (PREPARING, IKE, AUTHENTICATING, VERIFYING, CONNECTED, FAILED) or keyword…'**
  String get inlineAttribute_ea9d303a5e54fb42;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get inlineAttribute_d640c7421da06661;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'لینک اشتراک'**
  String get inlineAttribute_140669bdb031e927;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'username'**
  String get inlineAttribute_16f78a7d6317f102;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Guest SSID'**
  String get inlineAttribute_e1a0ff7a5353c7fe;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Domain or IP to explain'**
  String get inlineAttribute_e098b630f04d6d69;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'رمز عبور اشتراک'**
  String get inlineAttribute_0f39d38fb65968d0;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get inlineAttribute_858e4ba7a29fd38b;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Search installed apps or packages'**
  String get inlineAttribute_3dea43271fc3f002;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'اشتراک‌های شخصی'**
  String get inlineAttribute_ac8619ca1957889c;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'جستجوی کشور، شهر، آی‌پی...'**
  String get inlineAttribute_f8a5decc321d9f7a;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Waiting for engine connection log stream events?'**
  String get inlineAttribute_82ab1760fe92313f;

  /// Legacy inlineAttribute translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Download & Update'**
  String get inlineAttribute_c0671aa2f2dd814a;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get inlineTextTemplate_2e5f79bb94a8c40b;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Failed to update app rule: QZXVAR0QZX'**
  String get inlineTextTemplate_4b5e556c141daca0;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX CIDRs'**
  String get inlineTextTemplate_fe5115c86ab563dd;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Latency test failed: QZXVAR0QZX'**
  String get inlineTextTemplate_f6fd414931d6a430;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Downloading Update...'**
  String get inlineTextTemplate_be6ee118f6ce86a8;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Export failed: QZXVAR0QZX'**
  String get inlineTextTemplate_fe4eac0d19b1f8b2;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Failed to delete: QZXVAR0QZX'**
  String get inlineTextTemplate_846aa6f62acf906c;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'The update will download and install directly inside Harmoney.'**
  String get inlineTextTemplate_1d653fc4503ec979;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Could not add application: QZXVAR0QZX'**
  String get inlineTextTemplate_0b59208593d747ad;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Could not load servers: QZXVAR0QZX'**
  String get inlineTextTemplate_bfafae05cba5bb86;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Could not load app bypass settings: QZXVAR0QZX'**
  String get inlineTextTemplate_1a1e3bf73b281b6d;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Error: QZXVAR0QZX'**
  String get inlineTextTemplate_3c17c68905f8856a;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Country Bypass: QZXVAR0QZX'**
  String get inlineTextTemplate_e52ff58d5b3af8f0;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Could not update app bypass: QZXVAR0QZX'**
  String get inlineTextTemplate_8bc4d9b4f92c60ab;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Unjam failed: QZXVAR0QZX'**
  String get inlineTextTemplate_8df4368ecb09de86;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Connected Devices (QZXVAR0QZX)'**
  String get inlineTextTemplate_0d1e9be15aed1231;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'↓ QZXVAR0QZX Mbps'**
  String get inlineTextTemplate_601fcd78f13053e1;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'شناسه سخت‌افزاری از QZXVAR0QZX (QZXVAR1QZX) دریافت شد.'**
  String get inlineTextTemplate_972ff659f6e27b76;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Release Highlights'**
  String get inlineTextTemplate_ccccab7c5d91fcc1;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Saved to QZXVAR0QZX'**
  String get inlineTextTemplate_a170e1c90b9a1695;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Ping: QZXVAR0QZXms · Jitter: QZXVAR1QZXms · QZXVAR2QZX'**
  String get inlineTextTemplate_7e941c183788df69;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Update Available'**
  String get inlineTextTemplate_fd67fb8b214d0251;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Update Interrupted'**
  String get inlineTextTemplate_0c16e4802957bf2a;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX left'**
  String get inlineTextTemplate_e100a78e26906915;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Updated: QZXVAR0QZX'**
  String get inlineTextTemplate_e24a324bdb714d54;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Could not remove application: QZXVAR0QZX'**
  String get inlineTextTemplate_a8f0cc53b0dca9ef;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX countries selected (QZXVAR1QZX CIDRs)'**
  String get inlineTextTemplate_2347df78592d100a;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get inlineTextTemplate_73b6e48a1b552d11;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get inlineTextTemplate_c1c1009d3f37ec05;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Emergency Stop error: QZXVAR0QZX'**
  String get inlineTextTemplate_2b5bf24f64089836;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Check Updates'**
  String get inlineTextTemplate_a4738b604a205c2e;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Package installer launched. Tap below if you need to relaunch.'**
  String get inlineTextTemplate_3e695daee969126c;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'New Version Available'**
  String get inlineTextTemplate_005ef7725a64c7ed;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Imported QZXVAR0QZX WireGuard and QZXVAR1QZX OpenVPN profiles securely.'**
  String get inlineTextTemplate_e416fbfd7a91ed9f;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Status: QZXVAR0QZX · Latency: QZXVAR1QZX'**
  String get inlineTextTemplate_892b097363290e03;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Version: QZXVAR0QZX'**
  String get inlineTextTemplate_876c1a21e4aca06e;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get inlineTextTemplate_48845bff334a50a5;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Configure Device: QZXVAR0QZX'**
  String get inlineTextTemplate_a1868bb4d6de7026;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Not supported on QZXVAR0QZX'**
  String get inlineTextTemplate_df0ea8d18fa1b297;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Failed to update autostart: QZXVAR0QZX'**
  String get inlineTextTemplate_d437f3d2dc2207b4;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX Mbps (Ping QZXVAR1QZXms)'**
  String get inlineTextTemplate_8e339613f844cd3f;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Install Now'**
  String get inlineTextTemplate_b0e17c2810653b13;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No imported QZXVAR0QZX profile matches the selected Surfshark locations.'**
  String get inlineTextTemplate_251f8b3bcb3ff541;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX locations'**
  String get inlineTextTemplate_b027e90663d6b737;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZXms'**
  String get inlineTextTemplate_732cc46253cae40a;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX added'**
  String get inlineTextTemplate_169e482cbbd960b7;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Policy: QZXVAR0QZX · Today: QZXVAR1QZX'**
  String get inlineTextTemplate_10d0ba33ae09b3a4;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'↑ QZXVAR0QZX Mbps'**
  String get inlineTextTemplate_1ec56334a0b24b7c;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Disconnect failed: QZXVAR0QZX'**
  String get inlineTextTemplate_e61e185de8f8a9d7;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Failed to update Always-on VPN: QZXVAR0QZX'**
  String get inlineTextTemplate_d6975653ba21c6a2;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Download & Update'**
  String get inlineTextTemplate_c0671aa2f2dd814a;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Advanced System Routing on QZXVAR0QZX'**
  String get inlineTextTemplate_94fa013c0e7b11f3;

  /// Legacy inlineTextTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Update Download Complete'**
  String get inlineTextTemplate_4511036a54304f80;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get inlineAttributeTemplate_73b6e48a1b552d11;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Checking...'**
  String get inlineAttributeTemplate_2e5f79bb94a8c40b;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get inlineAttributeTemplate_c1c1009d3f37ec05;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Check Updates'**
  String get inlineAttributeTemplate_a4738b604a205c2e;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Release Highlights'**
  String get inlineAttributeTemplate_ccccab7c5d91fcc1;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Package installer launched. Tap below if you need to relaunch.'**
  String get inlineAttributeTemplate_3e695daee969126c;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Downloading Update...'**
  String get inlineAttributeTemplate_be6ee118f6ce86a8;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'No log lines matched the filter \"QZXVAR0QZX\" [QZXVAR1QZX].'**
  String get inlineAttributeTemplate_2f1118ed7cdb58dc;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'New Version Available'**
  String get inlineAttributeTemplate_005ef7725a64c7ed;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Update Available'**
  String get inlineAttributeTemplate_fd67fb8b214d0251;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Update Interrupted'**
  String get inlineAttributeTemplate_0c16e4802957bf2a;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'The update will download and install directly inside Harmoney.'**
  String get inlineAttributeTemplate_1d653fc4503ec979;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get inlineAttributeTemplate_48845bff334a50a5;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Download & Update'**
  String get inlineAttributeTemplate_c0671aa2f2dd814a;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'⚠ Notice: QZXVAR0QZX'**
  String get inlineAttributeTemplate_4a4177e796293af3;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Wi-Fi QR URI: QZXVAR0QZX'**
  String get inlineAttributeTemplate_fede49e2e980819c;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Update Download Complete'**
  String get inlineAttributeTemplate_4511036a54304f80;

  /// Legacy inlineAttributeTemplate translation migrated from the inline table.
  ///
  /// In en, this message translates to:
  /// **'Install Now'**
  String get inlineAttributeTemplate_b0e17c2810653b13;

  /// Application UI string migrated from AppStrings.aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About us'**
  String get appString_AboutUs;

  /// Application UI string migrated from AppStrings.aboutDescription.
  ///
  /// In en, this message translates to:
  /// **'Harmoney is built by Harmoney, providing a secure, high-speed, and resilient way to access the open internet.'**
  String get appString_AboutDescription;

  /// Application UI string migrated from AppStrings.connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get appString_Connect;

  /// Application UI string migrated from AppStrings.disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get appString_Disconnect;

  /// Application UI string migrated from AppStrings.connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get appString_Connected;

  /// Application UI string migrated from AppStrings.disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get appString_Disconnected;

  /// Application UI string migrated from AppStrings.locations.
  ///
  /// In en, this message translates to:
  /// **'Locations'**
  String get appString_Locations;

  /// Application UI string migrated from AppStrings.statistics.
  ///
  /// In en, this message translates to:
  /// **'Speed'**
  String get appString_Statistics;

  /// Application UI string migrated from AppStrings.splitTunnel.
  ///
  /// In en, this message translates to:
  /// **'Split Tunnel'**
  String get appString_SplitTunnel;

  /// Application UI string migrated from AppStrings.hotspot.
  ///
  /// In en, this message translates to:
  /// **'Hotspot'**
  String get appString_Hotspot;

  /// Application UI string migrated from AppStrings.protection.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get appString_Protection;

  /// Application UI string migrated from AppStrings.leakProtection.
  ///
  /// In en, this message translates to:
  /// **'Leak protection'**
  String get appString_LeakProtection;

  /// Application UI string migrated from AppStrings.systemSafeguards.
  ///
  /// In en, this message translates to:
  /// **'System safeguards'**
  String get appString_SystemSafeguards;

  /// Application UI string migrated from AppStrings.countryBypass.
  ///
  /// In en, this message translates to:
  /// **'Country bypass'**
  String get appString_CountryBypass;

  /// Application UI string migrated from AppStrings.diagnostics.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get appString_Diagnostics;

  /// Application UI string migrated from AppStrings.settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get appString_Settings;

  /// Application UI string migrated from AppStrings.connection.
  ///
  /// In en, this message translates to:
  /// **'Connection'**
  String get appString_Connection;

  /// Application UI string migrated from AppStrings.autoConnect.
  ///
  /// In en, this message translates to:
  /// **'Auto-connect'**
  String get appString_AutoConnect;

  /// Application UI string migrated from AppStrings.autoConnectSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Connect automatically on supported networks'**
  String get appString_AutoConnectSubtitle;

  /// Application UI string migrated from AppStrings.killSwitch.
  ///
  /// In en, this message translates to:
  /// **'Kill switch'**
  String get appString_KillSwitch;

  /// Application UI string migrated from AppStrings.killSwitchSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Block traffic if the VPN connection drops'**
  String get appString_KillSwitchSubtitle;

  /// Application UI string migrated from AppStrings.protocol.
  ///
  /// In en, this message translates to:
  /// **'Protocol'**
  String get appString_Protocol;

  /// Application UI string migrated from AppStrings.vpnProvider.
  ///
  /// In en, this message translates to:
  /// **'VPN provider'**
  String get appString_VpnProvider;

  /// Application UI string migrated from AppStrings.providerSeparated.
  ///
  /// In en, this message translates to:
  /// **'Provider layer is optimized for speed and isolation'**
  String get appString_ProviderSeparated;

  /// Application UI string migrated from AppStrings.privacy.
  ///
  /// In en, this message translates to:
  /// **'Privacy'**
  String get appString_Privacy;

  /// Application UI string migrated from AppStrings.dnsLeakProtection.
  ///
  /// In en, this message translates to:
  /// **'DNS leak protection'**
  String get appString_DnsLeakProtection;

  /// Application UI string migrated from AppStrings.ipv6LeakProtection.
  ///
  /// In en, this message translates to:
  /// **'IPv6 leak protection'**
  String get appString_Ipv6LeakProtection;

  /// Application UI string migrated from AppStrings.appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appString_Appearance;

  /// Application UI string migrated from AppStrings.system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get appString_System;

  /// Application UI string migrated from AppStrings.light.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get appString_Light;

  /// Application UI string migrated from AppStrings.dark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get appString_Dark;

  /// Application UI string migrated from AppStrings.language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get appString_Language;

  /// Application UI string migrated from AppStrings.loadApps.
  ///
  /// In en, this message translates to:
  /// **'Load apps'**
  String get appString_LoadApps;

  /// Application UI string migrated from AppStrings.searchingApps.
  ///
  /// In en, this message translates to:
  /// **'Search apps...'**
  String get appString_SearchingApps;

  /// Application UI string migrated from AppStrings.bypassIran.
  ///
  /// In en, this message translates to:
  /// **'Bypass Domestic Websites'**
  String get appString_BypassIran;

  /// Application UI string migrated from AppStrings.connectedTo.
  ///
  /// In en, this message translates to:
  /// **'Connected to'**
  String get appString_ConnectedTo;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Split Tunnel & Bypass'**
  String get directFa_26fc31773fa51ad0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Split Tunnel & Bypass'**
  String get directEn_c982c0c4cfe9c935;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Country & App Bypass'**
  String get directFa_1017a10a74fc8b4c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Country & App Bypass'**
  String get directEn_ed95556c5c93ded1;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Security & Kill Switch'**
  String get directFa_39dbd18df3aa1b73;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Security & Kill Switch'**
  String get directEn_0efd36b42d93a9cf;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Hotspot Shield'**
  String get directFa_fceec8184bae394a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Hotspot Shield'**
  String get directEn_affe75e7c781f044;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Traffic Analytics'**
  String get directFa_6a291c533e65eac9;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Traffic Stats'**
  String get directEn_26bce86e894398f0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'VPN Hotspot Sharing (Windows ICS)'**
  String get directFa_149bc72261ed557a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'VPN Hotspot Sharing (Windows ICS)'**
  String get directEn_e9d51941d0c1f37b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Share secure encrypted tunnel with phones & tablets'**
  String get directFa_ffc1a00b2cd1bd6a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Share secure encrypted tunnel with phones & tablets'**
  String get directEn_8693a5d72c6b23fa;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Enable Hotspot Sharing (ICS)'**
  String get directFa_6889a68d04894859;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Enable Hotspot Sharing (ICS)'**
  String get directEn_f24d839a275e6eaa;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Configures Windows ICS for the VPN adapter when Mobile Hotspot is active. The app verifies the ICS binding; client Internet traffic still needs an end-to-end check.'**
  String get directFa_3bcda1eec5106a5d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Configures Windows ICS for the VPN adapter when Mobile Hotspot is active. The app verifies the ICS binding; client Internet traffic still needs an end-to-end check.'**
  String get directEn_9f658c229a11bef6;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Hardware Profile: Dell Latitude 7210 & Intel / Cellular LTE'**
  String get directFa_9bbd9bac026872c1;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Hardware Profile: Dell Latitude 7210 & Intel / Cellular LTE'**
  String get directEn_9e4a7faff61f59aa;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'• Automatic MTU optimization to 1350 preventing packet fragmentation.\n• Intelligent dual-uplink support (Intel Wi-Fi + Cellular LTE).\n• Zero client-side software configuration needed on connected devices.'**
  String get directFa_50c65a3d13ee268a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'• Automatic MTU optimization to 1350 preventing packet fragmentation.\n• Intelligent dual-uplink support (Intel Wi-Fi + Cellular LTE).\n• Zero client-side software configuration needed on connected devices.'**
  String get directEn_0aa0eafed86db230;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Open Mobile Hotspot'**
  String get directFa_62610231d271d134;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Open Mobile Hotspot'**
  String get directEn_0acb9208ef119b21;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Hotspot sharing preference saved.'**
  String get directFa_3a920a034280df3b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Hotspot sharing preference saved.'**
  String get directEn_ad208643ab98407d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Save preference'**
  String get directFa_674da212761c9897;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Save preference'**
  String get directEn_fa174cea0ac4357d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'servers'**
  String get directFa_0b29754285a30eb5;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'servers'**
  String get directEn_8e3dc1afbc3ec556;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Tap to view and select'**
  String get directFa_7b7b1f9f056db6a2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Tap to view and select'**
  String get directEn_2cc9305c93b06b14;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Pinging'**
  String get directFa_3f513f6f165abe3a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Pinging'**
  String get directEn_1575703aa4004510;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Run a manual latency check'**
  String get directFa_bfe619723f7415af;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Run a manual latency check'**
  String get directEn_ee7ff7f0b25192c5;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Ping all'**
  String get directFa_047e26dc40ad2e6c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Ping all'**
  String get directEn_c749d615571ec59b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **' · No response'**
  String get directFa_9eb2b971b235433d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **' · No response'**
  String get directEn_52d81add0d0bba64;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED'**
  String get directFa_490a4c57bf7ab538;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get directEn_22965568d22a14ee;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Not compatible with this device'**
  String get directFa_c5ddc53614e359dd;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Not compatible with this device'**
  String get directEn_5de8c3898d69b278;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Locations & Routes'**
  String get directFa_631b37d4472bc4af;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Locations & Routes'**
  String get directEn_bbf3d191d555c872;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Smart routing and personal subscriptions'**
  String get directFa_19062eabc808d3cb;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Smart routing and personal subscriptions'**
  String get directEn_d0e13ceb47c44a7f;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Lightweight Firefox VPN tunnel'**
  String get directFa_dfb5490308844c12;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Lightweight Firefox VPN tunnel'**
  String get directEn_49a2fc4df1b8bad5;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Select connection service'**
  String get directFa_0aad2895c1e3bafe;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Select connection service'**
  String get directEn_46b5d935b82dd8e0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Firefox VPN protocol'**
  String get directFa_8f4835903634041e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Firefox VPN protocol'**
  String get directEn_034fc31b30e178f0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Fetching & validating feeds…'**
  String get directFa_1a192f60ba3a8289;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Fetching & validating feeds…'**
  String get directEn_13e340711e620242;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Offline; preserved last healthy config'**
  String get directFa_82fc0e4970c24375;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Offline; preserved last healthy config'**
  String get directEn_4b55315990907923;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Harmoney bundled sources'**
  String get directFa_19df9dbf599af948;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Harmoney bundled sources'**
  String get directEn_622490dc634188e3;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get directFa_72eadf7b1642b492;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get directEn_0e91610117029a62;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get directFa_d129f6c328ebc070;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Never'**
  String get directEn_6300ef800bb88429;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get directFa_bd917b26118b13c4;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get directEn_66f53417d3b7797a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Ping all visible'**
  String get directFa_d2a9c0e9a77e362f;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Ping all visible'**
  String get directEn_49ee72faa5b743f7;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Ping All'**
  String get directFa_54a0cc043e8b2469;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Ping All'**
  String get directEn_5e414ee0c5da2dde;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Refresh Catalog'**
  String get directFa_cc03494b29df4f8b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Refresh Catalog'**
  String get directEn_a7a480dfb660e610;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get directFa_15270886eaddc37f;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get directEn_a52ace420f2175d0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get directFa_bbe41ad560aa142b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get directEn_690dbe9dc0993c42;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Smart & Warp'**
  String get directFa_5f2e4ba5353998cd;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Smart & Warp'**
  String get directEn_e96958fdea5d076e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Stealth'**
  String get directFa_52ae64718fc96a07;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Stealth'**
  String get directEn_526a40a447ddd7aa;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get directFa_d49e29aa06fa679a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Favorites'**
  String get directEn_7a1f2a83aca9a081;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Lowest Ping'**
  String get directFa_be1aa9e3bcbefea8;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Lowest Ping'**
  String get directEn_d96e4d444648ad39;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Online Only'**
  String get directFa_b7280ab58d1ef0d3;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Online Only'**
  String get directEn_39abe2a6fc13b2b2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE'**
  String get directEn_630c2f1c0ee1b8d7;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get directFa_c6bdd72afead66be;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'No favorite servers yet'**
  String get directFa_b1fc7e540a30aaf8;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'No favorite servers yet'**
  String get directEn_dc70c82d78d1c0e8;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Star servers to pin them here for fast access'**
  String get directFa_49320fa08539eb81;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Star servers to pin them here for fast access'**
  String get directEn_9571e3d9d6f0c728;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'No recent connection history'**
  String get directFa_42527803296e602f;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'No recent connection history'**
  String get directEn_d09e302f1c0274ba;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Servers you connect to will appear here for 1-tap reconnect'**
  String get directFa_0fc8187b4a7f9368;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Servers you connect to will appear here for 1-tap reconnect'**
  String get directEn_f30337f6760cbc52;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'No servers match your criteria'**
  String get directFa_1fe15ae1e09b6e2c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'No servers match your criteria'**
  String get directEn_5833dd21953633eb;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Clear search term or reset filters'**
  String get directFa_2b63b2b0981c49df;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Clear search term or reset filters'**
  String get directEn_920eea58ed6b97ac;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Show All Servers'**
  String get directFa_3b855c73b085a016;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Show All Servers'**
  String get directEn_6bcc8512de553613;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Country IPv4 ranges bypass the VPN after reconnecting. App bypass uses the Windows physical interface and requires the Harmoney service.'**
  String get directFa_d5b3c30550d09e4c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Country IPv4 ranges bypass the VPN after reconnecting. App bypass uses the Windows physical interface and requires the Harmoney service.'**
  String get directEn_d86322c4ceb937de;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Per-app bypass'**
  String get directFa_df9d57a055ecc92b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Per-app bypass'**
  String get directEn_e7977ed18b1df209;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Selected apps use the physical network directly. Other apps continue using the VPN.'**
  String get directFa_a94787ee2df7791b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Selected apps use the physical network directly. Other apps continue using the VPN.'**
  String get directEn_36230e6a755f25c0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Enable app bypass'**
  String get directFa_6e26cf4eaf584275;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Enable app bypass'**
  String get directEn_0234c7f3ac8b5b71;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Add at least one application to turn this on.'**
  String get directFa_be1c8cef94eaf799;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Add at least one application to turn this on.'**
  String get directEn_81e9f4e64a840785;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Add application (.exe)'**
  String get directFa_1ab679752901fb30;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Add application (.exe)'**
  String get directEn_50829e8639527356;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get directFa_6badcac8c181d253;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get directEn_74a883a037bc227f;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Manage connection, security, and appearance'**
  String get directFa_3b1a615eb46d3552;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Manage connection, security, and appearance'**
  String get directEn_61118b57b609e8fd;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Connection & network'**
  String get directFa_3f50db43516612df;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Connection & network'**
  String get directEn_30df82f8484e7683;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Choose the VPN service for your connection'**
  String get directFa_e107b6a1c6237873;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Choose the VPN service for your connection'**
  String get directEn_910a1f4713f13d8e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'VPN protocol'**
  String get directFa_58315650533b0b3b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'VPN protocol'**
  String get directEn_7686b2c38e140183;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Available options for this service'**
  String get directFa_2a5bdeae1adad66c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Available options for this service'**
  String get directEn_cedbc131160b33f1;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get directFa_16aebe854ffb5f38;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Privacy & security'**
  String get directEn_f38d325999eb36a6;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Network protections configured for this device'**
  String get directFa_a89854802b5f20cf;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Network protections configured for this device'**
  String get directEn_be15fa8563e40cba;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Routes DNS requests through the VPN tunnel'**
  String get directFa_1409b5d4b2651bab;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Routes DNS requests through the VPN tunnel'**
  String get directEn_b613c94bf91b3fc9;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Prevents unrouted IPv6 traffic from bypassing the tunnel'**
  String get directFa_8195f49a5b2e17b2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Prevents unrouted IPv6 traffic from bypassing the tunnel'**
  String get directEn_1cdef3c7ac0432a7;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Restore network'**
  String get directFa_0e983de7a97d3ebc;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Restore network'**
  String get directEn_8bd8660e60b766d4;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Restore routes and traffic rules if the network is stuck'**
  String get directFa_be441169827bd41f;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Restore routes and traffic rules if the network is stuck'**
  String get directEn_0af7a160977315f6;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get directFa_7598b46f5cf1fc09;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get directEn_a76e13b9839270eb;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Automation & profiles'**
  String get directFa_ba59a5c62a44328b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Automation & profiles'**
  String get directEn_e59064ae08e6a067;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Startup behavior and imported VPN configurations'**
  String get directFa_48fd53e2af663b4a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Startup behavior and imported VPN configurations'**
  String get directEn_97bcdad71573d6c3;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Launch at system startup'**
  String get directFa_69a843018034c170;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Launch at system startup'**
  String get directEn_3f1c0972eed8648e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Start Harmoney when you sign in'**
  String get directFa_47133f15d25244d1;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Start Harmoney when you sign in'**
  String get directEn_0d5ac9a1f2d12cde;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Always-on VPN'**
  String get directFa_daf6a3deef1f3b02;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Always-on VPN'**
  String get directEn_58b2c361864f4c09;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Reconnect through the system watchdog'**
  String get directFa_70bbad1ef3799c29;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Reconnect through the system watchdog'**
  String get directEn_22e25c3212f145b0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Opens Android VPN settings to configure Always-on'**
  String get directFa_9229a87b05a54019;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Opens Android VPN settings to configure Always-on'**
  String get directEn_bce686c9ff4b4f85;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get directFa_ad7388a14026319e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get directEn_3907fa7f80722a6f;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Choose the app theme and language'**
  String get directFa_486db8686a654fbe;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Choose the app theme and language'**
  String get directEn_cb0d1cffba7882cc;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get directFa_90ec529f45409145;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get directEn_efb52e7172b77731;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get directFa_bcbedc248a089ce8;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'App language'**
  String get directEn_b8352b44a588721c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get directFa_88acd614f1d3e7b2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get directEn_268f14bbfe119c1e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Connection events, network errors, and technical logs'**
  String get directFa_9891a6dacb577296;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Connection events, network errors, and technical logs'**
  String get directEn_2cd958314044a442;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Technical logs'**
  String get directFa_3c77e77837fbd3a5;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Technical logs'**
  String get directEn_1c3d7cf2bec01443;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'View and filter application logs'**
  String get directFa_fb0c92377fa9ebf2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'View and filter application logs'**
  String get directEn_1a06ce3cb511774e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get directFa_d2c8a80d171eaac0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get directEn_ed077f3d8125d60d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Anti-Censorship Core'**
  String get directFa_84bf1721cbaf0414;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Anti-Censorship Core'**
  String get directEn_4f5845ea70794fc8;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'CONNECTED'**
  String get directEn_1f914c4386c0676e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'DISCONNECTED'**
  String get directFa_9dbd12e5e9f378e2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'DISCONNECTED'**
  String get directEn_5541de9515522b98;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Routes from Xray, WARP and MASQUE configurations. Connection is shown after traffic verification.'**
  String get directFa_5391ea668eee238e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Routes from Xray, WARP and MASQUE configurations. Connection is shown after traffic verification.'**
  String get directEn_92723a5ff9689c3d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Manage Firefox VPN Account'**
  String get directFa_feb86040674f19da;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Manage Firefox VPN Account'**
  String get directEn_316f766fb0bc3a72;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Remaining traffic:'**
  String get directFa_da40aa3623e41c95;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Remaining traffic:'**
  String get directEn_4968fc7fef5ea571;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Refresh status & quota'**
  String get directFa_da8c51e206680bba;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Refresh status & quota'**
  String get directEn_7af2f7454f3b55aa;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Query latest session and traffic quota'**
  String get directFa_f5afe95a8fd7ddc6;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Query latest session and traffic quota'**
  String get directEn_8035283793ddc0b5;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Re-login to account'**
  String get directFa_42337406cedc1429;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Re-login to account'**
  String get directEn_a836bff92bbc5af0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Renew session tokens or switch account'**
  String get directFa_e61fefa6ad7996d4;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Renew session tokens or switch account'**
  String get directEn_a899ea0cfb536e60;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get directFa_bf5696ba3389269b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get directEn_d0527e4b3d658351;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Clear stored credentials from this device'**
  String get directFa_ad503541892485c7;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Clear stored credentials from this device'**
  String get directEn_c4b662bd95db40f1;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Firefox VPN Account'**
  String get directFa_3ed02792f04eb5b4;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Firefox VPN Account'**
  String get directEn_229b05d20a6d2706;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get directFa_25384e5227763ffa;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Checking…'**
  String get directEn_ec963ffc911b8401;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get directFa_f14154be5d9988d7;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Session Expired'**
  String get directEn_7ae00a283ea9b728;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Logged In'**
  String get directFa_45aa400fa5168a7b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Logged In'**
  String get directEn_9b13e877e4aa90a7;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get directFa_55217fc0011924d2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Login Required'**
  String get directEn_88712c434b491bce;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Checking account…'**
  String get directFa_44fb79ae8debab9c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Checking account…'**
  String get directEn_d18f4156fea49644;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Security session expired; please sign in again to use servers.'**
  String get directFa_1e5f5243758c6f38;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Security session expired; please sign in again to use servers.'**
  String get directEn_fa488105cb65db88;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Sign in to activate Firefox tunnel and view data quota.'**
  String get directFa_0b8e3e351c70fd58;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Sign in to activate Firefox tunnel and view data quota.'**
  String get directEn_f493cd9c7ae396ec;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Establishing secure tunnel…'**
  String get directFa_65f6ae6ff5ae8280;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Establishing secure tunnel…'**
  String get directEn_24b8d9733417f7f2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'VPN tunnel inactive · Ready to connect'**
  String get directFa_2825bd47934b892f;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'VPN tunnel inactive · Ready to connect'**
  String get directEn_ee73ed2931582286;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Traffic Quota'**
  String get directFa_a032c52ee18734be;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Traffic Quota'**
  String get directEn_afdd44031ab46f34;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Monthly Allowance'**
  String get directFa_61a760cc9666bc9b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Monthly Allowance'**
  String get directEn_659e50811965fe84;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Quota information unavailable'**
  String get directFa_b160cc84c236bc55;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Quota information unavailable'**
  String get directEn_893e490d64407b8e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Unlimited quota'**
  String get directFa_06922cd515293cd4;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Unlimited quota'**
  String get directEn_23d5d93cf5f11e17;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'GiB'**
  String get directFa_80a85438cf023e19;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'GiB'**
  String get directEn_66a1561b84b46372;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **' of '**
  String get directFa_a624a1e41ffdc6d6;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **' of '**
  String get directEn_a4282e4b2298b90b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get directFa_4b329f46e3e4aa50;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'remaining'**
  String get directEn_43e3ece73ff8f4eb;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get directFa_6d2ae6f38c3f09cd;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Log in to account'**
  String get directEn_c90fdfab474bdd3e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Re-login'**
  String get directFa_9b009e657294963a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Re-login'**
  String get directEn_fbfd8ce759281a7c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Manage Account'**
  String get directFa_47018eca7a6a198e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Manage Account'**
  String get directEn_203229774cceb5f3;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get directFa_39db927c23ae2f24;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get directFa_447aac2e6e36c632;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Refresh Status'**
  String get directEn_72fe71cb37d209d2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get directEn_bcc0bcc9140b0c97;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get directFa_8ac2798171b7f59a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Check status'**
  String get directEn_69cd3590300a68c6;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get directFa_fe9c7660a2b6752a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get directEn_d461a493a3753877;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Automatic provider-managed routing'**
  String get directFa_65feb3156825dbc3;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Automatic provider-managed routing'**
  String get directEn_3e5404c2c8a5d4f7;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Monthly Data Quota'**
  String get directFa_0728ba5430a590a1;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Monthly Data Quota'**
  String get directEn_f6be68de3c8d5e7d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'You will receive visual alerts when reaching this limit.'**
  String get directFa_b496c7ee3eea90bc;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'You will receive visual alerts when reaching this limit.'**
  String get directEn_243a20f9ba6c2892;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Unlimited (Off)'**
  String get directFa_3aa40b685220c3cb;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Unlimited (Off)'**
  String get directEn_4bd0e4ba0e817d11;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get directFa_fa7af603d430b209;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get directEn_19766ed6ccb2f4a3;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Save Quota'**
  String get directFa_609b20177a3148b2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Save Quota'**
  String get directEn_8e1b786c7913210c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Traffic Analytics'**
  String get directEn_4bfa799fae21b467;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Live bandwidth, data accounting & quota'**
  String get directFa_b8b979fad05a28d9;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Live bandwidth, data accounting & quota'**
  String get directEn_2eb0c5a3ce65868c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Live Active'**
  String get directFa_e6522eb9b3c2254c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Live Active'**
  String get directEn_a0b16ccf9021fc82;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Waiting for VPN'**
  String get directFa_08914752d2e02ff9;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Waiting for VPN'**
  String get directEn_2693034906c0e6f9;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Live Real-Time Speed'**
  String get directFa_38a3d2526a8bcc84;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Live Real-Time Speed'**
  String get directEn_c6c2daab1f7d2fe5;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get directFa_9bf13dfa15fb680e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'DL'**
  String get directEn_2eb993f9bc93c5ff;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get directFa_2ce1cec62671ae15;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'UL'**
  String get directEn_6138f40c9673bed1;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Monthly Data Quota'**
  String get directFa_cc361d9901ffdf37;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Set Quota'**
  String get directFa_b0de3b412705cb35;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Set Quota'**
  String get directEn_a429cd15905e58a5;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'used'**
  String get directFa_c25fdb7da6c13c3a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'used'**
  String get directEn_f839161355091fcd;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'No Limit Set'**
  String get directFa_c17283824713e914;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'No Limit Set'**
  String get directEn_2de8796023cbb4c7;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get directFa_61b4fadd6541d1c0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get directEn_2b065c7c9ce466e5;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Peak Speed'**
  String get directFa_fc454815fc7e587d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Peak Speed'**
  String get directEn_ccbb73524b4bd4ee;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Highest recorded'**
  String get directFa_d39fe430fa149d24;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Highest recorded'**
  String get directEn_0debfca2599549f2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get directFa_ad9ba5d4f5d3620f;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get directEn_64367736022306e3;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Total'**
  String get directFa_d7efa0cd9804f3a3;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Lifetime Total'**
  String get directEn_722808dd53ec1823;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'All-time volume'**
  String get directFa_ee086cbab6feeb75;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'All-time volume'**
  String get directEn_20e93f7caa1a7a5c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Session Duration'**
  String get directFa_c709d51a733c7d0b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Session Duration'**
  String get directEn_ad4b77a68783ec24;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Session Download:'**
  String get directFa_3ed03a3af2ebf355;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Session Download:'**
  String get directEn_90f46423c0074765;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Session Upload:'**
  String get directFa_bca2becadd374c69;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Session Upload:'**
  String get directEn_4d9bfca28655ee45;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Last Speed Benchmark:'**
  String get directFa_048be696dea10d04;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Last Speed Benchmark:'**
  String get directEn_2faba03e2b8726a9;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get directFa_f07a81a062535ff7;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get directEn_b764cdc0eab71374;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Automatic route'**
  String get directFa_b8d890311eb66f8b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Automatic route'**
  String get directEn_58f885c3d5750c90;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Verified Secure Tunnel'**
  String get directFa_627f8d2a81499747;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Verified Secure Tunnel'**
  String get directEn_435483eb4a848f87;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Exit IP'**
  String get directFa_d115b5686b17f628;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Exit IP'**
  String get directEn_cea9bb520a68321d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get directFa_a3fa2a3ffcb94859;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get directEn_0d21bd52022ca7f7;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Measuring...'**
  String get directFa_b883b4839aacf6e7;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Measuring...'**
  String get directEn_e7c955a5ec17dda2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get directFa_01fff4b387cb6493;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Excellent'**
  String get directEn_0dc8ee555c28ec1b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get directFa_056e4427b316f2c7;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get directEn_c939327ca16dcf97;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get directFa_42a5dadf6e451488;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Fair'**
  String get directEn_f7b19afcde965ea4;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Tap to run full speed test'**
  String get directFa_3865275fd105a5b8;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Tap to run full speed test'**
  String get directEn_b8d5e190fa4127c4;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get directEn_d6eafe8235910042;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Upload'**
  String get directEn_865e89de78d94c74;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Tap to re-test latency'**
  String get directFa_ff9d6eaa4d416020;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Tap to re-test latency'**
  String get directEn_9ef6777f1d140309;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Copy Public IP'**
  String get directFa_6c85ce5d5c3eb500;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Copy Public IP'**
  String get directEn_caf4d6e51756401d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get directFa_a47a3ca2c3fb77ce;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Copied!'**
  String get directEn_ea61bc15688d1e48;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Domestic Bypass'**
  String get directFa_b6cd8e356ae4de3e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Domestic Bypass'**
  String get directEn_1214c275435c3c13;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Direct IR routes'**
  String get directFa_2841f70e40d3118f;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Direct IR routes'**
  String get directEn_179a9a0e2cfce115;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Kill Switch'**
  String get directFa_b4cab70060e554b3;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Kill Switch'**
  String get directEn_006b49290aa86bfe;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get directFa_1633c46938431a54;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get directEn_92340695899bd2d8;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get directFa_4e67bd8e348260b0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get directEn_75081b593d15cf6e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Speed Test'**
  String get directFa_120c9c6bd8826c8b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Speed Test'**
  String get directEn_d23ced7772a783f3;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Measure latency & speed'**
  String get directFa_3e67ba9b0445249e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Measure latency & speed'**
  String get directEn_948111705a82a507;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Connection service'**
  String get directFa_d5c66bbea9d37a9c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Connection service'**
  String get directEn_e1f42d830cee8336;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Connected & Protected'**
  String get directFa_48c1182b09375569;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Connected & Protected'**
  String get directEn_105e6388aad6ff7f;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get directFa_e2c8f657fd596d7d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get directEn_5f04ae9ed6a865bb;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Authenticating & Bypassing...'**
  String get directFa_1a8adc1da26270cc;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Authenticating & Bypassing...'**
  String get directEn_1d18406321d2db26;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get directFa_12df5a9cc276f2c3;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Connection Failed'**
  String get directEn_42aa4e7bc5d2c21a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Disconnecting...'**
  String get directFa_cd85b4ceda3cc131;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Disconnecting...'**
  String get directEn_cb5a85cad9bd34c5;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Ready to Connect'**
  String get directFa_9b54440688493c0e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Ready to Connect'**
  String get directEn_5883e493fc35afe6;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'All your traffic is encrypted and anonymous'**
  String get directFa_f941f415804ba6bc;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'All your traffic is encrypted and anonymous'**
  String get directEn_cd289597cdb36a8e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Finding the fastest censorship-resistant route...'**
  String get directFa_c1c8e35e7a1e6ab5;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Finding the fastest censorship-resistant route...'**
  String get directEn_fc7f3ba24f1e9374;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Tap the button to reconnect'**
  String get directFa_545c3b36cf6a9b19;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Tap the button to reconnect'**
  String get directEn_c00c5efaa984cbb0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Tap the shield button to secure your internet'**
  String get directFa_19b98ac54207bf43;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Tap the shield button to secure your internet'**
  String get directEn_dc50817ae538ef68;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Automatic Firefox VPN server'**
  String get directFa_ea55a64adb57f89d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Automatic Firefox VPN server'**
  String get directEn_a84cdc7941aa150d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Smart Route'**
  String get directFa_3c408aa10a3a59a2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Harmoney Smart Route'**
  String get directEn_17910d2c8cda2576;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'An available server is chosen when you connect'**
  String get directFa_8f195663090dbd82;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'An available server is chosen when you connect'**
  String get directEn_0666050624c4726b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Speed report copied to clipboard!'**
  String get directFa_787659ec3bcfb8a4;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Speed report copied to clipboard!'**
  String get directEn_f5af9ab211b447cd;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Speed Test History'**
  String get directFa_6d3beddaa5bcf6ea;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Speed Test History'**
  String get directEn_c3a6d1c87fa8d4bb;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get directFa_f2730ebc51f8b5f4;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get directEn_83b12c2216efb4fd;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'No speed tests recorded yet.'**
  String get directFa_0a48e042ec0bc4e0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'No speed tests recorded yet.'**
  String get directEn_df578dfdf0dafa9a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Speed & Grade'**
  String get directFa_147f59b73fb11974;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Speed & Grade'**
  String get directEn_f6e4e9eb494ae1e4;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Live Traffic'**
  String get directFa_cad272ec0da708d2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Live Traffic'**
  String get directEn_4e053f26797a1b12;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Diagnostics'**
  String get directFa_1b248f96a0d6123f;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Ping'**
  String get directFa_afc81625f67a81d4;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Ping'**
  String get directEn_6a4c3a4483b04488;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Jitter'**
  String get directFa_3381d5e424186c39;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Jitter'**
  String get directEn_91fbe4c855fbe075;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Smart Service Suitability'**
  String get directFa_b31ec87c31b48943;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Smart Service Suitability'**
  String get directEn_e17b6227325e1a8d;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get directFa_1d79e493a5f0af51;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Gaming'**
  String get directEn_0fadfa22881467dc;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get directFa_e8622ea6a8536d1c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Streaming'**
  String get directEn_a951c5945635e2d3;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'No Buffering'**
  String get directFa_9dbabd2760d00055;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'No Buffering'**
  String get directEn_7c2521637f81edab;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Calls (VoIP)'**
  String get directFa_ecae75dec1191127;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Calls (VoIP)'**
  String get directEn_17ea7be09dfd3486;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Zoom & Telegram'**
  String get directFa_023848907db873a8;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Zoom & Telegram'**
  String get directEn_48eed22fd9e942cd;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Stability Index'**
  String get directFa_d712411ba5c95ecd;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Stability Index'**
  String get directEn_07561925e24ab3c5;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Zero packet loss'**
  String get directFa_ceb05c63bfc2664a;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Zero packet loss'**
  String get directEn_2e7e5a988d7ff138;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Cancel Test'**
  String get directFa_45f41f3ef10068e9;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Cancel Test'**
  String get directEn_ebf5f31bd3fa8cf4;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Start Speed Test'**
  String get directFa_b9460b16f1ed426c;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Start Speed Test'**
  String get directEn_5e0104e1d0dd6cc2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Copy Report'**
  String get directFa_ec2855c996f9cbd2;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Copy Report'**
  String get directEn_54b8e0c0c268c154;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get directFa_e82a1c223cbe97b6;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get directEn_0e76960093379060;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'Feeds updated & verified (QZXVAR0QZX active)'**
  String get directFaTemplate_994633c2bcedc4a9;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'Feeds updated & verified (QZXVAR0QZX active)'**
  String get directEnTemplate_b828e6d7441cc143;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX of QZXVAR1QZX feeds verified'**
  String get directFaTemplate_5239746315c0eb65;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX of QZXVAR1QZX feeds verified'**
  String get directEnTemplate_8f43f1183a17a9ee;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX active feeds ready'**
  String get directFaTemplate_30d97df5d076bd85;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX active feeds ready'**
  String get directEnTemplate_96826d3bc31aa276;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'Last successful update: QZXVAR0QZX'**
  String get directFaTemplate_fee1d797c43cc69d;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'Last successful update: QZXVAR0QZX'**
  String get directEnTemplate_fded5aac30f3cd2a;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZXm ago'**
  String get directFaTemplate_3c0e143206c640a7;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZXm ago'**
  String get directEnTemplate_36d18ca5012e48ca;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZXh ago'**
  String get directFaTemplate_c5e58f11bda2617f;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZXh ago'**
  String get directEnTemplate_24aa4c9a230529bd;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX application(s) selected'**
  String get directFaTemplate_77f98929af010686;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX application(s) selected'**
  String get directEnTemplate_d15393d3ecf8ed01;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX of QZXVAR1QZX GiB'**
  String get directFaTemplate_6cb5f3a91c97ab58;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'QZXVAR0QZX of QZXVAR1QZX GiB'**
  String get directEnTemplate_23034a0887d70ad4;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'Resets: QZXVAR0QZX'**
  String get directFaTemplate_827e6929ed952562;

  /// Dynamic Persian and English UI template migrated to ARB; QZXVAR markers are runtime values.
  ///
  /// In en, this message translates to:
  /// **'Resets: QZXVAR0QZX'**
  String get directEnTemplate_d566a16d104214f0;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'profiles imported'**
  String get directFa_4767f95a766acad9;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'profiles imported'**
  String get directEn_fa3e465bd04c98ce;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Importing?'**
  String get directFa_6a94bd2919a75602;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Importing?'**
  String get directEn_186483a47635ef8b;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Import ZIP'**
  String get directFa_7bd1e551fd0c73d1;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Import ZIP'**
  String get directEn_cb0bf46bf1e385db;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get directFa_2c0b4ee2a03c434e;

  /// Persian and English UI phrase migrated to ARB.
  ///
  /// In en, this message translates to:
  /// **'Manage'**
  String get directEn_5a23444828db654a;

  /// No description provided for @desktopTrayOpenApplication.
  ///
  /// In en, this message translates to:
  /// **'Open Application'**
  String get desktopTrayOpenApplication;

  /// No description provided for @desktopTrayChooseServer.
  ///
  /// In en, this message translates to:
  /// **'Choose server…'**
  String get desktopTrayChooseServer;

  /// No description provided for @desktopTrayPreferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences / Settings'**
  String get desktopTrayPreferences;

  /// No description provided for @desktopTrayStartupOptions.
  ///
  /// In en, this message translates to:
  /// **'Startup Options'**
  String get desktopTrayStartupOptions;

  /// No description provided for @desktopTrayLaunchOnStartup.
  ///
  /// In en, this message translates to:
  /// **'Launch on startup'**
  String get desktopTrayLaunchOnStartup;

  /// No description provided for @desktopTraySoundEffect.
  ///
  /// In en, this message translates to:
  /// **'Sound effect'**
  String get desktopTraySoundEffect;

  /// No description provided for @desktopTrayStartMinimized.
  ///
  /// In en, this message translates to:
  /// **'Start minimized'**
  String get desktopTrayStartMinimized;

  /// No description provided for @desktopTrayForceClose.
  ///
  /// In en, this message translates to:
  /// **'Force close'**
  String get desktopTrayForceClose;

  /// No description provided for @desktopTrayServiceMode.
  ///
  /// In en, this message translates to:
  /// **'Service Mode'**
  String get desktopTrayServiceMode;

  /// No description provided for @desktopTrayProxyService.
  ///
  /// In en, this message translates to:
  /// **'Proxy Service'**
  String get desktopTrayProxyService;

  /// No description provided for @desktopTraySystemProxy.
  ///
  /// In en, this message translates to:
  /// **'System Proxy'**
  String get desktopTraySystemProxy;

  /// No description provided for @desktopTrayVpnModeUnavailable.
  ///
  /// In en, this message translates to:
  /// **'VPN (Unavailable)'**
  String get desktopTrayVpnModeUnavailable;

  /// No description provided for @desktopTrayExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get desktopTrayExit;

  /// No description provided for @desktopTrayReady.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get desktopTrayReady;

  /// No description provided for @desktopTrayDisconnecting.
  ///
  /// In en, this message translates to:
  /// **'Disconnecting…'**
  String get desktopTrayDisconnecting;

  /// No description provided for @desktopTrayCancelConnection.
  ///
  /// In en, this message translates to:
  /// **'Cancel connection'**
  String get desktopTrayCancelConnection;

  /// No description provided for @desktopTrayAutomatic.
  ///
  /// In en, this message translates to:
  /// **'Automatic'**
  String get desktopTrayAutomatic;

  /// No description provided for @desktopTrayError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get desktopTrayError;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['ar', 'de', 'en', 'es', 'fa', 'fr', 'it', 'ru', 'tr', 'zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar': return AppLocalizationsAr();
    case 'de': return AppLocalizationsDe();
    case 'en': return AppLocalizationsEn();
    case 'es': return AppLocalizationsEs();
    case 'fa': return AppLocalizationsFa();
    case 'fr': return AppLocalizationsFr();
    case 'it': return AppLocalizationsIt();
    case 'ru': return AppLocalizationsRu();
    case 'tr': return AppLocalizationsTr();
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
