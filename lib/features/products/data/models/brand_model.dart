import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/brand.dart';

part 'brand_model.g.dart';

@JsonSerializable()
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

  factory BrandModel.fromJson(Map<String, dynamic> json) =>
      _$BrandModelFromJson(json);

  Map<String, dynamic> toJson() => _$BrandModelToJson(this);

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
