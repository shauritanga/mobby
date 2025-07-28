import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/product_filter.dart';
import 'product_providers.dart' as products;

// Brand provider - fetches a single brand by ID
final brandProvider = FutureProvider.family<Brand?, String>((
  ref,
  brandId,
) async {
  final repository = ref.watch(products.productRepositoryProvider);
  return repository.getBrandById(brandId);
});

// Brand products provider - fetches all products for a specific brand
final brandProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  brandId,
) async {
  final repository = ref.watch(products.productRepositoryProvider);
  final result = await repository.getProductsByBrand(brandId);
  return result.products;
});

// Brand popular products provider - fetches popular products for a specific brand
final brandPopularProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, brandId) async {
      final repository = ref.watch(products.productRepositoryProvider);
      final filter = ProductFilter(
        brandIds: [brandId],
        minRating: 4.0,
        sortBy: SortOption.ratingDesc,
      );
      final result = await repository.getProducts(filter);
      return result.products;
    });

// Brand new arrivals provider - fetches new products for a specific brand
final brandNewArrivalsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  brandId,
) async {
  final repository = ref.watch(products.productRepositoryProvider);
  final filter = ProductFilter(
    brandIds: [brandId],
    sortBy: SortOption.newest,
    limit: 10,
  );
  final result = await repository.getProducts(filter);
  return result.products;
});

// All brands provider - fetches all available brands
final brandsProvider = FutureProvider<List<Brand>>((ref) async {
  final repository = ref.watch(products.productRepositoryProvider);
  return repository.getBrands();
});

// Featured brands provider - fetches featured brands
final featuredBrandsProvider = FutureProvider<List<Brand>>((ref) async {
  final brands = await ref.watch(brandsProvider.future);
  // Return brands with high ratings as featured
  return brands.where((b) => (b.rating ?? b.averageRating) >= 4.0).toList();
});

// Extension methods for brand-related actions
extension BrandProviderActions on WidgetRef {
  void toggleFollowBrand(String userId, String brandId) {
    // Mock implementation - in a real app this would update the backend
    // In production, this would call a repository method
  }

  bool isBrandFollowed(String brandId) {
    // Mock implementation - in a real app this would check user's followed brands
    return false;
  }

  void trackBrandView(String brandId) {
    // Mock implementation - in a real app this would track analytics
    // In production, this would call an analytics service
  }
}
