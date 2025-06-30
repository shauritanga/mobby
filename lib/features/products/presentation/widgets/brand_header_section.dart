import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/brand.dart';

class BrandHeaderSection extends StatelessWidget {
  final Brand brand;
  final VoidCallback? onSearchTap;
  final VoidCallback? onFollowTap;

  const BrandHeaderSection({
    super.key,
    required this.brand,
    this.onSearchTap,
    this.onFollowTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            brand.primaryColor ?? Theme.of(context).primaryColor,
            (brand.primaryColor ?? Theme.of(context).primaryColor).withOpacity(
              0.8,
            ),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern or image
          if (brand.imageUrl != null)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: brand.imageUrl!,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        brand.primaryColor ?? Theme.of(context).primaryColor,
                        (brand.primaryColor ?? Theme.of(context).primaryColor)
                            .withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      brand.primaryColor ?? Theme.of(context).primaryColor,
                      (brand.primaryColor ?? Theme.of(context).primaryColor)
                          .withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

          // Decorative pattern
          Positioned.fill(
            child: CustomPaint(
              painter: BrandPatternPainter(
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // Brand logo
                      Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: brand.logoUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12.r),
                                child: CachedNetworkImage(
                                  imageUrl: brand.logoUrl,
                                  fit: BoxFit.contain,
                                  errorWidget: (context, url, error) => Icon(
                                    Icons.business,
                                    size: 40.sp,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              )
                            : Icon(
                                Icons.business,
                                size: 40.sp,
                                color: Theme.of(context).primaryColor,
                              ),
                      ),

                      SizedBox(width: 16.w),

                      // Brand info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Brand name
                            Text(
                              brand.name,
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 2),
                                    blurRadius: 4,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: 4.h),

                            // Brand description
                            Text(
                              brand.description,
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.white.withOpacity(0.9),
                                fontStyle: FontStyle.italic,
                                shadows: [
                                  Shadow(
                                    offset: const Offset(0, 1),
                                    blurRadius: 2,
                                    color: Colors.black.withOpacity(0.3),
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 8.h),

                            // Brand stats
                            Row(
                              children: [
                                _buildStatChip(
                                  '${brand.productCount} products',
                                  Icons.inventory_2,
                                ),

                                SizedBox(width: 8.w),

                                if (brand.rating != null)
                                  _buildStatChip(
                                    '${brand.rating!.toStringAsFixed(1)} ★',
                                    Icons.star,
                                  ),

                                SizedBox(width: 8.w),

                                _buildStatChip(
                                  brand.countryOfOrigin,
                                  Icons.public,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16.h),

                  // Action buttons
                  Row(
                    children: [
                      // Follow button
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onFollowTap,
                          icon: Icon(Icons.favorite_border, size: 18.sp),
                          label: const Text('Follow'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.2),
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 12.w),

                      // Search button
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onSearchTap,
                          icon: Icon(
                            Icons.search,
                            size: 18.sp,
                            color: Colors.white,
                          ),
                          label: const Text('Search'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.3),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25.r),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(String text, IconData icon) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class BrandPatternPainter extends CustomPainter {
  final Color color;

  BrandPatternPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw brand-themed pattern (hexagons for automotive feel)
    final hexRadius = 30.0;
    final spacing = hexRadius * 1.5;

    for (double x = -hexRadius; x < size.width + hexRadius; x += spacing) {
      for (
        double y = -hexRadius;
        y < size.height + hexRadius;
        y += spacing * 0.866
      ) {
        final offsetX = x + (y / (spacing * 0.866) % 2) * spacing / 2;
        _drawHexagon(canvas, Offset(offsetX, y), hexRadius, paint);
      }
    }
  }

  void _drawHexagon(Canvas canvas, Offset center, double radius, Paint paint) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60) * (3.14159 / 180);
      final x =
          center.dx + radius * 0.5 * (i == 0 ? 1 : 0.5) * (i % 2 == 0 ? 1 : -1);
      final y = center.dy + radius * 0.5 * 0.866 * (i < 3 ? -1 : 1);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class BrandVerificationBadge extends StatelessWidget {
  final Brand brand;

  const BrandVerificationBadge({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    if (brand.isVerified != true) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified, size: 14.sp, color: Colors.white),
          SizedBox(width: 4.w),
          Text(
            'Verified',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class BrandRatingDisplay extends StatelessWidget {
  final Brand brand;

  const BrandRatingDisplay({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    if (brand.rating == null) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.amber.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star, size: 14.sp, color: Colors.amber),
          SizedBox(width: 4.w),
          Text(
            brand.rating!.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.amber[800],
              fontWeight: FontWeight.w600,
            ),
          ),
          if (brand.reviewCount != null) ...[
            SizedBox(width: 4.w),
            Text(
              '(${brand.reviewCount})',
              style: TextStyle(fontSize: 11.sp, color: Colors.amber[700]),
            ),
          ],
        ],
      ),
    );
  }
}

class BrandSocialLinks extends StatelessWidget {
  final Brand brand;
  final ValueChanged<String>? onLinkTap;

  const BrandSocialLinks({super.key, required this.brand, this.onLinkTap});

  @override
  Widget build(BuildContext context) {
    final socialLinks = <String, IconData>{
      if (brand.websiteUrl != null) brand.websiteUrl!: Icons.web,
    };

    if (socialLinks.isEmpty) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: socialLinks.entries.map((entry) {
        return Padding(
          padding: EdgeInsets.only(right: 8.w),
          child: GestureDetector(
            onTap: () => onLinkTap?.call(entry.key),
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Icon(entry.value, size: 16.sp, color: Colors.white),
            ),
          ),
        );
      }).toList(),
    );
  }
}
