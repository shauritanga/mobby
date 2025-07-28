import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/cart_item.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/domain/entities/product.dart';

class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.product,
    required super.quantity,
    required super.addedAt,
    super.updatedAt,
  });

  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      product: ProductModel.fromJson(json['product'] as Map<String, dynamic>),
      quantity: json['quantity'] as int,
      addedAt: _parseTimestamp(json['addedAt']),
      updatedAt: json['updatedAt'] != null
          ? _parseTimestamp(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product': (product as ProductModel).toJson(),
      'quantity': quantity,
      'addedAt': addedAt,
      'updatedAt': updatedAt,
    };
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    } else if (timestamp is String) {
      return DateTime.parse(timestamp);
    } else if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    return DateTime.now();
  }

  @override
  CartItem copyWith({
    String? id,
    Product? product,
    int? quantity,
    DateTime? addedAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      product: (product ?? this.product) as ProductModel,
      quantity: quantity ?? this.quantity,
      addedAt: addedAt ?? this.addedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
