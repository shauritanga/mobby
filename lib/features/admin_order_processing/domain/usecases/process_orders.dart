import '../entities/order.dart';
import '../repositories/admin_order_repository.dart';

class GetOrdersParams {
  final String? searchQuery;
  final OrderStatus? status;
  final OrderPriority? priority;
  final PaymentStatus? paymentStatus;
  final String? assignedTo;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sortBy;
  final bool sortDescending;
  final int page;
  final int limit;

  const GetOrdersParams({
    this.searchQuery,
    this.status,
    this.priority,
    this.paymentStatus,
    this.assignedTo,
    this.startDate,
    this.endDate,
    this.sortBy,
    this.sortDescending = false,
    this.page = 1,
    this.limit = 20,
  });
}

class GetOrders {
  final AdminOrderRepository repository;

  GetOrders(this.repository);

  Future<List<Order>> call(GetOrdersParams params) async {
    return await repository.getOrders(
      searchQuery: params.searchQuery,
      status: params.status,
      priority: params.priority,
      paymentStatus: params.paymentStatus,
      assignedTo: params.assignedTo,
      startDate: params.startDate,
      endDate: params.endDate,
      sortBy: params.sortBy,
      sortDescending: params.sortDescending,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetOrderById {
  final AdminOrderRepository repository;

  GetOrderById(this.repository);

  Future<Order?> call(String orderId) async {
    return await repository.getOrderById(orderId);
  }
}

class GetOrderByNumber {
  final AdminOrderRepository repository;

  GetOrderByNumber(this.repository);

  Future<Order?> call(String orderNumber) async {
    return await repository.getOrderByNumber(orderNumber);
  }
}

class UpdateOrderStatusParams {
  final String orderId;
  final OrderStatus status;
  final String? notes;

  const UpdateOrderStatusParams({
    required this.orderId,
    required this.status,
    this.notes,
  });
}

class UpdateOrderStatus {
  final AdminOrderRepository repository;

  UpdateOrderStatus(this.repository);

  Future<void> call(UpdateOrderStatusParams params) async {
    // Validate status transition
    final order = await repository.getOrderById(params.orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    // Check if status transition is valid
    if (!_isValidStatusTransition(order.status, params.status)) {
      throw Exception('Invalid status transition from ${order.status.displayName} to ${params.status.displayName}');
    }

    // Update order status
    await repository.updateOrderStatus(params.orderId, params.status, notes: params.notes);

    // Handle side effects based on new status
    await _handleStatusSideEffects(params.orderId, params.status);
  }

  bool _isValidStatusTransition(OrderStatus currentStatus, OrderStatus newStatus) {
    // Define valid status transitions
    const validTransitions = {
      OrderStatus.pending: [OrderStatus.confirmed, OrderStatus.cancelled],
      OrderStatus.confirmed: [OrderStatus.processing, OrderStatus.cancelled],
      OrderStatus.processing: [OrderStatus.shipped, OrderStatus.cancelled],
      OrderStatus.shipped: [OrderStatus.delivered, OrderStatus.returned],
      OrderStatus.delivered: [OrderStatus.returned, OrderStatus.refunded],
      OrderStatus.cancelled: [], // Terminal state
      OrderStatus.refunded: [], // Terminal state
      OrderStatus.returned: [OrderStatus.refunded],
    };

    return validTransitions[currentStatus]?.contains(newStatus) ?? false;
  }

  Future<void> _handleStatusSideEffects(String orderId, OrderStatus status) async {
    switch (status) {
      case OrderStatus.confirmed:
        // Reserve inventory
        await repository.reserveInventory(orderId);
        // Send order confirmation
        await repository.sendOrderConfirmation(orderId);
        break;
      case OrderStatus.processing:
        // Process order workflow
        await repository.processOrder(orderId);
        break;
      case OrderStatus.shipped:
        // Update inventory
        // Send shipping notification (handled in shipping use cases)
        break;
      case OrderStatus.delivered:
        // Capture payment if not already captured
        await repository.capturePayment(orderId);
        // Send delivery notification
        break;
      case OrderStatus.cancelled:
        // Release inventory
        await repository.releaseInventory(orderId);
        // Void payment if not captured
        await repository.voidPayment(orderId);
        break;
      case OrderStatus.refunded:
        // Process refund
        break;
      default:
        break;
    }
  }
}

class UpdateOrderPriorityParams {
  final String orderId;
  final OrderPriority priority;

  const UpdateOrderPriorityParams({
    required this.orderId,
    required this.priority,
  });
}

class UpdateOrderPriority {
  final AdminOrderRepository repository;

  UpdateOrderPriority(this.repository);

  Future<void> call(UpdateOrderPriorityParams params) async {
    await repository.updateOrderPriority(params.orderId, params.priority);
  }
}

class AssignOrderParams {
  final String orderId;
  final String assignedTo;
  final String assignedToName;

  const AssignOrderParams({
    required this.orderId,
    required this.assignedTo,
    required this.assignedToName,
  });
}

class AssignOrder {
  final AdminOrderRepository repository;

  AssignOrder(this.repository);

  Future<void> call(AssignOrderParams params) async {
    await repository.assignOrder(params.orderId, params.assignedTo, params.assignedToName);
  }
}

class UnassignOrder {
  final AdminOrderRepository repository;

  UnassignOrder(this.repository);

  Future<void> call(String orderId) async {
    await repository.unassignOrder(orderId);
  }
}

class AddOrderNotesParams {
  final String orderId;
  final String notes;
  final bool isAdminNote;

  const AddOrderNotesParams({
    required this.orderId,
    required this.notes,
    this.isAdminNote = false,
  });
}

class AddOrderNotes {
  final AdminOrderRepository repository;

  AddOrderNotes(this.repository);

  Future<void> call(AddOrderNotesParams params) async {
    await repository.addOrderNotes(
      params.orderId,
      params.notes,
      isAdminNote: params.isAdminNote,
    );
  }
}

class ProcessOrderParams {
  final String orderId;
  final String? notes;

  const ProcessOrderParams({
    required this.orderId,
    this.notes,
  });
}

class ProcessOrder {
  final AdminOrderRepository repository;

  ProcessOrder(this.repository);

  Future<void> call(ProcessOrderParams params) async {
    // Validate order can be processed
    final order = await repository.getOrderById(params.orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    if (!order.status.canProcess) {
      throw Exception('Order cannot be processed in current status: ${order.status.displayName}');
    }

    // Check inventory availability
    final inventoryAvailable = await repository.checkInventoryAvailability(params.orderId);
    if (!inventoryAvailable) {
      throw Exception('Insufficient inventory to process order');
    }

    // Validate order
    final isValid = await repository.validateOrder(params.orderId);
    if (!isValid) {
      final errors = await repository.getOrderValidationErrors(params.orderId);
      throw Exception('Order validation failed: ${errors.join(', ')}');
    }

    // Process the order
    await repository.processOrder(params.orderId, notes: params.notes);

    // Update status to processing
    await repository.updateOrderStatus(params.orderId, OrderStatus.processing, notes: params.notes);
  }
}

class CancelOrderParams {
  final String orderId;
  final String reason;
  final String? notes;

  const CancelOrderParams({
    required this.orderId,
    required this.reason,
    this.notes,
  });
}

class CancelOrder {
  final AdminOrderRepository repository;

  CancelOrder(this.repository);

  Future<void> call(CancelOrderParams params) async {
    // Validate order can be cancelled
    final order = await repository.getOrderById(params.orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    if (!order.status.canCancel) {
      throw Exception('Order cannot be cancelled in current status: ${order.status.displayName}');
    }

    // Cancel the order
    await repository.cancelOrder(params.orderId, params.reason, notes: params.notes);

    // Update status to cancelled
    await repository.updateOrderStatus(params.orderId, OrderStatus.cancelled, notes: params.notes);
  }
}

class GetOrderQueue {
  final AdminOrderRepository repository;

  GetOrderQueue(this.repository);

  Future<List<Order>> call({
    List<OrderStatus>? statuses,
    OrderPriority? minPriority,
    String? assignedTo,
    int limit = 50,
  }) async {
    return await repository.getOrderQueue(
      statuses: statuses,
      minPriority: minPriority,
      assignedTo: assignedTo,
      limit: limit,
    );
  }
}

class GetOrdersAnalytics {
  final AdminOrderRepository repository;

  GetOrdersAnalytics(this.repository);

  Future<Map<String, dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getOrdersAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class SearchOrders {
  final AdminOrderRepository repository;

  SearchOrders(this.repository);

  Future<List<Order>> call(String query, {int limit = 10}) async {
    return await repository.searchOrders(query, limit: limit);
  }
}

class BulkUpdateOrderStatusParams {
  final List<String> orderIds;
  final OrderStatus status;

  const BulkUpdateOrderStatusParams({
    required this.orderIds,
    required this.status,
  });
}

class BulkUpdateOrderStatus {
  final AdminOrderRepository repository;

  BulkUpdateOrderStatus(this.repository);

  Future<void> call(BulkUpdateOrderStatusParams params) async {
    // Validate all orders can be updated to the new status
    for (final orderId in params.orderIds) {
      final order = await repository.getOrderById(orderId);
      if (order == null) {
        throw Exception('Order $orderId not found');
      }

      if (!_isValidStatusTransition(order.status, params.status)) {
        throw Exception('Invalid status transition for order $orderId from ${order.status.displayName} to ${params.status.displayName}');
      }
    }

    // Perform bulk update
    await repository.bulkUpdateOrderStatus(params.orderIds, params.status);
  }

  bool _isValidStatusTransition(OrderStatus currentStatus, OrderStatus newStatus) {
    const validTransitions = {
      OrderStatus.pending: [OrderStatus.confirmed, OrderStatus.cancelled],
      OrderStatus.confirmed: [OrderStatus.processing, OrderStatus.cancelled],
      OrderStatus.processing: [OrderStatus.shipped, OrderStatus.cancelled],
      OrderStatus.shipped: [OrderStatus.delivered, OrderStatus.returned],
      OrderStatus.delivered: [OrderStatus.returned, OrderStatus.refunded],
      OrderStatus.cancelled: [],
      OrderStatus.refunded: [],
      OrderStatus.returned: [OrderStatus.refunded],
    };

    return validTransitions[currentStatus]?.contains(newStatus) ?? false;
  }
}
