import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product.dart';
import '../providers/product_providers_setup.dart';
import 'product_card.dart';

class RelatedProductsSection extends ConsumerWidget {
  final String productId;
  final ValueChanged<Product> onProductTap;

  const RelatedProductsSection({
    super.key,
    required this.productId,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Related products
          _buildRelatedProducts(context, ref),

          SizedBox(height: 24.h),

          // Frequently bought together
          _buildFrequentlyBoughtTogether(context, ref),

          SizedBox(height: 24.h),

          // Recently viewed
          _buildRecentlyViewed(context, ref),
        ],
      ),
    );
  }

  Widget _buildRelatedProducts(BuildContext context, WidgetRef ref) {
    final relatedProductsAsync = ref.watch(relatedProductsProvider(productId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Related Products',
          'Products similar to this one',
          Icons.recommend,
        ),

        SizedBox(height: 12.h),

        relatedProductsAsync.when(
          data: (products) => _buildProductGrid(context, products),
          loading: () => _buildLoadingGrid(context),
          error: (error, stack) =>
              _buildErrorWidget(context, 'related products'),
        ),
      ],
    );
  }

  Widget _buildFrequentlyBoughtTogether(BuildContext context, WidgetRef ref) {
    final frequentlyBoughtAsync = ref.watch(
      frequentlyBoughtTogetherProvider(productId),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Frequently Bought Together',
          'Customers who bought this item also bought',
          Icons.shopping_basket,
        ),

        SizedBox(height: 12.h),

        frequentlyBoughtAsync.when(
          data: (products) => _buildBundleSection(context, products),
          loading: () => _buildLoadingGrid(context),
          error: (error, stack) =>
              _buildErrorWidget(context, 'bundle products'),
        ),
      ],
    );
  }

  Widget _buildRecentlyViewed(BuildContext context, WidgetRef ref) {
    // For now, use a mock user ID. In a real app, this would come from authentication
    final recentlyViewedAsync = ref.watch(
      recentlyViewedProductsProvider('mock_user_id'),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          'Recently Viewed',
          'Products you viewed recently',
          Icons.history,
        ),

        SizedBox(height: 12.h),

        recentlyViewedAsync.when(
          data: (products) => products.isNotEmpty
              ? _buildHorizontalProductList(context, products)
              : _buildEmptyRecentlyViewed(context),
          loading: () => _buildLoadingGrid(context),
          error: (error, stack) =>
              _buildErrorWidget(context, 'recently viewed products'),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 20.sp, color: Theme.of(context).primaryColor),
        ),

        SizedBox(width: 12.w),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.headlineSmall?.color,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductGrid(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return _buildEmptyState(context, 'No related products found');
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: products.length > 4 ? 4 : products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          isGridView: true,
          onTap: () => onProductTap(product),
          onWishlistTap: () => _toggleWishlist(product),
        );
      },
    );
  }

  Widget _buildHorizontalProductList(
    BuildContext context,
    List<Product> products,
  ) {
    return SizedBox(
      height: 200.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return Container(
            width: 150.w,
            margin: EdgeInsets.only(right: 12.w),
            child: ProductCard(
              product: product,
              isGridView: true,
              onTap: () => onProductTap(product),
              onWishlistTap: () => _toggleWishlist(product),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBundleSection(BuildContext context, List<Product> products) {
    if (products.isEmpty) {
      return _buildEmptyState(context, 'No bundle products found');
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          // Bundle products
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: products.length > 3 ? 3 : products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  width: 100.w,
                  margin: EdgeInsets.only(right: 12.w),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.r),
                          child: Image.network(
                            product.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[200],
                                child: const Icon(Icons.broken_image),
                              );
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        product.name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          SizedBox(height: 16.h),

          // Bundle pricing
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bundle Price',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Theme.of(context).hintColor,
                      ),
                    ),
                    Text(
                      'TZS ${_formatPrice(_calculateBundlePrice(products))}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    Text(
                      'Save TZS ${_formatPrice(_calculateSavings(products))}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              ElevatedButton(
                onPressed: () => _addBundleToCart(products),
                child: Text('Add Bundle', style: TextStyle(fontSize: 14.sp)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 12.w,
        mainAxisSpacing: 12.h,
      ),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(12.r),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 48.sp,
            color: Theme.of(context).hintColor,
          ),
          SizedBox(height: 16.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyRecentlyViewed(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Icon(Icons.history, size: 48.sp, color: Theme.of(context).hintColor),
          SizedBox(height: 16.h),
          Text(
            'No recently viewed products',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            'Start browsing to see your recently viewed products here',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String type) {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load $type',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              // Retry loading
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  double _calculateBundlePrice(List<Product> products) {
    final totalPrice = products.fold<double>(
      0,
      (sum, product) => sum + product.price,
    );
    return totalPrice * 0.9; // 10% bundle discount
  }

  double _calculateSavings(List<Product> products) {
    final totalPrice = products.fold<double>(
      0,
      (sum, product) => sum + product.price,
    );
    return totalPrice * 0.1; // 10% savings
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  void _toggleWishlist(Product product) {
    // Toggle wishlist logic
  }

  void _addBundleToCart(List<Product> products) {
    // Add bundle to cart logic
  }
}
