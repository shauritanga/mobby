import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/review.dart';
import '../providers/review_providers.dart';

class ProductReviewsSection extends ConsumerWidget {
  final String productId;
  final VoidCallback? onWriteReview;

  const ProductReviewsSection({
    super.key,
    required this.productId,
    this.onWriteReview,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(productReviewsProvider(productId));

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Reviews summary
          _buildReviewsSummary(context, ref),

          SizedBox(height: 16.h),

          // Write review button
          _buildWriteReviewButton(context),

          SizedBox(height: 24.h),

          // Reviews list
          reviewsAsync.when(
            data: (reviews) => _buildReviewsList(context, reviews),
            loading: () => _buildLoadingReviews(context),
            error: (error, stack) => _buildErrorReviews(context),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSummary(BuildContext context, WidgetRef ref) {
    // In a real app, this would come from a separate provider
    // For now, we'll use mock data
    final averageRating = 4.2;
    final totalReviews = 156;
    final ratingDistribution = {5: 78, 4: 45, 3: 20, 2: 8, 1: 5};

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Average rating
              Column(
                children: [
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 32.sp,
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < averageRating.floor()
                            ? Icons.star
                            : index < averageRating
                            ? Icons.star_half
                            : Icons.star_border,
                        size: 20.sp,
                        color: Colors.amber,
                      );
                    }),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$totalReviews reviews',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                ],
              ),

              SizedBox(width: 24.w),

              // Rating distribution
              Expanded(
                child: Column(
                  children: ratingDistribution.entries.map((entry) {
                    final stars = entry.key;
                    final count = entry.value;
                    final percentage = count / totalReviews;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 4.h),
                      child: Row(
                        children: [
                          Text(
                            '$stars',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Icon(Icons.star, size: 12.sp, color: Colors.amber),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: LinearProgressIndicator(
                              value: percentage,
                              backgroundColor: Theme.of(context).dividerColor,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            count.toString(),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(context).hintColor,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWriteReviewButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onWriteReview,
        icon: Icon(Icons.rate_review, size: 20.sp),
        label: Text('Write a Review', style: TextStyle(fontSize: 16.sp)),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
      ),
    );
  }

  Widget _buildReviewsList(BuildContext context, List<Review> reviews) {
    if (reviews.isEmpty) {
      return _buildNoReviews(context);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Customer Reviews',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).textTheme.headlineSmall?.color,
          ),
        ),

        SizedBox(height: 12.h),

        ...reviews.map(
          (review) => Padding(
            padding: EdgeInsets.only(bottom: 16.h),
            child: _buildReviewCard(context, review),
          ),
        ),

        // Load more button
        if (reviews.length >= 20)
          Center(
            child: TextButton(
              onPressed: () => _loadMoreReviews(),
              child: const Text('Load More Reviews'),
            ),
          ),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context, Review review) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Review header
          Row(
            children: [
              // User avatar
              CircleAvatar(
                radius: 20.r,
                backgroundColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.1),
                child: Text(
                  review.userName.isNotEmpty
                      ? review.userName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),

              SizedBox(width: 12.w),

              // User info and rating
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.userName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Row(
                      children: [
                        // Star rating
                        Row(
                          children: List.generate(5, (index) {
                            return Icon(
                              index < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              size: 16.sp,
                              color: Colors.amber,
                            );
                          }),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          _formatDate(review.createdAt),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).hintColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Verified purchase badge
              if (review.isVerifiedPurchase)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Verified',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          SizedBox(height: 12.h),

          // Review title
          ...[
            Text(
              review.title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            SizedBox(height: 8.h),
          ],

          // Review content
          Text(
            review.comment,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.4,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),

          // Review images
          if (review.imageUrls.isNotEmpty) ...[
            SizedBox(height: 12.h),
            SizedBox(
              height: 80.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: review.imageUrls.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.network(
                        review.imageUrls[index],
                        width: 80.w,
                        height: 80.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 80.w,
                            height: 80.h,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image),
                          );
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
          ],

          SizedBox(height: 12.h),

          // Review actions
          Row(
            children: [
              // Helpful button
              TextButton.icon(
                onPressed: () => _markHelpful(review.id),
                icon: Icon(Icons.thumb_up_outlined, size: 16.sp),
                label: Text(
                  'Helpful (${review.helpfulCount})',
                  style: TextStyle(fontSize: 12.sp),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).hintColor,
                  padding: EdgeInsets.zero,
                ),
              ),

              SizedBox(width: 16.w),

              // Report button
              TextButton.icon(
                onPressed: () => _reportReview(review.id),
                icon: Icon(Icons.flag_outlined, size: 16.sp),
                label: Text('Report', style: TextStyle(fontSize: 12.sp)),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).hintColor,
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoReviews(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Icon(
            Icons.rate_review_outlined,
            size: 64.sp,
            color: Theme.of(context).hintColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Reviews Yet',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Be the first to review this product and help other customers make informed decisions.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: onWriteReview,
            child: const Text('Write First Review'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingReviews(BuildContext context) {
    return Column(
      children: List.generate(
        3,
        (index) => Padding(
          padding: EdgeInsets.only(bottom: 16.h),
          child: Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Theme.of(context).dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120.w,
                            height: 16.h,
                            color: Colors.grey[200],
                          ),
                          SizedBox(height: 4.h),
                          Container(
                            width: 80.w,
                            height: 12.h,
                            color: Colors.grey[200],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  height: 16.h,
                  color: Colors.grey[200],
                ),
                SizedBox(height: 4.h),
                Container(width: 200.w, height: 16.h, color: Colors.grey[200]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorReviews(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64.sp,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to Load Reviews',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Unable to load customer reviews. Please try again.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              // Retry loading reviews
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 30) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }

  void _loadMoreReviews() {
    // Load more reviews logic
  }

  void _markHelpful(String reviewId) {
    // Mark review as helpful
  }

  void _reportReview(String reviewId) {
    // Report review
  }
}
