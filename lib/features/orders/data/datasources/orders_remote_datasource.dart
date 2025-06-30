import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../models/shipment_model.dart';
import '../models/return_model.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/return.dart';

abstract class OrdersRemoteDataSource {
  // Order operations
  Future<List<OrderModel>> getUserOrders(
    String userId, {
    int page = 1,
    int limit = 20,
  });
  Future<OrderModel?> getOrderById(String orderId);
  Future<OrderModel> createOrder(OrderModel order);
  Future<OrderModel> updateOrder(OrderModel order);
  Future<void> cancelOrder(String orderId, String reason);

  // Order search and filtering
  Future<List<OrderModel>> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });

  // Order items
  Future<List<OrderItemModel>> getOrderItems(String orderId);
  Future<OrderItemModel?> getOrderItemById(String orderItemId);
  Future<OrderItemModel> updateOrderItem(OrderItemModel orderItem);

  // Shipment operations
  Future<List<ShipmentModel>> getOrderShipments(String orderId);
  Future<ShipmentModel?> getShipmentById(String shipmentId);
  Future<ShipmentModel?> getShipmentByTrackingNumber(String trackingNumber);
  Future<List<ShipmentModel>> trackShipments(List<String> trackingNumbers);

  // Return operations
  Future<List<ReturnModel>> getUserReturns(
    String userId, {
    int page = 1,
    int limit = 20,
  });
  Future<ReturnModel?> getReturnById(String returnId);
  Future<ReturnModel> createReturn(ReturnModel returnRequest);
  Future<ReturnModel> updateReturn(ReturnModel returnRequest);
  Future<void> cancelReturn(String returnId);

  // Statistics
  Future<Map<String, dynamic>> getOrderStatistics(String userId);
  Future<int> getOrderCount(String userId, {OrderStatus? status});
}

class OrdersRemoteDataSourceImpl implements OrdersRemoteDataSource {
  final FirebaseFirestore _firestore;

  OrdersRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<OrderModel>> getUserOrders(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print(
        '🔍 Fetching orders for user: $userId (page: $page, limit: $limit)',
      );

      Query query = _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .orderBy('orderDate', descending: true);

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
          .map(
            (doc) => OrderModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      print('✅ Found ${orders.length} orders for user');
      return orders;
    } catch (e) {
      print('❌ Error fetching user orders: $e');
      throw Exception('Failed to fetch user orders: $e');
    }
  }

  @override
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      print('🔍 Fetching order details for: $orderId');

      final doc = await _firestore.collection('orders').doc(orderId).get();

      if (!doc.exists) {
        print('⚠️ Order not found: $orderId');
        return null;
      }

