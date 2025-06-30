import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:io';

/// Profile image picker widget for profile picture management
/// Following specifications from FEATURES_DOCUMENTATION.md
class ProfileImagePicker extends StatelessWidget {
  final String? currentImageUrl;
  final String? selectedImagePath;
  final Function(String) onImageSelected;
  final VoidCallback onImageRemoved;

  const ProfileImagePicker({
    super.key,
    this.currentImageUrl,
    this.selectedImagePath,
    required this.onImageSelected,
    required this.onImageRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Profile Picture
        Stack(
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).primaryColor,
                  width: 3.w,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildProfileImage(context),
              ),
            ),
            
            // Edit Button
            Positioned(
              bottom: 0,
              right: 0,
              child: GestureDetector(
                onTap: () => _showImageOptions(context),
                child: Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white,
                      width: 2.w,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    size: 18.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
        
        SizedBox(height: 16.h),
        
        // Image Actions
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => _showImageOptions(context),
              icon: const Icon(Icons.edit),
              label: const Text('Change Photo'),
            ),
            
            if (currentImageUrl != null || selectedImagePath != null) ...[
              SizedBox(width: 16.w),
              TextButton.icon(
                onPressed: () => _confirmRemoveImage(context),
                icon: const Icon(Icons.delete, color: Colors.red),
                label: const Text(
                  'Remove Photo',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildProfileImage(BuildContext context) {
    // Show selected image if available
    if (selectedImagePath != null) {
      return Image.file(
        File(selectedImagePath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(context),
      );
    }
    
    // Show current image if available
    if (currentImageUrl?.isNotEmpty == true) {
      return CachedNetworkImage(
        imageUrl: currentImageUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => _buildDefaultAvatar(context),
      );
    }
    
    // Show default avatar
    return _buildDefaultAvatar(context);
  }

  Widget _buildDefaultAvatar(BuildContext context) {
    return Container(
      color: Theme.of(context).primaryColor.withOpacity(0.1),
      child: Icon(
        Icons.person,
        size: 60.sp,
        color: Theme.of(context).primaryColor,
      ),
    );
  }

  void _showImageOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              Text(
                'Change Profile Photo',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Camera Option
              ListTile(
                leading: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.blue,
                    size: 20.sp,
                  ),
                ),
                title: const Text('Take Photo'),
                subtitle: const Text('Use camera to take a new photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takePhoto();
                },
              ),
              
              // Gallery Option
              ListTile(
                leading: Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    Icons.photo_library,
                    color: Colors.green,
                    size: 20.sp,
                  ),
                ),
                title: const Text('Choose from Gallery'),
                subtitle: const Text('Select a photo from your gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickFromGallery();
                },
              ),
              
              // Remove Option (if image exists)
              if (currentImageUrl != null || selectedImagePath != null)
                ListTile(
                  leading: Container(
                    width: 40.w,
                    height: 40.w,
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.delete,
                      color: Colors.red,
                      size: 20.sp,
                    ),
                  ),
                  title: const Text('Remove Photo'),
                  subtitle: const Text('Remove current profile photo'),
                  onTap: () {
                    Navigator.pop(context);
                    _confirmRemoveImage(context);
                  },
                ),
              
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }

  void _takePhoto() {
    // TODO: Implement camera functionality
    // For now, show a placeholder message
    // In a real implementation, you would use image_picker package
    /*
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      onImageSelected(image.path);
    }
    */
  }

  void _pickFromGallery() {
    // TODO: Implement gallery picker functionality
    // For now, show a placeholder message
    // In a real implementation, you would use image_picker package
    /*
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      onImageSelected(image.path);
    }
    */
  }

  void _confirmRemoveImage(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Photo'),
        content: const Text(
          'Are you sure you want to remove your profile photo?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onImageRemoved();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}
