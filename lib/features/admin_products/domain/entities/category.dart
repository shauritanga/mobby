import 'package:equatable/equatable.dart';

enum CategoryStatus {
  active,
  inactive,
  archived
}

class CategorySEO extends Equatable {
  final String? metaTitle;
  final String? metaDescription;
  final List<String> keywords;
  final String? slug;

  const CategorySEO({
    this.metaTitle,
    this.metaDescription,
    this.keywords = const [],
    this.slug,
  });

  @override
  List<Object?> get props => [metaTitle, metaDescription, keywords, slug];
}

class Category extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? shortDescription;
  final String? parentId;
  final String? parentName;
  final String? imageUrl;
  final String? iconUrl;
  final CategoryStatus status;
  final int sortOrder;
  final bool isFeatured;
  final bool showInMenu;
  final CategorySEO seo;
  final Map<String, dynamic> customFields;
  final int productCount;
  final int level; // 0 for root categories, 1 for subcategories, etc.
  final List<String> childrenIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const Category({
    required this.id,
    required this.name,
    required this.description,
    this.shortDescription,
    this.parentId,
    this.parentName,
    this.imageUrl,
    this.iconUrl,
    required this.status,
    this.sortOrder = 0,
    this.isFeatured = false,
    this.showInMenu = true,
    required this.seo,
    required this.customFields,
    this.productCount = 0,
    this.level = 0,
    required this.childrenIds,
    required this.createdAt,
    required this.updatedAt,
    required this.createdBy,
    this.updatedBy,
  });

  bool get isActive => status == CategoryStatus.active;
  bool get isRootCategory => parentId == null;
  bool get hasChildren => childrenIds.isNotEmpty;
  bool get hasProducts => productCount > 0;
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;
  bool get hasIcon => iconUrl != null && iconUrl!.isNotEmpty;

  String get statusDisplayName {
    switch (status) {
      case CategoryStatus.active:
        return 'Active';
      case CategoryStatus.inactive:
        return 'Inactive';
      case CategoryStatus.archived:
        return 'Archived';
    }
  }

  String get breadcrumb {
    if (parentName != null) {
      return '$parentName > $name';
    }
    return name;
  }

  Category copyWith({
    String? id,
    String? name,
    String? description,
    String? shortDescription,
    String? parentId,
    String? parentName,
    String? imageUrl,
    String? iconUrl,
    CategoryStatus? status,
    int? sortOrder,
    bool? isFeatured,
    bool? showInMenu,
    CategorySEO? seo,
    Map<String, dynamic>? customFields,
    int? productCount,
    int? level,
    List<String>? childrenIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? createdBy,
    String? updatedBy,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      imageUrl: imageUrl ?? this.imageUrl,
      iconUrl: iconUrl ?? this.iconUrl,
      status: status ?? this.status,
      sortOrder: sortOrder ?? this.sortOrder,
      isFeatured: isFeatured ?? this.isFeatured,
      showInMenu: showInMenu ?? this.showInMenu,
      seo: seo ?? this.seo,
      customFields: customFields ?? this.customFields,
      productCount: productCount ?? this.productCount,
      level: level ?? this.level,
      childrenIds: childrenIds ?? this.childrenIds,
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
        parentId,
        parentName,
        imageUrl,
        iconUrl,
        status,
        sortOrder,
        isFeatured,
        showInMenu,
        seo,
        customFields,
        productCount,
        level,
        childrenIds,
        createdAt,
        updatedAt,
        createdBy,
        updatedBy,
      ];
}
