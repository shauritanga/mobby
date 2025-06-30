import '../entities/order.dart';
import '../entities/order_item.dart';
import '../entities/shipment.dart';
import '../entities/return.dart';

abstract class OrdersRepository {
  // Order operations
  Future<List<Order>> getUserOrders(String userId, {int page = 1, int limit = 20});
  Future<Order?> getOrderById(String orderId);
  Future<Order> createOrder(Order order);
  Future<Order> updateOrder(Order order);
  Future<void> cancelOrder(String orderId, String reason);
  
  // Order search and filtering
  Future<List<Order>> searchOrders(String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });
  
  // Order items
  Future<List<OrderItem>> getOrderItems(String orderId);
  Future<OrderItem?> getOrderItemById(String orderItemId);
  Future<OrderItem> updateOrderItem(OrderItem orderItem);
  
  // Shipment operations
  Future<List<Shipment>> getOrderShipments(String orderId);
  Future<Shipment?> getShipmentById(String shipmentId);
  Future<Shipment?> getShipmentByTrackingNumber(String trackingNumber);
  Future<List<Shipment>> trackShipments(List<String> trackingNumbers);
  
  // Return operations
  Future<List<Return>> getUserReturns(String userId, {int page = 1, int limit = 20});
  Future<Return?> getReturnById(String returnId);
  Future<Return> createReturn(Return returnRequest);
  Future<Return> updateReturn(Return returnRequest);
  Future<void> cancelReturn(String returnId);
  
  // Statistics
  Future<Map<String, dynamic>> getOrderStatistics(String userId);
  Future<int> getOrderCount(String userId, {OrderStatus? status});
  
  // Notifications
  Future<void> subscribeToOrderUpdates(String orderId);
  Future<void> unsubscribeFromOrderUpdates(String orderId);
}
