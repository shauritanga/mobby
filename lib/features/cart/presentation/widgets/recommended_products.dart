import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/cart_item.dart';
import '../../../products/domain/entities/product.dart';

class RecommendedProducts extends StatelessWidget {
  final List<CartItem> cartItems;
  final ValueChanged<String>? onProductTap;
  final ValueChanged<String>? onAddToCart;

  const RecommendedProducts({
    super.key,
    required this.cartItems,
    this.onProductTap,
    this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    // Mock recommended products based on cart items
    final recommendedProducts = _getRecommendedProducts();

    if (recommendedProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(
                  Icons.recommend,
                  size: 20.sp,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Recommended for You',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).textTheme.headlineSmall?.color,
                  ),
                ),
              ],
            ),
          ),

          // Products list
          SizedBox(
            height: 200.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: recommendedProducts.length,
              itemBuilder: (context, index) {
                final product = recommendedProducts[index];
                return Padding(
                  padding: EdgeInsets.only(right: 12.w),
                  child: _buildRecommendedProductCard(context, product),
                );
              },
            ),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildRecommendedProductCard(BuildContext context, Product product) {
    return GestureDetector(
      onTap: () => onProductTap?.call(product.id),
      child: Container(
        width: 140.w,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r),
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12.r),
                        topRight: Radius.circular(12.r),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: product.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image),
                        ),
                      ),
                    ),
                  ),

                  // Sale badge
                  if (product.isOnSale)
                    Positioned(
                      top: 6.h,
                      left: 6.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'SALE',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Product info
            Expanded(
              flex: 2,
              child: Padding(
                padding: EdgeInsets.all(8.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product name
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    SizedBox(height: 4.h),

                    // Price
                    Row(
                      children: [
                        Text(
                          'TZS ${_formatPrice(product.price)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),

                        if (product.isOnSale &&
                            product.originalPrice != null) ...[
                          SizedBox(width: 4.w),
                          Text(
                            'TZS ${_formatPrice(product.originalPrice!)}',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Theme.of(context).hintColor,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const Spacer(),

                    // Add to cart button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => onAddToCart?.call(product.id),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 4.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                        ),
                        child: Text('Add', style: TextStyle(fontSize: 10.sp)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Product> _getRecommendedProducts() {
    // Mock implementation - in real app, this would come from a recommendation service
    return [
      Product(
        id: 'rec1',
        name: 'Premium Engine Oil',
        description: 'High-quality engine oil',
        price: 25000,
        originalPrice: 30000,
        currency: 'TZS',
        imageUrl: 'https://example.com/engine-oil.jpg',
        imageUrls: ['https://example.com/engine-oil.jpg'],
        categoryId: 'engine',
        categoryName: 'Engine Parts',
        brandId: 'mobil',
        brandName: 'Mobil',
        sku: 'REC-EO-001',
        stockQuantity: 10,
        stockStatus: StockStatus.inStock,
        condition: ProductCondition.new_,
        rating: 4.5,
        reviewCount: 50,
        isFeatured: false,
        isActive: true,
        isDigital: false,
        requiresShipping: true,
        tags: ['engine', 'oil'],
        specifications: {},
        compatibleVehicles: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'rec2',
        name: 'Air Filter',
        description: 'High-performance air filter',
        price: 15000,
        currency: 'TZS',
        imageUrl: 'https://example.com/air-filter.jpg',
        imageUrls: ['https://example.com/air-filter.jpg'],
        categoryId: 'engine',
        categoryName: 'Engine Parts',
        brandId: 'kn',
        brandName: 'K&N',
        sku: 'REC-AF-001',
        stockQuantity: 5,
        stockStatus: StockStatus.inStock,
        condition: ProductCondition.new_,
        rating: 4.3,
        reviewCount: 30,
        isFeatured: false,
        isActive: true,
        isDigital: false,
        requiresShipping: true,
        tags: ['air', 'filter'],
        specifications: {},
        compatibleVehicles: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class FrequentlyBoughtTogether extends StatelessWidget {
  final List<CartItem> cartItems;
  final ValueChanged<List<String>>? onAddBundle;

  const FrequentlyBoughtTogether({
    super.key,
    required this.cartItems,
    this.onAddBundle,
  });

  @override
  Widget build(BuildContext context) {
    final bundleProducts = _getBundleProducts();

    if (bundleProducts.isEmpty) {
      return const SizedBox.shrink();
    }

    final bundlePrice = bundleProducts.fold<double>(
      0,
      (sum, product) => sum + product.price,
    );
    final originalPrice = bundleProducts.fold<double>(
      0,
      (sum, product) => sum + (product.originalPrice ?? product.price),
    );
    final savings = originalPrice - bundlePrice;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Frequently Bought Together',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),

          SizedBox(height: 12.h),

          // Bundle products
          Row(
            children: [
              ...bundleProducts.asMap().entries.map((entry) {
                final index = entry.key;
                final product = entry.value;

                return Row(
                  children: [
                    Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) => Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image),
                          ),
                        ),
                      ),
                    ),

                    if (index < bundleProducts.length - 1) ...[
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.add,
                        size: 16.sp,
                        color: Theme.of(context).hintColor,
                      ),
                      SizedBox(width: 8.w),
                    ],
                  ],
                );
              }),
            ],
          ),

          SizedBox(height: 12.h),

          // Bundle pricing
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bundle Price',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  Text(
                    'TZS ${_formatPrice(bundlePrice)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  if (savings > 0)
                    Text(
                      'Save TZS ${_formatPrice(savings)}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                ],
              ),

              const Spacer(),

              ElevatedButton(
                onPressed: () =>
                    onAddBundle?.call(bundleProducts.map((p) => p.id).toList()),
                child: const Text('Add Bundle'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Product> _getBundleProducts() {
    // Mock implementation
    return [
      Product(
        id: 'bundle1',
        name: 'Engine Oil',
        description: 'Premium engine oil',
        price: 25000,
        originalPrice: 30000,
        currency: 'TZS',
        imageUrl: 'https://example.com/engine-oil.jpg',
        imageUrls: ['https://example.com/engine-oil.jpg'],
        categoryId: 'engine',
        categoryName: 'Engine Parts',
        brandId: 'mobil',
        brandName: 'Mobil',
        sku: 'BUN-EO-001',
        stockQuantity: 10,
        stockStatus: StockStatus.inStock,
        condition: ProductCondition.new_,
        rating: 4.5,
        reviewCount: 50,
        isFeatured: false,
        isActive: true,
        isDigital: false,
        requiresShipping: true,
        tags: ['engine', 'oil'],
        specifications: {},
        compatibleVehicles: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      Product(
        id: 'bundle2',
        name: 'Oil Filter',
        description: 'High-quality oil filter',
        price: 12000,
        originalPrice: 15000,
        currency: 'TZS',
        imageUrl: 'https://example.com/oil-filter.jpg',
        imageUrls: ['https://example.com/oil-filter.jpg'],
        categoryId: 'engine',
        categoryName: 'Engine Parts',
        brandId: 'mobil',
        brandName: 'Mobil',
        sku: 'BUN-OF-001',
        stockQuantity: 8,
        stockStatus: StockStatus.inStock,
        condition: ProductCondition.new_,
        rating: 4.3,
        reviewCount: 30,
        isFeatured: false,
        isActive: true,
        isDigital: false,
        requiresShipping: true,
        tags: ['oil', 'filter'],
        specifications: {},
        compatibleVehicles: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
