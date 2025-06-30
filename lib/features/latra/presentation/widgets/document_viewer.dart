import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_document.dart';

/// Document Viewer widget for displaying and interacting with LATRA documents
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class DocumentViewer extends StatelessWidget {
  final LATRADocument document;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final VoidCallback? onDelete;
  final VoidCallback? onRenew;
  final bool showActions;
  final DocumentViewerMode mode;

  const DocumentViewer({
    super.key,
    required this.document,
    this.onDownload,
    this.onShare,
    this.onDelete,
    this.onRenew,
    this.showActions = true,
    this.mode = DocumentViewerMode.card,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case DocumentViewerMode.card:
        return _buildCardView();
      case DocumentViewerMode.list:
        return _buildListView();
      case DocumentViewerMode.grid:
        return _buildGridView();
      case DocumentViewerMode.detailed:
        return _buildDetailedView();
    }
  }

  Widget _buildCardView() {
    final statusColor = AppColors.getDocumentStatusColor(document.status.name);
    final isExpired = document.isExpired;
    final expiresSoon = document.expiresSoon;

    return Container(
      width: double.infinity,
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
          // Header
          Row(
            children: [
              _buildDocumentIcon(),
              SizedBox(width: 12.w),
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      document.type.displayName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _buildStatusBadge(),
            ],
          ),

          SizedBox(height: 16.h),

          // Document info
          _buildDocumentInfo(),

          // Expiry warning
          if (isExpired || expiresSoon) ...[
            SizedBox(height: 12.h),
            _buildExpiryWarning(isExpired),
          ],

          // Actions
          if (showActions) ...[SizedBox(height: 16.h), _buildActionButtons()],
        ],
      ),
    );
  }

  Widget _buildListView() {
    final statusColor = AppColors.getDocumentStatusColor(document.status.name);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          _buildDocumentIcon(size: 32.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Text(
                  document.type.displayName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _buildStatusBadge(compact: true),
          if (showActions) ...[
            SizedBox(width: 8.w),
            IconButton(
              onPressed: onDownload,
              icon: Icon(Icons.download, color: AppColors.primary, size: 20.w),
              padding: EdgeInsets.zero,
              constraints: BoxConstraints(minWidth: 32.w, minHeight: 32.w),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGridView() {
    final statusColor = AppColors.getDocumentStatusColor(document.status.name);

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _buildDocumentIcon(size: 40.w),
          SizedBox(height: 8.h),
          Text(
            document.title,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 4.h),
          _buildStatusBadge(compact: true),
        ],
      ),
    );
  }

  Widget _buildDetailedView() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              _buildDocumentIcon(size: 56.w),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      document.title,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
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
              _buildStatusBadge(),
            ],
          ),

          SizedBox(height: 24.h),

          // Detailed info
          _buildDetailedInfo(),

          // Verification notes
          if (document.verificationNotes != null &&
              document.verificationNotes!.isNotEmpty) ...[
            SizedBox(height: 20.h),
            _buildVerificationNotes(),
          ],

          // Actions
          if (showActions) ...[
            SizedBox(height: 24.h),
            _buildDetailedActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildDocumentIcon({double? size}) {
    final iconSize = size ?? 48.w;
    final statusColor = AppColors.getDocumentStatusColor(document.status.name);

    return Container(
      width: iconSize,
      height: iconSize,
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Icon(
        _getDocumentIcon(document.type),
        color: statusColor,
        size: iconSize * 0.5,
      ),
    );
  }

  Widget _buildStatusBadge({bool compact = false}) {
    final statusColor = AppColors.getDocumentStatusColor(document.status.name);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6.w : 8.w,
        vertical: compact ? 2.h : 4.h,
      ),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(compact ? 8.r : 12.r),
      ),
      child: Text(
        document.status.displayName,
        style: TextStyle(
          fontSize: compact ? 9.sp : 10.sp,
          fontWeight: FontWeight.w600,
          color: statusColor,
        ),
      ),
    );
  }

  Widget _buildDocumentInfo() {
    return Column(
      children: [
        _buildInfoRow('File Name', document.fileName),
        SizedBox(height: 8.h),
        _buildInfoRow('File Size', _formatFileSize(document.fileSize)),
        SizedBox(height: 8.h),
        _buildInfoRow('Uploaded', _formatDate(document.createdAt)),
        if (document.expiryDate != null) ...[
          SizedBox(height: 8.h),
          _buildInfoRow(
            'Expires',
            _formatDate(document.expiryDate!),
            valueColor: document.isExpired
                ? AppColors.error
                : document.expiresSoon
                ? AppColors.warning
                : null,
          ),
        ],
      ],
    );
  }

  Widget _buildDetailedInfo() {
    return Column(
      children: [
        _buildDetailedInfoRow(
          'File Name',
          document.fileName,
          Icons.description,
        ),
        _buildDetailedInfoRow(
          'File Size',
          _formatFileSize(document.fileSize),
          Icons.storage,
        ),
        _buildDetailedInfoRow(
          'Uploaded',
          _formatDate(document.createdAt),
          Icons.upload,
        ),
        if (document.verificationDate != null)
          _buildDetailedInfoRow(
            'Verified',
            _formatDate(document.verificationDate!),
            Icons.verified,
          ),
        if (document.expiryDate != null)
          _buildDetailedInfoRow(
            'Expires',
            _formatDate(document.expiryDate!),
            Icons.schedule,
            valueColor: document.isExpired
                ? AppColors.error
                : document.expiresSoon
                ? AppColors.warning
                : null,
          ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
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

  Widget _buildDetailedInfoRow(
    String label,
    String value,
    IconData icon, {
    Color? valueColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 20.w),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: valueColor ?? AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExpiryWarning(bool isExpired) {
    final color = isExpired ? AppColors.error : AppColors.warning;
    final message = isExpired
        ? 'This document has expired'
        : 'This document expires soon';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(
            isExpired ? Icons.error : Icons.warning,
            color: color,
            size: 20.w,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationNotes() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.info.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.note, color: AppColors.info, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'Verification Notes',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.info,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            document.verificationNotes!,
            style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
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
              label: Text('Download', style: TextStyle(fontSize: 12.sp)),
            ),
          ),

        if (onDownload != null && (onRenew != null || onDelete != null))
          SizedBox(width: 8.w),

        if (onRenew != null && (document.isExpired || document.expiresSoon))
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
      ],
    );
  }

  Widget _buildDetailedActionButtons() {
    return Row(
      children: [
        if (onDownload != null)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onDownload,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              icon: Icon(Icons.download, size: 18.w),
              label: Text('Download', style: TextStyle(fontSize: 14.sp)),
            ),
          ),

        if (onDownload != null && onShare != null) SizedBox(width: 12.w),

        if (onShare != null)
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onShare,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primary,
                side: BorderSide(color: AppColors.primary),
                padding: EdgeInsets.symmetric(vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              icon: Icon(Icons.share, size: 18.w),
              label: Text('Share', style: TextStyle(fontSize: 14.sp)),
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

/// Document viewer mode enumeration
enum DocumentViewerMode { card, list, grid, detailed }
