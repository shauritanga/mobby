import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_status.dart';

/// Notification Banner widget for urgent status updates
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class NotificationBanner extends StatelessWidget {
  final LATRAStatus status;
  final VoidCallback? onActionTap;
  final VoidCallback? onDismiss;

  const NotificationBanner({
    super.key,
    required this.status,
    this.onActionTap,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final bannerData = _getBannerData();
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: bannerData.backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: bannerData.borderColor),
        boxShadow: [
          BoxShadow(
            color: bannerData.shadowColor,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and dismiss button
          Row(
            children: [
              Icon(
                bannerData.icon,
                color: bannerData.iconColor,
                size: 24.w,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  bannerData.title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: bannerData.textColor,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  onPressed: onDismiss,
                  icon: Icon(
                    Icons.close,
                    color: bannerData.textColor.withOpacity(0.7),
                    size: 20.w,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(
                    minWidth: 24.w,
                    minHeight: 24.w,
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          // Message
          Text(
            bannerData.message,
            style: TextStyle(
              fontSize: 14.sp,
              color: bannerData.textColor.withOpacity(0.9),
            ),
          ),
          
          // Action button
          if (onActionTap != null && bannerData.actionText != null) ...[
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onActionTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: bannerData.actionButtonColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  bannerData.actionText!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
          
          // Deadline info
          if (bannerData.deadline != null) ...[
            SizedBox(height: 12.h),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: bannerData.textColor,
                    size: 16.w,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'Deadline: ${_formatDate(bannerData.deadline!)}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: bannerData.textColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  NotificationBannerData _getBannerData() {
    switch (status.type) {
      case LATRAStatusType.documentsRequired:
        return NotificationBannerData(
          title: 'Documents Required',
          message: 'Your application needs additional documents to proceed. Please upload the required documents as soon as possible.',
          icon: Icons.upload_file,
          backgroundColor: AppColors.warning.withOpacity(0.1),
          borderColor: AppColors.warning,
          iconColor: AppColors.warning,
          textColor: AppColors.warning,
          shadowColor: AppColors.warning.withOpacity(0.2),
          actionText: 'Upload Documents',
          actionButtonColor: AppColors.warning,
          deadline: DateTime.now().add(const Duration(days: 7)),
        );
      
      case LATRAStatusType.paymentRequired:
        return NotificationBannerData(
          title: 'Payment Required',
          message: 'Complete your payment to continue processing your application. Multiple payment methods are available.',
          icon: Icons.payment,
          backgroundColor: AppColors.error.withOpacity(0.1),
          borderColor: AppColors.error,
          iconColor: AppColors.error,
          textColor: AppColors.error,
          shadowColor: AppColors.error.withOpacity(0.2),
          actionText: 'Make Payment',
          actionButtonColor: AppColors.error,
          deadline: DateTime.now().add(const Duration(days: 14)),
        );
      
      case LATRAStatusType.appointmentRequired:
        return NotificationBannerData(
          title: 'Appointment Required',
          message: 'Schedule your appointment for document verification or practical test. Book your preferred time slot.',
          icon: Icons.event,
          backgroundColor: AppColors.info.withOpacity(0.1),
          borderColor: AppColors.info,
          iconColor: AppColors.info,
          textColor: AppColors.info,
          shadowColor: AppColors.info.withOpacity(0.2),
          actionText: 'Book Appointment',
          actionButtonColor: AppColors.info,
        );
      
      case LATRAStatusType.approved:
        return NotificationBannerData(
          title: 'Application Approved!',
          message: 'Congratulations! Your application has been approved. You can now collect your certificate.',
          icon: Icons.check_circle,
          backgroundColor: AppColors.success.withOpacity(0.1),
          borderColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.success,
          shadowColor: AppColors.success.withOpacity(0.2),
          actionText: 'View Certificate',
          actionButtonColor: AppColors.success,
        );
      
      case LATRAStatusType.rejected:
        return NotificationBannerData(
          title: 'Application Rejected',
          message: 'Your application was not approved. Please review the feedback and consider resubmitting.',
          icon: Icons.cancel,
          backgroundColor: AppColors.error.withOpacity(0.1),
          borderColor: AppColors.error,
          iconColor: AppColors.error,
          textColor: AppColors.error,
          shadowColor: AppColors.error.withOpacity(0.2),
          actionText: 'View Details',
          actionButtonColor: AppColors.error,
        );
      
      case LATRAStatusType.processed:
        return NotificationBannerData(
          title: 'Ready for Collection',
          message: 'Your certificate is ready! Visit the LATRA office during business hours to collect it.',
          icon: Icons.done_all,
          backgroundColor: AppColors.success.withOpacity(0.1),
          borderColor: AppColors.success,
          iconColor: AppColors.success,
          textColor: AppColors.success,
          shadowColor: AppColors.success.withOpacity(0.2),
          actionText: 'Get Directions',
          actionButtonColor: AppColors.success,
        );
      
      default:
        return NotificationBannerData(
          title: 'Status Update',
          message: status.description,
          icon: Icons.info,
          backgroundColor: AppColors.primary.withOpacity(0.1),
          borderColor: AppColors.primary,
          iconColor: AppColors.primary,
          textColor: AppColors.primary,
          shadowColor: AppColors.primary.withOpacity(0.2),
        );
    }
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

/// Notification banner data class
class NotificationBannerData {
  final String title;
  final String message;
  final IconData icon;
  final Color backgroundColor;
  final Color borderColor;
  final Color iconColor;
  final Color textColor;
  final Color shadowColor;
  final String? actionText;
  final Color? actionButtonColor;
  final DateTime? deadline;

  const NotificationBannerData({
    required this.title,
    required this.message,
    required this.icon,
    required this.backgroundColor,
    required this.borderColor,
    required this.iconColor,
    required this.textColor,
    required this.shadowColor,
    this.actionText,
    this.actionButtonColor,
    this.deadline,
  });
}
