import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_application.dart';
import '../../domain/entities/latra_status.dart';

/// Application Status Card widget for displaying application overview
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class ApplicationStatusCard extends StatelessWidget {
  final LATRAApplication application;
  final LATRAStatus? latestStatus;
  final VoidCallback? onViewDetails;

  const ApplicationStatusCard({
    super.key,
    required this.application,
    this.latestStatus,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.getStatusColor(application.status.name).withOpacity(0.1),
            AppColors.getStatusColor(application.status.name).withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: AppColors.getStatusColor(
            application.status.name,
          ).withOpacity(0.3),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              // Application icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.getStatusColor(application.status.name),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getApplicationIcon(application.type),
                  color: Colors.white,
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.title,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Application #${application.applicationNumber}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Status badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.getStatusColor(application.status.name),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  application.status.displayName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Application details
          _buildDetailRow('Type', application.type.displayName),
          SizedBox(height: 8.h),
          _buildDetailRow('Submitted', _formatDate(application.submissionDate)),
          SizedBox(height: 8.h),
          _buildDetailRow('Fee', _formatCurrency(application.applicationFee)),

          if (latestStatus != null) ...[
            SizedBox(height: 8.h),
            _buildDetailRow(
              'Last Update',
              _formatDate(latestStatus!.timestamp),
            ),
          ],

          SizedBox(height: 20.h),

          // Progress indicator
          _buildProgressIndicator(),

          SizedBox(height: 20.h),

          // Latest status message
          if (latestStatus != null) ...[
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Latest Update',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    latestStatus!.description,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // Action buttons
          Row(
            children: [
              if (onViewDetails != null)
                Expanded(
                  child: OutlinedButton(
                    onPressed: onViewDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.getStatusColor(
                        application.status.name,
                      ),
                      side: BorderSide(
                        color: AppColors.getStatusColor(
                          application.status.name,
                        ),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      'View Details',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

              if (onViewDetails != null && _canTakeAction()) ...[
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handlePrimaryAction(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.getStatusColor(
                        application.status.name,
                      ),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: Text(
                      _getPrimaryActionText(),
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final progress = _getApplicationProgress();
    final progressColor = AppColors.getStatusColor(application.status.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: progressColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: 8.h,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getApplicationIcon(LATRAApplicationType type) {
    switch (type) {
      case LATRAApplicationType.vehicleRegistration:
        return Icons.app_registration;
      case LATRAApplicationType.licenseRenewal:
        return Icons.refresh;
      case LATRAApplicationType.ownershipTransfer:
        return Icons.swap_horiz;
      case LATRAApplicationType.duplicateRegistration:
        return Icons.content_copy;
      case LATRAApplicationType.temporaryPermit:
        return Icons.schedule;
    }
  }

  double _getApplicationProgress() {
    switch (application.status) {
      case LATRAApplicationStatus.draft:
        return 0.1;
      case LATRAApplicationStatus.submitted:
        return 0.2;
      case LATRAApplicationStatus.pending:
        return 0.3;
      case LATRAApplicationStatus.underReview:
        return 0.5;
      case LATRAApplicationStatus.documentsRequired:
        return 0.4;
      case LATRAApplicationStatus.approved:
        return 0.9;
      case LATRAApplicationStatus.completed:
        return 1.0;
      case LATRAApplicationStatus.rejected:
        return 0.8;
      case LATRAApplicationStatus.cancelled:
        return 0.2;
    }
  }

  bool _canTakeAction() {
    return application.status == LATRAApplicationStatus.documentsRequired ||
        application.status == LATRAApplicationStatus.pending ||
        application.status == LATRAApplicationStatus.draft;
  }

  String _getPrimaryActionText() {
    switch (application.status) {
      case LATRAApplicationStatus.draft:
        return 'Complete Application';
      case LATRAApplicationStatus.documentsRequired:
        return 'Upload Documents';
      case LATRAApplicationStatus.pending:
        return 'Track Progress';
      default:
        return 'View Status';
    }
  }

  void _handlePrimaryAction() {
    // Handle primary action based on status
    switch (application.status) {
      case LATRAApplicationStatus.draft:
        // Navigate to complete application
        break;
      case LATRAApplicationStatus.documentsRequired:
        // Navigate to document upload
        break;
      case LATRAApplicationStatus.pending:
        // Show tracking details
        break;
      default:
        break;
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Not available';

    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return 'TZS ${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return 'TZS ${(amount / 1000).toStringAsFixed(0)}K';
    } else {
      return 'TZS ${amount.toStringAsFixed(0)}';
    }
  }
}
