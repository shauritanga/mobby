import 'package:equatable/equatable.dart';

class Category extends Equatable {
  final String id;
  final String name;
  final String description;
  final String iconName;
  final String colorHex;
  final String? imageUrl;
  final String? parentId;
  final int sortOrder;
  final bool isActive;
  final int productCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    required this.iconName,
    required this.colorHex,
    this.imageUrl,
    this.parentId,
    required this.sortOrder,
    required this.isActive,
    required this.productCount,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isParentCategory => parentId == null;
  bool get hasProducts => productCount > 0;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconName,
        colorHex,
        imageUrl,
        parentId,
        sortOrder,
        isActive,
        productCount,
        createdAt,
        updatedAt,
      ];

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? colorHex,
    String? imageUrl,
    String? parentId,
    int? sortOrder,
    bool? isActive,
    int? productCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      colorHex: colorHex ?? this.colorHex,
      imageUrl: imageUrl ?? this.imageUrl,
      parentId: parentId ?? this.parentId,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      productCount: productCount ?? this.productCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
