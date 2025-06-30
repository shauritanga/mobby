import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../auth/domain/entities/user.dart';

/// Profile header widget with user info and profile picture
/// Following specifications from FEATURES_DOCUMENTATION.md
class ProfileHeader extends StatelessWidget {
  final User? user;
  final double profileCompletion;
  final VoidCallback? onEditProfile;
  final VoidCallback? onProfilePictureTap;

  const ProfileHeader({
    super.key,
    this.user,
    this.profileCompletion = 0.0,
    this.onEditProfile,
    this.onProfilePictureTap,
  });

  const ProfileHeader.loading({super.key})
      : user = null,
        profileCompletion = 0.0,
        onEditProfile = null,
        onProfilePictureTap = null;

  const ProfileHeader.error(String error, {super.key})
      : user = null,
        profileCompletion = 0.0,
        onEditProfile = null,
        onProfilePictureTap = null;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return _buildLoadingState(context);
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              
              // Profile Picture
              GestureDetector(
                onTap: onProfilePictureTap,
                child: Stack(
                  children: [
                    Container(
                      width: 100.w,
                      height: 100.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3.w,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: user!.photoUrl?.isNotEmpty == true
                            ? CachedNetworkImage(
                                imageUrl: user!.photoUrl!,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[300],
                                  child: const Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                errorWidget: (context, url, error) => _buildDefaultAvatar(),
                              )
                            : _buildDefaultAvatar(),
                      ),
                    ),
                    
                    // Edit icon
                    if (onProfilePictureTap != null)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 32.w,
                          height: 32.w,
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 2.w,
                            ),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 16.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // User Name
              Text(
                user!.displayName?.isNotEmpty == true 
                    ? user!.displayName! 
                    : 'User',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 4.h),
              
              // Email
              Text(
                user!.email,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white.withOpacity(0.9),
                ),
                textAlign: TextAlign.center,
              ),
              
              // Phone number (if available)
              if (user!.phoneNumber?.isNotEmpty == true) ...[
                SizedBox(height: 4.h),
                Text(
                  user!.phoneNumber!,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              
              SizedBox(height: 16.h),
              
              // Profile Completion
              _buildProfileCompletion(context),
              
              SizedBox(height: 16.h),
              
              // Edit Profile Button
              if (onEditProfile != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: onEditProfile,
                    icon: const Icon(Icons.edit, color: Colors.white),
                    label: const Text(
                      'Edit Profile',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey[300],
      child: Icon(
        Icons.person,
        size: 50.sp,
        color: Colors.grey[600],
      ),
    );
  }

  Widget _buildProfileCompletion(BuildContext context) {
    final completionPercentage = (profileCompletion * 100).round();
    
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Profile Completion',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Text(
              '$completionPercentage%',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        
        SizedBox(height: 8.h),
        
        LinearProgressIndicator(
          value: profileCompletion,
          backgroundColor: Colors.white.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(
            completionPercentage >= 80 
                ? Colors.green 
                : completionPercentage >= 50 
                    ? Colors.orange 
                    : Colors.red,
          ),
        ),
        
        if (completionPercentage < 100) ...[
          SizedBox(height: 8.h),
          Text(
            _getCompletionMessage(completionPercentage),
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }

  String _getCompletionMessage(int percentage) {
    if (percentage < 30) {
      return 'Complete your profile to get the best experience';
    } else if (percentage < 60) {
      return 'Add more details to improve your profile';
    } else if (percentage < 90) {
      return 'Almost done! Add a few more details';
    } else {
      return 'Your profile is almost complete!';
    }
  }

  Widget _buildLoadingState(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              
              // Loading profile picture
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.3),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Loading text placeholders
              Container(
                width: 150.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              
              SizedBox(height: 8.h),
              
              Container(
                width: 200.w,
                height: 16.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              
              SizedBox(height: 24.h),
              
              // Loading button
              Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
