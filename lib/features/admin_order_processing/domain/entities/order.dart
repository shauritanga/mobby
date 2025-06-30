enum OrderStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  refunded,
  returned;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.processing:
        return 'Processing';
      case OrderStatus.shipped:
        return 'Shipped';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
      case OrderStatus.refunded:
        return 'Refunded';
      case OrderStatus.returned:
        return 'Returned';
    }
  }

  bool get canCancel {
    return this == OrderStatus.pending || this == OrderStatus.confirmed;
  }

  bool get canProcess {
    return this == OrderStatus.confirmed;
  }

  bool get canShip {
    return this == OrderStatus.processing;
  }

  bool get canRefund {
    return this == OrderStatus.delivered || this == OrderStatus.cancelled;
  }
}

enum PaymentStatus {
  pending,
  paid,
  failed,
  refunded,
  partiallyRefunded;

  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
      case PaymentStatus.partiallyRefunded:
        return 'Partially Refunded';
    }
  }
}

enum OrderPriority {
  low,
  normal,
  high,
  urgent;

  String get displayName {
    switch (this) {
      case OrderPriority.low:
        return 'Low';
      case OrderPriority.normal:
        return 'Normal';
      case OrderPriority.high:
        return 'High';
      case OrderPriority.urgent:
        return 'Urgent';
    }
  }
}

class OrderItem {
  final String id;
  final String productId;
  final String productName;
  final String productSku;
  final String? productImageUrl;
  final String? variantId;
  final String? variantName;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double? discountAmount;
  final Map<String, dynamic> productAttributes;
  final String? notes;

  const OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.productSku,
    this.productImageUrl,
    this.variantId,
    this.variantName,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.discountAmount,
    this.productAttributes = const {},
    this.notes,
  });

  OrderItem copyWith({
    String? id,
    String? productId,
    String? productName,
    String? productSku,
    String? productImageUrl,
    String? variantId,
    String? variantName,
    int? quantity,
    double? unitPrice,
    double? totalPrice,
    double? discountAmount,
    Map<String, dynamic>? productAttributes,
    String? notes,
  }) {
    return OrderItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      productName: productName ?? this.productName,
      productSku: productSku ?? this.productSku,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      variantId: variantId ?? this.variantId,
      variantName: variantName ?? this.variantName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      totalPrice: totalPrice ?? this.totalPrice,
      discountAmount: discountAmount ?? this.discountAmount,
      productAttributes: productAttributes ?? this.productAttributes,
      notes: notes ?? this.notes,
    );
  }
}

class OrderAddress {
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

  const OrderAddress({
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

  OrderAddress copyWith({
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
  }) {
    return OrderAddress(
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
    );
  }
}

class OrderPayment {
  final String id;
  final String method;
  final PaymentStatus status;
  final double amount;
  final String currency;
  final String? transactionId;
  final String? gatewayResponse;
  final DateTime? paidAt;
  final Map<String, dynamic> metadata;

  const OrderPayment({
    required this.id,
    required this.method,
    required this.status,
    required this.amount,
    required this.currency,
    this.transactionId,
    this.gatewayResponse,
    this.paidAt,
    this.metadata = const {},
  });

  OrderPayment copyWith({
    String? id,
    String? method,
    PaymentStatus? status,
    double? amount,
    String? currency,
    String? transactionId,
    String? gatewayResponse,
    DateTime? paidAt,
    Map<String, dynamic>? metadata,
  }) {
    return OrderPayment(
      id: id ?? this.id,
      method: method ?? this.method,
      status: status ?? this.status,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      transactionId: transactionId ?? this.transactionId,
      gatewayResponse: gatewayResponse ?? this.gatewayResponse,
      paidAt: paidAt ?? this.paidAt,
      metadata: metadata ?? this.metadata,
    );
  }
}

class OrderDiscount {
  final String id;
  final String code;
  final String type; // percentage, fixed_amount
  final double value;
  final double appliedAmount;
  final String? description;

  const OrderDiscount({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.appliedAmount,
    this.description,
  });

  OrderDiscount copyWith({
    String? id,
    String? code,
    String? type,
    double? value,
    double? appliedAmount,
    String? description,
  }) {
    return OrderDiscount(
      id: id ?? this.id,
      code: code ?? this.code,
      type: type ?? this.type,
      value: value ?? this.value,
      appliedAmount: appliedAmount ?? this.appliedAmount,
      description: description ?? this.description,
    );
  }
}

class Order {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final OrderStatus status;
  final OrderPriority priority;
  final List<OrderItem> items;
  final OrderAddress billingAddress;
  final OrderAddress shippingAddress;
  final OrderPayment? payment;
  final List<OrderDiscount> discounts;
  final double subtotal;
  final double taxAmount;
  final double shippingAmount;
  final double discountAmount;
  final double totalAmount;
  final String currency;
  final String? notes;
  final String? adminNotes;
  final Map<String, dynamic> metadata;
  final List<String> tags;
  final String? assignedTo;
  final String? assignedToName;
  final DateTime? estimatedDelivery;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? updatedBy;

  const Order({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.status,
    this.priority = OrderPriority.normal,
    required this.items,
    required this.billingAddress,
    required this.shippingAddress,
    this.payment,
    this.discounts = const [],
    required this.subtotal,
    required this.taxAmount,
    required this.shippingAmount,
    required this.discountAmount,
    required this.totalAmount,
    required this.currency,
    this.notes,
    this.adminNotes,
    this.metadata = const {},
    this.tags = const [],
    this.assignedTo,
    this.assignedToName,
    this.estimatedDelivery,
    required this.createdAt,
    required this.updatedAt,
    this.updatedBy,
  });

  int get itemCount => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isPaid => payment?.status == PaymentStatus.paid;

  bool get hasShippingAddress => 
      shippingAddress.street.isNotEmpty && 
      shippingAddress.city.isNotEmpty;

  bool get isHighPriority => 
      priority == OrderPriority.high || priority == OrderPriority.urgent;

  String get statusDisplayName => status.displayName;

  String get priorityDisplayName => priority.displayName;

  Order copyWith({
    String? id,
    String? orderNumber,
    String? customerId,
    String? customerName,
    String? customerEmail,
    String? customerPhone,
    OrderStatus? status,
    OrderPriority? priority,
    List<OrderItem>? items,
    OrderAddress? billingAddress,
    OrderAddress? shippingAddress,
    OrderPayment? payment,
    List<OrderDiscount>? discounts,
    double? subtotal,
    double? taxAmount,
    double? shippingAmount,
    double? discountAmount,
    double? totalAmount,
    String? currency,
    String? notes,
    String? adminNotes,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? assignedTo,
    String? assignedToName,
    DateTime? estimatedDelivery,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? updatedBy,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      customerPhone: customerPhone ?? this.customerPhone,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      items: items ?? this.items,
      billingAddress: billingAddress ?? this.billingAddress,
      shippingAddress: shippingAddress ?? this.shippingAddress,
      payment: payment ?? this.payment,
      discounts: discounts ?? this.discounts,
      subtotal: subtotal ?? this.subtotal,
      taxAmount: taxAmount ?? this.taxAmount,
      shippingAmount: shippingAmount ?? this.shippingAmount,
      discountAmount: discountAmount ?? this.discountAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
      notes: notes ?? this.notes,
      adminNotes: adminNotes ?? this.adminNotes,
      metadata: metadata ?? this.metadata,
      tags: tags ?? this.tags,
      assignedTo: assignedTo ?? this.assignedTo,
      assignedToName: assignedToName ?? this.assignedToName,
      estimatedDelivery: estimatedDelivery ?? this.estimatedDelivery,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }
}
