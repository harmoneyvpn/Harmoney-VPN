import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';

/// Comprehensive Iran bypass service:
/// - Loads country IP CIDRs and GeoSite domain rules
/// - Syncs updated CIDR lists from upstream GitHub/jsdelivr mirrors with safe fallback
/// - Compacts CIDRs for fast routing
/// - Generates Linux ipset / iptables policy routing scripts (0x8888 mark, table 8888)
/// - Generates safe cleanup scripts
class IranBypassService {
  IranBypassService._();
  static final IranBypassService instance = IranBypassService._();

  static const String assetPath = 'assets/rules/iran_cidrs.txt';
  static const Duration refreshInterval = Duration(hours: 24);
  static const Duration retryInterval = Duration(minutes: 30);
  static const String _geoSiteUrl =
      'https://raw.githubusercontent.com/Chocolate4U/Iran-v2ray-rules/release/geosite-lite.dat';
  static const String _geoSiteMirrorUrl =
      'https://cdn.jsdelivr.net/gh/Chocolate4U/Iran-v2ray-rules@release/geosite-lite.dat';
  static const List<List<String>> _remoteListUrlGroups = [
    [
      'https://raw.githubusercontent.com/farshidmousavii/iran-ip-ranges/main/dist/raw/ipv4.txt',
      'https://cdn.jsdelivr.net/gh/farshidmousavii/iran-ip-ranges@main/dist/raw/ipv4.txt',
    ],
    [
      'https://raw.githubusercontent.com/farshidmousavii/iran-ip-ranges/main/dist/raw/ipv6.txt',
      'https://cdn.jsdelivr.net/gh/farshidmousavii/iran-ip-ranges@main/dist/raw/ipv6.txt',
    ],
  ];

  List<String>? _cachedCidrs;
  DateTime? _cacheModifiedAt;
  DateTime? _lastRefreshAttempt;
  DateTime? _domainRoutesLoadedAt;
  List<String>? _cachedDomainRoutes;
  Set<String>? _cachedIranDomains;
  DateTime? _domainRulesLoadedAt;
  DateTime? _lastGeoSiteAttempt;
  String _updateStatus = 'bundled-fallback';

  String get updateStatus => _updateStatus;

  /// Loads the bundled list, refreshes it at most once a day, then adds
  /// current IPv4 destinations for the small curated university domain list.
  Future<List<String>> getIranCidrs() async {
    final base = await _getBaseCidrs();
    final domains = await getDomainBypassRoutes();
    return {...base, ...domains}.toList(growable: false);
  }

  Future<List<String>> _getBaseCidrs() async {
    final now = DateTime.now();
    if (_cachedCidrs == null || _cachedCidrs!.isEmpty) {
      final cache = await _cacheFile();
      if (await cache.exists()) {
        final cached = _parseCidrContent(await cache.readAsString());
        if (cached.length >= 500) {
          _cachedCidrs = cached;
          _cacheModifiedAt = await cache.lastModified();
        }
      }
      _cachedCidrs ??= await _loadBundledCidrs();
    }

    final cache = await _cacheFile();
    final isFresh =
        _cacheModifiedAt != null &&
        now.difference(_cacheModifiedAt!) < refreshInterval;
    final retryDue =
        _lastRefreshAttempt == null ||
        now.difference(_lastRefreshAttempt!) >= retryInterval;
    if (isFresh) _updateStatus = 'cache-current';
    if (!isFresh && retryDue) {
      _lastRefreshAttempt = now;
      final refreshed = await _downloadCidrs();
      if (refreshed != null) {
        _cachedCidrs = refreshed;
        await cache.parent.create(recursive: true);
        await cache.writeAsString(refreshed.join('\n'), flush: true);
        _cacheModifiedAt = await cache.lastModified();
        _updateStatus = 'updated';
      } else {
        _updateStatus = _cacheModifiedAt == null
            ? 'bundled-fallback'
            : 'offline-cache';
      }
    }
    return _cachedCidrs ?? const <String>[];
  }

  Future<List<String>> _loadBundledCidrs() async {
    try {
      return _parseCidrContent(await rootBundle.loadString(assetPath));
    } catch (_) {
      final file = File(assetPath);
      if (await file.exists()) {
        return _parseCidrContent(await file.readAsString());
      }
      return const <String>[];
    }
  }

