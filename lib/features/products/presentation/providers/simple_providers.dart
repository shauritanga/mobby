import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/brand.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/wishlist.dart';
import '../../domain/entities/review.dart';

// Mock data for development
final _mockCategories = <String, Category>{
  'engine': Category(
    id: 'engine',
    name: 'Engine Parts',
    description: 'Engine components and accessories',
    imageUrl: 'https://example.com/engine-category.jpg',
    productCount: 150,
    subcategories: [
      Category(id: 'pistons', name: 'Pistons', productCount: 25),
      Category(id: 'valves', name: 'Valves', productCount: 30),
      Category(id: 'gaskets', name: 'Gaskets', productCount: 45),
      Category(id: 'filters', name: 'Filters', productCount: 50),
    ],
  ),
  'brakes': Category(
    id: 'brakes',
    name: 'Brake System',
    description: 'Brake components and accessories',
    imageUrl: 'https://example.com/brake-category.jpg',
    productCount: 120,
    subcategories: [
      Category(id: 'brake-pads', name: 'Brake Pads', productCount: 40),
      Category(id: 'brake-discs', name: 'Brake Discs', productCount: 35),
      Category(id: 'brake-fluid', name: 'Brake Fluid', productCount: 45),
    ],
  ),
};

final _mockBrands = <String, Brand>{
  'mobil': Brand(
    id: 'mobil',
    name: 'Mobil',
    description: 'Premium automotive lubricants and oils',
    logoUrl: 'https://example.com/mobil-logo.jpg',
    websiteUrl: 'https://www.mobil.com',
    countryOfOrigin: 'USA',
    isActive: true,
    isFeatured: true,
    productCount: 85,
    averageRating: 4.6,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    imageUrl: 'https://example.com/mobil-banner.jpg',
    isVerified: true,
    rating: 4.6,
    reviewCount: 1250,
    email: 'contact@mobil.com',
    phone: '+1-800-MOBIL-1',
  ),
  'brembo': Brand(
    id: 'brembo',
    name: 'Brembo',
    description: 'World leader in brake technology',
    logoUrl: 'https://example.com/brembo-logo.jpg',
    websiteUrl: 'https://www.brembo.com',
    countryOfOrigin: 'Italy',
    isActive: true,
    isFeatured: true,
    productCount: 65,
    averageRating: 4.8,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    imageUrl: 'https://example.com/brembo-banner.jpg',
    isVerified: true,
    rating: 4.8,
    reviewCount: 890,
    email: 'info@brembo.com',
    phone: '+39-035-6061',
  ),
  'kn': Brand(
    id: 'kn',
    name: 'K&N',
    description: 'High-performance air filters',
    logoUrl: 'https://example.com/kn-logo.jpg',
    websiteUrl: 'https://www.knfilters.com',
    countryOfOrigin: 'USA',
    isActive: true,
    isFeatured: true,
    productCount: 45,
    averageRating: 4.5,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
    imageUrl: 'https://example.com/kn-banner.jpg',
    isVerified: true,
    rating: 4.5,
    reviewCount: 650,
    email: 'support@knfilters.com',
    phone: '+1-800-858-3333',
  ),
};

final _mockProducts = <Product>[
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
  Product(
    id: '3',
    name: 'Brake Pads Set',
    description: 'Premium ceramic brake pads for superior stopping power.',
    price: 45000,
    originalPrice: 50000,
    currency: 'TZS',
    imageUrl: 'https://example.com/brake-pads.jpg',
    imageUrls: ['https://example.com/brake-pads.jpg'],
    categoryId: 'brakes',
    categoryName: 'Brake System',
    brandId: 'brembo',
    brandName: 'Brembo',
    sku: 'BRE-BP-CER-001',
    stockQuantity: 0,
    stockStatus: StockStatus.outOfStock,
    condition: ProductCondition.new_,
    rating: 4.8,
    reviewCount: 156,
    isFeatured: true,
    isActive: true,
    isDigital: false,
    requiresShipping: true,
    tags: ['brake', 'pads', 'ceramic'],
    specifications: {'material': 'Ceramic', 'set': 'Front'},
    compatibleVehicles: ['BMW 3 Series', 'Audi A4'],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  ),
];

final _mockWishlists = <String, Wishlist>{};

