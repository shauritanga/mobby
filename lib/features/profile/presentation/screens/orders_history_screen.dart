import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/order_card.dart';
import '../widgets/order_filter_chips.dart';
import '../widgets/order_empty_state.dart';

/// Orders History Screen
/// Following specifications from FEATURES_DOCUMENTATION.md - Implement order history screen
/// showing user's past orders, order status, and order details navigation
class OrdersHistoryScreen extends ConsumerStatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  ConsumerState<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends ConsumerState<OrdersHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  final _searchController = TextEditingController();
  bool _isSearching = false;

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
    final currentUserAsync = ref.watch(currentUserProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: _isSearching ? _buildSearchField() : const Text('Order History'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
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
                  title: Text('Filter Orders'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Orders'),
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
            Tab(text: 'All'),
            Tab(text: 'Pending'),
            Tab(text: 'Delivered'),
            Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return _buildNotSignedInState();
          }
          return _buildOrdersContent(user.id);
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      controller: _searchController,
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search orders...',
        border: InputBorder.none,
        hintStyle: TextStyle(
          color: Theme.of(context).hintColor,
        ),
      ),
      style: TextStyle(
        color: Theme.of(context).textTheme.titleLarge?.color,
        fontSize: 18.sp,
      ),
      onChanged: (value) {
        // TODO: Implement search functionality
      },
    );
  }

  Widget _buildOrdersContent(String userId) {
    return Column(
      children: [
        // Filter Chips
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: OrderFilterChips(
            selectedFilter: _selectedFilter,
            onFilterChanged: (filter) {
              setState(() {
                _selectedFilter = filter;
              });
            },
          ),
        ),
        
        // Orders List
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildOrdersList(userId, 'all'),
              _buildOrdersList(userId, 'pending'),
              _buildOrdersList(userId, 'delivered'),
              _buildOrdersList(userId, 'cancelled'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildOrdersList(String userId, String status) {
    // TODO: Replace with actual orders provider
    // For now, we'll show sample data or empty state
    return _buildSampleOrdersList(status);
  }

  Widget _buildSampleOrdersList(String status) {
    // Sample orders data - in real implementation, this would come from a provider
    final sampleOrders = _getSampleOrders(status);
    
    if (sampleOrders.isEmpty) {
      return OrderEmptyState(
        status: status,
        onRefresh: () => _refreshOrders(),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshOrders(),
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: sampleOrders.length,
        itemBuilder: (context, index) {
          final order = sampleOrders[index];
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: OrderCard(
              order: order,
              onTap: () => _viewOrderDetails(order['id']),
              onReorder: () => _reorderItems(order['id']),
              onTrack: () => _trackOrder(order['id']),
              onCancel: order['status'] == 'pending' 
                  ? () => _cancelOrder(order['id'])
                  : null,
            ),
          );
        },
      ),
    );
  }

  List<Map<String, dynamic>> _getSampleOrders(String status) {
    final allOrders = [
      {
        'id': 'ORD-001',
        'orderNumber': '#ORD-001',
        'date': DateTime.now().subtract(const Duration(days: 2)),
        'status': 'delivered',
        'total': 125000.0,
        'currency': 'TZS',
        'itemCount': 3,
        'items': [
          {'name': 'Brake Pads', 'quantity': 2},
          {'name': 'Engine Oil', 'quantity': 1},
        ],
        'deliveryAddress': 'Dar es Salaam, Tanzania',
      },
      {
        'id': 'ORD-002',
        'orderNumber': '#ORD-002',
        'date': DateTime.now().subtract(const Duration(days: 5)),
        'status': 'pending',
        'total': 85000.0,
        'currency': 'TZS',
        'itemCount': 2,
        'items': [
          {'name': 'Air Filter', 'quantity': 1},
          {'name': 'Spark Plugs', 'quantity': 4},
        ],
        'deliveryAddress': 'Arusha, Tanzania',
      },
      {
        'id': 'ORD-003',
        'orderNumber': '#ORD-003',
        'date': DateTime.now().subtract(const Duration(days: 10)),
        'status': 'cancelled',
        'total': 45000.0,
        'currency': 'TZS',
        'itemCount': 1,
        'items': [
          {'name': 'Tire Pressure Gauge', 'quantity': 1},
        ],
        'deliveryAddress': 'Mwanza, Tanzania',
      },
      {
        'id': 'ORD-004',
        'orderNumber': '#ORD-004',
        'date': DateTime.now().subtract(const Duration(days: 15)),
        'status': 'delivered',
        'total': 200000.0,
        'currency': 'TZS',
        'itemCount': 5,
        'items': [
          {'name': 'Car Battery', 'quantity': 1},
          {'name': 'Headlight Bulbs', 'quantity': 2},
          {'name': 'Windshield Wipers', 'quantity': 2},
        ],
        'deliveryAddress': 'Dodoma, Tanzania',
      },
    ];

    if (status == 'all') {
      return allOrders;
    }
    
    return allOrders.where((order) => order['status'] == status).toList();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
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
            'Failed to load orders',
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
              // Refresh orders
              _refreshOrders();
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
            Icons.shopping_bag_outlined,
            size: 100.sp,
            color: Theme.of(context).hintColor,
          ),
          SizedBox(height: 24.h),
          Text(
            'Not Signed In',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please sign in to view your orders',
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
      case 'export':
        _exportOrders();
        break;
      case 'refresh':
        _refreshOrders();
        break;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Orders'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Date range filter
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Date Range'),
              subtitle: const Text('Last 30 days'),
              onTap: () {
                // TODO: Implement date range picker
              },
            ),
            // Amount filter
            ListTile(
              leading: const Icon(Icons.attach_money),
              title: const Text('Amount Range'),
              subtitle: const Text('Any amount'),
              onTap: () {
                // TODO: Implement amount range picker
              },
            ),
            // Status filter
            ListTile(
              leading: const Icon(Icons.filter_list),
              title: const Text('Status'),
              subtitle: const Text('All statuses'),
              onTap: () {
                // TODO: Implement status filter
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
              // TODO: Apply filters
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _exportOrders() {
    // TODO: Implement export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Export orders feature coming soon')),
    );
  }

  Future<void> _refreshOrders() async {
    // TODO: Implement refresh functionality
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Orders refreshed')),
      );
    }
  }

  void _viewOrderDetails(String orderId) {
    // TODO: Navigate to order details screen
    context.push('/orders/$orderId');
  }

  void _reorderItems(String orderId) {
    // TODO: Implement reorder functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reorder feature coming soon')),
    );
  }

  void _trackOrder(String orderId) {
    // TODO: Implement order tracking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order tracking feature coming soon')),
    );
  }

  void _cancelOrder(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Order'),
        content: const Text(
          'Are you sure you want to cancel this order? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Keep Order'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement cancel order functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Order cancelled successfully')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cancel Order'),
          ),
        ],
      ),
    );
  }
}
