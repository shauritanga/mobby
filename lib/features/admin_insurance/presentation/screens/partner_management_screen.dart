import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/insurance_partner.dart';
import '../providers/admin_insurance_providers.dart';
import '../widgets/partner_analytics_card.dart';
import '../widgets/partner_search_bar.dart';
import '../widgets/partner_list_item.dart';
import '../widgets/partner_filters_panel.dart';

/// Partner Management Screen for Admin Insurance Management
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin Insurance Management Feature
class PartnerManagementScreen extends ConsumerStatefulWidget {
  const PartnerManagementScreen({super.key});

  @override
  ConsumerState<PartnerManagementScreen> createState() => _PartnerManagementScreenState();
}

class _PartnerManagementScreenState extends ConsumerState<PartnerManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedPartners = {};
  bool _isSelectionMode = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final partnersAsync = ref.watch(partnersProvider);
    final filters = ref.watch(partnerFiltersProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Partner Management',
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
            icon: const Icon(Icons.add),
            onPressed: _addPartner,
            tooltip: 'Add Partner',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'refresh', child: Text('Refresh')),
              const PopupMenuItem(value: 'export', child: Text('Export Data')),
              const PopupMenuItem(value: 'settings', child: Text('Settings')),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Partners', icon: Icon(Icons.business)),
            Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPartnersTab(partnersAsync, filters),
          _buildAnalyticsTab(),
        ],
      ),
      floatingActionButton: _isSelectionMode
          ? FloatingActionButton.extended(
              onPressed: _showBulkActions,
              icon: const Icon(Icons.edit),
              label: Text('Actions (${_selectedPartners.length})'),
            )
          : null,
    );
  }

  Widget _buildPartnersTab(AsyncValue<List<InsurancePartner>> partnersAsync, PartnerFilters filters) {
    return Column(
      children: [
        // Search and Filters
        Padding(
          padding: EdgeInsets.all(16.w),
          child: PartnerSearchBar(
            controller: _searchController,
            onChanged: _onSearchChanged,
            onFilterPressed: _showFilters,
          ),
        ),

        // Partners List
        Expanded(
          child: partnersAsync.when(
            data: (partners) => _buildPartnersList(partners),
            loading: () => _buildLoadingList(),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyticsTab() {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        children: [
          PartnerAnalyticsCard(),
          // Add more analytics widgets here
        ],
      ),
    );
  }

  Widget _buildPartnersList(List<InsurancePartner> partners) {
    if (partners.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: partners.length,
        itemBuilder: (context, index) {
          final partner = partners[index];
          final isSelected = _selectedPartners.contains(partner.id);

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: PartnerListItem(
              partner: partner,
              isSelected: isSelected,
              isSelectionMode: _isSelectionMode,
              onTap: () => _onPartnerTap(partner),
              onSelectionChanged: (selected) => _onSelectionChanged(partner.id, selected),
              onStatusChanged: (status) => _updatePartnerStatus(partner.id, status),
              onEdit: () => _editPartner(partner),
              onDelete: () => _deletePartner(partner.id),
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
        child: _buildSkeletonPartnerCard(),
      ),
    );
  }

  Widget _buildSkeletonPartnerCard() {
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
            Icons.business_outlined,
            size: 64.r,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Partners Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add your first insurance partner to get started.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _addPartner,
            icon: const Icon(Icons.add),
            label: const Text('Add Partner'),
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
            'Error Loading Partners',
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
    final currentFilters = ref.read(partnerFiltersProvider);
    ref.read(partnerFiltersProvider.notifier).state = currentFilters.copyWith(
      searchQuery: query.isEmpty ? null : query,
    );
    _applyFilters();
  }

  void _showFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PartnerFiltersPanel(
        currentFilters: ref.read(partnerFiltersProvider),
        onFiltersChanged: (filters) {
          ref.read(partnerFiltersProvider.notifier).state = filters;
          _applyFilters();
        },
      ),
    );
  }

  void _applyFilters() {
    final filters = ref.read(partnerFiltersProvider);
    ref.read(partnersProvider.notifier).loadPartners(
      type: filters.type,
      status: filters.status,
      startDate: filters.startDate,
      endDate: filters.endDate,
      searchQuery: filters.searchQuery,
    );
  }

  Future<void> _refreshData() async {
    ref.invalidate(partnersProvider);
    ref.invalidate(partnersAnalyticsProvider);
  }

  void _onPartnerTap(InsurancePartner partner) {
    if (_isSelectionMode) {
      _onSelectionChanged(partner.id, !_selectedPartners.contains(partner.id));
    } else {
      // Navigate to partner details
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('View details for ${partner.name}')),
      );
    }
  }

  void _onSelectionChanged(String partnerId, bool selected) {
    setState(() {
      if (selected) {
        _selectedPartners.add(partnerId);
        if (!_isSelectionMode) {
          _isSelectionMode = true;
        }
      } else {
        _selectedPartners.remove(partnerId);
        if (_selectedPartners.isEmpty) {
          _isSelectionMode = false;
        }
      }
    });
  }

  void _selectAll() {
    final partners = ref.read(partnersProvider).value ?? [];
    setState(() {
      _selectedPartners.addAll(partners.map((p) => p.id));
      _isSelectionMode = true;
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPartners.clear();
      _isSelectionMode = false;
    });
  }

  void _addPartner() {
    // TODO: Navigate to add partner screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Add partner functionality')),
    );
  }

  void _editPartner(InsurancePartner partner) {
    // TODO: Navigate to edit partner screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Edit ${partner.name}')),
    );
  }

  void _deletePartner(String partnerId) {
    // TODO: Implement partner deletion
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Delete partner functionality')),
    );
  }

  void _updatePartnerStatus(String partnerId, PartnerStatus status) {
    // TODO: Implement status update
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Update status to ${status.displayName}')),
    );
  }

  void _showBulkActions() {
    // TODO: Show bulk actions dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bulk actions for ${_selectedPartners.length} partners')),
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
      case 'settings':
        // TODO: Navigate to settings
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings')),
        );
        break;
    }
  }
}
