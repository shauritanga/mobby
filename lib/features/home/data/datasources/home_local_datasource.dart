import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/banner_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/quick_action_model.dart';
import 'sample_data.dart';

abstract class HomeLocalDataSource {
  Future<List<BannerModel>> getCachedBanners();
  Future<void> cacheBanners(List<BannerModel> banners);
  
  Future<List<ProductModel>> getCachedFeaturedProducts();
  Future<void> cacheFeaturedProducts(List<ProductModel> products);
  
  Future<List<CategoryModel>> getCachedCategories();
  Future<void> cacheCategories(List<CategoryModel> categories);
  
  Future<List<QuickActionModel>> getCachedQuickActions();
  Future<void> cacheQuickActions(List<QuickActionModel> actions);
  
  Future<void> clearCache();
  Future<bool> isCacheValid();
  Future<void> seedSampleData();
}

class HomeLocalDataSourceImpl implements HomeLocalDataSource {
  final SharedPreferences _prefs;
  
  static const String _bannersKey = 'cached_banners';
  static const String _productsKey = 'cached_featured_products';
  static const String _categoriesKey = 'cached_categories';
  static const String _quickActionsKey = 'cached_quick_actions';
  static const String _cacheTimestampKey = 'cache_timestamp';
  static const String _sampleDataSeededKey = 'sample_data_seeded';
  static const Duration _cacheValidDuration = Duration(hours: 1);

  HomeLocalDataSourceImpl({required SharedPreferences prefs}) : _prefs = prefs;

  @override
  Future<List<BannerModel>> getCachedBanners() async {
    try {
      final jsonString = _prefs.getString(_bannersKey);
      if (jsonString == null) {
        // Return sample data if no cache exists
        await seedSampleData();
        return SampleData.banners;
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => BannerModel.fromJson(json)).toList();
    } catch (e) {
      // Return sample data on error
      return SampleData.banners;
    }
  }

  @override
  Future<void> cacheBanners(List<BannerModel> banners) async {
    try {
      final jsonList = banners.map((banner) => banner.toJson()).toList();
      await _prefs.setString(_bannersKey, json.encode(jsonList));
      await _updateCacheTimestamp();
    } catch (e) {
      throw Exception('Failed to cache banners: $e');
    }
  }

  @override
  Future<List<ProductModel>> getCachedFeaturedProducts() async {
    try {
      final jsonString = _prefs.getString(_productsKey);
      if (jsonString == null) {
        // Return sample data if no cache exists
        await seedSampleData();
        return SampleData.featuredProducts;
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      // Return sample data on error
      return SampleData.featuredProducts;
    }
  }

  @override
  Future<void> cacheFeaturedProducts(List<ProductModel> products) async {
    try {
      final jsonList = products.map((product) => product.toJson()).toList();
      await _prefs.setString(_productsKey, json.encode(jsonList));
      await _updateCacheTimestamp();
    } catch (e) {
      throw Exception('Failed to cache featured products: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCachedCategories() async {
    try {
      final jsonString = _prefs.getString(_categoriesKey);
      if (jsonString == null) {
        // Return sample data if no cache exists
        await seedSampleData();
        return SampleData.categories;
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => CategoryModel.fromJson(json)).toList();
    } catch (e) {
      // Return sample data on error
      return SampleData.categories;
    }
  }

  @override
  Future<void> cacheCategories(List<CategoryModel> categories) async {
    try {
      final jsonList = categories.map((category) => category.toJson()).toList();
      await _prefs.setString(_categoriesKey, json.encode(jsonList));
      await _updateCacheTimestamp();
    } catch (e) {
      throw Exception('Failed to cache categories: $e');
    }
  }

  @override
  Future<List<QuickActionModel>> getCachedQuickActions() async {
    try {
      final jsonString = _prefs.getString(_quickActionsKey);
      if (jsonString == null) {
        // Return sample data if no cache exists
        await seedSampleData();
        return SampleData.quickActions;
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList.map((json) => QuickActionModel.fromJson(json)).toList();
    } catch (e) {
      // Return sample data on error
      return SampleData.quickActions;
    }
  }

  @override
  Future<void> cacheQuickActions(List<QuickActionModel> actions) async {
    try {
      final jsonList = actions.map((action) => action.toJson()).toList();
      await _prefs.setString(_quickActionsKey, json.encode(jsonList));
      await _updateCacheTimestamp();
    } catch (e) {
      throw Exception('Failed to cache quick actions: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await Future.wait([
        _prefs.remove(_bannersKey),
        _prefs.remove(_productsKey),
        _prefs.remove(_categoriesKey),
        _prefs.remove(_quickActionsKey),
        _prefs.remove(_cacheTimestampKey),
      ]);
    } catch (e) {
      throw Exception('Failed to clear cache: $e');
    }
  }

  @override
  Future<bool> isCacheValid() async {
    try {
      final timestampString = _prefs.getString(_cacheTimestampKey);
      if (timestampString == null) return false;

      final timestamp = DateTime.parse(timestampString);
      final now = DateTime.now();
      return now.difference(timestamp) < _cacheValidDuration;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> seedSampleData() async {
    try {
      final isSeeded = _prefs.getBool(_sampleDataSeededKey) ?? false;
      if (isSeeded) return;

      // Cache sample data
      await Future.wait([
        cacheBanners(SampleData.banners),
        cacheFeaturedProducts(SampleData.featuredProducts),
        cacheCategories(SampleData.categories),
        cacheQuickActions(SampleData.quickActions),
      ]);

      // Mark as seeded
      await _prefs.setBool(_sampleDataSeededKey, true);
    } catch (e) {
      throw Exception('Failed to seed sample data: $e');
    }
  }

  Future<void> _updateCacheTimestamp() async {
    await _prefs.setString(_cacheTimestampKey, DateTime.now().toIso8601String());
  }
}
