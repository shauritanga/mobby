import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/category.dart';

class CategoryHeaderSection extends StatelessWidget {
  final Category category;
  final VoidCallback? onSearchTap;

  const CategoryHeaderSection({
    super.key,
    required this.category,
    this.onSearchTap,
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
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Background pattern or image
          if (category.imageUrl != null)
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: category.imageUrl!,
                fit: BoxFit.cover,
                color: Colors.black.withOpacity(0.3),
                colorBlendMode: BlendMode.darken,
                errorWidget: (context, url, error) => Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Theme.of(context).primaryColor,
                        Theme.of(context).primaryColor.withOpacity(0.7),
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
                      Theme.of(context).primaryColor,
                      Theme.of(context).primaryColor.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
            ),

          // Decorative pattern
          Positioned.fill(
            child: CustomPaint(painter: CategoryPatternPainter()),
          ),

          // Content
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      _getCategoryIcon(),
                      size: 32.sp,
                      color: Colors.white,
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Category name
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 28.sp,
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

                  // Category description
                  if (category.description != null)
                    Text(
                      category.description!,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white.withOpacity(0.9),
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

                  // Product count
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Text(
                      '${category.productCount ?? 0} products',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Quick search button
                  GestureDetector(
                    onTap: onSearchTap,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(25.r),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.search, size: 20.sp, color: Colors.white),
                          SizedBox(width: 8.w),
                          Text(
                            'Search in ${category.name}',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon() {
    // Map category names to appropriate icons
    switch (category.name.toLowerCase()) {
      case 'engine parts':
      case 'engine':
        return Icons.settings;
      case 'brake system':
      case 'brakes':
        return Icons.disc_full;
      case 'suspension':
        return Icons.height;
      case 'electrical':
      case 'electronics':
        return Icons.electrical_services;
      case 'body parts':
      case 'body':
        return Icons.directions_car;
      case 'interior':
        return Icons.airline_seat_recline_normal;
      case 'exterior':
        return Icons.car_repair;
      case 'tires':
      case 'wheels':
        return Icons.tire_repair;
      case 'fluids':
      case 'oils':
        return Icons.opacity;
      case 'tools':
        return Icons.build;
      case 'accessories':
        return Icons.star;
      default:
        return Icons.category;
    }
  }
}

class CategoryPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw decorative circles
    final circleRadius = 40.0;
    final spacing = 80.0;

    for (
      double x = -circleRadius;
      x < size.width + circleRadius;
      x += spacing
    ) {
      for (
        double y = -circleRadius;
        y < size.height + circleRadius;
        y += spacing
      ) {
        canvas.drawCircle(
          Offset(x + (y / spacing % 2) * spacing / 2, y),
          circleRadius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class CategoryStatsCard extends StatelessWidget {
  final Category category;

  const CategoryStatsCard({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Category Overview',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Products',
                  '${category.productCount ?? 0}',
                  Icons.inventory_2,
                ),
              ),

              Container(
                width: 1,
                height: 40.h,
                color: Theme.of(context).dividerColor,
              ),

              Expanded(
                child: _buildStatItem(
                  context,
                  'Subcategories',
                  '${category.subcategories?.length ?? 0}',
                  Icons.category,
                ),
              ),

              Container(
                width: 1,
                height: 40.h,
                color: Theme.of(context).dividerColor,
              ),

              Expanded(
                child: _buildStatItem(
                  context,
                  'Active',
                  category.isActive ? 'Yes' : 'No',
                  Icons.check_circle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 24.sp, color: Theme.of(context).primaryColor),

        SizedBox(height: 8.h),

        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),

        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: Theme.of(context).hintColor),
        ),
      ],
    );
  }
}

class CategoryBreadcrumb extends StatelessWidget {
  final List<Category> breadcrumbs;
  final ValueChanged<Category>? onCategoryTap;

  const CategoryBreadcrumb({
    super.key,
    required this.breadcrumbs,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            GestureDetector(
              onTap: () => onCategoryTap?.call(breadcrumbs.first),
              child: Text(
                'Home',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            ...breadcrumbs.asMap().entries.map((entry) {
              final index = entry.key;
              final category = entry.value;
              final isLast = index == breadcrumbs.length - 1;

              return Row(
                children: [
                  Icon(
                    Icons.chevron_right,
                    size: 16.sp,
                    color: Theme.of(context).hintColor,
                  ),

                  GestureDetector(
                    onTap: isLast ? null : () => onCategoryTap?.call(category),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isLast
                            ? Theme.of(context).textTheme.bodyMedium?.color
                            : Theme.of(context).primaryColor,
                        fontWeight: isLast ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
