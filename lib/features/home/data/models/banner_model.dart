import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/banner.dart';

part 'banner_model.g.dart';

@JsonSerializable()
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

  factory BannerModel.fromJson(Map<String, dynamic> json) =>
      _$BannerModelFromJson(json);

  Map<String, dynamic> toJson() => _$BannerModelToJson(this);

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
