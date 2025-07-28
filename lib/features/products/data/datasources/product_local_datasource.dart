import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product_model.dart';
import '../models/brand_model.dart';
import '../models/review_model.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product.dart';

abstract class ProductLocalDataSource {
  Future<ProductModel?> getProductById(String id);
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> getFeaturedProducts();
  Future<List<ProductModel>> getPopularProducts();
  Future<List<ProductModel>> getNewProducts();
  Future<List<ProductModel>> getSaleProducts();

  Future<List<BrandModel>> getBrands();
  Future<BrandModel?> getBrandById(String id);

  Future<List<ReviewModel>> getProductReviews(String productId);
  Future<ReviewModel?> getReviewById(String id);

  Future<List<String>> getSearchHistory();
  Future<List<ProductModel>> getRecentlyViewedProducts(String userId);
  Future<List<ProductModel>> getWishlistProducts(String userId);

  Future<void> cacheProducts(List<ProductModel> products);
  Future<void> cacheBrands(List<BrandModel> brands);
  Future<void> cacheReviews(List<ReviewModel> reviews);
  Future<void> addToSearchHistory(String query);
  Future<void> addToRecentlyViewed(String userId, String productId);
  Future<void> addToWishlist(String userId, String productId);
  Future<void> removeFromWishlist(String userId, String productId);

  Future<void> clearCache();
  Future<bool> isCacheValid();
  Future<DateTime?> getLastCacheTime();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final SharedPreferences _prefs;

  // Cache keys
  static const String _productsKey = 'cached_products';
  static const String _brandsKey = 'cached_brands';
  static const String _reviewsKey = 'cached_reviews';
  static const String _searchHistoryKey = 'search_history';
  static const String _recentlyViewedKey = 'recently_viewed';
  static const String _wishlistKey = 'wishlist';
  static const String _cacheTimeKey = 'cache_time';

  // Cache duration (1 hour)
  static const Duration _cacheDuration = Duration(hours: 1);

  ProductLocalDataSourceImpl({required SharedPreferences prefs})
    : _prefs = prefs;

