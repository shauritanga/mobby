import '../../domain/entities/quick_action.dart';

class QuickActionModel extends QuickAction {
  const QuickActionModel({
    required super.id,
    required super.title,
    required super.iconName,
    required super.route,
    required super.colorHex,
    required super.sortOrder,
    required super.isActive,
    required super.requiresAuth,
    super.description,
    required super.createdAt,
    required super.updatedAt,
  });

  factory QuickActionModel.fromMap(Map<String, dynamic> map) {
    return QuickActionModel(
      id: map['id'] as String,
      title: map['title'] as String,
      iconName: map['iconName'] as String,
      route: map['route'] as String,
      colorHex: map['colorHex'] as String,
      sortOrder: map['sortOrder'] as int,
      isActive: map['isActive'] as bool,
      requiresAuth: map['requiresAuth'] as bool,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'iconName': iconName,
      'route': route,
      'colorHex': colorHex,
      'sortOrder': sortOrder,
      'isActive': isActive,
      'requiresAuth': requiresAuth,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // For backward compatibility
  factory QuickActionModel.fromJson(Map<String, dynamic> json) =>
      QuickActionModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  factory QuickActionModel.fromEntity(QuickAction quickAction) {
    return QuickActionModel(
      id: quickAction.id,
      title: quickAction.title,
      iconName: quickAction.iconName,
      route: quickAction.route,
      colorHex: quickAction.colorHex,
      sortOrder: quickAction.sortOrder,
      isActive: quickAction.isActive,
      requiresAuth: quickAction.requiresAuth,
      description: quickAction.description,
      createdAt: quickAction.createdAt,
      updatedAt: quickAction.updatedAt,
    );
  }

  QuickAction toEntity() {
    return QuickAction(
      id: id,
      title: title,
      iconName: iconName,
      route: route,
      colorHex: colorHex,
      sortOrder: sortOrder,
      isActive: isActive,
      requiresAuth: requiresAuth,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  QuickActionModel copyWith({
    String? id,
    String? title,
    String? iconName,
    String? route,
    String? colorHex,
    int? sortOrder,
    bool? isActive,
    bool? requiresAuth,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return QuickActionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      iconName: iconName ?? this.iconName,
      route: route ?? this.route,
      colorHex: colorHex ?? this.colorHex,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      requiresAuth: requiresAuth ?? this.requiresAuth,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
