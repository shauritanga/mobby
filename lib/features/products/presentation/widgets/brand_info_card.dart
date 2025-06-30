import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/brand.dart';

class BrandInfoCard extends StatelessWidget {
  final Brand brand;
  final ValueChanged<String>? onCategoryTap;
  final VoidCallback? onContactTap;

  const BrandInfoCard({
    super.key,
    required this.brand,
    this.onCategoryTap,
    this.onContactTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand description
          ...[
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About ${brand.name}',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    brand.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.5,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: Theme.of(context).dividerColor),
          ],

          // Brand statistics
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Brand Overview',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),

                SizedBox(height: 12.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildStatItem(
                        context,
                        'Products',
                        '${brand.productCount ?? 0}',
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
                        'Categories',
                        '0', // TODO: Add categories support to Brand entity
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
                        'Rating',
                        brand.rating?.toStringAsFixed(1) ?? 'N/A',
                        Icons.star,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // TODO: Brand categories - Add categories support to Brand entity
          /*
          if (brand.categories != null && brand.categories!.isNotEmpty) ...[
            Divider(height: 1, color: Theme.of(context).dividerColor),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Product Categories',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: brand.categories!.take(6).map((category) {
                      return GestureDetector(
                        onTap: () => onCategoryTap?.call(category.id),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Theme.of(
                              context,
                            ).primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(
                              color: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            category.name,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  if (brand.categories!.length > 6) ...[
                    SizedBox(height: 8.h),
                    Text(
                      '+${brand.categories!.length - 6} more categories',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
          */

          // TODO: Brand highlights - Add highlights support to Brand entity
          /*
          if (brand.highlights != null && brand.highlights!.isNotEmpty) ...[
            Divider(height: 1, color: Theme.of(context).dividerColor),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Brand Highlights',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  ...brand.highlights!.map((highlight) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 8.h),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: EdgeInsets.only(top: 6.h),
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Text(
                              highlight,
                              style: TextStyle(
                                fontSize: 14.sp,
                                height: 1.4,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
          */

          // Contact information
          if (brand.email != null ||
              brand.phone != null ||
              brand.websiteUrl != null) ...[
            Divider(height: 1, color: Theme.of(context).dividerColor),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.headlineSmall?.color,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  if (brand.websiteUrl != null)
                    _buildContactItem(
                      context,
                      Icons.web,
                      'Website',
                      brand.websiteUrl!,
                      () => _openWebsite(brand.websiteUrl!),
                    ),

                  if (brand.email != null)
                    _buildContactItem(
                      context,
                      Icons.email,
                      'Email',
                      brand.email!,
                      () => _sendEmail(brand.email!),
                    ),

                  if (brand.phone != null)
                    _buildContactItem(
                      context,
                      Icons.phone,
                      'Phone',
                      brand.phone!,
                      () => _makeCall(brand.phone!),
                    ),

                  SizedBox(height: 8.h),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: onContactTap,
                      icon: Icon(Icons.contact_support, size: 18.sp),
                      label: const Text('Contact Brand'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
            fontSize: 18.sp,
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

  Widget _buildContactItem(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    VoidCallback onTap,
  ) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: GestureDetector(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 20.sp, color: Theme.of(context).primaryColor),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 20.sp,
              color: Theme.of(context).hintColor,
            ),
          ],
        ),
      ),
    );
  }

  void _openWebsite(String url) {
    // Open website functionality
  }

  void _sendEmail(String email) {
    // Send email functionality
  }

  void _makeCall(String phone) {
    // Make call functionality
  }
}

// TODO: BrandAchievements - Add achievements support to Brand entity
/*
class BrandAchievements extends StatelessWidget {
  final Brand brand;

  const BrandAchievements({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    final achievements = brand.achievements ?? [];

    if (achievements.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Achievements & Awards',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),

          SizedBox(height: 12.h),

          ...achievements.map((achievement) {
            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.emoji_events,
                      size: 20.sp,
                      color: Colors.amber[700],
                    ),
                  ),

                  SizedBox(width: 12.w),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                        if (achievement.description != null)
                          Text(
                            achievement.description!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        if (achievement.year != null)
                          Text(
                            achievement.year.toString(),
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Theme.of(context).hintColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
*/

// TODO: BrandTimeline - Add foundedYear and headquarters support to Brand entity
/*
class BrandTimeline extends StatelessWidget {
  final Brand brand;

  const BrandTimeline({super.key, required this.brand});

  @override
  Widget build(BuildContext context) {
    if (brand.foundedYear == null) {
      return const SizedBox.shrink();
    }

    final currentYear = DateTime.now().year;
    final yearsInBusiness = currentYear - brand.foundedYear!;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Company Timeline',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),

          SizedBox(height: 12.h),

          Row(
            children: [
              Icon(
                Icons.business,
                size: 20.sp,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 12.w),
              Text(
                'Founded in ${brand.foundedYear}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),

          SizedBox(height: 8.h),

          Row(
            children: [
              Icon(
                Icons.timeline,
                size: 20.sp,
                color: Theme.of(context).primaryColor,
              ),
              SizedBox(width: 12.w),
              Text(
                '$yearsInBusiness years in business',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),

          if (brand.headquarters != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 20.sp,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 12.w),
                Text(
                  'Headquarters: ${brand.headquarters}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
*/
