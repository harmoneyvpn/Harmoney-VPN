import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

/// Unauthenticated IKE_SA_INIT round trip, not an authenticated tunnel test.
class IkeLatencyProbe {
  static final _group14 = BigInt.parse(
    'FFFFFFFFFFFFFFFFC90FDAA22168C234C4C6628B80DC1CD129024E08'
    '8A67CC74020BBEA63B139B22514A08798E3404DDEF9519B3CD3A431'
    'B302B0A6DF25F14374FE1356D6D51C245E485B576625E7EC6F44C42'
    'E9A637ED6B0BFF5CB6F406B7EDEE386BFB5A899FA5AE9F24117C4B'
    '1FE649286651ECE45B3DC2007CB8A163BF0598DA48361C55D39A6916'
    '3FA8FD24CF5F83655D23DCA3AD961C62F356208552BB9ED529077096'
    '966D670C354E4ABC9804F1746C08CA18217C32905E462E36CE3BE39E'
    '772C180E86039B2783A2EC07A28FB5C55DF06F4C52C9DE2BCBF6955'
    '817183995497CEA956AE515D2261898FA051015728E5A8AACAA68FFF'
    'FFFFFFFFFFFFF',
    radix: 16,
  );

  static Uint8List createPacket() {
    final random = Random.secure();
    List<int> bytes(int count) =>
        List.generate(count, (_) => random.nextInt(256));
    final secret = bytes(32)
        .fold(BigInt.zero, (value, byte) => (value << 8) | BigInt.from(byte));
    var publicKey = BigInt.two.modPow(secret + BigInt.two, _group14);
    final key = Uint8List(256);
    for (var i = key.length - 1; i >= 0; i--) {
      key[i] = (publicKey & BigInt.from(255)).toInt();
      publicKey >>= 8;
    }
    final packet = Uint8List.fromList([
      ...bytes(8), ...List.filled(8, 0),
      33, 0x20, 34, 0x08, 0, 0, 0, 0, 0, 0, 0, 0,
      // SA, proposal, AES-CBC-256, PRF-SHA2-256, SHA1-96, MODP-2048.
      34, 0, 0, 48, 0, 0, 0, 44, 1, 1, 0, 4,
      3, 0, 0, 12, 1, 0, 0, 12, 0x80, 0x0e, 1, 0,
      3, 0, 0, 8, 2, 0, 0, 5,
      3, 0, 0, 8, 3, 0, 0, 2,
      0, 0, 0, 8, 4, 0, 0, 14,
      // Group 14 requires a 256-byte public value; KE length includes header.
      40, 0, 1, 8, 0, 14, 0, 0, ...key,
      0, 0, 0, 36, ...bytes(32),
    ]);
    ByteData.sublistView(packet).setUint32(24, packet.length);
    return packet;
  }

  static bool matchesResponse(List<int> data, List<int> request) {
    if (data.length < 28 ||
        request.length < 28 ||
        data[17] != 0x20 ||
        data[18] != 34 ||
        (data[19] & 0x28) != 0x20) {
      return false;
    }
    for (final i in [...List.generate(8, (i) => i), 20, 21, 22, 23]) {
      if (data[i] != request[i]) return false;
    }
    final length = ByteData.sublistView(Uint8List.fromList(data)).getUint32(24);
    return length == data.length && length > 28;
  }

  static Future<int?> probeAddress(
    InternetAddress address, {
    int port = 500,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    final packet = createPacket();
    final wire = port == 4500 ? <int>[0, 0, 0, 0, ...packet] : packet;
    final started = Stopwatch()..start();
    final result = Completer<int?>();
    StreamSubscription<RawSocketEvent>? subscription;
    Timer? deadline;
    Timer? retry;
    try {
      subscription = socket.listen(
        (event) {
          if (event != RawSocketEvent.read || result.isCompleted) return;
          Datagram? datagram;
          while ((datagram = socket.receive()) != null) {
            final incoming = datagram!;
            if (incoming.address.address != address.address ||
                incoming.port != port) {
              continue;
            }
            var data = incoming.data;
            if (port == 4500) {
              if (data.length < 32 || data.take(4).any((b) => b != 0)) continue;
              data = Uint8List.sublistView(data, 4);
            }
            if (matchesResponse(data, packet)) {
              result.complete(started.elapsedMilliseconds.clamp(1, 60000));
              break;
            }
          }
        },
        onError: (Object error) {
          if (!result.isCompleted) result.completeError(error);
        },
      );
      deadline = Timer(timeout, () {
        if (!result.isCompleted) result.complete(null);
      });
      retry = Timer.periodic(const Duration(milliseconds: 1200), (_) {
        if (!result.isCompleted) socket.send(wire, address, port);
      });
      socket.send(wire, address, port);
      return await result.future;
    } finally {
      deadline?.cancel();
      retry?.cancel();
      await subscription?.cancel();
      socket.close();
    }
  }
}
