import 'package:equatable/equatable.dart';

class Banner extends Equatable {
  final String id;
  final String title;
  final String subtitle;
  final String imageUrl;
  final String? actionUrl;
  final String actionText;
  final String colorHex;
  final int priority;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? expiresAt;

  const Banner({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imageUrl,
    this.actionUrl,
    required this.actionText,
    required this.colorHex,
    required this.priority,
    required this.isActive,
    required this.createdAt,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        subtitle,
        imageUrl,
        actionUrl,
        actionText,
        colorHex,
        priority,
        isActive,
        createdAt,
        expiresAt,
      ];

  Banner copyWith({
    String? id,
    String? title,
    String? subtitle,
    String? imageUrl,
    String? actionUrl,
    String? actionText,
    String? colorHex,
    int? priority,
    bool? isActive,
    DateTime? createdAt,
    DateTime? expiresAt,
  }) {
    return Banner(
      id: id ?? this.id,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      imageUrl: imageUrl ?? this.imageUrl,
      actionUrl: actionUrl ?? this.actionUrl,
      actionText: actionText ?? this.actionText,
      colorHex: colorHex ?? this.colorHex,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      expiresAt: expiresAt ?? this.expiresAt,
    );
  }
}
