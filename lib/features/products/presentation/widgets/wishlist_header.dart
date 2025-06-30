import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/wishlist.dart';

class WishlistHeader extends StatelessWidget {
  final Wishlist wishlist;
  final VoidCallback? onShareTap;
  final VoidCallback? onClearTap;

  const WishlistHeader({
    super.key,
    required this.wishlist,
    this.onShareTap,
    this.onClearTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header content
          Row(
            children: [
              // Wishlist icon
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
                child: Icon(Icons.favorite, size: 32.sp, color: Colors.white),
              ),

              SizedBox(width: 16.w),

              // Wishlist info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'My Wishlist',
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

                    Text(
                      'Your saved items',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withOpacity(0.9),
                        shadows: [
                          Shadow(
                            offset: const Offset(0, 1),
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.3),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Wishlist statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Total Items',
                  '${wishlist.products.length}',
                  Icons.inventory_2,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: _buildStatCard(
                  context,
                  'Available',
                  '${wishlist.products.where((p) => p.isInStock).length}',
                  Icons.check_circle,
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: _buildStatCard(
                  context,
                  'On Sale',
                  '${wishlist.products.where((p) => p.isOnSale).length}',
                  Icons.local_offer,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onShareTap,
                  icon: Icon(Icons.share, size: 18.sp, color: Colors.white),
                  label: const Text('Share'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _addAllToCart(context),
                  icon: Icon(Icons.shopping_cart, size: 18.sp),
                  label: const Text('Add All to Cart'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.2),
                    foregroundColor: Colors.white,
                    side: BorderSide(color: Colors.white.withOpacity(0.3)),
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
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20.sp, color: Colors.white),

          SizedBox(height: 6.h),

          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _addAllToCart(BuildContext context) {
    final availableProducts = wishlist.products
        .where((p) => p.isInStock)
        .toList();

    if (availableProducts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No available items to add to cart'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add All to Cart'),
        content: Text(
          'Add ${availableProducts.length} available items to your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Add all available products to cart
              for (final product in availableProducts) {
                // TODO: Implement add to cart functionality
                // ref.addToCart(product, 1);
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    '${availableProducts.length} items added to cart',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Add All'),
          ),
        ],
      ),
    );
  }
}

class WishlistSummaryCard extends StatelessWidget {
  final Wishlist wishlist;
  final VoidCallback? onViewAll;

  const WishlistSummaryCard({
    super.key,
    required this.wishlist,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final totalValue = wishlist.products.fold<double>(
      0,
      (sum, product) => sum + product.price,
    );

    final onSaleValue = wishlist.products
        .where((p) => p.isOnSale)
        .fold<double>(0, (sum, product) => sum + product.price);

    final savings = wishlist.products
        .where((p) => p.isOnSale && p.originalPrice != null)
        .fold<double>(
          0,
          (sum, product) => sum + (product.originalPrice! - product.price),
        );

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Wishlist Summary',
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
                child: _buildSummaryItem(
                  context,
                  'Total Value',
                  'TZS ${_formatPrice(totalValue)}',
                  Icons.account_balance_wallet,
                ),
              ),

              Container(
                width: 1,
                height: 40.h,
                color: Theme.of(context).dividerColor,
              ),

              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Items',
                  '${wishlist.products.length}',
                  Icons.inventory_2,
                ),
              ),
            ],
          ),

          if (savings > 0) ...[
            SizedBox(height: 16.h),

            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(color: Colors.green.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.savings, size: 20.sp, color: Colors.green),
                  SizedBox(width: 8.w),
                  Text(
                    'Potential Savings: TZS ${_formatPrice(savings)}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.green[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 16.h),

          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onViewAll,
              child: const Text('View All Items'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
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

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class WishlistQuickActions extends StatelessWidget {
  final Wishlist wishlist;
  final VoidCallback? onAddAllToCart;
  final VoidCallback? onShareWishlist;
  final VoidCallback? onClearWishlist;

  const WishlistQuickActions({
    super.key,
    required this.wishlist,
    this.onAddAllToCart,
    this.onShareWishlist,
    this.onClearWishlist,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              context,
              'Add All to Cart',
              Icons.shopping_cart,
              onAddAllToCart,
              Theme.of(context).primaryColor,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: _buildActionButton(
              context,
              'Share',
              Icons.share,
              onShareWishlist,
              Colors.blue,
            ),
          ),

          SizedBox(width: 12.w),

          Expanded(
            child: _buildActionButton(
              context,
              'Clear',
              Icons.clear_all,
              onClearWishlist,
              Theme.of(context).colorScheme.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback? onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24.sp, color: color),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                color: color,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
