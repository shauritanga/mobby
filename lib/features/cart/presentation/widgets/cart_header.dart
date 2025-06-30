import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/cart.dart';

class CartHeader extends StatelessWidget {
  final Cart cart;
  final VoidCallback? onClearCart;
  final VoidCallback? onSaveForLater;

  const CartHeader({
    super.key,
    required this.cart,
    this.onClearCart,
    this.onSaveForLater,
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
              // Cart icon
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
                  Icons.shopping_cart,
                  size: 32.sp,
                  color: Colors.white,
                ),
              ),
              
              SizedBox(width: 16.w),
              
              // Cart info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shopping Cart',
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
                      '${cart.items.length} item${cart.items.length != 1 ? 's' : ''} in your cart',
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
          
          // Cart statistics
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  'Items',
                  '${cart.items.length}',
                  Icons.inventory_2,
                ),
              ),
              
              SizedBox(width: 12.w),
              
              Expanded(
                child: _buildStatCard(
                  context,
                  'Subtotal',
                  'TZS ${_formatPrice(cart.subtotal)}',
                  Icons.account_balance_wallet,
                ),
              ),
              
              SizedBox(width: 12.w),
              
              Expanded(
                child: _buildStatCard(
                  context,
                  'Savings',
                  'TZS ${_formatPrice(cart.totalSavings)}',
                  Icons.savings,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Quick actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onSaveForLater,
                  icon: Icon(
                    Icons.bookmark_outline,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                  label: const Text('Save for Later'),
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
              
              SizedBox(width: 12.w),
              
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _showCartActions(context),
                  icon: Icon(
                    Icons.more_horiz,
                    size: 18.sp,
                  ),
                  label: const Text('More Actions'),
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
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: Colors.white,
          ),
          
          SizedBox(height: 6.h),
          
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
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

  void _showCartActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: EdgeInsets.only(top: 8.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Cart Actions',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            ListTile(
              leading: const Icon(Icons.bookmark_outline),
              title: const Text('Save All for Later'),
              onTap: () {
                Navigator.of(context).pop();
                onSaveForLater?.call();
              },
            ),
            
            ListTile(
              leading: const Icon(Icons.share),
              title: const Text('Share Cart'),
              onTap: () {
                Navigator.of(context).pop();
                _shareCart(context);
              },
            ),
            
            ListTile(
              leading: Icon(
                Icons.clear_all,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Clear Cart',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
              onTap: () {
                Navigator.of(context).pop();
                onClearCart?.call();
              },
            ),
            
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _shareCart(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Share Cart'),
        content: const Text('Share your cart with friends and family'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement share functionality
            },
            child: const Text('Share'),
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

class CartProgressIndicator extends StatelessWidget {
  final Cart cart;
  final double freeShippingThreshold;

  const CartProgressIndicator({
    super.key,
    required this.cart,
    this.freeShippingThreshold = 50000, // TZS 50,000
  });

  @override
  Widget build(BuildContext context) {
    final progress = (cart.subtotal / freeShippingThreshold).clamp(0.0, 1.0);
    final remaining = freeShippingThreshold - cart.subtotal;
    
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_shipping,
                size: 20.sp,
                color: progress >= 1.0 ? Colors.green : Theme.of(context).primaryColor,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  progress >= 1.0
                      ? 'You qualify for FREE shipping!'
                      : 'Add TZS ${_formatPrice(remaining)} more for FREE shipping',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: progress >= 1.0 ? Colors.green : Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : Theme.of(context).primaryColor,
            ),
          ),
          
          SizedBox(height: 8.h),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TZS ${_formatPrice(cart.subtotal)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).hintColor,
                ),
              ),
              Text(
                'TZS ${_formatPrice(freeShippingThreshold)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(context).hintColor,
                ),
              ),
            ],
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

class CartQuickStats extends StatelessWidget {
  final Cart cart;

  const CartQuickStats({
    super.key,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    final totalQuantity = cart.items.fold<int>(0, (sum, item) => sum + item.quantity);
    final uniqueProducts = cart.items.length;
    final averagePrice = cart.items.isNotEmpty ? cart.subtotal / totalQuantity : 0.0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cart Summary',
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
                child: _buildQuickStat(
                  context,
                  'Total Items',
                  totalQuantity.toString(),
                  Icons.inventory_2,
                ),
              ),
              
              Container(
                width: 1,
                height: 40.h,
                color: Theme.of(context).dividerColor,
              ),
              
              Expanded(
                child: _buildQuickStat(
                  context,
                  'Products',
                  uniqueProducts.toString(),
                  Icons.category,
                ),
              ),
              
              Container(
                width: 1,
                height: 40.h,
                color: Theme.of(context).dividerColor,
              ),
              
              Expanded(
                child: _buildQuickStat(
                  context,
                  'Avg. Price',
                  'TZS ${_formatPrice(averagePrice)}',
                  Icons.trending_up,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStat(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: Theme.of(context).primaryColor,
        ),
        
        SizedBox(height: 4.h),
        
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Theme.of(context).hintColor,
          ),
          textAlign: TextAlign.center,
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
