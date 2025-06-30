import '../../domain/entities/category.dart';

class CategorySEOModel {
  final String? metaTitle;
  final String? metaDescription;
  final List<String> keywords;
  final String? slug;

  const CategorySEOModel({
    this.metaTitle,
    this.metaDescription,
    this.keywords = const [],
    this.slug,
  });

  factory CategorySEOModel.fromJson(Map<String, dynamic> json) {
    return CategorySEOModel(
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

  factory CategorySEOModel.fromEntity(CategorySEO seo) {
    return CategorySEOModel(
      metaTitle: seo.metaTitle,
      metaDescription: seo.metaDescription,
      keywords: seo.keywords,
      slug: seo.slug,
    );
  }

  CategorySEO toEntity() {
    return CategorySEO(
      metaTitle: metaTitle,
      metaDescription: metaDescription,
      keywords: keywords,
      slug: slug,
    );
  }
}

class CategoryModel {
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
  final CategorySEOModel seo;
  final Map<String, dynamic> customFields;
  final int productCount;
  final int level;
  final List<String> childrenIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String createdBy;
  final String? updatedBy;

  const CategoryModel({
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

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      shortDescription: json['shortDescription'] as String?,
      parentId: json['parentId'] as String?,
      parentName: json['parentName'] as String?,
      imageUrl: json['imageUrl'] as String?,
      iconUrl: json['iconUrl'] as String?,
      status: CategoryStatus.values.firstWhere((e) => e.name == json['status']),
      sortOrder: json['sortOrder'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      showInMenu: json['showInMenu'] as bool? ?? true,
      seo: CategorySEOModel.fromJson(json['seo'] as Map<String, dynamic>),
      customFields: Map<String, dynamic>.from(json['customFields'] as Map),
      productCount: json['productCount'] as int? ?? 0,
      level: json['level'] as int? ?? 0,
      childrenIds: List<String>.from(json['childrenIds'] as List? ?? []),
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
      'parentId': parentId,
      'parentName': parentName,
      'imageUrl': imageUrl,
      'iconUrl': iconUrl,
      'status': status.name,
      'sortOrder': sortOrder,
      'isFeatured': isFeatured,
      'showInMenu': showInMenu,
      'seo': seo.toJson(),
      'customFields': customFields,
      'productCount': productCount,
      'level': level,
      'childrenIds': childrenIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'createdBy': createdBy,
      'updatedBy': updatedBy,
    };
  }

  factory CategoryModel.fromEntity(Category category) {
    return CategoryModel(
      id: category.id,
      name: category.name,
      description: category.description,
      shortDescription: category.shortDescription,
      parentId: category.parentId,
      parentName: category.parentName,
      imageUrl: category.imageUrl,
      iconUrl: category.iconUrl,
      status: category.status,
      sortOrder: category.sortOrder,
      isFeatured: category.isFeatured,
      showInMenu: category.showInMenu,
      seo: CategorySEOModel.fromEntity(category.seo),
      customFields: category.customFields,
      productCount: category.productCount,
      level: category.level,
      childrenIds: category.childrenIds,
      createdAt: category.createdAt,
      updatedAt: category.updatedAt,
      createdBy: category.createdBy,
      updatedBy: category.updatedBy,
    );
  }

  Category toEntity() {
    return Category(
      id: id,
      name: name,
      description: description,
      shortDescription: shortDescription,
      parentId: parentId,
      parentName: parentName,
      imageUrl: imageUrl,
      iconUrl: iconUrl,
      status: status,
      sortOrder: sortOrder,
      isFeatured: isFeatured,
      showInMenu: showInMenu,
      seo: seo.toEntity(),
      customFields: customFields,
      productCount: productCount,
      level: level,
      childrenIds: childrenIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdBy: createdBy,
      updatedBy: updatedBy,
    );
  }
}
