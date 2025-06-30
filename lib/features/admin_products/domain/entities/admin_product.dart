import 'package:equatable/equatable.dart';

enum ProductStatus {
  draft,
  active,
  inactive,
  outOfStock,
  discontinued
}

enum ProductType {
  physical,
  digital,
  service,
  subscription
}

class ProductVariant extends Equatable {
  final String id;
  final String name;
  final String sku;
  final double price;
  final double? compareAtPrice;
  final int stockQuantity;
  final Map<String, String> attributes; // e.g., {"color": "red", "size": "M"}
  final List<String> imageUrls;
  final bool isActive;

  const ProductVariant({
    required this.id,
    required this.name,
    required this.sku,
    required this.price,
    this.compareAtPrice,
    required this.stockQuantity,
    required this.attributes,
    required this.imageUrls,
    this.isActive = true,
  });

  bool get isOnSale => compareAtPrice != null && compareAtPrice! > price;
  double get discountPercentage => isOnSale ? ((compareAtPrice! - price) / compareAtPrice!) * 100 : 0.0;
  bool get isInStock => stockQuantity > 0;

  @override
  List<Object?> get props => [
        id,
        name,
        sku,
        price,
        compareAtPrice,
        stockQuantity,
        attributes,
        imageUrls,
        isActive,
      ];
}

class ProductSEO extends Equatable {
  final String? metaTitle;
  final String? metaDescription;
  final List<String> keywords;
  final String? slug;

  const ProductSEO({
    this.metaTitle,
    this.metaDescription,
    this.keywords = const [],
    this.slug,
  });

  @override
  List<Object?> get props => [metaTitle, metaDescription, keywords, slug];
}

class ProductShipping extends Equatable {
  final double weight;
  final double? length;
  final double? width;
  final double? height;
  final bool requiresShipping;
  final bool isFreeShipping;
  final double? shippingCost;

  const ProductShipping({
    required this.weight,
    this.length,
    this.width,
    this.height,
    this.requiresShipping = true,
    this.isFreeShipping = false,
    this.shippingCost,
  });

  @override
  List<Object?> get props => [
        weight,
        length,
        width,
        height,
        requiresShipping,
        isFreeShipping,
        shippingCost,
      ];
}

class AdminProduct extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? shortDescription;
  final String sku;
  final String categoryId;
  final String categoryName;
  final String? brandId;
  final String? brandName;
  final String? supplierId;
  final String? supplierName;
  final ProductType type;
  final ProductStatus status;
  final double price;
  final double? compareAtPrice;
  final double costPrice;
  final String currency;
  final int stockQuantity;
  final int? lowStockThreshold;
  final bool trackQuantity;
  final List<String> imageUrls;
  final List<ProductVariant> variants;
  final List<String> tags;
  final ProductSEO seo;
  final ProductShipping shipping;
  final Map<String, dynamic> customFields;
  final bool isFeatured;
  final bool isDigital;
  final int salesCount;
  final double averageRating;
  final int reviewCount;
  final DateTime? publishedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const AdminProduct({
    required this.id,
    required this.name,
    required this.description,
    this.shortDescription,
    required this.sku,
    required this.categoryId,
    required this.categoryName,
    this.brandId,
    this.brandName,
    this.supplierId,
    this.supplierName,
    required this.type,
    required this.status,
    required this.price,
    this.compareAtPrice,
    required this.costPrice,
    required this.currency,
    required this.stockQuantity,
    this.lowStockThreshold,
    this.trackQuantity = true,
    required this.imageUrls,
    required this.variants,
    required this.tags,
    required this.seo,
    required this.shipping,
    required this.customFields,
    this.isFeatured = false,
    this.isDigital = false,
    this.salesCount = 0,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.publishedAt,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  bool get isActive => status == ProductStatus.active;
  bool get isInStock => stockQuantity > 0;
  bool get isLowStock => lowStockThreshold != null && stockQuantity <= lowStockThreshold!;
  bool get isOnSale => compareAtPrice != null && compareAtPrice! > price;
  bool get isPublished => publishedAt != null;
  bool get hasVariants => variants.isNotEmpty;
  
  double get discountPercentage => isOnSale ? ((compareAtPrice! - price) / compareAtPrice!) * 100 : 0.0;
  double get profitMargin => price > 0 ? ((price - costPrice) / price) * 100 : 0.0;
  
  String get statusDisplayName {
    switch (status) {
      case ProductStatus.draft:
        return 'Draft';
      case ProductStatus.active:
        return 'Active';
      case ProductStatus.inactive:
        return 'Inactive';
      case ProductStatus.outOfStock:
        return 'Out of Stock';
      case ProductStatus.discontinued:
        return 'Discontinued';
    }
  }

  String get typeDisplayName {
    switch (type) {
      case ProductType.physical:
        return 'Physical';
      case ProductType.digital:
        return 'Digital';
      case ProductType.service:
        return 'Service';
      case ProductType.subscription:
        return 'Subscription';
    }
  }

  AdminProduct copyWith({
    String? id,
    String? name,
    String? description,
    String? shortDescription,
    String? sku,
    String? categoryId,
    String? categoryName,
    String? brandId,
    String? brandName,
    String? supplierId,
    String? supplierName,
    ProductType? type,
    ProductStatus? status,
    double? price,
    double? compareAtPrice,
    double? costPrice,
    String? currency,
    int? stockQuantity,
    int? lowStockThreshold,
    bool? trackQuantity,
    List<String>? imageUrls,
    List<ProductVariant>? variants,
    List<String>? tags,
    ProductSEO? seo,
    ProductShipping? shipping,
    Map<String, dynamic>? customFields,
    bool? isFeatured,
    bool? isDigital,
    int? salesCount,
    double? averageRating,
    int? reviewCount,
    DateTime? publishedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return AdminProduct(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      sku: sku ?? this.sku,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      brandId: brandId ?? this.brandId,
      brandName: brandName ?? this.brandName,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      type: type ?? this.type,
      status: status ?? this.status,
      price: price ?? this.price,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      costPrice: costPrice ?? this.costPrice,
      currency: currency ?? this.currency,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      trackQuantity: trackQuantity ?? this.trackQuantity,
      imageUrls: imageUrls ?? this.imageUrls,
      variants: variants ?? this.variants,
      tags: tags ?? this.tags,
      seo: seo ?? this.seo,
      shipping: shipping ?? this.shipping,
      customFields: customFields ?? this.customFields,
      isFeatured: isFeatured ?? this.isFeatured,
      isDigital: isDigital ?? this.isDigital,
      salesCount: salesCount ?? this.salesCount,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      publishedAt: publishedAt ?? this.publishedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        shortDescription,
        sku,
        categoryId,
        categoryName,
        brandId,
        brandName,
        supplierId,
        supplierName,
        type,
        status,
        price,
        compareAtPrice,
        costPrice,
        currency,
        stockQuantity,
        lowStockThreshold,
        trackQuantity,
        imageUrls,
        variants,
        tags,
        seo,
        shipping,
        customFields,
        isFeatured,
        isDigital,
        salesCount,
        averageRating,
        reviewCount,
        publishedAt,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
