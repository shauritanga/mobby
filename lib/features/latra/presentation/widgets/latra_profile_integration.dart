import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../services/latra_integration_service.dart';
import '../utils/latra_navigation.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

/// LATRA Profile Integration widget for displaying LATRA info in profile
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRAProfileIntegration extends ConsumerWidget {
  const LATRAProfileIntegration({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider).value;
    
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<LATRASummary>(
      future: ref.read(latraIntegrationServiceProvider).getUserLATRASummary(currentUser.id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingSection();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final summary = snapshot.data!;
        return _buildLATRASection(context, summary);
      },
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120.w,
            height: 18.h,
            decoration: BoxDecoration(
              color: AppColors.border.withOpacity(0.3),
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: List.generate(3, (index) => 
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 12.w : 0),
                  height: 60.h,
                  decoration: BoxDecoration(
                    color: AppColors.border.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLATRASection(BuildContext context, LATRASummary summary) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.account_balance,
                color: AppColors.primary,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Text(
                'LATRA Services',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => LATRANavigation.navigateToMain(context),
                child: Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Statistics Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Applications',
                  summary.totalApplications.toString(),
                  Icons.description,
                  AppColors.primary,
                  onTap: () => LATRANavigation.navigateToStatusTracking(context),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  'Documents',
                  summary.totalDocuments.toString(),
                  Icons.folder,
                  AppColors.info,
                  onTap: () => LATRANavigation.navigateToDocuments(context),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  'Active',
                  summary.activeApplications.toString(),
                  Icons.pending,
                  AppColors.warning,
                  onTap: () => LATRANavigation.navigateToStatusTracking(context),
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Quick Actions
          Row(
            children: [
              Expanded(
                child: _buildQuickActionButton(
                  'New Application',
                  Icons.add_circle_outline,
                  AppColors.success,
                  () => _showApplicationOptions(context),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildQuickActionButton(
                  'Track Status',
                  Icons.timeline,
                  AppColors.info,
                  () => LATRANavigation.navigateToStatusTracking(context),
                ),
              ),
            ],
          ),
          
          // Alerts and Notifications
          if (summary.pendingActions.isNotEmpty || 
              summary.expiredDocuments > 0 || 
              summary.expiringSoonDocuments > 0) ...[
            SizedBox(height: 16.h),
            _buildAlertsSection(context, summary),
          ],
          
          // Last Activity
          if (summary.lastApplicationDate != null) ...[
            SizedBox(height: 16.h),
            _buildLastActivitySection(summary.lastApplicationDate!),
          ],
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 20.w,
            ),
            SizedBox(height: 8.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 16.w,
            ),
            SizedBox(width: 6.w),
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
      ),
    );
  }

  Widget _buildAlertsSection(BuildContext context, LATRASummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alerts',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        
        if (summary.pendingActions.isNotEmpty)
          _buildAlertItem(
            '${summary.pendingActions.length} pending action${summary.pendingActions.length == 1 ? '' : 's'}',
            Icons.warning_amber,
            AppColors.warning,
            () => LATRANavigation.navigateToStatusTracking(context),
          ),
        
        if (summary.expiredDocuments > 0)
          _buildAlertItem(
            '${summary.expiredDocuments} document${summary.expiredDocuments == 1 ? '' : 's'} expired',
            Icons.error,
            AppColors.error,
            () => LATRANavigation.navigateToDocuments(context),
          ),
        
        if (summary.expiringSoonDocuments > 0)
          _buildAlertItem(
            '${summary.expiringSoonDocuments} document${summary.expiringSoonDocuments == 1 ? '' : 's'} expiring soon',
            Icons.schedule,
            AppColors.warning,
            () => LATRANavigation.navigateToDocuments(context),
          ),
      ],
    );
  }

  Widget _buildAlertItem(
    String message,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 16.w,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: color,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: color,
                size: 12.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastActivitySection(DateTime lastActivity) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            color: AppColors.textSecondary,
            size: 16.w,
          ),
          SizedBox(width: 8.w),
          Text(
            'Last activity: ${_formatDate(lastActivity)}',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  void _showApplicationOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.symmetric(vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  Text(
                    'New LATRA Application',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  _buildApplicationOption(
                    context,
                    'Vehicle Registration',
                    'Register a new vehicle with LATRA',
                    Icons.app_registration,
                    AppColors.primary,
                    () => LATRANavigation.navigateToVehicleRegistration(context),
                  ),
                  SizedBox(height: 12.h),
                  _buildApplicationOption(
                    context,
                    'Driving License',
                    'Apply for a new driving license',
                    Icons.credit_card,
                    AppColors.success,
                    () => LATRANavigation.navigateToLicenseApplication(context),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildApplicationOption(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        onTap();
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 20.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16.w,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
