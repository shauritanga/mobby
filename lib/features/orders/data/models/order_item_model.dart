import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/order_item.dart';

part 'order_item_model.g.dart';

@JsonSerializable()
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

  factory OrderItemModel.fromJson(Map<String, dynamic> json) =>
      _$OrderItemModelFromJson(json);

  Map<String, dynamic> toJson() => _$OrderItemModelToJson(this);

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
