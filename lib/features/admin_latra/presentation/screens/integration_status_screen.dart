import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/verification_status.dart';
import '../providers/admin_latra_providers.dart';
import '../widgets/integration_analytics_card.dart';
import '../widgets/integration_status_card.dart';
import '../widgets/integration_events_list.dart';

/// Integration Status Screen for Admin LATRA Management
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin LATRA Management Feature
class IntegrationStatusScreen extends ConsumerStatefulWidget {
  const IntegrationStatusScreen({super.key});

  @override
  ConsumerState<IntegrationStatusScreen> createState() => _IntegrationStatusScreenState();
}

class _IntegrationStatusScreenState extends ConsumerState<IntegrationStatusScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final integrationStatusesAsync = ref.watch(integrationStatusesProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Integration Status',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettings,
            tooltip: 'Settings',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Overview', icon: Icon(Icons.dashboard)),
            Tab(text: 'Services', icon: Icon(Icons.cloud)),
            Tab(text: 'Events', icon: Icon(Icons.event_note)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOverviewTab(),
          _buildServicesTab(integrationStatusesAsync),
          _buildEventsTab(),
        ],
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Analytics Card
          const IntegrationAnalyticsCard(),
          SizedBox(height: 24.h),

          // Quick Actions
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          _buildQuickActions(),
          SizedBox(height: 24.h),

          // System Health Summary
          Text(
            'System Health',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          _buildSystemHealthSummary(),
        ],
      ),
    );
  }

  Widget _buildServicesTab(AsyncValue<List<IntegrationStatus>> integrationStatusesAsync) {
    return integrationStatusesAsync.when(
      data: (statuses) => _buildServicesList(statuses),
      loading: () => _buildLoadingServices(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildEventsTab() {
    return const IntegrationEventsList();
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildQuickActionCard(
            'Test LATRA API',
            Icons.api,
            Colors.blue,
            _testLATRAAPI,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: _buildQuickActionCard(
            'Test Verification',
            Icons.verified,
            Colors.green,
            _testVerificationAPI,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32.r,
              color: color,
            ),
            SizedBox(height: 8.h),
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealthSummary() {
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _buildHealthMetric('Overall Health', 'Healthy', Colors.green, Icons.check_circle),
            SizedBox(height: 12.h),
            _buildHealthMetric('Response Time', '< 200ms', Colors.blue, Icons.speed),
            SizedBox(height: 12.h),
            _buildHealthMetric('Uptime', '99.9%', Colors.green, Icons.trending_up),
            SizedBox(height: 12.h),
            _buildHealthMetric('Last Check', '2 min ago', Colors.grey, Icons.access_time),
          ],
        ),
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value, Color color, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.r,
          color: color,
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildServicesList(List<IntegrationStatus> statuses) {
    if (statuses.isEmpty) {
      return _buildEmptyServicesState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: statuses.length,
        itemBuilder: (context, index) {
          final status = statuses[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: IntegrationStatusCard(
              status: status,
              onTap: () => _onServiceTap(status),
              onTest: () => _testService(status.serviceName),
              onViewEvents: () => _viewServiceEvents(status.serviceName),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingServices() {
    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: _buildSkeletonServiceCard(),
      ),
    );
  }

  Widget _buildSkeletonServiceCard() {
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        height: 100.h,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  height: 16.h,
                  width: 120.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 20.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(
                  height: 12.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                SizedBox(width: 16.w),
                Container(
                  height: 12.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyServicesState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.cloud_off,
            size: 64.r,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Services Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No integration services are currently configured.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.r,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error Loading Integration Status',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    ref.invalidate(integrationStatusesProvider);
    ref.invalidate(integrationAnalyticsProvider);
  }

  void _showSettings() {
    // TODO: Implement integration settings
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Integration settings')),
    );
  }

  void _testLATRAAPI() {
    // TODO: Implement LATRA API test
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Testing LATRA API...')),
    );
  }

  void _testVerificationAPI() {
    // TODO: Implement Verification API test
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Testing Verification API...')),
    );
  }

  void _onServiceTap(IntegrationStatus status) {
    // TODO: Navigate to service details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View details for ${status.serviceName}')),
    );
  }

  void _testService(String serviceName) {
    // TODO: Implement service test
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Testing $serviceName...')),
    );
  }

  void _viewServiceEvents(String serviceName) {
    // TODO: Navigate to service events
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View events for $serviceName')),
    );
  }
}
