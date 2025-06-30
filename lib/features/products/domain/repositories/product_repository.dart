import '../entities/product.dart';
import '../entities/product_search_result.dart';
import '../entities/brand.dart';
import '../entities/review.dart';
import '../entities/product_filter.dart';

abstract class ProductRepository {
  // Product CRUD operations
  Future<Product?> getProductById(String id);
  Future<ProductSearchResult> getProducts(ProductFilter filter);
  Future<List<Product>> getFeaturedProducts({int limit = 10});
  Future<List<Product>> getPopularProducts({int limit = 10});
  Future<List<Product>> getNewProducts({int limit = 10});
  Future<List<Product>> getSaleProducts({int limit = 10});

  // Category-based queries
  Future<ProductSearchResult> getProductsByCategory(
    String categoryId, {
    ProductFilter? filter,
  });
  Future<List<Product>> getRelatedProducts(String productId, {int limit = 5});
  Future<List<Product>> getFrequentlyBoughtTogether(
    String productId, {
    int limit = 3,
  });

  // Brand-based queries
  Future<ProductSearchResult> getProductsByBrand(
    String brandId, {
    ProductFilter? filter,
  });
  Future<List<Brand>> getBrands();
  Future<List<Brand>> getFeaturedBrands({int limit = 10});
  Future<Brand?> getBrandById(String id);

  // Search functionality
  Future<ProductSearchResult> searchProducts(
    String query, {
    ProductFilter? filter,
  });
  Future<List<String>> getSearchSuggestions(String query, {int limit = 5});
  Future<List<Product>> getSearchHistory({int limit = 10});

  // Review operations
  Future<List<Review>> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 20,
  });
  Future<Review?> getReviewById(String id);
  Future<Review> createReview(Review review);
  Future<Review> updateReview(Review review);
  Future<void> deleteReview(String id);
  Future<void> markReviewHelpful(String reviewId, bool isHelpful);

  // Inventory operations
  Future<bool> isProductInStock(String productId);
  Future<int> getProductStock(String productId);
  Future<List<Product>> getLowStockProducts({int limit = 20});
  Future<List<Product>> getOutOfStockProducts({int limit = 20});

  // Vehicle compatibility
  Future<List<Product>> getProductsForVehicle(
    String vehicleModel, {
    ProductFilter? filter,
  });
  Future<List<String>> getCompatibleVehicles(String productId);

  // Price operations
  Future<ProductSearchResult> getProductsInPriceRange(
    double minPrice,
    double maxPrice, {
    ProductFilter? filter,
  });
  Future<List<Product>> getProductsOnSale({
    ProductFilter? filter,
    int limit = 20,
  });

  // Analytics and tracking
  Future<void> trackProductView(String productId);
  Future<void> trackProductSearch(String query);
  Future<void> trackCategoryView(String categoryId);
  Future<void> trackBrandView(String brandId);

  // Wishlist operations
  Future<List<Product>> getWishlistProducts(String userId);
  Future<void> addToWishlist(String userId, String productId);
  Future<void> removeFromWishlist(String userId, String productId);
  Future<bool> isInWishlist(String userId, String productId);

  // Recently viewed
  Future<List<Product>> getRecentlyViewedProducts(
    String userId, {
    int limit = 10,
  });
  Future<void> addToRecentlyViewed(String userId, String productId);

  // Cache management
  Future<void> refreshProductCache();
  Future<void> clearProductCache();
  Future<bool> isProductCacheValid();

  // Bulk operations
  Future<List<Product>> getProductsByIds(List<String> productIds);
  Future<Map<String, bool>> checkProductsAvailability(List<String> productIds);
  Future<Map<String, int>> getProductsStock(List<String> productIds);
}
