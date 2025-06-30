// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_item_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

OrderItemModel _$OrderItemModelFromJson(Map<String, dynamic> json) =>
    OrderItemModel(
      id: json['id'] as String,
      orderId: json['orderId'] as String,
      productId: json['productId'] as String,
      productName: json['productName'] as String,
      productSku: json['productSku'] as String,
      productImageUrl: json['productImageUrl'] as String,
      productVariant: json['productVariant'] as String?,
      unitPrice: (json['unitPrice'] as num).toDouble(),
      quantity: (json['quantity'] as num).toInt(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String,
      status: $enumDecode(_$OrderItemStatusEnumMap, json['status']),
      notes: json['notes'] as String?,
      productMetadata: json['productMetadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$OrderItemModelToJson(OrderItemModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'orderId': instance.orderId,
      'productId': instance.productId,
      'productName': instance.productName,
      'productSku': instance.productSku,
      'productImageUrl': instance.productImageUrl,
      'productVariant': instance.productVariant,
      'unitPrice': instance.unitPrice,
      'quantity': instance.quantity,
      'totalPrice': instance.totalPrice,
      'discountAmount': instance.discountAmount,
      'currency': instance.currency,
      'status': _$OrderItemStatusEnumMap[instance.status]!,
      'notes': instance.notes,
      'productMetadata': instance.productMetadata,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$OrderItemStatusEnumMap = {
  OrderItemStatus.pending: 'pending',
  OrderItemStatus.confirmed: 'confirmed',
  OrderItemStatus.processing: 'processing',
  OrderItemStatus.shipped: 'shipped',
  OrderItemStatus.delivered: 'delivered',
  OrderItemStatus.cancelled: 'cancelled',
  OrderItemStatus.returned: 'returned',
  OrderItemStatus.refunded: 'refunded',
};
