import 'dart:async';

enum VpnNotificationEventType {
  subscriptionUpdated,
  subscriptionExpiry,
  subscriptionQuota,
}

class VpnNotificationEvent {
  const VpnNotificationEvent(this.type, {this.value = 0, this.failed = 0});

  final VpnNotificationEventType type;
  final int value;
  final int failed;
}

class VpnNotificationEvents {
  VpnNotificationEvents._();

  static final _events = StreamController<VpnNotificationEvent>.broadcast();
  static Stream<VpnNotificationEvent> get stream => _events.stream;

  static void publish(VpnNotificationEvent event) => _events.add(event);
}
