import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product.dart';

class ProductInfoSection extends ConsumerWidget {
  final Product product;
  final VoidCallback? onBrandTap;
  final VoidCallback? onCategoryTap;

  const ProductInfoSection({
    super.key,
    required this.product,
    this.onBrandTap,
    this.onCategoryTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.all(16.w),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Brand and category
          _buildBrandAndCategory(context),

          SizedBox(height: 8.h),

          // Product name
          Text(
            product.name,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              height: 1.2,
              color: Theme.of(context).textTheme.headlineLarge?.color,
            ),
          ),

          SizedBox(height: 8.h),

          // Rating and reviews
          _buildRatingSection(context),

          SizedBox(height: 16.h),

          // Price section
          _buildPriceSection(context),

          SizedBox(height: 16.h),

          // Stock status
          _buildStockStatus(context),

          if (product.shortDescription != null) ...[
            SizedBox(height: 16.h),

            // Short description
            Text(
              product.shortDescription!,
              style: TextStyle(
                fontSize: 16.sp,
                height: 1.4,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],

          SizedBox(height: 16.h),

          // Key features
          _buildKeyFeatures(context),

          SizedBox(height: 16.h),

          // Product badges
          _buildProductBadges(context),
        ],
      ),
    );
  }

  Widget _buildBrandAndCategory(BuildContext context) {
    return Row(
      children: [
        // Brand
        GestureDetector(
          onTap: onBrandTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(
                color: Theme.of(context).primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.business,
                  size: 14.sp,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 4.w),
                Text(
                  product.brandName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),

        SizedBox(width: 8.w),

        // Category
        GestureDetector(
          onTap: onCategoryTap,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.category,
                  size: 14.sp,
                  color: Theme.of(context).hintColor,
                ),
                SizedBox(width: 4.w),
                Text(
                  product.categoryName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Column(
      children: [
        // First row: Stars, rating, and reviews
        Row(
          children: [
            // Star rating
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final starValue = index + 1;
                final rating = product.rating;

                return Icon(
                  starValue <= rating
                      ? Icons.star
                      : starValue - 0.5 <= rating
                      ? Icons.star_half
                      : Icons.star_border,
                  size: 18.sp, // Slightly smaller to save space
                  color: Colors.amber,
                );
              }),
            ),

            SizedBox(width: 8.w),

            // Rating value
            Text(
              product.rating.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),

            SizedBox(width: 8.w),

            // Review count - make it flexible
            Expanded(
              child: Text(
                '(${product.reviewCount} reviews)',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).hintColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Product ID
            Text(
              'ID: ${product.sku.isNotEmpty ? product.sku : product.id.substring(0, 8)}',
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).hintColor,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Current price
            Text(
              'TZS ${_formatPrice(product.price)}',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: Theme.of(context).primaryColor,
              ),
            ),

            // Original price (if on sale)
            if (product.isOnSale && product.originalPrice != null) ...[
              SizedBox(width: 12.w),
              Text(
                'TZS ${_formatPrice(product.originalPrice!)}',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Theme.of(context).hintColor,
                  decoration: TextDecoration.lineThrough,
                ),
              ),
            ],
          ],
        ),

        // Savings amount
        if (product.isOnSale && product.originalPrice != null) ...[
          SizedBox(height: 4.h),
          Text(
            'You save TZS ${_formatPrice(product.originalPrice! - product.price)}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.green,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],

        // Price per unit (if applicable)
        if (product.dimensions?.unit != null) ...[
          SizedBox(height: 4.h),
          Text(
            'TZS ${_formatPrice(product.price)} per ${product.dimensions!.unit}',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStockStatus(BuildContext context) {
    Color statusColor;
    String statusText;
    IconData statusIcon;

    if (product.isOutOfStock) {
      statusColor = Theme.of(context).colorScheme.error;
      statusText = 'Out of Stock';
      statusIcon = Icons.remove_circle_outline;
    } else if (product.isLowStock) {
      statusColor = Colors.orange;
      statusText = 'Low Stock (${product.stockQuantity} left)';
      statusIcon = Icons.warning_amber;
    } else {
      statusColor = Colors.green;
      statusText = 'In Stock';
      statusIcon = Icons.check_circle_outline;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: statusColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 20.sp, color: statusColor),
          SizedBox(width: 8.w),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyFeatures(BuildContext context) {
    final features = product.tags;
    if (features.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Key Features',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.headlineSmall?.color,
          ),
        ),

        SizedBox(height: 8.h),

        ...features
            .take(3)
            .map(
              (feature) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 6.h, right: 8.w),
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        feature,
                        style: TextStyle(
                          fontSize: 14.sp,
                          height: 1.4,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }

  Widget _buildProductBadges(BuildContext context) {
    final badges = <Widget>[];

    // Featured badge
    if (product.isFeatured) {
      badges.add(
        _buildBadge(
          context,
          'Featured',
          Icons.star,
          Theme.of(context).primaryColor,
        ),
      );
    }

    // New badge
    if (product.isNew) {
      badges.add(_buildBadge(context, 'New', Icons.new_releases, Colors.green));
    }

    // Best seller badge
    if (product.isPopular) {
      badges.add(
        _buildBadge(context, 'Best Seller', Icons.trending_up, Colors.orange),
      );
    }

    // Warranty badge
    if (product.hasWarranty) {
      badges.add(
        _buildBadge(context, 'Warranty', Icons.verified_user, Colors.blue),
      );
    }

    if (badges.isEmpty) return const SizedBox.shrink();

    return Wrap(spacing: 8.w, runSpacing: 8.h, children: badges);
  }

  Widget _buildBadge(
    BuildContext context,
    String label,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
