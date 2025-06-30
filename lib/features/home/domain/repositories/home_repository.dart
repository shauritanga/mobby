import '../entities/banner.dart';
import '../entities/product.dart';
import '../entities/category.dart';
import '../entities/quick_action.dart';

abstract class HomeRepository {
  // Banners
  Future<List<Banner>> getBanners();
  Future<List<Banner>> getActiveBanners();
  Future<Banner?> getBannerById(String id);
  
  // Products
  Future<List<Product>> getFeaturedProducts({int limit = 10});
  Future<List<Product>> getProductsByCategory(String categoryId, {int limit = 10});
  Future<Product?> getProductById(String id);
  
  // Categories
  Future<List<Category>> getCategories();
  Future<List<Category>> getActiveCategories();
  Future<List<Category>> getParentCategories();
  Future<Category?> getCategoryById(String id);
  
  // Quick Actions
  Future<List<QuickAction>> getQuickActions();
  Future<List<QuickAction>> getActiveQuickActions();
  Future<QuickAction?> getQuickActionById(String id);
  
  // Analytics
  Future<void> trackBannerClick(String bannerId);
  Future<void> trackProductView(String productId);
  Future<void> trackCategoryView(String categoryId);
  Future<void> trackQuickActionClick(String actionId);
  
  // Cache management
  Future<void> refreshCache();
  Future<void> clearCache();
}
