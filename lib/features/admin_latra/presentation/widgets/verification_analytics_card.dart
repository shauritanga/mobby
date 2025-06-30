import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/admin_latra_providers.dart';

class VerificationAnalyticsCard extends ConsumerWidget {
  const VerificationAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(verificationAnalyticsProvider);

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
                  Icons.verified,
                  size: 20.r,
                  color: Theme.of(context).colorScheme.primary,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Verification Overview',
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
    final totalVerifications = analytics['totalVerifications'] as int? ?? 0;
    final approvedVerifications = analytics['approvedVerifications'] as int? ?? 0;
    final rejectedVerifications = analytics['rejectedVerifications'] as int? ?? 0;
    final pendingVerifications = analytics['pendingVerifications'] as int? ?? 0;

    return Row(
      children: [
        Expanded(
          child: _buildMetricItem(
            context,
            'Total',
            totalVerifications.toString(),
            Icons.folder,
            Colors.blue,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildMetricItem(
            context,
            'Approved',
            approvedVerifications.toString(),
            Icons.check_circle,
            Colors.green,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildMetricItem(
            context,
            'Rejected',
            rejectedVerifications.toString(),
            Icons.cancel,
            Colors.red,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildMetricItem(
            context,
            'Pending',
            pendingVerifications.toString(),
            Icons.pending,
            Colors.orange,
          ),
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
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 16.r,
            color: color,
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
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < 4; i++) ...[
          Expanded(child: _buildSkeletonMetric(context)),
          if (i < 3) SizedBox(width: 12.w),
        ],
      ],
    );
  }

  Widget _buildSkeletonMetric(BuildContext context) {
    return Container(
      height: 60.h,
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          Container(
            height: 16.h,
            width: 16.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            height: 14.h,
            width: 20.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(7.r),
            ),
          ),
          SizedBox(height: 2.h),
          Container(
            height: 10.h,
            width: 30.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(5.r),
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
