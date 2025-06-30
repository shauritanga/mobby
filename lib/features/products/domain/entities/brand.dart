import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Brand extends Equatable {
  final String id;
  final String name;
  final String description;
  final String logoUrl;
  final String? websiteUrl;
  final String countryOfOrigin;
  final bool isActive;
  final bool isFeatured;
  final int productCount;
  final double averageRating;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? email;
  final String? phone;
  final Color? primaryColor;
  final String? imageUrl;
  final bool? isVerified;
  final int? reviewCount;
  final double? rating;

  const Brand({
    required this.id,
    required this.name,
    required this.description,
    required this.logoUrl,
    this.websiteUrl,
    required this.countryOfOrigin,
    required this.isActive,
    required this.isFeatured,
    required this.productCount,
    required this.averageRating,
    required this.createdAt,
    required this.updatedAt,
    this.email,
    this.phone,
    this.primaryColor,
    this.imageUrl,
    this.isVerified,
    this.reviewCount,
    this.rating,
  });

  bool get hasProducts => productCount > 0;
  bool get isPopular => averageRating >= 4.0 && productCount >= 10;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    logoUrl,
    websiteUrl,
    countryOfOrigin,
    isActive,
    isFeatured,
    productCount,
    averageRating,
    createdAt,
    updatedAt,
  ];

  Brand copyWith({
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
    return Brand(
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
