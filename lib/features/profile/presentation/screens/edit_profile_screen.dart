import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/profile_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../widgets/profile_form_field.dart';
import '../widgets/profile_image_picker.dart';

/// Edit Profile Screen
/// Following specifications from FEATURES_DOCUMENTATION.md - Build screen for editing user profile
/// information including name, email, phone, profile picture upload
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _phoneNumberController = TextEditingController();

  String? _selectedImagePath;
  bool _isLoading = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _phoneNumberController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      _displayNameController.text = currentUser.displayName ?? '';
      _phoneNumberController.text = currentUser.phoneNumber ?? '';

      // Add listeners to detect changes
      _displayNameController.addListener(_onFieldChanged);
      _phoneNumberController.addListener(_onFieldChanged);
    }
  }

  void _onFieldChanged() {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      final hasDisplayNameChanged =
          _displayNameController.text != (currentUser.displayName ?? '');
      final hasPhoneChanged =
          _phoneNumberController.text != (currentUser.phoneNumber ?? '');
      final hasImageChanged = _selectedImagePath != null;

      final newHasChanges =
          hasDisplayNameChanged || hasPhoneChanged || hasImageChanged;

      if (newHasChanges != _hasChanges) {
        setState(() {
          _hasChanges = newHasChanges;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _isLoading ? null : _saveProfile,
              child: _isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Save'),
            ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return _buildNotSignedInState();
          }
          return _buildEditForm(user);
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildEditForm(user) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: EdgeInsets.all(16.w),
        children: [
          // Profile Picture Section
          Center(
            child: ProfileImagePicker(
              currentImageUrl: user.photoUrl,
              selectedImagePath: _selectedImagePath,
              onImageSelected: (imagePath) {
                setState(() {
                  _selectedImagePath = imagePath;
                });
                _onFieldChanged();
              },
              onImageRemoved: () {
                setState(() {
                  _selectedImagePath = null;
                });
                _onFieldChanged();
              },
            ),
          ),

          SizedBox(height: 32.h),

          // Personal Information Section
          _buildSectionHeader('Personal Information'),

          SizedBox(height: 16.h),

          ProfileFormField(
            controller: _displayNameController,
            label: 'Display Name',
            hint: 'Enter your display name',
            icon: Icons.person,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Display name is required';
              }
              if (value.trim().length < 2) {
                return 'Display name must be at least 2 characters';
              }
              return null;
            },
          ),

          SizedBox(height: 16.h),

          ProfileFormField(
            controller: _phoneNumberController,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value != null && value.isNotEmpty) {
                // Basic phone number validation for Tanzania
                final phoneRegex = RegExp(r'^(\+255|0)[67]\d{8}$');
                if (!phoneRegex.hasMatch(value.replaceAll(' ', ''))) {
                  return 'Please enter a valid Tanzanian phone number';
                }
              }
              return null;
            },
          ),

          SizedBox(height: 16.h),

          // Email field (read-only)
          ProfileFormField(
            initialValue: user.email,
            label: 'Email Address',
            hint: 'Your email address',
            icon: Icons.email,
            enabled: false,
            suffix: Icon(
              Icons.lock,
              size: 16.sp,
              color: Theme.of(context).hintColor,
            ),
            helperText:
                'Email cannot be changed here. Contact support if needed.',
          ),

          SizedBox(height: 32.h),

          // Account Information Section
          _buildSectionHeader('Account Information'),

          SizedBox(height: 16.h),

          _buildInfoTile(
            icon: Icons.calendar_today,
            title: 'Member Since',
            subtitle: _formatDate(user.createdAt),
          ),

          SizedBox(height: 8.h),

          _buildInfoTile(
            icon: Icons.verified_user,
            title: 'Email Verified',
            subtitle: user.isEmailVerified ? 'Verified' : 'Not Verified',
            trailing: user.isEmailVerified
                ? Icon(Icons.check_circle, color: Colors.green, size: 20.sp)
                : Icon(Icons.warning, color: Colors.orange, size: 20.sp),
          ),

          if (!user.isEmailVerified) ...[
            SizedBox(height: 8.h),
            Card(
              color: Colors.orange.withOpacity(0.1),
              child: Padding(
                padding: EdgeInsets.all(12.w),
                child: Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange, size: 20.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Please verify your email address to access all features.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.orange[800],
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: _resendVerificationEmail,
                      child: const Text('Verify'),
                    ),
                  ],
                ),
              ),
            ),
          ],

          SizedBox(height: 32.h),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _hasChanges && !_isLoading ? _saveProfile : null,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        const Text('Saving...'),
                      ],
                    )
                  : const Text('Save Changes'),
            ),
          ),

          SizedBox(height: 16.h),

          // Cancel Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _cancelEdit,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text('Cancel'),
            ),
          ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20.sp, color: Theme.of(context).primaryColor),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load profile',
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(currentUserProvider);
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotSignedInState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_circle,
            size: 100.sp,
            color: Theme.of(context).hintColor,
          ),
          SizedBox(height: 24.h),
          Text(
            'Not Signed In',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please sign in to edit your profile',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).hintColor,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => context.go('/auth/login'),
            child: const Text('Sign In'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';

    final months = [
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

    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updateProfileUseCase = ref.read(updateProfileUseCaseProvider);

      final params = UpdateProfileParams(
        displayName: _displayNameController.text.trim().isEmpty
            ? null
            : _displayNameController.text.trim(),
        phoneNumber: _phoneNumberController.text.trim().isEmpty
            ? null
            : _phoneNumberController.text.trim(),
        photoUrl: _selectedImagePath, // TODO: Upload image and get URL
      );

      final result = await updateProfileUseCase(params);

      result.fold(
        (failure) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to update profile: ${failure.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        (user) {
          if (mounted) {
            // Invalidate providers to refresh data
            ref.invalidate(currentUserProvider);
            ref.invalidate(userProfileProvider(user.id));

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate back
            context.pop();
          }
        },
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('An error occurred: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cancelEdit() {
    if (_hasChanges) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Discard Changes'),
          content: const Text(
            'You have unsaved changes. Are you sure you want to discard them?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Keep Editing'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                context.pop();
              },
              child: const Text('Discard'),
            ),
          ],
        ),
      );
    } else {
      context.pop();
    }
  }

  void _resendVerificationEmail() {
    // TODO: Implement resend verification email
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Verification email sent')));
  }
}
