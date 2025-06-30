import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/shipment_model.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/shipment.dart';

abstract class AdminOrderRemoteDataSource {
  // Order operations
  Future<List<OrderModel>> getOrders({
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

  Future<OrderModel?> getOrderById(String orderId);
  Future<OrderModel?> getOrderByNumber(String orderNumber);
  Future<OrderModel> updateOrder(OrderModel order);
  Future<void> updateOrderStatus(String orderId, OrderStatus status, {String? notes});
  Future<void> updateOrderPriority(String orderId, OrderPriority priority);
  Future<void> assignOrder(String orderId, String assignedTo, String assignedToName);
  Future<void> unassignOrder(String orderId);
  Future<void> addOrderNotes(String orderId, String notes, {bool isAdminNote = false});
  Future<void> addOrderTags(String orderId, List<String> tags);
  Future<void> removeOrderTags(String orderId, List<String> tags);

  // Order analytics and reporting
  Future<Map<String, dynamic>> getOrdersAnalytics({DateTime? startDate, DateTime? endDate});
  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status, {int limit = 50});
  Future<List<OrderModel>> getOrdersByPriority(OrderPriority priority, {int limit = 50});
  Future<List<OrderModel>> getOrdersByCustomer(String customerId, {int limit = 20});
  Future<List<OrderModel>> getAssignedOrders(String assignedTo, {int limit = 50});
  Future<List<OrderModel>> getOverdueOrders({int limit = 50});
  Future<List<OrderModel>> getRecentOrders({int limit = 20});

  // Order queue management
  Future<List<OrderModel>> getOrderQueue({
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
  Future<List<ShipmentModel>> getShipments({
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

  Future<ShipmentModel?> getShipmentById(String shipmentId);
  Future<List<ShipmentModel>> getShipmentsByOrder(String orderId);
  Future<ShipmentModel> createShipment(ShipmentModel shipment);
  Future<ShipmentModel> updateShipment(ShipmentModel shipment);
  Future<void> updateShipmentStatus(String shipmentId, ShipmentStatus status, {String? notes});
  Future<void> addTrackingNumber(String shipmentId, String trackingNumber, String? trackingUrl);
  Future<void> addTrackingEvent(String shipmentId, TrackingEventModel event);
  Future<void> updateShipmentTracking(String shipmentId);

  // Shipping carriers
  Future<List<ShippingCarrierModel>> getShippingCarriers({bool activeOnly = true});
  Future<ShippingCarrierModel?> getShippingCarrierById(String carrierId);
  Future<ShippingCarrierModel> createShippingCarrier(ShippingCarrierModel carrier);
  Future<ShippingCarrierModel> updateShippingCarrier(ShippingCarrierModel carrier);
  Future<void> deleteShippingCarrier(String carrierId);

  // Communication
  Future<void> sendOrderConfirmation(String orderId);
  Future<void> sendShippingNotification(String orderId, String shipmentId);
  Future<void> sendDeliveryNotification(String orderId, String shipmentId);
  Future<void> sendOrderStatusUpdate(String orderId, OrderStatus status, {String? message});
  Future<void> sendCustomMessage(String orderId, String subject, String message);
  Future<List<Map<String, dynamic>>> getOrderCommunications(String orderId);
  Future<void> logCommunication(String orderId, String type, String subject, String message, {Map<String, dynamic>? metadata});

  // Search and filters
  Future<List<OrderModel>> searchOrders(String query, {int limit = 10});
  Future<List<ShipmentModel>> searchShipments(String query, {int limit = 10});
  Future<Map<String, dynamic>> getOrderFilters();
  Future<List<String>> getOrderTags();
  Future<List<Map<String, dynamic>>> getAssignableUsers();

  // Bulk operations
  Future<void> bulkUpdateOrderStatus(List<String> orderIds, OrderStatus status);
  Future<void> bulkAssignOrders(List<String> orderIds, String assignedTo, String assignedToName);
  Future<void> bulkUpdateOrderPriority(List<String> orderIds, OrderPriority priority);
  Future<void> bulkAddOrderTags(List<String> orderIds, List<String> tags);
}

class AdminOrderRemoteDataSourceImpl implements AdminOrderRemoteDataSource {
  final FirebaseFirestore _firestore;

  AdminOrderRemoteDataSourceImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<OrderModel>> getOrders({
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
      Query query = _firestore.collection('orders');

      // Apply filters
      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (priority != null) {
        query = query.where('priority', isEqualTo: priority.name);
      }

      if (paymentStatus != null) {
        query = query.where('payment.status', isEqualTo: paymentStatus.name);
      }

      if (assignedTo != null) {
        query = query.where('assignedTo', isEqualTo: assignedTo);
      }

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate.toIso8601String());
      }

      // Apply sorting
      final sortField = sortBy ?? 'updatedAt';
      query = query.orderBy(sortField, descending: sortDescending);

      // Apply pagination
      if (page > 1) {
        final offset = (page - 1) * limit;
        query = query.limit(offset + limit);
      } else {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();
      
      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      if (page > 1) {
        final offset = (page - 1) * limit;
        docs = docs.skip(offset).toList();
      }

      final orders = docs
          .map((doc) => OrderModel.fromJson({'id': doc.id, ...doc.data() as Map<String, dynamic>}))
          .toList();

      // Apply search query filter (client-side for simplicity)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final filteredOrders = orders.where((order) {
          final query = searchQuery.toLowerCase();
          return order.orderNumber.toLowerCase().contains(query) ||
                 order.customerName.toLowerCase().contains(query) ||
                 order.customerEmail.toLowerCase().contains(query) ||
                 order.items.any((item) => item.productName.toLowerCase().contains(query));
        }).toList();
        
        return filteredOrders;
      }

      return orders;
    } catch (e) {
      throw Exception('Failed to fetch orders: $e');
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection('orders').doc(orderId).get();
      
      if (!doc.exists) return null;

      return OrderModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch order: $e');
    }
  }

  @override
  Future<OrderModel?> getOrderByNumber(String orderNumber) async {
    try {
      final querySnapshot = await _firestore
          .collection('orders')
          .where('orderNumber', isEqualTo: orderNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return OrderModel.fromJson({'id': doc.id, ...doc.data()});
    } catch (e) {
      throw Exception('Failed to fetch order by number: $e');
    }
  }

  @override
  Future<OrderModel> updateOrder(OrderModel order) async {
    try {
      final orderData = order.toJson();
      orderData['updatedAt'] = FieldValue.serverTimestamp();
      
      await _firestore.collection('orders').doc(order.id).update(orderData);
      
      final updatedDoc = await _firestore.collection('orders').doc(order.id).get();
      return OrderModel.fromJson({'id': order.id, ...updatedDoc.data()!});
    } catch (e) {
      throw Exception('Failed to update order: $e');
    }
  }

  @override
  Future<void> updateOrderStatus(String orderId, OrderStatus status, {String? notes}) async {
    try {
      final updateData = {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (notes != null) {
        updateData['adminNotes'] = notes;
      }

      await _firestore.collection('orders').doc(orderId).update(updateData);
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }

  @override
  Future<void> updateOrderPriority(String orderId, OrderPriority priority) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'priority': priority.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update order priority: $e');
    }
  }

  @override
  Future<void> assignOrder(String orderId, String assignedTo, String assignedToName) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'assignedTo': assignedTo,
        'assignedToName': assignedToName,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to assign order: $e');
    }
  }

