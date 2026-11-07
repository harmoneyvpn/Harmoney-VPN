import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../core/connection_exporter.dart';
import '../../../core/firetunnel_vpn_core.dart';
import '../../../core/vpn_core.dart';
import '../../../shared/utils/direction_helper.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

class ExportDialog extends StatefulWidget {
  const ExportDialog({super.key, required this.servers});

  final List<VpnServer> servers;

  static Future<void> show(
    BuildContext context, {
    required List<VpnServer> servers,
  }) {
    return showDialog<void>(
      context: context,
      builder: (_) => ExportDialog(servers: servers),
    );
  }

  @override
  State<ExportDialog> createState() => _ExportDialogState();
}

class _ExportDialogState extends State<ExportDialog> {
  bool _exporting = false;
  String? _exportedPath;
  String? _error;

  String get _defaultDestination {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE'] ??
        Directory.current.path;
    return '$home${Platform.pathSeparator}Desktop${Platform.pathSeparator}Harmoney_Connections';
  }

  Future<void> _startExport() async {
    setState(() {
      _exporting = true;
      _error = null;
      _exportedPath = null;
    });

    try {
      final firefoxServers = await FireTunnelVpnCore().listServers(
        providerId: FireTunnelVpnCore.providerId,
      );
      final path = await ConnectionExporter.exportConnections(
        servers: [...widget.servers, ...firefoxServers],
      );

      if (!mounted) return;
      setState(() {
        _exporting = false;
        _exportedPath = path;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _exporting = false;
        _error = 'خطا در صدور فایل‌ها: $e';
      });
    }
  }

  void _openFolder(String path) {
    try {
      if (Platform.isWindows) {
        Process.start('explorer.exe', [path], runInShell: false);
      } else {
        Process.start('xdg-open', [path], runInShell: false);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141926),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
        side: BorderSide(
          color: const Color(0xFF00E5FF).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 480.w),
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E5FF).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: const Icon(
                      Icons.file_download_outlined,
                      color: Color(0xFF00E5FF),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  LocalizedText(
                    'خروجی‌گرفتن از پروفایل‌های اتصال',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              LocalizedText(
                'Export the selected server list as JSON and TXT files.',
                style: TextStyle(color: Colors.grey[300], fontSize: 12.sp),
              ),
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2433),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    LocalizedText(
                      'محل ذخیره پیش‌فرض:',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 11.sp,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    LtrText(
                      _defaultDestination,
                      style: TextStyle(
                        color: const Color(0xFF00E5FF),
                        fontSize: 11.sp,
                        fontFamily: 'Courier',
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              if (_exportedPath != null) ...[
                SizedBox(height: 10.h),
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.green, width: 0.8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LocalizedText(
                        'فایل‌ها با موفقیت استخراج شدند.',
                        style: TextStyle(
                          color: Colors.greenAccent,
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[800],
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                        ),
                        icon: const Icon(Icons.folder_open, size: 16),
                        label: const LocalizedText('باز کردن پوشه'),
                        onPressed: () => _openFolder(_exportedPath!),
                      ),
                    ],
                  ),
                ),
              ],
              if (_error != null) ...[
                SizedBox(height: 10.h),
                LocalizedText(
                  _error!,
                  style: TextStyle(color: Colors.redAccent, fontSize: 11.sp),
                ),
              ],
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const LocalizedText(
                      'بستن',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E5FF),
                      foregroundColor: Colors.black,
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    onPressed: _exporting ? null : _startExport,
                    child: _exporting
                        ? SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const LocalizedText('شروع استخراج'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
