import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product_search_result.dart';
import 'product_providers.dart';

part 'search_filter_providers.g.dart';

// Search State Management
@riverpod
class SearchState extends _$SearchState {
  @override
  String build() {
    return '';
  }

  void updateQuery(String query) {
    state = query;
  }

  void clearSearch() {
    state = '';
  }
}

// Filter State Management
@riverpod
class FilterState extends _$FilterState {
  @override
  ProductFilter build() {
    return const ProductFilter();
  }

  void updateFilter(ProductFilter filter) {
    state = filter;
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void updateCategoryIds(List<String> categoryIds) {
    state = state.copyWith(categoryIds: categoryIds);
  }

  void addCategoryId(String categoryId) {
    final currentCategories = List<String>.from(state.categoryIds);
    if (!currentCategories.contains(categoryId)) {
      currentCategories.add(categoryId);
      state = state.copyWith(categoryIds: currentCategories);
    }
  }

  void removeCategoryId(String categoryId) {
    final currentCategories = List<String>.from(state.categoryIds);
    currentCategories.remove(categoryId);
    state = state.copyWith(categoryIds: currentCategories);
  }

  void updateBrandIds(List<String> brandIds) {
    state = state.copyWith(brandIds: brandIds);
  }

  void addBrandId(String brandId) {
    final currentBrands = List<String>.from(state.brandIds);
    if (!currentBrands.contains(brandId)) {
      currentBrands.add(brandId);
      state = state.copyWith(brandIds: currentBrands);
    }
  }

  void removeBrandId(String brandId) {
    final currentBrands = List<String>.from(state.brandIds);
    currentBrands.remove(brandId);
    state = state.copyWith(brandIds: currentBrands);
  }

  void updatePriceRange(double? minPrice, double? maxPrice) {
    state = state.copyWith(
      priceRange: PriceRange(minPrice: minPrice, maxPrice: maxPrice),
    );
  }

  void updateMinRating(double? minRating) {
    state = state.copyWith(minRating: minRating);
  }

  void updateAvailability(ProductAvailability availability) {
    state = state.copyWith(availability: availability);
  }

  void updateIsFeatured(bool? isFeatured) {
    state = state.copyWith(isFeatured: isFeatured);
  }

  void updateIsOnSale(bool? isOnSale) {
    state = state.copyWith(isOnSale: isOnSale);
  }

  void updateSortBy(SortOption sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  void updatePage(int page) {
    state = state.copyWith(page: page);
  }

  void nextPage() {
    state = state.copyWith(page: state.page + 1);
  }

  void previousPage() {
    if (state.page > 1) {
      state = state.copyWith(page: state.page - 1);
    }
  }

  void resetPage() {
    state = state.copyWith(page: 1);
  }

  void updateLimit(int limit) {
    state = state.copyWith(limit: limit);
  }

  void clearFilters() {
    state = const ProductFilter();
  }

  void clearFiltersKeepSearch() {
    final currentQuery = state.searchQuery;
    state = ProductFilter(searchQuery: currentQuery);
  }

  bool get hasActiveFilters {
    return state.hasFilters;
  }

  int get activeFilterCount {
    int count = 0;
    if (state.categoryIds.isNotEmpty) count++;
    if (state.brandIds.isNotEmpty) count++;
    if (state.priceRange.hasRange) count++;
    if (state.minRating != null) count++;
    if (state.availability != ProductAvailability.all) count++;
    if (state.isFeatured != null) count++;
    if (state.isOnSale != null) count++;
    return count;
  }
}

// Search Results Provider
@riverpod
Future<ProductSearchResult> searchResults(Ref ref) async {
  final searchQuery = ref.watch(searchStateProvider);
  final filter = ref.watch(filterStateProvider);

  if (searchQuery.isEmpty && !filter.hasFilters) {
    // Return empty result if no search query or filters
    return const ProductSearchResult(
      products: [],
      totalCount: 0,
      currentPage: 1,
      totalPages: 0,
      hasNextPage: false,
      hasPreviousPage: false,
    );
  }

  final searchFilter = filter.copyWith(
    searchQuery: searchQuery.isEmpty ? null : searchQuery,
  );

  if (searchQuery.isNotEmpty) {
    return await ref.watch(
      searchProductsProvider((query: searchQuery, filter: searchFilter)).future,
    );
  } else {
    return await ref.watch(productsProvider(searchFilter).future);
  }
}

// Search Suggestions Provider
@riverpod
Future<List<String>> searchSuggestionsForQuery(Ref ref, String query) async {
  if (query.length < 2) return [];

  return await ref.watch(searchSuggestionsProvider(query).future);
}

// Active Search and Filter Provider
@riverpod
Future<ProductSearchResult> activeSearchAndFilter(Ref ref) async {
  final searchQuery = ref.watch(searchStateProvider);
  final filter = ref.watch(filterStateProvider);

  // Always apply current filter, with or without search
  final activeFilter = filter.copyWith(
    searchQuery: searchQuery.isEmpty ? null : searchQuery,
  );

  return await ref.watch(productsProvider(activeFilter).future);
}

// Pagination State
@riverpod
class PaginationState extends _$PaginationState {
  @override
  Map<String, dynamic> build() {
    return {
      'currentPage': 1,
      'totalPages': 0,
      'totalCount': 0,
      'hasNextPage': false,
      'hasPreviousPage': false,
      'isLoading': false,
    };
  }

  void updateFromSearchResult(ProductSearchResult result) {
    state = {
      'currentPage': result.currentPage,
      'totalPages': result.totalPages,
      'totalCount': result.totalCount,
      'hasNextPage': result.hasNextPage,
      'hasPreviousPage': result.hasPreviousPage,
      'isLoading': false,
    };
  }

  void setLoading(bool isLoading) {
    state = {...state, 'isLoading': isLoading};
  }

  void reset() {
    state = {
      'currentPage': 1,
      'totalPages': 0,
      'totalCount': 0,
      'hasNextPage': false,
      'hasPreviousPage': false,
      'isLoading': false,
    };
  }

  int get currentPage => state['currentPage'] as int;
  int get totalPages => state['totalPages'] as int;
  int get totalCount => state['totalCount'] as int;
  bool get hasNextPage => state['hasNextPage'] as bool;
  bool get hasPreviousPage => state['hasPreviousPage'] as bool;
  bool get isLoading => state['isLoading'] as bool;
}

// Search History Provider
@riverpod
class SearchHistoryState extends _$SearchHistoryState {
  @override
  List<String> build() {
    return [];
  }

  void addSearch(String query) {
    if (query.trim().isEmpty) return;

    final currentHistory = List<String>.from(state);

    // Remove if already exists
    currentHistory.remove(query);

    // Add to beginning
    currentHistory.insert(0, query);

    // Keep only last 20 searches
    if (currentHistory.length > 20) {
      currentHistory.removeRange(20, currentHistory.length);
    }

    state = currentHistory;
  }

  void removeSearch(String query) {
    final currentHistory = List<String>.from(state);
    currentHistory.remove(query);
    state = currentHistory;
  }

  void clearHistory() {
    state = [];
  }
}

// Quick Filter Presets
@riverpod
class QuickFilters extends _$QuickFilters {
  @override
  Map<String, ProductFilter> build() {
    return {
      'featured': const ProductFilter(isFeatured: true),
      'on_sale': const ProductFilter(isOnSale: true),
      'high_rated': const ProductFilter(minRating: 4.0),
      'in_stock': const ProductFilter(
        availability: ProductAvailability.inStock,
      ),
      'price_low_high': const ProductFilter(sortBy: SortOption.priceAsc),
      'price_high_low': const ProductFilter(sortBy: SortOption.priceDesc),
      'newest': const ProductFilter(sortBy: SortOption.newest),
      'popular': const ProductFilter(sortBy: SortOption.popular),
      'best_rated': const ProductFilter(sortBy: SortOption.ratingDesc),
    };
  }

  void applyQuickFilter(String filterKey) {
    final quickFilter = state[filterKey];
    if (quickFilter != null) {
      ref.read(filterStateProvider.notifier).updateFilter(quickFilter);
    }
  }

  ProductFilter? getQuickFilter(String filterKey) {
    return state[filterKey];
  }

  List<String> get availableFilters => state.keys.toList();
}

// Search and Filter Utility Extensions
extension SearchFilterExtension on WidgetRef {
  /// Perform search with query
  void searchProducts(String query) {
    read(searchStateProvider.notifier).updateQuery(query);
    read(filterStateProvider.notifier).resetPage();
    read(searchHistoryStateProvider.notifier).addSearch(query);
  }

  /// Clear search but keep filters
  void clearSearch() {
    read(searchStateProvider.notifier).clearSearch();
    read(filterStateProvider.notifier).resetPage();
  }

  /// Apply quick filter
  void applyQuickFilter(String filterKey) {
    read(quickFiltersProvider.notifier).applyQuickFilter(filterKey);
    read(filterStateProvider.notifier).resetPage();
  }

  /// Clear all filters
  void clearAllFilters() {
    read(filterStateProvider.notifier).clearFilters();
    read(searchStateProvider.notifier).clearSearch();
  }

  /// Clear filters but keep search
  void clearFiltersKeepSearch() {
    read(filterStateProvider.notifier).clearFiltersKeepSearch();
  }

  /// Toggle category filter
  void toggleCategoryFilter(String categoryId) {
    final currentFilter = read(filterStateProvider);
    if (currentFilter.categoryIds.contains(categoryId)) {
      read(filterStateProvider.notifier).removeCategoryId(categoryId);
    } else {
      read(filterStateProvider.notifier).addCategoryId(categoryId);
    }
    read(filterStateProvider.notifier).resetPage();
  }

  /// Toggle brand filter
  void toggleBrandFilter(String brandId) {
    final currentFilter = read(filterStateProvider);
    if (currentFilter.brandIds.contains(brandId)) {
      read(filterStateProvider.notifier).removeBrandId(brandId);
    } else {
      read(filterStateProvider.notifier).addBrandId(brandId);
    }
    read(filterStateProvider.notifier).resetPage();
  }

  /// Update sort option
  void updateSort(SortOption sortBy) {
    read(filterStateProvider.notifier).updateSortBy(sortBy);
    read(filterStateProvider.notifier).resetPage();
  }

  /// Go to next page
  void nextPage() {
    read(filterStateProvider.notifier).nextPage();
  }

  /// Go to previous page
  void previousPage() {
    read(filterStateProvider.notifier).previousPage();
  }

  /// Go to specific page
  void goToPage(int page) {
    read(filterStateProvider.notifier).updatePage(page);
  }

  /// Get current search query
  String getCurrentSearchQuery() {
    return read(searchStateProvider);
  }

  /// Get current filter
  ProductFilter getCurrentFilter() {
    return read(filterStateProvider);
  }

  /// Check if has active filters
  bool hasActiveFilters() {
    return read(filterStateProvider.notifier).hasActiveFilters;
  }

  /// Get active filter count
  int getActiveFilterCount() {
    return read(filterStateProvider.notifier).activeFilterCount;
  }
}
