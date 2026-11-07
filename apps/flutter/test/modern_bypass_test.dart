import 'package:flutter_test/flutter_test.dart';
import 'package:harmoney_vpn_client/core/iran_bypass_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Modern Bypass & Hotspot Routing Tests', () {
    test('identifies domestic Iranian domains correctly', () {
      final service = IranBypassService.instance;
      expect(service.isDomesticDomain('varzesh3.ir'), isTrue);
      expect(service.isDomesticDomain('shaparak.ir'), isTrue);
      expect(service.isDomesticDomain('sanjesh.org.ir'), isTrue);
      expect(service.isDomesticDomain('bankmellat.ir'), isTrue);
      expect(service.isDomesticDomain('google.com'), isFalse);
      expect(service.isDomesticDomain('youtube.com'), isFalse);
    });

    test('provides domestic DNS resolvers list', () {
      final dnsServers = IranBypassService.instance.getDomesticDnsServers();
      expect(dnsServers, isNotEmpty);
      expect(dnsServers, contains('10.202.10.202'));
      expect(dnsServers, contains('178.22.122.100'));
    });

    test('generates valid Proxy Auto-Config (PAC) script with domestic routing', () {
      final pac = IranBypassService.instance.generatePacScript(
        proxyHost: '192.168.43.1',
        socksPort: 10808,
        httpPort: 10809,
      );

      expect(pac, contains('FindProxyForURL'));
      expect(pac, contains('*.ir'));
      expect(pac, contains('DIRECT'));
      expect(pac, contains('192.168.43.1:10809'));
      expect(pac, contains('192.168.43.1:10808'));
    });

    test('returns engine domain rules format', () async {
      final rules = await IranBypassService.instance.getDomainRulesForEngine();
      expect(rules, contains('domain:ir'));
      expect(rules, contains('domain:xn--mgba3a4f16a'));
    });
  });
}

