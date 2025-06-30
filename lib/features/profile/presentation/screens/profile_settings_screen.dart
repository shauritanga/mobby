import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/profile_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/user_preferences.dart';
import '../widgets/settings_section.dart';
import '../widgets/settings_tile.dart';
import '../widgets/settings_switch_tile.dart';
import '../widgets/settings_dropdown_tile.dart';

/// Profile Settings Screen
/// Following specifications from FEATURES_DOCUMENTATION.md - Settings screen with app preferences,
/// notifications, privacy settings, and account management options
class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends ConsumerState<ProfileSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return _buildNotSignedInState();
          }
          return _buildSettingsContent(user.id);
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildSettingsContent(String userId) {
    final userPreferencesAsync = ref.watch(userPreferencesProvider(userId));

    return userPreferencesAsync.when(
      data: (preferences) => _buildSettingsList(userId, preferences),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildSettingsList(String userId, UserPreferences preferences) {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // App Preferences Section
        SettingsSection(
          title: 'App Preferences',
          children: [
            SettingsDropdownTile<String>(
              icon: Icons.language,
              title: 'Language',
              subtitle: _getLanguageDisplayName(preferences.language),
              value: preferences.language,
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'sw', child: Text('Kiswahili')),
              ],
              onChanged: (value) => _updatePreference(
                userId,
                preferences.copyWith(language: value),
                'language',
                value,
              ),
            ),
            
            SettingsDropdownTile<String>(
              icon: Icons.attach_money,
              title: 'Currency',
              subtitle: _getCurrencyDisplayName(preferences.currency),
              value: preferences.currency,
              items: const [
                DropdownMenuItem(value: 'TZS', child: Text('Tanzanian Shilling (TZS)')),
                DropdownMenuItem(value: 'USD', child: Text('US Dollar (USD)')),
                DropdownMenuItem(value: 'EUR', child: Text('Euro (EUR)')),
              ],
              onChanged: (value) => _updatePreference(
                userId,
                preferences.copyWith(currency: value),
                'currency',
                value,
              ),
            ),
            
            SettingsDropdownTile<String>(
              icon: Icons.palette,
              title: 'Theme',
              subtitle: _getThemeDisplayName(preferences.theme),
              value: preferences.theme,
              items: const [
                DropdownMenuItem(value: 'light', child: Text('Light')),
                DropdownMenuItem(value: 'dark', child: Text('Dark')),
                DropdownMenuItem(value: 'system', child: Text('System')),
              ],
              onChanged: (value) => _updatePreference(
                userId,
                preferences.copyWith(theme: value),
                'theme',
                value,
              ),
            ),
          ],
        ),

        SizedBox(height: 24.h),

        // Notification Settings Section
        SettingsSection(
          title: 'Notifications',
          children: [
            SettingsSwitchTile(
              icon: Icons.notifications,
              title: 'Enable Notifications',
              subtitle: 'Receive app notifications',
              value: preferences.notificationsEnabled,
              onChanged: (value) => _updatePreference(
                userId,
                preferences.copyWith(notificationsEnabled: value),
                'notificationsEnabled',
                value,
              ),
            ),
            
            if (preferences.notificationsEnabled) ...[
              SettingsSwitchTile(
                icon: Icons.email,
                title: 'Email Notifications',
                subtitle: 'Receive notifications via email',
                value: preferences.emailNotifications,
                onChanged: (value) => _updatePreference(
                  userId,
                  preferences.copyWith(emailNotifications: value),
                  'emailNotifications',
                  value,
                ),
              ),
              
              SettingsSwitchTile(
                icon: Icons.sms,
                title: 'SMS Notifications',
                subtitle: 'Receive notifications via SMS',
                value: preferences.smsNotifications,
                onChanged: (value) => _updatePreference(
                  userId,
                  preferences.copyWith(smsNotifications: value),
                  'smsNotifications',
                  value,
                ),
              ),
              
              SettingsSwitchTile(
                icon: Icons.phone_android,
                title: 'Push Notifications',
                subtitle: 'Receive push notifications',
                value: preferences.pushNotifications,
                onChanged: (value) => _updatePreference(
                  userId,
                  preferences.copyWith(pushNotifications: value),
                  'pushNotifications',
                  value,
                ),
              ),
            ],
          ],
        ),

        SizedBox(height: 24.h),

        // Marketing & Communication Section
        SettingsSection(
          title: 'Marketing & Communication',
          children: [
            SettingsSwitchTile(
              icon: Icons.campaign,
              title: 'Marketing Emails',
              subtitle: 'Receive promotional emails and offers',
              value: preferences.marketingEmails,
              onChanged: (value) => _updatePreference(
                userId,
                preferences.copyWith(marketingEmails: value),
                'marketingEmails',
                value,
              ),
            ),
            
            SettingsSwitchTile(
              icon: Icons.shopping_bag,
              title: 'Order Updates',
              subtitle: 'Receive updates about your orders',
              value: preferences.orderUpdates,
              onChanged: (value) => _updatePreference(
                userId,
                preferences.copyWith(orderUpdates: value),
                'orderUpdates',
                value,
              ),
            ),
            
            SettingsSwitchTile(
              icon: Icons.local_offer,
              title: 'Promotional Offers',
              subtitle: 'Receive special offers and discounts',
              value: preferences.promotionalOffers,
              onChanged: (value) => _updatePreference(
                userId,
                preferences.copyWith(promotionalOffers: value),
                'promotionalOffers',
                value,
              ),
            ),
            
            SettingsSwitchTile(
              icon: Icons.recommend,
              title: 'Expert Recommendations',
              subtitle: 'Receive product recommendations from experts',
              value: preferences.expertRecommendations,
              onChanged: (value) => _updatePreference(
                userId,
                preferences.copyWith(expertRecommendations: value),
                'expertRecommendations',
                value,
              ),
            ),
          ],
        ),

        SizedBox(height: 24.h),

        // Privacy & Security Section
        SettingsSection(
          title: 'Privacy & Security',
          children: [
            SettingsSwitchTile(
              icon: Icons.fingerprint,
              title: 'Biometric Authentication',
              subtitle: 'Use fingerprint or face ID to sign in',
              value: preferences.biometricAuth,
              onChanged: (value) => _updatePreference(
                userId,
                preferences.copyWith(biometricAuth: value),
                'biometricAuth',
                value,
              ),
            ),
            
            SettingsSwitchTile(
              icon: Icons.backup,
              title: 'Auto Backup',
              subtitle: 'Automatically backup your data',
              value: preferences.autoBackup,
              onChanged: (value) => _updatePreference(
                userId,
                preferences.copyWith(autoBackup: value),
                'autoBackup',
                value,
              ),
            ),
            
            SettingsTile(
              icon: Icons.lock,
              title: 'Change Password',
              subtitle: 'Update your account password',
              onTap: () => _changePassword(),
            ),
            
            SettingsTile(
              icon: Icons.privacy_tip,
              title: 'Privacy Policy',
              subtitle: 'Read our privacy policy',
              onTap: () => _showPrivacyPolicy(),
            ),
            
            SettingsTile(
              icon: Icons.description,
              title: 'Terms of Service',
              subtitle: 'Read our terms of service',
              onTap: () => _showTermsOfService(),
            ),
          ],
        ),

        SizedBox(height: 24.h),

        // Account Management Section
        SettingsSection(
          title: 'Account Management',
          children: [
            SettingsTile(
              icon: Icons.download,
              title: 'Export Data',
              subtitle: 'Download your account data',
              onTap: () => _exportData(userId),
            ),
            
            SettingsTile(
              icon: Icons.refresh,
              title: 'Clear Cache',
              subtitle: 'Clear app cache and refresh data',
              onTap: () => _clearCache(userId),
            ),
            
            SettingsTile(
              icon: Icons.restore,
              title: 'Reset Settings',
              subtitle: 'Reset all settings to default',
              onTap: () => _resetSettings(userId),
            ),
            
            SettingsTile(
              icon: Icons.delete_forever,
              title: 'Delete Account',
              subtitle: 'Permanently delete your account',
              onTap: () => _deleteAccount(),
              textColor: Colors.red,
              iconColor: Colors.red,
            ),
          ],
        ),

        SizedBox(height: 32.h),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
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
            'Failed to load settings',
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
              final currentUser = ref.read(currentUserProvider).value;
              if (currentUser != null) {
                ref.invalidate(userPreferencesProvider(currentUser.id));
              }
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
            Icons.settings,
            size: 100.sp,
            color: Theme.of(context).hintColor,
          ),
          SizedBox(height: 24.h),
          Text(
            'Not Signed In',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please sign in to access settings',
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

  // Helper methods for display names
  String _getLanguageDisplayName(String code) {
    switch (code) {
      case 'en':
        return 'English';
      case 'sw':
        return 'Kiswahili';
      default:
        return 'English';
    }
  }

  String _getCurrencyDisplayName(String code) {
    switch (code) {
      case 'TZS':
        return 'Tanzanian Shilling';
      case 'USD':
        return 'US Dollar';
      case 'EUR':
        return 'Euro';
      default:
        return 'Tanzanian Shilling';
    }
  }

  String _getThemeDisplayName(String theme) {
    switch (theme) {
      case 'light':
        return 'Light';
      case 'dark':
        return 'Dark';
      case 'system':
        return 'System';
      default:
        return 'System';
    }
  }

  // Action methods
  void _updatePreference(
    String userId,
    UserPreferences newPreferences,
    String preferenceName,
    dynamic value,
  ) async {
    try {
      // Update preferences
      final repository = ref.read(profileRepositoryProvider);
      await repository.updateUserPreferences(newPreferences);
      
      // Track preference change
      ref.read(preferenceChangeProvider((
        userId: userId,
        preference: preferenceName,
        value: value,
      )));
      
      // Invalidate to refresh UI
      ref.invalidate(userPreferencesProvider(userId));
      
      // Show success feedback
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$preferenceName updated successfully'),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update $preferenceName: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _changePassword() {
    // TODO: Implement change password functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Change password feature coming soon')),
    );
  }

  void _showPrivacyPolicy() {
    // TODO: Implement privacy policy display
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy policy feature coming soon')),
    );
  }

  void _showTermsOfService() {
    // TODO: Implement terms of service display
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Terms of service feature coming soon')),
    );
  }

  void _exportData(String userId) async {
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

      await ref.read(exportUserDataProvider(userId));
      
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Data exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading dialog
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to export data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _clearCache(String userId) async {
    try {
      await ref.read(clearProfileCacheProvider(userId));
      
      // Invalidate all providers to refresh data
      ref.invalidate(userProfileProvider(userId));
      ref.invalidate(userAddressesProvider(userId));
      ref.invalidate(userPaymentMethodsProvider(userId));
      ref.invalidate(userPreferencesProvider(userId));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cache cleared successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear cache: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _resetSettings(String userId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Settings'),
        content: const Text(
          'Are you sure you want to reset all settings to default? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final repository = ref.read(profileRepositoryProvider);
                await repository.resetUserPreferences(userId);
                
                ref.invalidate(userPreferencesProvider(userId));
                
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Settings reset successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to reset settings: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to permanently delete your account? '
          'This action cannot be undone and all your data will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              try {
                final repository = ref.read(profileRepositoryProvider);
                await repository.deleteUserAccount();
                
                // Sign out and navigate to login
                ref.read(authNotifierProvider.notifier).signOut();
                
                if (mounted) {
                  context.go('/auth/login');
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Account deleted successfully')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete account: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
