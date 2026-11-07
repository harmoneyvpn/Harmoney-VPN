import 'dart:io';
import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';
import 'app_update_info.dart';
import 'app_update_service.dart';

enum _UpdateStep { ready, downloading, downloaded, error }

/// Next-Generation Cyber-Glass In-App Update Dialog for Harmoney VPN
class AppUpdateDialog extends StatefulWidget {
  final AppUpdateInfo updateInfo;

  const AppUpdateDialog({super.key, required this.updateInfo});

  static Future<void> show(BuildContext context, AppUpdateInfo info) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) => AppUpdateDialog(updateInfo: info),
    );
  }

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  _UpdateStep _step = _UpdateStep.ready;
  double _progress = 0.0;
  int _receivedBytes = 0;
  int _totalBytes = 0;
  double _speedMBs = 0.0;
  String? _errorMessage;
  File? _downloadedFile;
  CancelToken? _cancelToken;

  @override
  void dispose() {
    _cancelToken?.cancel('Dialog dismissed');
    super.dispose();
  }

  void _startDownload() async {
    setState(() {
      _step = _UpdateStep.downloading;
      _progress = 0.0;
      _errorMessage = null;
    });

    _cancelToken = CancelToken();

    try {
      final file = await AppUpdateService.instance.downloadUpdate(
        widget.updateInfo,
        cancelToken: _cancelToken,
        onProgress: (progress, received, total, speed) {
          if (mounted) {
            setState(() {
              _progress = progress;
              _receivedBytes = received;
              _totalBytes = total;
              _speedMBs = speed;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _downloadedFile = file;
          _step = _UpdateStep.downloaded;
        });
        _triggerInstall();
      }
    } catch (e) {
      if (!mounted) return;
      if (e is DioException && CancelToken.isCancel(e)) return;
      setState(() {
        _step = _UpdateStep.error;
        _errorMessage = e.toString();
      });
    }
  }

  void _triggerInstall() async {
    if (_downloadedFile == null) return;
    try {
      await AppUpdateService.instance.installUpdate(_downloadedFile!);
    } catch (e) {
      if (mounted) {
        setState(() {
          _step = _UpdateStep.error;
          _errorMessage = 'Installation failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final info = widget.updateInfo;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      child: Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Container(
          width: 440.w,
          constraints: BoxConstraints(maxHeight: 620.h),
          decoration: BoxDecoration(
            color: const Color(0xFF092B3B).withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(28.r),
            border: Border.all(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF00E5FF).withValues(alpha: 0.22),
                blurRadius: 36,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.70),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28.r),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildHeader(info),
                Flexible(child: _buildBody(info)),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppUpdateInfo info) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 20.h, 16.w, 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00E5FF), Color(0xFF00F5B8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF00E5FF).withValues(alpha: 0.35),
                  blurRadius: 12,
                ),
              ],
            ),
            child: const Icon(
              Icons.system_update_alt_rounded,
              color: Color(0xFF071E2B),
              size: 24,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LocalizedText(
                  'Harmoney Update Available',
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Text(
                      'v${info.currentVersion}',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 11.sp,
                        color: Colors.white54,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 12.sp,
                        color: const Color(0xFF00E5FF),
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00F5B8).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6.r),
                        border: Border.all(
                          color:
                              const Color(0xFF00F5B8).withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'v${info.latestVersion}',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF00F5B8),
                        ),
                      ),
                    ),
                    if (info.formattedFileSize.isNotEmpty) ...[
                      SizedBox(width: 8.w),
                      Text(
                        '· ${info.formattedFileSize}',
                        style: TextStyle(
                          fontFamily: 'Lato',
                          fontSize: 11.sp,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (_step != _UpdateStep.downloading)
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white60),
              onPressed: () => Navigator.of(context).pop(),
              tooltip: 'Close',
            ),
        ],
      ),
    );
  }

  Widget _buildBody(AppUpdateInfo info) {
    if (_step == _UpdateStep.downloading) {
      return _buildDownloadProgress();
    }
    if (_step == _UpdateStep.downloaded) {
      return _buildDownloadedView();
    }
    if (_step == _UpdateStep.error) {
      return _buildErrorView();
    }

    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.notes_rounded,
                  size: 16.sp, color: const Color(0xFFFFC46B)),
              SizedBox(width: 8.w),
              LocalizedText(
                'Release Highlights',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFFFC46B),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            constraints: BoxConstraints(maxHeight: 220.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.28),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: SingleChildScrollView(
              child: Text(
                info.releaseNotes.isNotEmpty
                    ? info.releaseNotes
                    : 'Performance optimizations, enhanced connection stability, and core security updates.',
                style: TextStyle(
                  fontFamily: 'SF Pro',
                  fontSize: 12.sp,
                  height: 1.5,
                  color: Colors.white.withValues(alpha: 0.85),
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: const Color(0xFF00E5FF).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: Color(0xFF00E5FF),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: LocalizedText(
                    'The update will download and install directly inside Harmoney.',
                    style: TextStyle(
                      fontFamily: 'SF Pro',
                      fontSize: 11.sp,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadProgress() {
    final percent = (_progress * 100).toInt();
    final mbReceived = (_receivedBytes / (1024 * 1024)).toStringAsFixed(1);
    final mbTotal = (_totalBytes / (1024 * 1024)).toStringAsFixed(1);

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              LocalizedText(
                'Downloading Update...',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF00F5B8),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8.h,
              backgroundColor: Colors.white.withValues(alpha: 0.10),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00F5B8),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$mbReceived MB / $mbTotal MB',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 11.sp,
                  color: Colors.white60,
                ),
              ),
              Text(
                '${_speedMBs.toStringAsFixed(1)} MB/s',
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 11.sp,
                  color: const Color(0xFF00E5FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadedView() {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF00F5B8).withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF00F5B8),
              size: 40,
            ),
          ),
          SizedBox(height: 14.h),
          LocalizedText(
            'Update Download Complete',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          LocalizedText(
            'Package installer launched. Tap below if you need to relaunch.',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 12.sp,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFFF5252),
            size: 38,
          ),
          SizedBox(height: 10.h),
          LocalizedText(
            'Update Interrupted',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            _errorMessage ?? 'Unable to complete update package retrieval.',
            style: TextStyle(
              fontFamily: 'SF Pro',
              fontSize: 11.sp,
              color: Colors.white60,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.02),
        border: Border(
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          if (_step == _UpdateStep.ready) ...[
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  foregroundColor: Colors.white60,
                ),
                child: LocalizedText(
                  'Later',
                  style: TextStyle(fontSize: 13.sp),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _startDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F5B8),
                  foregroundColor: const Color(0xFF071E2B),
                  elevation: 6,
                  shadowColor: const Color(0xFF00F5B8).withValues(alpha: 0.45),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.download_rounded, size: 18),
                    SizedBox(width: 6.w),
                    LocalizedText(
                      'Download & Update',
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else if (_step == _UpdateStep.downloading) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  _cancelToken?.cancel('Cancelled by user');
                  setState(() => _step = _UpdateStep.ready);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(
                    color: Colors.white.withValues(alpha: 0.20),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: const LocalizedText('Cancel'),
              ),
            ),
          ] else if (_step == _UpdateStep.downloaded) ...[
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _triggerInstall,
                icon: const Icon(Icons.install_mobile_rounded, size: 18),
                label: const LocalizedText('Install Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00F5B8),
                  foregroundColor: const Color(0xFF071E2B),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
              ),
            ),
          ] else if (_step == _UpdateStep.error) ...[
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const LocalizedText('Dismiss'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _startDownload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00E5FF),
                  foregroundColor: const Color(0xFF071E2B),
                ),
                child: const LocalizedText('Retry'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
