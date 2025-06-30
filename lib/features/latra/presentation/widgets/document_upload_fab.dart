import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_document.dart';
import '../providers/latra_form_providers.dart';
import '../providers/latra_state_providers.dart';

/// Document Upload FAB widget for uploading documents
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class DocumentUploadFAB extends ConsumerWidget {
  final String? applicationId;
  final VoidCallback? onUploadSuccess;

  const DocumentUploadFAB({
    super.key,
    this.applicationId,
    this.onUploadSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentState = ref.watch(latraDocumentNotifierProvider);

    return FloatingActionButton.extended(
      onPressed: documentState.isUploading 
          ? null 
          : () => _showUploadBottomSheet(context, ref),
      backgroundColor: documentState.isUploading 
          ? AppColors.textSecondary 
          : AppColors.primary,
      foregroundColor: Colors.white,
      icon: documentState.isUploading
          ? SizedBox(
              width: 20.w,
              height: 20.w,
              child: const CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Icon(Icons.upload_file),
      label: Text(
        documentState.isUploading ? 'Uploading...' : 'Upload Document',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _showUploadBottomSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DocumentUploadBottomSheet(
        applicationId: applicationId,
        onUploadSuccess: onUploadSuccess,
      ),
    );
  }
}

/// Document Upload Bottom Sheet widget
class DocumentUploadBottomSheet extends ConsumerStatefulWidget {
  final String? applicationId;
  final VoidCallback? onUploadSuccess;

  const DocumentUploadBottomSheet({
    super.key,
    this.applicationId,
    this.onUploadSuccess,
  });

  @override
  ConsumerState<DocumentUploadBottomSheet> createState() => _DocumentUploadBottomSheetState();
}

class _DocumentUploadBottomSheetState extends ConsumerState<DocumentUploadBottomSheet> {
  LATRADocumentType? _selectedType;
  String _title = '';
  String _description = '';
  String? _selectedFilePath;

  @override
  Widget build(BuildContext context) {
    final documentState = ref.watch(latraDocumentNotifierProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.symmetric(vertical: 12.h),
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Text(
                  'Upload Document',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.close, color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          
          Divider(color: AppColors.border),
          
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Document type selection
                  Text(
                    'Document Type',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildDocumentTypeSelector(),
                  
                  SizedBox(height: 24.h),
                  
                  // Title field
                  Text(
                    'Document Title',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    onChanged: (value) => setState(() => _title = value),
                    decoration: InputDecoration(
                      hintText: 'Enter document title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 16.h),
                  
                  // Description field
                  Text(
                    'Description (Optional)',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextFormField(
                    onChanged: (value) => setState(() => _description = value),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Enter document description',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  
                  SizedBox(height: 24.h),
                  
                  // File selection
                  Text(
                    'Select File',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  _buildFileSelector(),
                  
                  SizedBox(height: 32.h),
                  
                  // Upload progress
                  if (documentState.isUploading) ...[
                    Text(
                      'Upload Progress',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    LinearProgressIndicator(
                      value: documentState.uploadProgress,
                      backgroundColor: AppColors.border,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      '${(documentState.uploadProgress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                  
                  // Upload button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _canUpload() && !documentState.isUploading
                          ? () => _uploadDocument()
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Text(
                        documentState.isUploading ? 'Uploading...' : 'Upload Document',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentTypeSelector() {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: LATRADocumentType.values.map((type) {
        final isSelected = _selectedType == type;
        return FilterChip(
          label: Text(
            type.displayName,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.primary,
            ),
          ),
          selected: isSelected,
          onSelected: (selected) {
            setState(() {
              _selectedType = selected ? type : null;
              if (selected) {
                _title = type.displayName;
              }
            });
          },
          backgroundColor: Colors.white,
          selectedColor: AppColors.primary,
          checkmarkColor: Colors.white,
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFileSelector() {
    return InkWell(
      onTap: () => _selectFile(),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border, style: BorderStyle.solid),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(
              _selectedFilePath != null ? Icons.description : Icons.upload_file,
              color: AppColors.primary,
              size: 48.w,
            ),
            SizedBox(height: 12.h),
            Text(
              _selectedFilePath != null 
                  ? _selectedFilePath!.split('/').last
                  : 'Tap to select file',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: _selectedFilePath != null 
                    ? AppColors.textPrimary 
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_selectedFilePath == null) ...[
              SizedBox(height: 4.h),
              Text(
                'Supported formats: PDF, JPG, PNG (Max 10MB)',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _selectFile() {
    // Simulate file selection
    setState(() {
      _selectedFilePath = '/storage/emulated/0/Documents/sample_document.pdf';
    });
  }

  bool _canUpload() {
    return _selectedType != null && 
           _title.isNotEmpty && 
           _selectedFilePath != null;
  }

  Future<void> _uploadDocument() async {
    if (!_canUpload() || widget.applicationId == null) return;

    final success = await ref.read(latraDocumentNotifierProvider.notifier)
        .uploadDocument(
          applicationId: widget.applicationId!,
          filePath: _selectedFilePath!,
          type: _selectedType!,
          title: _title,
          description: _description.isNotEmpty ? _description : null,
        );

    if (success) {
      Navigator.of(context).pop();
      widget.onUploadSuccess?.call();
      _showSuccessSnackBar('Document uploaded successfully');
    } else {
      _showErrorSnackBar('Failed to upload document');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
