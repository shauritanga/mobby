import '../entities/order.dart';
import '../entities/shipment.dart';

abstract class AdminOrderRepository {
  // Order operations
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
  });

  Future<Order?> getOrderById(String orderId);
  Future<Order?> getOrderByNumber(String orderNumber);
  Future<Order> updateOrder(Order order);
  Future<void> updateOrderStatus(String orderId, OrderStatus status, {String? notes});
  Future<void> updateOrderPriority(String orderId, OrderPriority priority);
  Future<void> assignOrder(String orderId, String assignedTo, String assignedToName);
  Future<void> unassignOrder(String orderId);
  Future<void> addOrderNotes(String orderId, String notes, {bool isAdminNote = false});
  Future<void> addOrderTags(String orderId, List<String> tags);
  Future<void> removeOrderTags(String orderId, List<String> tags);

  // Order analytics and reporting
  Future<Map<String, dynamic>> getOrdersAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<Order>> getOrdersByStatus(OrderStatus status, {int limit = 50});
  Future<List<Order>> getOrdersByPriority(OrderPriority priority, {int limit = 50});
  Future<List<Order>> getOrdersByCustomer(String customerId, {int limit = 20});
  Future<List<Order>> getAssignedOrders(String assignedTo, {int limit = 50});
  Future<List<Order>> getOverdueOrders({int limit = 50});
  Future<List<Order>> getRecentOrders({int limit = 20});

  // Order queue management
  Future<List<Order>> getOrderQueue({
    List<OrderStatus>? statuses,
    OrderPriority? minPriority,
    String? assignedTo,
    int limit = 50,
  });
  Future<int> getOrderQueueCount({
    List<OrderStatus>? statuses,
    OrderPriority? minPriority,
    String? assignedTo,
  });

  // Shipment operations
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
  });

  Future<Shipment?> getShipmentById(String shipmentId);
  Future<List<Shipment>> getShipmentsByOrder(String orderId);
  Future<Shipment> createShipment(Shipment shipment);
  Future<Shipment> updateShipment(Shipment shipment);
  Future<void> updateShipmentStatus(String shipmentId, ShipmentStatus status, {String? notes});
  Future<void> addTrackingNumber(String shipmentId, String trackingNumber, String? trackingUrl);
  Future<void> addTrackingEvent(String shipmentId, TrackingEvent event);
  Future<void> updateShipmentTracking(String shipmentId);

  // Shipping carriers
  Future<List<ShippingCarrier>> getShippingCarriers({bool activeOnly = true});
  Future<ShippingCarrier?> getShippingCarrierById(String carrierId);
  Future<ShippingCarrier> createShippingCarrier(ShippingCarrier carrier);
  Future<ShippingCarrier> updateShippingCarrier(ShippingCarrier carrier);
  Future<void> deleteShippingCarrier(String carrierId);

  // Shipping analytics
  Future<Map<String, dynamic>> getShippingAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<Shipment>> getActiveShipments({int limit = 50});
  Future<List<Shipment>> getDelayedShipments({int limit = 50});
  Future<List<Shipment>> getShipmentsByCarrier(String carrierId, {int limit = 50});

  // Customer communication
  Future<void> sendOrderConfirmation(String orderId);
  Future<void> sendShippingNotification(String orderId, String shipmentId);
  Future<void> sendDeliveryNotification(String orderId, String shipmentId);
  Future<void> sendOrderStatusUpdate(String orderId, OrderStatus status, {String? message});
  Future<void> sendCustomMessage(String orderId, String subject, String message);

  // Communication history
  Future<List<Map<String, dynamic>>> getOrderCommunications(String orderId);
  Future<void> logCommunication(String orderId, String type, String subject, String message, {Map<String, dynamic>? metadata});

  // Bulk operations
  Future<void> bulkUpdateOrderStatus(List<String> orderIds, OrderStatus status);
  Future<void> bulkAssignOrders(List<String> orderIds, String assignedTo, String assignedToName);
  Future<void> bulkUpdateOrderPriority(List<String> orderIds, OrderPriority priority);
  Future<void> bulkAddOrderTags(List<String> orderIds, List<String> tags);

  // Export operations
  Future<String> exportOrders({
    String format = 'csv',
    List<String>? orderIds,
    Map<String, dynamic>? filters,
  });
  Future<String> exportShipments({
    String format = 'csv',
    List<String>? shipmentIds,
    Map<String, dynamic>? filters,
  });

  // Search and filters
  Future<List<Order>> searchOrders(String query, {int limit = 10});
  Future<List<Shipment>> searchShipments(String query, {int limit = 10});
  Future<Map<String, dynamic>> getOrderFilters();
  Future<List<String>> getOrderTags();
  Future<List<Map<String, dynamic>>> getAssignableUsers();

  // Order processing workflows
  Future<void> processOrder(String orderId, {String? notes});
  Future<void> fulfillOrder(String orderId, {String? notes});
  Future<void> cancelOrder(String orderId, String reason, {String? notes});
  Future<void> refundOrder(String orderId, double amount, String reason, {String? notes});
  Future<void> returnOrder(String orderId, List<String> itemIds, String reason, {String? notes});

  // Inventory integration
  Future<void> reserveInventory(String orderId);
  Future<void> releaseInventory(String orderId);
  Future<void> updateInventoryOnShipment(String shipmentId);
  Future<bool> checkInventoryAvailability(String orderId);

  // Payment integration
  Future<void> capturePayment(String orderId);
  Future<void> refundPayment(String orderId, double amount, {String? reason});
  Future<void> voidPayment(String orderId);
  Future<OrderPayment?> getOrderPayment(String orderId);

  // Notifications and alerts
  Future<void> createOrderAlert(String orderId, String type, String message);
  Future<List<Map<String, dynamic>>> getOrderAlerts({
    String? orderId,
    String? type,
    bool unreadOnly = false,
    int limit = 50,
  });
  Future<void> markAlertAsRead(String alertId);

  // Order metrics
  Future<Map<String, dynamic>> getOrderMetrics({
    DateTime? startDate,
    DateTime? endDate,
    String? groupBy,
  });
  Future<Map<String, dynamic>> getShippingMetrics({
    DateTime? startDate,
    DateTime? endDate,
    String? carrierId,
  });
  Future<Map<String, dynamic>> getCustomerOrderMetrics(String customerId);

  // Order validation
  Future<bool> validateOrder(String orderId);
  Future<List<String>> getOrderValidationErrors(String orderId);
  Future<void> fixOrderValidationErrors(String orderId, Map<String, dynamic> fixes);
}
