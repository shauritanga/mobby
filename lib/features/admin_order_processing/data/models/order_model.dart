import '../../domain/entities/order.dart';

class OrderItemModel {
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

  const OrderItemModel({
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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String,
      productImageUrl: json['productImageUrl'] as String?,
      variantId: json['variantId'] as String?,
      variantName: json['variantName'] as String?,
      quantity: json['quantity'] as int,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      discountAmount: json['discountAmount'] != null
          ? (json['discountAmount'] as num).toDouble()
          : null,
      productAttributes: Map<String, dynamic>.from(
        json['productAttributes'] as Map? ?? {},
      ),
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'productImageUrl': productImageUrl,
      'variantId': variantId,
      'variantName': variantName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'totalPrice': totalPrice,
      'discountAmount': discountAmount,
      'productAttributes': productAttributes,
      'notes': notes,
    };
  }

  factory OrderItemModel.fromEntity(OrderItem item) {
    return OrderItemModel(
      id: item.id,
      productId: item.productId,
      productName: item.productName,
      productSku: item.productSku,
      productImageUrl: item.productImageUrl,
      variantId: item.variantId,
      variantName: item.variantName,
      quantity: item.quantity,
      unitPrice: item.unitPrice,
      totalPrice: item.totalPrice,
      discountAmount: item.discountAmount,
      productAttributes: item.productAttributes,
      notes: item.notes,
    );
  }

  OrderItem toEntity() {
    return OrderItem(
      id: id,
      productId: productId,
      productName: productName,
      productSku: productSku,
      productImageUrl: productImageUrl,
      variantId: variantId,
      variantName: variantName,
      quantity: quantity,
      unitPrice: unitPrice,
      totalPrice: totalPrice,
      discountAmount: discountAmount,
      productAttributes: productAttributes,
      notes: notes,
    );
  }
}

class OrderAddressModel {
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

