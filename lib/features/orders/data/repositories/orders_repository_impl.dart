import '../../domain/entities/order.dart';
import '../../domain/entities/order_item.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/entities/return.dart';
import '../../domain/repositories/orders_repository.dart';
import '../datasources/orders_remote_datasource.dart';
import '../datasources/orders_local_datasource.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../models/return_model.dart';

class OrdersRepositoryImpl implements OrdersRepository {
  final OrdersRemoteDataSource _remoteDataSource;
  final OrdersLocalDataSource _localDataSource;

  OrdersRepositoryImpl({
    required OrdersRemoteDataSource remoteDataSource,
    required OrdersLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<List<Order>> getUserOrders(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('📦 Fetching user orders from remote...');
      final remoteOrders = await _remoteDataSource.getUserOrders(
        userId,
        page: page,
        limit: limit,
      );
      final orders = remoteOrders.map((model) => model.toEntity()).toList();

      // Cache the results
      await _localDataSource.cacheOrders(remoteOrders, userId);

      print('✅ Found ${orders.length} orders from remote');
      return orders;
    } catch (e) {
      print('❌ Error fetching orders from remote: $e');
      // Fallback to local cache
      final cachedOrders = await _localDataSource.getCachedOrders(userId);
      print('📱 Found ${cachedOrders.length} orders from cache');
      return cachedOrders.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    try {
      print('📦 Fetching order details from remote...');
      final remoteOrder = await _remoteDataSource.getOrderById(orderId);
      if (remoteOrder != null) {
        await _localDataSource.cacheOrder(remoteOrder);
        return remoteOrder.toEntity();
      }
      return null;
    } catch (e) {
      print('❌ Error fetching order from remote: $e');
      // Fallback to local cache
      final cachedOrder = await _localDataSource.getCachedOrder(orderId);
      return cachedOrder?.toEntity();
    }
  }

  @override
  Future<Order> createOrder(Order order) async {
    try {
      final orderModel = OrderModel.fromEntity(order);
      final createdOrder = await _remoteDataSource.createOrder(orderModel);
      await _localDataSource.cacheOrder(createdOrder);
      return createdOrder.toEntity();
    } catch (e) {
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<Order> updateOrder(Order order) async {
    try {
      final orderModel = OrderModel.fromEntity(order);
      final updatedOrder = await _remoteDataSource.updateOrder(orderModel);
      await _localDataSource.cacheOrder(updatedOrder);
      return updatedOrder.toEntity();
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  @override
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _remoteDataSource.cancelOrder(orderId, reason);
      // Update local cache if order exists
      final cachedOrder = await _localDataSource.getCachedOrder(orderId);
      if (cachedOrder != null) {
        final updatedOrder = OrderModel.fromJson({
          ...cachedOrder.toJson(),
          'status': OrderStatus.cancelled.name,
          'cancelledDate': DateTime.now().toIso8601String(),
          'cancellationReason': reason,
          'updatedAt': DateTime.now().toIso8601String(),
        });
        await _localDataSource.cacheOrder(updatedOrder);
      }
    } catch (e) {
      throw Exception('Failed to cancel order: $e');
    }
  }

  @override
  Future<List<Order>> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final remoteOrders = await _remoteDataSource.searchOrders(
        userId,
        query: query,
        status: status,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );
      return remoteOrders.map((model) => model.toEntity()).toList();
    } catch (e) {
      print('❌ Error searching orders: $e');
      // Fallback to cached orders with local filtering
      final cachedOrders = await _localDataSource.getCachedOrders(userId);
      List<OrderModel> filteredOrders = cachedOrders;

      if (status != null) {
        filteredOrders = filteredOrders
            .where((order) => order.status == status)
            .toList();
      }

      if (query != null && query.isNotEmpty) {
        filteredOrders = filteredOrders
            .where(
              (order) =>
                  order.orderNumber.toLowerCase().contains(
                    query.toLowerCase(),
                  ) ||
                  order.items.any(
                    (item) => item.productName.toLowerCase().contains(
                      query.toLowerCase(),
                    ),
                  ),
            )
            .toList();
      }

      return filteredOrders.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<List<OrderItem>> getOrderItems(String orderId) async {
    try {
      final orderItems = await _remoteDataSource.getOrderItems(orderId);
      return orderItems.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch order items: $e');
    }
  }

  @override
  Future<OrderItem?> getOrderItemById(String orderItemId) async {
    try {
      final orderItem = await _remoteDataSource.getOrderItemById(orderItemId);
      return orderItem?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch order item: $e');
    }
  }

  @override
  Future<OrderItem> updateOrderItem(OrderItem orderItem) async {
    try {
      final orderItemModel = OrderItemModel.fromEntity(orderItem);
      final updatedOrderItem = await _remoteDataSource.updateOrderItem(
        orderItemModel,
      );
      return updatedOrderItem.toEntity();
    } catch (e) {
      throw Exception('Failed to update order item: $e');
    }
  }

  @override
  Future<List<Shipment>> getOrderShipments(String orderId) async {
    try {
      final shipments = await _remoteDataSource.getOrderShipments(orderId);
      return shipments.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch order shipments: $e');
    }
  }

  @override
  Future<Shipment?> getShipmentById(String shipmentId) async {
    try {
      final shipment = await _remoteDataSource.getShipmentById(shipmentId);
      return shipment?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch shipment: $e');
    }
  }

  @override
  Future<Shipment?> getShipmentByTrackingNumber(String trackingNumber) async {
    try {
      final shipment = await _remoteDataSource.getShipmentByTrackingNumber(
        trackingNumber,
      );
      return shipment?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch shipment by tracking number: $e');
    }
  }

  @override
  Future<List<Shipment>> trackShipments(List<String> trackingNumbers) async {
    try {
      final shipments = await _remoteDataSource.trackShipments(trackingNumbers);
      return shipments.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to track shipments: $e');
    }
  }

  @override
  Future<List<Return>> getUserReturns(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('📦 Fetching user returns from remote...');
      final remoteReturns = await _remoteDataSource.getUserReturns(
        userId,
        page: page,
        limit: limit,
      );
      final returns = remoteReturns.map((model) => model.toEntity()).toList();

      // Cache the results
      await _localDataSource.cacheReturns(remoteReturns, userId);

      print('✅ Found ${returns.length} returns from remote');
      return returns;
    } catch (e) {
      print('❌ Error fetching returns from remote: $e');
      // Fallback to local cache
      final cachedReturns = await _localDataSource.getCachedReturns(userId);
      print('📱 Found ${cachedReturns.length} returns from cache');
      return cachedReturns.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<Return?> getReturnById(String returnId) async {
    try {
      final returnModel = await _remoteDataSource.getReturnById(returnId);
      return returnModel?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch return: $e');
    }
  }

  @override
  Future<Return> createReturn(Return returnRequest) async {
    try {
      final returnModel = ReturnModel.fromEntity(returnRequest);
      final createdReturn = await _remoteDataSource.createReturn(returnModel);
      return createdReturn.toEntity();
    } catch (e) {
      throw Exception('Failed to create return: $e');
    }
  }

  @override
  Future<Return> updateReturn(Return returnRequest) async {
    try {
      final returnModel = ReturnModel.fromEntity(returnRequest);
      final updatedReturn = await _remoteDataSource.updateReturn(returnModel);
      return updatedReturn.toEntity();
    } catch (e) {
      throw Exception('Failed to update return: $e');
    }
  }

  @override
  Future<void> cancelReturn(String returnId) async {
    try {
      await _remoteDataSource.cancelReturn(returnId);
    } catch (e) {
      throw Exception('Failed to cancel return: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderStatistics(String userId) async {
    try {
      return await _remoteDataSource.getOrderStatistics(userId);
    } catch (e) {
      throw Exception('Failed to fetch order statistics: $e');
    }
  }

  @override
  Future<int> getOrderCount(String userId, {OrderStatus? status}) async {
    try {
      return await _remoteDataSource.getOrderCount(userId, status: status);
    } catch (e) {
      throw Exception('Failed to get order count: $e');
    }
  }

  @override
  Future<void> subscribeToOrderUpdates(String orderId) async {
    // TODO: Implement real-time order updates subscription
    // This could use Firebase Cloud Messaging or WebSocket connections
  }

  @override
  Future<void> unsubscribeFromOrderUpdates(String orderId) async {
    // TODO: Implement real-time order updates unsubscription
  }
}
