import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final String id;
  final String productId;
  final String userId;
  final String userName;
  final String? userAvatarUrl;
  final double rating;
  final String title;
  final String comment;
  final List<String> imageUrls;
  final bool isVerifiedPurchase;
  final bool isHelpful;
  final int helpfulCount;
  final int notHelpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Review({
    required this.id,
    required this.productId,
    required this.userId,
    required this.userName,
    this.userAvatarUrl,
    required this.rating,
    required this.title,
    required this.comment,
    required this.imageUrls,
    required this.isVerifiedPurchase,
    required this.isHelpful,
    required this.helpfulCount,
    required this.notHelpfulCount,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasImages => imageUrls.isNotEmpty;
  bool get isPositive => rating >= 4.0;
  bool get isNegative => rating <= 2.0;
  double get helpfulRatio => 
      (helpfulCount + notHelpfulCount) > 0 
          ? helpfulCount / (helpfulCount + notHelpfulCount) 
          : 0.0;

  @override
  List<Object?> get props => [
        id,
        productId,
        userId,
        userName,
        userAvatarUrl,
        rating,
        title,
        comment,
        imageUrls,
        isVerifiedPurchase,
        isHelpful,
        helpfulCount,
        notHelpfulCount,
        createdAt,
        updatedAt,
      ];

  Review copyWith({
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
    return Review(
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