  const OrderAddressModel({
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

  factory OrderAddressModel.fromJson(Map<String, dynamic> json) {
    return OrderAddressModel(
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
    };
  }

  factory OrderAddressModel.fromEntity(OrderAddress address) {
    return OrderAddressModel(
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
    );
  }

  OrderAddress toEntity() {
    return OrderAddress(
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
    );
  }
}

class OrderPaymentModel {
  final String id;
  final String method;
  final String status;
  final double amount;
  final String currency;
  final String? transactionId;
  final String? gatewayResponse;
  final String? paidAt;
  final Map<String, dynamic> metadata;

  const OrderPaymentModel({
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

  factory OrderPaymentModel.fromJson(Map<String, dynamic> json) {
    return OrderPaymentModel(
      id: json['id'] as String,
      method: json['method'] as String,
      status: json['status'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      transactionId: json['transactionId'] as String?,
      gatewayResponse: json['gatewayResponse'] as String?,
      paidAt: json['paidAt'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'method': method,
      'status': status,
      'amount': amount,
      'currency': currency,
      'transactionId': transactionId,
      'gatewayResponse': gatewayResponse,
      'paidAt': paidAt,
      'metadata': metadata,
    };
  }

  factory OrderPaymentModel.fromEntity(OrderPayment payment) {
    return OrderPaymentModel(
      id: payment.id,
      method: payment.method,
      status: payment.status.name,
      amount: payment.amount,
      currency: payment.currency,
      transactionId: payment.transactionId,
      gatewayResponse: payment.gatewayResponse,
      paidAt: payment.paidAt?.toIso8601String(),
      metadata: payment.metadata,
    );
  }

  OrderPayment toEntity() {
    return OrderPayment(
      id: id,
      method: method,
      status: PaymentStatus.values.firstWhere((e) => e.name == status),
      amount: amount,
      currency: currency,
      transactionId: transactionId,
      gatewayResponse: gatewayResponse,
      paidAt: paidAt != null ? DateTime.parse(paidAt!) : null,
      metadata: metadata,
    );
  }
}

class OrderDiscountModel {
  final String id;
  final String code;
  final String type;
  final double value;
  final double appliedAmount;
  final String? description;

  const OrderDiscountModel({
    required this.id,
    required this.code,
    required this.type,
    required this.value,
    required this.appliedAmount,
    this.description,
  });

  factory OrderDiscountModel.fromJson(Map<String, dynamic> json) {
    return OrderDiscountModel(
      id: json['id'] as String,
      code: json['code'] as String,
      type: json['type'] as String,
      value: (json['value'] as num).toDouble(),
      appliedAmount: (json['appliedAmount'] as num).toDouble(),
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'type': type,
      'value': value,
      'appliedAmount': appliedAmount,
      'description': description,
    };
  }

  factory OrderDiscountModel.fromEntity(OrderDiscount discount) {
    return OrderDiscountModel(
      id: discount.id,
      code: discount.code,
      type: discount.type,
      value: discount.value,
      appliedAmount: discount.appliedAmount,
      description: discount.description,
    );
  }

  OrderDiscount toEntity() {
    return OrderDiscount(
      id: id,
      code: code,
      type: type,
      value: value,
      appliedAmount: appliedAmount,
      description: description,
    );
  }
}

class OrderModel {
  final String id;
  final String orderNumber;
  final String customerId;
  final String customerName;
  final String customerEmail;
  final String? customerPhone;
  final String status;
  final String priority;
  final List<OrderItemModel> items;
  final OrderAddressModel billingAddress;
  final OrderAddressModel shippingAddress;
  final OrderPaymentModel? payment;
  final List<OrderDiscountModel> discounts;
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
  final String? estimatedDelivery;
  final String createdAt;
  final String updatedAt;
  final String? updatedBy;

  const OrderModel({
    required this.id,
    required this.orderNumber,
    required this.customerId,
    required this.customerName,
    required this.customerEmail,
    this.customerPhone,
    required this.status,
    required this.priority,
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

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      orderNumber: json['orderNumber'] as String,
      customerId: json['customerId'] as String,
      customerName: json['customerName'] as String,
      customerEmail: json['customerEmail'] as String,
      customerPhone: json['customerPhone'] as String?,
      status: json['status'] as String,
      priority: json['priority'] as String,
      items: (json['items'] as List)
          .map((item) => OrderItemModel.fromJson(item))
          .toList(),
      billingAddress: OrderAddressModel.fromJson(
        json['billingAddress'] as Map<String, dynamic>,
      ),
      shippingAddress: OrderAddressModel.fromJson(
        json['shippingAddress'] as Map<String, dynamic>,
      ),
      payment: json['payment'] != null
          ? OrderPaymentModel.fromJson(json['payment'] as Map<String, dynamic>)
          : null,
      discounts: (json['discounts'] as List? ?? [])
          .map((discount) => OrderDiscountModel.fromJson(discount))
          .toList(),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxAmount: (json['taxAmount'] as num).toDouble(),
      shippingAmount: (json['shippingAmount'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num).toDouble(),
      totalAmount: (json['totalAmount'] as num).toDouble(),
      currency: json['currency'] as String,
      notes: json['notes'] as String?,
      adminNotes: json['adminNotes'] as String?,
      metadata: Map<String, dynamic>.from(json['metadata'] as Map? ?? {}),
      tags: List<String>.from(json['tags'] as List? ?? []),
      assignedTo: json['assignedTo'] as String?,
      assignedToName: json['assignedToName'] as String?,
      estimatedDelivery: json['estimatedDelivery'] as String?,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderNumber': orderNumber,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
      'customerPhone': customerPhone,
      'status': status,
      'priority': priority,
      'items': items.map((item) => item.toJson()).toList(),
      'billingAddress': billingAddress.toJson(),
      'shippingAddress': shippingAddress.toJson(),
      'payment': payment?.toJson(),
      'discounts': discounts.map((discount) => discount.toJson()).toList(),
      'subtotal': subtotal,
      'taxAmount': taxAmount,
      'shippingAmount': shippingAmount,
      'discountAmount': discountAmount,
      'totalAmount': totalAmount,
      'currency': currency,
      'notes': notes,
      'adminNotes': adminNotes,
      'metadata': metadata,
      'tags': tags,
      'assignedTo': assignedTo,
      'assignedToName': assignedToName,
      'estimatedDelivery': estimatedDelivery,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'updatedBy': updatedBy,
    };
  }

  factory OrderModel.fromEntity(Order order) {
    return OrderModel(
      id: order.id,
      orderNumber: order.orderNumber,
      customerId: order.customerId,
      customerName: order.customerName,
      customerEmail: order.customerEmail,
      customerPhone: order.customerPhone,
      status: order.status.name,
      priority: order.priority.name,
      items: order.items
          .map((item) => OrderItemModel.fromEntity(item))
          .toList(),
      billingAddress: OrderAddressModel.fromEntity(order.billingAddress),
      shippingAddress: OrderAddressModel.fromEntity(order.shippingAddress),
      payment: order.payment != null
          ? OrderPaymentModel.fromEntity(order.payment!)
          : null,
      discounts: order.discounts
          .map((discount) => OrderDiscountModel.fromEntity(discount))
          .toList(),
      subtotal: order.subtotal,
      taxAmount: order.taxAmount,
      shippingAmount: order.shippingAmount,
      discountAmount: order.discountAmount,
      totalAmount: order.totalAmount,
      currency: order.currency,
      notes: order.notes,
      adminNotes: order.adminNotes,
      metadata: order.metadata,
      tags: order.tags,
      assignedTo: order.assignedTo,
      assignedToName: order.assignedToName,
      estimatedDelivery: order.estimatedDelivery?.toIso8601String(),
      createdAt: order.createdAt.toIso8601String(),
      updatedAt: order.updatedAt.toIso8601String(),
      updatedBy: order.updatedBy,
    );
  }

  Order toEntity() {
    return Order(
      id: id,
      orderNumber: orderNumber,
      customerId: customerId,
      customerName: customerName,
      customerEmail: customerEmail,
      customerPhone: customerPhone,
      status: OrderStatus.values.firstWhere((e) => e.name == status),
      priority: OrderPriority.values.firstWhere((e) => e.name == priority),
      items: items.map((item) => item.toEntity()).toList(),
      billingAddress: billingAddress.toEntity(),
      shippingAddress: shippingAddress.toEntity(),
      payment: payment?.toEntity(),
      discounts: discounts.map((discount) => discount.toEntity()).toList(),
      subtotal: subtotal,
      taxAmount: taxAmount,
      shippingAmount: shippingAmount,
      discountAmount: discountAmount,
      totalAmount: totalAmount,
      currency: currency,
      notes: notes,
      adminNotes: adminNotes,
      metadata: metadata,
      tags: tags,
      assignedTo: assignedTo,
      assignedToName: assignedToName,
      estimatedDelivery: estimatedDelivery != null
          ? DateTime.parse(estimatedDelivery!)
          : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      updatedBy: updatedBy,
    );
  }
}
