import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/product.dart';

part 'product_model.g.dart';

// Helper functions for ProductDimensions serialization
ProductDimensions? _dimensionsFromJson(Map<String, dynamic>? json) {
  if (json == null) return null;
  return ProductDimensionsModel.fromJson(json).toEntity();
}

Map<String, dynamic>? _dimensionsToJson(ProductDimensions? dimensions) {
  if (dimensions == null) return null;
  return ProductDimensionsModel.fromEntity(dimensions).toJson();
}

@JsonSerializable()
class ProductDimensionsModel extends ProductDimensions {
  const ProductDimensionsModel({
    super.length,
    super.width,
    super.height,
    super.weight,
    super.unit,
  });

  factory ProductDimensionsModel.fromJson(Map<String, dynamic> json) =>
      _$ProductDimensionsModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductDimensionsModelToJson(this);

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

@JsonSerializable()
class ProductModel extends Product {
  @JsonKey(fromJson: _dimensionsFromJson, toJson: _dimensionsToJson)
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

  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      _$ProductModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProductModelToJson(this);

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
}
