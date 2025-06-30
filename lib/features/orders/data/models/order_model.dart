import '../../domain/entities/order.dart';

class ShippingAddressModel extends ShippingAddress {
  const ShippingAddressModel({
    required super.fullName,
    required super.phoneNumber,
    required super.addressLine1,
    super.addressLine2,
    required super.city,
    required super.region,
    required super.postalCode,
    required super.country,
    super.isDefault = false,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      fullName: json['fullName'] as String,
      phoneNumber: json['phoneNumber'] as String,
      addressLine1: json['addressLine1'] as String,
      addressLine2: json['addressLine2'] as String?,
      city: json['city'] as String,
      region: json['region'] as String,
      postalCode: json['postalCode'] as String,
      country: json['country'] as String,
      isDefault: json['isDefault'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'addressLine1': addressLine1,
      'addressLine2': addressLine2,
      'city': city,
      'region': region,
      'postalCode': postalCode,
      'country': country,
      'isDefault': isDefault,
    };
  }

  factory ShippingAddressModel.fromEntity(ShippingAddress address) {
    return ShippingAddressModel(
      fullName: address.fullName,
      phoneNumber: address.phoneNumber,
      addressLine1: address.addressLine1,
      addressLine2: address.addressLine2,
      city: address.city,
      region: address.region,
      postalCode: address.postalCode,
      country: address.country,
      isDefault: address.isDefault,
    );
  }
}

class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.orderNumber,
    required super.status,
    required super.paymentStatus,
    required super.paymentMethod,
    required super.items,
    required super.subtotal,
    required super.shippingCost,
    required super.taxAmount,
    required super.discountAmount,
    required super.totalAmount,
    required super.currency,
    required super.shippingAddress,
    super.billingAddress,
    super.notes,
    super.couponCode,
    required super.orderDate,
    super.estimatedDeliveryDate,
    super.deliveredDate,
    super.cancelledDate,
    super.cancellationReason,
    required super.shipments,
    super.metadata,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      orderNumber: json['orderNumber'] as String,
      status: OrderStatus.values.byName(json['status'] as String),
      paymentStatus: PaymentStatus.values.byName(
        json['paymentStatus'] as String,
      ),
      paymentMethod: PaymentMethod.values.byName(
        json['paymentMethod'] as String,
      ),
      items: [], // Simplified for now
      subtotal: (json['subtotal'] as num).toDouble(),
      shippingCost: (json['shippingCost'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      shippingAddress: ShippingAddressModel.fromJson(
        json['shippingAddress'] as Map<String, dynamic>,
      ),
      orderDate: DateTime.parse(json['orderDate'] as String),
      shipments: [], // Simplified for now
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'orderNumber': orderNumber,
      'status': status.name,
      'paymentStatus': paymentStatus.name,
      'paymentMethod': paymentMethod.name,
      'subtotal': subtotal,
      'shippingCost': shippingCost,
      'taxAmount': taxAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'shippingAddress': ShippingAddressModel.fromEntity(
        shippingAddress,
      ).toJson(),
      'orderDate': orderDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      userId: order.userId,
      orderNumber: order.orderNumber,
      status: order.status,
      paymentStatus: order.paymentStatus,
      paymentMethod: order.paymentMethod,
      items: order.items,
      subtotal: order.subtotal,
      shippingCost: order.shippingCost,
      taxAmount: order.taxAmount,
      discountAmount: order.discountAmount,
      totalAmount: order.totalAmount,
      currency: order.currency,
      shippingAddress: order.shippingAddress,
      billingAddress: order.billingAddress,
      notes: order.notes,
      couponCode: order.couponCode,
      orderDate: order.orderDate,
      estimatedDeliveryDate: order.estimatedDeliveryDate,
      deliveredDate: order.deliveredDate,
      cancelledDate: order.cancelledDate,
      cancellationReason: order.cancellationReason,
      shipments: order.shipments,
      metadata: order.metadata,
      createdAt: order.createdAt,
      updatedAt: order.updatedAt,
    );
  }

  Order toEntity() => this;
}
