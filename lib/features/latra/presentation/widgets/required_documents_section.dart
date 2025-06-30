import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';

/// Required Documents Section widget for LATRA registration
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class RequiredDocumentsSection extends ConsumerWidget {
  final List<String> requiredDocuments;
  final List<String> uploadedDocuments;
  final Function(String) onDocumentUploaded;
  final Function(String) onDocumentRemoved;
  final String? error;

  const RequiredDocumentsSection({
    super.key,
    required this.requiredDocuments,
    required this.uploadedDocuments,
    required this.onDocumentUploaded,
    required this.onDocumentRemoved,
    this.error,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Documents',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Upload all required documents for your application',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 16.h),
        
        if (requiredDocuments.isEmpty)
          _buildEmptyState()
        else
          _buildDocumentsList(),

        if (error != null) ...[
          SizedBox(height: 8.h),
          Text(
            error!,
            style: TextStyle(
              color: AppColors.error,
              fontSize: 12.sp,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.description_outlined,
            color: AppColors.textSecondary,
            size: 48.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Documents Required',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Select an application type to see required documents',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    return Column(
      children: requiredDocuments.map((document) {
        final isUploaded = uploadedDocuments.contains(document);
        return _buildDocumentItem(document, isUploaded);
      }).toList(),
    );
  }

  Widget _buildDocumentItem(String document, bool isUploaded) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isUploaded 
              ? AppColors.success.withOpacity(0.1) 
              : Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isUploaded ? AppColors.success : AppColors.border,
            width: isUploaded ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Document Icon
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: isUploaded 
                    ? AppColors.success 
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                isUploaded ? Icons.check_circle : Icons.description,
                color: isUploaded ? Colors.white : AppColors.primary,
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            
            // Document Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: isUploaded 
                          ? AppColors.success 
                          : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    isUploaded 
                        ? 'Document uploaded successfully'
                        : 'Required for application',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: isUploaded 
                          ? AppColors.success 
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Action Button
            if (isUploaded)
              IconButton(
                onPressed: () => onDocumentRemoved(document),
                icon: Icon(
                  Icons.delete_outline,
                  color: AppColors.error,
                  size: 20.w,
                ),
                tooltip: 'Remove document',
              )
            else
              ElevatedButton(
                onPressed: () => _showDocumentUploadDialog(document),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  minimumSize: Size(80.w, 36.h),
                ),
                child: Text(
                  'Upload',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showDocumentUploadDialog(String documentType) {
    // This would show a document upload dialog
    // For now, simulate upload
    Future.delayed(const Duration(seconds: 1), () {
      onDocumentUploaded(documentType);
    });
  }
}
