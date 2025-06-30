import 'package:equatable/equatable.dart';

class QuickAction extends Equatable {
  final String id;
  final String title;
  final String iconName;
  final String route;
  final String colorHex;
  final int sortOrder;
  final bool isActive;
  final bool requiresAuth;
  final String? description;
  final DateTime createdAt;
  final DateTime updatedAt;

  const QuickAction({
    required this.id,
    required this.title,
    required this.iconName,
    required this.route,
    required this.colorHex,
    required this.sortOrder,
    required this.isActive,
    required this.requiresAuth,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    iconName,
    route,
    colorHex,
    sortOrder,
    isActive,
    requiresAuth,
    description,
    createdAt,
    updatedAt,
  ];

  QuickAction copyWith({
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
    return QuickAction(
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
