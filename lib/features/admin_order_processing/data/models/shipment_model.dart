import '../../domain/entities/shipment.dart';

class ShippingCarrierModel {
  final String id;
  final String name;
  final String code;
  final String? logoUrl;
  final String? trackingUrl;
  final bool isActive;

  const ShippingCarrierModel({
    required this.id,
    required this.name,
    required this.code,
    this.logoUrl,
    this.trackingUrl,
    this.isActive = true,
  });

  factory ShippingCarrierModel.fromJson(Map<String, dynamic> json) {
    return ShippingCarrierModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      logoUrl: json['logoUrl'] as String?,
      trackingUrl: json['trackingUrl'] as String?,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'logoUrl': logoUrl,
      'trackingUrl': trackingUrl,
      'isActive': isActive,
    };
  }

  factory ShippingCarrierModel.fromEntity(ShippingCarrier carrier) {
    return ShippingCarrierModel(
      id: carrier.id,
      name: carrier.name,
      code: carrier.code,
      logoUrl: carrier.logoUrl,
      trackingUrl: carrier.trackingUrl,
      isActive: carrier.isActive,
    );
  }

  ShippingCarrier toEntity() {
    return ShippingCarrier(
      id: id,
      name: name,
      code: code,
      logoUrl: logoUrl,
      trackingUrl: trackingUrl,
      isActive: isActive,
    );
  }
}

class TrackingEventModel {
  final String id;
  final String status;
  final String description;
  final String? location;
  final String timestamp;
  final Map<String, dynamic> metadata;

  const TrackingEventModel({
    required this.id,
    required this.status,
    required this.description,
    this.location,
    required this.timestamp,
    this.metadata = const {},
  });

  factory TrackingEventModel.fromJson(Map<String, dynamic> json) {
    return TrackingEventModel(
      id: json['id'] as String,
      status: json['status'] as String,
      description: json['description'] as String,
      location: json['location'] as String?,
      timestamp: json['timestamp'] as String,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'description': description,
      'location': location,
      'timestamp': timestamp,
      'metadata': metadata,
    };
  }

  factory TrackingEventModel.fromEntity(TrackingEvent event) {
    return TrackingEventModel(
      id: event.id,
      status: event.status,
      description: event.description,
      location: event.location,
      timestamp: event.timestamp.toIso8601String(),
      metadata: event.metadata,
    );
  }

  TrackingEvent toEntity() {
    return TrackingEvent(
      id: id,
      status: status,
      description: description,
      location: location,
      timestamp: DateTime.parse(timestamp),
      metadata: metadata,
    );
  }
}

class ShipmentItemModel {
  final String id;
  final String orderItemId;
  final String productId;
  final String productName;
  final String productSku;
  final int quantity;
  final double weight;
  final Map<String, dynamic> dimensions;

  const ShipmentItemModel({
    required this.id,
    required this.orderItemId,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.quantity,
    this.weight = 0.0,
    this.dimensions = const {},
  });

