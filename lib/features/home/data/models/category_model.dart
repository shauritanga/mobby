import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.description,
    required super.iconName,
    required super.colorHex,
    super.imageUrl,
    super.parentId,
    required super.sortOrder,
    required super.isActive,
    required super.productCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      iconName: map['iconName'] as String,
      colorHex: map['colorHex'] as String,
      imageUrl: map['imageUrl'] as String?,
      parentId: map['parentId'] as String?,
      sortOrder: map['sortOrder'] as int,
      isActive: map['isActive'] as bool,
      productCount: map['productCount'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconName': iconName,
      'colorHex': colorHex,
      'imageUrl': imageUrl,
      'parentId': parentId,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'productCount': productCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // For backward compatibility
  factory CategoryModel.fromJson(Map<String, dynamic> json) =>
      CategoryModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      iconName: category.iconName,
      colorHex: category.colorHex,
      imageUrl: category.imageUrl,
      parentId: category.parentId,
      sortOrder: category.sortOrder,
      isActive: category.isActive,
      productCount: category.productCount,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      iconName: iconName,
      colorHex: colorHex,
      imageUrl: imageUrl,
      parentId: parentId,
      sortOrder: sortOrder,
      isActive: isActive,
      productCount: productCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  CategoryModel copyWith({
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
    return CategoryModel(
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
