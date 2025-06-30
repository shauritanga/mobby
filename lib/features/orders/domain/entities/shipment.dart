import 'package:equatable/equatable.dart';

enum ShipmentStatus {
  pending,
  processing,
  shipped,
  inTransit,
  outForDelivery,
  delivered,
  failed,
  returned,
  cancelled
}

enum ShippingMethod {
  standard,
  express,
  overnight,
  pickup,
  sameDay
}

class TrackingEvent extends Equatable {
  final String id;
  final String description;
  final String location;
  final DateTime timestamp;
  final ShipmentStatus status;
  final String? notes;

  const TrackingEvent({
    required this.id,
    required this.description,
    required this.location,
    required this.timestamp,
    required this.status,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        description,
        location,
        timestamp,
        status,
        notes,
      ];
}

class Shipment extends Equatable {
  final String id;
  final String orderId;
  final String trackingNumber;
  final String carrier;
  final ShippingMethod shippingMethod;
  final ShipmentStatus status;
  final List<String> orderItemIds;
  final double weight;
  final String? dimensions;
  final DateTime? shippedDate;
  final DateTime? estimatedDeliveryDate;
  final DateTime? deliveredDate;
  final String? deliveredTo;
  final String? deliverySignature;
  final List<TrackingEvent> trackingEvents;
  final double shippingCost;
  final String currency;
  final String? notes;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Shipment({
    required this.id,
    required this.orderId,
    required this.trackingNumber,
    required this.carrier,
    required this.shippingMethod,
    required this.status,
    required this.orderItemIds,
    required this.weight,
    this.dimensions,
    this.shippedDate,
    this.estimatedDeliveryDate,
    this.deliveredDate,
    this.deliveredTo,
    this.deliverySignature,
    required this.trackingEvents,
    required this.shippingCost,
    required this.currency,
    this.notes,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isDelivered => status == ShipmentStatus.delivered;
  
  bool get isInTransit => status == ShipmentStatus.inTransit || 
                         status == ShipmentStatus.outForDelivery;
  
  bool get canBeTracked => trackingNumber.isNotEmpty && 
                          status != ShipmentStatus.pending;

  TrackingEvent? get latestTrackingEvent {
    if (trackingEvents.isEmpty) return null;
    return trackingEvents.reduce((a, b) => 
        a.timestamp.isAfter(b.timestamp) ? a : b);
  }

  @override
  List<Object?> get props => [
        id,
        orderId,
        trackingNumber,
        carrier,
        shippingMethod,
        status,
        orderItemIds,
        weight,
        dimensions,
        shippedDate,
        estimatedDeliveryDate,
        deliveredDate,
        deliveredTo,
        deliverySignature,
        trackingEvents,
        shippingCost,
        currency,
        notes,
        metadata,
        createdAt,
        updatedAt,
      ];
}
