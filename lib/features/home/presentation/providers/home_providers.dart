import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/banner.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/quick_action.dart';
import '../../domain/repositories/home_repository.dart';
import '../../data/repositories/home_repository_impl.dart';
import '../../data/datasources/home_remote_datasource.dart';
import '../../data/datasources/home_local_datasource.dart';

// Core dependencies
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Data sources
final homeRemoteDataSourceProvider = Provider<HomeRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return HomeRemoteDataSourceImpl(firestore: firestore);
});

final homeLocalDataSourceProvider = Provider<HomeLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return HomeLocalDataSourceImpl(prefs: prefs);
});

// Repository
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final remoteDataSource = ref.watch(homeRemoteDataSourceProvider);
  final localDataSource = ref.watch(homeLocalDataSourceProvider);

  return HomeRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// Banner providers
final bannersProvider = FutureProvider<List<Banner>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getActiveBanners();
});

final bannerByIdProvider = FutureProvider.family<Banner?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getBannerById(id);
});

// Product providers
final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getFeaturedProducts(limit: 10);
});

final productsByCategoryProvider = FutureProvider.family<List<Product>, String>(
  (ref, categoryId) async {
    final repository = ref.watch(homeRepositoryProvider);
    return repository.getProductsByCategory(categoryId, limit: 10);
  },
);

final productByIdProvider = FutureProvider.family<Product?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getProductById(id);
});

// Category providers
final categoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getActiveCategories();
});

final parentCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getParentCategories();
});

final categoryByIdProvider = FutureProvider.family<Category?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getCategoryById(id);
});

// Quick action providers
final quickActionsProvider = FutureProvider<List<QuickAction>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getActiveQuickActions();
});

final quickActionByIdProvider = FutureProvider.family<QuickAction?, String>((
  ref,
  id,
) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.getQuickActionById(id);
});

// Analytics providers
final bannerClickProvider = Provider.family<Future<void>, String>((
  ref,
  bannerId,
) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.trackBannerClick(bannerId);
});

final productViewProvider = Provider.family<Future<void>, String>((
  ref,
  productId,
) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.trackProductView(productId);
});

final categoryViewProvider = Provider.family<Future<void>, String>((
  ref,
  categoryId,
) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.trackCategoryView(categoryId);
});

final quickActionClickProvider = Provider.family<Future<void>, String>((
  ref,
  actionId,
) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.trackQuickActionClick(actionId);
});

// Cache management providers
final refreshCacheProvider = Provider<Future<void>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.refreshCache();
});

final clearCacheProvider = Provider<Future<void>>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.clearCache();
});

// Combined home data provider for the home screen
final homeDataProvider = FutureProvider<HomeData>((ref) async {
  final bannersFuture = ref.watch(bannersProvider.future);
  final productsFuture = ref.watch(featuredProductsProvider.future);
  final categoriesFuture = ref.watch(parentCategoriesProvider.future);
  final quickActionsFuture = ref.watch(quickActionsProvider.future);

  final results = await Future.wait([
    bannersFuture,
    productsFuture,
    categoriesFuture,
    quickActionsFuture,
  ]);

  return HomeData(
    banners: results[0] as List<Banner>,
    featuredProducts: results[1] as List<Product>,
    categories: results[2] as List<Category>,
    quickActions: results[3] as List<QuickAction>,
  );
});

// Home data model
class HomeData {
  final List<Banner> banners;
  final List<Product> featuredProducts;
  final List<Category> categories;
  final List<QuickAction> quickActions;

  const HomeData({
    required this.banners,
    required this.featuredProducts,
    required this.categories,
    required this.quickActions,
  });

  HomeData copyWith({
    List<Banner>? banners,
    List<Product>? featuredProducts,
    List<Category>? categories,
    List<QuickAction>? quickActions,
  }) {
    return HomeData(
      banners: banners ?? this.banners,
      featuredProducts: featuredProducts ?? this.featuredProducts,
      categories: categories ?? this.categories,
      quickActions: quickActions ?? this.quickActions,
    );
  }
}
