import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:harmoney_vpn_client/app/localized_text.dart';

import '../../core/vpn_core.dart';
import '../country_flag.dart';
import '../services/haptic_service.dart';

class RecommendedServersCarousel extends StatefulWidget {
  const RecommendedServersCarousel({
    super.key,
    required this.servers,
    this.selectedServer,
    required this.onSelect,
  });

  final List<VpnServer> servers;
  final VpnServer? selectedServer;
  final ValueChanged<VpnServer> onSelect;

  @override
  State<RecommendedServersCarousel> createState() =>
      _RecommendedServersCarouselState();
}

class _RecommendedServersCarouselState
    extends State<RecommendedServersCarousel> {
  final PageController _pageController = PageController(viewportFraction: 0.88);

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.servers.isEmpty) return const SizedBox.shrink();

    final isFa = Localizations.localeOf(context).languageCode == 'fa';
    // Take top 4 recommended servers
    final featured = widget.servers.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
          child: Row(
            children: [
              const Icon(
                Icons.flash_on_rounded,
                size: 16,
                color: Color(0xFF00D4AA),
              ),
              SizedBox(width: 6.w),
              LocalizedText(
                isFa ? 'مسیرهای برگزیده و پرسرعت' : 'Recommended Fast Routes',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 145.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: featured.length,
            itemBuilder: (context, index) {
              final srv = featured[index];
              final isSelected = widget.selectedServer?.id == srv.id;

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                child: InkWell(
                  onTap: () {
                    HapticService.lightClick();
                    widget.onSelect(srv);
                  },
                  borderRadius: BorderRadius.circular(16.r),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF00D4AA).withValues(alpha: 0.14)
                          : const Color(0xFF161B26).withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00D4AA)
                            : Colors.white.withValues(alpha: 0.1),
                        width: isSelected ? 1.5 : 1.0,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: const Color(0xFF00D4AA)
                                    .withValues(alpha: 0.15),
                                blurRadius: 12,
                                spreadRadius: 1,
                              ),
                            ]
                          : null,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 42.w,
                          height: 42.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFF00D4AA)
                                .withValues(alpha: 0.15),
                            border: Border.all(
                              color: const Color(0xFF00D4AA)
                                  .withValues(alpha: 0.4),
                            ),
                          ),
                          child: CountryFlags.resolve(srv).isNotEmpty
                              ? CountryFlag(
                                  code: CountryFlags.resolve(srv),
                                  size: 42.w,
                                )
                              : Icon(
                                  srv.providerId == 'harmoney'
                                      ? (srv.countryCode == 'CF'
                                            ? Icons.cloud_queue_rounded
                                            : Icons.bolt_rounded)
                                      : Icons.public_rounded,
                                  size: 22.sp,
                                  color: const Color(0xFF00D4AA),
                                ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              LocalizedText(
                                '${srv.country} - ${srv.city}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              LocalizedText(
                                '${srv.countryCode ?? ''} · ${srv.providerId.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.white54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00D4AA)
                                .withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: LocalizedText(
                            isFa ? 'انتخاب' : 'Select',
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF00D4AA),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 10.h),
        Center(
          child: SmoothPageIndicator(
            controller: _pageController,
            count: featured.length,
            effect: const ExpandingDotsEffect(
              dotHeight: 6,
              dotWidth: 6,
              expansionFactor: 3.5,
              activeDotColor: Color(0xFF00D4AA),
              dotColor: Colors.white24,
              spacing: 6,
            ),
          ),
        ),
      ],
    );
  }
}
