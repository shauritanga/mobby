import '../../domain/entities/review.dart';

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

  factory ReviewModel.fromMap(Map<String, dynamic> map) {
    return ReviewModel(
      id: map['id'] as String,
      productId: map['productId'] as String,
      userId: map['userId'] as String,
      userName: map['userName'] as String,
      userAvatarUrl: map['userAvatarUrl'] as String?,
      rating: (map['rating'] as num).toDouble(),
      title: map['title'] as String,
      comment: map['comment'] as String,
      imageUrls: List<String>.from(map['imageUrls'] as List),
      isVerifiedPurchase: map['isVerifiedPurchase'] as bool,
      isHelpful: map['isHelpful'] as bool,
      helpfulCount: map['helpfulCount'] as int,
      notHelpfulCount: map['notHelpfulCount'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'userId': userId,
      'userName': userName,
      'userAvatarUrl': userAvatarUrl,
      'rating': rating,
      'title': title,
      'comment': comment,
      'imageUrls': imageUrls,
      'isVerifiedPurchase': isVerifiedPurchase,
      'isHelpful': isHelpful,
      'helpfulCount': helpfulCount,
      'notHelpfulCount': notHelpfulCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // For backward compatibility
  factory ReviewModel.fromJson(Map<String, dynamic> json) =>
      ReviewModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

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
