import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/commission.dart';
import '../providers/admin_insurance_providers.dart';
import '../widgets/commission_analytics_card.dart';
import '../widgets/commission_search_bar.dart';
import '../widgets/commission_list_item.dart';
import '../widgets/commission_filters_panel.dart';

/// Commission Tracking Screen for Admin Insurance Management
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin Insurance Management Feature
class CommissionTrackingScreen extends ConsumerStatefulWidget {
  const CommissionTrackingScreen({super.key});

  @override
  ConsumerState<CommissionTrackingScreen> createState() => _CommissionTrackingScreenState();
}

class _CommissionTrackingScreenState extends ConsumerState<CommissionTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedCommissions = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commissionsAsync = ref.watch(commissionsProvider);
    final filters = ref.watch(commissionFiltersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Commission Tracking',
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
            icon: const Icon(Icons.payment),
            onPressed: _processPayments,
            tooltip: 'Process Payments',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
              const PopupMenuItem(value: 'export', child: Text('Export Data')),
              const PopupMenuItem(value: 'reports', child: Text('Generate Report')),
              const PopupMenuItem(value: 'reconcile', child: Text('Reconcile')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All', icon: Icon(Icons.list)),
            Tab(text: 'Pending', icon: Icon(Icons.pending)),
            Tab(text: 'Approved', icon: Icon(Icons.check_circle)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCommissionsTab(commissionsAsync, filters),
          _buildPendingTab(commissionsAsync, filters),
          _buildApprovedTab(commissionsAsync, filters),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: _isSelectionMode
          ? FloatingActionButton.extended(
              onPressed: _showBulkActions,
              icon: const Icon(Icons.edit),
              label: Text('Actions (${_selectedCommissions.length})'),
            )
          : FloatingActionButton.extended(
              onPressed: _addCommissionAdjustment,
              icon: const Icon(Icons.add),
              label: const Text('Adjustment'),
            ),
    );
  }

  Widget _buildCommissionsTab(AsyncValue<List<Commission>> commissionsAsync, CommissionFilters filters) {
    return Column(
      children: [
        // Search and Filters
        Padding(
          padding: EdgeInsets.all(16.w),
          child: CommissionSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onFilterPressed: _showFilters,
          ),
        ),

        // Commissions List
        Expanded(
          child: commissionsAsync.when(
            data: (commissions) => _buildCommissionsList(commissions),
            loading: () => _buildLoadingList(),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingTab(AsyncValue<List<Commission>> commissionsAsync, CommissionFilters filters) {
    return commissionsAsync.when(
      data: (commissions) {
        final pendingCommissions = commissions
            .where((commission) => commission.status == CommissionStatus.pending)
            .toList();
        return _buildCommissionsList(pendingCommissions, isPendingView: true);
      },
      loading: () => _buildLoadingList(),
      error: (error, stack) => _buildErrorState(error.toString()),
    );
  }

  Widget _buildApprovedTab(AsyncValue<List<Commission>> commissionsAsync, CommissionFilters filters) {
    return commissionsAsync.when(
      data: (commissions) {
        final approvedCommissions = commissions
            .where((commission) => commission.status == CommissionStatus.approved)
            .toList();
        return _buildCommissionsList(approvedCommissions, isApprovedView: true);
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
          CommissionAnalyticsCard(),
          // Add more analytics widgets here
        ],
      ),
    );
  }

  Widget _buildCommissionsList(List<Commission> commissions, {bool isPendingView = false, bool isApprovedView = false}) {
    if (commissions.isEmpty) {
      return _buildEmptyState(isPendingView, isApprovedView);
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: commissions.length,
        itemBuilder: (context, index) {
          final commission = commissions[index];
          final isSelected = _selectedCommissions.contains(commission.id);

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: CommissionListItem(
              commission: commission,
              isSelected: isSelected,
              isSelectionMode: _isSelectionMode,
              onTap: () => _onCommissionTap(commission),
              onSelectionChanged: (selected) => _onSelectionChanged(commission.id, selected),
              onStatusChanged: (status) => _updateCommissionStatus(commission.id, status),
              onProcessPayment: (paymentRef, method) => _processCommissionPayment(commission.id, paymentRef, method),
              onAddAdjustment: (reason, amount, type) => _addAdjustment(commission.id, reason, amount, type),
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
        child: _buildSkeletonCommissionCard(),
      ),
    );
  }

  Widget _buildSkeletonCommissionCard() {
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
            SizedBox(height: 16.h),
            Container(
              height: 18.h,
              width: 100.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(9.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isPendingView, bool isApprovedView) {
    String title;
    String subtitle;
    IconData icon;

    if (isPendingView) {
      title = 'No Pending Commissions';
      subtitle = 'All commissions have been processed.';
      icon = Icons.pending;
    } else if (isApprovedView) {
      title = 'No Approved Commissions';
      subtitle = 'No commissions are ready for payment.';
      icon = Icons.check_circle;
    } else {
      title = 'No Commissions Found';
      subtitle = 'No commission records to display.';
      icon = Icons.monetization_on_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64.r,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
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
            'Error Loading Commissions',
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
    final currentFilters = ref.read(commissionFiltersProvider);
    ref.read(commissionFiltersProvider.notifier).state = currentFilters.copyWith(
      searchQuery: query.isEmpty ? null : query,
    );
    _applyFilters();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommissionFiltersPanel(
        currentFilters: ref.read(commissionFiltersProvider),
        onFiltersChanged: (filters) {
          ref.read(commissionFiltersProvider.notifier).state = filters;
          _applyFilters();
        },
      ),
    );
  }

  void _applyFilters() {
    final filters = ref.read(commissionFiltersProvider);
    ref.read(commissionsProvider.notifier).loadCommissions(
      type: filters.type,
      status: filters.status,
      tier: filters.tier,
      partnerId: filters.partnerId,
      startDate: filters.startDate,
      endDate: filters.endDate,
      searchQuery: filters.searchQuery,
    );
  }

  Future<void> _refreshData() async {
    ref.invalidate(commissionsProvider);
    ref.invalidate(commissionsAnalyticsProvider);
  }

  void _onCommissionTap(Commission commission) {
    if (_isSelectionMode) {
      _onSelectionChanged(commission.id, !_selectedCommissions.contains(commission.id));
    } else {
      // Navigate to commission details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('View details for commission ${commission.id}')),
      );
    }
  }

  void _onSelectionChanged(String commissionId, bool selected) {
    setState(() {
      if (selected) {
        _selectedCommissions.add(commissionId);
        if (!_isSelectionMode) {
          _isSelectionMode = true;
        }
      } else {
        _selectedCommissions.remove(commissionId);
        if (_selectedCommissions.isEmpty) {
          _isSelectionMode = false;
        }
      }
    });
  }

  void _selectAll() {
    final commissions = ref.read(commissionsProvider).value ?? [];
    setState(() {
      _selectedCommissions.addAll(commissions.map((c) => c.id));
      _isSelectionMode = true;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedCommissions.clear();
      _isSelectionMode = false;
    });
  }

  void _processPayments() {
    // TODO: Navigate to payment processing screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Process payments functionality')),
    );
  }

  void _addCommissionAdjustment() {
    // TODO: Navigate to add adjustment screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add commission adjustment')),
    );
  }

  void _updateCommissionStatus(String commissionId, CommissionStatus status) {
    // TODO: Implement status update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Update status to ${status.displayName}')),
    );
  }

  void _processCommissionPayment(String commissionId, String paymentRef, String method) {
    // TODO: Implement payment processing
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Process payment: $paymentRef via $method')),
    );
  }

  void _addAdjustment(String commissionId, String reason, double amount, AdjustmentType type) {
    // TODO: Implement adjustment addition
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Add ${type.displayName}: $reason (${amount.toStringAsFixed(2)})')),
    );
  }

  void _showBulkActions() {
    // TODO: Show bulk actions dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bulk actions for ${_selectedCommissions.length} commissions')),
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
      case 'reconcile':
        // TODO: Navigate to reconciliation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reconcile commissions')),
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