// Mock reviews data
final _mockReviews = <String, List<Review>>{
  '1': [
    Review(
      id: 'review_1_1',
      productId: '1',
      userId: 'user_1',
      userName: 'John Doe',
      rating: 5.0,
      title: 'Excellent Engine Oil',
      comment:
          'This engine oil has significantly improved my car\'s performance. Highly recommended!',
      imageUrls: const [],
      isVerifiedPurchase: true,
      isHelpful: false,
      helpfulCount: 12,
      notHelpfulCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
      updatedAt: DateTime.now().subtract(const Duration(days: 15)),
    ),
    Review(
      id: 'review_1_2',
      productId: '1',
      userId: 'user_2',
      userName: 'Sarah Johnson',
      rating: 4.0,
      title: 'Good quality oil',
      comment: 'Works well for my vehicle. Good value for money.',
      imageUrls: const [],
      isVerifiedPurchase: true,
      isHelpful: false,
      helpfulCount: 8,
      notHelpfulCount: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 8)),
      updatedAt: DateTime.now().subtract(const Duration(days: 8)),
    ),
    Review(
      id: 'review_1_3',
      productId: '1',
      userId: 'user_3',
      userName: 'Mike Wilson',
      rating: 5.0,
      title: 'Perfect for my Toyota',
      comment:
          'Been using this for 6 months now. Engine runs smoother and quieter.',
      imageUrls: const ['https://example.com/review-image-1.jpg'],
      isVerifiedPurchase: true,
      isHelpful: false,
      helpfulCount: 15,
      notHelpfulCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
      updatedAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ],
  '2': [
    Review(
      id: 'review_2_1',
      productId: '2',
      userId: 'user_4',
      userName: 'Lisa Chen',
      rating: 4.0,
      title: 'Great air filter',
      comment: 'Easy to install and noticeable improvement in air flow.',
      imageUrls: const [],
      isVerifiedPurchase: true,
      isHelpful: false,
      helpfulCount: 6,
      notHelpfulCount: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 12)),
      updatedAt: DateTime.now().subtract(const Duration(days: 12)),
    ),
    Review(
      id: 'review_2_2',
      productId: '2',
      userId: 'user_5',
      userName: 'David Brown',
      rating: 5.0,
      title: 'K&N quality as expected',
      comment:
          'Excellent build quality. Worth the investment for better engine performance.',
      imageUrls: const [],
      isVerifiedPurchase: true,
      isHelpful: false,
      helpfulCount: 9,
      notHelpfulCount: 0,
      createdAt: DateTime.now().subtract(const Duration(days: 20)),
      updatedAt: DateTime.now().subtract(const Duration(days: 20)),
    ),
  ],
  '3': [
    Review(
      id: 'review_3_1',
      productId: '3',
      userId: 'user_6',
      userName: 'Emma Davis',
      rating: 5.0,
      title: 'Outstanding brake pads',
      comment:
          'Brembo quality is unmatched. Excellent stopping power and very quiet.',
      imageUrls: const [],
      isVerifiedPurchase: true,
      isHelpful: false,
      helpfulCount: 18,
      notHelpfulCount: 1,
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now().subtract(const Duration(days: 30)),
    ),
    Review(
      id: 'review_3_2',
      productId: '3',
      userId: 'user_7',
      userName: 'Robert Taylor',
      rating: 4.0,
      title: 'Good brake pads',
      comment:
          'Solid performance, though a bit pricey. But you get what you pay for.',
      imageUrls: const [],
      isVerifiedPurchase: false,
      isHelpful: false,
      helpfulCount: 5,
      notHelpfulCount: 2,
      createdAt: DateTime.now().subtract(const Duration(days: 18)),
      updatedAt: DateTime.now().subtract(const Duration(days: 18)),
    ),
  ],
};

// Simple providers using FutureProvider.family
final categoryProvider = FutureProvider.family<Category?, String>((
  ref,
  categoryId,
) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockCategories[categoryId];
});

final categoryProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  categoryId,
) async {
  await Future.delayed(const Duration(milliseconds: 500));
  return _mockProducts
      .where(
        (product) => product.categoryName.toLowerCase().contains(
          categoryId.toLowerCase(),
        ),
      )
      .toList();
});

final brandProvider = FutureProvider.family<Brand?, String>((
  ref,
  brandId,
) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockBrands[brandId];
});

final brandProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  brandId,
) async {
  await Future.delayed(const Duration(milliseconds: 500));
  final brand = _mockBrands[brandId];
  if (brand == null) return [];

  return _mockProducts
      .where(
        (product) =>
            product.brandName.toLowerCase() == brand.name.toLowerCase(),
      )
      .toList();
});

final brandPopularProductsProvider =
    FutureProvider.family<List<Product>, String>((ref, brandId) async {
      await Future.delayed(const Duration(milliseconds: 500));
      final brand = _mockBrands[brandId];
      if (brand == null) return [];

      return _mockProducts
          .where(
            (product) =>
                product.brandName.toLowerCase() == brand.name.toLowerCase() &&
                product.rating >= 4.5,
          )
          .toList();
    });

final brandNewArrivalsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  brandId,
) async {
  await Future.delayed(const Duration(milliseconds: 500));
  final brand = _mockBrands[brandId];
  if (brand == null) return [];

  return _mockProducts
      .where(
        (product) =>
            product.brandName.toLowerCase() == brand.name.toLowerCase(),
      )
      .take(3)
      .toList();
});

final brandsProvider = FutureProvider<List<Brand>>((ref) async {
  await Future.delayed(const Duration(milliseconds: 300));
  return _mockBrands.values.toList();
});

// Related products provider - returns products similar to the given product
final relatedProductsProvider = FutureProvider.family<List<Product>, String>((
  ref,
  productId,
) async {
  await Future.delayed(const Duration(milliseconds: 500));

  // Get the current product to find related ones
  final currentProduct = _mockProducts.firstWhere(
    (p) => p.id == productId,
    orElse: () => _mockProducts.first,
  );

  // Find products in the same category or with similar tags
  final relatedProducts = _mockProducts
      .where(
        (product) =>
            product.id != productId && // Exclude the current product
            (product.categoryId == currentProduct.categoryId ||
                product.brandId == currentProduct.brandId ||
                product.tags.any((tag) => currentProduct.tags.contains(tag))),
      )
      .take(6) // Limit to 6 related products
      .toList();

  return relatedProducts;
});

// Frequently bought together provider - returns products often bought with the given product
final frequentlyBoughtTogetherProvider =
    FutureProvider.family<List<Product>, String>((ref, productId) async {
      await Future.delayed(const Duration(milliseconds: 500));

      // Get the current product
      final currentProduct = _mockProducts.firstWhere(
        (p) => p.id == productId,
        orElse: () => _mockProducts.first,
      );

      // Mock logic: find products that are commonly bought together
      // In a real app, this would come from purchase history analytics
      final bundleProducts = _mockProducts
          .where(
            (product) =>
                product.id != productId && // Exclude the current product
                (product.categoryId == currentProduct.categoryId ||
                    product.brandId == currentProduct.brandId) &&
                product.rating >= 4.0,
          ) // Only include well-rated products
          .take(4) // Limit to 4 bundle products
          .toList();

      return bundleProducts;
    });

final userWishlistProvider = FutureProvider.family<Wishlist, String>((
  ref,
  userId,
) async {
  await Future.delayed(const Duration(milliseconds: 300));

  return _mockWishlists[userId] ??
      Wishlist(
        id: 'wishlist_$userId',
        userId: userId,
        products: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
});

// Product reviews provider
final productReviewsProvider = FutureProvider.family<List<Review>, String>((
  ref,
  productId,
) async {
  await Future.delayed(const Duration(milliseconds: 400));
  return _mockReviews[productId] ?? [];
});

// Extension methods for actions
extension SimpleProviderActions on WidgetRef {
  void addToWishlist(String userId, String productId) {
    final product = _mockProducts.firstWhere((p) => p.id == productId);
    final currentWishlist =
        _mockWishlists[userId] ??
        Wishlist(
          id: 'wishlist_$userId',
          userId: userId,
          products: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

    if (!currentWishlist.products.any((p) => p.id == productId)) {
      _mockWishlists[userId] = currentWishlist.copyWith(
        products: [...currentWishlist.products, product],
        updatedAt: DateTime.now(),
      );
      invalidate(userWishlistProvider(userId));
    }
  }

  void removeFromWishlist(String userId, String productId) {
    final currentWishlist = _mockWishlists[userId];
    if (currentWishlist != null) {
      _mockWishlists[userId] = currentWishlist.copyWith(
        products: currentWishlist.products
            .where((p) => p.id != productId)
            .toList(),
        updatedAt: DateTime.now(),
      );
      invalidate(userWishlistProvider(userId));
    }
  }

  void clearWishlist(String userId) {
    final currentWishlist = _mockWishlists[userId];
    if (currentWishlist != null) {
      _mockWishlists[userId] = currentWishlist.copyWith(
        products: [],
        updatedAt: DateTime.now(),
      );
      invalidate(userWishlistProvider(userId));
    }
  }

  void toggleFollowBrand(String userId, String brandId) {
    // Mock implementation
  }

  bool isBrandFollowed(String brandId) {
    // Mock implementation
    return false;
  }

  void addToCart(Product product, int quantity) {
    // Mock implementation - this would be handled by cart providers
  }
}
