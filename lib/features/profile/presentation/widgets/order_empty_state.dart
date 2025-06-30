import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

/// Order empty state widget for when no orders are found
/// Following specifications from FEATURES_DOCUMENTATION.md
class OrderEmptyState extends StatelessWidget {
  final String status;
  final VoidCallback? onRefresh;

  const OrderEmptyState({
    super.key,
    required this.status,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getEmptyStateIcon(),
                size: 60.sp,
                color: Theme.of(context).primaryColor.withOpacity(0.6),
              ),
            ),
            
            SizedBox(height: 24.h),
            
            // Title
            Text(
              _getEmptyStateTitle(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.titleLarge?.color,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 8.h),
            
            // Subtitle
            Text(
              _getEmptyStateSubtitle(),
              style: TextStyle(
                fontSize: 16.sp,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: 32.h),
            
            // Action Buttons
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  IconData _getEmptyStateIcon() {
    switch (status) {
      case 'pending':
        return Icons.schedule;
      case 'delivered':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      default:
        return Icons.shopping_bag_outlined;
    }
  }

  String _getEmptyStateTitle() {
    switch (status) {
      case 'pending':
        return 'No Pending Orders';
      case 'delivered':
        return 'No Delivered Orders';
      case 'cancelled':
        return 'No Cancelled Orders';
      default:
        return 'No Orders Yet';
    }
  }

  String _getEmptyStateSubtitle() {
    switch (status) {
      case 'pending':
        return 'You don\'t have any pending orders at the moment.';
      case 'delivered':
        return 'You don\'t have any delivered orders yet.';
      case 'cancelled':
        return 'You don\'t have any cancelled orders.';
      default:
        return 'Start shopping for automotive parts and accessories to see your orders here.';
    }
  }

  Widget _buildActionButtons(BuildContext context) {
    if (status == 'all') {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => context.go('/products'),
              icon: const Icon(Icons.shopping_cart),
              label: const Text('Start Shopping'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          
          SizedBox(height: 12.h),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.go('/categories'),
              icon: const Icon(Icons.category),
              label: const Text('Browse Categories'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        if (onRefresh != null) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRefresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
          
          SizedBox(height: 12.h),
        ],
        
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => context.go('/products'),
            icon: const Icon(Icons.shopping_cart),
            label: const Text('Shop Now'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
