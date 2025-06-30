import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/admin_latra_providers.dart';

class IntegrationAnalyticsCard extends ConsumerWidget {
  const IntegrationAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(integrationAnalyticsProvider);

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
                  Icons.cloud,
                  size: 20.r,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Integration Overview',
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
    final totalServices = analytics['totalServices'] as int? ?? 0;
    final healthyServices = analytics['healthyServices'] as int? ?? 0;
    final warningServices = analytics['warningServices'] as int? ?? 0;
    final downServices = analytics['downServices'] as int? ?? 0;
    final averageResponseTime = analytics['averageResponseTime'] as int? ?? 0;

    return Column(
      children: [
        // First row: Services status
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                'Total',
                totalServices.toString(),
                Icons.cloud,
                Colors.blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildMetricItem(
                context,
                'Healthy',
                healthyServices.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        
        // Second row: Warning and Down
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                'Warning',
                warningServices.toString(),
                Icons.warning,
                Colors.orange,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildMetricItem(
                context,
                'Down',
                downServices.toString(),
                Icons.error,
                Colors.red,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        
        // Third row: Response time
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                'Avg Response',
                '${averageResponseTime}ms',
                Icons.speed,
                Colors.purple,
              ),
            ),
            Expanded(child: Container()), // Empty space
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
        for (int i = 0; i < 3; i++) ...[
          Row(
            children: [
              Expanded(child: _buildSkeletonMetric(context)),
              SizedBox(width: 12.w),
              Expanded(child: i < 2 ? _buildSkeletonMetric(context) : Container()),
            ],
          ),
          if (i < 2) SizedBox(height: 12.h),
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
            height: 14.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(7.r),
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
        ],
      ),
    );
  }
}
