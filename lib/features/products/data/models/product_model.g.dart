// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'product_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProductDimensionsModel _$ProductDimensionsModelFromJson(
        Map<String, dynamic> json) =>
    ProductDimensionsModel(
      length: (json['length'] as num?)?.toDouble(),
      width: (json['width'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      weight: (json['weight'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
    );

Map<String, dynamic> _$ProductDimensionsModelToJson(
        ProductDimensionsModel instance) =>
    <String, dynamic>{
      'length': instance.length,
      'width': instance.width,
      'height': instance.height,
      'weight': instance.weight,
      'unit': instance.unit,
    };

ProductModel _$ProductModelFromJson(Map<String, dynamic> json) => ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      shortDescription: json['shortDescription'] as String?,
      price: (json['price'] as num).toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      currency: json['currency'] as String,
      imageUrl: json['imageUrl'] as String,
      imageUrls:
          (json['imageUrls'] as List<dynamic>).map((e) => e as String).toList(),
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      brandId: json['brandId'] as String,
      brandName: json['brandName'] as String,
      sku: json['sku'] as String,
      barcode: json['barcode'] as String?,
      stockQuantity: (json['stockQuantity'] as num).toInt(),
      minStockLevel: (json['minStockLevel'] as num?)?.toInt(),
      stockStatus: $enumDecode(_$StockStatusEnumMap, json['stockStatus']),
      condition: $enumDecode(_$ProductConditionEnumMap, json['condition']),
      rating: (json['rating'] as num).toDouble(),
      reviewCount: (json['reviewCount'] as num).toInt(),
      isFeatured: json['isFeatured'] as bool,
      isActive: json['isActive'] as bool,
      isDigital: json['isDigital'] as bool,
      requiresShipping: json['requiresShipping'] as bool,
      tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
      specifications: json['specifications'] as Map<String, dynamic>,
      warranty: json['warranty'] as String?,
      manufacturer: json['manufacturer'] as String?,
      countryOfOrigin: json['countryOfOrigin'] as String?,
      compatibleVehicles: (json['compatibleVehicles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      dimensionsModel:
          _dimensionsFromJson(json['dimensionsModel'] as Map<String, dynamic>?),
    );

Map<String, dynamic> _$ProductModelToJson(ProductModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'shortDescription': instance.shortDescription,
      'price': instance.price,
      'originalPrice': instance.originalPrice,
      'currency': instance.currency,
      'imageUrl': instance.imageUrl,
      'imageUrls': instance.imageUrls,
      'categoryId': instance.categoryId,
      'categoryName': instance.categoryName,
      'brandId': instance.brandId,
      'brandName': instance.brandName,
      'sku': instance.sku,
      'barcode': instance.barcode,
      'stockQuantity': instance.stockQuantity,
      'minStockLevel': instance.minStockLevel,
      'stockStatus': _$StockStatusEnumMap[instance.stockStatus]!,
      'condition': _$ProductConditionEnumMap[instance.condition]!,
      'rating': instance.rating,
      'reviewCount': instance.reviewCount,
      'isFeatured': instance.isFeatured,
      'isActive': instance.isActive,
      'isDigital': instance.isDigital,
      'requiresShipping': instance.requiresShipping,
      'tags': instance.tags,
      'specifications': instance.specifications,
      'warranty': instance.warranty,
      'manufacturer': instance.manufacturer,
      'countryOfOrigin': instance.countryOfOrigin,
      'compatibleVehicles': instance.compatibleVehicles,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
      'dimensionsModel': _dimensionsToJson(instance.dimensionsModel),
    };

const _$StockStatusEnumMap = {
  StockStatus.inStock: 'inStock',
  StockStatus.lowStock: 'lowStock',
  StockStatus.outOfStock: 'outOfStock',
  StockStatus.preOrder: 'preOrder',
  StockStatus.discontinued: 'discontinued',
};

const _$ProductConditionEnumMap = {
  ProductCondition.new_: 'new_',
  ProductCondition.used: 'used',
  ProductCondition.refurbished: 'refurbished',
  ProductCondition.damaged: 'damaged',
};
