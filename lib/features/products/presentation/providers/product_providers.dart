import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/services/firebase_service.dart';
import '../../../../core/providers/core_providers.dart';
import '../../data/models/product_model.dart';

import '../../data/datasources/firebase_products_datasource.dart';
import '../../data/datasources/product_remote_datasource.dart';
import '../../data/datasources/product_local_datasource.dart';
import '../../data/repositories/product_repository_impl.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product_search_result.dart';
import '../../domain/repositories/product_repository.dart';
import '../../../home/presentation/providers/home_providers.dart' as home;

// Core dependencies
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Firebase service provider
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService();
});

// Data source providers
final productRemoteDataSourceProvider = Provider<ProductRemoteDataSource>((
  ref,
) {
  final firestore = ref.watch(firestoreProvider);
  return ProductRemoteDataSourceImpl(firestore: firestore);
});

final productLocalDataSourceProvider = Provider<ProductLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ProductLocalDataSourceImpl(prefs: prefs);
});

// Repository provider
final productRepositoryProvider = Provider<ProductRepository>((ref) {
  final remoteDataSource = ref.watch(productRemoteDataSourceProvider);
  final localDataSource = ref.watch(productLocalDataSourceProvider);

  return ProductRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
  );
});

// Firebase products datasource provider (legacy - for backward compatibility)
final firebaseProductsDatasourceProvider = Provider<FirebaseProductsDatasource>(
  (ref) {
    final firebaseService = ref.watch(firebaseServiceProvider);
    return FirebaseProductsDatasource(firebaseService);
  },
);

// Firebase products provider that fetches ALL products from Firestore
final firebaseProductsProvider = FutureProvider<List<Product>>((ref) async {
  try {
    print(
      '� FirebaseProductsProvider: Fetching ALL products directly from Firestore...',
    );

    // Get Firestore instance directly (same as home repository)
    final firestore = ref.watch(firestoreProvider);

    // Query all active products directly
    final querySnapshot = await firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .get();

    print(
      '📦 FirebaseProductsProvider: Got ${querySnapshot.docs.length} documents from Firestore',
    );

    final products = querySnapshot.docs
        .where((doc) => doc.exists)
        .map((doc) {
          try {
            final data = {'id': doc.id, ...doc.data()};
            // Convert Firestore Timestamps to ISO8601 strings for JSON parsing
            if (data['createdAt'] is Timestamp) {
              data['createdAt'] = (data['createdAt'] as Timestamp)
                  .toDate()
                  .toIso8601String();
            }
            if (data['updatedAt'] is Timestamp) {
              data['updatedAt'] = (data['updatedAt'] as Timestamp)
                  .toDate()
                  .toIso8601String();
            }

            return ProductModel.fromMap(data);
          } catch (e) {
            print('❌ Error parsing product ${doc.id}: $e');
            return null;
          }
        })
        .whereType<ProductModel>()
        .toList();

    print(
      '✅ FirebaseProductsProvider: Successfully converted ${products.length} products',
    );
    return products;
  } catch (e) {
    print('❌ FirebaseProductsProvider: Error fetching products: $e');
    // Fallback to empty list if Firebase fails
    return <Product>[];
  }
});

// Simple product provider
final productProvider = FutureProvider.family<Product?, String>((
  ref,
  productId,
) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getProductById(productId);
});

// Additional simple providers
final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getFeaturedProducts();
});

final popularProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getPopularProducts();
});

final saleProductsProvider = FutureProvider<List<Product>>((ref) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getSaleProducts();
});

