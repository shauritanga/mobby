import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// LATRA Quick Actions widget for common LATRA operations
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRAQuickActions extends StatelessWidget {
  final VoidCallback? onVehicleRegistration;
  final VoidCallback? onLicenseApplication;
  final VoidCallback? onStatusTracking;
  final VoidCallback? onDocumentUpload;
  final VoidCallback? onRenewal;
  final VoidCallback? onPayment;
  final bool showAll;
  final QuickActionsLayout layout;

  const LATRAQuickActions({
    super.key,
    this.onVehicleRegistration,
    this.onLicenseApplication,
    this.onStatusTracking,
    this.onDocumentUpload,
    this.onRenewal,
    this.onPayment,
    this.showAll = true,
    this.layout = QuickActionsLayout.grid,
  });

  @override
  Widget build(BuildContext context) {
    final actions = _getQuickActions();
    
    switch (layout) {
      case QuickActionsLayout.grid:
        return _buildGridLayout(actions);
      case QuickActionsLayout.list:
        return _buildListLayout(actions);
      case QuickActionsLayout.horizontal:
        return _buildHorizontalLayout(actions);
      case QuickActionsLayout.compact:
        return _buildCompactLayout(actions);
    }
  }

  Widget _buildGridLayout(List<QuickAction> actions) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.2,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) => _buildGridActionCard(actions[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildListLayout(List<QuickAction> actions) {
    return Container(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...actions.map((action) => _buildListActionCard(action)),
        ],
      ),
    );
  }

  Widget _buildHorizontalLayout(List<QuickAction> actions) {
    return Container(
      height: 120.h,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: actions.length,
              itemBuilder: (context, index) => _buildHorizontalActionCard(actions[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactLayout(List<QuickAction> actions) {
    return Container(
      padding: EdgeInsets.all(12.w),
      child: Row(
        children: [
          for (int i = 0; i < actions.length && i < 4; i++) ...[
            Expanded(child: _buildCompactActionButton(actions[i])),
            if (i < actions.length - 1 && i < 3) SizedBox(width: 8.w),
          ],
        ],
      ),
    );
  }

  Widget _buildGridActionCard(QuickAction action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: action.color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                action.icon,
                color: action.color,
                size: 24.w,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              action.title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (action.subtitle != null) ...[
              SizedBox(height: 4.h),
              Text(
                action.subtitle!,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildListActionCard(QuickAction action) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      action.title,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    if (action.subtitle != null) ...[
                      SizedBox(height: 4.h),
                      Text(
                        action.subtitle!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalActionCard(QuickAction action) {
    return Container(
      width: 100.w,
      margin: EdgeInsets.only(right: 12.w),
      child: InkWell(
        onTap: action.onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36.w,
                height: 36.w,
                decoration: BoxDecoration(
                  color: action.color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  action.icon,
                  color: action.color,
                  size: 20.w,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                action.title,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCompactActionButton(QuickAction action) {
    return InkWell(
      onTap: action.onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: action.color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(
              action.icon,
              color: action.color,
              size: 20.w,
            ),
            SizedBox(height: 4.h),
            Text(
              action.title,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: action.color,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  List<QuickAction> _getQuickActions() {
    final allActions = [
      if (onVehicleRegistration != null)
        QuickAction(
          title: 'Vehicle Registration',
          subtitle: 'Register your vehicle',
          icon: Icons.app_registration,
          color: AppColors.primary,
          onTap: onVehicleRegistration!,
        ),
      if (onLicenseApplication != null)
        QuickAction(
          title: 'License Application',
          subtitle: 'Apply for driving license',
          icon: Icons.credit_card,
          color: AppColors.success,
          onTap: onLicenseApplication!,
        ),
      if (onStatusTracking != null)
        QuickAction(
          title: 'Track Status',
          subtitle: 'Check application status',
          icon: Icons.timeline,
          color: AppColors.info,
          onTap: onStatusTracking!,
        ),
      if (onDocumentUpload != null)
        QuickAction(
          title: 'Upload Documents',
          subtitle: 'Submit required documents',
          icon: Icons.upload_file,
          color: AppColors.warning,
          onTap: onDocumentUpload!,
        ),
      if (onRenewal != null)
        QuickAction(
          title: 'Renewal',
          subtitle: 'Renew license or registration',
          icon: Icons.refresh,
          color: AppColors.secondary,
          onTap: onRenewal!,
        ),
      if (onPayment != null)
        QuickAction(
          title: 'Make Payment',
          subtitle: 'Pay fees and charges',
          icon: Icons.payment,
          color: AppColors.error,
          onTap: onPayment!,
        ),
    ];

    return showAll ? allActions : allActions.take(4).toList();
  }
}

/// Quick actions layout enumeration
enum QuickActionsLayout {
  grid,
  list,
  horizontal,
  compact,
}

/// Quick action data class
class QuickAction {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const QuickAction({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}
