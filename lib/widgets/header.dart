import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class GeoraHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool showBackButton;
  final bool showBrandLogo;
  final VoidCallback? onBack;
  final Widget? trailing;

  const GeoraHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.showBackButton = false,
    this.showBrandLogo = false,
    this.onBack,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.maroon,
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(36),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(36),
        ),
        child: Stack(
          children: [
            // Decorative background circles matching design
            Positioned(
              top: -45,
              right: -35,
              child: Container(
                width: 175,
                height: 175,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.15),
                ),
              ),
            ),
            Positioned(
              top: -65,
              left: -55,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.05),
                ),
              ),
            ),

            // Content
            Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: topPadding + 14,
                bottom: 24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (showBackButton) ...[
                    GestureDetector(
                      onTap: onBack ?? () => Navigator.maybePop(context),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: const Icon(
                          Icons.arrow_back,
                          color: AppColors.white,
                          size: 24,
                        ),
                      ),
                    ),
                  ],
                  if (showBrandLogo) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'GEORA',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          'SMART ATTENDANCE',
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: AppColors.cream.withValues(alpha: 0.85),
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 14),
                      ],
                    ),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              title,
                              style: GoogleFonts.poppins(
                                fontSize: 25,
                                fontWeight: FontWeight.w800,
                                color: AppColors.white,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              subtitle,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w400,
                                color: AppColors.cream.withValues(alpha: 0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                      ?trailing,
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
