import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/profile_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../vehicles/presentation/providers/vehicle_providers.dart';
import '../widgets/profile_header.dart';
import '../widgets/profile_menu_section.dart';
import '../widgets/profile_stats_section.dart';
import '../widgets/profile_quick_actions.dart';

/// Main Profile Screen
/// Following specifications from FEATURES_DOCUMENTATION.md - Profile Screen with user info display,
/// profile picture, basic details, and navigation to sub-screens
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Track profile view for analytics
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser != null) {
        ref.read(profileViewProvider(currentUser.id));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return _buildNotSignedInState();
          }
          return _buildProfileContent(user.id);
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildProfileContent(String userId) {
    final userProfileAsync = ref.watch(userProfileProvider(userId));
    final userAddressesAsync = ref.watch(userAddressesProvider(userId));
    final userPaymentMethodsAsync = ref.watch(
      userPaymentMethodsProvider(userId),
    );
    final userVehiclesAsync = ref.watch(userVehiclesProvider(userId));
    final profileCompletion = ref.watch(profileCompletionProvider(userId));

    return CustomScrollView(
      slivers: [
        // App Bar with profile header
        SliverAppBar(
          expandedHeight: 280.h,
          floating: false,
          pinned: true,
          backgroundColor: Theme.of(context).primaryColor,
          flexibleSpace: FlexibleSpaceBar(
            background: userProfileAsync.when(
              data: (profile) => ProfileHeader(
                user: profile,
                profileCompletion: profileCompletion,
                onEditProfile: () => _navigateToEditProfile(),
                onProfilePictureTap: () => _showProfilePictureOptions(),
              ),
              loading: () => const ProfileHeader.loading(),
              error: (error, stack) => ProfileHeader.error(error.toString()),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => context.push('/profile/settings'),
            ),
            PopupMenuButton<String>(
              onSelected: _handleMenuAction,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: ListTile(
                    leading: Icon(Icons.edit),
                    title: Text('Edit Profile'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: Icon(Icons.download),
                    title: Text('Export Data'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'refresh',
                  child: ListTile(
                    leading: Icon(Icons.refresh),
                    title: Text('Refresh'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ],
        ),

        // Profile Stats Section
        SliverToBoxAdapter(
          child: ProfileStatsSection(
            addressCount: userAddressesAsync.when(
              data: (addresses) => addresses.length,
              loading: () => 0,
              error: (error, stack) => 0,
            ),
            paymentMethodCount: userPaymentMethodsAsync.when(
              data: (methods) => methods.length,
              loading: () => 0,
              error: (error, stack) => 0,
            ),
            vehicleCount: userVehiclesAsync.when(
              data: (vehicles) => vehicles.length,
              loading: () => 0,
              error: (error, stack) => 0,
            ),
            profileCompletion: profileCompletion,
          ),
        ),

        // Quick Actions
        SliverToBoxAdapter(
          child: ProfileQuickActions(
            onAddAddress: () => context.push('/profile/addresses/add'),
            onAddPaymentMethod: () =>
                context.push('/profile/payment-methods/add'),
            onViewOrders: () => context.push('/profile/orders'),
            onContactSupport: () => _contactSupport(),
            onAddVehicle: () => context.push('/vehicles/add'),
            onViewVehicles: () => context.push('/vehicles'),
          ),
        ),

        // Menu Sections
        SliverToBoxAdapter(
          child: ProfileMenuSection(
            title: 'Account Management',
            items: [
              ProfileMenuItem(
                icon: Icons.location_on,
                title: 'Address Book',
                subtitle: userAddressesAsync.when(
                  data: (addresses) => '${addresses.length} addresses',
                  loading: () => 'Loading...',
                  error: (error, stack) => 'Error loading addresses',
                ),
                onTap: () => context.push('/profile/addresses'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              ProfileMenuItem(
                icon: Icons.payment,
                title: 'Payment Methods',
                subtitle: userPaymentMethodsAsync.when(
                  data: (methods) => '${methods.length} methods',
                  loading: () => 'Loading...',
                  error: (error, stack) => 'Error loading methods',
                ),
                onTap: () => context.push('/profile/payment-methods'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              ProfileMenuItem(
                icon: Icons.shopping_bag,
                title: 'Order History',
                subtitle: 'View your past orders',
                onTap: () => context.push('/profile/orders'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(
          child: ProfileMenuSection(
            title: 'Vehicle & Services',
            items: [
              ProfileMenuItem(
                icon: Icons.directions_car,
                title: 'My Vehicles',
                subtitle: userVehiclesAsync.when(
                  data: (vehicles) => '${vehicles.length} vehicles registered',
                  loading: () => 'Loading...',
                  error: (error, stack) => 'Error loading vehicles',
                ),
                onTap: () => context.push('/vehicles'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              ProfileMenuItem(
                icon: Icons.build,
                title: 'Technical Assistance',
                subtitle: 'Get expert help',
                onTap: () => context.push('/assistance'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              ProfileMenuItem(
                icon: Icons.account_balance,
                title: 'LATRA Services',
                subtitle: 'Vehicle registration & licensing',
                onTap: () => context.push('/latra'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              ProfileMenuItem(
                icon: Icons.security,
                title: 'Insurance Services',
                subtitle: 'Manage your policies',
                onTap: () => context.push('/insurance'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ],
          ),
        ),

        SliverToBoxAdapter(
          child: ProfileMenuSection(
            title: 'App Settings',
            items: [
              ProfileMenuItem(
                icon: Icons.settings,
                title: 'Settings',
                subtitle: 'App preferences & notifications',
                onTap: () => context.push('/profile/settings'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              ProfileMenuItem(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help and contact us',
                onTap: () => _contactSupport(),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              ProfileMenuItem(
                icon: Icons.info,
                title: 'About Mobby',
                subtitle: 'App version and information',
                onTap: () => _showAboutDialog(),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
            ],
          ),
        ),

        // Sign Out Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _signOut,
                    icon: const Icon(Icons.logout, color: Colors.red),
                    label: const Text(
                      'Sign Out',
                      style: TextStyle(color: Colors.red),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ],
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
              // Refresh the current user provider
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
            'Please sign in to view your profile',
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

  void _navigateToEditProfile() {
    context.push('/profile/edit');
  }

  void _showProfilePictureOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement camera functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement gallery functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: const Text('Remove Photo'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement remove photo functionality
              },
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(String action) {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) return;

    switch (action) {
      case 'edit':
        _navigateToEditProfile();
        break;
      case 'export':
        _exportUserData(currentUser.id);
        break;
      case 'refresh':
        _refreshProfile(currentUser.id);
        break;
    }
  }

  void _exportUserData(String userId) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 16),
              Text('Exporting data...'),
            ],
          ),
        ),
      );

      final data = await ref.read(exportUserDataProvider(userId));

      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show success dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Complete'),
            content: const Text('Your data has been exported successfully.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog

        // Show error dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Export Failed'),
            content: Text('Failed to export data: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  void _refreshProfile(String userId) {
    ref.read(refreshProfileCacheProvider(userId));
    ref.invalidate(userProfileProvider(userId));
    ref.invalidate(userAddressesProvider(userId));
    ref.invalidate(userPaymentMethodsProvider(userId));
    ref.invalidate(userPreferencesProvider(userId));

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Profile refreshed')));
  }

  void _contactSupport() {
    // TODO: Implement support contact functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support contact feature coming soon')),
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'Mobby',
      applicationVersion: '1.0.0',
      applicationIcon: Icon(
        Icons.directions_car,
        size: 48.sp,
        color: Theme.of(context).primaryColor,
      ),
      children: [
        const Text(
          'Mobby is your comprehensive automotive platform for spare parts, '
          'vehicle management, and automotive services in Tanzania.',
        ),
      ],
    );
  }

  void _signOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authNotifierProvider.notifier).signOut();
              context.go('/auth/login');
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