      final order = OrderModel.fromJson({'id': doc.id, ...doc.data()!});
      print('✅ Order found: ${order.orderNumber}');
      return order;
    } catch (e) {
      print('❌ Error fetching order: $e');
      throw Exception('Failed to fetch order: $e');
    }
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    try {
      print('🔍 Creating new order: ${order.orderNumber}');

      final orderData = order.toJson();
      orderData.remove('id'); // Remove id before creating
      final docRef = await _firestore.collection('orders').add(orderData);

      // Create new order with the generated ID
      final createdOrder = OrderModel.fromJson({'id': docRef.id, ...orderData});

      print('✅ Order created with ID: ${docRef.id}');
      return createdOrder;
    } catch (e) {
      print('❌ Error creating order: $e');
      throw Exception('Failed to create order: $e');
    }
  }

  @override
  Future<OrderModel> updateOrder(OrderModel order) async {
    try {
      print('🔍 Updating order: ${order.id}');

      await _firestore
          .collection('orders')
          .doc(order.id)
          .update(order.toJson());

      print('✅ Order updated: ${order.id}');
      return order;
    } catch (e) {
      print('❌ Error updating order: $e');
      throw Exception('Failed to update order: $e');
    }
  }

  @override
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      print('🔍 Cancelling order: $orderId');

      await _firestore.collection('orders').doc(orderId).update({
        'status': OrderStatus.cancelled.name,
        'cancelledDate': FieldValue.serverTimestamp(),
        'cancellationReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Order cancelled: $orderId');
    } catch (e) {
      print('❌ Error cancelling order: $e');
      throw Exception('Failed to cancel order: $e');
    }
  }

  @override
  Future<List<OrderModel>> searchOrders(
    String userId, {
    String? query,
    OrderStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🔍 Searching orders for user: $userId');

      Query firestoreQuery = _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId);

      if (status != null) {
        firestoreQuery = firestoreQuery.where('status', isEqualTo: status.name);
      }

      if (startDate != null) {
        firestoreQuery = firestoreQuery.where(
          'orderDate',
          isGreaterThanOrEqualTo: startDate,
        );
      }

      if (endDate != null) {
        firestoreQuery = firestoreQuery.where(
          'orderDate',
          isLessThanOrEqualTo: endDate,
        );
      }

      firestoreQuery = firestoreQuery.orderBy('orderDate', descending: true);

      if (page > 1) {
        final offset = (page - 1) * limit;
        firestoreQuery = firestoreQuery.limit(offset + limit);
      } else {
        firestoreQuery = firestoreQuery.limit(limit);
      }

      final querySnapshot = await firestoreQuery.get();

      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      if (page > 1) {
        final offset = (page - 1) * limit;
        docs = docs.skip(offset).toList();
      }

      List<OrderModel> orders = docs
          .map(
            (doc) => OrderModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      // Apply text search filter if query is provided
      if (query != null && query.isNotEmpty) {
        orders = orders
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

      print('✅ Found ${orders.length} orders matching search criteria');
      return orders;
    } catch (e) {
      print('❌ Error searching orders: $e');
      throw Exception('Failed to search orders: $e');
    }
  }

  @override
  Future<List<OrderItemModel>> getOrderItems(String orderId) async {
    try {
      print('🔍 Fetching order items for: $orderId');

      final querySnapshot = await _firestore
          .collection('orderItems')
          .where('orderId', isEqualTo: orderId)
          .get();

      final items = querySnapshot.docs
          .map((doc) => OrderItemModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();

      print('✅ Found ${items.length} order items');
      return items;
    } catch (e) {
      print('❌ Error fetching order items: $e');
      throw Exception('Failed to fetch order items: $e');
    }
  }

  @override
  Future<OrderItemModel?> getOrderItemById(String orderItemId) async {
    try {
      final doc = await _firestore
          .collection('orderItems')
          .doc(orderItemId)
          .get();

      if (!doc.exists) return null;

      return OrderItemModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch order item: $e');
    }
  }

  @override
  Future<OrderItemModel> updateOrderItem(OrderItemModel orderItem) async {
    try {
      await _firestore
          .collection('orderItems')
          .doc(orderItem.id)
          .update(orderItem.toJson());
      return orderItem;
    } catch (e) {
      throw Exception('Failed to update order item: $e');
    }
  }

  @override
  Future<List<ShipmentModel>> getOrderShipments(String orderId) async {
    try {
      print('🔍 Fetching shipments for order: $orderId');

      final querySnapshot = await _firestore
          .collection('shipments')
          .where('orderId', isEqualTo: orderId)
          .get();

      final shipments = querySnapshot.docs
          .map((doc) => ShipmentModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();

      print('✅ Found ${shipments.length} shipments');
      return shipments;
    } catch (e) {
      print('❌ Error fetching shipments: $e');
      throw Exception('Failed to fetch shipments: $e');
    }
  }

  @override
  Future<ShipmentModel?> getShipmentById(String shipmentId) async {
    try {
      final doc = await _firestore
          .collection('shipments')
          .doc(shipmentId)
          .get();

      if (!doc.exists) return null;

      return ShipmentModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch shipment: $e');
    }
  }

  @override
  Future<ShipmentModel?> getShipmentByTrackingNumber(
    String trackingNumber,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('shipments')
          .where('trackingNumber', isEqualTo: trackingNumber)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return ShipmentModel.fromJson({'id': doc.id, ...doc.data()});
    } catch (e) {
      throw Exception('Failed to fetch shipment by tracking number: $e');
    }
  }

  @override
  Future<List<ShipmentModel>> trackShipments(
    List<String> trackingNumbers,
  ) async {
    try {
      if (trackingNumbers.isEmpty) return [];

      final querySnapshot = await _firestore
          .collection('shipments')
          .where('trackingNumber', whereIn: trackingNumbers)
          .get();

      return querySnapshot.docs
          .map((doc) => ShipmentModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to track shipments: $e');
    }
  }

  @override
  Future<List<ReturnModel>> getUserReturns(
    String userId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🔍 Fetching returns for user: $userId');

      Query query = _firestore
          .collection('returns')
          .where('userId', isEqualTo: userId)
          .orderBy('requestDate', descending: true);

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

      final returns = docs
          .map(
            (doc) => ReturnModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      print('✅ Found ${returns.length} returns');
      return returns;
    } catch (e) {
      print('❌ Error fetching returns: $e');
      throw Exception('Failed to fetch returns: $e');
    }
  }

  @override
  Future<ReturnModel?> getReturnById(String returnId) async {
    try {
      final doc = await _firestore.collection('returns').doc(returnId).get();

      if (!doc.exists) return null;

      return ReturnModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch return: $e');
    }
  }

  @override
  Future<ReturnModel> createReturn(ReturnModel returnRequest) async {
    try {
      print('🔍 Creating return request: ${returnRequest.returnNumber}');

      final returnData = returnRequest.toJson();
      returnData.remove('id');
      final docRef = await _firestore.collection('returns').add(returnData);

      final createdReturn = ReturnModel.fromJson({
        'id': docRef.id,
        ...returnData,
      });

      print('✅ Return created with ID: ${docRef.id}');
      return createdReturn;
    } catch (e) {
      print('❌ Error creating return: $e');
      throw Exception('Failed to create return: $e');
    }
  }

  @override
  Future<ReturnModel> updateReturn(ReturnModel returnRequest) async {
    try {
      await _firestore
          .collection('returns')
          .doc(returnRequest.id)
          .update(returnRequest.toJson());
      return returnRequest;
    } catch (e) {
      throw Exception('Failed to update return: $e');
    }
  }

  @override
  Future<void> cancelReturn(String returnId) async {
    try {
      await _firestore.collection('returns').doc(returnId).update({
        'status': ReturnStatus.cancelled.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel return: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getOrderStatistics(String userId) async {
    try {
      print('🔍 Fetching order statistics for user: $userId');

      final ordersQuery = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      final orders = ordersQuery.docs;
      final totalOrders = orders.length;

      int pendingOrders = 0;
      int completedOrders = 0;
      int cancelledOrders = 0;
      double totalSpent = 0.0;

      for (final doc in orders) {
        final data = doc.data();
        final status = data['status'] as String?;
        final totalAmount = (data['totalAmount'] as num?)?.toDouble() ?? 0.0;

        totalSpent += totalAmount;

        switch (status) {
          case 'pending':
          case 'confirmed':
          case 'processing':
            pendingOrders++;
            break;
          case 'delivered':
            completedOrders++;
            break;
          case 'cancelled':
            cancelledOrders++;
            break;
        }
      }

      final statistics = {
        'totalOrders': totalOrders,
        'pendingOrders': pendingOrders,
        'completedOrders': completedOrders,
        'cancelledOrders': cancelledOrders,
        'totalSpent': totalSpent,
        'currency': 'TZS',
      };

      print('✅ Order statistics calculated');
      return statistics;
    } catch (e) {
      print('❌ Error fetching order statistics: $e');
      throw Exception('Failed to fetch order statistics: $e');
    }
  }

  @override
  Future<int> getOrderCount(String userId, {OrderStatus? status}) async {
    try {
      Query query = _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to get order count: $e');
    }
  }
}