  factory ShipmentItemModel.fromJson(Map<String, dynamic> json) {
    return ShipmentItemModel(
      id: json['id'] as String,
      orderItemId: json['orderItemId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String,
      quantity: json['quantity'] as int,
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      dimensions: Map<String, dynamic>.from(json['dimensions'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderItemId': orderItemId,
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'quantity': quantity,
      'weight': weight,
      'dimensions': dimensions,
    };
  }

  factory ShipmentItemModel.fromEntity(ShipmentItem item) {
    return ShipmentItemModel(
      id: item.id,
      orderItemId: item.orderItemId,
      productId: item.productId,
      productName: item.productName,
      productSku: item.productSku,
      quantity: item.quantity,
      weight: item.weight,
      dimensions: item.dimensions,
    );
  }

  ShipmentItem toEntity() {
    return ShipmentItem(
      id: id,
      orderItemId: orderItemId,
      productId: productId,
      productName: productName,
      productSku: productSku,
      quantity: quantity,
      weight: weight,
      dimensions: dimensions,
    );
  }
}

class ShippingAddressModel {
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

  const ShippingAddressModel({
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

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      company: json['company'] as String?,
      street: json['street'] as String,
      street2: json['street2'] as String?,
      city: json['city'] as String,
      state: json['state'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      instructions: json['instructions'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'company': company,
      'street': street,
      'street2': street2,
      'city': city,
      'state': state,
      'postalCode': postalCode,
      'country': country,
      'phone': phone,
      'email': email,
      'instructions': instructions,
    };
  }

  factory ShippingAddressModel.fromEntity(ShippingAddress address) {
    return ShippingAddressModel(
      firstName: address.firstName,
      lastName: address.lastName,
      company: address.company,
      street: address.street,
      street2: address.street2,
      city: address.city,
      state: address.state,
      postalCode: address.postalCode,
      country: address.country,
      phone: address.phone,
      email: address.email,
      instructions: address.instructions,
    );
  }

  ShippingAddress toEntity() {
    return ShippingAddress(
      firstName: firstName,
      lastName: lastName,
      company: company,
      street: street,
      street2: street2,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      phone: phone,
      email: email,
      instructions: instructions,
    );
  }
}

class ShipmentModel {
  final String id;
  final String orderId;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String status;
  final String method;
  final ShippingCarrierModel carrier;
  final String? trackingNumber;
  final String? trackingUrl;
  final List<ShipmentItemModel> items;
  final ShippingAddressModel shippingAddress;
  final double weight;
  final Map<String, dynamic> dimensions;
  final double shippingCost;
  final String currency;
  final List<TrackingEventModel> trackingEvents;
  final String? notes;
  final String? internalNotes;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final String? estimatedDelivery;
  final String? actualDelivery;
  final String? shippedAt;
  final String createdAt;
  final String updatedAt;
  final String createdBy;
  final String? updatedBy;

  const ShipmentModel({
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

  factory ShipmentModel.fromJson(Map<String, dynamic> json) {
    return ShipmentModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      orderNumber: json['orderNumber'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      status: json['status'] as String,
      method: json['method'] as String,
      carrier: ShippingCarrierModel.fromJson(
        json['carrier'] as Map<String, dynamic>,
      ),
      trackingNumber: json['trackingNumber'] as String?,
      trackingUrl: json['trackingUrl'] as String?,
      items: (json['items'] as List)
          .map((item) => ShipmentItemModel.fromJson(item))
          .toList(),
      shippingAddress: ShippingAddressModel.fromJson(
        json['shippingAddress'] as Map<String, dynamic>,
      ),
      weight: (json['weight'] as num?)?.toDouble() ?? 0.0,
      dimensions: Map<String, dynamic>.from(json['dimensions'] as Map? ?? {}),
      shippingCost: (json['shippingCost'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String,
      trackingEvents: (json['trackingEvents'] as List? ?? [])
          .map((event) => TrackingEventModel.fromJson(event))
          .toList(),
      notes: json['notes'] as String?,
      internalNotes: json['internalNotes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      tags: List<String>.from(json['tags'] as List? ?? []),
      estimatedDelivery: json['estimatedDelivery'] as String?,
      actualDelivery: json['actualDelivery'] as String?,
      shippedAt: json['shippedAt'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'status': status,
      'method': method,
      'carrier': carrier.toJson(),
      'trackingNumber': trackingNumber,
      'trackingUrl': trackingUrl,
      'items': items.map((item) => item.toJson()).toList(),
      'shippingAddress': shippingAddress.toJson(),
      'weight': weight,
      'dimensions': dimensions,
      'shippingCost': shippingCost,
      'currency': currency,
      'trackingEvents': trackingEvents.map((event) => event.toJson()).toList(),
      'notes': notes,
      'internalNotes': internalNotes,
      'metadata': metadata,
      'tags': tags,
      'estimatedDelivery': estimatedDelivery,
      'actualDelivery': actualDelivery,
      'shippedAt': shippedAt,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  factory ShipmentModel.fromEntity(Shipment shipment) {
    return ShipmentModel(
      id: shipment.id,
      orderId: shipment.orderId,
      orderNumber: shipment.orderNumber,
      customerId: shipment.customerId,
      customerName: shipment.customerName,
      status: shipment.status.name,
      method: shipment.method.name,
      carrier: ShippingCarrierModel.fromEntity(shipment.carrier),
      trackingNumber: shipment.trackingNumber,
      trackingUrl: shipment.trackingUrl,
      items: shipment.items
          .map((item) => ShipmentItemModel.fromEntity(item))
          .toList(),
      shippingAddress: ShippingAddressModel.fromEntity(
        shipment.shippingAddress,
      ),
      weight: shipment.weight,
      dimensions: shipment.dimensions,
      shippingCost: shipment.shippingCost,
      currency: shipment.currency,
      trackingEvents: shipment.trackingEvents
          .map((event) => TrackingEventModel.fromEntity(event))
          .toList(),
      notes: shipment.notes,
      internalNotes: shipment.internalNotes,
      metadata: shipment.metadata,
      tags: shipment.tags,
      estimatedDelivery: shipment.estimatedDelivery?.toIso8601String(),
      actualDelivery: shipment.actualDelivery?.toIso8601String(),
      shippedAt: shipment.shippedAt?.toIso8601String(),
      createdAt: shipment.createdAt.toIso8601String(),
      updatedAt: shipment.updatedAt.toIso8601String(),
      createdBy: shipment.createdBy,
      updatedBy: shipment.updatedBy,
    );
  }

  Shipment toEntity() {
    return Shipment(
      id: id,
      orderId: orderId,
      orderNumber: orderNumber,
      customerId: customerId,
      customerName: customerName,
      status: ShipmentStatus.values.firstWhere((e) => e.name == status),
      method: ShippingMethod.values.firstWhere((e) => e.name == method),
      carrier: carrier.toEntity(),
      trackingNumber: trackingNumber,
      trackingUrl: trackingUrl,
      items: items.map((item) => item.toEntity()).toList(),
      shippingAddress: shippingAddress.toEntity(),
      weight: weight,
      dimensions: dimensions,
      shippingCost: shippingCost,
      currency: currency,
      trackingEvents: trackingEvents.map((event) => event.toEntity()).toList(),
      notes: notes,
      internalNotes: internalNotes,
      metadata: metadata,
      tags: tags,
      estimatedDelivery: estimatedDelivery != null
          ? DateTime.parse(estimatedDelivery!)
          : null,
      actualDelivery: actualDelivery != null
          ? DateTime.parse(actualDelivery!)
          : null,
      shippedAt: shippedAt != null ? DateTime.parse(shippedAt!) : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }
}
