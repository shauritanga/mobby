import '../entities/order.dart';
import '../entities/shipment.dart';
import '../repositories/admin_order_repository.dart';

class GetShipmentsParams {
  final String? searchQuery;
  final String? orderId;
  final ShipmentStatus? status;
  final ShippingMethod? method;
  final String? carrierId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? sortBy;
  final bool sortDescending;
  final int page;
  final int limit;

  const GetShipmentsParams({
    this.searchQuery,
    this.orderId,
    this.status,
    this.method,
    this.carrierId,
    this.startDate,
    this.endDate,
    this.sortBy,
    this.sortDescending = false,
    this.page = 1,
    this.limit = 20,
  });
}

class GetShipments {
  final AdminOrderRepository repository;

  GetShipments(this.repository);

  Future<List<Shipment>> call(GetShipmentsParams params) async {
    return await repository.getShipments(
      searchQuery: params.searchQuery,
      orderId: params.orderId,
      status: params.status,
      method: params.method,
      carrierId: params.carrierId,
      startDate: params.startDate,
      endDate: params.endDate,
      sortBy: params.sortBy,
      sortDescending: params.sortDescending,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetShipmentById {
  final AdminOrderRepository repository;

  GetShipmentById(this.repository);

  Future<Shipment?> call(String shipmentId) async {
    return await repository.getShipmentById(shipmentId);
  }
}

class GetShipmentsByOrder {
  final AdminOrderRepository repository;

  GetShipmentsByOrder(this.repository);

  Future<List<Shipment>> call(String orderId) async {
    return await repository.getShipmentsByOrder(orderId);
  }
}

class CreateShipmentParams {
  final String orderId;
  final ShippingMethod method;
  final String carrierId;
  final List<String> itemIds;
  final String? notes;

  const CreateShipmentParams({
    required this.orderId,
    required this.method,
    required this.carrierId,
    required this.itemIds,
    this.notes,
  });
}

class CreateShipment {
  final AdminOrderRepository repository;

  CreateShipment(this.repository);

  Future<Shipment> call(CreateShipmentParams params) async {
    // Get the order
    final order = await repository.getOrderById(params.orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    // Validate order can be shipped
    if (!order.status.canShip) {
      throw Exception('Order cannot be shipped in current status: ${order.status.displayName}');
    }

    // Get shipping carrier
    final carrier = await repository.getShippingCarrierById(params.carrierId);
    if (carrier == null) {
      throw Exception('Shipping carrier not found');
    }

    // Create shipment items from order items
    final shipmentItems = <ShipmentItem>[];
    for (final itemId in params.itemIds) {
      final orderItem = order.items.firstWhere(
        (item) => item.id == itemId,
        orElse: () => throw Exception('Order item $itemId not found'),
      );

      shipmentItems.add(ShipmentItem(
        id: '', // Will be generated
        orderItemId: orderItem.id,
        productId: orderItem.productId,
        productName: orderItem.productName,
        productSku: orderItem.productSku,
        quantity: orderItem.quantity,
      ));
    }

    // Create shipping address from order
    final shippingAddress = ShippingAddress(
      firstName: order.shippingAddress.firstName,
      lastName: order.shippingAddress.lastName,
      company: order.shippingAddress.company,
      street: order.shippingAddress.street,
      street2: order.shippingAddress.street2,
      city: order.shippingAddress.city,
      state: order.shippingAddress.state,
      postalCode: order.shippingAddress.postalCode,
      country: order.shippingAddress.country,
      phone: order.shippingAddress.phone,
      email: order.shippingAddress.email,
    );

    // Create shipment
    final shipment = Shipment(
      id: '', // Will be generated
      orderId: order.id,
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      customerName: order.customerName,
      status: ShipmentStatus.pending,
      method: params.method,
      carrier: carrier,
      items: shipmentItems,
      shippingAddress: shippingAddress,
      shippingCost: order.shippingAmount,
      currency: order.currency,
      notes: params.notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      createdBy: '', // Will be set by repository
    );

    return await repository.createShipment(shipment);
  }
}

class UpdateShipmentStatusParams {
  final String shipmentId;
  final ShipmentStatus status;
  final String? notes;

  const UpdateShipmentStatusParams({
    required this.shipmentId,
    required this.status,
    this.notes,
  });
}

class UpdateShipmentStatus {
  final AdminOrderRepository repository;

  UpdateShipmentStatus(this.repository);

  Future<void> call(UpdateShipmentStatusParams params) async {
    // Get the shipment
    final shipment = await repository.getShipmentById(params.shipmentId);
    if (shipment == null) {
      throw Exception('Shipment not found');
    }

    // Validate status transition
    if (!_isValidStatusTransition(shipment.status, params.status)) {
      throw Exception('Invalid status transition from ${shipment.status.displayName} to ${params.status.displayName}');
    }

    // Update shipment status
    await repository.updateShipmentStatus(params.shipmentId, params.status, notes: params.notes);

    // Handle side effects
    await _handleStatusSideEffects(shipment, params.status);
  }

  bool _isValidStatusTransition(ShipmentStatus currentStatus, ShipmentStatus newStatus) {
    const validTransitions = {
      ShipmentStatus.pending: [ShipmentStatus.processing, ShipmentStatus.cancelled],
      ShipmentStatus.processing: [ShipmentStatus.shipped, ShipmentStatus.cancelled],
      ShipmentStatus.shipped: [ShipmentStatus.inTransit, ShipmentStatus.failed],
      ShipmentStatus.inTransit: [ShipmentStatus.outForDelivery, ShipmentStatus.failed],
      ShipmentStatus.outForDelivery: [ShipmentStatus.delivered, ShipmentStatus.failed],
      ShipmentStatus.delivered: [ShipmentStatus.returned],
      ShipmentStatus.failed: [ShipmentStatus.processing, ShipmentStatus.returned],
      ShipmentStatus.returned: [],
      ShipmentStatus.cancelled: [],
    };

    return validTransitions[currentStatus]?.contains(newStatus) ?? false;
  }

  Future<void> _handleStatusSideEffects(Shipment shipment, ShipmentStatus status) async {
    switch (status) {
      case ShipmentStatus.shipped:
        // Update order status to shipped
        await repository.updateOrderStatus(shipment.orderId, OrderStatus.shipped);
        // Update inventory
        await repository.updateInventoryOnShipment(shipment.id);
        // Send shipping notification
        await repository.sendShippingNotification(shipment.orderId, shipment.id);
        break;
      case ShipmentStatus.delivered:
        // Update order status to delivered
        await repository.updateOrderStatus(shipment.orderId, OrderStatus.delivered);
        // Send delivery notification
        await repository.sendDeliveryNotification(shipment.orderId, shipment.id);
        break;
      case ShipmentStatus.cancelled:
        // Check if this was the only shipment for the order
        final orderShipments = await repository.getShipmentsByOrder(shipment.orderId);
        final activeShipments = orderShipments.where((s) => s.status.isActive).toList();
        
        if (activeShipments.isEmpty) {
          // No active shipments, revert order to processing
          await repository.updateOrderStatus(shipment.orderId, OrderStatus.processing);
        }
        break;
      default:
        break;
    }
  }
}

class AddTrackingNumberParams {
  final String shipmentId;
  final String trackingNumber;
  final String? trackingUrl;

  const AddTrackingNumberParams({
    required this.shipmentId,
    required this.trackingNumber,
    this.trackingUrl,
  });
}

class AddTrackingNumber {
  final AdminOrderRepository repository;

  AddTrackingNumber(this.repository);

  Future<void> call(AddTrackingNumberParams params) async {
    await repository.addTrackingNumber(
      params.shipmentId,
      params.trackingNumber,
      params.trackingUrl,
    );

    // Update shipment tracking information
    await repository.updateShipmentTracking(params.shipmentId);
  }
}

class AddTrackingEventParams {
  final String shipmentId;
  final String status;
  final String description;
  final String? location;

  const AddTrackingEventParams({
    required this.shipmentId,
    required this.status,
    required this.description,
    this.location,
  });
}

class AddTrackingEvent {
  final AdminOrderRepository repository;

  AddTrackingEvent(this.repository);

  Future<void> call(AddTrackingEventParams params) async {
    final event = TrackingEvent(
      id: '', // Will be generated
      status: params.status,
      description: params.description,
      location: params.location,
      timestamp: DateTime.now(),
    );

    await repository.addTrackingEvent(params.shipmentId, event);
  }
}

class UpdateShipmentTracking {
  final AdminOrderRepository repository;

  UpdateShipmentTracking(this.repository);

  Future<void> call(String shipmentId) async {
    await repository.updateShipmentTracking(shipmentId);
  }
}

class GetShippingCarriers {
  final AdminOrderRepository repository;

  GetShippingCarriers(this.repository);

  Future<List<ShippingCarrier>> call({bool activeOnly = true}) async {
    return await repository.getShippingCarriers(activeOnly: activeOnly);
  }
}

class GetActiveShipments {
  final AdminOrderRepository repository;

  GetActiveShipments(this.repository);

  Future<List<Shipment>> call({int limit = 50}) async {
    return await repository.getActiveShipments(limit: limit);
  }
}

class GetDelayedShipments {
  final AdminOrderRepository repository;

  GetDelayedShipments(this.repository);

  Future<List<Shipment>> call({int limit = 50}) async {
    return await repository.getDelayedShipments(limit: limit);
  }
}

class GetShippingAnalytics {
  final AdminOrderRepository repository;

  GetShippingAnalytics(this.repository);

  Future<Map<String, dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await repository.getShippingAnalytics(
      startDate: startDate,
      endDate: endDate,
    );
  }
}

class SearchShipments {
  final AdminOrderRepository repository;

  SearchShipments(this.repository);

  Future<List<Shipment>> call(String query, {int limit = 10}) async {
    return await repository.searchShipments(query, limit: limit);
  }
}

class ShipOrderParams {
  final String orderId;
  final ShippingMethod method;
  final String carrierId;
  final String? trackingNumber;
  final String? notes;

  const ShipOrderParams({
    required this.orderId,
    required this.method,
    required this.carrierId,
    this.trackingNumber,
    this.notes,
  });
}

class ShipOrder {
  final AdminOrderRepository repository;

  ShipOrder(this.repository);

  Future<Shipment> call(ShipOrderParams params) async {
    // Get the order
    final order = await repository.getOrderById(params.orderId);
    if (order == null) {
      throw Exception('Order not found');
    }

    // Create shipment with all order items
    final createShipmentParams = CreateShipmentParams(
      orderId: params.orderId,
      method: params.method,
      carrierId: params.carrierId,
      itemIds: order.items.map((item) => item.id).toList(),
      notes: params.notes,
    );

    final createShipment = CreateShipment(repository);
    final shipment = await createShipment(createShipmentParams);

    // Add tracking number if provided
    if (params.trackingNumber != null) {
      final addTrackingParams = AddTrackingNumberParams(
        shipmentId: shipment.id,
        trackingNumber: params.trackingNumber!,
      );

      final addTracking = AddTrackingNumber(repository);
      await addTracking(addTrackingParams);
    }

    // Update shipment status to shipped
    final updateStatusParams = UpdateShipmentStatusParams(
      shipmentId: shipment.id,
      status: ShipmentStatus.shipped,
      notes: params.notes,
    );

    final updateStatus = UpdateShipmentStatus(repository);
    await updateStatus(updateStatusParams);

    return shipment;
  }
}
