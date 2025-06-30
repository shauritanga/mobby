import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product_search_result.dart';

// Simple mock providers for development
final mockProductsProvider = Provider<List<Product>>((ref) {
  return [
    Product(
      id: '1',
      name: 'Premium Engine Oil 5W-30',
      description:
          'High-quality synthetic engine oil for optimal engine performance.',
      price: 25000,
      originalPrice: 30000,
      currency: 'TZS',
      imageUrl: 'https://example.com/engine-oil.jpg',
      imageUrls: ['https://example.com/engine-oil.jpg'],
      categoryId: 'engine',
      categoryName: 'Engine Parts',
      brandId: 'mobil',
      brandName: 'Mobil',
      sku: 'MOB-EO-5W30-001',
      stockQuantity: 50,
      stockStatus: StockStatus.inStock,
      condition: ProductCondition.new_,
      rating: 4.5,
      reviewCount: 128,
      isFeatured: true,
      isActive: true,
      isDigital: false,
      requiresShipping: true,
      tags: ['engine', 'oil', 'synthetic'],
      specifications: {'viscosity': '5W-30', 'volume': '4L'},
      compatibleVehicles: ['Toyota Camry', 'Honda Civic'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    Product(
      id: '2',
      name: 'Air Filter',
      description: 'High-performance air filter for better engine breathing.',
      price: 15000,
      currency: 'TZS',
      imageUrl: 'https://example.com/air-filter.jpg',
      imageUrls: ['https://example.com/air-filter.jpg'],
      categoryId: 'engine',
      categoryName: 'Engine Parts',
      brandId: 'kn',
      brandName: 'K&N',
      sku: 'KN-AF-001',
      stockQuantity: 25,
      stockStatus: StockStatus.inStock,
      condition: ProductCondition.new_,
      rating: 4.3,
      reviewCount: 89,
      isFeatured: false,
      isActive: true,
      isDigital: false,
      requiresShipping: true,
      tags: ['air', 'filter', 'performance'],
      specifications: {'type': 'High-flow', 'material': 'Cotton'},
      compatibleVehicles: ['Toyota Camry', 'Honda Civic'],
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
  ];
});

// Simple product provider
final productProvider = FutureProvider.family<Product?, String>((
  ref,
  productId,
) async {
  final products = ref.watch(mockProductsProvider);
  await Future.delayed(
    const Duration(milliseconds: 300),
  ); // Simulate network delay
  try {
    return products.firstWhere((p) => p.id == productId);
  } on StateError {
    return null;
  }
});

// Additional simple providers
final featuredProductsProvider = FutureProvider<List<Product>>((ref) async {
  final products = ref.watch(mockProductsProvider);
  await Future.delayed(const Duration(milliseconds: 300));
  return products.where((p) => p.isFeatured).toList();
});

final popularProductsProvider = FutureProvider<List<Product>>((ref) async {
  final products = ref.watch(mockProductsProvider);
  await Future.delayed(const Duration(milliseconds: 300));
  return products.where((p) => p.rating >= 4.5).toList();
});

final saleProductsProvider = FutureProvider<List<Product>>((ref) async {
  final products = ref.watch(mockProductsProvider);
  await Future.delayed(const Duration(milliseconds: 300));
  return products.where((p) => p.originalPrice != null).toList();
});

// Products provider with filter support
final productsProvider =
    FutureProvider.family<ProductSearchResult, ProductFilter>((
      ref,
      filter,
    ) async {
      final products = ref.watch(mockProductsProvider);
      await Future.delayed(const Duration(milliseconds: 500));

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

        // Price range filter
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
        if (filter.isFeatured != null &&
            product.isFeatured != filter.isFeatured!) {
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
          filteredProducts.sort(
            (a, b) => b.reviewCount.compareTo(a.reviewCount),
          );
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

  final products = ref.watch(mockProductsProvider);
  await Future.delayed(const Duration(milliseconds: 200));

  final suggestions = <String>{};

  for (final product in products) {
    // Add product names that match
    if (product.name.toLowerCase().contains(query.toLowerCase())) {
      suggestions.add(product.name);
    }

    // Add brand names that match
    if (product.brandName.toLowerCase().contains(query.toLowerCase())) {
      suggestions.add(product.brandName);
    }

    // Add category names that match
    if (product.categoryName.toLowerCase().contains(query.toLowerCase())) {
      suggestions.add(product.categoryName);
    }

    // Add tags that match
    for (final tag in product.tags) {
      if (tag.toLowerCase().contains(query.toLowerCase())) {
        suggestions.add(tag);
      }
    }
  }

  return suggestions.take(5).toList();
});

// Extension methods for actions
extension ProductProviderActions on WidgetRef {
  void trackProductView(String productId) {
    // Mock implementation
  }

  void trackProductSearch(String query) {
    // Mock implementation
  }
}
