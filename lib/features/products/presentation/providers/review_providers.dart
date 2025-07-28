import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/review.dart';
import '../../domain/repositories/product_repository.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/datasources/product_local_datasource.dart';

// Data source providers
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  return ProductRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  // This will be provided by dependency injection in main.dart
  throw UnimplementedError('SharedPreferences must be provided');
});

// Repository provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepositoryImpl(
    remoteDataSource: ref.read(productRemoteDataSourceProvider),
    localDataSource: ref.read(productLocalDataSourceProvider),
  );
});

// Product Reviews Provider - fetches reviews for a specific product
final productReviewsProvider = FutureProvider.family<List<Review>, String>((
  ref,
  productId,
) async {
  final repository = ref.read(productRepositoryProvider);
  return await repository.getProductReviews(productId);
});
// Review Summary Provider - provides aggregated review data
final reviewSummaryProvider = FutureProvider.family<ReviewSummary, String>((
  ref,
  productId,
) async {
  final reviews = await ref.watch(productReviewsProvider(productId).future);

  if (reviews.isEmpty) {
    return const ReviewSummary(
      averageRating: 0.0,
      totalReviews: 0,
      ratingDistribution: {},
    );
  }

  final totalReviews = reviews.length;
  final totalRating = reviews.fold<double>(
    0.0,
    (total, review) => total + review.rating,
  );
  final averageRating = totalRating / totalReviews;

  // Calculate rating distribution
  final ratingDistribution = <int, int>{};
  for (int i = 1; i <= 5; i++) {
    ratingDistribution[i] = reviews.where((r) => r.rating.round() == i).length;
  }

  return ReviewSummary(
    averageRating: averageRating,
    totalReviews: totalReviews,
    ratingDistribution: ratingDistribution,
  );
});

// Review Summary data class
class ReviewSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  const ReviewSummary({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });
}
