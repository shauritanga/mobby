import 'package:equatable/equatable.dart';

enum ProductCondition { new_, used, refurbished, damaged }

enum StockStatus { inStock, lowStock, outOfStock, preOrder, discontinued }

class ProductDimensions extends Equatable {
  final double? length;
  final double? width;
  final double? height;
  final double? weight;
  final String? unit;

  const ProductDimensions({
    this.length,
    this.width,
    this.height,
    this.weight,
    this.unit,
  });

  @override
  List<Object?> get props => [length, width, height, weight, unit];
}

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? shortDescription;
  final double price;
  final double? originalPrice;
  final String currency;
  final String imageUrl;
  final List<String> imageUrls;
  final String categoryId;
  final String categoryName;
  final String brandId;
  final String brandName;
  final String sku;
  final String? barcode;
  final int stockQuantity;
  final int? minStockLevel;
  final StockStatus stockStatus;
  final ProductCondition condition;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isActive;
  final bool isDigital;
  final bool requiresShipping;
  final List<String> tags;
  final Map<String, dynamic> specifications;
  final ProductDimensions? dimensions;
  final String? warranty;
  final String? manufacturer;
  final String? countryOfOrigin;
  final List<String> compatibleVehicles;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    this.shortDescription,
    required this.price,
    this.originalPrice,
    required this.currency,
    required this.imageUrl,
    required this.imageUrls,
    required this.categoryId,
    required this.categoryName,
    required this.brandId,
    required this.brandName,
    required this.sku,
    this.barcode,
    required this.stockQuantity,
    this.minStockLevel,
    required this.stockStatus,
    required this.condition,
    required this.rating,
    required this.reviewCount,
    required this.isFeatured,
    required this.isActive,
    required this.isDigital,
    required this.requiresShipping,
    required this.tags,
    required this.specifications,
    this.dimensions,
    this.warranty,
    this.manufacturer,
    this.countryOfOrigin,
    required this.compatibleVehicles,
    required this.createdAt,
    required this.updatedAt,
  });

  // Computed properties
  bool get isOnSale => originalPrice != null && originalPrice! > price;

  double get discountPercentage {
    if (!isOnSale) return 0.0;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  bool get isInStock => stockStatus == StockStatus.inStock;
  bool get isLowStock => stockStatus == StockStatus.lowStock;
  bool get isOutOfStock => stockStatus == StockStatus.outOfStock;
  bool get isAvailable => isInStock || isLowStock;

  bool get isNew => condition == ProductCondition.new_;
  bool get isUsed => condition == ProductCondition.used;

  bool get hasReviews => reviewCount > 0;
  bool get isHighlyRated => rating >= 4.0;
  bool get isPopular => reviewCount >= 50 && rating >= 4.0;

  bool get hasWarranty => warranty != null && warranty!.isNotEmpty;
  bool get hasMultipleImages => imageUrls.length > 1;

  String get stockStatusText {
    switch (stockStatus) {
      case StockStatus.inStock:
        return 'In Stock';
      case StockStatus.lowStock:
        return 'Low Stock';
      case StockStatus.outOfStock:
        return 'Out of Stock';
      case StockStatus.preOrder:
        return 'Pre-Order';
      case StockStatus.discontinued:
        return 'Discontinued';
    }
  }

  String get conditionText {
    switch (condition) {
      case ProductCondition.new_:
        return 'New';
      case ProductCondition.used:
        return 'Used';
      case ProductCondition.refurbished:
        return 'Refurbished';
      case ProductCondition.damaged:
        return 'Damaged';
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    shortDescription,
    price,
    originalPrice,
    currency,
    imageUrl,
    imageUrls,
    categoryId,
    categoryName,
    brandId,
    brandName,
    sku,
    barcode,
    stockQuantity,
    minStockLevel,
    stockStatus,
    condition,
    rating,
    reviewCount,
    isFeatured,
    isActive,
    isDigital,
    requiresShipping,
    tags,
    specifications,
    dimensions,
    warranty,
    manufacturer,
    countryOfOrigin,
    compatibleVehicles,
    createdAt,
    updatedAt,
  ];

  Product copyWith({
    String? id,
    String? name,
    String? description,
    String? shortDescription,
    double? price,
    double? originalPrice,
    String? currency,
    String? imageUrl,
    List<String>? imageUrls,
    String? categoryId,
    String? categoryName,
    String? brandId,
    String? brandName,
    String? sku,
    String? barcode,
    int? stockQuantity,
    int? minStockLevel,
    StockStatus? stockStatus,
    ProductCondition? condition,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isActive,
    bool? isDigital,
    bool? requiresShipping,
    List<String>? tags,
    Map<String, dynamic>? specifications,
    ProductDimensions? dimensions,
    String? warranty,
    String? manufacturer,
    String? countryOfOrigin,
    List<String>? compatibleVehicles,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      currency: currency ?? this.currency,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      sku: sku ?? this.sku,
      barcode: barcode ?? this.barcode,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      stockStatus: stockStatus ?? this.stockStatus,
      condition: condition ?? this.condition,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      isDigital: isDigital ?? this.isDigital,
      requiresShipping: requiresShipping ?? this.requiresShipping,
      tags: tags ?? this.tags,
      specifications: specifications ?? this.specifications,
      dimensions: dimensions ?? this.dimensions,
      warranty: warranty ?? this.warranty,
      manufacturer: manufacturer ?? this.manufacturer,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      compatibleVehicles: compatibleVehicles ?? this.compatibleVehicles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
