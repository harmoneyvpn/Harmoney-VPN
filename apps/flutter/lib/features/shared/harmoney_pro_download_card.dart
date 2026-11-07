import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/github_edition.dart';
import 'package:harmoney_vpn_client/app/localized_text.dart';

class HarmoneyProDownloadCard extends StatelessWidget {
  const HarmoneyProDownloadCard({super.key});

  Future<void> _open(BuildContext context) async {
    final url = GithubEdition.harmoneyProDownloadUrl.trim();
    final uri = Uri.tryParse(url);
    if (uri == null || !{'https', 'http'}.contains(uri.scheme)) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          backgroundColor: const Color(0xFF0D2A39),
          title: const LocalizedText(
            'Harmoney Pro',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          content: const LocalizedText(
            'The Harmoney Pro download link is not available yet.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const LocalizedText('Close'),
            ),
          ],
        ),
      );
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: () => _open(context),
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsetsDirectional.fromSTEB(12.w, 9.h, 10.w, 9.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.centerStart,
              end: AlignmentDirectional.centerEnd,
              colors: [
                const Color(0xFF8B5CF6).withValues(alpha: .2),
                const Color(0xFF00D4AA).withValues(alpha: .09),
              ],
            ),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFF8B5CF6).withValues(alpha: .32),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: .2),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(
                  Icons.hub_rounded,
                  color: const Color(0xFFC4A7FF),
                  size: 19.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const LocalizedText(
                      'Harmoney Pro',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    const LocalizedText(
                      'More protocols and connection options',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.white60, fontSize: 10),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 6.w),
              OutlinedButton.icon(
                onPressed: () => _open(context),
                icon: Icon(Icons.download_rounded, size: 14.sp),
                label: const LocalizedText(
                  'Download Harmoney Pro',
                  maxLines: 1,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD9CCFF),
                  side: BorderSide(
                    color: const Color(0xFFB794F6).withValues(alpha: .55),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 7.h),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
