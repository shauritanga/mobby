import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_application.dart';
import '../../domain/entities/latra_status.dart';
import '../providers/latra_providers.dart';
import '../providers/latra_state_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/application_status_card.dart';
import '../widgets/status_timeline.dart';
import '../widgets/next_steps_card.dart';
import '../widgets/notification_banner.dart';

/// LATRA Status Tracking Screen for monitoring application progress
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRAStatusTrackingScreen extends ConsumerStatefulWidget {
  final String? applicationId;

  const LATRAStatusTrackingScreen({
    super.key,
    this.applicationId,
  });

  @override
  ConsumerState<LATRAStatusTrackingScreen> createState() => _LATRAStatusTrackingScreenState();
}

class _LATRAStatusTrackingScreenState extends ConsumerState<LATRAStatusTrackingScreen> {
  final _scrollController = ScrollController();
  String? _selectedApplicationId;

  @override
  void initState() {
    super.initState();
    _selectedApplicationId = widget.applicationId;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      // Load user applications if no specific application ID provided
      if (_selectedApplicationId == null) {
        ref.read(latraApplicationNotifierProvider.notifier)
            .loadUserApplications(currentUser.id);
      } else {
        // Load specific application and its status
        ref.read(latraApplicationNotifierProvider.notifier)
            .loadApplication(_selectedApplicationId!);
        ref.read(latraStatusNotifierProvider.notifier)
            .trackApplicationStatus(_selectedApplicationId!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final applicationState = ref.watch(latraApplicationNotifierProvider);
    final statusState = ref.watch(latraStatusNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('LATRA Status Tracking'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _refreshData(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Application Selection (if no specific application provided)
              if (_selectedApplicationId == null) ...[
                _buildApplicationSelector(currentUser?.id, applicationState),
                SizedBox(height: 24.h),
              ],

              // Selected Application Content
              if (_selectedApplicationId != null) ...[
                // Notification Banner
                if (statusState.latestStatus != null && 
                    statusState.latestStatus!.requiresAction)
                  NotificationBanner(
                    status: statusState.latestStatus!,
                    onActionTap: () => _handleStatusAction(statusState.latestStatus!),
                  ),

                SizedBox(height: 16.h),

                // Application Status Card
                if (applicationState.application != null)
                  ApplicationStatusCard(
                    application: applicationState.application!,
                    latestStatus: statusState.latestStatus,
                    onViewDetails: () => _showApplicationDetails(applicationState.application!),
                  ),

                SizedBox(height: 24.h),

                // Status Timeline
                _buildStatusTimeline(statusState),
                SizedBox(height: 24.h),

                // Next Steps Card
                if (statusState.latestStatus != null)
                  NextStepsCard(
                    application: applicationState.application!,
                    currentStatus: statusState.latestStatus!,
                    onActionTap: (action) => _handleNextStepAction(action),
                  ),

                SizedBox(height: 24.h),

                // Quick Actions
                _buildQuickActions(),
              ] else ...[
                // No Application Selected State
                _buildNoApplicationSelectedState(),
              ],

              // Error Display
              if (applicationState.error != null || statusState.error != null)
                _buildErrorDisplay(applicationState.error ?? statusState.error!),

              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildApplicationSelector(String? userId, LATRAApplicationState applicationState) {
    if (userId == null) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, child) {
        final applicationsAsync = ref.watch(userLATRAApplicationsProvider(userId));
        
        return applicationsAsync.when(
          data: (applications) {
            if (applications.isEmpty) {
              return _buildNoApplicationsState();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Application to Track',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 16.h),
                ...applications.map((application) => _buildApplicationSelectorCard(application)),
              ],
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  Widget _buildApplicationSelectorCard(LATRAApplication application) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      child: InkWell(
        onTap: () => _selectApplication(application.id),
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
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
              // Status Icon
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: AppColors.getStatusColor(application.status.name).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  _getApplicationIcon(application.type),
                  color: AppColors.getStatusColor(application.status.name),
                  size: 24.w,
                ),
              ),
              SizedBox(width: 16.w),
              
              // Application Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      application.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Application #${application.applicationNumber}',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: AppColors.getStatusColor(application.status.name).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        application.status.displayName,
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w500,
                          color: AppColors.getStatusColor(application.status.name),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Icon(
                Icons.arrow_forward_ios,
                color: AppColors.textSecondary,
                size: 16.w,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusTimeline(LATRAStatusState statusState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status Timeline',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        
        if (statusState.isLoading)
          _buildLoadingState()
        else if (statusState.statusList.isEmpty)
          _buildEmptyTimelineState()
        else
          StatusTimeline(
            statusList: statusState.statusList,
            onStatusTap: (status) => _showStatusDetails(status),
          ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.upload_file,
                label: 'Upload Documents',
                onTap: () => _navigateToDocuments(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.payment,
                label: 'Make Payment',
                onTap: () => _navigateToPayment(),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.support_agent,
                label: 'Contact Support',
                onTap: () => _contactSupport(),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildQuickActionButton(
                icon: Icons.share,
                label: 'Share Status',
                onTap: () => _shareStatus(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 24.w,
            ),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoApplicationsState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
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
            size: 64.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Applications Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'You haven\'t submitted any LATRA applications yet.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Submit New Application',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoApplicationSelectedState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(
            Icons.touch_app,
            color: AppColors.textSecondary,
            size: 64.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'Select an Application',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Choose an application from the list above to track its status.',
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

  Widget _buildLoadingState() {
    return Container(
      height: 200.h,
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.error),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 32.w,
          ),
          SizedBox(height: 8.h),
          Text(
            'Error Loading Data',
            style: TextStyle(
              color: AppColors.error,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            error,
            style: TextStyle(
              color: AppColors.error,
              fontSize: 14.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTimelineState() {
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
            Icons.timeline,
            color: AppColors.textSecondary,
            size: 48.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Status Updates',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Status updates will appear here as your application progresses.',
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

  Widget _buildErrorDisplay(String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.error),
      ),
      child: Text(
        error,
        style: TextStyle(
          color: AppColors.error,
          fontSize: 14.sp,
        ),
      ),
    );
  }

  IconData _getApplicationIcon(LATRAApplicationType type) {
    switch (type) {
      case LATRAApplicationType.vehicleRegistration:
        return Icons.app_registration;
      case LATRAApplicationType.licenseRenewal:
        return Icons.refresh;
      case LATRAApplicationType.ownershipTransfer:
        return Icons.swap_horiz;
      case LATRAApplicationType.duplicateRegistration:
        return Icons.content_copy;
      case LATRAApplicationType.temporaryPermit:
        return Icons.schedule;
    }
  }

  void _selectApplication(String applicationId) {
    setState(() {
      _selectedApplicationId = applicationId;
    });
    
    // Load application and status data
    ref.read(latraApplicationNotifierProvider.notifier)
        .loadApplication(applicationId);
    ref.read(latraStatusNotifierProvider.notifier)
        .trackApplicationStatus(applicationId);
  }

  Future<void> _refreshData() async {
    if (_selectedApplicationId != null) {
      ref.read(latraApplicationNotifierProvider.notifier)
          .loadApplication(_selectedApplicationId!);
      ref.read(latraStatusNotifierProvider.notifier)
          .trackApplicationStatus(_selectedApplicationId!);
    } else {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser != null) {
        ref.read(latraApplicationNotifierProvider.notifier)
            .loadUserApplications(currentUser.id);
      }
    }
  }

  void _handleStatusAction(LATRAStatus status) {
    // Handle status-specific actions
    switch (status.type) {
      case LATRAStatusType.documentsRequired:
        _navigateToDocuments();
        break;
      case LATRAStatusType.paymentRequired:
        _navigateToPayment();
        break;
      case LATRAStatusType.appointmentRequired:
        _navigateToAppointment();
        break;
      default:
        break;
    }
  }

  void _handleNextStepAction(String action) {
    switch (action) {
      case 'upload_documents':
        _navigateToDocuments();
        break;
      case 'make_payment':
        _navigateToPayment();
        break;
      case 'book_appointment':
        _navigateToAppointment();
        break;
      case 'contact_support':
        _contactSupport();
        break;
      default:
        break;
    }
  }

  void _showApplicationDetails(LATRAApplication application) {
    // Navigate to application details screen
  }

  void _showStatusDetails(LATRAStatus status) {
    // Show status details dialog
  }

  void _navigateToDocuments() {
    // Navigate to documents screen
  }

  void _navigateToPayment() {
    // Navigate to payment screen
  }

  void _navigateToAppointment() {
    // Navigate to appointment booking screen
  }

  void _contactSupport() {
    // Open support contact options
  }

  void _shareStatus() {
    // Share application status
  }
}
