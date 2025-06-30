import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/metric.dart';

import '../providers/admin_providers.dart';
import '../widgets/dashboard_metric_card.dart';
import '../widgets/system_status_card.dart';
import '../widgets/quick_actions_panel.dart';
import '../widgets/recent_activities_card.dart';
import '../widgets/system_alerts_card.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Load dashboard data when screen initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(dashboardProvider.notifier).loadDashboard();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToAnalytics() {
    context.push('/admin/analytics');
  }

  void _navigateToReports() {
    context.push('/admin/reports');
  }

  void _navigateToSystemMonitor() {
    context.push('/admin/system');
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(dashboardProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120.h,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Admin Dashboard',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              titlePadding: EdgeInsets.only(left: 16.w, bottom: 16.h),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.analytics_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: _navigateToAnalytics,
                tooltip: 'Analytics',
              ),
              IconButton(
                icon: Icon(
                  Icons.assessment_outlined,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: _navigateToReports,
                tooltip: 'Reports',
              ),
              IconButton(
                icon: Icon(
                  Icons.monitor_heart_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: _navigateToSystemMonitor,
                tooltip: 'System Monitor',
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => ref
                    .read(dashboardProvider.notifier)
                    .loadDashboard(refresh: true),
                tooltip: 'Refresh',
              ),
            ],
          ),

          // Dashboard Content
          dashboardAsync.when(
            data: (dashboardState) => _buildDashboardContent(dashboardState),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardContent(DashboardState dashboardState) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Status Overview
            if (dashboardState.systemStatus != null)
              SystemStatusCard(systemStatus: dashboardState.systemStatus!),

            SizedBox(height: 16.h),

            // Key Metrics Grid
            _buildMetricsSection(dashboardState.metrics),

            SizedBox(height: 16.h),

            // Quick Actions and Recent Activities Row
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Quick Actions Panel
                Expanded(flex: 1, child: const QuickActionsPanel()),

                SizedBox(width: 16.w),

                // Recent Activities
                Expanded(flex: 2, child: const RecentActivitiesCard()),
              ],
            ),

            SizedBox(height: 16.h),

            // System Alerts
            const SystemAlertsCard(),

            SizedBox(height: 16.h),

            // Navigation Cards
            _buildNavigationCards(),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsSection(List<Metric> metrics) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Key Metrics',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton.icon(
              onPressed: _navigateToAnalytics,
              icon: Icon(
                Icons.analytics,
                size: 16.r,
                color: Theme.of(context).colorScheme.primary,
              ),
              label: Text(
                'View All',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ],
        ),

        SizedBox(height: 12.h),

        // Metrics Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.6,
          ),
          itemCount: metrics.take(4).length,
          itemBuilder: (context, index) {
            final metric = metrics[index];
            return DashboardMetricCard(metric: metric);
          },
        ),
      ],
    );
  }

  Widget _buildNavigationCards() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Navigation',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),

        SizedBox(height: 12.h),

        Row(
          children: [
            Expanded(
              child: _buildNavigationCard(
                title: 'Analytics',
                subtitle: 'Detailed insights',
                icon: Icons.analytics,
                color: Colors.blue,
                onTap: _navigateToAnalytics,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildNavigationCard(
                title: 'Reports',
                subtitle: 'Generate reports',
                icon: Icons.assessment,
                color: Colors.green,
                onTap: _navigateToReports,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: _buildNavigationCard(
                title: 'System',
                subtitle: 'Monitor health',
                icon: Icons.monitor_heart,
                color: Colors.orange,
                onTap: _navigateToSystemMonitor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNavigationCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: color.withValues(alpha: 0.2), width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 24.r, color: color),
              ),
              SizedBox(height: 8.h),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // System status skeleton
            _buildSkeletonCard(height: 120.h),
            SizedBox(height: 16.h),

            // Metrics grid skeleton
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 1.6,
              ),
              itemCount: 4,
              itemBuilder: (context, index) => _buildSkeletonCard(),
            ),

            SizedBox(height: 16.h),

            // Quick actions and activities skeleton
            Row(
              children: [
                Expanded(child: _buildSkeletonCard(height: 200.h)),
                SizedBox(width: 16.w),
                Expanded(flex: 2, child: _buildSkeletonCard(height: 200.h)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonCard({double? height}) {
    return Container(
      height: height ?? 100.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
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
                'Error Loading Dashboard',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => ref
                    .read(dashboardProvider.notifier)
                    .loadDashboard(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
