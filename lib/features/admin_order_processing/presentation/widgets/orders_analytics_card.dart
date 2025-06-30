import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/admin_order_providers.dart';

class OrdersAnalyticsCard extends ConsumerWidget {
  const OrdersAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(ordersAnalyticsProvider);

    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.analytics,
                  size: 20.r,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Orders Overview',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            analyticsAsync.when(
              data: (analytics) => _buildAnalyticsContent(context, analytics),
              loading: () => _buildLoadingContent(context),
              error: (error, stack) => _buildErrorContent(context, error.toString()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context, Map<String, dynamic> analytics) {
    final totalOrders = analytics['totalOrders'] as int? ?? 0;
    final pendingOrders = analytics['pendingOrders'] as int? ?? 0;
    final processingOrders = analytics['processingOrders'] as int? ?? 0;
    final shippedOrders = analytics['shippedOrders'] as int? ?? 0;
    final deliveredOrders = analytics['deliveredOrders'] as int? ?? 0;
    final cancelledOrders = analytics['cancelledOrders'] as int? ?? 0;
    final totalRevenue = analytics['totalRevenue'] as double? ?? 0.0;
    final averageOrderValue = analytics['averageOrderValue'] as double? ?? 0.0;

    return Column(
      children: [
        // First row: Total Orders and Revenue
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                'Total Orders',
                totalOrders.toString(),
                Icons.shopping_cart,
                Colors.blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildMetricItem(
                context,
                'Total Revenue',
                'TZS ${_formatCurrency(totalRevenue)}',
                Icons.attach_money,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        
        // Second row: Pending and Processing
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                'Pending',
                pendingOrders.toString(),
                Icons.pending,
                Colors.orange,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildMetricItem(
                context,
                'Processing',
                processingOrders.toString(),
                Icons.settings,
                Colors.purple,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        
        // Third row: Shipped and Delivered
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                'Shipped',
                shippedOrders.toString(),
                Icons.local_shipping,
                Colors.indigo,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildMetricItem(
                context,
                'Delivered',
                deliveredOrders.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        
        // Fourth row: Cancelled and Average Order Value
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                'Cancelled',
                cancelledOrders.toString(),
                Icons.cancel,
                Colors.red,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildMetricItem(
                context,
                'Avg. Order',
                'TZS ${_formatCurrency(averageOrderValue)}',
                Icons.trending_up,
                Colors.teal,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricItem(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 16.r,
                color: color,
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < 4; i++) ...[
          Row(
            children: [
              Expanded(child: _buildSkeletonMetric(context)),
              SizedBox(width: 12.w),
              Expanded(child: _buildSkeletonMetric(context)),
            ],
          ),
          if (i < 3) SizedBox(height: 12.h),
        ],
      ],
    );
  }

  Widget _buildSkeletonMetric(BuildContext context) {
    return Container(
      height: 60.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 12.h,
            width: 60.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            height: 16.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContent(BuildContext context, String error) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 32.r,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 8.h),
          Text(
            'Failed to load analytics',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }
}
