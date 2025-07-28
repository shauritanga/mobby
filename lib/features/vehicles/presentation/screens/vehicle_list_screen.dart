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

  // Animation controllers for enhanced visual appeal
  late AnimationController _listAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;
  late Animation<Offset> _fabSlideAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Initialize animation controllers
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fabScaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fabAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _fabSlideAnimation =
        Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _fabAnimationController,
            curve: Curves.easeOutBack,
          ),
        );

    // Start animations
    _listAnimationController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _fabAnimationController.forward();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _listAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Tesla-like clean background
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return _buildNotSignedInState();
          }
          return _buildModernVehiclesContent(user.id);
        },
        loading: () => _buildModernLoadingState(),
        error: (error, stack) => _buildModernErrorState(error.toString()),
      ),
    );
  }

  Widget _buildModernVehiclesContent(String userId) {
    return CustomScrollView(
      slivers: [
        // Modern App Bar
        SliverAppBar(
          expandedHeight: 120.h,
          floating: true,
          pinned: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'My Vehicles',
                            style: TextStyle(
                              fontSize: 32.sp,
                              fontWeight:
                                  FontWeight.w300, // Tesla-like thin font
                              color: const Color(0xFF1A1A1A),
                              letterSpacing: -0.5,
                            ),
                          ),
                          const Spacer(),
                          _buildModernActionButton(
                            Icons.search_rounded,
                            () => setState(() => _isSearching = true),
                          ),
                          SizedBox(width: 12.w),
                          _buildModernActionButton(
                            Icons.add_rounded,
                            () => context.push('/vehicles/add'),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Manage your fleet with ease',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w400,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        // Modern Stats Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: _buildModernStatsSection(userId),
          ),
        ),

        // Modern Tab Section
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
            child: _buildModernTabBar(),
          ),
        ),

        // Vehicles List
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildModernVehiclesList(userId, null),
              _buildModernVehiclesList(userId, VehicleStatus.active),
              _buildModernAlertsTab(userId),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildModernActionButton(IconData icon, VoidCallback onPressed) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12.r),
          child: Icon(icon, size: 20.sp, color: const Color(0xFF374151)),
        ),
      ),
    );
  }

  Widget _buildModernStatsSection(String userId) {
    final statsAsync = ref.watch(vehicleStatisticsProvider(userId));

    return statsAsync.when(
      data: (stats) => Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: _buildStatItem(
                'Total',
                (stats['totalVehicles'] as int? ?? 0).toString(),
                Icons.directions_car_outlined,
                const Color(0xFF3B82F6),
              ),
            ),
            Container(width: 1, height: 40.h, color: const Color(0xFFE5E7EB)),
            Expanded(
              child: _buildStatItem(
                'Active',
                (stats['activeVehicles'] as int? ?? 0).toString(),
                Icons.check_circle_outline,
                const Color(0xFF10B981),
              ),
            ),
            Container(width: 1, height: 40.h, color: const Color(0xFFE5E7EB)),
            Expanded(
              child: _buildStatItem(
                'Alerts',
                ((stats['expiredDocuments'] as int? ?? 0) +
                        (stats['expiringSoonDocuments'] as int? ?? 0))
                    .toString(),
                Icons.warning_amber_outlined,
                const Color(0xFFF59E0B),
              ),
            ),
          ],
        ),
      ),
      loading: () => _buildStatsShimmer(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, size: 24.sp, color: color),
        ),
        SizedBox(height: 12.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }

  Widget _buildModernTabBar() {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: const Color(0xFF111827),
        unselectedLabelColor: const Color(0xFF6B7280),
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: const [
          Tab(text: 'All'),
          Tab(text: 'Active'),
          Tab(text: 'Alerts'),
        ],
      ),
    );
  }

  Widget _buildAppBarTitle() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.directions_car_rounded,
            size: 24.sp,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'My Vehicles',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.onSurface,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Manage your fleet',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Search vehicles...',
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 12.h,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 16.sp,
        ),
        onChanged: (value) {
          ref.read(vehicleFilterStateProvider.notifier).setSearchQuery(value);
        },
      ),
    );
  }

  Widget _buildModernVehiclesList(String userId, VehicleStatus? statusFilter) {
    return Consumer(
      builder: (context, ref, child) {
        final vehiclesAsync = statusFilter == null
            ? ref.watch(filteredVehiclesProvider)
            : ref.watch(userVehiclesProvider(userId));

        return vehiclesAsync.when(
          data: (vehicles) {
            final filteredVehicles = statusFilter == null
                ? vehicles
                : vehicles.where((v) => v.status == statusFilter).toList();

            if (filteredVehicles.isEmpty) {
              return _buildModernEmptyState();
            }

            return Container(
              color: const Color(0xFFF8F9FA),
              child: RefreshIndicator(
                onRefresh: () => _refreshVehicles(userId),
                color: const Color(0xFF3B82F6),
                child: ListView.builder(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  itemCount: filteredVehicles.length,
                  itemBuilder: (context, index) {
                    final vehicle = filteredVehicles[index];
                    return AnimatedBuilder(
                      animation: _listAnimationController,
                      builder: (context, child) {
                        final animationDelay = index * 0.1;
                        final animationValue = Curves.easeOutCubic.transform(
                          (_listAnimationController.value - animationDelay)
                              .clamp(0.0, 1.0),
                        );

                        return Transform.translate(
                          offset: Offset(0, 30 * (1 - animationValue)),
                          child: Opacity(
                            opacity: animationValue,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: _buildModernVehicleCard(vehicle),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            );
          },
          loading: () => _buildModernLoadingList(),
          error: (error, stack) => _buildModernErrorState(error.toString()),
        );
      },
    );
  }

  Widget _buildModernVehicleCard(Vehicle vehicle) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _viewVehicleDetails(vehicle.id),
          borderRadius: BorderRadius.circular(20.r),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Vehicle Image
                    Container(
                      width: 80.w,
                      height: 80.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF3B82F6).withOpacity(0.1),
                            const Color(0xFF8B5CF6).withOpacity(0.1),
                          ],
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16.r),
                        child: vehicle.primaryImageUrl != null
                            ? Image.network(
                                vehicle.primaryImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    _buildModernPlaceholderImage(),
                              )
                            : _buildModernPlaceholderImage(),
                      ),
                    ),
                    SizedBox(width: 20.w),
                    // Vehicle Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vehicle.displayName,
                                  style: TextStyle(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF111827),
                                    letterSpacing: -0.3,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              _buildModernStatusChip(vehicle.status),
                            ],
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12.w,
                              vertical: 6.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Text(
                              vehicle.plateNumber,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF374151),
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          SizedBox(height: 12.h),
                          Row(
                            children: [
                              _buildModernInfoChip(
                                Icons.palette_outlined,
                                vehicle.color,
                              ),
                              SizedBox(width: 8.w),
                              _buildModernInfoChip(
                                Icons.local_gas_station_outlined,
                                vehicle.fuelType.displayName,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernPlaceholderImage() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF3B82F6).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
        ),
      ),
      child: Icon(
        Icons.directions_car_outlined,
        size: 32.sp,
        color: const Color(0xFF6B7280),
      ),
    );
  }

  Widget _buildModernStatusChip(VehicleStatus status) {
    Color color;
    String text;

    switch (status) {
      case VehicleStatus.active:
        color = const Color(0xFF10B981);
        text = 'Active';
        break;
      case VehicleStatus.inactive:
        color = const Color(0xFF6B7280);
        text = 'Inactive';
        break;
      case VehicleStatus.scrapped:
        color = const Color(0xFFF59E0B);
        text = 'Scrapped';
        break;
      case VehicleStatus.sold:
        color = const Color(0xFFEF4444);
        text = 'Sold';
        break;
      case VehicleStatus.stolen:
        color = const Color(0xFFDC2626);
        text = 'Stolen';
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildModernInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12.sp, color: const Color(0xFF6B7280)),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF374151),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(60.r),
              ),
              child: Icon(
                Icons.directions_car_outlined,
                size: 48.sp,
                color: const Color(0xFF9CA3AF),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'No vehicles yet',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF111827),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add your first vehicle to get started',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            ElevatedButton.icon(
              onPressed: () => context.push('/vehicles/add'),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Vehicle'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
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
                    return AnimatedBuilder(
                      animation: _listAnimationController,
                      builder: (context, child) {
                        final animationDelay = index * 0.1;
                        final animationValue = Curves.easeOutBack.transform(
                          (_listAnimationController.value - animationDelay)
                              .clamp(0.0, 1.0),
                        );

                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - animationValue)),
                          child: Opacity(
                            opacity: animationValue,
                            child: Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: Hero(
                                tag: 'vehicle_card_${vehicle.id}',
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
                              ),
                            ),
                          ),
                        );
                      },
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

  Widget _buildModernLoadingState() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60.w,
              height: 60.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
                  strokeWidth: 3,
                ),
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              'Loading vehicles...',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF6B7280),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernLoadingList() {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
        itemCount: 3,
        itemBuilder: (context, index) => Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: _buildVehicleCardShimmer(),
        ),
      ),
    );
  }

  Widget _buildVehicleCardShimmer() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 20.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 8.h),
                Container(
                  width: 100.w,
                  height: 16.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF3F4F6),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Container(
                      width: 60.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 60.w,
                      height: 16.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsShimmer() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(child: _buildStatShimmerItem()),
          Container(width: 1, height: 40.h, color: const Color(0xFFE5E7EB)),
          Expanded(child: _buildStatShimmerItem()),
          Container(width: 1, height: 40.h, color: const Color(0xFFE5E7EB)),
          Expanded(child: _buildStatShimmerItem()),
        ],
      ),
    );
  }

  Widget _buildStatShimmerItem() {
    return Column(
      children: [
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: 40.w,
          height: 20.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          width: 60.w,
          height: 16.h,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ],
    );
  }

  Widget _buildModernErrorState(String error) {
    return Container(
      color: const Color(0xFFF8F9FA),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.w,
                height: 120.w,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2),
                  borderRadius: BorderRadius.circular(60.r),
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48.sp,
                  color: const Color(0xFFEF4444),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Something went wrong',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Unable to load vehicles. Please try again.',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF6B7280),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              ElevatedButton.icon(
                onPressed: () => ref.invalidate(userVehiclesProvider),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3B82F6),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 16.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernAlertsTab(String userId) {
    // For now, return a simple placeholder - you can implement this later
    return _buildModernEmptyState();
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
