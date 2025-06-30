enum ShipmentStatus {
  pending,
  processing,
  shipped,
  inTransit,
  outForDelivery,
  delivered,
  failed,
  returned,
  cancelled;

  String get displayName {
    switch (this) {
      case ShipmentStatus.pending:
        return 'Pending';
      case ShipmentStatus.processing:
        return 'Processing';
      case ShipmentStatus.shipped:
        return 'Shipped';
      case ShipmentStatus.inTransit:
        return 'In Transit';
      case ShipmentStatus.outForDelivery:
        return 'Out for Delivery';
      case ShipmentStatus.delivered:
        return 'Delivered';
      case ShipmentStatus.failed:
        return 'Failed';
      case ShipmentStatus.returned:
        return 'Returned';
      case ShipmentStatus.cancelled:
        return 'Cancelled';
    }
  }

  bool get isActive {
    return this != ShipmentStatus.delivered && 
           this != ShipmentStatus.failed && 
           this != ShipmentStatus.returned && 
           this != ShipmentStatus.cancelled;
  }

  bool get canCancel {
    return this == ShipmentStatus.pending || this == ShipmentStatus.processing;
  }

  bool get canTrack {
    return this == ShipmentStatus.shipped || 
           this == ShipmentStatus.inTransit || 
           this == ShipmentStatus.outForDelivery;
  }
}

enum ShippingMethod {
  standard,
  express,
  overnight,
  pickup,
  sameDay;

  String get displayName {
    switch (this) {
      case ShippingMethod.standard:
        return 'Standard Shipping';
      case ShippingMethod.express:
        return 'Express Shipping';
      case ShippingMethod.overnight:
        return 'Overnight Shipping';
      case ShippingMethod.pickup:
        return 'Store Pickup';
      case ShippingMethod.sameDay:
        return 'Same Day Delivery';
    }
  }
}

class ShippingCarrier {
  final String id;
  final String name;
  final String code;
  final String? logoUrl;
  final String? trackingUrl;
  final bool isActive;

  const ShippingCarrier({
    required this.id,
    required this.name,
    required this.code,
    this.logoUrl,
    this.trackingUrl,
    this.isActive = true,
  });

  ShippingCarrier copyWith({
    String? id,
    String? name,
    String? code,
    String? logoUrl,
    String? trackingUrl,
    bool? isActive,
  }) {
    return ShippingCarrier(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      logoUrl: logoUrl ?? this.logoUrl,
      trackingUrl: trackingUrl ?? this.trackingUrl,
      isActive: isActive ?? this.isActive,
    );
  }
}

class TrackingEvent {
  final String id;
  final String status;
  final String description;
  final String? location;
  final DateTime timestamp;
  final Map<String, dynamic> metadata;

  const TrackingEvent({
    required this.id,
    required this.status,
    required this.description,
    this.location,
    required this.timestamp,
    this.metadata = const {},
  });

  TrackingEvent copyWith({
    String? id,
    String? status,
    String? description,
    String? location,
    DateTime? timestamp,
    Map<String, dynamic>? metadata,
  }) {
    return TrackingEvent(
      id: id ?? this.id,
      status: status ?? this.status,
      description: description ?? this.description,
      location: location ?? this.location,
      timestamp: timestamp ?? this.timestamp,
      metadata: metadata ?? this.metadata,
    );
  }
}

class ShipmentItem {
  final String id;
  final String orderItemId;
  final String productId;
  final String productName;
  final String productSku;
  final int quantity;
  final double weight;
  final Map<String, dynamic> dimensions;

  const ShipmentItem({
    required this.id,
    required this.orderItemId,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.quantity,
    this.weight = 0.0,
    this.dimensions = const {},
  });

  ShipmentItem copyWith({
    String? id,
    String? orderItemId,
    String? productId,
    String? productName,
    String? productSku,
    int? quantity,
    double? weight,
    Map<String, dynamic>? dimensions,
  }) {
    return ShipmentItem(
      id: id ?? this.id,
      orderItemId: orderItemId ?? this.orderItemId,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      quantity: quantity ?? this.quantity,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
    );
  }
}

