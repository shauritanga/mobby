import '../../domain/entities/banner.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/quick_action.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_remote_datasource.dart';
import '../datasources/home_local_datasource.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;
  final HomeLocalDataSource _localDataSource;

  HomeRepositoryImpl({
    required HomeRemoteDataSource remoteDataSource,
    required HomeLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  @override
  Future<List<Banner>> getBanners() async {
    try {
      // Try to get from remote first
      final remoteBanners = await _remoteDataSource.getBanners();
      final banners = remoteBanners.map((model) => model.toEntity()).toList();

      // Cache the results
      await _localDataSource.cacheBanners(remoteBanners);

      return banners;
    } catch (e) {
      // Fallback to local cache
      final cachedBanners = await _localDataSource.getCachedBanners();
      return cachedBanners.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<List<Banner>> getActiveBanners() async {
    try {
      // Try to get from remote first
      final remoteBanners = await _remoteDataSource.getActiveBanners();
      return remoteBanners.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Fallback to local cache and filter active ones
      final cachedBanners = await _localDataSource.getCachedBanners();
      final now = DateTime.now();
      return cachedBanners
          .where(
            (banner) =>
                banner.isActive &&
                (banner.expiresAt == null || banner.expiresAt!.isAfter(now)),
          )
          .map((model) => model.toEntity())
          .toList();
    }
  }

  @override
  Future<Banner?> getBannerById(String id) async {
    try {
      final remoteBanner = await _remoteDataSource.getBannerById(id);
      return remoteBanner?.toEntity();
    } catch (e) {
      // Fallback to local cache
      final cachedBanners = await _localDataSource.getCachedBanners();
      final banner = cachedBanners.where((b) => b.id == id).firstOrNull;
      return banner?.toEntity();
    }
  }

  @override
  Future<List<Product>> getFeaturedProducts({int limit = 10}) async {
    try {
      // Try to get from remote first
      print('Fetching featured products from remote...');
      final remoteProducts = await _remoteDataSource.getFeaturedProducts(
        limit: limit,
      );
      final products = remoteProducts.map((model) => model.toEntity()).toList();

      print('Found ${products.length} featured products from remote');

      // Cache the results
      await _localDataSource.cacheFeaturedProducts(remoteProducts);

      return products;
    } catch (e) {
      print('Error fetching featured products from remote: $e');
      // Fallback to local cache
      final cachedProducts = await _localDataSource.getCachedFeaturedProducts();
      print('Found ${cachedProducts.length} featured products from cache');
      return cachedProducts
          .take(limit)
          .map((model) => model.toEntity())
          .toList();
    }
  }

  @override
  Future<List<Product>> getProductsByCategory(
    String categoryId, {
    int limit = 10,
  }) async {
    try {
      final remoteProducts = await _remoteDataSource.getProductsByCategory(
        categoryId,
        limit: limit,
      );
      return remoteProducts.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Fallback to local cache and filter by category
      final cachedProducts = await _localDataSource.getCachedFeaturedProducts();
      return cachedProducts
          .where((product) => product.categoryId == categoryId)
          .take(limit)
          .map((model) => model.toEntity())
          .toList();
    }
  }

  @override
  Future<Product?> getProductById(String id) async {
    try {
      final remoteProduct = await _remoteDataSource.getProductById(id);
      return remoteProduct?.toEntity();
    } catch (e) {
      // Fallback to local cache
      final cachedProducts = await _localDataSource.getCachedFeaturedProducts();
      final product = cachedProducts.where((p) => p.id == id).firstOrNull;
      return product?.toEntity();
    }
  }

  @override
  Future<List<Category>> getCategories() async {
    try {
      // Try to get from remote first
      final remoteCategories = await _remoteDataSource.getCategories();
      final categories = remoteCategories
          .map((model) => model.toEntity())
          .toList();

      // Cache the results
      await _localDataSource.cacheCategories(remoteCategories);

      return categories;
    } catch (e) {
      // Fallback to local cache
      final cachedCategories = await _localDataSource.getCachedCategories();
      return cachedCategories.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<List<Category>> getActiveCategories() async {
    try {
      print('Fetching active categories from remote...');
      final remoteCategories = await _remoteDataSource.getActiveCategories();
      print('Found ${remoteCategories.length} active categories from remote');
      return remoteCategories.map((model) => model.toEntity()).toList();
    } catch (e) {
      print('Error fetching active categories from remote: $e');
      // Fallback to local cache and filter active ones
      final cachedCategories = await _localDataSource.getCachedCategories();
      final activeCategories = cachedCategories
          .where((category) => category.isActive)
          .map((model) => model.toEntity())
          .toList();
      print('Found ${activeCategories.length} active categories from cache');
      return activeCategories;
    }
  }

  @override
  Future<List<Category>> getParentCategories() async {
    try {
      final remoteCategories = await _remoteDataSource.getParentCategories();
      return remoteCategories.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Fallback to local cache and filter parent categories
      final cachedCategories = await _localDataSource.getCachedCategories();
      return cachedCategories
          .where((category) => category.isActive && category.parentId == null)
          .map((model) => model.toEntity())
          .toList();
    }
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    try {
      final remoteCategory = await _remoteDataSource.getCategoryById(id);
      return remoteCategory?.toEntity();
    } catch (e) {
      // Fallback to local cache
      final cachedCategories = await _localDataSource.getCachedCategories();
      final category = cachedCategories.where((c) => c.id == id).firstOrNull;
      return category?.toEntity();
    }
  }

  @override
  Future<List<QuickAction>> getQuickActions() async {
    try {
      // Try to get from remote first
      final remoteActions = await _remoteDataSource.getQuickActions();
      final actions = remoteActions.map((model) => model.toEntity()).toList();

      // Cache the results
      await _localDataSource.cacheQuickActions(remoteActions);

      return actions;
    } catch (e) {
      // Fallback to local cache
      final cachedActions = await _localDataSource.getCachedQuickActions();
      return cachedActions.map((model) => model.toEntity()).toList();
    }
  }

  @override
  Future<List<QuickAction>> getActiveQuickActions() async {
    try {
      final remoteActions = await _remoteDataSource.getActiveQuickActions();
      return remoteActions.map((model) => model.toEntity()).toList();
    } catch (e) {
      // Fallback to local cache and filter active ones
      final cachedActions = await _localDataSource.getCachedQuickActions();
      return cachedActions
          .where((action) => action.isActive)
          .map((model) => model.toEntity())
          .toList();
    }
  }

  @override
  Future<QuickAction?> getQuickActionById(String id) async {
    try {
      final remoteAction = await _remoteDataSource.getQuickActionById(id);
      return remoteAction?.toEntity();
    } catch (e) {
      // Fallback to local cache
      final cachedActions = await _localDataSource.getCachedQuickActions();
      final action = cachedActions.where((a) => a.id == id).firstOrNull;
      return action?.toEntity();
    }
  }

  @override
  Future<void> trackBannerClick(String bannerId) async {
    try {
      await _remoteDataSource.trackBannerClick(bannerId);
    } catch (e) {
      // Analytics failures shouldn't break the app
      // Could implement local analytics queue here
    }
  }

  @override
  Future<void> trackProductView(String productId) async {
    try {
      await _remoteDataSource.trackProductView(productId);
    } catch (e) {
      // Analytics failures shouldn't break the app
    }
  }

  @override
  Future<void> trackCategoryView(String categoryId) async {
    try {
      await _remoteDataSource.trackCategoryView(categoryId);
    } catch (e) {
      // Analytics failures shouldn't break the app
    }
  }

  @override
  Future<void> trackQuickActionClick(String actionId) async {
    try {
      await _remoteDataSource.trackQuickActionClick(actionId);
    } catch (e) {
      // Analytics failures shouldn't break the app
    }
  }

  @override
  Future<void> refreshCache() async {
    try {
      // Clear existing cache
      await _localDataSource.clearCache();

      // Fetch fresh data and cache it
      await Future.wait([
        getBanners(),
        getFeaturedProducts(),
        getCategories(),
        getQuickActions(),
      ]);
    } catch (e) {
      throw Exception('Failed to refresh cache: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    await _localDataSource.clearCache();
  }
}
