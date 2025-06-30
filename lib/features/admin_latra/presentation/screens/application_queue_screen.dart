import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../latra/domain/entities/latra_application.dart';
import '../providers/admin_latra_providers.dart';
import '../widgets/application_filters_panel.dart';
import '../widgets/application_list_item.dart';
import '../widgets/application_search_bar.dart';
import '../widgets/applications_analytics_card.dart';

/// Application Queue Screen for Admin LATRA Management
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin LATRA Management Feature
class ApplicationQueueScreen extends ConsumerStatefulWidget {
  const ApplicationQueueScreen({super.key});

  @override
  ConsumerState<ApplicationQueueScreen> createState() => _ApplicationQueueScreenState();
}

class _ApplicationQueueScreenState extends ConsumerState<ApplicationQueueScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  List<String> _selectedApplicationIds = [];
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Load more applications
      final currentFilters = ref.read(applicationFiltersProvider);
      ref.read(applicationFiltersProvider.notifier).state = currentFilters.copyWith(
        page: currentFilters.page + 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(applicationFiltersProvider);
    final applicationsAsync = ref.watch(applicationsProvider(filters));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Application Queue',
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
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: _handleBulkAction,
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'approve', child: Text('Bulk Approve')),
                const PopupMenuItem(value: 'reject', child: Text('Bulk Reject')),
                const PopupMenuItem(value: 'assign', child: Text('Bulk Assign')),
              ],
            ),
          ] else ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshData,
              tooltip: 'Refresh',
            ),
            IconButton(
              icon: const Icon(Icons.checklist),
              onPressed: _enterSelectionMode,
              tooltip: 'Select Multiple',
            ),
          ],
        ],
      ),
      body: Column(
        children: [
          // Analytics Card
          Padding(
            padding: EdgeInsets.all(16.w),
            child: const ApplicationsAnalyticsCard(),
          ),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: ApplicationSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onFilterPressed: _showFiltersPanel,
            ),
          ),

          SizedBox(height: 16.h),

          // Applications List
          Expanded(
            child: applicationsAsync.when(
              data: (applications) => _buildApplicationsList(applications),
              loading: () => _buildLoadingList(),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplicationsList(List<LATRAApplication> applications) {
    if (applications.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: applications.length,
        itemBuilder: (context, index) {
          final application = applications[index];
          final isSelected = _selectedApplicationIds.contains(application.id);

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: ApplicationListItem(
              application: application,
              isSelected: isSelected,
              isSelectionMode: _isSelectionMode,
              onTap: () => _onApplicationTap(application),
              onSelectionChanged: (selected) => _onSelectionChanged(application.id, selected),
              onStatusChanged: (status) => _updateApplicationStatus(application.id, status),
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
      itemCount: 10,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: _buildSkeletonItem(),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        height: 120.h,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16.h,
              width: 200.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 12.h,
              width: 150.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6.r),
              ),
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
                const Spacer(),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 64.r,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Applications Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'There are no applications matching your current filters.',
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
      page: 1, // Reset to first page
    );
  }

  void _showFiltersPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ApplicationFiltersPanel(
        currentFilters: ref.read(applicationFiltersProvider),
        onFiltersChanged: (filters) {
          ref.read(applicationFiltersProvider.notifier).state = filters.copyWith(page: 1);
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    ref.invalidate(applicationsProvider);
    ref.invalidate(applicationsAnalyticsProvider);
  }

  void _onApplicationTap(LATRAApplication application) {
    if (_isSelectionMode) {
      _onSelectionChanged(application.id, !_selectedApplicationIds.contains(application.id));
    } else {
      // Navigate to application details
      // TODO: Implement navigation to application details screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('View details for ${application.applicationNumber}')),
      );
    }
  }

  void _onSelectionChanged(String applicationId, bool selected) {
    setState(() {
      if (selected) {
        _selectedApplicationIds.add(applicationId);
      } else {
        _selectedApplicationIds.remove(applicationId);
      }

      if (_selectedApplicationIds.isEmpty) {
        _isSelectionMode = false;
      }
    });
  }

  void _enterSelectionMode() {
    setState(() {
      _isSelectionMode = true;
    });
  }

  void _selectAll() {
    final filters = ref.read(applicationFiltersProvider);
    final applicationsAsync = ref.read(applicationsProvider(filters));
    
    applicationsAsync.whenData((applications) {
      setState(() {
        _selectedApplicationIds = applications.map((app) => app.id).toList();
      });
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedApplicationIds.clear();
      _isSelectionMode = false;
    });
  }

  void _handleBulkAction(String action) {
    if (_selectedApplicationIds.isEmpty) return;

    switch (action) {
      case 'approve':
        _bulkUpdateStatus(LATRAApplicationStatus.approved);
        break;
      case 'reject':
        _bulkUpdateStatus(LATRAApplicationStatus.rejected);
        break;
      case 'assign':
        _showBulkAssignDialog();
        break;
    }
  }

  void _bulkUpdateStatus(LATRAApplicationStatus status) {
    // TODO: Implement bulk status update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bulk ${status.displayName} - ${_selectedApplicationIds.length} applications')),
    );
    _clearSelection();
  }

  void _showBulkAssignDialog() {
    // TODO: Implement bulk assign dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bulk assign - ${_selectedApplicationIds.length} applications')),
    );
  }

  void _updateApplicationStatus(String applicationId, LATRAApplicationStatus status) {
    // TODO: Implement status update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Update status to ${status.displayName}')),
    );
  }

  void _assignApplication(String applicationId, String userId, String userName) {
    // TODO: Implement assignment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Assign to $userName')),
    );
  }

  void _addApplicationNotes(String applicationId, String notes) {
    // TODO: Implement add notes
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add notes: $notes')),
    );
  }
}
