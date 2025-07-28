import '../../domain/entities/brand.dart';

class BrandModel extends Brand {
  const BrandModel({
    required super.id,
    required super.name,
    required super.description,
    required super.logoUrl,
    super.websiteUrl,
    required super.countryOfOrigin,
    required super.isActive,
    required super.isFeatured,
    required super.productCount,
    required super.averageRating,
    required super.createdAt,
    required super.updatedAt,
  });

  factory BrandModel.fromMap(Map<String, dynamic> map) {
    return BrandModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      logoUrl: map['logoUrl'] as String,
      websiteUrl: map['websiteUrl'] as String?,
      countryOfOrigin: map['countryOfOrigin'] as String,
      isActive: map['isActive'] as bool,
      isFeatured: map['isFeatured'] as bool,
      productCount: map['productCount'] as int,
      averageRating: (map['averageRating'] as num).toDouble(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logoUrl': logoUrl,
      'websiteUrl': websiteUrl,
      'countryOfOrigin': countryOfOrigin,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'productCount': productCount,
      'averageRating': averageRating,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // For backward compatibility
  factory BrandModel.fromJson(Map<String, dynamic> json) =>
      BrandModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  factory BrandModel.fromEntity(Brand brand) {
    return BrandModel(
      id: brand.id,
      name: brand.name,
      description: brand.description,
      logoUrl: brand.logoUrl,
      websiteUrl: brand.websiteUrl,
      countryOfOrigin: brand.countryOfOrigin,
      isActive: brand.isActive,
      isFeatured: brand.isFeatured,
      productCount: brand.productCount,
      averageRating: brand.averageRating,
      createdAt: brand.createdAt,
      updatedAt: brand.updatedAt,
    );
  }

  Brand toEntity() {
    return Brand(
      id: id,
      name: name,
      description: description,
      logoUrl: logoUrl,
      websiteUrl: websiteUrl,
      countryOfOrigin: countryOfOrigin,
      isActive: isActive,
      isFeatured: isFeatured,
      productCount: productCount,
      averageRating: averageRating,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  BrandModel copyWith({
    String? id,
    String? name,
    String? description,
    String? logoUrl,
    String? websiteUrl,
    String? countryOfOrigin,
    bool? isActive,
    bool? isFeatured,
    int? productCount,
    double? averageRating,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return BrandModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      countryOfOrigin: countryOfOrigin ?? this.countryOfOrigin,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      productCount: productCount ?? this.productCount,
      averageRating: averageRating ?? this.averageRating,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