// Products provider with filter support
final productsProvider = FutureProvider.family<ProductSearchResult, ProductFilter>((
  ref,
  filter,
) async {
  print('🔍 ProductsProvider called with filter: ${filter.toString()}');
  final productsAsync = await ref.watch(firebaseProductsProvider.future);
  final products = productsAsync;
  print('📦 Raw products from Firebase: ${products.length} items');
  // Apply filters to mock products
  var filteredProducts = products.where((product) {
    // Search query filter
    if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
      final query = filter.searchQuery!.toLowerCase();
      if (!product.name.toLowerCase().contains(query) &&
          !product.description.toLowerCase().contains(query) &&
          !product.tags.any((tag) => tag.toLowerCase().contains(query))) {
        return false;
      }
    }

    // Category filter
    if (filter.categoryIds.isNotEmpty) {
      if (!filter.categoryIds.contains(product.categoryId)) {
        return false;
      }
    }

    // Brand filter
    if (filter.brandIds.isNotEmpty) {
      if (!filter.brandIds.contains(product.brandId)) {
        return false;
      }
    }

    // Price range filter (adjusted for USD pricing)
    if (filter.priceRange.hasRange) {
      if (filter.priceRange.minPrice != null &&
          product.price < filter.priceRange.minPrice!) {
        return false;
      }
      if (filter.priceRange.maxPrice != null &&
          product.price > filter.priceRange.maxPrice!) {
        return false;
      }
    }

    // Rating filter
    if (filter.minRating != null && product.rating < filter.minRating!) {
      return false;
    }

    // Availability filter
    if (filter.availability != ProductAvailability.all) {
      switch (filter.availability) {
        case ProductAvailability.inStock:
          if (product.stockStatus != StockStatus.inStock) return false;
          break;
        case ProductAvailability.outOfStock:
          if (product.stockStatus != StockStatus.outOfStock) return false;
          break;
        case ProductAvailability.lowStock:
          if (product.stockStatus != StockStatus.lowStock) return false;
          break;
        case ProductAvailability.all:
          break;
      }
    }

    // Featured filter
    if (filter.isFeatured != null && product.isFeatured != filter.isFeatured!) {
      return false;
    }

    // On sale filter
    if (filter.isOnSale != null) {
      final isOnSale = product.originalPrice != null;
      if (isOnSale != filter.isOnSale!) {
        return false;
      }
    }

    return true;
  }).toList();

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
    case SortOption.popular:
      filteredProducts.sort((a, b) => b.reviewCount.compareTo(a.reviewCount));
      break;
    case SortOption.nameAsc:
      filteredProducts.sort((a, b) => a.name.compareTo(b.name));
      break;
    case SortOption.nameDesc:
      filteredProducts.sort((a, b) => b.name.compareTo(a.name));
      break;
    case SortOption.relevance:
      // Keep original order for relevance
      break;
  }

  // Apply pagination
  final totalCount = filteredProducts.length;
  final totalPages = (totalCount / filter.limit).ceil();
  final startIndex = (filter.page - 1) * filter.limit;
  final endIndex = (startIndex + filter.limit).clamp(0, totalCount);

  final paginatedProducts = filteredProducts.sublist(
    startIndex.clamp(0, totalCount),
    endIndex,
  );

  print('✅ Filtered products: ${filteredProducts.length} items');
  print(
    '📄 Paginated products: ${paginatedProducts.length} items (page ${filter.page})',
  );

  return ProductSearchResult(
    products: paginatedProducts,
    totalCount: totalCount,
    currentPage: filter.page,
    totalPages: totalPages,
    hasNextPage: filter.page < totalPages,
    hasPreviousPage: filter.page > 1,
  );
});

// Search products provider
final searchProductsProvider =
    FutureProvider.family<
      ProductSearchResult,
      ({String query, ProductFilter? filter})
    >((ref, params) async {
      final searchFilter = (params.filter ?? const ProductFilter()).copyWith(
        searchQuery: params.query,
      );
      return ref.watch(productsProvider(searchFilter).future);
    });

// Search suggestions provider
final searchSuggestionsProvider = FutureProvider.family<List<String>, String>((
  ref,
  query,
) async {
  if (query.length < 2) return [];

  final repository = ref.watch(productRepositoryProvider);
  return await repository.getSearchSuggestions(query);
});

// Category providers - delegate to home providers for categories
final categoryByIdProvider = home.categoryByIdProvider;

// Products by category provider
final categoryProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  categoryId,
) async {
  final repository = ref.watch(productRepositoryProvider);
  final result = await repository.getProductsByCategory(categoryId);
  return result.products;
});

// Related products provider
final relatedProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  productId,
) async {
  final repository = ref.watch(productRepositoryProvider);
  return await repository.getRelatedProducts(productId);
});

// Frequently bought together provider
final frequentlyBoughtTogetherProvider =
    FutureProvider.family<List<Product>, String>((ref, productId) async {
      final repository = ref.watch(productRepositoryProvider);
      return await repository.getFrequentlyBoughtTogether(productId);
    });

// Recently viewed products provider
final recentlyViewedProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, userId) async {
      final repository = ref.watch(productRepositoryProvider);
      return await repository.getRecentlyViewedProducts(userId);
    });

// Product tracking providers
final productViewProvider = Provider.family<Future<void>, String>((
  ref,
  productId,
) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.trackProductView(productId);
});

final productSearchProvider = Provider.family<Future<void>, String>((
  ref,
  query,
) {
  final repository = ref.watch(productRepositoryProvider);
  return repository.trackProductSearch(query);
});

// Extension methods for actions
extension ProductProviderActions on WidgetRef {
  void trackProductView(String productId) {
    read(productViewProvider(productId));
  }

  void trackProductSearch(String query) {
    read(productSearchProvider(query));
  }
}
