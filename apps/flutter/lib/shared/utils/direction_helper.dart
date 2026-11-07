import 'package:flutter/material.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

/// Helper for Unicode bidirectional text isolation and LTR technical content.
/// Prevents RTL text inversion and glitches for IP addresses, CIDRs, durations, and rates.
abstract class DirectionHelper {
  /// Left-to-Right Isolate (LRI) char
  static const String lri = '\u2066';

  /// Pop Directional Isolate (PDI) char
  static const String pdi = '\u2069';

  /// Wraps any string in Unicode LTR isolation markers to prevent RTL reordering bugs.
  static String isolateLtr(String text) {
    if (text.isEmpty) return text;
    return '$lri$text$pdi';
  }

  /// Formats duration as mm:ss or hh:mm:ss in clean LTR isolated format.
  static String formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (hours > 0) {
      final h = hours.toString().padLeft(2, '0');
      return isolateLtr('$h:$minutes:$seconds');
    }
    return isolateLtr('$minutes:$seconds');
  }

  /// Formats byte rates like 1.2 MB/s or 450 KB/s in clean LTR.
  static String formatRate(double bytesPerSec) {
    if (bytesPerSec <= 0) return isolateLtr('0 B/s');
    if (bytesPerSec >= 1024 * 1024) {
      final mb = (bytesPerSec / (1024 * 1024)).toStringAsFixed(1);
      return isolateLtr('$mb MB/s');
    }
    if (bytesPerSec >= 1024) {
      final kb = (bytesPerSec / 1024).toStringAsFixed(1);
      return isolateLtr('$kb KB/s');
    }
    return isolateLtr('${bytesPerSec.toInt()} B/s');
  }
}

/// Widget that strictly renders its child in LTR direction.
class LtrText extends StatelessWidget {
  const LtrText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.overflow,
    this.maxLines,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextOverflow? overflow;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LocalizedText(
        text,
        style: style,
        textAlign: textAlign,
        overflow: overflow,
        maxLines: maxLines,
      ),
    );
  }
}
