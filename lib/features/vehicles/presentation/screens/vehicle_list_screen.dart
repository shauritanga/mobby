import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/vehicle_providers.dart';
import '../providers/vehicle_operations_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/vehicle_card.dart';
import '../widgets/vehicle_filter_bar.dart';
import '../widgets/vehicle_stats_card.dart';
import '../widgets/vehicle_alerts_card.dart';
import '../widgets/vehicle_empty_state.dart';
import '../../domain/entities/vehicle.dart';

/// Vehicle List Screen
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
/// Main screen showing user's registered vehicles with add/edit capabilities
class VehicleListScreen extends ConsumerStatefulWidget {
  const VehicleListScreen({super.key});

  @override
  ConsumerState<VehicleListScreen> createState() => _VehicleListScreenState();
}

class _VehicleListScreenState extends ConsumerState<VehicleListScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  bool _isSearching = false;

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
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : const Text('My Vehicles'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 3, // Increased for better Material 3 compliance
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  ref
                      .read(vehicleFilterStateProvider.notifier)
                      .setSearchQuery(null);
                }
              });
            },
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'filter',
                child: ListTile(
                  leading: Icon(Icons.filter_list),
                  title: Text('Filter Vehicles'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'sort',
                child: ListTile(
                  leading: Icon(Icons.sort),
                  title: Text('Sort Vehicles'),
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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Vehicles'),
            Tab(text: 'Active'),
            Tab(text: 'Alerts'),
          ],
        ),
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return _buildNotSignedInState();
          }
          return _buildVehiclesContent(user.id);
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/vehicles/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add Vehicle'),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search vehicles...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Theme.of(context).hintColor),
      ),
      style: TextStyle(
        color: Theme.of(context).textTheme.titleLarge?.color,
        fontSize: 18.sp,
      ),
      onChanged: (value) {
        ref.read(vehicleFilterStateProvider.notifier).setSearchQuery(value);
      },
    );
  }

  Widget _buildVehiclesContent(String userId) {
    return Column(
      children: [
        // Vehicle Filter Bar
        const VehicleFilterBar(),

        // Vehicle Stats Card
        Padding(
          padding: EdgeInsets.all(16.w),
          child: VehicleStatsCard(userId: userId),
        ),

        // Alerts Card
        const VehicleAlertsCard(),

        // Vehicles List
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildVehiclesList(userId, null),
              _buildVehiclesList(userId, VehicleStatus.active),
              _buildAlertsTab(userId),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildVehiclesList(String userId, VehicleStatus? statusFilter) {
    return Consumer(
      builder: (context, ref, child) {
        final vehiclesAsync = statusFilter == null
            ? ref.watch(filteredVehiclesProvider)
            : ref.watch(userVehiclesProvider(userId));

        return vehiclesAsync.when(
          data: (vehicles) {
            // Apply status filter if specified
            var filteredVehicles = vehicles;
            if (statusFilter != null) {
              filteredVehicles = vehicles
                  .where((v) => v.status == statusFilter)
                  .toList();
            }

            if (filteredVehicles.isEmpty) {
              return VehicleEmptyState(
                onAddVehicle: () => context.push('/vehicles/add'),
                onRefresh: () => _refreshVehicles(userId),
              );
            }

            return Container(
              // Use surfaceContainerLowest for the main background to create depth
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              child: RefreshIndicator(
                onRefresh: () => _refreshVehicles(userId),
                child: ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: filteredVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = filteredVehicles[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: VehicleCard(
                        vehicle: vehicle,
                        onTap: () => _viewVehicleDetails(vehicle.id),
                        onEdit: () => _editVehicle(vehicle.id),
                        onDelete: () => _deleteVehicle(vehicle),
                        onViewDocuments: () =>
                            _viewVehicleDocuments(vehicle.id),
                        onViewMaintenance: () =>
                            _viewVehicleMaintenance(vehicle.id),
                      ),
                    );
                  },
                ),
              ),
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  Widget _buildAlertsTab(String userId) {
    return Consumer(
      builder: (context, ref, child) {
        final alertsAsync = ref.watch(vehicleAlertsProvider);

        return alertsAsync.when(
          data: (alerts) {
            final expiredDocs = alerts['expiredDocuments'] ?? [];
            final expiringSoonDocs = alerts['expiringSoonDocuments'] ?? [];
            final overdueMaintenance = alerts['overdueMaintenance'] ?? [];

            final hasAlerts =
                expiredDocs.isNotEmpty ||
                expiringSoonDocs.isNotEmpty ||
                overdueMaintenance.isNotEmpty;

            if (!hasAlerts) {
              return _buildNoAlertsState();
            }

            return ListView(
              padding: EdgeInsets.all(16.w),
              children: [
                if (expiredDocs.isNotEmpty) ...[
                  _buildAlertSection(
                    'Expired Documents',
                    expiredDocs.length,
                    Icons.warning,
                    Colors.red,
                    () => _viewExpiredDocuments(),
                  ),
                  SizedBox(height: 16.h),
                ],

                if (expiringSoonDocs.isNotEmpty) ...[
                  _buildAlertSection(
                    'Documents Expiring Soon',
                    expiringSoonDocs.length,
                    Icons.schedule,
                    Colors.orange,
                    () => _viewExpiringSoonDocuments(),
                  ),
                  SizedBox(height: 16.h),
                ],

                if (overdueMaintenance.isNotEmpty) ...[
                  _buildAlertSection(
                    'Overdue Maintenance',
                    overdueMaintenance.length,
                    Icons.build,
                    Colors.amber,
                    () => _viewOverdueMaintenance(),
                  ),
                ],
              ],
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  Widget _buildAlertSection(
    String title,
    int count,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 40.w,
          height: 40.w,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        title: Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '$count item${count > 1 ? 's' : ''} need${count == 1 ? 's' : ''} attention',
          style: TextStyle(
            fontSize: 14.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 16.sp,
          color: Theme.of(context).hintColor,
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildNoAlertsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 100.sp, color: Colors.green),
          SizedBox(height: 24.h),
          Text(
            'All Good!',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'No alerts for your vehicles',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
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
            'Failed to load vehicles',
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
                ref.invalidate(userVehiclesProvider(currentUser.id));
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
            Icons.directions_car,
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
            'Please sign in to manage your vehicles',
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

  void _handleMenuAction(String action) {
    switch (action) {
      case 'filter':
        _showFilterDialog();
        break;
      case 'sort':
        _showSortDialog();
        break;
      case 'refresh':
        final currentUser = ref.read(currentUserProvider).value;
        if (currentUser != null) {
          _refreshVehicles(currentUser.id);
        }
        break;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Vehicles'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Vehicle type filter
            ListTile(
              leading: const Icon(Icons.directions_car),
              title: const Text('Vehicle Type'),
              subtitle: const Text('Filter by vehicle type'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show vehicle type filter
              },
            ),
            // Status filter
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('Status'),
              subtitle: const Text('Filter by vehicle status'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show status filter
              },
            ),
            // Fuel type filter
            ListTile(
              leading: const Icon(Icons.local_gas_station),
              title: const Text('Fuel Type'),
              subtitle: const Text('Filter by fuel type'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Show fuel type filter
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(vehicleFilterStateProvider.notifier).clearFilters();
            },
            child: const Text('Clear All'),
          ),
        ],
      ),
    );
  }

  void _showSortDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sort Vehicles'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Date Added (Newest)'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sorting
              },
            ),
            ListTile(
              title: const Text('Date Added (Oldest)'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sorting
              },
            ),
            ListTile(
              title: const Text('Make & Model'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sorting
              },
            ),
            ListTile(
              title: const Text('Year'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Implement sorting
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshVehicles(String userId) async {
    ref.invalidate(userVehiclesProvider(userId));
    ref.invalidate(vehicleStatisticsProvider(userId));
    ref.invalidate(vehicleAlertsProvider);
  }

  void _viewVehicleDetails(String vehicleId) {
    context.push('/vehicles/$vehicleId');
  }

  void _editVehicle(String vehicleId) {
    context.push('/vehicles/$vehicleId/edit');
  }

  void _deleteVehicle(Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: Text(
          'Are you sure you want to delete ${vehicle.displayName}? This action cannot be undone.',
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
                final operations = ref.read(vehicleOperationsProvider);
                await operations.deleteVehicle(vehicle.id, vehicle.userId);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vehicle deleted successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to delete vehicle: $e'),
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

  void _viewVehicleDocuments(String vehicleId) {
    context.push('/vehicles/$vehicleId/documents');
  }

  void _viewVehicleMaintenance(String vehicleId) {
    context.push('/vehicles/$vehicleId/maintenance');
  }

  void _viewExpiredDocuments() {
    context.push('/vehicles/documents/expired');
  }

  void _viewExpiringSoonDocuments() {
    context.push('/vehicles/documents/expiring-soon');
  }

  void _viewOverdueMaintenance() {
    context.push('/vehicles/maintenance/overdue');
  }
}
