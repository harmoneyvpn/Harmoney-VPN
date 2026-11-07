import 'dart:convert';
import 'dart:io';

import 'vpn_core.dart';

class ConnectionExporter {
  static Future<String> exportConnections({
    required List<VpnServer> servers,
    String? customPath,
  }) async {
    final home =
        Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        Directory.current.path;
    final desktop = Directory('$home/Desktop');
    final baseDir = await desktop.exists() ? desktop : Directory(home);
    final targetDir = customPath != null && customPath.isNotEmpty
        ? Directory(customPath)
        : Directory('${baseDir.path}/Harmoney_Connections');
    await targetDir.create(recursive: true);

    final entries = servers
        .map(
          (server) => {
            'id': server.id,
            'provider': server.providerId,
            'name': server.city.isNotEmpty ? server.city : server.country,
            'country': server.country,
            'country_code': server.countryCode ?? '',
            'hostname': server.hostname,
            'latency_ms': server.latencyMs,
          },
        )
        .toList();
    await File('${targetDir.path}/servers.json').writeAsString(
      const JsonEncoder.withIndent('  ').convert(entries),
      flush: true,
    );

    final lines = StringBuffer('Harmoney server list (${entries.length})\n');
    for (final server in servers) {
      final name = '${server.country} - ${server.city}'.trim();
      lines.writeln('$name -> ${server.hostname}');
    }
    await File('${targetDir.path}/servers.txt')
        .writeAsString(lines.toString(), flush: true);
    return targetDir.path;
  }
}
