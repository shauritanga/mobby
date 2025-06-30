import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../latra/domain/entities/latra_document.dart';
import '../../domain/entities/verification_status.dart';

class DocumentListItem extends StatelessWidget {
  final LATRADocument document;
  final VoidCallback onTap;
  final Function(VerificationResult result, String? notes, List<String> issues)
  onVerify;
  final VoidCallback onViewHistory;

  const DocumentListItem({
    super.key,
    required this.document,
    required this.onTap,
    required this.onVerify,
    required this.onViewHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Icon(
                    _getDocumentIcon(),
                    size: 24.r,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          document.fileName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          document.type.displayName,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusBadge(context),
                ],
              ),

              SizedBox(height: 16.h),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showVerifyDialog(context),
                      icon: const Icon(Icons.verified, size: 16),
                      label: const Text('Verify'),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onViewHistory,
                      icon: const Icon(Icons.history, size: 16),
                      label: const Text('History'),
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

  IconData _getDocumentIcon() {
    switch (document.type) {
      case LATRADocumentType.nationalId:
        return Icons.badge;
      case LATRADocumentType.drivingLicense:
        return Icons.credit_card;
      case LATRADocumentType.vehicleRegistration:
        return Icons.directions_car;
      case LATRADocumentType.insurance:
        return Icons.security;
      case LATRADocumentType.inspection:
        return Icons.fact_check;
      case LATRADocumentType.medicalCertificate:
        return Icons.local_hospital;
      case LATRADocumentType.passportPhoto:
        return Icons.photo_camera;
      case LATRADocumentType.proofOfResidence:
        return Icons.home;
      case LATRADocumentType.ownershipTransfer:
        return Icons.swap_horiz;
      case LATRADocumentType.powerOfAttorney:
        return Icons.gavel;
      case LATRADocumentType.taxClearance:
        return Icons.receipt_long;
      case LATRADocumentType.importPermit:
        return Icons.import_export;
      case LATRADocumentType.purchaseReceipt:
        return Icons.receipt;
      case LATRADocumentType.insuranceCertificate:
        return Icons.security;
      case LATRADocumentType.inspectionCertificate:
        return Icons.fact_check;
      case LATRADocumentType.other:
        return Icons.description;
    }
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (document.status) {
      case LATRADocumentStatus.pending:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        break;
      case LATRADocumentStatus.uploaded:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        break;
      case LATRADocumentStatus.verified:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        break;
      case LATRADocumentStatus.rejected:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
      case LATRADocumentStatus.expired:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        document.status.displayName,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  void _showVerifyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verify Document'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: Colors.green),
              title: const Text('Approve'),
              onTap: () {
                Navigator.of(context).pop();
                onVerify(VerificationResult.approved, null, []);
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel, color: Colors.red),
              title: const Text('Reject'),
              onTap: () {
                Navigator.of(context).pop();
                onVerify(VerificationResult.rejected, null, []);
              },
            ),
            ListTile(
              leading: const Icon(Icons.pending, color: Colors.orange),
              title: const Text('Requires Review'),
              onTap: () {
                Navigator.of(context).pop();
                onVerify(VerificationResult.requiresReview, null, []);
              },
            ),
          ],
        ),
      ),
    );
  }
}
