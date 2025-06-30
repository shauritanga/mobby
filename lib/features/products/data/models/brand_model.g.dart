// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'brand_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BrandModel _$BrandModelFromJson(Map<String, dynamic> json) => BrandModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      logoUrl: json['logoUrl'] as String,
      websiteUrl: json['websiteUrl'] as String?,
      countryOfOrigin: json['countryOfOrigin'] as String,
      isActive: json['isActive'] as bool,
      isFeatured: json['isFeatured'] as bool,
      productCount: (json['productCount'] as num).toInt(),
      averageRating: (json['averageRating'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BrandModelToJson(BrandModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'logoUrl': instance.logoUrl,
      'websiteUrl': instance.websiteUrl,
      'countryOfOrigin': instance.countryOfOrigin,
      'isActive': instance.isActive,
      'isFeatured': instance.isFeatured,
      'productCount': instance.productCount,
      'averageRating': instance.averageRating,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
