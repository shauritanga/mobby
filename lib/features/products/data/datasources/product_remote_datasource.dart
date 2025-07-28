import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/brand_model.dart';
import '../models/review_model.dart';
import '../../domain/entities/product_filter.dart';
import '../../domain/entities/product_search_result.dart';

abstract class ProductRemoteDataSource {
  Future<ProductModel?> getProductById(String id);
  Future<ProductSearchResult> getProducts(ProductFilter filter);
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10});
  Future<List<ProductModel>> getPopularProducts({int limit = 10});
  Future<List<ProductModel>> getNewProducts({int limit = 10});
  Future<List<ProductModel>> getSaleProducts({int limit = 10});

  Future<ProductSearchResult> getProductsByCategory(
    String categoryId, {
    ProductFilter? filter,
  });
  Future<List<ProductModel>> getRelatedProducts(
    String productId, {
    int limit = 5,
  });
  Future<List<ProductModel>> getFrequentlyBoughtTogether(
    String productId, {
    int limit = 3,
  });

  Future<ProductSearchResult> getProductsByBrand(
    String brandId, {
    ProductFilter? filter,
  });
  Future<List<BrandModel>> getBrands();
  Future<List<BrandModel>> getFeaturedBrands({int limit = 10});
  Future<BrandModel?> getBrandById(String id);

  Future<ProductSearchResult> searchProducts(
    String query, {
    ProductFilter? filter,
  });
  Future<List<String>> getSearchSuggestions(String query, {int limit = 5});

  Future<List<ReviewModel>> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 20,
  });
  Future<ReviewModel?> getReviewById(String id);
  Future<ReviewModel> createReview(ReviewModel review);
  Future<ReviewModel> updateReview(ReviewModel review);
  Future<void> deleteReview(String id);
  Future<void> markReviewHelpful(String reviewId, bool isHelpful);

  Future<bool> isProductInStock(String productId);
  Future<int> getProductStock(String productId);
  Future<List<ProductModel>> getLowStockProducts({int limit = 20});
  Future<List<ProductModel>> getOutOfStockProducts({int limit = 20});

  Future<List<ProductModel>> getProductsForVehicle(
    String vehicleModel, {
    ProductFilter? filter,
  });
  Future<List<String>> getCompatibleVehicles(String productId);

  Future<ProductSearchResult> getProductsInPriceRange(
    double minPrice,
    double maxPrice, {
    ProductFilter? filter,
  });
  Future<List<ProductModel>> getProductsOnSale({
    ProductFilter? filter,
    int limit = 20,
  });

  Future<void> trackProductView(String productId);
  Future<void> trackProductSearch(String query);
  Future<void> trackCategoryView(String categoryId);
  Future<void> trackBrandView(String brandId);

  Future<List<ProductModel>> getProductsByIds(List<String> productIds);
  Future<Map<String, bool>> checkProductsAvailability(List<String> productIds);
  Future<Map<String, int>> getProductsStock(List<String> productIds);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final FirebaseFirestore _firestore;

  ProductRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _productsCollection =>
      _firestore.collection('products');
  CollectionReference get _brandsCollection => _firestore.collection('brands');
  CollectionReference get _reviewsCollection =>
      _firestore.collection('reviews');
  CollectionReference get _analyticsCollection =>
      _firestore.collection('analytics');

  // Helper method to parse product from Firestore document
  ProductModel _parseProductFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Ensure the document ID is included in the data
    data['id'] = doc.id;
    return ProductModel.fromMap(data);
  }

  // Helper method to parse product from document snapshot
  ProductModel _parseProductFromDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Ensure the document ID is included in the data
    data['id'] = doc.id;
    return ProductModel.fromMap(data);
  }

  // Helper method to parse brand from Firestore document
  BrandModel _parseBrandFromDoc(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Ensure the document ID is included in the data
    data['id'] = doc.id;
    return BrandModel.fromMap(data);
  }

  // Helper method to parse brand from document snapshot
  BrandModel _parseBrandFromDocSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    // Ensure the document ID is included in the data
    data['id'] = doc.id;
    return BrandModel.fromMap(data);
  }

  @override
  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _productsCollection.doc(id).get();
      if (doc.exists) {
        return _parseProductFromDocSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get product by ID: $e');
    }
  }

  @override
  Future<ProductSearchResult> getProducts(ProductFilter filter) async {
    try {
      Query query = _productsCollection.where('isActive', isEqualTo: true);

      // Apply filters
      if (filter.categoryIds.isNotEmpty) {
        query = query.where('categoryId', whereIn: filter.categoryIds);
      }

      if (filter.brandIds.isNotEmpty) {
        query = query.where('brandId', whereIn: filter.brandIds);
      }

      if (filter.priceRange.hasRange) {
        if (filter.priceRange.minPrice != null) {
          query = query.where(
            'price',
            isGreaterThanOrEqualTo: filter.priceRange.minPrice,
          );
        }
        if (filter.priceRange.maxPrice != null) {
          query = query.where(
            'price',
            isLessThanOrEqualTo: filter.priceRange.maxPrice,
          );
        }
      }

      if (filter.minRating != null) {
        query = query.where('rating', isGreaterThanOrEqualTo: filter.minRating);
      }

      if (filter.isFeatured != null) {
        query = query.where('isFeatured', isEqualTo: filter.isFeatured);
      }

      // Apply sorting
      switch (filter.sortBy) {
        case SortOption.priceAsc:
          query = query.orderBy('price', descending: false);
          break;
        case SortOption.priceDesc:
          query = query.orderBy('price', descending: true);
          break;
        case SortOption.ratingDesc:
          query = query.orderBy('rating', descending: true);
          break;
        case SortOption.newest:
          query = query.orderBy('createdAt', descending: true);
          break;
        case SortOption.popular:
          query = query.orderBy('reviewCount', descending: true);
          break;
        case SortOption.nameAsc:
          query = query.orderBy('name', descending: false);
          break;
        case SortOption.nameDesc:
          query = query.orderBy('name', descending: true);
          break;
        case SortOption.relevance:
          query = query.orderBy('createdAt', descending: true);
          break;
      }

      // Get total count for pagination
      final totalSnapshot = await query.get();
      final totalCount = totalSnapshot.docs.length;

      // Apply pagination using startAfter for better performance
      Query paginatedQuery = query;
      if (filter.page > 1) {
        final skipCount = (filter.page - 1) * filter.limit;
        if (skipCount < totalCount) {
          // For simplicity, we'll use limit and skip logic
          // In production, consider using startAfter with document snapshots
          final skipSnapshot = await query.limit(skipCount).get();
          if (skipSnapshot.docs.isNotEmpty) {
            paginatedQuery = query.startAfterDocument(skipSnapshot.docs.last);
          }
        }
      }

      final snapshot = await paginatedQuery.limit(filter.limit).get();
      final products = snapshot.docs.map(_parseProductFromDoc).toList();

      final totalPages = (totalCount / filter.limit).ceil();

      return ProductSearchResult(
        products: products.map((p) => p.toEntity()).toList(),
        totalCount: totalCount,
        currentPage: filter.page,
        totalPages: totalPages,
        hasNextPage: filter.page < totalPages,
        hasPreviousPage: filter.page > 1,
      );
    } catch (e) {
      throw Exception('Failed to get products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    try {
      final snapshot = await _productsCollection
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map(_parseProductFromDoc).toList();
    } catch (e) {
      throw Exception('Failed to get featured products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getPopularProducts({int limit = 10}) async {
    try {
      final snapshot = await _productsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('reviewCount', descending: true)
          .orderBy('rating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map(_parseProductFromDoc).toList();
    } catch (e) {
      throw Exception('Failed to get popular products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getNewProducts({int limit = 10}) async {
    try {
      final snapshot = await _productsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map(_parseProductFromDoc).toList();
    } catch (e) {
      throw Exception('Failed to get new products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getSaleProducts({int limit = 10}) async {
    try {
      final snapshot = await _productsCollection
          .where('isActive', isEqualTo: true)
          .where('originalPrice', isNull: false)
          .orderBy('originalPrice', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map(_parseProductFromDoc).toList();
    } catch (e) {
      throw Exception('Failed to get sale products: $e');
    }
  }

  @override
  Future<ProductSearchResult> getProductsByCategory(
    String categoryId, {
    ProductFilter? filter,
  }) async {
    try {
      Query query = _productsCollection
          .where('isActive', isEqualTo: true)
          .where('categoryId', isEqualTo: categoryId);

      if (filter != null) {
        // Apply additional filters
        if (filter.brandIds.isNotEmpty) {
          query = query.where('brandId', whereIn: filter.brandIds);
        }

        if (filter.priceRange.hasRange) {
          if (filter.priceRange.minPrice != null) {
            query = query.where(
              'price',
              isGreaterThanOrEqualTo: filter.priceRange.minPrice,
            );
          }
          if (filter.priceRange.maxPrice != null) {
            query = query.where(
              'price',
              isLessThanOrEqualTo: filter.priceRange.maxPrice,
            );
          }
        }

        if (filter.minRating != null) {
          query = query.where(
            'rating',
            isGreaterThanOrEqualTo: filter.minRating,
          );
        }

        // Apply sorting
        switch (filter.sortBy) {
          case SortOption.priceAsc:
            query = query.orderBy('price', descending: false);
            break;
          case SortOption.priceDesc:
            query = query.orderBy('price', descending: true);
            break;
          case SortOption.ratingDesc:
            query = query.orderBy('rating', descending: true);
            break;
          case SortOption.newest:
            query = query.orderBy('createdAt', descending: true);
            break;
          case SortOption.popular:
            query = query.orderBy('reviewCount', descending: true);
            break;
          case SortOption.nameAsc:
            query = query.orderBy('name', descending: false);
            break;
          case SortOption.nameDesc:
            query = query.orderBy('name', descending: true);
            break;
          case SortOption.relevance:
            query = query.orderBy('createdAt', descending: true);
            break;
        }
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      final totalSnapshot = await query.get();
      final totalCount = totalSnapshot.docs.length;

      // Apply pagination
      final pageSize = filter?.limit ?? 20;
      final currentPage = filter?.page ?? 1;

      Query paginatedQuery = query;
      if (currentPage > 1) {
        final skipCount = (currentPage - 1) * pageSize;
        if (skipCount < totalCount) {
          final skipSnapshot = await query.limit(skipCount).get();
          if (skipSnapshot.docs.isNotEmpty) {
            paginatedQuery = query.startAfterDocument(skipSnapshot.docs.last);
          }
        }
      }

      final snapshot = await paginatedQuery.limit(pageSize).get();
      final products = snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();

      final totalPages = (totalCount / pageSize).ceil();

      return ProductSearchResult(
        products: products.map((p) => p.toEntity()).toList(),
        totalCount: totalCount,
        currentPage: currentPage,
        totalPages: totalPages,
        hasNextPage: currentPage < totalPages,
        hasPreviousPage: currentPage > 1,
      );
    } catch (e) {
      throw Exception('Failed to get products by category: $e');
    }
  }

  @override
  Future<List<ProductModel>> getRelatedProducts(
    String productId, {
    int limit = 5,
  }) async {
    try {
      // Get the product to find related products
      final productDoc = await _productsCollection.doc(productId).get();
      if (!productDoc.exists) {
        return [];
      }

      final productData = productDoc.data() as Map<String, dynamic>;
      final categoryId = productData['categoryId'] as String?;
      final brandId = productData['brandId'] as String?;

      Query query = _productsCollection
          .where('isActive', isEqualTo: true)
          .where('id', isNotEqualTo: productId);

      // Prefer same category
      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      final snapshot = await query.limit(limit * 2).get(); // Get more to filter
      final products = snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Prioritize same brand
      if (brandId != null) {
        products.sort((a, b) {
          if (a.brandId == brandId && b.brandId != brandId) return -1;
          if (a.brandId != brandId && b.brandId == brandId) return 1;
          return b.rating.compareTo(a.rating);
        });
      }

      return products.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get related products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getFrequentlyBoughtTogether(
    String productId, {
    int limit = 3,
  }) async {
    try {
      // This would typically require analytics data
      // For now, return related products from same category
      return await getRelatedProducts(productId, limit: limit);
    } catch (e) {
      throw Exception('Failed to get frequently bought together products: $e');
    }
  }

  @override
  Future<ProductSearchResult> getProductsByBrand(
    String brandId, {
    ProductFilter? filter,
  }) async {
    try {
      Query query = _productsCollection
          .where('isActive', isEqualTo: true)
          .where('brandId', isEqualTo: brandId);

      if (filter != null) {
        // Apply additional filters
        if (filter.categoryIds.isNotEmpty) {
          query = query.where('categoryId', whereIn: filter.categoryIds);
        }

        if (filter.priceRange.hasRange) {
          if (filter.priceRange.minPrice != null) {
            query = query.where(
              'price',
              isGreaterThanOrEqualTo: filter.priceRange.minPrice,
            );
          }
          if (filter.priceRange.maxPrice != null) {
            query = query.where(
              'price',
              isLessThanOrEqualTo: filter.priceRange.maxPrice,
            );
          }
        }

        if (filter.minRating != null) {
          query = query.where(
            'rating',
            isGreaterThanOrEqualTo: filter.minRating,
          );
        }

        // Apply sorting
        switch (filter.sortBy) {
          case SortOption.priceAsc:
            query = query.orderBy('price', descending: false);
            break;
          case SortOption.priceDesc:
            query = query.orderBy('price', descending: true);
            break;
          case SortOption.ratingDesc:
            query = query.orderBy('rating', descending: true);
            break;
          case SortOption.newest:
            query = query.orderBy('createdAt', descending: true);
            break;
          case SortOption.popular:
            query = query.orderBy('reviewCount', descending: true);
            break;
          case SortOption.nameAsc:
            query = query.orderBy('name', descending: false);
            break;
          case SortOption.nameDesc:
            query = query.orderBy('name', descending: true);
            break;
          case SortOption.relevance:
            query = query.orderBy('createdAt', descending: true);
            break;
        }
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      final totalSnapshot = await query.get();
      final totalCount = totalSnapshot.docs.length;

      // Apply pagination
      final pageSize = filter?.limit ?? 20;
      final currentPage = filter?.page ?? 1;

      Query paginatedQuery = query;
      if (currentPage > 1) {
        final skipCount = (currentPage - 1) * pageSize;
        if (skipCount < totalCount) {
          final skipSnapshot = await query.limit(skipCount).get();
          if (skipSnapshot.docs.isNotEmpty) {
            paginatedQuery = query.startAfterDocument(skipSnapshot.docs.last);
          }
        }
      }

      final snapshot = await paginatedQuery.limit(pageSize).get();
      final products = snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();

      final totalPages = (totalCount / pageSize).ceil();

      return ProductSearchResult(
        products: products.map((p) => p.toEntity()).toList(),
        totalCount: totalCount,
        currentPage: currentPage,
        totalPages: totalPages,
        hasNextPage: currentPage < totalPages,
        hasPreviousPage: currentPage > 1,
      );
    } catch (e) {
      throw Exception('Failed to get products by brand: $e');
    }
  }

  @override
  Future<List<BrandModel>> getBrands() async {
    try {
      final snapshot = await _brandsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return snapshot.docs.map(_parseBrandFromDoc).toList();
    } catch (e) {
      throw Exception('Failed to get brands: $e');
    }
  }

  @override
  Future<List<BrandModel>> getFeaturedBrands({int limit = 10}) async {
    try {
      final snapshot = await _brandsCollection
          .where('isActive', isEqualTo: true)
          .where('isFeatured', isEqualTo: true)
          .orderBy('averageRating', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs.map(_parseBrandFromDoc).toList();
    } catch (e) {
      throw Exception('Failed to get featured brands: $e');
    }
  }

  @override
  Future<BrandModel?> getBrandById(String id) async {
    try {
      final doc = await _brandsCollection.doc(id).get();
      if (doc.exists) {
        return _parseBrandFromDocSnapshot(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get brand by ID: $e');
    }
  }

  @override
  Future<ProductSearchResult> searchProducts(
    String query, {
    ProductFilter? filter,
  }) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation using array-contains for tags
      Query firestoreQuery = _productsCollection.where(
        'isActive',
        isEqualTo: true,
      );

      // Search in tags (basic text search)
      if (query.isNotEmpty) {
        final searchTerms = query.toLowerCase().split(' ');
        // This is a simplified search - in production, use Algolia or similar
        firestoreQuery = firestoreQuery.where(
          'tags',
          arrayContainsAny: searchTerms,
        );
      }

      if (filter != null) {
        // Apply filters
        if (filter.categoryIds.isNotEmpty) {
          firestoreQuery = firestoreQuery.where(
            'categoryId',
            whereIn: filter.categoryIds,
          );
        }

        if (filter.brandIds.isNotEmpty) {
          firestoreQuery = firestoreQuery.where(
            'brandId',
            whereIn: filter.brandIds,
          );
        }

        if (filter.priceRange.hasRange) {
          if (filter.priceRange.minPrice != null) {
            firestoreQuery = firestoreQuery.where(
              'price',
              isGreaterThanOrEqualTo: filter.priceRange.minPrice,
            );
          }
          if (filter.priceRange.maxPrice != null) {
            firestoreQuery = firestoreQuery.where(
              'price',
              isLessThanOrEqualTo: filter.priceRange.maxPrice,
            );
          }
        }

        if (filter.minRating != null) {
          firestoreQuery = firestoreQuery.where(
            'rating',
            isGreaterThanOrEqualTo: filter.minRating,
          );
        }

        // Apply sorting
        switch (filter.sortBy) {
          case SortOption.priceAsc:
            firestoreQuery = firestoreQuery.orderBy('price', descending: false);
            break;
          case SortOption.priceDesc:
            firestoreQuery = firestoreQuery.orderBy('price', descending: true);
            break;
          case SortOption.ratingDesc:
            firestoreQuery = firestoreQuery.orderBy('rating', descending: true);
            break;
          case SortOption.newest:
            firestoreQuery = firestoreQuery.orderBy(
              'createdAt',
              descending: true,
            );
            break;
          case SortOption.popular:
            firestoreQuery = firestoreQuery.orderBy(
              'reviewCount',
              descending: true,
            );
            break;
          case SortOption.nameAsc:
            firestoreQuery = firestoreQuery.orderBy('name', descending: false);
            break;
          case SortOption.nameDesc:
            firestoreQuery = firestoreQuery.orderBy('name', descending: true);
            break;
          case SortOption.relevance:
            firestoreQuery = firestoreQuery.orderBy(
              'createdAt',
              descending: true,
            );
            break;
        }
      } else {
        firestoreQuery = firestoreQuery.orderBy('createdAt', descending: true);
      }

      final totalSnapshot = await firestoreQuery.get();
      final allProducts = totalSnapshot.docs
          .map(
            (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Client-side filtering for better search results
      List<ProductModel> filteredProducts = allProducts;
      if (query.isNotEmpty) {
        final searchQuery = query.toLowerCase();
        filteredProducts = allProducts.where((product) {
          return product.name.toLowerCase().contains(searchQuery) ||
              product.description.toLowerCase().contains(searchQuery) ||
              product.brandName.toLowerCase().contains(searchQuery) ||
              product.tags.any(
                (tag) => tag.toLowerCase().contains(searchQuery),
              );
        }).toList();
      }

      final totalCount = filteredProducts.length;
      final pageSize = filter?.limit ?? 20;
      final currentPage = filter?.page ?? 1;
      final startIndex = (currentPage - 1) * pageSize;
      final endIndex = (startIndex + pageSize).clamp(0, totalCount);

      final paginatedProducts = filteredProducts.sublist(
        startIndex.clamp(0, totalCount),
        endIndex,
      );

      final totalPages = (totalCount / pageSize).ceil();

      return ProductSearchResult(
        products: paginatedProducts.map((p) => p.toEntity()).toList(),
        totalCount: totalCount,
        currentPage: currentPage,
        totalPages: totalPages,
        hasNextPage: currentPage < totalPages,
        hasPreviousPage: currentPage > 1,
      );
    } catch (e) {
      throw Exception('Failed to search products: $e');
    }
  }

  @override
  Future<List<String>> getSearchSuggestions(
    String query, {
    int limit = 5,
  }) async {
    try {
      if (query.isEmpty) return [];

      final snapshot = await _productsCollection
          .where('isActive', isEqualTo: true)
          .limit(50) // Get more products to generate suggestions
          .get();

      final products = snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();

      final suggestions = <String>{};
      final searchQuery = query.toLowerCase();

      for (final product in products) {
        // Add product name if it contains the query
        if (product.name.toLowerCase().contains(searchQuery)) {
          suggestions.add(product.name);
        }

        // Add brand name if it contains the query
        if (product.brandName.toLowerCase().contains(searchQuery)) {
          suggestions.add(product.brandName);
        }

        // Add relevant tags
        for (final tag in product.tags) {
          if (tag.toLowerCase().contains(searchQuery)) {
            suggestions.add(tag);
          }
        }

        if (suggestions.length >= limit * 2) break;
      }

      return suggestions.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get search suggestions: $e');
    }
  }

  @override
  Future<List<ReviewModel>> getProductReviews(
    String productId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Query query = _reviewsCollection
          .where('productId', isEqualTo: productId)
          .orderBy('createdAt', descending: true);

      // Apply pagination
      if (page > 1) {
        final skipCount = (page - 1) * limit;
        final skipSnapshot = await query.limit(skipCount).get();
        if (skipSnapshot.docs.isNotEmpty) {
          query = query.startAfterDocument(skipSnapshot.docs.last);
        }
      }

      final snapshot = await query.limit(limit).get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ReviewModel.fromMap(data);
      }).toList();
    } catch (e) {
      throw Exception('Failed to get product reviews: $e');
    }
  }

  @override
  Future<ReviewModel?> getReviewById(String id) async {
    try {
      final doc = await _reviewsCollection.doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return ReviewModel.fromMap(data);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get review by ID: $e');
    }
  }

  @override
  Future<ReviewModel> createReview(ReviewModel review) async {
    try {
      final docRef = _reviewsCollection.doc(review.id);
      await docRef.set(review.toJson());

      // Update product review count and rating
      await _updateProductReviewStats(review.productId);

      return review;
    } catch (e) {
      throw Exception('Failed to create review: $e');
    }
  }

  @override
  Future<ReviewModel> updateReview(ReviewModel review) async {
    try {
      await _reviewsCollection.doc(review.id).update(review.toJson());

      // Update product review stats
      await _updateProductReviewStats(review.productId);

      return review;
    } catch (e) {
      throw Exception('Failed to update review: $e');
    }
  }

  @override
  Future<void> deleteReview(String id) async {
    try {
      final reviewDoc = await _reviewsCollection.doc(id).get();
      if (reviewDoc.exists) {
        final reviewData = reviewDoc.data() as Map<String, dynamic>;
        final productId = reviewData['productId'] as String;

        await _reviewsCollection.doc(id).delete();

        // Update product review stats
        await _updateProductReviewStats(productId);
      }
    } catch (e) {
      throw Exception('Failed to delete review: $e');
    }
  }

  @override
  Future<void> markReviewHelpful(String reviewId, bool isHelpful) async {
    try {
      final reviewDoc = await _reviewsCollection.doc(reviewId).get();
      if (reviewDoc.exists) {
        final reviewData = reviewDoc.data() as Map<String, dynamic>;
        final currentHelpfulCount = reviewData['helpfulCount'] as int? ?? 0;
        final currentNotHelpfulCount =
            reviewData['notHelpfulCount'] as int? ?? 0;

        final updates = <String, dynamic>{'isHelpful': isHelpful};

        if (isHelpful) {
          updates['helpfulCount'] = currentHelpfulCount + 1;
        } else {
          updates['notHelpfulCount'] = currentNotHelpfulCount + 1;
        }

        await _reviewsCollection.doc(reviewId).update(updates);
      }
    } catch (e) {
      throw Exception('Failed to mark review helpful: $e');
    }
  }

  // Helper method to update product review statistics
  Future<void> _updateProductReviewStats(String productId) async {
    try {
      final reviewsSnapshot = await _reviewsCollection
          .where('productId', isEqualTo: productId)
          .get();

      final reviews = reviewsSnapshot.docs;
      final reviewCount = reviews.length;

      if (reviewCount > 0) {
        final totalRating = reviews.fold<double>(0.0, (total, doc) {
          final data = doc.data() as Map<String, dynamic>;
          return total + (data['rating'] as num).toDouble();
        });
        final averageRating = totalRating / reviewCount;

        await _productsCollection.doc(productId).update({
          'reviewCount': reviewCount,
          'rating': averageRating,
        });
      } else {
        await _productsCollection.doc(productId).update({
          'reviewCount': 0,
          'rating': 0.0,
        });
      }
    } catch (e) {
      // Log error in production using proper logging framework
      print('Error updating product review stats: $e');
    }
  }

  @override
  Future<bool> isProductInStock(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final stockQuantity = data['stockQuantity'] as int? ?? 0;
        return stockQuantity > 0;
      }
      return false;
    } catch (e) {
      throw Exception('Failed to check product stock: $e');
    }
  }

  @override
  Future<int> getProductStock(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['stockQuantity'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      throw Exception('Failed to get product stock: $e');
    }
  }

  @override
  Future<List<ProductModel>> getLowStockProducts({int limit = 20}) async {
    try {
      final snapshot = await _productsCollection
          .where('isActive', isEqualTo: true)
          .where('stockQuantity', isGreaterThan: 0)
          .where(
            'stockQuantity',
            isLessThanOrEqualTo: 10,
          ) // Low stock threshold
          .orderBy('stockQuantity')
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get low stock products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getOutOfStockProducts({int limit = 20}) async {
    try {
      final snapshot = await _productsCollection
          .where('isActive', isEqualTo: true)
          .where('stockQuantity', isEqualTo: 0)
          .orderBy('updatedAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get out of stock products: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsForVehicle(
    String vehicleModel, {
    ProductFilter? filter,
  }) async {
    try {
      Query query = _productsCollection
          .where('isActive', isEqualTo: true)
          .where('compatibleVehicles', arrayContains: vehicleModel);

      if (filter != null) {
        // Apply additional filters
        if (filter.categoryIds.isNotEmpty) {
          query = query.where('categoryId', whereIn: filter.categoryIds);
        }

        if (filter.brandIds.isNotEmpty) {
          query = query.where('brandId', whereIn: filter.brandIds);
        }

        if (filter.priceRange.hasRange) {
          if (filter.priceRange.minPrice != null) {
            query = query.where(
              'price',
              isGreaterThanOrEqualTo: filter.priceRange.minPrice,
            );
          }
          if (filter.priceRange.maxPrice != null) {
            query = query.where(
              'price',
              isLessThanOrEqualTo: filter.priceRange.maxPrice,
            );
          }
        }

        // Apply sorting
        switch (filter.sortBy) {
          case SortOption.priceAsc:
            query = query.orderBy('price', descending: false);
            break;
          case SortOption.priceDesc:
            query = query.orderBy('price', descending: true);
            break;
          case SortOption.ratingDesc:
            query = query.orderBy('rating', descending: true);
            break;
          case SortOption.newest:
            query = query.orderBy('createdAt', descending: true);
            break;
          case SortOption.popular:
            query = query.orderBy('reviewCount', descending: true);
            break;
          case SortOption.nameAsc:
            query = query.orderBy('name', descending: false);
            break;
          case SortOption.nameDesc:
            query = query.orderBy('name', descending: true);
            break;
          case SortOption.relevance:
            query = query.orderBy('createdAt', descending: true);
            break;
        }
      } else {
        query = query.orderBy('createdAt', descending: true);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to get products for vehicle: $e');
    }
  }

  @override
  Future<List<String>> getCompatibleVehicles(String productId) async {
    try {
      final doc = await _productsCollection.doc(productId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final compatibleVehicles = data['compatibleVehicles'] as List<dynamic>?;
        return compatibleVehicles?.cast<String>() ?? [];
      }
      return [];
    } catch (e) {
      throw Exception('Failed to get compatible vehicles: $e');
    }
  }

  @override
  Future<ProductSearchResult> getProductsInPriceRange(
    double minPrice,
    double maxPrice, {
    ProductFilter? filter,
  }) async {
    try {
      Query query = _productsCollection
          .where('isActive', isEqualTo: true)
          .where('price', isGreaterThanOrEqualTo: minPrice)
          .where('price', isLessThanOrEqualTo: maxPrice);

      if (filter != null) {
        // Apply additional filters
        if (filter.categoryIds.isNotEmpty) {
          query = query.where('categoryId', whereIn: filter.categoryIds);
        }

        if (filter.brandIds.isNotEmpty) {
          query = query.where('brandId', whereIn: filter.brandIds);
        }

        if (filter.minRating != null) {
          query = query.where(
            'rating',
            isGreaterThanOrEqualTo: filter.minRating,
          );
        }

        // Apply sorting
        switch (filter.sortBy) {
          case SortOption.priceAsc:
            query = query.orderBy('price', descending: false);
            break;
          case SortOption.priceDesc:
            query = query.orderBy('price', descending: true);
            break;
          case SortOption.ratingDesc:
            query = query.orderBy('rating', descending: true);
            break;
          case SortOption.newest:
            query = query.orderBy('createdAt', descending: true);
            break;
          case SortOption.popular:
            query = query.orderBy('reviewCount', descending: true);
            break;
          case SortOption.nameAsc:
            query = query.orderBy('name', descending: false);
            break;
          case SortOption.nameDesc:
            query = query.orderBy('name', descending: true);
            break;
          case SortOption.relevance:
            query = query.orderBy('price', descending: false);
            break;
        }
      } else {
        query = query.orderBy('price', descending: false);
      }

      final totalSnapshot = await query.get();
      final totalCount = totalSnapshot.docs.length;

      // Apply pagination
      final pageSize = filter?.limit ?? 20;
      final currentPage = filter?.page ?? 1;

      Query paginatedQuery = query;
      if (currentPage > 1) {
        final skipCount = (currentPage - 1) * pageSize;
        if (skipCount < totalCount) {
          final skipSnapshot = await query.limit(skipCount).get();
          if (skipSnapshot.docs.isNotEmpty) {
            paginatedQuery = query.startAfterDocument(skipSnapshot.docs.last);
          }
        }
      }

      final snapshot = await paginatedQuery.limit(pageSize).get();
      final products = snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();

      final totalPages = (totalCount / pageSize).ceil();

      return ProductSearchResult(
        products: products.map((p) => p.toEntity()).toList(),
        totalCount: totalCount,
        currentPage: currentPage,
        totalPages: totalPages,
        hasNextPage: currentPage < totalPages,
        hasPreviousPage: currentPage > 1,
      );
    } catch (e) {
      throw Exception('Failed to get products in price range: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsOnSale({
    ProductFilter? filter,
    int limit = 20,
  }) async {
    try {
      Query query = _productsCollection
          .where('isActive', isEqualTo: true)
          .where('originalPrice', isNull: false);

      if (filter != null) {
        // Apply additional filters
        if (filter.categoryIds.isNotEmpty) {
          query = query.where('categoryId', whereIn: filter.categoryIds);
        }

        if (filter.brandIds.isNotEmpty) {
          query = query.where('brandId', whereIn: filter.brandIds);
        }

        if (filter.priceRange.hasRange) {
          if (filter.priceRange.minPrice != null) {
            query = query.where(
              'price',
              isGreaterThanOrEqualTo: filter.priceRange.minPrice,
            );
          }
          if (filter.priceRange.maxPrice != null) {
            query = query.where(
              'price',
              isLessThanOrEqualTo: filter.priceRange.maxPrice,
            );
          }
        }

        if (filter.minRating != null) {
          query = query.where(
            'rating',
            isGreaterThanOrEqualTo: filter.minRating,
          );
        }
      }

      // Order by discount percentage (calculated client-side)
      final snapshot = await query
          .limit(limit * 2)
          .get(); // Get more to sort by discount
      final products = snapshot.docs
          .map(
            (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>),
          )
          .toList();

      // Sort by discount percentage
      products.sort((a, b) {
        final discountA = a.originalPrice != null
            ? ((a.originalPrice! - a.price) / a.originalPrice!) * 100
            : 0.0;
        final discountB = b.originalPrice != null
            ? ((b.originalPrice! - b.price) / b.originalPrice!) * 100
            : 0.0;
        return discountB.compareTo(discountA);
      });

      return products.take(limit).toList();
    } catch (e) {
      throw Exception('Failed to get products on sale: $e');
    }
  }

  @override
  Future<void> trackProductView(String productId) async {
    try {
      final timestamp = DateTime.now();
      await _analyticsCollection.add({
        'type': 'product_view',
        'productId': productId,
        'timestamp': timestamp,
        'date': timestamp.toIso8601String().split('T')[0], // YYYY-MM-DD format
      });
    } catch (e) {
      // Don't throw error for analytics - just log it
      print('Failed to track product view: $e');
    }
  }

  @override
  Future<void> trackProductSearch(String query) async {
    try {
      final timestamp = DateTime.now();
      await _analyticsCollection.add({
        'type': 'product_search',
        'query': query,
        'timestamp': timestamp,
        'date': timestamp.toIso8601String().split('T')[0],
      });
    } catch (e) {
      print('Failed to track product search: $e');
    }
  }

  @override
  Future<void> trackCategoryView(String categoryId) async {
    try {
      final timestamp = DateTime.now();
      await _analyticsCollection.add({
        'type': 'category_view',
        'categoryId': categoryId,
        'timestamp': timestamp,
        'date': timestamp.toIso8601String().split('T')[0],
      });
    } catch (e) {
      print('Failed to track category view: $e');
    }
  }

  @override
  Future<void> trackBrandView(String brandId) async {
    try {
      final timestamp = DateTime.now();
      await _analyticsCollection.add({
        'type': 'brand_view',
        'brandId': brandId,
        'timestamp': timestamp,
        'date': timestamp.toIso8601String().split('T')[0],
      });
    } catch (e) {
      print('Failed to track brand view: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByIds(List<String> productIds) async {
    try {
      if (productIds.isEmpty) return [];

      // Firestore 'in' queries are limited to 10 items
      final chunks = <List<String>>[];
      for (int i = 0; i < productIds.length; i += 10) {
        chunks.add(productIds.sublist(i, (i + 10).clamp(0, productIds.length)));
      }

      final allProducts = <ProductModel>[];
      for (final chunk in chunks) {
        final snapshot = await _productsCollection
            .where('id', whereIn: chunk)
            .where('isActive', isEqualTo: true)
            .get();

        final products = snapshot.docs
            .map(
              (doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>),
            )
            .toList();

        allProducts.addAll(products);
      }

      return allProducts;
    } catch (e) {
      throw Exception('Failed to get products by IDs: $e');
    }
  }

  @override
  Future<Map<String, bool>> checkProductsAvailability(
    List<String> productIds,
  ) async {
    try {
      final products = await getProductsByIds(productIds);
      final availability = <String, bool>{};

      for (final productId in productIds) {
        final product = products.firstWhere(
          (p) => p.id == productId,
          orElse: () => throw StateError('Product not found'),
        );
        availability[productId] = product.stockQuantity > 0;
      }

      // Set unavailable for products not found
      for (final productId in productIds) {
        availability.putIfAbsent(productId, () => false);
      }

      return availability;
    } catch (e) {
      throw Exception('Failed to check products availability: $e');
    }
  }

  @override
  Future<Map<String, int>> getProductsStock(List<String> productIds) async {
    try {
      final products = await getProductsByIds(productIds);
      final stock = <String, int>{};

      for (final productId in productIds) {
        try {
          final product = products.firstWhere((p) => p.id == productId);
          stock[productId] = product.stockQuantity;
        } catch (e) {
          stock[productId] = 0; // Product not found or inactive
        }
      }

      return stock;
    } catch (e) {
      throw Exception('Failed to get products stock: $e');
    }
  }
}
