// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      imageUrl: json['imageUrl'] as String,
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      brand: json['brand'] as String,
      sku: json['sku'] as String,
      stockQuantity: (json['stockQuantity'] as num).toInt(),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      isFeatured: json['isFeatured'] as bool,
      isActive: json['isActive'] as bool,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      specifications: json['specifications'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'price': instance.price,
      'originalPrice': instance.originalPrice,
      'imageUrl': instance.imageUrl,
      'imageUrls': instance.imageUrls,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'brand': instance.brand,
      'sku': instance.sku,
      'stockQuantity': instance.stockQuantity,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'isFeatured': instance.isFeatured,
      'isActive': instance.isActive,
      'tags': instance.tags,
      'specifications': instance.specifications,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
