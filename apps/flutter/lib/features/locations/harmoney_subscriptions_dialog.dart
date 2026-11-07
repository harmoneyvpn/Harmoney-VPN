import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:zxing2/qrcode.dart';

import '../../core/harmoney_subscription_service.dart';
import '../../core/platform_capability_matrix.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

class HarmoneySubscriptionsDialog extends StatefulWidget {
  const HarmoneySubscriptionsDialog({
    super.key,
    required this.isPersian,
  });

  final bool isPersian;

  static Future<void> show(
    BuildContext context, {
    required bool isPersian,
  }) =>
      showDialog<void>(
        context: context,
        builder: (_) => HarmoneySubscriptionsDialog(
          isPersian: isPersian,
        ),
      );

  @override
  State<HarmoneySubscriptionsDialog> createState() =>
      _HarmoneySubscriptionsDialogState();
}

class _HarmoneySubscriptionsDialogState
    extends State<HarmoneySubscriptionsDialog> {
  final _urlController = TextEditingController();
  final _nameController = TextEditingController();
  List<HarmoneySubscription> _subscriptions = const [];
  bool _busy = false;
  bool _clipboardDetected = false;
  Timer? _clipboardTimer;
  String? _lastClipboardValue;

  bool get _fa => widget.isPersian;

  @override
  void initState() {
    super.initState();
    _refresh();
    _clipboardTimer = Timer.periodic(
      const Duration(milliseconds: 900),
      (_) => _checkClipboard(),
    );
  }

  @override
  void dispose() {
    _clipboardTimer?.cancel();
    _urlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _checkClipboard() async {
    if (!mounted || _urlController.text.trim().isNotEmpty) return;
    String? value;
    try {
      value = (await Clipboard.getData('text/plain'))?.text?.trim();
    } catch (_) {
      return;
    }
    if (value == null || value == _lastClipboardValue || !_isHttpUrl(value)) {
      return;
    }
    _lastClipboardValue = value;
    if (!mounted || _urlController.text.trim().isNotEmpty) return;
    setState(() {
      _urlController.text = value!;
      _clipboardDetected = true;
    });
  }

  bool _isHttpUrl(String value) {
    final uri = Uri.tryParse(value);
    return uri != null &&
        uri.hasAuthority &&
        {'http', 'https'}.contains(uri.scheme.toLowerCase());
  }

  Future<void> _scanQr() async {
    if (Platform.isWindows || Platform.isLinux) {
      await _readQrImage();
      return;
    }
    if (!(Platform.isAndroid || Platform.isIOS || Platform.isMacOS)) return;
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B2632),
        title: LocalizedText(
          _fa ? 'اسکن QR اشتراک' : 'Scan subscription QR',
          style: const TextStyle(color: Colors.white),
        ),
        content: SizedBox(
          width: 360,
          height: 360,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: MobileScanner(
              onDetect: (capture) {
                if (capture.barcodes.isEmpty) return;
                final raw = capture.barcodes.first.rawValue?.trim();
                if (raw != null && _isHttpUrl(raw)) {
                  Navigator.of(context).pop(raw);
                }
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: LocalizedText(_fa ? 'لغو' : 'Cancel'),
          ),
        ],
      ),
    );
    if (value != null && mounted) {
      setState(() {
        _urlController.text = value;
        _clipboardDetected = false;
      });
    }
  }

  Future<void> _readQrImage() async {
    try {
      final selection = await FilePicker.pickFiles(
        type: FileType.image,
        withData: true,
        allowMultiple: false,
      );
      if (selection == null || selection.files.isEmpty) return;
      final bytes = selection.files.single.bytes;
      if (bytes == null || bytes.isEmpty || bytes.length > 20 * 1024 * 1024) {
        _message('The image is empty or larger than 20 MB.');
        return;
      }
      final image = img.decodeImage(bytes);
      if (image == null) {
        _message('Could not read this image format.');
        return;
      }
      final rgba =
          image.convert(numChannels: 4).getBytes(order: img.ChannelOrder.abgr);
      final source = RGBLuminanceSource(
        image.width,
        image.height,
        rgba.buffer.asInt32List(rgba.offsetInBytes, rgba.length ~/ 4),
      );
      final result = QRCodeReader().decode(
        BinaryBitmap(GlobalHistogramBinarizer(source)),
      );
      final value = result.text.trim();
      if (!_isHttpUrl(value)) {
        _message('This QR code does not contain an HTTP(S) subscription link.');
        return;
      }
      if (mounted) {
        setState(() {
          _urlController.text = value;
          _clipboardDetected = false;
        });
      }
    } catch (_) {
      _message('Could not detect a QR code in that image.');
    }
  }

  Future<void> _load() async {
    final service = HarmoneySubscriptionService.instance;
    final values = await service.list();
    if (mounted) {
      setState(() {
        _subscriptions = values;
      });
    }
  }

  Future<void> _add() async {
    setState(() => _busy = true);
    try {
      await HarmoneySubscriptionService.instance.add(
        url: _urlController.text,
        name: _nameController.text,
      );
      _urlController.clear();
      _nameController.clear();
      _clipboardDetected = false;
      await _load();
      _message(_fa ? 'اشتراک اضافه شد.' : 'Subscription added.');
    } catch (error) {
      _message(error.toString().replaceFirst('FormatException: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refresh() async {
    setState(() => _busy = true);
    try {
      final values = await HarmoneySubscriptionService.instance.refreshAll();
      if (mounted) setState(() => _subscriptions = values);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: LocalizedText(value)));
  }

  @override
  Widget build(BuildContext context) {
    final refreshCapability = PlatformCapabilityMatrix.getCapability(
      PlatformFeatureKey.backgroundSubscriptionRefresh,
    );
    final title = _fa ? 'اشتراک‌های شخصی' : 'Personal subscriptions';
    return AlertDialog(
      backgroundColor: const Color(0xFF0B2632),
      title: LocalizedText(title, style: const TextStyle(color: Colors.white)),
      content: SizedBox(
        width: 520,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              LocalizedText(
                _fa
                    ? 'لینک اشتراک HTTP یا HTTPS را وارد کنید. لینک‌ها به‌صورت امن روی همین دستگاه ذخیره می‌شوند.'
                    : 'Add an HTTP or HTTPS subscription URL. Links are stored securely on this device.',
                style: const TextStyle(color: Colors.white70, height: 1.4),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Colors.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: LocalizedText(
                      refreshCapability.reason,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _urlController,
                onChanged: (_) {
                  if (_clipboardDetected) {
                    setState(() => _clipboardDetected = false);
                  }
                },
                keyboardType: TextInputType.url,
                textDirection: TextDirection.ltr,
                decoration: InputDecoration(
                  labelText: _fa
                      ? localizedUiText(context, 'لینک اشتراک')
                      : localizedUiText(context, 'Subscription URL'),
                  helperText: _clipboardDetected
                      ? (_fa
                          ? localizedUiText(context, 'لینک کپی‌شده پیدا شد.')
                          : localizedUiText(
                              context,
                              'Copied subscription link detected.',
                            ))
                      : null,
                  suffixIcon: IconButton(
                    tooltip: _fa
                        ? localizedUiText(context, 'چسباندن')
                        : localizedUiText(context, 'Paste'),
                    onPressed: () async {
                      final data = await Clipboard.getData('text/plain');
                      if (data?.text != null) _urlController.text = data!.text!;
                    },
                    icon: const Icon(Icons.content_paste_rounded),
                  ),
                ),
              ),
              if (Platform.isAndroid ||
                  Platform.isIOS ||
                  Platform.isMacOS ||
                  Platform.isWindows ||
                  Platform.isLinux)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: OutlinedButton.icon(
                    onPressed: _scanQr,
                    icon: Icon(
                      Platform.isWindows || Platform.isLinux
                          ? Icons.image_search_rounded
                          : Icons.qr_code_scanner_rounded,
                    ),
                    label: LocalizedText(
                      Platform.isWindows || Platform.isLinux
                          ? (_fa ? 'انتخاب تصویر QR' : 'Choose QR image')
                          : (_fa ? 'اسکن QR' : 'Scan QR'),
                    ),
                  ),
                ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: _fa
                      ? localizedUiText(context, 'نام دلخواه (اختیاری)')
                      : localizedUiText(context, 'Name (optional)'),
                ),
              ),
              const SizedBox(height: 10),
              FilledButton.icon(
                onPressed: _busy ? null : _add,
                icon: const Icon(Icons.add_link_rounded),
                label: LocalizedText(
                  _fa ? 'افزودن اشتراک' : 'Add subscription',
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: LocalizedText(
                      _fa ? 'اشتراک‌های ثبت‌شده' : 'Saved subscriptions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: _fa
                        ? localizedUiText(context, 'بروزرسانی همه')
                        : localizedUiText(context, 'Refresh all'),
                    onPressed: _busy ? null : _refresh,
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              if (_subscriptions.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: LocalizedText(
                    _fa
                        ? 'هنوز اشتراکی اضافه نشده.'
                        : 'No subscriptions added yet.',
                    style: const TextStyle(color: Colors.white60),
                  ),
                ),
              for (final subscription in _subscriptions) ...[
                _subscriptionTile(subscription),
              ],
              if (_busy)
                const Padding(
                  padding: EdgeInsets.only(top: 10),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: LocalizedText(_fa ? 'بستن' : 'Close'),
        ),
      ],
    );
  }

  Widget _subscriptionTile(HarmoneySubscription subscription) {
    final host = Uri.tryParse(subscription.url)?.host ?? '';
    final details = subscription.error != null
        ? subscription.error!
        : '${subscription.nodeCount} ${_fa ? 'سرور' : 'servers'}'
            '${subscription.lastUpdated == null ? '' : ' · ${_fa ? 'بروزرسانی شد' : 'updated'} ${MaterialLocalizations.of(context).formatShortDate(subscription.lastUpdated!.toLocal())} ${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(subscription.lastUpdated!.toLocal()))}'}';
    final used =
        (subscription.uploadBytes ?? 0) + (subscription.downloadBytes ?? 0);
    final quota = subscription.totalBytes == null
        ? ''
        : ' · ${_fa ? 'مصرف' : 'used'} ${_formatBytes(used)} / ${_formatBytes(subscription.totalBytes!)}';
    final expiry = subscription.expiresAt == null
        ? ''
        : ' · ${_fa ? 'انقضا' : 'expires'} ${MaterialLocalizations.of(context).formatShortDate(subscription.expiresAt!.toLocal())}';
    final versionWarning = subscription.requiredAppVersion == null
        ? ''
        : ' · ${_fa ? 'حداقل نسخه' : 'min app'} ${subscription.requiredAppVersion}';
    return Column(
      children: [
        ListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          leading: Icon(
            subscription.error == null
                ? Icons.link_rounded
                : Icons.error_outline,
            color: subscription.error == null
                ? const Color(0xFF00D4AA)
                : Colors.orangeAccent,
          ),
          title: LocalizedText(
            subscription.name,
            style: const TextStyle(color: Colors.white),
          ),
          subtitle: LocalizedText(
            '$host · $details$quota$expiry$versionWarning',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: subscription.error == null
                  ? Colors.white60
                  : Colors.orangeAccent,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Switch.adaptive(
                value: subscription.enabled,
                onChanged: _busy
                    ? null
                    : (value) async {
                        await HarmoneySubscriptionService.instance.setEnabled(
                          subscription.id,
                          value,
                        );
                        await _load();
                      },
              ),
              IconButton(
                tooltip: _fa
                    ? localizedUiText(context, 'حذف')
                    : localizedUiText(context, 'Remove'),
                onPressed: _busy
                    ? null
                    : () async {
                        await HarmoneySubscriptionService.instance.remove(
                          subscription.id,
                        );
                        await _load();
                      },
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.white54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    final units = ['KB', 'MB', 'GB', 'TB'];
    var value = bytes / 1024;
    var index = 0;
    while (value >= 1024 && index < units.length - 1) {
      value /= 1024;
      index++;
    }
    return '${value.toStringAsFixed(1)} ${units[index]}';
  }
}
