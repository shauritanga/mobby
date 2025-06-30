import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../providers/admin_insurance_providers.dart';

class ApplicationAnalyticsCard extends ConsumerWidget {
  const ApplicationAnalyticsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsync = ref.watch(applicationsAnalyticsProvider);

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
                  'Application Overview',
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
    final totalApplications = analytics['totalApplications'] as int? ?? 0;
    final pendingApplications = analytics['pendingApplications'] as int? ?? 0;
    final approvedApplications = analytics['approvedApplications'] as int? ?? 0;
    final rejectedApplications = analytics['rejectedApplications'] as int? ?? 0;
    final underReviewApplications = analytics['underReviewApplications'] as int? ?? 0;

    return Column(
      children: [
        // First row: Total and Pending
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                'Total',
                totalApplications.toString(),
                Icons.assignment,
                Colors.blue,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildMetricItem(
                context,
                'Pending',
                pendingApplications.toString(),
                Icons.pending_actions,
                Colors.orange,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        
        // Second row: Under Review and Approved
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                'Under Review',
                underReviewApplications.toString(),
                Icons.rate_review,
                Colors.purple,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildMetricItem(
                context,
                'Approved',
                approvedApplications.toString(),
                Icons.check_circle,
                Colors.green,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        
        // Third row: Rejected
        Row(
          children: [
            Expanded(
              child: _buildMetricItem(
                context,
                'Rejected',
                rejectedApplications.toString(),
                Icons.cancel,
                Colors.red,
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
              fontSize: 18.sp,
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
            height: 18.h,
            width: 40.w,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(9.r),
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
