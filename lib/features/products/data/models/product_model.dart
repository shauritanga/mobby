import '../../domain/entities/product.dart';

class ProductDimensionsModel extends ProductDimensions {
  const ProductDimensionsModel({
    super.length,
    super.width,
    super.height,
    super.weight,
    super.unit,
  });

  factory ProductDimensionsModel.fromMap(Map<String, dynamic> map) {
    return ProductDimensionsModel(
      length: map['length'] ?? 0.0,
      width: map['width'] ?? 0.0,
      height: map['height'] ?? 0.0,
      weight: map['weight'] ?? 0.0,
      unit: map['unit'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'length': length,
      'width': width,
      'height': height,
      'weight': weight,
      'unit': unit,
    };
  }

  ProductDimensions toEntity() {
    return ProductDimensions(
      length: length,
      width: width,
      height: height,
      weight: weight,
      unit: unit,
    );
  }

  factory ProductDimensionsModel.fromEntity(ProductDimensions dimensions) {
    return ProductDimensionsModel(
      length: dimensions.length,
      width: dimensions.width,
      height: dimensions.height,
      weight: dimensions.weight,
      unit: dimensions.unit,
    );
  }
}

class ProductModel extends Product {
  final ProductDimensions? dimensionsModel;

  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    super.shortDescription,
    required super.price,
    super.originalPrice,
    required super.currency,
    required super.imageUrl,
    required super.imageUrls,
    required super.categoryId,
    required super.categoryName,
    required super.brandId,
    required super.brandName,
    required super.sku,
    super.barcode,
    required super.stockQuantity,
    super.minStockLevel,
    required super.stockStatus,
    required super.condition,
    required super.rating,
    required super.reviewCount,
    required super.isFeatured,
    required super.isActive,
    required super.isDigital,
    required super.requiresShipping,
    required super.tags,
    required super.specifications,
    super.warranty,
    super.manufacturer,
    super.countryOfOrigin,
    required super.compatibleVehicles,
    required super.createdAt,
    required super.updatedAt,
    this.dimensionsModel,
  }) : super(dimensions: dimensionsModel);

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      shortDescription: map['shortDescription'] as String?,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      currency: map['currency'] as String? ?? 'USD',
      imageUrl: map['imageUrl'] as String? ?? '',
      imageUrls:
          (map['imageUrls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      categoryId: map['categoryId'] as String? ?? '',
      categoryName: map['categoryName'] as String? ?? '',
      brandId: map['brandId'] as String? ?? '',
      brandName: map['brandName'] as String? ?? '',
      sku: map['sku'] as String? ?? '',
      barcode: map['barcode'] ?? "",
      stockQuantity: (map['stockQuantity'] as num?)?.toInt() ?? 0,
      minStockLevel: (map['minStockLevel'] as num?)?.toInt(),
      stockStatus: _parseStockStatus(map['stockStatus'] ?? ""),
      condition: _parseProductCondition(map['condition'] ?? ""),
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      isFeatured: map['isFeatured'] as bool? ?? false,
      isActive: map['isActive'] as bool? ?? true,
      isDigital: map['isDigital'] as bool? ?? false,
      requiresShipping: map['requiresShipping'] as bool? ?? true,
      tags:
          (map['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
          [],
      specifications: map['specifications'] as Map<String, dynamic>? ?? {},
      warranty: map['warranty'] as String?,
      manufacturer: map['manufacturer'] as String?,
      countryOfOrigin: map['countryOfOrigin'] as String?,
      compatibleVehicles:
          (map['compatibleVehicles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      dimensionsModel: map['dimensionsModel'] != null
          ? ProductDimensionsModel.fromMap(
              map['dimensionsModel'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'shortDescription': shortDescription,
      'price': price,
      'originalPrice': originalPrice,
      'currency': currency,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'brandId': brandId,
      'brandName': brandName,
      'sku': sku,
      'barcode': barcode,
      'stockQuantity': stockQuantity,
      'minStockLevel': minStockLevel,
      'stockStatus': stockStatus.name,
      'condition': condition.name,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'isDigital': isDigital,
      'requiresShipping': requiresShipping,
      'tags': tags,
      'specifications': specifications,
      'warranty': warranty,
      'manufacturer': manufacturer,
      'countryOfOrigin': countryOfOrigin,
      'compatibleVehicles': compatibleVehicles,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'dimensionsModel': dimensionsModel != null
          ? ProductDimensionsModel.fromEntity(dimensionsModel!).toMap()
          : null,
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      shortDescription: product.shortDescription,
      price: product.price,
      originalPrice: product.originalPrice,
      currency: product.currency,
      imageUrl: product.imageUrl,
      imageUrls: product.imageUrls,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
      brandId: product.brandId,
      brandName: product.brandName,
      sku: product.sku,
      barcode: product.barcode,
      stockQuantity: product.stockQuantity,
      minStockLevel: product.minStockLevel,
      stockStatus: product.stockStatus,
      condition: product.condition,
      rating: product.rating,
      reviewCount: product.reviewCount,
      isFeatured: product.isFeatured,
      isActive: product.isActive,
      isDigital: product.isDigital,
      requiresShipping: product.requiresShipping,
      tags: product.tags,
      specifications: product.specifications,
      dimensionsModel: product.dimensions,
      warranty: product.warranty,
      manufacturer: product.manufacturer,
      countryOfOrigin: product.countryOfOrigin,
      compatibleVehicles: product.compatibleVehicles,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      shortDescription: shortDescription,
      price: price,
      originalPrice: originalPrice,
      currency: currency,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      categoryId: categoryId,
      categoryName: categoryName,
      brandId: brandId,
      brandName: brandName,
      sku: sku,
      barcode: barcode,
      stockQuantity: stockQuantity,
      minStockLevel: minStockLevel,
      stockStatus: stockStatus,
      condition: condition,
      rating: rating,
      reviewCount: reviewCount,
      isFeatured: isFeatured,
      isActive: isActive,
      isDigital: isDigital,
      requiresShipping: requiresShipping,
      tags: tags,
      specifications: specifications,
      dimensions: dimensions,
      warranty: warranty,
      manufacturer: manufacturer,
      countryOfOrigin: countryOfOrigin,
      compatibleVehicles: compatibleVehicles,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Helper methods for parsing
  static StockStatus _parseStockStatus(String? status) {
    switch (status) {
      case 'inStock':
        return StockStatus.inStock;
      case 'lowStock':
        return StockStatus.lowStock;
      case 'outOfStock':
        return StockStatus.outOfStock;
      default:
        return StockStatus.inStock;
    }
  }

  static ProductCondition _parseProductCondition(String? condition) {
    switch (condition) {
      case 'new':
        return ProductCondition.new_;
      case 'used':
        return ProductCondition.used;
      case 'refurbished':
        return ProductCondition.refurbished;
      default:
        return ProductCondition.new_;
    }
  }

  static DateTime _parseDateTime(dynamic dateTime) {
    if (dateTime == null) return DateTime.now();
    if (dateTime is String) {
      return DateTime.tryParse(dateTime) ?? DateTime.now();
    }
    if (dateTime is DateTime) return dateTime;
    return DateTime.now();
  }

  // Legacy methods for backward compatibility
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      ProductModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();
}
