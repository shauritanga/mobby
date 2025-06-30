import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/application.dart';
import '../providers/admin_insurance_providers.dart';
import '../widgets/application_analytics_card.dart';
import '../widgets/application_search_bar.dart';
import '../widgets/application_list_item.dart';
import '../widgets/application_filters_panel.dart';

/// Application Processing Screen for Admin Insurance Management
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin Insurance Management Feature
class ApplicationProcessingScreen extends ConsumerStatefulWidget {
  const ApplicationProcessingScreen({super.key});

  @override
  ConsumerState<ApplicationProcessingScreen> createState() => _ApplicationProcessingScreenState();
}

class _ApplicationProcessingScreenState extends ConsumerState<ApplicationProcessingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedApplications = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationsAsync = ref.watch(applicationsProvider);
    final filters = ref.watch(applicationFiltersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Application Processing',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          if (_isSelectionMode) ...[
            IconButton(
              icon: const Icon(Icons.select_all),
              onPressed: _selectAll,
              tooltip: 'Select All',
            ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: _clearSelection,
              tooltip: 'Clear Selection',
            ),
          ],
          IconButton(
            icon: const Icon(Icons.assignment_add),
            onPressed: _addApplication,
            tooltip: 'Add Application',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
              const PopupMenuItem(value: 'export', child: Text('Export Data')),
              const PopupMenuItem(value: 'reports', child: Text('Generate Report')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'Pending', icon: Icon(Icons.pending_actions)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildApplicationsTab(applicationsAsync, filters),
          _buildPendingTab(applicationsAsync, filters),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: _isSelectionMode
          ? FloatingActionButton.extended(
              onPressed: _showBulkActions,
              icon: const Icon(Icons.edit),
              label: Text('Actions (${_selectedApplications.length})'),
            )
          : null,
    );
  }

  Widget _buildApplicationsTab(AsyncValue<List<InsuranceApplication>> applicationsAsync, ApplicationFilters filters) {
    return Column(
      children: [
        // Search and Filters
        Padding(
          padding: EdgeInsets.all(16.w),
          child: ApplicationSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onFilterPressed: _showFilters,
          ),
        ),

        // Applications List
        Expanded(
          child: applicationsAsync.when(
            data: (applications) => _buildApplicationsList(applications),
            loading: () => _buildLoadingList(),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTab(AsyncValue<List<InsuranceApplication>> applicationsAsync, ApplicationFilters filters) {
    return applicationsAsync.when(
      data: (applications) {
        final pendingApplications = applications
            .where((app) => app.status == ApplicationStatus.pending || app.status == ApplicationStatus.underReview)
            .toList();
        return _buildApplicationsList(pendingApplications, isPendingView: true);
      },
      loading: () => _buildLoadingList(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildAnalyticsTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          ApplicationAnalyticsCard(),
          // Add more analytics widgets here
        ],
      ),
    );
  }

  Widget _buildApplicationsList(List<InsuranceApplication> applications, {bool isPendingView = false}) {
    if (applications.isEmpty) {
      return _buildEmptyState(isPendingView);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          final isSelected = _selectedApplications.contains(application.id);

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: ApplicationListItem(
              application: application,
              isSelected: isSelected,
              isSelectionMode: _isSelectionMode,
              onTap: () => _onApplicationTap(application),
              onSelectionChanged: (selected) => _onSelectionChanged(application.id, selected),
              onStatusChanged: (status) => _updateApplicationStatus(application.id, status),
              onPriorityChanged: (priority) => _updateApplicationPriority(application.id, priority),
              onAssign: (userId, userName) => _assignApplication(application.id, userId, userName),
              onAddNotes: (notes) => _addApplicationNotes(application.id, notes),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: _buildSkeletonApplicationCard(),
      ),
    );
  }

  Widget _buildSkeletonApplicationCard() {
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        height: 140.h,
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
            Container(
              height: 12.h,
              width: 200.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            SizedBox(height: 8.h),
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
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(
                  height: 24.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  height: 24.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isPendingView) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isPendingView ? Icons.pending_actions : Icons.assignment_outlined,
            size: 64.r,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            isPendingView ? 'No Pending Applications' : 'No Applications Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            isPendingView 
                ? 'All applications have been processed.'
                : 'No insurance applications to display.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          if (!isPendingView) ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _addApplication,
              icon: const Icon(Icons.add),
              label: const Text('Add Application'),
            ),
          ],
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
            'Error Loading Applications',
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

  void _onSearchChanged(String query) {
    final currentFilters = ref.read(applicationFiltersProvider);
    ref.read(applicationFiltersProvider.notifier).state = currentFilters.copyWith(
      searchQuery: query.isEmpty ? null : query,
    );
    _applyFilters();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplicationFiltersPanel(
        currentFilters: ref.read(applicationFiltersProvider),
        onFiltersChanged: (filters) {
          ref.read(applicationFiltersProvider.notifier).state = filters;
          _applyFilters();
        },
      ),
    );
  }

  void _applyFilters() {
    final filters = ref.read(applicationFiltersProvider);
    ref.read(applicationsProvider.notifier).loadApplications(
      type: filters.type,
      status: filters.status,
      priority: filters.priority,
      partnerId: filters.partnerId,
      assignedTo: filters.assignedTo,
      startDate: filters.startDate,
      endDate: filters.endDate,
      searchQuery: filters.searchQuery,
    );
  }

  Future<void> _refreshData() async {
    ref.invalidate(applicationsProvider);
    ref.invalidate(applicationsAnalyticsProvider);
  }

  void _onApplicationTap(InsuranceApplication application) {
    if (_isSelectionMode) {
      _onSelectionChanged(application.id, !_selectedApplications.contains(application.id));
    } else {
      // Navigate to application details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('View details for ${application.applicationNumber}')),
      );
    }
  }

  void _onSelectionChanged(String applicationId, bool selected) {
    setState(() {
      if (selected) {
        _selectedApplications.add(applicationId);
        if (!_isSelectionMode) {
          _isSelectionMode = true;
        }
      } else {
        _selectedApplications.remove(applicationId);
        if (_selectedApplications.isEmpty) {
          _isSelectionMode = false;
        }
      }
    });
  }

  void _selectAll() {
    final applications = ref.read(applicationsProvider).value ?? [];
    setState(() {
      _selectedApplications.addAll(applications.map((a) => a.id));
      _isSelectionMode = true;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedApplications.clear();
      _isSelectionMode = false;
    });
  }

  void _addApplication() {
    // TODO: Navigate to add application screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add application functionality')),
    );
  }

  void _updateApplicationStatus(String applicationId, ApplicationStatus status) {
    // TODO: Implement status update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Update status to ${status.displayName}')),
    );
  }

  void _updateApplicationPriority(String applicationId, ApplicationPriority priority) {
    // TODO: Implement priority update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Update priority to ${priority.displayName}')),
    );
  }

  void _assignApplication(String applicationId, String userId, String userName) {
    // TODO: Implement assignment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assign to $userName')),
    );
  }

  void _addApplicationNotes(String applicationId, String notes) {
    // TODO: Implement notes addition
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add notes: $notes')),
    );
  }

  void _showBulkActions() {
    // TODO: Show bulk actions dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bulk actions for ${_selectedApplications.length} applications')),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        _refreshData();
        break;
      case 'export':
        // TODO: Implement export functionality
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Export functionality')),
        );
        break;
      case 'reports':
        // TODO: Navigate to reports
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Generate report')),
        );
        break;
      case 'settings':
        // TODO: Navigate to settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings')),
        );
        break;
    }
  }
}
