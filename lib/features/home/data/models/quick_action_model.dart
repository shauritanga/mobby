import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/quick_action.dart';

part 'quick_action_model.g.dart';

@JsonSerializable()
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

  factory QuickActionModel.fromJson(Map<String, dynamic> json) =>
      _$QuickActionModelFromJson(json);

  Map<String, dynamic> toJson() => _$QuickActionModelToJson(this);

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
