import 'package:equatable/equatable.dart';

enum SortOption {
  relevance,
  priceAsc,
  priceDesc,
  ratingDesc,
  newest,
  popular,
  nameAsc,
  nameDesc,
}

enum ProductAvailability {
  all,
  inStock,
  outOfStock,
  lowStock,
}

class PriceRange extends Equatable {
  final double? minPrice;
  final double? maxPrice;

  const PriceRange({
    this.minPrice,
    this.maxPrice,
  });

  bool get hasRange => minPrice != null || maxPrice != null;

  @override
  List<Object?> get props => [minPrice, maxPrice];

  PriceRange copyWith({
    double? minPrice,
    double? maxPrice,
  }) {
    return PriceRange(
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

class ProductFilter extends Equatable {
  final String? searchQuery;
  final List<String> categoryIds;
  final List<String> brandIds;
  final PriceRange priceRange;
  final double? minRating;
  final ProductAvailability availability;
  final bool? isFeatured;
  final bool? isOnSale;
  final SortOption sortBy;
  final int page;
  final int limit;

  const ProductFilter({
    this.searchQuery,
    this.categoryIds = const [],
    this.brandIds = const [],
    this.priceRange = const PriceRange(),
    this.minRating,
    this.availability = ProductAvailability.all,
    this.isFeatured,
    this.isOnSale,
    this.sortBy = SortOption.relevance,
    this.page = 1,
    this.limit = 20,
  });

  bool get hasFilters =>
      searchQuery?.isNotEmpty == true ||
      categoryIds.isNotEmpty ||
      brandIds.isNotEmpty ||
      priceRange.hasRange ||
      minRating != null ||
      availability != ProductAvailability.all ||
      isFeatured != null ||
      isOnSale != null;

  bool get hasSearch => searchQuery?.isNotEmpty == true;

  @override
  List<Object?> get props => [
        searchQuery,
        categoryIds,
        brandIds,
        priceRange,
        minRating,
        availability,
        isFeatured,
        isOnSale,
        sortBy,
        page,
        limit,
      ];

  ProductFilter copyWith({
    String? searchQuery,
    List<String>? categoryIds,
    List<String>? brandIds,
    PriceRange? priceRange,
    double? minRating,
    ProductAvailability? availability,
    bool? isFeatured,
    bool? isOnSale,
    SortOption? sortBy,
    int? page,
    int? limit,
  }) {
    return ProductFilter(
      searchQuery: searchQuery ?? this.searchQuery,
      categoryIds: categoryIds ?? this.categoryIds,
      brandIds: brandIds ?? this.brandIds,
      priceRange: priceRange ?? this.priceRange,
      minRating: minRating ?? this.minRating,
      availability: availability ?? this.availability,
      isFeatured: isFeatured ?? this.isFeatured,
      isOnSale: isOnSale ?? this.isOnSale,
      sortBy: sortBy ?? this.sortBy,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  ProductFilter clearFilters() {
    return const ProductFilter();
  }

  ProductFilter nextPage() {
    return copyWith(page: page + 1);
  }

  ProductFilter resetPage() {
    return copyWith(page: 1);
  }
}
