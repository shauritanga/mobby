import '../../domain/entities/order_item.dart';

class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    required super.productId,
    required super.productName,
    required super.productSku,
    required super.productImageUrl,
    super.productVariant,
    required super.unitPrice,
    required super.quantity,
    required super.totalPrice,
    super.discountAmount = 0.0,
    required super.currency,
    required super.status,
    super.notes,
    super.productMetadata,
    required super.createdAt,
    required super.updatedAt,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as String,
      orderId: map['orderId'] as String,
      productId: map['productId'] as String,
      productName: map['productName'] as String,
      productSku: map['productSku'] as String,
      productImageUrl: map['productImageUrl'] as String,
      productVariant: map['productVariant'] as String?,
      unitPrice: (map['unitPrice'] as num).toDouble(),
      quantity: map['quantity'] as int,
      totalPrice: (map['totalPrice'] as num).toDouble(),
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      currency: map['currency'] as String,
      status: OrderItemStatus.values.firstWhere(
        (e) => e.name == map['status'] as String,
        orElse: () => OrderItemStatus.pending,
      ),
      notes: map['notes'] as String?,
      productMetadata: map['productMetadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'productSku': productSku,
      'productImageUrl': productImageUrl,
      'productVariant': productVariant,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'discountAmount': discountAmount,
      'currency': currency,
      'status': status.name,
      'notes': notes,
      'productMetadata': productMetadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // For backward compatibility
  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      OrderItemModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  factory OrderItemModel.fromEntity(OrderItem orderItem) {
    return OrderItemModel(
      id: orderItem.id,
      orderId: orderItem.orderId,
      productId: orderItem.productId,
      productName: orderItem.productName,
      productSku: orderItem.productSku,
      productImageUrl: orderItem.productImageUrl,
      productVariant: orderItem.productVariant,
      unitPrice: orderItem.unitPrice,
      quantity: orderItem.quantity,
      totalPrice: orderItem.totalPrice,
      discountAmount: orderItem.discountAmount,
      currency: orderItem.currency,
      status: orderItem.status,
      notes: orderItem.notes,
      productMetadata: orderItem.productMetadata,
      createdAt: orderItem.createdAt,
      updatedAt: orderItem.updatedAt,
    );
  }

  OrderItem toEntity() => this;
}
