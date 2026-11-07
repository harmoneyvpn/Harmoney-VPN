import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../l10n/app_localizations_lookup.dart';

String _arbKey(String prefix, String source) =>
    '$prefix${sha256.convert(utf8.encode(source)).toString().substring(0, 16)}';

String? _translateTemplate(
  AppLocalizations l10n,
  String source,
  Map<String, String> templates,
) {
  for (final entry in templates.entries) {
    final placeholders = RegExp(r'QZXVAR\d+QZX')
        .allMatches(entry.key)
        .map((match) => match.group(0)!)
        .toList(growable: false);
    if (placeholders.isEmpty) continue;

    final translated = appLocalizationsInlineValue(l10n, entry.value);
    if (translated == null) continue;
    final translatedPlaceholders = RegExp(r'QZXVAR\d+QZX')
        .allMatches(translated)
        .map((match) => match.group(0)!)
        .toSet();
    if (!translatedPlaceholders.containsAll(placeholders) ||
        !placeholders.toSet().containsAll(translatedPlaceholders)) {
      continue;
    }

    final parts = entry.key.split(RegExp(r'QZXVAR\d+QZX'));
    final pattern = '^${parts.map(RegExp.escape).join(r'([\s\S]*?)')}\$';
    final match = RegExp(pattern).firstMatch(source);
    if (match == null) continue;

    var result = translated;
    for (var index = 0; index < placeholders.length; index++) {
      result = result.replaceAll(
        placeholders[index],
        match.group(index + 1) ?? '',
      );
    }
    return result;
  }
  return null;
}

String _translateArbText(AppLocalizations l10n, String source) {
  final exact = appLocalizationsInlineValue(
        l10n,
        _arbKey('inlineText_', source),
      ) ??
      appLocalizationsInlineValue(
        l10n,
        _arbKey('inlineAttribute_', source),
      );
  if (exact != null) return exact;

  final direct = appLocalizationsInlineValue(
        l10n,
        _arbKey('directFa_', source),
      ) ??
      appLocalizationsInlineValue(
        l10n,
        _arbKey('directEn_', source),
      );
  if (direct != null) return direct;

  return _translateTemplate(l10n, source, inlineTextTemplateKeys) ??
      _translateTemplate(l10n, source, inlineAttributeTemplateKeys) ??
      _translateTemplate(l10n, source, directFaTemplateKeys) ??
      _translateTemplate(l10n, source, directEnTemplateKeys) ??
      source;
}

String localizedUiText(BuildContext context, String source) {
  final l10n = AppLocalizations.of(context);
  return l10n == null ? source : _translateArbText(l10n, source);
}

/// A [Text] widget that localizes literal UI copy using the active app locale.
class LocalizedText extends StatelessWidget {
  const LocalizedText(
    this.data, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaleFactor,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.semanticsIdentifier,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
  });

  final String data;
  final TextStyle? style;
  final StrutStyle? strutStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final Locale? locale;
  final bool? softWrap;
  final TextOverflow? overflow;
  @Deprecated('Use textScaler instead.')
  final double? textScaleFactor;
  final TextScaler? textScaler;
  final int? maxLines;
  final String? semanticsLabel;
  final String? semanticsIdentifier;
  final TextWidthBasis? textWidthBasis;
  final TextHeightBehavior? textHeightBehavior;
  final Color? selectionColor;

  @override
  Widget build(BuildContext context) {
    return Text(
      localizedUiText(context, data),
      style: style,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaleFactor: textScaleFactor,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      semanticsIdentifier: semanticsIdentifier,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
    );
  }
}
