// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quick_action_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuickActionModel _$QuickActionModelFromJson(Map<String, dynamic> json) =>
    QuickActionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      iconName: json['iconName'] as String,
      route: json['route'] as String,
      colorHex: json['colorHex'] as String,
      sortOrder: (json['sortOrder'] as num).toInt(),
      isActive: json['isActive'] as bool,
      requiresAuth: json['requiresAuth'] as bool,
      description: json['description'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$QuickActionModelToJson(QuickActionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'iconName': instance.iconName,
      'route': instance.route,
      'colorHex': instance.colorHex,
      'sortOrder': instance.sortOrder,
      'isActive': instance.isActive,
      'requiresAuth': instance.requiresAuth,
      'description': instance.description,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
