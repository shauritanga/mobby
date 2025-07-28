import '../../domain/entities/banner.dart';

class BannerModel extends Banner {
  const BannerModel({
    required super.id,
    required super.title,
    required super.subtitle,
    required super.imageUrl,
    super.actionUrl,
    required super.actionText,
    required super.colorHex,
    required super.priority,
    required super.isActive,
    required super.createdAt,
    super.expiresAt,
  });

  factory BannerModel.fromMap(Map<String, dynamic> map) {
    return BannerModel(
      id: map['id'] as String,
      title: map['title'] as String,
      subtitle: map['subtitle'] as String,
      imageUrl: map['imageUrl'] as String,
      actionUrl: map['actionUrl'] as String?,
      actionText: map['actionText'] as String,
      colorHex: map['colorHex'] as String,
      priority: map['priority'] as int,
      isActive: map['isActive'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      expiresAt: map['expiresAt'] != null
          ? DateTime.parse(map['expiresAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'imageUrl': imageUrl,
      'actionUrl': actionUrl,
      'actionText': actionText,
      'colorHex': colorHex,
      'priority': priority,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  // For backward compatibility
  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      BannerModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  factory BannerModel.fromEntity(Banner banner) {
    return BannerModel(
      id: banner.id,
      title: banner.title,
      subtitle: banner.subtitle,
      imageUrl: banner.imageUrl,
      actionUrl: banner.actionUrl,
      actionText: banner.actionText,
      colorHex: banner.colorHex,
      priority: banner.priority,
      isActive: banner.isActive,
      createdAt: banner.createdAt,
      expiresAt: banner.expiresAt,
    );
  }

  Banner toEntity() {
    return Banner(
      id: id,
      title: title,
      subtitle: subtitle,
      imageUrl: imageUrl,
      actionUrl: actionUrl,
      actionText: actionText,
      colorHex: colorHex,
      priority: priority,
      isActive: isActive,
      createdAt: createdAt,
      expiresAt: expiresAt,
    );
  }

  @override
  BannerModel copyWith({
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
    return BannerModel(
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
