import '../../domain/entities/order.dart';
import '../../domain/entities/shipment.dart';
import '../../domain/repositories/admin_order_repository.dart';
import '../datasources/admin_order_remote_datasource.dart';
import '../models/order_model.dart';
import '../models/shipment_model.dart';

class AdminOrderRepositoryImpl implements AdminOrderRepository {
  final AdminOrderRemoteDataSource _remoteDataSource;

  AdminOrderRepositoryImpl({
    required AdminOrderRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<Order>> getOrders({
    String? searchQuery,
    OrderStatus? status,
    OrderPriority? priority,
    PaymentStatus? paymentStatus,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    bool sortDescending = false,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final orders = await _remoteDataSource.getOrders(
        searchQuery: searchQuery,
        status: status,
        priority: priority,
        paymentStatus: paymentStatus,
        assignedTo: assignedTo,
        startDate: startDate,
        endDate: endDate,
        sortBy: sortBy,
        sortDescending: sortDescending,
        page: page,
        limit: limit,
      );
      return orders.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<Order?> getOrderById(String orderId) async {
    try {
      final order = await _remoteDataSource.getOrderById(orderId);
      return order?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  @override
  Future<Order?> getOrderByNumber(String orderNumber) async {
    try {
      final order = await _remoteDataSource.getOrderByNumber(orderNumber);
      return order?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch order by number: $e');
    }
  }

  @override
  Future<Order> updateOrder(Order order) async {
    try {
      final orderModel = OrderModel.fromEntity(order);
      final updatedOrder = await _remoteDataSource.updateOrder(orderModel);
      return updatedOrder.toEntity();
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status, {String? notes}) async {
    try {
      await _remoteDataSource.updateOrderStatus(orderId, status, notes: notes);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<void> updateOrderPriority(String orderId, OrderPriority priority) async {
    try {
      await _remoteDataSource.updateOrderPriority(orderId, priority);
    } catch (e) {
      throw Exception('Failed to update order priority: $e');
    }
  }

  @override
  Future<void> assignOrder(String orderId, String assignedTo, String assignedToName) async {
    try {
      await _remoteDataSource.assignOrder(orderId, assignedTo, assignedToName);
    } catch (e) {
      throw Exception('Failed to assign order: $e');
    }
  }

  @override
  Future<void> unassignOrder(String orderId) async {
    try {
      await _remoteDataSource.unassignOrder(orderId);
    } catch (e) {
      throw Exception('Failed to unassign order: $e');
    }
  }

  @override
  Future<void> addOrderNotes(String orderId, String notes, {bool isAdminNote = false}) async {
    try {
      await _remoteDataSource.addOrderNotes(orderId, notes, isAdminNote: isAdminNote);
    } catch (e) {
      throw Exception('Failed to add order notes: $e');
    }
  }

  @override
  Future<void> addOrderTags(String orderId, List<String> tags) async {
    try {
      await _remoteDataSource.addOrderTags(orderId, tags);
    } catch (e) {
      throw Exception('Failed to add order tags: $e');
    }
  }

  @override
  Future<void> removeOrderTags(String orderId, List<String> tags) async {
    try {
      await _remoteDataSource.removeOrderTags(orderId, tags);
    } catch (e) {
      throw Exception('Failed to remove order tags: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrdersAnalytics({DateTime? startDate, DateTime? endDate}) async {
    try {
      return await _remoteDataSource.getOrdersAnalytics(startDate: startDate, endDate: endDate);
    } catch (e) {
      throw Exception('Failed to fetch orders analytics: $e');
    }
  }

  @override
  Future<List<Order>> getOrdersByStatus(OrderStatus status, {int limit = 50}) async {
    try {
      final orders = await _remoteDataSource.getOrdersByStatus(status, limit: limit);
      return orders.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by status: $e');
    }
  }

  @override
  Future<List<Order>> getOrdersByPriority(OrderPriority priority, {int limit = 50}) async {
    try {
      final orders = await _remoteDataSource.getOrdersByPriority(priority, limit: limit);
      return orders.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by priority: $e');
    }
  }

  @override
  Future<List<Order>> getOrdersByCustomer(String customerId, {int limit = 20}) async {
    try {
      final orders = await _remoteDataSource.getOrdersByCustomer(customerId, limit: limit);
      return orders.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch orders by customer: $e');
    }
  }

  @override
  Future<List<Order>> getAssignedOrders(String assignedTo, {int limit = 50}) async {
    try {
      final orders = await _remoteDataSource.getAssignedOrders(assignedTo, limit: limit);
      return orders.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch assigned orders: $e');
    }
  }

  @override
  Future<List<Order>> getOverdueOrders({int limit = 50}) async {
    try {
      final orders = await _remoteDataSource.getOverdueOrders(limit: limit);
      return orders.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch overdue orders: $e');
    }
  }

  @override
  Future<List<Order>> getRecentOrders({int limit = 20}) async {
    try {
      final orders = await _remoteDataSource.getRecentOrders(limit: limit);
      return orders.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch recent orders: $e');
    }
  }

  @override
  Future<List<Order>> getOrderQueue({
    List<OrderStatus>? statuses,
    OrderPriority? minPriority,
    String? assignedTo,
    int limit = 50,
  }) async {
    try {
      final orders = await _remoteDataSource.getOrderQueue(
        statuses: statuses,
        minPriority: minPriority,
        assignedTo: assignedTo,
        limit: limit,
      );
      return orders.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch order queue: $e');
    }
  }

  @override
  Future<int> getOrderQueueCount({
    List<OrderStatus>? statuses,
    OrderPriority? minPriority,
    String? assignedTo,
  }) async {
    try {
      return await _remoteDataSource.getOrderQueueCount(
        statuses: statuses,
        minPriority: minPriority,
        assignedTo: assignedTo,
      );
    } catch (e) {
      throw Exception('Failed to fetch order queue count: $e');
    }
  }

  @override
  Future<List<Shipment>> getShipments({
    String? searchQuery,
    String? orderId,
    ShipmentStatus? status,
    ShippingMethod? method,
    String? carrierId,
    DateTime? startDate,
    DateTime? endDate,
    String? sortBy,
    bool sortDescending = false,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final shipments = await _remoteDataSource.getShipments(
        searchQuery: searchQuery,
        orderId: orderId,
        status: status,
        method: method,
        carrierId: carrierId,
        startDate: startDate,
        endDate: endDate,
        sortBy: sortBy,
        sortDescending: sortDescending,
        page: page,
        limit: limit,
      );
      return shipments.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch shipments: $e');
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
  Future<List<Shipment>> getShipmentsByOrder(String orderId) async {
    try {
      final shipments = await _remoteDataSource.getShipmentsByOrder(orderId);
      return shipments.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch shipments by order: $e');
    }
  }

  @override
  Future<Shipment> createShipment(Shipment shipment) async {
    try {
      final shipmentModel = ShipmentModel.fromEntity(shipment);
      final createdShipment = await _remoteDataSource.createShipment(shipmentModel);
      return createdShipment.toEntity();
    } catch (e) {
      throw Exception('Failed to create shipment: $e');
    }
  }

  @override
  Future<Shipment> updateShipment(Shipment shipment) async {
    try {
      final shipmentModel = ShipmentModel.fromEntity(shipment);
      final updatedShipment = await _remoteDataSource.updateShipment(shipmentModel);
      return updatedShipment.toEntity();
    } catch (e) {
      throw Exception('Failed to update shipment: $e');
    }
  }

  @override
  Future<void> updateShipmentStatus(String shipmentId, ShipmentStatus status, {String? notes}) async {
    try {
      await _remoteDataSource.updateShipmentStatus(shipmentId, status, notes: notes);
    } catch (e) {
      throw Exception('Failed to update shipment status: $e');
    }
  }

  @override
  Future<void> addTrackingNumber(String shipmentId, String trackingNumber, String? trackingUrl) async {
    try {
      await _remoteDataSource.addTrackingNumber(shipmentId, trackingNumber, trackingUrl);
    } catch (e) {
      throw Exception('Failed to add tracking number: $e');
    }
  }

  @override
  Future<void> addTrackingEvent(String shipmentId, TrackingEvent event) async {
    try {
      final eventModel = TrackingEventModel.fromEntity(event);
      await _remoteDataSource.addTrackingEvent(shipmentId, eventModel);
    } catch (e) {
      throw Exception('Failed to add tracking event: $e');
    }
  }

  @override
  Future<void> updateShipmentTracking(String shipmentId) async {
    try {
      await _remoteDataSource.updateShipmentTracking(shipmentId);
    } catch (e) {
      throw Exception('Failed to update shipment tracking: $e');
    }
  }

  @override
  Future<List<ShippingCarrier>> getShippingCarriers({bool activeOnly = true}) async {
    try {
      final carriers = await _remoteDataSource.getShippingCarriers(activeOnly: activeOnly);
      return carriers.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch shipping carriers: $e');
    }
  }

  @override
  Future<ShippingCarrier?> getShippingCarrierById(String carrierId) async {
    try {
      final carrier = await _remoteDataSource.getShippingCarrierById(carrierId);
      return carrier?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch shipping carrier: $e');
    }
  }

  @override
  Future<ShippingCarrier> createShippingCarrier(ShippingCarrier carrier) async {
    try {
      final carrierModel = ShippingCarrierModel.fromEntity(carrier);
      final createdCarrier = await _remoteDataSource.createShippingCarrier(carrierModel);
      return createdCarrier.toEntity();
    } catch (e) {
      throw Exception('Failed to create shipping carrier: $e');
    }
  }

  @override
  Future<ShippingCarrier> updateShippingCarrier(ShippingCarrier carrier) async {
    try {
      final carrierModel = ShippingCarrierModel.fromEntity(carrier);
      final updatedCarrier = await _remoteDataSource.updateShippingCarrier(carrierModel);
      return updatedCarrier.toEntity();
    } catch (e) {
      throw Exception('Failed to update shipping carrier: $e');
    }
  }

  @override
  Future<void> deleteShippingCarrier(String carrierId) async {
    try {
      await _remoteDataSource.deleteShippingCarrier(carrierId);
    } catch (e) {
      throw Exception('Failed to delete shipping carrier: $e');
    }
  }

  // Placeholder implementations for remaining methods
  @override
  Future<Map<String, dynamic>> getShippingAnalytics({DateTime? startDate, DateTime? endDate}) async {
    return {'totalShipments': 0, 'activeShipments': 0, 'deliveredShipments': 0};
  }

  @override
  Future<List<Shipment>> getActiveShipments({int limit = 50}) async {
    return [];
  }

  @override
  Future<List<Shipment>> getDelayedShipments({int limit = 50}) async {
    return [];
  }

  @override
  Future<List<Shipment>> getShipmentsByCarrier(String carrierId, {int limit = 50}) async {
    return [];
  }

  @override
  Future<void> sendOrderConfirmation(String orderId) async {
    await _remoteDataSource.sendOrderConfirmation(orderId);
  }

  @override
  Future<void> sendShippingNotification(String orderId, String shipmentId) async {
    await _remoteDataSource.sendShippingNotification(orderId, shipmentId);
  }

  @override
  Future<void> sendDeliveryNotification(String orderId, String shipmentId) async {
    await _remoteDataSource.sendDeliveryNotification(orderId, shipmentId);
  }

  @override
  Future<void> sendOrderStatusUpdate(String orderId, OrderStatus status, {String? message}) async {
    await _remoteDataSource.sendOrderStatusUpdate(orderId, status, message: message);
  }

  @override
  Future<void> sendCustomMessage(String orderId, String subject, String message) async {
    await _remoteDataSource.sendCustomMessage(orderId, subject, message);
  }

  @override
  Future<List<Map<String, dynamic>>> getOrderCommunications(String orderId) async {
    return await _remoteDataSource.getOrderCommunications(orderId);
  }

  @override
  Future<void> logCommunication(String orderId, String type, String subject, String message, {Map<String, dynamic>? metadata}) async {
    await _remoteDataSource.logCommunication(orderId, type, subject, message, metadata: metadata);
  }

  @override
  Future<void> bulkUpdateOrderStatus(List<String> orderIds, OrderStatus status) async {
    await _remoteDataSource.bulkUpdateOrderStatus(orderIds, status);
  }

  @override
  Future<void> bulkAssignOrders(List<String> orderIds, String assignedTo, String assignedToName) async {
    await _remoteDataSource.bulkAssignOrders(orderIds, assignedTo, assignedToName);
  }

  @override
  Future<void> bulkUpdateOrderPriority(List<String> orderIds, OrderPriority priority) async {
    await _remoteDataSource.bulkUpdateOrderPriority(orderIds, priority);
  }

  @override
  Future<void> bulkAddOrderTags(List<String> orderIds, List<String> tags) async {
    await _remoteDataSource.bulkAddOrderTags(orderIds, tags);
  }

  @override
  Future<String> exportOrders({String format = 'csv', List<String>? orderIds, Map<String, dynamic>? filters}) async {
    return 'export-url';
  }

  @override
  Future<String> exportShipments({String format = 'csv', List<String>? shipmentIds, Map<String, dynamic>? filters}) async {
    return 'export-url';
  }

  @override
  Future<List<Order>> searchOrders(String query, {int limit = 10}) async {
    final orders = await _remoteDataSource.searchOrders(query, limit: limit);
    return orders.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Shipment>> searchShipments(String query, {int limit = 10}) async {
    final shipments = await _remoteDataSource.searchShipments(query, limit: limit);
    return shipments.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Map<String, dynamic>> getOrderFilters() async {
    return await _remoteDataSource.getOrderFilters();
  }

  @override
  Future<List<String>> getOrderTags() async {
    return await _remoteDataSource.getOrderTags();
  }

  @override
  Future<List<Map<String, dynamic>>> getAssignableUsers() async {
    return await _remoteDataSource.getAssignableUsers();
  }

  // Stub implementations for remaining methods
  @override
  Future<void> processOrder(String orderId, {String? notes}) async {}

  @override
  Future<void> fulfillOrder(String orderId, {String? notes}) async {}

  @override
  Future<void> cancelOrder(String orderId, String reason, {String? notes}) async {}

  @override
  Future<void> refundOrder(String orderId, double amount, String reason, {String? notes}) async {}

  @override
  Future<void> returnOrder(String orderId, List<String> itemIds, String reason, {String? notes}) async {}

  @override
  Future<void> reserveInventory(String orderId) async {}

  @override
  Future<void> releaseInventory(String orderId) async {}

  @override
  Future<void> updateInventoryOnShipment(String shipmentId) async {}

  @override
  Future<bool> checkInventoryAvailability(String orderId) async => true;

  @override
  Future<void> capturePayment(String orderId) async {}

  @override
  Future<void> refundPayment(String orderId, double amount, {String? reason}) async {}

  @override
  Future<void> voidPayment(String orderId) async {}

  @override
  Future<OrderPayment?> getOrderPayment(String orderId) async => null;

  @override
  Future<void> createOrderAlert(String orderId, String type, String message) async {}

  @override
  Future<List<Map<String, dynamic>>> getOrderAlerts({String? orderId, String? type, bool unreadOnly = false, int limit = 50}) async => [];

  @override
  Future<void> markAlertAsRead(String alertId) async {}

  @override
  Future<Map<String, dynamic>> getOrderMetrics({DateTime? startDate, DateTime? endDate, String? groupBy}) async => {};

  @override
  Future<Map<String, dynamic>> getShippingMetrics({DateTime? startDate, DateTime? endDate, String? carrierId}) async => {};

  @override
  Future<Map<String, dynamic>> getCustomerOrderMetrics(String customerId) async => {};

  @override
  Future<bool> validateOrder(String orderId) async => true;

  @override
  Future<List<String>> getOrderValidationErrors(String orderId) async => [];

  @override
  Future<void> fixOrderValidationErrors(String orderId, Map<String, dynamic> fixes) async {}
}
