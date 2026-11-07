import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'vpn_core.dart';
import 'vpn_core_providers.dart';
import 'vpn_notification_events.dart';

final vpnNotificationsProvider = Provider<VpnNotifications>((ref) {
  final notifications = VpnNotifications();
  ref.listen(connectionStateProvider, (previous, next) {
    final state = next.asData?.value;
    if (state != null) notifications.update(state);
  });
  final eventSubscription = VpnNotificationEvents.stream.listen(
    notifications.notifyEvent,
  );
  ref.onDispose(eventSubscription.cancel);
  ref.onDispose(notifications.dispose);
  return notifications;
});

/// Android notifications belong to the native foreground VPN services.
/// Desktop/Apple notifications follow real connection state while the app runs.
class VpnNotifications {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void> _queue = Future<void>.value();
  bool _initialized = false;
  bool _disposed = false;
  bool _wasActive = false;
  VpnConnectionStatus? _last;
  Locale _locale = const Locale('fa');

  void setLocale(Locale locale) => _locale = locale;

  void notifyEvent(VpnNotificationEvent event) {
    if (_disposed) return;
    final fa = _locale.languageCode == 'fa';
    final messages = switch (event.type) {
      VpnNotificationEventType.subscriptionUpdated => (
          fa ? 'به‌روزرسانی اشتراک' : 'Subscription update',
          event.failed == 0
              ? (fa ? 'به‌روزرسانی کامل شد.' : 'Update completed.')
              : (fa
                  ? 'به‌روزرسانی کامل شد؛ ${event.failed} مورد ناموفق بود.'
                  : 'Update finished; ${event.failed} item(s) failed.'),
        ),
      VpnNotificationEventType.subscriptionExpiry => (
          fa ? 'نزدیک‌شدن به انقضای اشتراک' : 'Subscription expiring soon',
          fa
              ? '${event.value} روز تا انقضای اشتراک مانده است.'
              : 'Your subscription expires in ${event.value} day(s).',
        ),
      VpnNotificationEventType.subscriptionQuota => (
          fa ? 'سهمیهٔ اشتراک رو به پایان است' : 'Subscription quota is low',
          fa
              ? '${event.value}٪ از حجم اشتراک مصرف شده است.'
              : '${event.value}% of your subscription data has been used.',
        ),
    };
    _queue = _queue.then((_) async {
      if (_disposed) return;
      try {
        await _initializeForEvents();
        await _plugin.show(
          id: 7110 + event.type.index,
          title: messages.$1,
          body: messages.$2,
          notificationDetails: NotificationDetails(
            android: const AndroidNotificationDetails(
              'harmoney_updates',
              'Harmoney updates',
              channelDescription: 'VPN subscription status and quota alerts',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
            ),
            iOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentSound: false,
              presentBadge: false,
            ),
            macOS: const DarwinNotificationDetails(
              presentAlert: true,
              presentSound: false,
              presentBadge: false,
            ),
            linux: const LinuxNotificationDetails(suppressSound: true),
          ),
        );
      } catch (error) {
        debugPrint('[Harmoney event notifications] $error');
      }
    });
  }

  Future<void> _initializeForEvents() async {
    if (_initialized) return;
    await _plugin.initialize(
      settings: InitializationSettings(
        android: const AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: const DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        macOS: const DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
        linux: LinuxInitializationSettings(
          defaultActionName: _locale.languageCode == 'fa'
              ? 'باز کردن Harmoney'
              : 'Open Harmoney',
          defaultIcon: FilePathLinuxIcon(
            '${File(Platform.resolvedExecutable).parent.path}${Platform.pathSeparator}data${Platform.pathSeparator}flutter_assets${Platform.pathSeparator}assets${Platform.pathSeparator}images${Platform.pathSeparator}ic_stat_harmoney_512.png',
          ),
          defaultSuppressSound: true,
        ),
        windows: const WindowsInitializationSettings(
          appName: 'Harmoney',
          appUserModelId: 'Harmoney.Client',
          guid: 'a0d77baf-d756-471e-a07e-8b621abe2376',
        ),
      ),
    );
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }
    _initialized = true;
  }

  void update(VpnConnectionState state) {
    if (Platform.isAndroid || _disposed) return;
    if (state.status == _last) return;
    _last = state.status;
    final messages = switch (state.status) {
      VpnConnectionStatus.connected => const {
          'fa': 'متصل',
          'en': 'Connected',
          'ar': 'متصل',
          'tr': 'Bağlandı',
          'ru': 'Подключено',
          'zh': '已连接',
          'fr': 'Connecté',
          'de': 'Verbunden',
          'es': 'Conectado',
          'it': 'Connesso',
        },
      VpnConnectionStatus.recovering ||
      VpnConnectionStatus.reconnecting =>
        const {
          'fa': 'در حال بازیابی اتصال',
          'en': 'Reconnecting',
          'ar': 'جارٍ إعادة الاتصال',
          'tr': 'Yeniden bağlanıyor',
          'ru': 'Повторное подключение',
          'zh': '正在重新连接',
          'fr': 'Reconnexion en cours',
          'de': 'Verbindung wird wiederhergestellt',
          'es': 'Reconectando',
          'it': 'Riconnessione in corso',
        },
      VpnConnectionStatus.error || VpnConnectionStatus.failed => const {
          'fa': 'اتصال ناموفق',
          'en': 'Connection failed',
          'ar': 'فشل الاتصال',
          'tr': 'Bağlantı başarısız',
          'ru': 'Не удалось подключиться',
          'zh': '连接失败',
          'fr': 'Échec de la connexion',
          'de': 'Verbindung fehlgeschlagen',
          'es': 'Error de conexión',
          'it': 'Connessione non riuscita',
        },
      VpnConnectionStatus.disconnected when _wasActive => const {
          'fa': 'قطع اتصال',
          'en': 'Disconnected',
          'ar': 'تم قطع الاتصال',
          'tr': 'Bağlantı kesildi',
          'ru': 'Отключено',
          'zh': '已断开连接',
          'fr': 'Déconnecté',
          'de': 'Getrennt',
          'es': 'Desconectado',
          'it': 'Disconnesso',
        },
      _ => null,
    };
    if (state.status == VpnConnectionStatus.connected) _wasActive = true;
    if (state.status == VpnConnectionStatus.disconnected) _wasActive = false;
    if (messages == null) return;
    var message = messages[_locale.languageCode] ?? messages['en']!;
    if (state.isConnected) {
      final server = state.server?.city.isNotEmpty == true
          ? state.server!.city
          : state.server?.country ?? state.endpoint ?? 'VPN';
      message = '$message - $server';
    }
    _queue = _queue.then((_) async {
      if (_disposed) return;
      try {
        if (!_initialized) {
          await _plugin.initialize(
              settings: InitializationSettings(
            iOS: const DarwinInitializationSettings(
                requestAlertPermission: false,
                requestBadgePermission: false,
                requestSoundPermission: false),
            macOS: const DarwinInitializationSettings(
                requestAlertPermission: false,
                requestBadgePermission: false,
                requestSoundPermission: false),
            linux: LinuxInitializationSettings(
                defaultActionName: const {
                      'fa': 'باز کردن Harmoney',
                      'ar': 'فتح Harmoney',
                      'tr': 'Harmoney’yi aç',
                      'ru': 'Открыть Harmoney',
                      'zh': '打开 Harmoney',
                      'fr': 'Ouvrir Harmoney',
                      'de': 'Harmoney öffnen',
                      'es': 'Abrir Harmoney',
                      'it': 'Apri Harmoney',
                    }[_locale.languageCode] ??
                    'Open Harmoney',
                defaultIcon: FilePathLinuxIcon(
                    '${File(Platform.resolvedExecutable).parent.path}${Platform.pathSeparator}data${Platform.pathSeparator}flutter_assets${Platform.pathSeparator}assets${Platform.pathSeparator}images${Platform.pathSeparator}ic_stat_harmoney_512.png'),
                defaultSuppressSound: true),
            windows: const WindowsInitializationSettings(
                appName: 'Harmoney',
                appUserModelId: 'Harmoney.Client',
                guid: 'a0d77baf-d756-471e-a07e-8b621abe2376'),
          ));
          await _plugin
              .resolvePlatformSpecificImplementation<
                  IOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: false, sound: false);
          await _plugin
              .resolvePlatformSpecificImplementation<
                  MacOSFlutterLocalNotificationsPlugin>()
              ?.requestPermissions(alert: true, badge: false, sound: false);
          _initialized = true;
        }
        await _plugin.show(
            id: 7102,
            title: 'Harmoney VPN',
            body: message,
            notificationDetails: const NotificationDetails(
              iOS: DarwinNotificationDetails(
                  presentAlert: true, presentSound: false, presentBadge: false),
              macOS: DarwinNotificationDetails(
                  presentAlert: true, presentSound: false, presentBadge: false),
              linux: LinuxNotificationDetails(suppressSound: true),
            ));
      } catch (error) {
        // An unavailable notification server never interrupts the VPN.
        debugPrint('[Harmoney notifications] $error');
      }
    });
  }

  void dispose() {
    _disposed = true;
  }
}