  @override
  Future<void> unassignOrder(String orderId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'assignedTo': null,
        'assignedToName': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to unassign order: $e');
    }
  }

  @override
  Future<void> addOrderNotes(String orderId, String notes, {bool isAdminNote = false}) async {
    try {
      final field = isAdminNote ? 'adminNotes' : 'notes';
      await _firestore.collection('orders').doc(orderId).update({
        field: notes,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add order notes: $e');
    }
  }

  @override
  Future<void> addOrderTags(String orderId, List<String> tags) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'tags': FieldValue.arrayUnion(tags),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add order tags: $e');
    }
  }

  @override
  Future<void> removeOrderTags(String orderId, List<String> tags) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'tags': FieldValue.arrayRemove(tags),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to remove order tags: $e');
    }
  }

  // Stub implementations for remaining methods
  @override
  Future<Map<String, dynamic>> getOrdersAnalytics({DateTime? startDate, DateTime? endDate}) async {
    return {
      'totalOrders': 150,
      'pendingOrders': 25,
      'processingOrders': 40,
      'shippedOrders': 60,
      'deliveredOrders': 20,
      'cancelledOrders': 5,
      'totalRevenue': 125000.0,
      'averageOrderValue': 833.33,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  @override
  Future<List<OrderModel>> getOrdersByStatus(OrderStatus status, {int limit = 50}) async {
    return []; // Stub implementation
  }

  @override
  Future<List<OrderModel>> getOrdersByPriority(OrderPriority priority, {int limit = 50}) async {
    return []; // Stub implementation
  }

  @override
  Future<List<OrderModel>> getOrdersByCustomer(String customerId, {int limit = 20}) async {
    return []; // Stub implementation
  }

  @override
  Future<List<OrderModel>> getAssignedOrders(String assignedTo, {int limit = 50}) async {
    return []; // Stub implementation
  }

  @override
  Future<List<OrderModel>> getOverdueOrders({int limit = 50}) async {
    return []; // Stub implementation
  }

  @override
  Future<List<OrderModel>> getRecentOrders({int limit = 20}) async {
    return []; // Stub implementation
  }

  @override
  Future<List<OrderModel>> getOrderQueue({
    List<OrderStatus>? statuses,
    OrderPriority? minPriority,
    String? assignedTo,
    int limit = 50,
  }) async {
    return []; // Stub implementation
  }

  @override
  Future<int> getOrderQueueCount({
    List<OrderStatus>? statuses,
    OrderPriority? minPriority,
    String? assignedTo,
  }) async {
    return 0; // Stub implementation
  }

  // Shipment operations - Stub implementations
  @override
  Future<List<ShipmentModel>> getShipments({
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
    return []; // Stub implementation
  }

  @override
  Future<ShipmentModel?> getShipmentById(String shipmentId) async {
    return null; // Stub implementation
  }

  @override
  Future<List<ShipmentModel>> getShipmentsByOrder(String orderId) async {
    return []; // Stub implementation
  }

  @override
  Future<ShipmentModel> createShipment(ShipmentModel shipment) async {
    return shipment; // Stub implementation
  }

  @override
  Future<ShipmentModel> updateShipment(ShipmentModel shipment) async {
    return shipment; // Stub implementation
  }

  @override
  Future<void> updateShipmentStatus(String shipmentId, ShipmentStatus status, {String? notes}) async {
    // Stub implementation
  }

  @override
  Future<void> addTrackingNumber(String shipmentId, String trackingNumber, String? trackingUrl) async {
    // Stub implementation
  }

  @override
  Future<void> addTrackingEvent(String shipmentId, TrackingEventModel event) async {
    // Stub implementation
  }

  @override
  Future<void> updateShipmentTracking(String shipmentId) async {
    // Stub implementation
  }

  @override
  Future<List<ShippingCarrierModel>> getShippingCarriers({bool activeOnly = true}) async {
    return [
      ShippingCarrierModel(
        id: 'dhl',
        name: 'DHL Express',
        code: 'DHL',
        logoUrl: 'https://example.com/dhl-logo.png',
        trackingUrl: 'https://www.dhl.com/tracking',
      ),
      ShippingCarrierModel(
        id: 'fedex',
        name: 'FedEx',
        code: 'FEDEX',
        logoUrl: 'https://example.com/fedex-logo.png',
        trackingUrl: 'https://www.fedex.com/tracking',
      ),
    ];
  }

  @override
  Future<ShippingCarrierModel?> getShippingCarrierById(String carrierId) async {
    return null; // Stub implementation
  }

  @override
  Future<ShippingCarrierModel> createShippingCarrier(ShippingCarrierModel carrier) async {
    return carrier; // Stub implementation
  }

  @override
  Future<ShippingCarrierModel> updateShippingCarrier(ShippingCarrierModel carrier) async {
    return carrier; // Stub implementation
  }

  @override
  Future<void> deleteShippingCarrier(String carrierId) async {
    // Stub implementation
  }

  // Communication - Stub implementations
  @override
  Future<void> sendOrderConfirmation(String orderId) async {
    // Stub implementation
  }

  @override
  Future<void> sendShippingNotification(String orderId, String shipmentId) async {
    // Stub implementation
  }

  @override
  Future<void> sendDeliveryNotification(String orderId, String shipmentId) async {
    // Stub implementation
  }

  @override
  Future<void> sendOrderStatusUpdate(String orderId, OrderStatus status, {String? message}) async {
    // Stub implementation
  }

  @override
  Future<void> sendCustomMessage(String orderId, String subject, String message) async {
    // Stub implementation
  }

  @override
  Future<List<Map<String, dynamic>>> getOrderCommunications(String orderId) async {
    return []; // Stub implementation
  }

  @override
  Future<void> logCommunication(String orderId, String type, String subject, String message, {Map<String, dynamic>? metadata}) async {
    // Stub implementation
  }

  // Search and filters - Stub implementations
  @override
  Future<List<OrderModel>> searchOrders(String query, {int limit = 10}) async {
    return []; // Stub implementation
  }

  @override
  Future<List<ShipmentModel>> searchShipments(String query, {int limit = 10}) async {
    return []; // Stub implementation
  }

  @override
  Future<Map<String, dynamic>> getOrderFilters() async {
    return {
      'statuses': OrderStatus.values.map((s) => s.name).toList(),
      'priorities': OrderPriority.values.map((p) => p.name).toList(),
      'paymentStatuses': PaymentStatus.values.map((p) => p.name).toList(),
    };
  }

  @override
  Future<List<String>> getOrderTags() async {
    return ['urgent', 'vip', 'bulk-order', 'international', 'gift'];
  }

  @override
  Future<List<Map<String, dynamic>>> getAssignableUsers() async {
    return [
      {'id': 'user1', 'name': 'John Doe', 'role': 'Order Manager'},
      {'id': 'user2', 'name': 'Jane Smith', 'role': 'Fulfillment Specialist'},
    ];
  }

  // Bulk operations - Stub implementations
  @override
  Future<void> bulkUpdateOrderStatus(List<String> orderIds, OrderStatus status) async {
    // Stub implementation
  }

  @override
  Future<void> bulkAssignOrders(List<String> orderIds, String assignedTo, String assignedToName) async {
    // Stub implementation
  }

  @override
  Future<void> bulkUpdateOrderPriority(List<String> orderIds, OrderPriority priority) async {
    // Stub implementation
  }

  @override
  Future<void> bulkAddOrderTags(List<String> orderIds, List<String> tags) async {
    // Stub implementation
  }
}
