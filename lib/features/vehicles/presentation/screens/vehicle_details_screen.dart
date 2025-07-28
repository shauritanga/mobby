import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/vehicle_providers.dart';
import '../providers/vehicle_operations_providers.dart';
import '../widgets/vehicle_info_card.dart';
import '../widgets/vehicle_documents_summary.dart';
import '../widgets/vehicle_maintenance_summary.dart';
import '../widgets/vehicle_image_gallery.dart';
import '../../domain/entities/vehicle.dart';

/// Vehicle Details Screen
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
/// Display comprehensive vehicle information with documents and maintenance overview
class VehicleDetailsScreen extends ConsumerStatefulWidget {
  final String vehicleId;

  const VehicleDetailsScreen({super.key, required this.vehicleId});

  @override
  ConsumerState<VehicleDetailsScreen> createState() =>
      _VehicleDetailsScreenState();
}

class _VehicleDetailsScreenState extends ConsumerState<VehicleDetailsScreen>
    with TickerProviderStateMixin {
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
    final vehicleAsync = ref.watch(vehicleByIdProvider(widget.vehicleId));

    return vehicleAsync.when(
      data: (vehicle) {
        if (vehicle == null) {
          return _buildNotFoundScreen();
        }
        return _buildVehicleDetails(vehicle);
      },
      loading: () => _buildLoadingScreen(),
      error: (error, stack) => _buildErrorScreen(error.toString()),
    );
  }

  Widget _buildVehicleDetails(Vehicle vehicle) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.surfaceContainerLowest,
              Theme.of(context).colorScheme.surface.withValues(alpha: 0.8),
              Theme.of(
                context,
              ).colorScheme.surfaceContainer.withValues(alpha: 0.3),
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            // Enhanced App Bar with Vehicle Image - with comprehensive null safety
            SliverAppBar(
              expandedHeight: 320.h,
              pinned: true,
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              flexibleSpace: _buildSafeFlexibleSpaceBar(vehicle),
              actions: [
                PopupMenuButton<String>(
                  onSelected: (action) => _handleAction(action, vehicle),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit),
                        title: Text('Edit Vehicle'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'share',
                      child: ListTile(
                        leading: Icon(Icons.share),
                        title: Text('Share'),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete, color: Colors.red),
                        title: Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Enhanced Vehicle Information Section
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Enhanced Quick Info Row
                    Row(
                      children: [
                        Expanded(
                          child: _buildQuickInfoCard(
                            Icons.calendar_today_rounded,
                            'Year',
                            vehicle.year.toString(),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildQuickInfoCard(
                            Icons.speed_rounded,
                            'Mileage',
                            vehicle.mileage != null
                                ? '${_formatMileage(vehicle.mileage ?? 0)} km'
                                : 'N/A',
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: _buildQuickInfoCard(
                            Icons.local_gas_station_rounded,
                            'Fuel',
                            vehicle.fuelType.displayName,
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // Vehicle Information Card
                    VehicleInfoCard(vehicle: vehicle),

                    SizedBox(height: 16.h),

                    // Enhanced Tab Section
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Theme.of(context).colorScheme.surface,
                            Theme.of(context).colorScheme.surfaceContainer
                                .withValues(alpha: 0.3),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20.r),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.1),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.shadow.withValues(alpha: 0.1),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.shadow.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Container(
                            margin: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: TabBar(
                              controller: _tabController,
                              indicator: BoxDecoration(
                                borderRadius: BorderRadius.circular(14.r),
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.8),
                                  ],
                                ),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              dividerColor: Colors.transparent,
                              labelColor: Theme.of(
                                context,
                              ).colorScheme.onPrimary,
                              unselectedLabelColor: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.7),
                              labelStyle: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                              unselectedLabelStyle: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              tabs: const [
                                Tab(text: 'Documents'),
                                Tab(text: 'Maintenance'),
                                Tab(text: 'Photos'),
                              ],
                            ),
                          ),

                          SizedBox(
                            height: 400.h,
                            child: TabBarView(
                              controller: _tabController,
                              children: [
                                VehicleDocumentsSummary(
                                  vehicleId: widget.vehicleId,
                                ),
                                VehicleMaintenanceSummary(
                                  vehicleId: widget.vehicleId,
                                ),
                                VehicleImageGallery(vehicle: vehicle),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

      // Enhanced Floating Action Buttons
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.secondary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              heroTag: 'add_document',
              onPressed: () =>
                  context.push('/vehicles/${widget.vehicleId}/documents/add'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(
                Icons.description_rounded,
                color: Theme.of(context).colorScheme.onSecondary,
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton(
              heroTag: 'edit_vehicle',
              onPressed: () =>
                  context.push('/vehicles/${widget.vehicleId}/edit'),
              backgroundColor: Colors.transparent,
              elevation: 0,
              child: Icon(
                Icons.edit_rounded,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build FlexibleSpaceBar with comprehensive null safety
  Widget _buildSafeFlexibleSpaceBar(Vehicle vehicle) {
    try {
      return FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(left: 16.w, bottom: 16.h, right: 80.w),
        title: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Text(
            vehicle.displayName,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: -0.5,
              shadows: [
                Shadow(
                  offset: const Offset(0, 1),
                  blurRadius: 4,
                  color: Colors.black.withValues(alpha: 0.8),
                ),
              ],
            ),
          ),
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Vehicle Image with enhanced null safety
            Builder(
              builder: (context) {
                try {
                  final imageUrl = vehicle.primaryImageUrl;
                  if (imageUrl != null && imageUrl.isNotEmpty) {
                    return CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildImagePlaceholder(),
                      errorWidget: (context, url, error) =>
                          _buildImagePlaceholder(),
                    );
                  }
                  return _buildImagePlaceholder();
                } catch (e) {
                  return _buildImagePlaceholder();
                }
              },
            ),

            // Enhanced Gradient Overlay for better readability
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.1),
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.6, 1.0],
                ),
              ),
            ),

            // Vehicle Status Badge with null safety
            Positioned(
              top: 100.h,
              right: 16.w,
              child: _buildStatusBadge(vehicle.status),
            ),
          ],
        ),
      );
    } catch (e) {
      // Fallback FlexibleSpaceBar in case of any errors
      return FlexibleSpaceBar(
        title: Text(
          'Vehicle Details',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        background: _buildImagePlaceholder(),
      );
    }
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.directions_car, size: 80.sp, color: Colors.grey[600]),
          SizedBox(height: 16.h),
          Text(
            'No Image',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(VehicleStatus status) {
    Color backgroundColor;
    Color textColor;
    String text;
    IconData icon;

    switch (status) {
      case VehicleStatus.active:
        backgroundColor = Colors.green.shade600;
        textColor = Colors.white;
        text = 'Active';
        icon = Icons.check_circle_rounded;
        break;
      case VehicleStatus.inactive:
        backgroundColor = Colors.grey.shade600;
        textColor = Colors.white;
        text = 'Inactive';
        icon = Icons.pause_circle_rounded;
        break;
      case VehicleStatus.sold:
        backgroundColor = Colors.blue.shade600;
        textColor = Colors.white;
        text = 'Sold';
        icon = Icons.sell_rounded;
        break;
      case VehicleStatus.scrapped:
        backgroundColor = Colors.red.shade600;
        textColor = Colors.white;
        text = 'Scrapped';
        icon = Icons.delete_forever_rounded;
        break;
      case VehicleStatus.stolen:
        backgroundColor = Colors.purple.shade600;
        textColor = Colors.white;
        text = 'Stolen';
        icon = Icons.warning_rounded;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [backgroundColor, backgroundColor.withValues(alpha: 0.8)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: backgroundColor.withValues(alpha: 0.4),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16.sp, color: textColor),
          SizedBox(width: 6.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: textColor,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickInfoCard(IconData icon, String label, String value) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(
              context,
            ).colorScheme.surfaceContainer.withValues(alpha: 0.5),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
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
              icon,
              size: 28.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.7),
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Widget _buildErrorScreen(String error) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Center(
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
              'Failed to load vehicle',
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
                ref.invalidate(vehicleByIdProvider(widget.vehicleId));
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundScreen() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vehicle Details'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64.sp,
              color: Theme.of(context).hintColor,
            ),
            SizedBox(height: 16.h),
            Text(
              'Vehicle Not Found',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Text(
              'The vehicle you are looking for does not exist or has been removed.',
              style: TextStyle(
                fontSize: 14.sp,
                color: Theme.of(context).hintColor,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatMileage(int mileage) {
    if (mileage >= 1000000) {
      return '${(mileage / 1000000).toStringAsFixed(1)}M';
    } else if (mileage >= 1000) {
      return '${(mileage / 1000).toStringAsFixed(1)}K';
    } else {
      return mileage.toString();
    }
  }

  void _handleAction(String action, Vehicle vehicle) {
    switch (action) {
      case 'edit':
        context.push('/vehicles/${vehicle.id}/edit');
        break;
      case 'share':
        _shareVehicle(vehicle);
        break;
      case 'delete':
        _showDeleteConfirmation(vehicle);
        break;
    }
  }

  void _shareVehicle(Vehicle vehicle) {
    // TODO: Implement vehicle sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _showDeleteConfirmation(Vehicle vehicle) {
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
              await _deleteVehicle(vehicle);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle(Vehicle vehicle) async {
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
        context.pop();
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
  }
}
