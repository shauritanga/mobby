import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_application.dart';

/// Application Summary Card widget for displaying LATRA application overview
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class ApplicationSummaryCard extends StatelessWidget {
  final LATRAApplication application;
  final VoidCallback? onTap;
  final VoidCallback? onTrackStatus;
  final VoidCallback? onViewDocuments;
  final bool showActions;
  final bool compact;

  const ApplicationSummaryCard({
    super.key,
    required this.application,
    this.onTap,
    this.onTrackStatus,
    this.onViewDocuments,
    this.showActions = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.getStatusColor(application.status.name);

    return Container(
      margin: EdgeInsets.only(bottom: compact ? 8.h : 16.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(compact ? 12.w : 16.w),
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
                  // Application type icon
                  Container(
                    width: compact ? 36.w : 48.w,
                    height: compact ? 36.w : 48.w,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getApplicationIcon(application.type),
                      color: statusColor,
                      size: compact ? 18.w : 24.w,
                    ),
                  ),
                  SizedBox(width: 12.w),

                  // Application info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          application.title,
                          style: TextStyle(
                            fontSize: compact ? 14.sp : 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'App #${application.applicationNumber}',
                          style: TextStyle(
                            fontSize: compact ? 11.sp : 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Status badge
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 6.w : 8.w,
                      vertical: compact ? 3.h : 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(compact ? 8.r : 12.r),
                    ),
                    child: Text(
                      application.status.displayName,
                      style: TextStyle(
                        fontSize: compact ? 9.sp : 10.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              if (!compact) ...[
                SizedBox(height: 12.h),

                // Application details
                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Type',
                        application.type.displayName,
                        Icons.category,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Submitted',
                        _formatDate(application.submissionDate),
                        Icons.calendar_today,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 8.h),

                Row(
                  children: [
                    Expanded(
                      child: _buildDetailItem(
                        'Fee',
                        _formatCurrency(application.applicationFee),
                        Icons.payment,
                      ),
                    ),
                    Expanded(
                      child: _buildDetailItem(
                        'Progress',
                        '${_getProgressPercentage()}%',
                        Icons.trending_up,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Progress bar
                _buildProgressBar(),
              ],

              // Action buttons
              if (showActions && !compact) ...[
                SizedBox(height: 16.h),
                Row(
                  children: [
                    if (onTrackStatus != null)
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: onTrackStatus,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: statusColor,
                            side: BorderSide(color: statusColor),
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          icon: Icon(Icons.timeline, size: 16.w),
                          label: Text(
                            'Track Status',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      ),

                    if (onTrackStatus != null && onViewDocuments != null)
                      SizedBox(width: 8.w),

                    if (onViewDocuments != null)
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: onViewDocuments,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: statusColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          icon: Icon(Icons.description, size: 16.w),
                          label: Text(
                            'Documents',
                            style: TextStyle(fontSize: 12.sp),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14.w, color: AppColors.textSecondary),
        SizedBox(width: 4.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    final progress = _getProgress();
    final statusColor = AppColors.getStatusColor(application.status.name);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              '${_getProgressPercentage()}%',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Container(
          width: double.infinity,
          height: 6.h,
          decoration: BoxDecoration(
            color: AppColors.border,
            borderRadius: BorderRadius.circular(3.r),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(3.r),
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

  double _getProgress() {
    switch (application.status) {
      case LATRAApplicationStatus.draft:
        return 0.1;
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
      case LATRAApplicationStatus.submitted:
        return 0.2;
      case LATRAApplicationStatus.cancelled:
        return 0.2;
    }
  }

  int _getProgressPercentage() {
    return (_getProgress() * 100).toInt();
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';

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

    return '${date.day} ${months[date.month - 1]}';
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
