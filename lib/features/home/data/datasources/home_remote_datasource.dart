import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/banner_model.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/quick_action_model.dart';
import 'sample_data.dart';

abstract class HomeRemoteDataSource {
  Future<List<BannerModel>> getBanners();
  Future<List<BannerModel>> getActiveBanners();
  Future<BannerModel?> getBannerById(String id);

  Future<List<ProductModel>> getFeaturedProducts({int limit = 10});
  Future<List<ProductModel>> getProductsByCategory(
    String categoryId, {
    int limit = 10,
  });
  Future<ProductModel?> getProductById(String id);

  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryModel>> getActiveCategories();
  Future<List<CategoryModel>> getParentCategories();
  Future<CategoryModel?> getCategoryById(String id);

  Future<List<QuickActionModel>> getQuickActions();
  Future<List<QuickActionModel>> getActiveQuickActions();
  Future<QuickActionModel?> getQuickActionById(String id);

  Future<void> trackBannerClick(String bannerId);
  Future<void> trackProductView(String productId);
  Future<void> trackCategoryView(String categoryId);
  Future<void> trackQuickActionClick(String actionId);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore _firestore;

  HomeRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<BannerModel>> getBanners() async {
    try {
      final querySnapshot = await _firestore
          .collection('banners')
          .orderBy('priority', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BannerModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch banners: $e');
    }
  }

  @override
  Future<List<BannerModel>> getActiveBanners() async {
    try {
      final now = DateTime.now();
      final querySnapshot = await _firestore
          .collection('banners')
          .where('isActive', isEqualTo: true)
          .where('expiresAt', isGreaterThan: now)
          .orderBy('expiresAt')
          .orderBy('priority', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => BannerModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active banners: $e');
    }
  }

  @override
  Future<BannerModel?> getBannerById(String id) async {
    try {
      final doc = await _firestore.collection('banners').doc(id).get();
      if (!doc.exists) return null;

      return BannerModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch banner: $e');
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    try {
      print('🔍 Fetching featured products from Firestore...');

      // Simplified query to avoid composite index requirements
      final querySnapshot = await _firestore
          .collection('products')
          .where('isFeatured', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .limit(limit * 2) // Get more to filter and sort in app
          .get();

      print('📊 Raw query returned ${querySnapshot.docs.length} documents');

      final products = querySnapshot.docs
          .map((doc) {
            final data = {'id': doc.id, ...doc.data()};
            print('📦 Product data: $data');
            return ProductModel.fromJson(data);
          })
          .where((product) => (product.stockQuantity ?? 0) > 0) // Filter in app
          .toList();

      print('✅ After filtering: ${products.length} products with stock');

      // Sort in application layer
      products.sort((a, b) {
        // First by rating (descending), then by stock quantity (ascending)
        final ratingComparison = (b.rating ?? 0.0).compareTo(a.rating ?? 0.0);
        if (ratingComparison != 0) return ratingComparison;
        return (a.stockQuantity ?? 0).compareTo(b.stockQuantity ?? 0);
      });

      final result = products.take(limit).toList();
      print('🎯 Final result: ${result.length} featured products');

      return result;
    } catch (e) {
      print('❌ Error fetching featured products: $e');
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByCategory(
    String categoryId, {
    int limit = 10,
  }) async {
    try {
      // Simplified query to avoid composite index requirements
      final querySnapshot = await _firestore
          .collection('products')
          .where('categoryId', isEqualTo: categoryId)
          .where('isActive', isEqualTo: true)
          .limit(limit * 2) // Get more to sort in app
          .get();

      final products = querySnapshot.docs
          .map((doc) => ProductModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();

      // Sort in application layer by rating (descending)
      products.sort((a, b) => (b.rating ?? 0.0).compareTo(a.rating ?? 0.0));

      return products.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection('products').doc(id).get();
      if (!doc.exists) return null;

      return ProductModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .orderBy('sortOrder')
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getActiveCategories() async {
    try {
      print('🔍 Fetching active categories from Firestore...');

      // Simplified query to avoid composite index requirements
      final querySnapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .get();

      print('📊 Raw query returned ${querySnapshot.docs.length} categories');

      final categories = querySnapshot.docs.map((doc) {
        final data = {'id': doc.id, ...doc.data()};
        print('📂 Category data: $data');
        return CategoryModel.fromJson(data);
      }).toList();

      // Sort in application layer
      categories.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));

      print('✅ Final result: ${categories.length} active categories');
      return categories;
    } catch (e) {
      print('❌ Error fetching active categories: $e');
      throw Exception('Failed to fetch active categories: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getParentCategories() async {
    try {
      // Simplified query to avoid composite index requirements
      final querySnapshot = await _firestore
          .collection('categories')
          .where('isActive', isEqualTo: true)
          .get();

      final categories = querySnapshot.docs
          .map((doc) => CategoryModel.fromJson({'id': doc.id, ...doc.data()}))
          .where((category) => category.parentId == null) // Filter in app
          .toList();

      // Sort in application layer
      categories.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));

      return categories;
    } catch (e) {
      throw Exception('Failed to fetch parent categories: $e');
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    try {
      final doc = await _firestore.collection('categories').doc(id).get();
      if (!doc.exists) return null;

      return CategoryModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }

  @override
  Future<List<QuickActionModel>> getQuickActions() async {
    try {
      final querySnapshot = await _firestore
          .collection('quickActions')
          .orderBy('sortOrder')
          .get();

      return querySnapshot.docs
          .map(
            (doc) => QuickActionModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch quick actions: $e');
    }
  }

  @override
  Future<List<QuickActionModel>> getActiveQuickActions() async {
    try {
      final querySnapshot = await _firestore
          .collection('quickActions')
          .where('isActive', isEqualTo: true)
          .orderBy('sortOrder')
          .get();

      return querySnapshot.docs
          .map(
            (doc) => QuickActionModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch active quick actions: $e');
    }
  }

  @override
  Future<QuickActionModel?> getQuickActionById(String id) async {
    try {
      final doc = await _firestore.collection('quickActions').doc(id).get();
      if (!doc.exists) return null;

      return QuickActionModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch quick action: $e');
    }
  }

  @override
  Future<void> trackBannerClick(String bannerId) async {
    try {
      await _firestore.collection('analytics').add({
        'type': 'banner_click',
        'bannerId': bannerId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Analytics failures shouldn't break the app
      print('Failed to track banner click: $e');
    }
  }

  @override
  Future<void> trackProductView(String productId) async {
    try {
      await _firestore.collection('analytics').add({
        'type': 'product_view',
        'productId': productId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to track product view: $e');
    }
  }

  @override
  Future<void> trackCategoryView(String categoryId) async {
    try {
      await _firestore.collection('analytics').add({
        'type': 'category_view',
        'categoryId': categoryId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to track category view: $e');
    }
  }

  @override
  Future<void> trackQuickActionClick(String actionId) async {
    try {
      await _firestore.collection('analytics').add({
        'type': 'quick_action_click',
        'actionId': actionId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Failed to track quick action click: $e');
    }
  }
}
