import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/latra_quick_actions.dart';
import '../widgets/application_summary_card.dart';
import '../providers/latra_providers.dart';
import '../providers/latra_state_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../utils/latra_navigation.dart';

/// LATRA Main Screen - Entry point for all LATRA services
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRAMainScreen extends ConsumerStatefulWidget {
  const LATRAMainScreen({super.key});

  @override
  ConsumerState<LATRAMainScreen> createState() => _LATRAMainScreenState();
}

class _LATRAMainScreenState extends ConsumerState<LATRAMainScreen> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserApplications();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadUserApplications() {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      ref
          .read(latraApplicationNotifierProvider.notifier)
          .loadUserApplications(currentUser.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('LATRA Services'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _refreshData(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeaderSection(),

              // Quick Actions
              LATRAQuickActions(
                onVehicleRegistration: () => _navigateToVehicleRegistration(),
                onLicenseApplication: () => _navigateToLicenseApplication(),
                onStatusTracking: () => _navigateToStatusTracking(),
                onDocumentUpload: () => _navigateToDocuments(),
                onRenewal: () => _navigateToRenewal(),
                onPayment: () => _navigateToPayment(),
                layout: QuickActionsLayout.grid,
              ),

              SizedBox(height: 24.h),

              // Recent Applications
              if (currentUser != null) _buildRecentApplications(currentUser.id),

              SizedBox(height: 24.h),

              // Information Section
              _buildInformationSection(),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.primary.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 32.w,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LATRA Services',
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Land Transport Regulatory Authority',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            'Manage your vehicle registration, driving license applications, and track your application status all in one place.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentApplications(String userId) {
    return Consumer(
      builder: (context, ref, child) {
        final applicationsAsync = ref.watch(
          userLATRAApplicationsProvider(userId),
        );

        return applicationsAsync.when(
          data: (applications) {
            if (applications.isEmpty) {
              return _buildNoApplicationsSection();
            }

            final recentApplications = applications.take(3).toList();

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recent Applications',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      if (applications.length > 3)
                        TextButton(
                          onPressed: () => _navigateToStatusTracking(),
                          child: Text(
                            'View All',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  ...recentApplications.map(
                    (application) => ApplicationSummaryCard(
                      application: application,
                      compact: true,
                      onTap: () => _navigateToStatusTracking(
                        applicationId: application.id,
                      ),
                      onTrackStatus: () => _navigateToStatusTracking(
                        applicationId: application.id,
                      ),
                      onViewDocuments: () =>
                          _navigateToDocuments(applicationId: application.id),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => _buildLoadingApplications(),
          error: (error, stack) => _buildErrorApplications(),
        );
      },
    );
  }

  Widget _buildNoApplicationsSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
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
              'No Applications Yet',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Start your first LATRA application using the quick actions above.',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingApplications() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Applications',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          ...List.generate(
            2,
            (index) => Container(
              margin: EdgeInsets.only(bottom: 12.h),
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.border.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorApplications() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.error.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: AppColors.error),
        ),
        child: Column(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 32.w),
            SizedBox(height: 8.h),
            Text(
              'Failed to load applications',
              style: TextStyle(
                color: AppColors.error,
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInformationSection() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information & Support',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 16.h),
          _buildInfoCard(
            'Office Hours',
            'Monday - Friday: 8:00 AM - 5:00 PM\nSaturday: 8:00 AM - 1:00 PM',
            Icons.access_time,
            AppColors.info,
          ),
          SizedBox(height: 12.h),
          _buildInfoCard(
            'Contact Information',
            'Phone: +255 22 2110808\nEmail: info@latra.go.tz\nWebsite: www.latra.go.tz',
            Icons.contact_phone,
            AppColors.success,
          ),
          SizedBox(height: 12.h),
          _buildInfoCard(
            'Emergency Services',
            'For urgent matters, contact our 24/7 emergency line: +255 22 2110999',
            Icons.emergency,
            AppColors.warning,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(
    String title,
    String content,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 20.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      ref
          .read(latraApplicationNotifierProvider.notifier)
          .loadUserApplications(currentUser.id);
    }
  }

  void _navigateToVehicleRegistration() {
    LATRANavigation.navigateToVehicleRegistration(context);
  }

  void _navigateToLicenseApplication() {
    LATRANavigation.navigateToLicenseApplication(context);
  }

  void _navigateToStatusTracking({String? applicationId}) {
    LATRANavigation.navigateToStatusTracking(
      context,
      applicationId: applicationId,
    );
  }

  void _navigateToDocuments({String? applicationId}) {
    LATRANavigation.navigateToDocuments(context, applicationId: applicationId);
  }

  void _navigateToRenewal() {
    // Navigate to renewal screen (placeholder for now)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Renewal feature coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _navigateToPayment() {
    // Navigate to payment screen (placeholder for now)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment feature coming soon'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
