import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/order.dart';
import '../../domain/usecases/process_orders.dart';
import '../providers/admin_order_providers.dart';
import '../widgets/order_list_item.dart';
import '../widgets/order_filters_panel.dart';
import '../widgets/order_search_bar.dart';
import '../widgets/orders_analytics_card.dart';

class OrderQueueScreen extends ConsumerStatefulWidget {
  const OrderQueueScreen({super.key});

  @override
  ConsumerState<OrderQueueScreen> createState() => _OrderQueueScreenState();
}

class _OrderQueueScreenState extends ConsumerState<OrderQueueScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  // Filter state
  OrderStatus? _selectedStatus;
  OrderPriority? _selectedPriority;
  PaymentStatus? _selectedPaymentStatus;
  String? _selectedAssignedTo;
  DateTime? _startDate;
  DateTime? _endDate;
  String _sortBy = 'updatedAt';
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Load initial orders
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadOrders(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMoreOrders();
    }
  }

  void _loadOrders({bool refresh = false}) {
    ref
        .read(ordersListProvider.notifier)
        .loadOrders(
          searchQuery: _searchController.text.isNotEmpty
              ? _searchController.text
              : null,
          status: _selectedStatus,
          priority: _selectedPriority,
          paymentStatus: _selectedPaymentStatus,
          assignedTo: _selectedAssignedTo,
          startDate: _startDate,
          endDate: _endDate,
          sortBy: _sortBy,
          sortDescending: _sortDescending,
          refresh: refresh,
        );
  }

  void _loadMoreOrders() {
    ref.read(ordersListProvider.notifier).loadMoreOrders();
  }

  void _onSearchChanged(String query) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == query) {
        _loadOrders(refresh: true);
      }
    });
  }

  void _onFiltersChanged({
    OrderStatus? status,
    OrderPriority? priority,
    PaymentStatus? paymentStatus,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    setState(() {
      _selectedStatus = status;
      _selectedPriority = priority;
      _selectedPaymentStatus = paymentStatus;
      _selectedAssignedTo = assignedTo;
      _startDate = startDate;
      _endDate = endDate;
    });
    _loadOrders(refresh: true);
  }

  void _onSortChanged(String sortBy, bool descending) {
    setState(() {
      _sortBy = sortBy;
      _sortDescending = descending;
    });
    _loadOrders(refresh: true);
  }

  void _navigateToOrderDetails(String orderId) {
    context.push('/admin/orders/$orderId');
  }

  void _showFiltersPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => OrderFiltersPanel(
        selectedStatus: _selectedStatus,
        selectedPriority: _selectedPriority,
        selectedPaymentStatus: _selectedPaymentStatus,
        selectedAssignedTo: _selectedAssignedTo,
        startDate: _startDate,
        endDate: _endDate,
        onFiltersChanged: _onFiltersChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(ordersListProvider);

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
                'Order Queue',
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
                  Icons.filter_list,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: _showFiltersPanel,
                tooltip: 'Filters',
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.sort,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onSelected: (value) {
                  final parts = value.split('_');
                  final sortBy = parts[0];
                  final descending = parts[1] == 'desc';
                  _onSortChanged(sortBy, descending);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'orderNumber_asc',
                    child: Text('Order Number (A-Z)'),
                  ),
                  const PopupMenuItem(
                    value: 'orderNumber_desc',
                    child: Text('Order Number (Z-A)'),
                  ),
                  const PopupMenuItem(
                    value: 'customerName_asc',
                    child: Text('Customer (A-Z)'),
                  ),
                  const PopupMenuItem(
                    value: 'customerName_desc',
                    child: Text('Customer (Z-A)'),
                  ),
                  const PopupMenuItem(
                    value: 'totalAmount_asc',
                    child: Text('Amount (Low-High)'),
                  ),
                  const PopupMenuItem(
                    value: 'totalAmount_desc',
                    child: Text('Amount (High-Low)'),
                  ),
                  const PopupMenuItem(
                    value: 'priority_desc',
                    child: Text('Priority (High-Low)'),
                  ),
                  const PopupMenuItem(
                    value: 'updatedAt_desc',
                    child: Text('Recently Updated'),
                  ),
                  const PopupMenuItem(
                    value: 'createdAt_desc',
                    child: Text('Recently Created'),
                  ),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => _loadOrders(refresh: true),
                tooltip: 'Refresh',
              ),
            ],
          ),

          // Analytics Card
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: const OrdersAnalyticsCard(),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: OrderSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onFilterPressed: _showFiltersPanel,
              ),
            ),
          ),

          SizedBox(height: 16.h).sliver,

          // Orders List
          ordersAsync.when(
            data: (ordersState) => _buildOrdersList(ordersState),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showBulkActions(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.checklist),
        label: const Text('Bulk Actions'),
      ),
    );
  }

  Widget _buildOrdersList(OrdersListState ordersState) {
    if (ordersState.orders.isEmpty && !ordersState.isLoading) {
      return _buildEmptyState();
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        if (index < ordersState.orders.length) {
          final order = ordersState.orders[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
            child: OrderListItem(
              order: order,
              onTap: () => _navigateToOrderDetails(order.id),
              onStatusChanged: (status) => _updateOrderStatus(order.id, status),
              onPriorityChanged: (priority) =>
                  _updateOrderPriority(order.id, priority),
              onAssign: (userId, userName) =>
                  _assignOrder(order.id, userId, userName),
              onUnassign: () => _unassignOrder(order.id),
            ),
          );
        } else if (ordersState.hasMore) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          );
        }
        return null;
      }, childCount: ordersState.orders.length + (ordersState.hasMore ? 1 : 0)),
    );
  }

  Widget _buildLoadingState() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: _buildSkeletonCard(),
        ),
        childCount: 10,
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 140.h,
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

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shopping_cart_outlined,
                size: 64.r,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: 16.h),
              Text(
                'No Orders Found',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'No orders match your current filters',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedStatus = null;
                    _selectedPriority = null;
                    _selectedPaymentStatus = null;
                    _selectedAssignedTo = null;
                    _startDate = null;
                    _endDate = null;
                    _searchController.clear();
                  });
                  _loadOrders(refresh: true);
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ),
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
                'Error Loading Orders',
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
                onPressed: () => _loadOrders(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final updateOrderStatusUseCase = ref.read(
        updateOrderStatusUseCaseProvider,
      );
      await updateOrderStatusUseCase(
        UpdateOrderStatusParams(orderId: orderId, status: status),
      );

      _loadOrders(refresh: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to ${status.displayName}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order status: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _updateOrderPriority(String orderId, OrderPriority priority) async {
    try {
      final updateOrderPriorityUseCase = ref.read(
        updateOrderPriorityUseCaseProvider,
      );
      await updateOrderPriorityUseCase(
        UpdateOrderPriorityParams(orderId: orderId, priority: priority),
      );

      _loadOrders(refresh: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order priority updated to ${priority.displayName}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update order priority: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _assignOrder(String orderId, String userId, String userName) async {
    try {
      final assignOrderUseCase = ref.read(assignOrderUseCaseProvider);
      await assignOrderUseCase(
        AssignOrderParams(
          orderId: orderId,
          assignedTo: userId,
          assignedToName: userName,
        ),
      );

      _loadOrders(refresh: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order assigned to $userName'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to assign order: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _unassignOrder(String orderId) async {
    try {
      final unassignOrderUseCase = ref.read(unassignOrderUseCaseProvider);
      await unassignOrderUseCase(orderId);

      _loadOrders(refresh: true);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Order unassigned'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to unassign order: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _showBulkActions() {
    // TODO: Implement bulk actions dialog
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Bulk actions coming soon')));
  }
}

extension SliverBoxWidget on Widget {
  Widget get sliver => SliverToBoxAdapter(child: this);
}
