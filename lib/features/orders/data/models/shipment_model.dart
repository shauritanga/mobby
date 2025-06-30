import '../../domain/entities/shipment.dart';

class TrackingEventModel extends TrackingEvent {
  const TrackingEventModel({
    required super.id,
    required super.description,
    required super.location,
    required super.timestamp,
    required super.status,
    super.notes,
  });

  factory TrackingEventModel.fromJson(Map<String, dynamic> json) {
    return TrackingEventModel(
      id: json['id'] as String,
      description: json['description'] as String,
      location: json['location'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: ShipmentStatus.values.byName(json['status'] as String),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'description': description,
      'location': location,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'notes': notes,
    };
  }

  factory TrackingEventModel.fromEntity(TrackingEvent event) {
    return TrackingEventModel(
      id: event.id,
      description: event.description,
      location: event.location,
      timestamp: event.timestamp,
      status: event.status,
      notes: event.notes,
    );
  }

  TrackingEvent toEntity() => this;
}

class ShipmentModel extends Shipment {
  const ShipmentModel({
    required super.id,
    required super.orderId,
    required super.trackingNumber,
    required super.carrier,
    required super.shippingMethod,
    required super.status,
    required super.orderItemIds,
    required super.weight,
    super.dimensions,
    super.shippedDate,
    super.estimatedDeliveryDate,
    super.deliveredDate,
    super.deliveredTo,
    super.deliverySignature,
    required super.trackingEvents,
    required super.shippingCost,
    required super.currency,
    super.notes,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      trackingNumber: json['trackingNumber'] as String,
      carrier: json['carrier'] as String,
      shippingMethod: ShippingMethod.values.byName(
        json['shippingMethod'] as String,
      ),
      status: ShipmentStatus.values.byName(json['status'] as String),
      orderItemIds: List<String>.from(json['orderItemIds'] ?? []),
      weight: (json['weight'] as num).toDouble(),
      dimensions: json['dimensions'] as String?,
      shippedDate: json['shippedDate'] != null
          ? DateTime.parse(json['shippedDate'] as String)
          : null,
      estimatedDeliveryDate: json['estimatedDeliveryDate'] != null
          ? DateTime.parse(json['estimatedDeliveryDate'] as String)
          : null,
      deliveredDate: json['deliveredDate'] != null
          ? DateTime.parse(json['deliveredDate'] as String)
          : null,
      deliveredTo: json['deliveredTo'] as String?,
      deliverySignature: json['deliverySignature'] as String?,
      trackingEvents: [], // Simplified for now
      shippingCost: (json['shippingCost'] as num).toDouble(),
      currency: json['currency'] as String,
      notes: json['notes'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'trackingNumber': trackingNumber,
      'carrier': carrier,
      'shippingMethod': shippingMethod.name,
      'status': status.name,
      'orderItemIds': orderItemIds,
      'weight': weight,
      'dimensions': dimensions,
      'shippedDate': shippedDate?.toIso8601String(),
      'estimatedDeliveryDate': estimatedDeliveryDate?.toIso8601String(),
      'deliveredDate': deliveredDate?.toIso8601String(),
      'deliveredTo': deliveredTo,
      'deliverySignature': deliverySignature,
      'shippingCost': shippingCost,
      'currency': currency,
      'notes': notes,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ShipmentModel.fromEntity(Shipment shipment) {
    return ShipmentModel(
      id: shipment.id,
      orderId: shipment.orderId,
      trackingNumber: shipment.trackingNumber,
      carrier: shipment.carrier,
      shippingMethod: shipment.shippingMethod,
      status: shipment.status,
      orderItemIds: shipment.orderItemIds,
      weight: shipment.weight,
      dimensions: shipment.dimensions,
      shippedDate: shipment.shippedDate,
      estimatedDeliveryDate: shipment.estimatedDeliveryDate,
      deliveredDate: shipment.deliveredDate,
      deliveredTo: shipment.deliveredTo,
      deliverySignature: shipment.deliverySignature,
      trackingEvents: shipment.trackingEvents,
      shippingCost: shipment.shippingCost,
      currency: shipment.currency,
      notes: shipment.notes,
      metadata: shipment.metadata,
      createdAt: shipment.createdAt,
      updatedAt: shipment.updatedAt,
    );
  }

  Shipment toEntity() => this;
}
