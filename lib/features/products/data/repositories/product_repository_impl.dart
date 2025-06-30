import 'package:mobby/features/products/domain/entities/product_search_result.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../datasources/product_local_datasource.dart';
import '../models/product_model.dart';
import '../models/brand_model.dart';
import '../models/review_model.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;
  final ProductLocalDataSource _localDataSource;

  ProductRepositoryImpl({
    required ProductRemoteDataSource remoteDataSource,
    required ProductLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<Product?> getProductById(String id) async {
    try {
      // Try remote first
      final remoteProduct = await _remoteDataSource.getProductById(id);
      if (remoteProduct != null) {
        return remoteProduct.toEntity();
      }

      // Fallback to local cache
      final localProduct = await _localDataSource.getProductById(id);
      return localProduct?.toEntity();
    } catch (e) {
      print('Error getting product by ID: $e');

      // Try local cache as last resort
      try {
        final localProduct = await _localDataSource.getProductById(id);
        return localProduct?.toEntity();
      } catch (e) {
        print('Error getting product from local cache: $e');
        return null;
      }
    }
  }

  @override
  Future<ProductSearchResult> getProducts(ProductFilter filter) async {
    try {
      // Try remote first
      final result = await _remoteDataSource.getProducts(filter);

      // Cache the results
      if (result.products.isNotEmpty) {
        final productModels = result.products
            .map((p) => ProductModel.fromEntity(p))
            .toList();
        await _localDataSource.cacheProducts(productModels);
      }

      return result;
    } catch (e) {
      print('Error getting products from remote: $e');

      // Fallback to local cache
      try {
        final localProducts = await _localDataSource.getProducts();
        return _filterLocalProducts(localProducts, filter);
      } catch (e) {
        print('Error getting products from local cache: $e');
        return const ProductSearchResult(
          products: [],
          totalCount: 0,
          currentPage: 1,
          totalPages: 0,
          hasNextPage: false,
          hasPreviousPage: false,
        );
      }
    }
  }

  ProductSearchResult _filterLocalProducts(
    List<ProductModel> products,
    ProductFilter filter,
  ) {
    var filteredProducts = products.map((p) => p.toEntity()).toList();

    // Apply search filter
    if (filter.hasSearch) {
      final query = filter.searchQuery!.toLowerCase();
      filteredProducts = filteredProducts
          .where(
            (p) =>
                p.name.toLowerCase().contains(query) ||
                p.description.toLowerCase().contains(query) ||
                p.brandName.toLowerCase().contains(query) ||
                p.tags.any((tag) => tag.toLowerCase().contains(query)),
          )
          .toList();
    }

    // Apply category filter
    if (filter.categoryIds.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((p) => filter.categoryIds.contains(p.categoryId))
          .toList();
    }

    // Apply brand filter
    if (filter.brandIds.isNotEmpty) {
      filteredProducts = filteredProducts
          .where((p) => filter.brandIds.contains(p.brandId))
          .toList();
    }

    // Apply price range filter
    if (filter.priceRange.hasRange) {
      filteredProducts = filteredProducts.where((p) {
        if (filter.priceRange.minPrice != null &&
            p.price < filter.priceRange.minPrice!) {
          return false;
        }
        if (filter.priceRange.maxPrice != null &&
            p.price > filter.priceRange.maxPrice!) {
          return false;
        }
        return true;
      }).toList();
    }

    // Apply rating filter
    if (filter.minRating != null) {
      filteredProducts = filteredProducts
          .where((p) => p.rating >= filter.minRating!)
          .toList();
    }

    // Apply featured filter
    if (filter.isFeatured != null) {
      filteredProducts = filteredProducts
          .where((p) => p.isFeatured == filter.isFeatured)
          .toList();
    }

    // Apply sale filter
    if (filter.isOnSale != null) {
      filteredProducts = filteredProducts
          .where((p) => p.isOnSale == filter.isOnSale)
          .toList();
    }

    // Apply availability filter
    switch (filter.availability) {
      case ProductAvailability.inStock:
        filteredProducts = filteredProducts.where((p) => p.isInStock).toList();
        break;
      case ProductAvailability.outOfStock:
        filteredProducts = filteredProducts
            .where((p) => p.isOutOfStock)
            .toList();
        break;
      case ProductAvailability.lowStock:
        filteredProducts = filteredProducts.where((p) => p.isLowStock).toList();
        break;
      case ProductAvailability.all:
        break;
    }

    // Apply sorting
    switch (filter.sortBy) {
      case SortOption.priceAsc:
        filteredProducts.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        filteredProducts.sort((a, b) => b.price.compareTo(a.price));
        break;
      case SortOption.ratingDesc:
        filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.newest:
        filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case SortOption.nameAsc:
        filteredProducts.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        filteredProducts.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.popular:
        filteredProducts.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
        break;
      case SortOption.relevance:
      default:
        // Keep original order for relevance
        break;
    }

    final totalCount = filteredProducts.length;
    final totalPages = (totalCount / filter.limit).ceil();

    // Apply pagination
    final startIndex = (filter.page - 1) * filter.limit;
    final endIndex = (startIndex + filter.limit).clamp(0, totalCount);
    final paginatedProducts = filteredProducts.sublist(
      startIndex.clamp(0, totalCount),
      endIndex,
    );

    return ProductSearchResult(
      products: paginatedProducts,
      totalCount: totalCount,
      currentPage: filter.page,
      totalPages: totalPages,
      hasNextPage: filter.page < totalPages,
      hasPreviousPage: filter.page > 1,
    );
  }

  @override
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      final remoteProducts = await _remoteDataSource.getFeaturedProducts(
        limit: limit,
      );
      final products = remoteProducts.map((p) => p.toEntity()).toList();

      // Cache the results
      await _localDataSource.cacheProducts(remoteProducts);

      return products;
    } catch (e) {
      print('Error getting featured products from remote: $e');

      // Fallback to local cache
      final localProducts = await _localDataSource.getFeaturedProducts();
      return localProducts.take(limit).map((p) => p.toEntity()).toList();
    }
  }

  @override
  Future<List<Product>> getPopularProducts({int limit = 10}) async {
    try {
      final remoteProducts = await _remoteDataSource.getPopularProducts(
        limit: limit,
      );
      final products = remoteProducts.map((p) => p.toEntity()).toList();

      // Cache the results
      await _localDataSource.cacheProducts(remoteProducts);

      return products;
    } catch (e) {
      print('Error getting popular products from remote: $e');

      // Fallback to local cache
      final localProducts = await _localDataSource.getPopularProducts();
      return localProducts.take(limit).map((p) => p.toEntity()).toList();
    }
  }

  @override
  Future<List<Product>> getNewProducts({int limit = 10}) async {
    try {
      final remoteProducts = await _remoteDataSource.getNewProducts(
        limit: limit,
      );
      final products = remoteProducts.map((p) => p.toEntity()).toList();

      // Cache the results
      await _localDataSource.cacheProducts(remoteProducts);

      return products;
    } catch (e) {
      print('Error getting new products from remote: $e');

      // Fallback to local cache
      final localProducts = await _localDataSource.getNewProducts();
      return localProducts.take(limit).map((p) => p.toEntity()).toList();
    }
  }

  @override
  Future<List<Product>> getSaleProducts({int limit = 10}) async {
    try {
      final remoteProducts = await _remoteDataSource.getSaleProducts(
        limit: limit,
      );
      final products = remoteProducts.map((p) => p.toEntity()).toList();

      // Cache the results
      await _localDataSource.cacheProducts(remoteProducts);

      return products;
    } catch (e) {
      print('Error getting sale products from remote: $e');

      // Fallback to local cache
      final localProducts = await _localDataSource.getSaleProducts();
      return localProducts.take(limit).map((p) => p.toEntity()).toList();
    }
  }

  @override
  Future<ProductSearchResult> getProductsByCategory(
    String categoryId, {
    ProductFilter? filter,
  }) async {
    final categoryFilter = (filter ?? const ProductFilter()).copyWith(
      categoryIds: [categoryId],
    );
    return getProducts(categoryFilter);
  }

  @override
  Future<List<Product>> getRelatedProducts(
    String productId, {
    int limit = 5,
  }) async {
    try {
      final remoteProducts = await _remoteDataSource.getRelatedProducts(
        productId,
        limit: limit,
      );
      return remoteProducts.map((p) => p.toEntity()).toList();
    } catch (e) {
      print('Error getting related products: $e');

      // Simple fallback - get products from same category
      final product = await getProductById(productId);
      if (product != null) {
        final categoryProducts = await getProductsByCategory(
          product.categoryId,
        );
        return categoryProducts.products
            .where((p) => p.id != productId)
            .take(limit)
            .toList();
      }

      return [];
    }
  }

  @override
  Future<List<Product>> getFrequentlyBoughtTogether(
    String productId, {
    int limit = 3,
  }) async {
    try {
      final remoteProducts = await _remoteDataSource
          .getFrequentlyBoughtTogether(productId, limit: limit);
      return remoteProducts.map((p) => p.toEntity()).toList();
    } catch (e) {
      print('Error getting frequently bought together: $e');

      // Simple fallback - get popular products from same category
      final product = await getProductById(productId);
      if (product != null) {
        final popularProducts = await getPopularProducts(limit: limit * 2);
        return popularProducts
            .where(
              (p) => p.id != productId && p.categoryId == product.categoryId,
            )
            .take(limit)
            .toList();
      }

      return [];
    }
  }

  @override
  Future<ProductSearchResult> getProductsByBrand(
    String brandId, {
    ProductFilter? filter,
  }) async {
    final brandFilter = (filter ?? const ProductFilter()).copyWith(
      brandIds: [brandId],
    );
    return getProducts(brandFilter);
  }

  @override
  Future<List<Brand>> getBrands() async {
    try {
      final remoteBrands = await _remoteDataSource.getBrands();
      final brands = remoteBrands.map((b) => b.toEntity()).toList();

      // Cache the results
      await _localDataSource.cacheBrands(remoteBrands);

      return brands;
    } catch (e) {
      print('Error getting brands from remote: $e');

      // Fallback to local cache
      final localBrands = await _localDataSource.getBrands();
      return localBrands.map((b) => b.toEntity()).toList();
    }
  }

  @override
  Future<List<Brand>> getFeaturedBrands({int limit = 10}) async {
    try {
      final remoteBrands = await _remoteDataSource.getFeaturedBrands(
        limit: limit,
      );
      return remoteBrands.map((b) => b.toEntity()).toList();
    } catch (e) {
      print('Error getting featured brands from remote: $e');

      // Fallback to local cache
      final localBrands = await _localDataSource.getBrands();
      return localBrands
          .where((b) => b.isFeatured)
          .take(limit)
          .map((b) => b.toEntity())
          .toList();
    }
  }

  @override
  Future<Brand?> getBrandById(String id) async {
    try {
      final remoteBrand = await _remoteDataSource.getBrandById(id);
      return remoteBrand?.toEntity();
    } catch (e) {
      print('Error getting brand by ID from remote: $e');

      // Fallback to local cache
      final localBrand = await _localDataSource.getBrandById(id);
      return localBrand?.toEntity();
    }
  }

  @override
  Future<ProductSearchResult> searchProducts(
    String query, {
    ProductFilter? filter,
  }) async {
    // Track search
    await trackProductSearch(query);
    await _localDataSource.addToSearchHistory(query);

    final searchFilter = (filter ?? const ProductFilter()).copyWith(
      searchQuery: query,
    );
    return getProducts(searchFilter);
  }

  @override
  Future<List<String>> getSearchSuggestions(
    String query, {
    int limit = 5,
  }) async {
    try {
      return await _remoteDataSource.getSearchSuggestions(query, limit: limit);
    } catch (e) {
      print('Error getting search suggestions: $e');

      // Fallback to search history
      final searchHistory = await _localDataSource.getSearchHistory();
      return searchHistory
          .where((s) => s.toLowerCase().contains(query.toLowerCase()))
          .take(limit)
          .toList();
    }
  }

  @override
  Future<List<Product>> getSearchHistory({int limit = 10}) async {
    // This would typically return products from search history
    // For now, return recently viewed products
    return [];
  }

  @override
  Future<List<Review>> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final remoteReviews = await _remoteDataSource.getProductReviews(
        productId,
        page: page,
        limit: limit,
      );

      // Cache the results
      await _localDataSource.cacheReviews(remoteReviews);

      return remoteReviews.map((r) => r.toEntity()).toList();
    } catch (e) {
      print('Error getting product reviews from remote: $e');

      // Fallback to local cache
      final localReviews = await _localDataSource.getProductReviews(productId);
      final startIndex = (page - 1) * limit;
      final endIndex = (startIndex + limit).clamp(0, localReviews.length);

      return localReviews
          .sublist(startIndex.clamp(0, localReviews.length), endIndex)
          .map((r) => r.toEntity())
          .toList();
    }
  }

  @override
  Future<Review?> getReviewById(String id) async {
    try {
      final remoteReview = await _remoteDataSource.getReviewById(id);
      return remoteReview?.toEntity();
    } catch (e) {
      print('Error getting review by ID from remote: $e');

      // Fallback to local cache
      final localReview = await _localDataSource.getReviewById(id);
      return localReview?.toEntity();
    }
  }

  @override
  Future<Review> createReview(Review review) async {
    final reviewModel = ReviewModel.fromEntity(review);
    final createdReview = await _remoteDataSource.createReview(reviewModel);
    return createdReview.toEntity();
  }

  @override
  Future<Review> updateReview(Review review) async {
    final reviewModel = ReviewModel.fromEntity(review);
    final updatedReview = await _remoteDataSource.updateReview(reviewModel);
    return updatedReview.toEntity();
  }

  @override
  Future<void> deleteReview(String id) async {
    await _remoteDataSource.deleteReview(id);
  }

  @override
  Future<void> markReviewHelpful(String reviewId, bool isHelpful) async {
    await _remoteDataSource.markReviewHelpful(reviewId, isHelpful);
  }

  @override
  Future<bool> isProductInStock(String productId) async {
    try {
      return await _remoteDataSource.isProductInStock(productId);
    } catch (e) {
      print('Error checking product stock: $e');

      // Fallback to local cache
      final product = await _localDataSource.getProductById(productId);
      return product?.isInStock ?? false;
    }
  }

  @override
  Future<int> getProductStock(String productId) async {
    try {
      return await _remoteDataSource.getProductStock(productId);
    } catch (e) {
      print('Error getting product stock: $e');

      // Fallback to local cache
      final product = await _localDataSource.getProductById(productId);
      return product?.stockQuantity ?? 0;
    }
  }

  @override
  Future<List<Product>> getLowStockProducts({int limit = 20}) async {
    try {
      final remoteProducts = await _remoteDataSource.getLowStockProducts(
        limit: limit,
      );
      return remoteProducts.map((p) => p.toEntity()).toList();
    } catch (e) {
      print('Error getting low stock products: $e');

      // Fallback to local cache
      final localProducts = await _localDataSource.getProducts();
      return localProducts
          .where((p) => p.isLowStock)
          .take(limit)
          .map((p) => p.toEntity())
          .toList();
    }
  }

  @override
  Future<List<Product>> getOutOfStockProducts({int limit = 20}) async {
    try {
      final remoteProducts = await _remoteDataSource.getOutOfStockProducts(
        limit: limit,
      );
      return remoteProducts.map((p) => p.toEntity()).toList();
    } catch (e) {
      print('Error getting out of stock products: $e');

      // Fallback to local cache
      final localProducts = await _localDataSource.getProducts();
      return localProducts
          .where((p) => p.isOutOfStock)
          .take(limit)
          .map((p) => p.toEntity())
          .toList();
    }
  }

  @override
  Future<List<Product>> getProductsForVehicle(
    String vehicleModel, {
    ProductFilter? filter,
  }) async {
    try {
      final remoteProducts = await _remoteDataSource.getProductsForVehicle(
        vehicleModel,
        filter: filter,
      );
      return remoteProducts.map((p) => p.toEntity()).toList();
    } catch (e) {
      print('Error getting products for vehicle: $e');

      // Fallback to local cache
      final localProducts = await _localDataSource.getProducts();
      return localProducts
          .where((p) => p.compatibleVehicles.contains(vehicleModel))
          .map((p) => p.toEntity())
          .toList();
    }
  }

  @override
  Future<List<String>> getCompatibleVehicles(String productId) async {
    try {
      return await _remoteDataSource.getCompatibleVehicles(productId);
    } catch (e) {
      print('Error getting compatible vehicles: $e');

      // Fallback to local cache
      final product = await _localDataSource.getProductById(productId);
      return product?.compatibleVehicles ?? [];
    }
  }

  @override
  Future<ProductSearchResult> getProductsInPriceRange(
    double minPrice,
    double maxPrice, {
    ProductFilter? filter,
  }) async {
    final priceFilter = (filter ?? const ProductFilter()).copyWith(
      priceRange: PriceRange(minPrice: minPrice, maxPrice: maxPrice),
    );
    return getProducts(priceFilter);
  }

  @override
  Future<List<Product>> getProductsOnSale({
    ProductFilter? filter,
    int limit = 20,
  }) async {
    final saleFilter = (filter ?? const ProductFilter()).copyWith(
      isOnSale: true,
      limit: limit,
    );
    final result = await getProducts(saleFilter);
    return result.products;
  }

  @override
  Future<void> trackProductView(String productId) async {
    await _remoteDataSource.trackProductView(productId);
  }

  @override
  Future<void> trackProductSearch(String query) async {
    await _remoteDataSource.trackProductSearch(query);
  }

  @override
  Future<void> trackCategoryView(String categoryId) async {
    await _remoteDataSource.trackCategoryView(categoryId);
  }

  @override
  Future<void> trackBrandView(String brandId) async {
    await _remoteDataSource.trackBrandView(brandId);
  }

  @override
  Future<List<Product>> getWishlistProducts(String userId) async {
    final localProducts = await _localDataSource.getWishlistProducts(userId);
    return localProducts.map((p) => p.toEntity()).toList();
  }

  @override
  Future<void> addToWishlist(String userId, String productId) async {
    await _localDataSource.addToWishlist(userId, productId);
  }

  @override
  Future<void> removeFromWishlist(String userId, String productId) async {
    await _localDataSource.removeFromWishlist(userId, productId);
  }

  @override
  Future<bool> isInWishlist(String userId, String productId) async {
    final wishlistProducts = await _localDataSource.getWishlistProducts(userId);
    return wishlistProducts.any((p) => p.id == productId);
  }

  @override
  Future<List<Product>> getRecentlyViewedProducts(
    String userId, {
    int limit = 10,
  }) async {
    final localProducts = await _localDataSource.getRecentlyViewedProducts(
      userId,
    );
    return localProducts.take(limit).map((p) => p.toEntity()).toList();
  }

  @override
  Future<void> addToRecentlyViewed(String userId, String productId) async {
    await _localDataSource.addToRecentlyViewed(userId, productId);
  }

  @override
  Future<void> refreshProductCache() async {
    // Clear cache and fetch fresh data
    await _localDataSource.clearCache();

    // Fetch fresh data
    const filter = ProductFilter(limit: 100); // Get first 100 products
    await getProducts(filter);
    await getBrands();
  }

  @override
  Future<void> clearProductCache() async {
    await _localDataSource.clearCache();
  }

  @override
  Future<bool> isProductCacheValid() async {
    return await _localDataSource.isCacheValid();
  }

  @override
  Future<List<Product>> getProductsByIds(List<String> productIds) async {
    try {
      final remoteProducts = await _remoteDataSource.getProductsByIds(
        productIds,
      );
      return remoteProducts.map((p) => p.toEntity()).toList();
    } catch (e) {
      print('Error getting products by IDs: $e');

      // Fallback to local cache
      final products = <Product>[];
      for (final id in productIds) {
        final product = await _localDataSource.getProductById(id);
        if (product != null) {
          products.add(product.toEntity());
        }
      }
      return products;
    }
  }

  @override
  Future<Map<String, bool>> checkProductsAvailability(
    List<String> productIds,
  ) async {
    try {
      return await _remoteDataSource.checkProductsAvailability(productIds);
    } catch (e) {
      print('Error checking products availability: $e');

      // Fallback to local cache
      final availability = <String, bool>{};
      for (final id in productIds) {
        final product = await _localDataSource.getProductById(id);
        availability[id] = product?.isInStock ?? false;
      }
      return availability;
    }
  }

  @override
  Future<Map<String, int>> getProductsStock(List<String> productIds) async {
    try {
      return await _remoteDataSource.getProductsStock(productIds);
    } catch (e) {
      print('Error getting products stock: $e');

      // Fallback to local cache
      final stock = <String, int>{};
      for (final id in productIds) {
        final product = await _localDataSource.getProductById(id);
        stock[id] = product?.stockQuantity ?? 0;
      }
      return stock;
    }
  }
}
