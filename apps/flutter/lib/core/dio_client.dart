import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';

import 'app_talker.dart';
import 'network_speed_test.dart';

class DioClient {
  DioClient._();

  static final DioClient instance = DioClient._();

  late final Dio dio = _createSecureDio();

  static Dio _createSecureDio() {
    final dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 10),
        headers: {
          'User-Agent': 'Harmoney-Client/2.0 (by Harmoney)',
          'Accept': 'application/json, text/plain, */*',
        },
      ),
    );

    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        // Anti-Proxy: Bypass local sniffing/intercepting proxies
        client.findProxy = (uri) => 'DIRECT';
        // Reject unverified/self-signed certs immediately
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) => false;
        return client;
      },
      validateCertificate: (X509Certificate? cert, String host, int port) {
        if (cert == null) return false;
        final issuer = cert.issuer.toLowerCase();
        final subject = cert.subject.toLowerCase();
        const suspiciousCa = [
          'charles',
          'httptoolkit',
          'http toolkit',
          'mitmproxy',
          'portswigger',
          'burp',
          'fiddler',
          'proxyman',
          'whistle',
          'reqable',
        ];
        if (suspiciousCa.any((ca) => issuer.contains(ca) || subject.contains(ca))) {
          return false;
        }
        if (cert.issuer == cert.subject) {
          return false;
        }
        return true;
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          AppTalker.debug('[Dio Request] ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          AppTalker.debug(
            '[Dio Response] ${response.statusCode} from ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (DioException error, handler) {
          AppTalker.warning('[Dio Error] ${error.message} (${error.type})');
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  static const String _cloudflareDoH = 'https://cloudflare-dns.com/dns-query';
  static const String _googleDoH = 'https://dns.google/resolve';

  /// Resolves hostname to an IPv4 address using DNS over HTTPS (DoH)
  Future<String?> resolveDoH(String hostname, {String? provider}) async {
    try {
      final endpoint = provider ?? _cloudflareDoH;
      final response = await dio.get<Map<String, dynamic>>(
        endpoint,
        queryParameters: {'name': hostname, 'type': 'A'},
        options: Options(
          headers: {'Accept': 'application/dns-json'},
          responseType: ResponseType.json,
        ),
      );

      final answers = response.data?['Answer'] as List?;
      if (answers != null && answers.isNotEmpty) {
        for (final answer in answers) {
          if (answer is Map && answer['type'] == 1) {
            // Type 1 is A (IPv4)
            final ip = answer['data']?.toString();
            if (ip != null && ip.isNotEmpty) {
              AppTalker.info('[DoH] Resolved $hostname -> $ip via DoH');
              return ip;
            }
          }
        }
      }
      return null;
    } catch (e) {
      if (provider == null) {
        // Fallback to Google DoH if Cloudflare fails
        try {
          final fallbackResponse = await dio.get<Map<String, dynamic>>(
            _googleDoH,
            queryParameters: {'name': hostname, 'type': 'A'},
            options: Options(
              headers: {'Accept': 'application/dns-json'},
              responseType: ResponseType.json,
            ),
          );
          final answers = fallbackResponse.data?['Answer'] as List?;
          if (answers != null && answers.isNotEmpty) {
            for (final answer in answers) {
              if (answer is Map && answer['type'] == 1) {
                final ip = answer['data']?.toString();
                if (ip != null && ip.isNotEmpty) {
                  AppTalker.info(
                    '[DoH] Resolved $hostname -> $ip via Google DoH fallback',
                  );
                  return ip;
                }
              }
            }
          }
        } catch (_) {}
      }
      AppTalker.warning('[DoH] Resolution failed for $hostname: $e');
      return null;
    }
  }

  /// Fast multipart & chunked speed test with live progress callbacks
  Future<NetworkSpeedResult> runSpeedTest({
    void Function(double downloadProgress, double mbps)? onProgress,
  }) async {
    const downloadUrl =
        'https://speed.cloudflare.com/__down?bytes=5242880'; // 5MB
    const uploadUrl = 'https://speed.cloudflare.com/__up';

    // 1. Latency Probe
    final latencies = <double>[];
    for (int i = 0; i < 3; i++) {
      final watch = Stopwatch()..start();
      try {
        await dio.get(
          'https://speed.cloudflare.com/__down?bytes=1',
          options: Options(responseType: ResponseType.bytes),
        );
        watch.stop();
        latencies.add(watch.elapsedMicroseconds / 1000.0);
      } catch (_) {
        watch.stop();
      }
    }

    final avgLatency = latencies.isNotEmpty
        ? latencies.reduce((a, b) => a + b) / latencies.length
        : 50.0;
    final jitter = latencies.length > 1
        ? (latencies[1] - latencies[0]).abs()
        : 2.0;

    // 2. Download Test with Progress
    int receivedBytes = 0;
    final downloadWatch = Stopwatch()..start();

    try {
      await dio.get(
        downloadUrl,
        options: Options(responseType: ResponseType.stream),
        onReceiveProgress: (received, total) {
          receivedBytes = received;
          final elapsed = downloadWatch.elapsedMicroseconds / 1000000.0;
          if (elapsed > 0) {
            final currentMbps = (received * 8.0) / (elapsed * 1000000.0);
            final progress = total > 0
                ? (received / total).clamp(0.0, 1.0)
                : 0.5;
            onProgress?.call(progress, currentMbps);
          }
        },
      );
    } catch (e) {
      AppTalker.warning('Download test chunk error: $e');
    }
    downloadWatch.stop();

    final downloadElapsed = max(
      0.1,
      downloadWatch.elapsedMicroseconds / 1000000.0,
    );
    final downloadMbps = (receivedBytes * 8.0) / (downloadElapsed * 1000000.0);

    // 3. Upload Test
    const uploadBytes = 512 * 1024; // 512 KB
    final uploadPayload = Uint8List(uploadBytes);
    final uploadWatch = Stopwatch()..start();
    try {
      await dio.post(
        uploadUrl,
        data: Stream.fromIterable([uploadPayload]),
        options: Options(
          headers: {
            'Content-Type': 'application/octet-stream',
            'Content-Length': uploadBytes,
          },
        ),
      );
    } catch (e) {
      AppTalker.warning('Upload test chunk error: $e');
    }
    uploadWatch.stop();

    final uploadElapsed = max(0.1, uploadWatch.elapsedMicroseconds / 1000000.0);
    final uploadMbps = (uploadBytes * 8.0) / (uploadElapsed * 1000000.0);

    return NetworkSpeedResult(
      latencyMs: avgLatency,
      jitterMs: jitter,
      downloadMbps: downloadMbps,
      uploadMbps: uploadMbps,
      transferredBytes: receivedBytes + uploadBytes,
    );
  }
}