  @override
  Future<ProductModel?> getProductById(String id) async {
    try {
      final products = await getProducts();
      return products.firstWhere(
        (product) => product.id == id,
        orElse: () => throw Exception('Product not found'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    try {
      final productsJson = _prefs.getString(_productsKey);
      if (productsJson == null) return [];

      final List<dynamic> productsList = json.decode(productsJson);
      return productsList
          .map((json) => ProductModel.fromMap(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting cached products: $e');
      return [];
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    final products = await getProducts();
    return products.where((p) => p.isFeatured && p.isActive).toList();
  }

  @override
  Future<List<ProductModel>> getPopularProducts() async {
    final products = await getProducts();
    final popularProducts = products.where((p) => p.isActive).toList()
      ..sort((a, b) {
        final aScore = a.reviewCount * a.rating;
        final bScore = b.reviewCount * b.rating;
        return bScore.compareTo(aScore);
      });
    return popularProducts;
  }

  @override
  Future<List<ProductModel>> getNewProducts() async {
    final products = await getProducts();
    final newProducts = products.where((p) => p.isActive).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return newProducts;
  }

  @override
  Future<List<ProductModel>> getSaleProducts() async {
    final products = await getProducts();
    return products.where((p) => p.isActive && p.isOnSale).toList();
  }

  @override
  Future<List<BrandModel>> getBrands() async {
    try {
      final brandsJson = _prefs.getString(_brandsKey);
      if (brandsJson == null) return [];

      final List<dynamic> brandsList = json.decode(brandsJson);
      return brandsList
          .map((json) => BrandModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting cached brands: $e');
      return [];
    }
  }

  @override
  Future<BrandModel?> getBrandById(String id) async {
    try {
      final brands = await getBrands();
      return brands.firstWhere(
        (brand) => brand.id == id,
        orElse: () => throw Exception('Brand not found'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<ReviewModel>> getProductReviews(String productId) async {
    try {
      final reviewsJson = _prefs.getString(_reviewsKey);
      if (reviewsJson == null) return [];

      final List<dynamic> reviewsList = json.decode(reviewsJson);
      final allReviews = reviewsList
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return allReviews.where((r) => r.productId == productId).toList();
    } catch (e) {
      print('Error getting cached reviews: $e');
      return [];
    }
  }

  @override
  Future<ReviewModel?> getReviewById(String id) async {
    try {
      final reviewsJson = _prefs.getString(_reviewsKey);
      if (reviewsJson == null) return null;

      final List<dynamic> reviewsList = json.decode(reviewsJson);
      final allReviews = reviewsList
          .map((json) => ReviewModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return allReviews.firstWhere(
        (review) => review.id == id,
        orElse: () => throw Exception('Review not found'),
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<String>> getSearchHistory() async {
    try {
      final searchHistory = _prefs.getStringList(_searchHistoryKey) ?? [];
      return searchHistory.reversed.take(10).toList(); // Last 10 searches
    } catch (e) {
      print('Error getting search history: $e');
      return [];
    }
  }

  @override
  Future<List<ProductModel>> getRecentlyViewedProducts(String userId) async {
    try {
      final recentlyViewedJson = _prefs.getString(
        '${_recentlyViewedKey}_$userId',
      );
      if (recentlyViewedJson == null) return [];

      final List<dynamic> productIds = json.decode(recentlyViewedJson);
      final products = await getProducts();

      final recentlyViewed = <ProductModel>[];
      for (final id in productIds) {
        try {
          final product = products.firstWhere((p) => p.id == id);
          recentlyViewed.add(product);
        } catch (e) {
          // Product not found in cache, skip
        }
      }

      return recentlyViewed;
    } catch (e) {
      print('Error getting recently viewed products: $e');
      return [];
    }
  }

  @override
  Future<List<ProductModel>> getWishlistProducts(String userId) async {
    try {
      final wishlistJson = _prefs.getString('${_wishlistKey}_$userId');
      if (wishlistJson == null) return [];

      final List<dynamic> productIds = json.decode(wishlistJson);
      final products = await getProducts();

      final wishlistProducts = <ProductModel>[];
      for (final id in productIds) {
        try {
          final product = products.firstWhere((p) => p.id == id);
          wishlistProducts.add(product);
        } catch (e) {
          // Product not found in cache, skip
        }
      }

      return wishlistProducts;
    } catch (e) {
      print('Error getting wishlist products: $e');
      return [];
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      final productsJson = json.encode(
        products.map((product) => product.toMap()).toList(),
      );
      await _prefs.setString(_productsKey, productsJson);
      await _prefs.setInt(_cacheTimeKey, DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching products: $e');
    }
  }

  @override
  Future<void> cacheBrands(List<BrandModel> brands) async {
    try {
      final brandsJson = json.encode(
        brands.map((brand) => brand.toJson()).toList(),
      );
      await _prefs.setString(_brandsKey, brandsJson);
    } catch (e) {
      print('Error caching brands: $e');
    }
  }

  @override
  Future<void> cacheReviews(List<ReviewModel> reviews) async {
    try {
      final reviewsJson = json.encode(
        reviews.map((review) => review.toJson()).toList(),
      );
      await _prefs.setString(_reviewsKey, reviewsJson);
    } catch (e) {
      print('Error caching reviews: $e');
    }
  }

  @override
  Future<void> addToSearchHistory(String query) async {
    try {
      final searchHistory = _prefs.getStringList(_searchHistoryKey) ?? [];

      // Remove if already exists to avoid duplicates
      searchHistory.remove(query);

      // Add to beginning
      searchHistory.insert(0, query);

      // Keep only last 20 searches
      if (searchHistory.length > 20) {
        searchHistory.removeRange(20, searchHistory.length);
      }

      await _prefs.setStringList(_searchHistoryKey, searchHistory);
    } catch (e) {
      print('Error adding to search history: $e');
    }
  }

  @override
  Future<void> addToRecentlyViewed(String userId, String productId) async {
    try {
      final key = '${_recentlyViewedKey}_$userId';
      final recentlyViewedJson = _prefs.getString(key);

      List<dynamic> productIds = [];
      if (recentlyViewedJson != null) {
        productIds = json.decode(recentlyViewedJson);
      }

      // Remove if already exists
      productIds.remove(productId);

      // Add to beginning
      productIds.insert(0, productId);

      // Keep only last 20 products
      if (productIds.length > 20) {
        productIds.removeRange(20, productIds.length);
      }

      await _prefs.setString(key, json.encode(productIds));
    } catch (e) {
      print('Error adding to recently viewed: $e');
    }
  }

  @override
  Future<void> addToWishlist(String userId, String productId) async {
    try {
      final key = '${_wishlistKey}_$userId';
      final wishlistJson = _prefs.getString(key);

      List<dynamic> productIds = [];
      if (wishlistJson != null) {
        productIds = json.decode(wishlistJson);
      }

      // Add if not already exists
      if (!productIds.contains(productId)) {
        productIds.add(productId);
        await _prefs.setString(key, json.encode(productIds));
      }
    } catch (e) {
      print('Error adding to wishlist: $e');
    }
  }

  @override
  Future<void> removeFromWishlist(String userId, String productId) async {
    try {
      final key = '${_wishlistKey}_$userId';
      final wishlistJson = _prefs.getString(key);

      if (wishlistJson != null) {
        final List<dynamic> productIds = json.decode(wishlistJson);
        productIds.remove(productId);
        await _prefs.setString(key, json.encode(productIds));
      }
    } catch (e) {
      print('Error removing from wishlist: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await _prefs.remove(_productsKey);
      await _prefs.remove(_brandsKey);
      await _prefs.remove(_reviewsKey);
      await _prefs.remove(_cacheTimeKey);
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  @override
  Future<bool> isCacheValid() async {
    try {
      final cacheTime = await getLastCacheTime();
      if (cacheTime == null) return false;

      final now = DateTime.now();
      final difference = now.difference(cacheTime);

      return difference < _cacheDuration;
    } catch (e) {
      print('Error checking cache validity: $e');
      return false;
    }
  }

  @override
  Future<DateTime?> getLastCacheTime() async {
    try {
      final cacheTimeMs = _prefs.getInt(_cacheTimeKey);
      if (cacheTimeMs == null) return null;

      return DateTime.fromMillisecondsSinceEpoch(cacheTimeMs);
    } catch (e) {
      print('Error getting cache time: $e');
      return null;
    }
  }
}
