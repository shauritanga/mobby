import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_document.dart';

/// Document Card widget for displaying LATRA document information
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class DocumentCard extends StatelessWidget {
  final LATRADocument document;
  final VoidCallback? onTap;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;
  final VoidCallback? onRenew;
  final bool showExpiryWarning;

  const DocumentCard({
    super.key,
    required this.document,
    this.onTap,
    this.onDownload,
    this.onDelete,
    this.onRenew,
    this.showExpiryWarning = false,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = AppColors.getDocumentStatusColor(document.status.name);
    final isExpired = document.isExpired;
    final expiresSoon = document.expiresSoon;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isExpired
                  ? AppColors.error
                  : expiresSoon
                  ? AppColors.warning
                  : AppColors.border,
              width: isExpired || expiresSoon ? 2 : 1,
            ),
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
              // Header with document type and status
              Row(
                children: [
                  // Document type icon
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getDocumentIcon(document.type),
                      color: statusColor,
                      size: 24.w,
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // Document info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.title,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          document.type.displayName,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      document.status.displayName,
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Document details
              _buildDetailRow('File Name', document.fileName),
              SizedBox(height: 8.h),
              _buildDetailRow('File Size', _formatFileSize(document.fileSize)),
              SizedBox(height: 8.h),
              _buildDetailRow('Uploaded', _formatDate(document.createdAt)),

              if (document.verificationDate != null) ...[
                SizedBox(height: 8.h),
                _buildDetailRow(
                  'Verified',
                  _formatDate(document.verificationDate!),
                ),
              ],

              if (document.expiryDate != null) ...[
                SizedBox(height: 8.h),
                _buildDetailRow(
                  'Expires',
                  _formatDate(document.expiryDate!),
                  valueColor: isExpired
                      ? AppColors.error
                      : expiresSoon
                      ? AppColors.warning
                      : null,
                ),
              ],

              // Expiry warning
              if (showExpiryWarning && (isExpired || expiresSoon)) ...[
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: (isExpired ? AppColors.error : AppColors.warning)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(
                      color: isExpired ? AppColors.error : AppColors.warning,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isExpired ? Icons.error : Icons.warning,
                        color: isExpired ? AppColors.error : AppColors.warning,
                        size: 20.w,
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          isExpired
                              ? 'This document has expired'
                              : 'This document expires soon',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: isExpired
                                ? AppColors.error
                                : AppColors.warning,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Verification notes
              if (document.verificationNotes != null &&
                  document.verificationNotes!.isNotEmpty) ...[
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Verification Notes',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        document.verificationNotes!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 16.h),

              // Action buttons
              Row(
                children: [
                  if (onDownload != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDownload,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: BorderSide(color: AppColors.primary),
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        icon: Icon(Icons.download, size: 16.w),
                        label: Text(
                          'Download',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    ),

                  if (onDownload != null &&
                      (onRenew != null || onDelete != null))
                    SizedBox(width: 8.w),

                  if (onRenew != null && (isExpired || expiresSoon))
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onRenew,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.warning,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        icon: Icon(Icons.refresh, size: 16.w),
                        label: Text('Renew', style: TextStyle(fontSize: 12.sp)),
                      ),
                    ),

                  if (onDelete != null && !(isExpired || expiresSoon))
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDelete,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: BorderSide(color: AppColors.error),
                          padding: EdgeInsets.symmetric(vertical: 8.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        icon: Icon(Icons.delete_outline, size: 16.w),
                        label: Text(
                          'Delete',
                          style: TextStyle(fontSize: 12.sp),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  IconData _getDocumentIcon(LATRADocumentType type) {
    switch (type) {
      case LATRADocumentType.nationalId:
        return Icons.badge;
      case LATRADocumentType.drivingLicense:
        return Icons.credit_card;
      case LATRADocumentType.vehicleRegistration:
        return Icons.app_registration;
      case LATRADocumentType.insuranceCertificate:
        return Icons.security;
      case LATRADocumentType.inspectionCertificate:
        return Icons.verified;
      case LATRADocumentType.purchaseReceipt:
        return Icons.receipt;
      case LATRADocumentType.importPermit:
        return Icons.import_export;
      case LATRADocumentType.taxClearance:
        return Icons.receipt_long;
      case LATRADocumentType.ownershipTransfer:
        return Icons.swap_horiz;
      case LATRADocumentType.powerOfAttorney:
        return Icons.gavel;
      case LATRADocumentType.insurance:
        return Icons.security;
      case LATRADocumentType.inspection:
        return Icons.verified;
      case LATRADocumentType.medicalCertificate:
        return Icons.medical_services;
      case LATRADocumentType.passportPhoto:
        return Icons.photo_camera;
      case LATRADocumentType.proofOfResidence:
        return Icons.home;
      case LATRADocumentType.other:
        return Icons.description;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
  }

  String _formatDate(DateTime date) {
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
}
