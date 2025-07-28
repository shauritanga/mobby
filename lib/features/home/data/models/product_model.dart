import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.price,
    super.originalPrice,
    required super.imageUrl,
    required super.imageUrls,
    required super.categoryId,
    required super.categoryName,
    required super.brand,
    required super.sku,
    required super.stockQuantity,
    required super.rating,
    required super.reviewCount,
    required super.isFeatured,
    required super.isActive,
    required super.tags,
    required super.specifications,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? "",
      name: map['name'] ?? "",
      description: map['description'] ?? "",
      price: (map['price'] as num).toDouble(),
      originalPrice: (map['originalPrice'] as num?)?.toDouble(),
      imageUrl: map['imageUrl'] ?? "",
      imageUrls: List<String>.from(map['imageUrls'] as List),
      categoryId: map['categoryId'] ?? "",
      categoryName: map['categoryName'] ?? "",
      brand: map['brand'] ?? "",
      sku: map['sku'] ?? "",
      stockQuantity: map['stockQuantity'] as int,
      rating: (map['rating'] as num).toDouble(),
      reviewCount: map['reviewCount'] as int,
      isFeatured: map['isFeatured'] as bool,
      isActive: map['isActive'] as bool,
      tags: List<String>.from(map['tags'] as List),
      specifications: Map<String, String>.from(map['specifications'] as Map),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'price': price,
      'originalPrice': originalPrice,
      'imageUrl': imageUrl,
      'imageUrls': imageUrls,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'brand': brand,
      'sku': sku,
      'stockQuantity': stockQuantity,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'tags': tags,
      'specifications': specifications,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // For backward compatibility
  factory ProductModel.fromJson(Map<String, dynamic> json) =>
      ProductModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      price: product.price,
      originalPrice: product.originalPrice,
      imageUrl: product.imageUrl,
      imageUrls: product.imageUrls,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
      brand: product.brand,
      sku: product.sku,
      stockQuantity: product.stockQuantity,
      rating: product.rating,
      reviewCount: product.reviewCount,
      isFeatured: product.isFeatured,
      isActive: product.isActive,
      tags: product.tags,
      specifications: product.specifications,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
    );
  }

  Product toEntity() {
    return Product(
      id: id,
      name: name,
      description: description,
      price: price,
      originalPrice: originalPrice,
      imageUrl: imageUrl,
      imageUrls: imageUrls,
      categoryId: categoryId,
      categoryName: categoryName,
      brand: brand,
      sku: sku,
      stockQuantity: stockQuantity,
      rating: rating,
      reviewCount: reviewCount,
      isFeatured: isFeatured,
      isActive: isActive,
      tags: tags,
      specifications: specifications,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  ProductModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? originalPrice,
    String? imageUrl,
    List<String>? imageUrls,
    String? categoryId,
    String? categoryName,
    String? brand,
    String? sku,
    int? stockQuantity,
    double? rating,
    int? reviewCount,
    bool? isFeatured,
    bool? isActive,
    List<String>? tags,
    Map<String, dynamic>? specifications,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      originalPrice: originalPrice ?? this.originalPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      imageUrls: imageUrls ?? this.imageUrls,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      brand: brand ?? this.brand,
      sku: sku ?? this.sku,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      isFeatured: isFeatured ?? this.isFeatured,
      isActive: isActive ?? this.isActive,
      tags: tags ?? this.tags,
      specifications: specifications ?? this.specifications,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