  Future<List<String>?> _downloadCidrs() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 4);
    try {
      Future<List<String>?> downloadFamily(List<String> urls) async {
        for (final url in urls) {
          try {
            final body = await (() async {
              final request = await client.getUrl(Uri.parse(url));
              final response = await request.close();
              if (response.statusCode != HttpStatus.ok) return null;
              return response.transform(utf8.decoder).join();
            })().timeout(const Duration(seconds: 6));
            if (body == null || body.length > 2 * 1024 * 1024) continue;
            final cidrs = _parseCidrContent(body);
            final minimum = urls.first.endsWith('ipv4.txt') ? 500 : 100;
            if (cidrs.length >= minimum) return cidrs;
          } catch (_) {}
        }
        return null;
      }

      final families = await Future.wait(
        _remoteListUrlGroups.map(downloadFamily),
      );
      if (families.any((family) => family == null)) return null;
      final downloaded = families.expand((family) => family!).toList();
      final unique = downloaded.toSet().toList(growable: false);
      final ipv4Count = unique.where((cidr) => !cidr.contains(':')).length;
      final ipv6Count = unique.where((cidr) => cidr.contains(':')).length;
      if (ipv4Count < 500 ||
          ipv4Count > 10000 ||
          ipv6Count < 100 ||
          ipv6Count > 5000) {
        return null;
      }
      return unique;
    } catch (_) {
      return null;
    } finally {
      client.close(force: true);
    }
  }

  List<String> _parseCidrContent(String content) {
    final result = <String>{};
    for (final line in const LineSplitter().convert(content)) {
      final value = line.split('#').first.trim();
      final parts = value.split('/');
      if (parts.length != 2) continue;
      final address = InternetAddress.tryParse(parts[0].trim());
      final prefix = int.tryParse(parts[1].trim());
      if (address == null || prefix == null) continue;
      final isV4 = address.type == InternetAddressType.IPv4;
      if (isV4 ? (prefix < 8 || prefix > 32) : (prefix < 16 || prefix > 128)) {
        continue;
      }
      if (_isNonPublicAddress(address)) continue;
      result.add('${address.address}/$prefix');
    }
    return result.toList(growable: false);
  }

  bool _isNonPublicAddress(InternetAddress address) {
    final bytes = address.rawAddress;
    if (address.type == InternetAddressType.IPv4) {
      final first = bytes[0];
      final second = bytes[1];
      return first == 0 ||
          first == 10 ||
          first == 127 ||
          first >= 224 ||
          (first == 169 && second == 254) ||
          (first == 172 && second >= 16 && second <= 31) ||
          (first == 192 && second == 168);
    }
    return address.isLoopback ||
        address.isLinkLocal ||
        (bytes[0] & 0xFE) == 0xFC ||
        bytes[0] == 0xFF;
  }

  Future<File> _cacheFile() async {
    final home = Platform.environment['HOME'] ?? '';
    final base = Platform.isWindows
        ? (Platform.environment['LOCALAPPDATA'] ??
              Platform.environment['APPDATA'] ??
              Directory.systemTemp.path)
        : Platform.isLinux
        ? (Platform.environment['XDG_CACHE_HOME'] ??
              (home.isNotEmpty ? '$home/.cache' : Directory.systemTemp.path))
        : Directory.systemTemp.path;
    return File(
      '$base${Platform.pathSeparator}harmoney-vpn${Platform.pathSeparator}rules'
      '${Platform.pathSeparator}iran_cidrs.active.txt',
    );
  }

  /// Resolves curated and key non-.ir domestic domains to static routes.
  /// Results are cached so route setup does not repeat DNS lookups on every reconnect.
  /// Domestic .ir domains are already routed via country CIDRs; only domains that
  /// may point to external Anycast/CDNs are resolved here.
  Future<List<String>> getDomainBypassRoutes() async {
    final now = DateTime.now();
    if (_cachedDomainRoutes != null &&
        _domainRoutesLoadedAt != null &&
        now.difference(_domainRoutesLoadedAt!) < const Duration(hours: 4)) {
      return _cachedDomainRoutes!;
    }

    final routesCache = await _domainRoutesCacheFile();
    if (await routesCache.exists()) {
      final modified = await routesCache.lastModified();
      if (now.difference(modified) < const Duration(hours: 12)) {
        final cached = _parseCidrContent(await routesCache.readAsString());
        if (cached.isNotEmpty) {
          _cachedDomainRoutes = cached;
          _domainRoutesLoadedAt = now;
          return cached;
        }
      }
    }

    final geoSiteDomains = await _loadIranianGeoSiteDomains();
    final bundledDomains = await _loadBundledDomains();
    // Non-.ir domains and university/curated domains may point to external Anycast/IPs
    final criticalDomains = <String>{
      ...bundledDomains,
      ...geoSiteDomains.where((d) => !d.endsWith('.ir')).take(100),
      'digikala.com',
      'aparat.com',
      'filimo.com',
      'telewebion.com',
      'torob.com',
      'divar.ir',
      'snapp.ir',
      'tapsi.ir',
      'cafebazaar.ir',
      'shaparak.ir',
    };

    final routes = <String>{};
    final pending = criticalDomains.toList(growable: false);
    var nextIndex = 0;
    Future<void> worker() async {
      while (true) {
        final index = nextIndex++;
        if (index >= pending.length) return;
        try {
          final addresses = await InternetAddress.lookup(pending[index])
              .timeout(const Duration(milliseconds: 800));
          for (final address in addresses) {
            if (_isNonPublicAddress(address)) continue;
            routes.add(address.type == InternetAddressType.IPv4
                ? '${address.address}/32'
                : '${address.address}/128');
          }
        } catch (_) {}
      }
    }

    await Future.wait(List.generate(16, (_) => worker()));
    _domainRoutesLoadedAt = now;
    _cachedDomainRoutes = routes.toList(growable: false);
    try {
      await _writeDomainRoutesCache(_cachedDomainRoutes!);
    } catch (_) {}
    return _cachedDomainRoutes!;
  }

  /// Returns the complete set of Iranian domains from GeoSite and bundled rules
  /// without forcing blocking DNS resolutions.
  Future<Set<String>> getIranianDomains() async {
    final geoSiteDomains = await _loadIranianGeoSiteDomains();
    final bundledDomains = await _loadBundledDomains();
    return {...geoSiteDomains, ...bundledDomains};
  }

  /// Generates domain matching rules for modern routing engines (Xray, sing-box).
  Future<List<String>> getDomainRulesForEngine() async {
    final domains = await getIranianDomains();
    final rules = <String>['domain:ir', 'domain:xn--mgba3a4f16a'];
    for (final d in domains) {
      if (!d.endsWith('.ir')) {
        rules.add('domain:$d');
      }
    }
    return rules;
  }

  /// High-performance domestic DNS resolvers.
  List<String> getDomesticDnsServers() => const [
        '10.202.10.202',
        '178.22.122.100',
        '10.202.10.10',
        '185.51.200.2',
      ];

  /// Checks whether a hostname belongs to Iranian domestic networks.
  bool isDomesticDomain(String host) {
    final lower = host.trim().toLowerCase();
    if (lower.endsWith('.ir') || lower.endsWith('.xn--mgba3a4f16a')) return true;
    if (_cachedIranDomains != null && _cachedIranDomains!.contains(lower)) {
      return true;
    }
    return false;
  }

  /// Generates a complete, high-speed Proxy Auto-Config (PAC) script for
  /// Hotspot clients (iPhone, iPad, Windows, Android TV, Mac) and local browsers.
  String generatePacScript({
    String proxyHost = '192.168.43.1',
    int socksPort = 10808,
    int httpPort = 10809,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('function FindProxyForURL(url, host) {');
    buffer.writeln('  // Local host and plain hostnames direct');
    buffer.writeln('  if (isPlainHostName(host) || host === "localhost" || host === "127.0.0.1") return "DIRECT";');
    buffer.writeln('  // Private RFC1918 subnets direct');
    buffer.writeln('  if (shExpMatch(host, "10.*") || shExpMatch(host, "192.168.*") || shExpMatch(host, "172.1[6-9].*") || shExpMatch(host, "172.2[0-9].*") || shExpMatch(host, "172.3[0-1].*")) return "DIRECT";');
    buffer.writeln('  // Iranian TLDs direct');
    buffer.writeln('  if (shExpMatch(host, "*.ir") || shExpMatch(host, "*.xn--mgba3a4f16a") || host === "ir") return "DIRECT";');
    buffer.writeln('  // Major domestic services');
    buffer.writeln('  var directDomains = ["digikala.com", "aparat.com", "telewebion.com", "filimo.com", "rubika.ir", "eitaa.com", "bale.ai", "splus.ir", "shaparak.ir", "torob.com", "divar.ir", "snapp.ir", "tapsi.ir"];');
    buffer.writeln('  for (var i = 0; i < directDomains.length; i++) {');
    buffer.writeln('    if (host === directDomains[i] || dnsDomainIs(host, "." + directDomains[i])) return "DIRECT";');
    buffer.writeln('  }');
    buffer.writeln('  // All international traffic routes through encrypted proxy');
    buffer.writeln('  return "PROXY $proxyHost:$httpPort; SOCKS5 $proxyHost:$socksPort; DIRECT";');
    buffer.writeln('}');
    return buffer.toString();
  }

  Future<Set<String>> _loadBundledDomains() async {
    try {
      final content =
          await rootBundle.loadString('assets/rules/iran_domains.txt');
      return content
          .split(RegExp(r'\r?\n'))
          .map((line) => line.trim().toLowerCase())
          .where((line) => line.isNotEmpty && !line.startsWith('#'))
          .toSet();
    } catch (_) {
      return const <String>{};
    }
  }

  Future<Set<String>> _loadIranianGeoSiteDomains() async {
    final now = DateTime.now();
    if (_cachedIranDomains != null &&
        _domainRulesLoadedAt != null &&
        now.difference(_domainRulesLoadedAt!) < refreshInterval) {
      return _cachedIranDomains!;
    }

    final cache = await _geoSiteCacheFile();
    Uint8List? bytes;
    if (await cache.exists()) {
      final stat = await cache.stat();
      if (now.difference(stat.modified) < refreshInterval) {
        bytes = await cache.readAsBytes();
      }
    }
    if (bytes == null) {
      final retryDue =
          _lastGeoSiteAttempt == null ||
          now.difference(_lastGeoSiteAttempt!) >= retryInterval;
      if (retryDue) {
        _lastGeoSiteAttempt = now;
        bytes = await _downloadGeoSite();
      }
      if (bytes != null) {
        await cache.parent.create(recursive: true);
        final temporary = File('${cache.path}.tmp');
        await temporary.writeAsBytes(bytes, flush: true);
        if (await cache.exists()) await cache.delete();
        await temporary.rename(cache.path);
      } else if (await cache.exists()) {
        bytes = await cache.readAsBytes();
      }
    }

    var parsed = <String>{};
    if (bytes != null) {
      try {
        parsed = _parseIranianGeoSite(bytes);
      } catch (_) {}
    }
    if (parsed.isEmpty &&
        (_lastGeoSiteAttempt == null ||
            now.difference(_lastGeoSiteAttempt!) >= retryInterval)) {
      _lastGeoSiteAttempt = now;
      final refreshed = await _downloadGeoSite();
      if (refreshed != null) {
        try {
          parsed = _parseIranianGeoSite(refreshed);
          await cache.parent.create(recursive: true);
          await cache.writeAsBytes(refreshed, flush: true);
        } catch (_) {}
      }
    }
    if (parsed.isNotEmpty) {
      _cachedIranDomains = parsed;
      _domainRulesLoadedAt = now;
    } else {
      _cachedIranDomains ??= const <String>{};
    }
    return _cachedIranDomains!;
  }

  Future<Uint8List?> _downloadGeoSite() async {
    final client = HttpClient()..connectionTimeout = const Duration(seconds: 6);
    try {
      for (final url in [_geoSiteUrl, _geoSiteMirrorUrl]) {
        try {
          final request = await client.getUrl(Uri.parse(url));
          final response = await request.close().timeout(
            const Duration(seconds: 12),
          );
          if (response.statusCode != HttpStatus.ok) continue;
          final bytes = await response
              .fold<List<int>>(<int>[], (out, chunk) {
                out.addAll(chunk);
                if (out.length > 8 * 1024 * 1024) {
                  throw const FormatException('GeoSite rules exceed 8 MiB.');
                }
                return out;
              })
              .timeout(const Duration(seconds: 12));
          final data = Uint8List.fromList(bytes);
          if (_parseIranianGeoSite(data).isNotEmpty) return data;
        } catch (_) {}
      }
      return null;
    } finally {
      client.close(force: true);
    }
  }

  Future<File> _geoSiteCacheFile() async => File(
    '${(await _cacheFile()).parent.path}${Platform.pathSeparator}iran_geosite.dat',
  );

  Future<File> _domainRoutesCacheFile() async => File(
    '${(await _cacheFile()).parent.path}${Platform.pathSeparator}iran_domain_routes.txt',
  );

  Future<void> _writeDomainRoutesCache(List<String> routes) async {
    if (routes.isEmpty) return;
    final file = await _domainRoutesCacheFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(routes.join('\n'), flush: true);
  }

  /// Writes the current GeoIP + GeoSite-resolved routes for desktop helpers.
  Future<File> writeActiveBypassCidrsFile() async {
    final routes = await getIranCidrs();
    final file = await activeBypassCidrsFile();
    await file.parent.create(recursive: true);
    await file.writeAsString(routes.join('\n'), flush: true);
    return file;
  }

  Future<File> activeBypassCidrsFile() async => File(
    '${(await _cacheFile()).parent.path}${Platform.pathSeparator}iran_bypass_routes.txt',
  );

  Set<String> _parseIranianGeoSite(Uint8List bytes) {
    final domains = <String>{};
    var offset = 0;
    while (offset < bytes.length) {
      final tag = _readVarint(bytes, offset);
      offset = tag.next;
      if ((tag.value >> 3) != 1 || (tag.value & 7) != 2) {
        offset = _skipProtoField(bytes, offset, tag.value & 7);
        continue;
      }
      final length = _readVarint(bytes, offset);
      offset = length.next;
      final end = offset + length.value;
      if (end > bytes.length) return <String>{};
      final entry = Uint8List.sublistView(bytes, offset, end);
      final parsed = _parseGeoSiteEntry(entry);
      if (parsed.$1 == 'IR') domains.addAll(parsed.$2);
      offset = end;
    }
    return domains;
  }

  (String, Set<String>) _parseGeoSiteEntry(Uint8List bytes) {
    var offset = 0;
    var code = '';
    final domains = <String>{};
    while (offset < bytes.length) {
      final tag = _readVarint(bytes, offset);
      offset = tag.next;
      final field = tag.value >> 3;
      final wire = tag.value & 7;
      if (field == 1 && wire == 2) {
        final length = _readVarint(bytes, offset);
        offset = length.next;
        final end = offset + length.value;
        if (end > bytes.length) break;
        code = utf8.decode(bytes.sublist(offset, end), allowMalformed: true);
        offset = end;
      } else if (field == 2 && wire == 2) {
        final length = _readVarint(bytes, offset);
        offset = length.next;
        final end = offset + length.value;
        if (end > bytes.length) break;
        final rule = _parseGeoSiteDomain(
          Uint8List.sublistView(bytes, offset, end),
        );
        if (rule != null) domains.add(rule);
        offset = end;
      } else {
        offset = _skipProtoField(bytes, offset, wire);
      }
    }
    return (code, domains);
  }

  String? _parseGeoSiteDomain(Uint8List bytes) {
    var offset = 0;
    var type = -1;
    var value = '';
    while (offset < bytes.length) {
      final tag = _readVarint(bytes, offset);
      offset = tag.next;
      final field = tag.value >> 3;
      final wire = tag.value & 7;
      if (field == 1 && wire == 0) {
        final number = _readVarint(bytes, offset);
        type = number.value;
        offset = number.next;
      } else if (field == 2 && wire == 2) {
        final length = _readVarint(bytes, offset);
        offset = length.next;
        final end = offset + length.value;
        if (end > bytes.length) return null;
        value = utf8.decode(bytes.sublist(offset, end), allowMalformed: true);
        offset = end;
      } else {
        offset = _skipProtoField(bytes, offset, wire);
      }
    }
    final domain = value
        .toLowerCase()
        .trim()
        .replaceFirst(RegExp(r'^\.+'), '')
        .replaceFirst(RegExp(r'\.+$'), '');
    if (type != 2 && type != 3) return null;
    if (!RegExp(r'^[a-z0-9.-]{1,253}$').hasMatch(domain)) return null;
    return domain;
  }

  ({int value, int next}) _readVarint(Uint8List bytes, int offset) {
    var value = 0;
    var shift = 0;
    while (offset < bytes.length && shift < 35) {
      final byte = bytes[offset++];
      value |= (byte & 0x7f) << shift;
      if ((byte & 0x80) == 0) return (value: value, next: offset);
      shift += 7;
    }
    throw const FormatException('Malformed GeoSite protobuf varint.');
  }

  int _skipProtoField(Uint8List bytes, int offset, int wireType) {
    switch (wireType) {
      case 0:
        return _readVarint(bytes, offset).next;
      case 1:
        return offset + 8;
      case 2:
        final length = _readVarint(bytes, offset);
        return length.next + length.value;
      case 5:
        return offset + 4;
      default:
        throw const FormatException('Unsupported GeoSite protobuf field.');
    }
  }

  /// Loads only IPv4 CIDRs with prefix length between 0 and 32.
  Future<List<String>> getIranIpv4Cidrs() async {
    final all = await getIranCidrs();
    return all
        .where((c) {
          if (c.contains(':') || !c.contains('.')) return false;
          final parts = c.split('/');
          if (parts.length != 2) return false;
          final p = int.tryParse(parts[1].trim());
          return p != null && p >= 0 && p <= 32;
        })
        .toList(growable: false);
  }

  /// Loads only IPv6 CIDRs.
  Future<List<String>> getIranIpv6Cidrs() async {
    final all = await getIranCidrs();
    return all.where((c) => c.contains(':')).toList(growable: false);
  }

  /// Generates an ipset restore script content for fast kernel loading.
  Future<String> generateIpsetRestoreContent() async {
    final cidrs = await getIranIpv4Cidrs();
    final buffer = StringBuffer();
    buffer.writeln(
      'create iran_bypass hash:net family inet hashsize 2048 maxelem 65536 -exist',
    );
    for (final cidr in cidrs) {
      buffer.writeln('add iran_bypass $cidr -exist');
    }
    return buffer.toString();
  }

  /// Generates a shell script snippet to apply Linux Iran bypass and hotspot forwarding.
  Future<String> generateLinuxRoutingScript({
    required bool bypassIran,
    required bool hotspotSharing,
    bool bypassViaProfileRoutes = false,
  }) async {
    final buffer = StringBuffer();
    buffer.writeln('#!/bin/sh');
    buffer.writeln('# Harmoney Routing, Iran Bypass & Hotspot Helper for Linux');

    buffer.writeln(r'''
HOTSPOT_DEV=$(ip -4 addr show 2>/dev/null | grep -B2 '10.42.' | head -n1 | awk '{print $2}' | tr -d ':')
if [ -z "$HOTSPOT_DEV" ]; then
  HOTSPOT_DEV=$(nmcli -t -f DEVICE,TYPE,STATE dev 2>/dev/null | grep 'wifi:connected' | awk -F: '{print $1}' | head -n1)
fi
if [ -z "$HOTSPOT_DEV" ]; then
  HOTSPOT_DEV="wlo1"
fi

WAN_DEV=$(ip route show default 2>/dev/null | grep -v 'tun\|vpn' | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | grep -v "^${HOTSPOT_DEV}$" | head -n1)
if [ -z "$WAN_DEV" ]; then
  WAN_DEV=$(ip -4 route show 2>/dev/null | grep -E 'dev (wwp|wwan|cdc|wlo|wlan|wlp|eth|enp|eno|ens|usb)[0-9a-zA-Z]*' | awk '{for(i=1;i<=NF;i++) if($i=="dev") print $(i+1)}' | grep -v "^${HOTSPOT_DEV}$" | head -n1)
fi
if [ -z "$WAN_DEV" ]; then
  WAN_DEV=$(ip -o link show up 2>/dev/null | awk -F': ' '{print $2}' | grep -v 'lo\|tun\|vpn\|docker\|br-\|virbr' | grep -v "^${HOTSPOT_DEV}$" | head -n1)
fi

WAN_GW=$(ip route show default 2>/dev/null | grep -v 'tun\|vpn' | awk '{for(i=1;i<=NF;i++) if($i=="via") print $(i+1)}' | head -n1)
if [ -z "$WAN_GW" ] && [ -n "$WAN_DEV" ]; then
  WAN_GW=$(ip -4 route show dev "$WAN_DEV" 2>/dev/null | grep 'via ' | awk '{print $3}' | head -n1)
fi
WAN_GW6=$(ip -6 route show default 2>/dev/null | grep -v 'tun\|vpn' | awk '{for(i=1;i<=NF;i++) if($i=="via") print $(i+1)}' | head -n1)
if [ -n "$WAN_DEV" ]; then
  WAN_IP=$(ip -4 addr show dev "$WAN_DEV" 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d/ -f1 | head -n1)
fi
''');

    if (bypassIran && !bypassViaProfileRoutes) {
      final ipv4Cidrs = await getIranIpv4Cidrs();
      final ipv6Cidrs = await getIranIpv6Cidrs();
      final domainRoutes = await getDomainBypassRoutes();
      buffer.writeln(
        'echo "Harmoney: Iran bypass list=$_updateStatus routes=${ipv4Cidrs.length + ipv6Cidrs.length} geosite-dns=${domainRoutes.length}"',
      );

      buffer.writeln(r'''
if command -v ipset >/dev/null 2>&1; then
  ipset create iran_bypass hash:net family inet hashsize 2048 maxelem 65536 -exist 2>/dev/null || true
  cat << 'IPSETEOF' | ipset restore -! 2>/dev/null || true
create iran_bypass hash:net family inet hashsize 2048 maxelem 65536 -exist''');
      for (final c in ipv4Cidrs) {
        buffer.writeln('add iran_bypass $c -exist');
      }
      for (final c in domainRoutes.where((route) => !route.contains(':'))) {
        buffer.writeln('add iran_bypass $c -exist');
      }
      buffer.writeln(
        r'''IPSETEOF

  iptables -t mangle -C OUTPUT -m set --match-set iran_bypass dst -j MARK --set-mark 0x8888 2>/dev/null || \
    iptables -t mangle -I OUTPUT 1 -m set --match-set iran_bypass dst -j MARK --set-mark 0x8888
  iptables -t mangle -C PREROUTING -m set --match-set iran_bypass dst -j MARK --set-mark 0x8888 2>/dev/null || \
    iptables -t mangle -I PREROUTING 1 -m set --match-set iran_bypass dst -j MARK --set-mark 0x8888

  if [ -n "$WAN_DEV" ]; then
    ip rule del fwmark 0x8888 table 8888 2>/dev/null || true
    ip rule add fwmark 0x8888 table 8888 priority 100
    if [ -n "$WAN_GW" ]; then
      if [ -n "$WAN_IP" ]; then
        ip route replace default via "$WAN_GW" dev "$WAN_DEV" src "$WAN_IP" table 8888 2>/dev/null || \
          ip route add default via "$WAN_GW" dev "$WAN_DEV" src "$WAN_IP" table 8888
      else
        ip route replace default via "$WAN_GW" dev "$WAN_DEV" table 8888 2>/dev/null || \
          ip route add default via "$WAN_GW" dev "$WAN_DEV" table 8888
      fi
    else
      if [ -n "$WAN_IP" ]; then
        ip route replace default dev "$WAN_DEV" src "$WAN_IP" table 8888 2>/dev/null || \
          ip route add default dev "$WAN_DEV" src "$WAN_IP" table 8888
      else
        ip route replace default dev "$WAN_DEV" table 8888 2>/dev/null || \
          ip route add default dev "$WAN_DEV" table 8888
      fi
    fi
    ip route flush cache

    iptables -t nat -C POSTROUTING -o "$WAN_DEV" -m mark --mark 0x8888 -j MASQUERADE 2>/dev/null || \
      iptables -t nat -I POSTROUTING 1 -o "$WAN_DEV" -m mark --mark 0x8888 -j MASQUERADE
  fi

  if command -v ip6tables >/dev/null 2>&1; then
    cat << 'IPSETEOF6' | ipset restore -! 2>/dev/null || true
create iran_bypass6 hash:net family inet6 hashsize 1024 maxelem 65536 -exist''',
      );
      for (final c in ipv6Cidrs) {
        buffer.writeln('add iran_bypass6 $c -exist');
      }
      for (final c in domainRoutes.where((route) => route.contains(':'))) {
        buffer.writeln('add iran_bypass6 $c -exist');
      }
      buffer.writeln(r'''IPSETEOF6
    ip6tables -t mangle -C OUTPUT -m set --match-set iran_bypass6 dst -j MARK --set-mark 0x8888 2>/dev/null || \
      ip6tables -t mangle -I OUTPUT 1 -m set --match-set iran_bypass6 dst -j MARK --set-mark 0x8888
    ip6tables -t mangle -C PREROUTING -m set --match-set iran_bypass6 dst -j MARK --set-mark 0x8888 2>/dev/null || \
      ip6tables -t mangle -I PREROUTING 1 -m set --match-set iran_bypass6 dst -j MARK --set-mark 0x8888
    if [ -n "$WAN_DEV" ]; then
      ip -6 rule del fwmark 0x8888 table 8888 2>/dev/null || true
      ip -6 rule add fwmark 0x8888 table 8888 priority 100
      if [ -n "$WAN_GW6" ]; then
        ip -6 route replace default via "$WAN_GW6" dev "$WAN_DEV" table 8888 2>/dev/null || ip -6 route add default via "$WAN_GW6" dev "$WAN_DEV" table 8888
      else
        ip -6 route replace default dev "$WAN_DEV" table 8888 2>/dev/null || ip -6 route add default dev "$WAN_DEV" table 8888
      fi
    fi
  fi
fi
''');
    }

    if (hotspotSharing) {
      buffer.writeln(r'''
sysctl -w net.ipv4.ip_forward=1
sysctl -w net.ipv4.conf.all.rp_filter=2
sysctl -w net.ipv4.conf.default.rp_filter=2
if [ -n "$HOTSPOT_DEV" ]; then
  sysctl -w "net.ipv4.conf.$HOTSPOT_DEV.rp_filter=2" 2>/dev/null || true
fi
if [ -n "$WAN_DEV" ]; then
  sysctl -w "net.ipv4.conf.$WAN_DEV.rp_filter=2" 2>/dev/null || true
fi

iptables -t mangle -C FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || \
  iptables -t mangle -I FORWARD 1 -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu

if [ -n "$HOTSPOT_DEV" ]; then
  iptables -t nat -C PREROUTING -i "$HOTSPOT_DEV" -p udp --dport 53 -j DNAT --to-destination 1.1.1.1:53 2>/dev/null || \
    iptables -t nat -I PREROUTING 1 -i "$HOTSPOT_DEV" -p udp --dport 53 -j DNAT --to-destination 1.1.1.1:53
  iptables -t nat -C PREROUTING -i "$HOTSPOT_DEV" -p tcp --dport 53 -j DNAT --to-destination 1.1.1.1:53 2>/dev/null || \
    iptables -t nat -I PREROUTING 1 -i "$HOTSPOT_DEV" -p tcp --dport 53 -j DNAT --to-destination 1.1.1.1:53
fi

iptables -C FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || \
  iptables -I FORWARD 1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -C FORWARD -j ACCEPT 2>/dev/null || \
  iptables -I FORWARD 2 -j ACCEPT

iptables -t nat -C POSTROUTING -o tun+ -j MASQUERADE 2>/dev/null || \
  iptables -t nat -A POSTROUTING -o tun+ -j MASQUERADE
iptables -t nat -C POSTROUTING -o vpn+ -j MASQUERADE 2>/dev/null || \
  iptables -t nat -A POSTROUTING -o vpn+ -j MASQUERADE
''');
    }

    return buffer.toString();
  }

  /// Generates cleanup script for Linux bypass and hotspot sharing.
  static String generateLinuxCleanupScript() {
    return r'''#!/bin/sh
iptables -t mangle -D OUTPUT -m set --match-set iran_bypass dst -j MARK --set-mark 0x8888 2>/dev/null || true
iptables -t mangle -D PREROUTING -m set --match-set iran_bypass dst -j MARK --set-mark 0x8888 2>/dev/null || true
iptables -t mangle -D FORWARD -p tcp --tcp-flags SYN,RST SYN -j TCPMSS --clamp-mss-to-pmtu 2>/dev/null || true

ip6tables -t mangle -D OUTPUT -m set --match-set iran_bypass6 dst -j MARK --set-mark 0x8888 2>/dev/null || true
ip6tables -t mangle -D PREROUTING -m set --match-set iran_bypass6 dst -j MARK --set-mark 0x8888 2>/dev/null || true

ip rule del fwmark 0x8888 table 8888 2>/dev/null || true
ip -6 rule del fwmark 0x8888 table 8888 2>/dev/null || true
ip route flush table 8888 2>/dev/null || true
ip -6 route flush table 8888 2>/dev/null || true
ip route flush cache 2>/dev/null || true

iptables -t nat -D POSTROUTING -o tun+ -j MASQUERADE 2>/dev/null || true
iptables -t nat -D POSTROUTING -o vpn+ -j MASQUERADE 2>/dev/null || true
iptables -t nat -D POSTROUTING -m mark --mark 0x8888 -j MASQUERADE 2>/dev/null || true

HOTSPOT_DEV=$(ip -4 addr show 2>/dev/null | grep -B2 '10.42.' | head -n1 | awk '{print $2}' | tr -d ':')
if [ -n "$HOTSPOT_DEV" ]; then
  iptables -t nat -D PREROUTING -i "$HOTSPOT_DEV" -p udp --dport 53 -j DNAT --to-destination 1.1.1.1:53 2>/dev/null || true
  iptables -t nat -D PREROUTING -i "$HOTSPOT_DEV" -p tcp --dport 53 -j DNAT --to-destination 1.1.1.1:53 2>/dev/null || true
fi

for dev in $(ip -o link show 2>/dev/null | awk -F': ' '{print $2}'); do
  iptables -t nat -D POSTROUTING -o "$dev" -m mark --mark 0x8888 -j MASQUERADE 2>/dev/null || true
done

ipset destroy iran_bypass 2>/dev/null || true
ipset destroy iran_bypass6 2>/dev/null || true
exit 0
''';
  }
}