class ShippingAddress {
  final String firstName;
  final String lastName;
  final String? company;
  final String street;
  final String? street2;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final String? phone;
  final String? email;
  final String? instructions;

  const ShippingAddress({
    required this.firstName,
    required this.lastName,
    this.company,
    required this.street,
    this.street2,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.phone,
    this.email,
    this.instructions,
  });

  String get fullName => '$firstName $lastName';

  String get formattedAddress {
    final parts = <String>[
      if (company != null) company!,
      fullName,
      street,
      if (street2 != null) street2!,
      '$city, $state $postalCode',
      country,
    ];
    return parts.join('\n');
  }

  ShippingAddress copyWith({
    String? firstName,
    String? lastName,
    String? company,
    String? street,
    String? street2,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    String? phone,
    String? email,
    String? instructions,
  }) {
    return ShippingAddress(
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      company: company ?? this.company,
      street: street ?? this.street,
      street2: street2 ?? this.street2,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      instructions: instructions ?? this.instructions,
    );
  }
}

class Shipment {
  final String id;
  final String orderId;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final ShipmentStatus status;
  final ShippingMethod method;
  final ShippingCarrier carrier;
  final String? trackingNumber;
  final String? trackingUrl;
  final List<ShipmentItem> items;
  final ShippingAddress shippingAddress;
  final double weight;
  final Map<String, dynamic> dimensions;
  final double shippingCost;
  final String currency;
  final List<TrackingEvent> trackingEvents;
  final String? notes;
  final String? internalNotes;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final DateTime? estimatedDelivery;
  final DateTime? actualDelivery;
  final DateTime? shippedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const Shipment({
    required this.id,
    required this.orderId,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.status,
    required this.method,
    required this.carrier,
    this.trackingNumber,
    this.trackingUrl,
    required this.items,
    required this.shippingAddress,
    this.weight = 0.0,
    this.dimensions = const {},
    this.shippingCost = 0.0,
    required this.currency,
    this.trackingEvents = const [],
    this.notes,
    this.internalNotes,
    this.metadata = const {},
    this.tags = const [],
    this.estimatedDelivery,
    this.actualDelivery,
    this.shippedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get hasTracking => trackingNumber != null && trackingNumber!.isNotEmpty;

  bool get isDelivered => status == ShipmentStatus.delivered;

  bool get canTrack => status.canTrack && hasTracking;

  String get statusDisplayName => status.displayName;

  String get methodDisplayName => method.displayName;

  TrackingEvent? get latestTrackingEvent {
    if (trackingEvents.isEmpty) return null;
    return trackingEvents.reduce((a, b) => 
        a.timestamp.isAfter(b.timestamp) ? a : b);
  }

  Shipment copyWith({
    String? id,
    String? orderId,
    String? orderNumber,
    String? customerId,
    String? customerName,
    ShipmentStatus? status,
    ShippingMethod? method,
    ShippingCarrier? carrier,
    String? trackingNumber,
    String? trackingUrl,
    List<ShipmentItem>? items,
    ShippingAddress? shippingAddress,
    double? weight,
    Map<String, dynamic>? dimensions,
    double? shippingCost,
    String? currency,
    List<TrackingEvent>? trackingEvents,
    String? notes,
    String? internalNotes,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    DateTime? estimatedDelivery,
    DateTime? actualDelivery,
    DateTime? shippedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Shipment(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      method: method ?? this.method,
      carrier: carrier ?? this.carrier,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      trackingUrl: trackingUrl ?? this.trackingUrl,
      items: items ?? this.items,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      weight: weight ?? this.weight,
      dimensions: dimensions ?? this.dimensions,
      shippingCost: shippingCost ?? this.shippingCost,
      currency: currency ?? this.currency,
      trackingEvents: trackingEvents ?? this.trackingEvents,
      notes: notes ?? this.notes,
      internalNotes: internalNotes ?? this.internalNotes,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      actualDelivery: actualDelivery ?? this.actualDelivery,
      shippedAt: shippedAt ?? this.shippedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
