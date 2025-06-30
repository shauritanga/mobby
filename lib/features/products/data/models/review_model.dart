import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/review.dart';

part 'review_model.g.dart';

@JsonSerializable()
class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.productId,
    required super.userId,
    required super.userName,
    super.userAvatarUrl,
    required super.rating,
    required super.title,
    required super.comment,
    required super.imageUrls,
    required super.isVerifiedPurchase,
    required super.isHelpful,
    required super.helpfulCount,
    required super.notHelpfulCount,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      _$ReviewModelFromJson(json);

  Map<String, dynamic> toJson() => _$ReviewModelToJson(this);

  factory ReviewModel.fromEntity(Review review) {
    return ReviewModel(
      id: review.id,
      productId: review.productId,
      userId: review.userId,
      userName: review.userName,
      userAvatarUrl: review.userAvatarUrl,
      rating: review.rating,
      title: review.title,
      comment: review.comment,
      imageUrls: review.imageUrls,
      isVerifiedPurchase: review.isVerifiedPurchase,
      isHelpful: review.isHelpful,
      helpfulCount: review.helpfulCount,
      notHelpfulCount: review.notHelpfulCount,
      createdAt: review.createdAt,
      updatedAt: review.updatedAt,
    );
  }

  Review toEntity() {
    return Review(
      id: id,
      productId: productId,
      userId: userId,
      userName: userName,
      userAvatarUrl: userAvatarUrl,
      rating: rating,
      title: title,
      comment: comment,
      imageUrls: imageUrls,
      isVerifiedPurchase: isVerifiedPurchase,
      isHelpful: isHelpful,
      helpfulCount: helpfulCount,
      notHelpfulCount: notHelpfulCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  ReviewModel copyWith({
    String? id,
    String? productId,
    String? userId,
    String? userName,
    String? userAvatarUrl,
    double? rating,
    String? title,
    String? comment,
    List<String>? imageUrls,
    bool? isVerifiedPurchase,
    bool? isHelpful,
    int? helpfulCount,
    int? notHelpfulCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      userAvatarUrl: userAvatarUrl ?? this.userAvatarUrl,
      rating: rating ?? this.rating,
      title: title ?? this.title,
      comment: comment ?? this.comment,
      imageUrls: imageUrls ?? this.imageUrls,
      isVerifiedPurchase: isVerifiedPurchase ?? this.isVerifiedPurchase,
      isHelpful: isHelpful ?? this.isHelpful,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      notHelpfulCount: notHelpfulCount ?? this.notHelpfulCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
