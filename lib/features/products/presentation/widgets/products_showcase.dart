import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/product.dart';
import '../providers/product_providers.dart';

/// Products Showcase Widget - Demonstrates integrated sample products
class ProductsShowcase extends ConsumerWidget {
  const ProductsShowcase({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Automotive Products'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Navigate to search screen
              context.push('/products');
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(context),

            SizedBox(height: 24.h),

            // Featured Products
            _buildFeaturedProducts(context, ref),

            SizedBox(height: 24.h),

            // Products on Sale
            _buildSaleProducts(context, ref),

            SizedBox(height: 24.h),

            // Categories Section
            _buildCategoriesSection(context),

            SizedBox(height: 24.h),

            // All Products Button
            _buildViewAllButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to Mobby Auto Parts',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Discover premium automotive products for your vehicle',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildStatCard('12+', 'Products'),
              SizedBox(width: 16.w),
              _buildStatCard('8', 'Categories'),
              SizedBox(width: 16.w),
              _buildStatCard('5+', 'Brands'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String number, String label) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Column(
          children: [
            Text(
              number,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedProducts(BuildContext context, WidgetRef ref) {
    final featuredProductsAsync = ref.watch(featuredProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Featured Products',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
            TextButton(
              onPressed: () => context.push('/products'),
              child: const Text('View All'),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 200.h,
          child: featuredProductsAsync.when(
            data: (products) => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(context, product);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Error loading products: $error')),
          ),
        ),
      ],
    );
  }

  Widget _buildSaleProducts(BuildContext context, WidgetRef ref) {
    final saleProductsAsync = ref.watch(saleProductsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Special Offers',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                'SALE',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 200.h,
          child: saleProductsAsync.when(
            data: (products) => ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return _buildProductCard(context, product);
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) =>
                Center(child: Text('Error loading products: $error')),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Container(
      width: 160.w,
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          Container(
            height: 100.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: Image.network(
                product.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Center(
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40.sp,
                      color: Colors.grey[400],
                    ),
                  );
                },
              ),
            ),
          ),

          // Product Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Price
                  if (product.isOnSale) ...[
                    Text(
                      '${product.currency} ${product.originalPrice!.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey,
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                  Text(
                    '${product.currency} ${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: product.isOnSale
                          ? Colors.red
                          : Theme.of(context).colorScheme.primary,
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

  Widget _buildCategoriesSection(BuildContext context) {
    final categories = [
      {'name': 'Fluids & Lubricants', 'icon': Icons.opacity, 'count': 2},
      {'name': 'Brakes & Suspension', 'icon': Icons.settings, 'count': 1},
      {'name': 'Filters', 'icon': Icons.filter_alt, 'count': 1},
      {'name': 'Electrical', 'icon': Icons.electrical_services, 'count': 1},
      {'name': 'Tires & Wheels', 'icon': Icons.tire_repair, 'count': 1},
      {'name': 'Lighting', 'icon': Icons.lightbulb, 'count': 1},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Shop by Category',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
        ),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.0,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    category['icon'] as IconData,
                    size: 32.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${category['count']} items',
                    style: TextStyle(fontSize: 8.sp, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.push('/products'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        child: Text(
          'View All Products',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
