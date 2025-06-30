import '../../domain/entities/admin_product.dart';

class ProductVariantModel {
  final String id;
  final String name;
  final String sku;
  final double price;
  final double? compareAtPrice;
  final int stockQuantity;
  final Map<String, String> attributes;
  final List<String> imageUrls;
  final bool isActive;

  const ProductVariantModel({
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

  factory ProductVariantModel.fromJson(Map<String, dynamic> json) {
    return ProductVariantModel(
      id: json['id'] as String,
      name: json['name'] as String,
      sku: json['sku'] as String,
      price: (json['price'] as num).toDouble(),
      compareAtPrice: json['compareAtPrice'] != null ? (json['compareAtPrice'] as num).toDouble() : null,
      stockQuantity: json['stockQuantity'] as int,
      attributes: Map<String, String>.from(json['attributes'] as Map),
      imageUrls: List<String>.from(json['imageUrls'] as List),
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sku': sku,
      'price': price,
      'compareAtPrice': compareAtPrice,
      'stockQuantity': stockQuantity,
      'attributes': attributes,
      'imageUrls': imageUrls,
      'isActive': isActive,
    };
  }

  factory ProductVariantModel.fromEntity(ProductVariant variant) {
    return ProductVariantModel(
      id: variant.id,
      name: variant.name,
      sku: variant.sku,
      price: variant.price,
      compareAtPrice: variant.compareAtPrice,
      stockQuantity: variant.stockQuantity,
      attributes: variant.attributes,
      imageUrls: variant.imageUrls,
      isActive: variant.isActive,
    );
  }

  ProductVariant toEntity() {
    return ProductVariant(
      id: id,
      name: name,
      sku: sku,
      price: price,
      compareAtPrice: compareAtPrice,
      stockQuantity: stockQuantity,
      attributes: attributes,
      imageUrls: imageUrls,
      isActive: isActive,
    );
  }
}

class ProductSEOModel {
  final String? metaTitle;
  final String? metaDescription;
  final List<String> keywords;
  final String? slug;

  const ProductSEOModel({
    this.metaTitle,
    this.metaDescription,
    this.keywords = const [],
    this.slug,
  });

  factory ProductSEOModel.fromJson(Map<String, dynamic> json) {
    return ProductSEOModel(
      metaTitle: json['metaTitle'] as String?,
      metaDescription: json['metaDescription'] as String?,
      keywords: List<String>.from(json['keywords'] as List? ?? []),
      slug: json['slug'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'metaTitle': metaTitle,
      'metaDescription': metaDescription,
      'keywords': keywords,
      'slug': slug,
    };
  }

  factory ProductSEOModel.fromEntity(ProductSEO seo) {
    return ProductSEOModel(
      metaTitle: seo.metaTitle,
      metaDescription: seo.metaDescription,
      keywords: seo.keywords,
      slug: seo.slug,
    );
  }

  ProductSEO toEntity() {
    return ProductSEO(
      metaTitle: metaTitle,
      metaDescription: metaDescription,
      keywords: keywords,
      slug: slug,
    );
  }
}

class ProductShippingModel {
  final double weight;
  final double? length;
  final double? width;
  final double? height;
  final bool requiresShipping;
  final bool isFreeShipping;
  final double? shippingCost;

  const ProductShippingModel({
    required this.weight,
    this.length,
    this.width,
    this.height,
    this.requiresShipping = true,
    this.isFreeShipping = false,
    this.shippingCost,
  });

  factory ProductShippingModel.fromJson(Map<String, dynamic> json) {
    return ProductShippingModel(
      weight: (json['weight'] as num).toDouble(),
      length: json['length'] != null ? (json['length'] as num).toDouble() : null,
      width: json['width'] != null ? (json['width'] as num).toDouble() : null,
      height: json['height'] != null ? (json['height'] as num).toDouble() : null,
      requiresShipping: json['requiresShipping'] as bool? ?? true,
      isFreeShipping: json['isFreeShipping'] as bool? ?? false,
      shippingCost: json['shippingCost'] != null ? (json['shippingCost'] as num).toDouble() : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'length': length,
      'width': width,
      'height': height,
      'requiresShipping': requiresShipping,
      'isFreeShipping': isFreeShipping,
      'shippingCost': shippingCost,
    };
  }

  factory ProductShippingModel.fromEntity(ProductShipping shipping) {
    return ProductShippingModel(
      weight: shipping.weight,
      length: shipping.length,
      width: shipping.width,
      height: shipping.height,
      requiresShipping: shipping.requiresShipping,
      isFreeShipping: shipping.isFreeShipping,
      shippingCost: shipping.shippingCost,
    );
  }

  ProductShipping toEntity() {
    return ProductShipping(
      weight: weight,
      length: length,
      width: width,
      height: height,
      requiresShipping: requiresShipping,
      isFreeShipping: isFreeShipping,
      shippingCost: shippingCost,
    );
  }
}

class AdminProductModel {
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
  final List<ProductVariantModel> variants;
  final List<String> tags;
  final ProductSEOModel seo;
  final ProductShippingModel shipping;
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

  const AdminProductModel({
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

  factory AdminProductModel.fromJson(Map<String, dynamic> json) {
    return AdminProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      shortDescription: json['shortDescription'] as String?,
      sku: json['sku'] as String,
      categoryId: json['categoryId'] as String,
      categoryName: json['categoryName'] as String,
      brandId: json['brandId'] as String?,
      brandName: json['brandName'] as String?,
      supplierId: json['supplierId'] as String?,
      supplierName: json['supplierName'] as String?,
      type: ProductType.values.firstWhere((e) => e.name == json['type']),
      status: ProductStatus.values.firstWhere((e) => e.name == json['status']),
      price: (json['price'] as num).toDouble(),
      compareAtPrice: json['compareAtPrice'] != null ? (json['compareAtPrice'] as num).toDouble() : null,
      costPrice: (json['costPrice'] as num).toDouble(),
      currency: json['currency'] as String,
      stockQuantity: json['stockQuantity'] as int,
      lowStockThreshold: json['lowStockThreshold'] as int?,
      trackQuantity: json['trackQuantity'] as bool? ?? true,
      imageUrls: List<String>.from(json['imageUrls'] as List),
      variants: (json['variants'] as List).map((v) => ProductVariantModel.fromJson(v)).toList(),
      tags: List<String>.from(json['tags'] as List),
      seo: ProductSEOModel.fromJson(json['seo'] as Map<String, dynamic>),
      shipping: ProductShippingModel.fromJson(json['shipping'] as Map<String, dynamic>),
      customFields: Map<String, dynamic>.from(json['customFields'] as Map),
      isFeatured: json['isFeatured'] as bool? ?? false,
      isDigital: json['isDigital'] as bool? ?? false,
      salesCount: json['salesCount'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      publishedAt: json['publishedAt'] != null ? DateTime.parse(json['publishedAt'] as String) : null,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdBy: json['createdBy'] as String,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'shortDescription': shortDescription,
      'sku': sku,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'brandId': brandId,
      'brandName': brandName,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'type': type.name,
      'status': status.name,
      'price': price,
      'compareAtPrice': compareAtPrice,
      'costPrice': costPrice,
      'currency': currency,
      'stockQuantity': stockQuantity,
      'lowStockThreshold': lowStockThreshold,
      'trackQuantity': trackQuantity,
      'imageUrls': imageUrls,
      'variants': variants.map((v) => v.toJson()).toList(),
      'tags': tags,
      'seo': seo.toJson(),
      'shipping': shipping.toJson(),
      'customFields': customFields,
      'isFeatured': isFeatured,
      'isDigital': isDigital,
      'salesCount': salesCount,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'publishedAt': publishedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  factory AdminProductModel.fromEntity(AdminProduct product) {
    return AdminProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      shortDescription: product.shortDescription,
      sku: product.sku,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
      brandId: product.brandId,
      brandName: product.brandName,
      supplierId: product.supplierId,
      supplierName: product.supplierName,
      type: product.type,
      status: product.status,
      price: product.price,
      compareAtPrice: product.compareAtPrice,
      costPrice: product.costPrice,
      currency: product.currency,
      stockQuantity: product.stockQuantity,
      lowStockThreshold: product.lowStockThreshold,
      trackQuantity: product.trackQuantity,
      imageUrls: product.imageUrls,
      variants: product.variants.map((v) => ProductVariantModel.fromEntity(v)).toList(),
      tags: product.tags,
      seo: ProductSEOModel.fromEntity(product.seo),
      shipping: ProductShippingModel.fromEntity(product.shipping),
      customFields: product.customFields,
      isFeatured: product.isFeatured,
      isDigital: product.isDigital,
      salesCount: product.salesCount,
      averageRating: product.averageRating,
      reviewCount: product.reviewCount,
      publishedAt: product.publishedAt,
      createdAt: product.createdAt,
      updatedAt: product.updatedAt,
      createdBy: product.createdBy,
      updatedBy: product.updatedBy,
    );
  }

  AdminProduct toEntity() {
    return AdminProduct(
      id: id,
      name: name,
      description: description,
      shortDescription: shortDescription,
      sku: sku,
      categoryId: categoryId,
      categoryName: categoryName,
      brandId: brandId,
      brandName: brandName,
      supplierId: supplierId,
      supplierName: supplierName,
      type: type,
      status: status,
      price: price,
      compareAtPrice: compareAtPrice,
      costPrice: costPrice,
      currency: currency,
      stockQuantity: stockQuantity,
      lowStockThreshold: lowStockThreshold,
      trackQuantity: trackQuantity,
      imageUrls: imageUrls,
      variants: variants.map((v) => v.toEntity()).toList(),
      tags: tags,
      seo: seo.toEntity(),
      shipping: shipping.toEntity(),
      customFields: customFields,
      isFeatured: isFeatured,
      isDigital: isDigital,
      salesCount: salesCount,
      averageRating: averageRating,
      reviewCount: reviewCount,
      publishedAt: publishedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }
}
