import 'package:equatable/equatable.dart';

enum OrderItemStatus {
  pending,
  confirmed,
  processing,
  shipped,
  delivered,
  cancelled,
  returned,
  refunded
}

class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String productId;
  final String productName;
  final String productSku;
  final String productImageUrl;
  final String? productVariant;
  final double unitPrice;
  final int quantity;
  final double totalPrice;
  final double discountAmount;
  final String currency;
  final OrderItemStatus status;
  final String? notes;
  final Map<String, dynamic>? productMetadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.productSku,
    required this.productImageUrl,
    this.productVariant,
    required this.unitPrice,
    required this.quantity,
    required this.totalPrice,
    this.discountAmount = 0.0,
    required this.currency,
    required this.status,
    this.notes,
    this.productMetadata,
    required this.createdAt,
    required this.updatedAt,
  });

  double get finalPrice => totalPrice - discountAmount;
  
  bool get canBeReturned => status == OrderItemStatus.delivered;
  
  bool get canBeCancelled => status == OrderItemStatus.pending || 
                            status == OrderItemStatus.confirmed;

  @override
  List<Object?> get props => [
        id,
        orderId,
        productId,
        productName,
        productSku,
        productImageUrl,
        productVariant,
        unitPrice,
        quantity,
        totalPrice,
        discountAmount,
        currency,
        status,
        notes,
        productMetadata,
        createdAt,
        updatedAt,
      ];
}
