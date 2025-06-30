import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/banner.dart' as banner_entity;
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/quick_action.dart';
import '../providers/home_providers.dart';
import '../widgets/loading_widgets.dart' as loading_widgets;
import '../../../../debug_database_test.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final PageController _bannerController = PageController();
  int _currentBannerIndex = 0;
  Timer? _bannerTimer;

  @override
  void initState() {
    super.initState();
    // Auto-scroll will be started when banners are loaded
  }

  @override
  void dispose() {
    _bannerTimer?.cancel();
    _bannerController.dispose();
    super.dispose();
  }

  void _startBannerAutoScroll(int bannerCount) {
    _bannerTimer?.cancel();
    if (bannerCount > 1) {
      _bannerTimer = Timer.periodic(const Duration(seconds: 4), (timer) {
        if (_bannerController.hasClients) {
          final nextPage = (_currentBannerIndex + 1) % bannerCount;
          _bannerController.animateToPage(
            nextPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Custom App Bar with Search
          SliverAppBar(
            expandedHeight: 120.h,
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Theme.of(context).colorScheme.primary,
                      Theme.of(
                        context,
                      ).colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row with greeting and actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Good Morning!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                                Text(
                                  'Find your car parts',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.shopping_cart,
                                    color: Colors.white,
                                    size: 24.r,
                                  ),
                                  onPressed: () => context.push('/home/cart'),
                                ),
                                IconButton(
                                  icon: Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                    size: 24.r,
                                  ),
                                  onPressed: () {
                                    // TODO: Navigate to notifications
                                  },
                                ),
                                // Temporary debug button
                                IconButton(
                                  icon: Icon(
                                    Icons.bug_report,
                                    color: Colors.white,
                                    size: 24.r,
                                  ),
                                  onPressed: () =>
                                      showDatabaseDebugTest(context),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 12.h),
                        // Search Bar
                        Container(
                          height: 44.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: TextField(
                            decoration: InputDecoration(
                              hintText:
                                  'Search for parts, brands, or services...',
                              hintStyle: TextStyle(
                                fontSize: 14.sp,
                                color: Colors.grey[600],
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: Colors.grey[600],
                                size: 20.r,
                              ),
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),
                            onTap: () {
                              // TODO: Navigate to search screen
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Advertisement Banner Section
                _buildAdvertisementBanner(),

                // Quick Actions Section
                _buildQuickActions(),

                // Featured Products Section
                _buildFeaturedProducts(),

                // Categories Section
                _buildCategories(),

                // Services Promotion Section
                _buildServicesPromotion(),

                // Recent Activity Section
                _buildRecentActivity(),

                // Bottom spacing
                SizedBox(height: 100.h), // Space for bottom navigation
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvertisementBanner() {
    return Consumer(
      builder: (context, ref, child) {
        final bannersAsync = ref.watch(bannersProvider);

        return bannersAsync.when(
          data: (banners) {
            if (banners.isEmpty) {
              return loading_widgets.EmptyStateWidget(
                title: 'No Banners Available',
                subtitle: 'Check back later for exciting offers!',
                icon: Icons.campaign,
              );
            }

            // Start auto-scroll when banners are loaded
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startBannerAutoScroll(banners.length);
            });

            return _buildBannerCarousel(banners);
          },
          loading: () => const loading_widgets.BannerLoadingWidget(),
          error: (error, stack) => loading_widgets.ErrorWidget(
            message: 'Failed to load banners',
            onRetry: () => ref.invalidate(bannersProvider),
          ),
        );
      },
    );
  }

  Widget _buildBannerCarousel(List<banner_entity.Banner> banners) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 16.h),
      height: 200.h, // Increased height to prevent overflow
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _bannerController,
              onPageChanged: (index) {
                setState(() {
                  _currentBannerIndex = index;
                });
              },
              itemCount: banners.length,
              itemBuilder: (context, index) {
                final banner = banners[index];
                final bannerColor = Color(
                  int.parse(banner.colorHex.replaceFirst('#', '0xFF')),
                );

                return GestureDetector(
                  onTap: () {
                    // Track banner click
                    ref.read(bannerClickProvider(banner.id));

                    // Navigate to action URL if available
                    if (banner.actionUrl != null) {
                      context.go(banner.actionUrl!);
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 16.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          bannerColor,
                          bannerColor.withValues(alpha: 0.8),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(
                        16.w,
                      ), // Reduced padding to fit content better
                      child: Row(
                        children: [
                          Expanded(
                            flex: 3, // Give more space to text content
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  banner.title,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize:
                                        20.sp, // Slightly reduced to fit better
                                    fontWeight: FontWeight.bold,
                                    height: 1.2,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 6.h),
                                Text(
                                  banner.subtitle,
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 14.sp, // Slightly reduced
                                    height: 1.3,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 12.h),
                                ElevatedButton(
                                  onPressed: () {
                                    // Track banner click
                                    ref.read(bannerClickProvider(banner.id));

                                    // Navigate to action URL if available
                                    if (banner.actionUrl != null) {
                                      context.go(banner.actionUrl!);
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: bannerColor,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16.w,
                                      vertical: 6.h,
                                    ),
                                    minimumSize: Size(
                                      0,
                                      32.h,
                                    ), // Set minimum height
                                  ),
                                  child: Text(
                                    banner.actionText,
                                    style: TextStyle(
                                      fontSize: 12.sp, // Slightly reduced
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            flex: 1, // Less space for icon
                            child: Icon(
                              Icons.local_offer,
                              size: 48.r, // Reduced size
                              color: Colors.white.withValues(alpha: 0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 12.h),
          // Banner indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: banners.asMap().entries.map((entry) {
              return Container(
                width: _currentBannerIndex == entry.key ? 24.w : 8.w,
                height: 8.h,
                margin: EdgeInsets.symmetric(horizontal: 4.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4.r),
                  color: _currentBannerIndex == entry.key
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(
                          context,
                        ).colorScheme.outline.withValues(alpha: 0.3),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Consumer(
      builder: (context, ref, child) {
        final actionsAsync = ref.watch(quickActionsProvider);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 16.h),
              actionsAsync.when(
                data: (actions) {
                  if (actions.isEmpty) {
                    return loading_widgets.EmptyStateWidget(
                      title: 'No Quick Actions',
                      subtitle: 'Quick actions will appear here!',
                      icon: Icons.flash_on,
                    );
                  }

                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: actions.map((action) {
                      return Expanded(child: _buildQuickActionCard(action));
                    }).toList(),
                  );
                },
                loading: () => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(
                    4,
                    (index) => Expanded(
                      child: Container(
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        child: const loading_widgets.QuickActionLoadingWidget(),
                      ),
                    ),
                  ),
                ),
                error: (error, stack) => loading_widgets.ErrorWidget(
                  message: 'Failed to load quick actions',
                  onRetry: () => ref.invalidate(quickActionsProvider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuickActionCard(QuickAction action) {
    final actionColor = Color(
      int.parse(action.colorHex.replaceFirst('#', '0xFF')),
    );

    return GestureDetector(
      onTap: () {
        // Track quick action click
        ref.read(quickActionClickProvider(action.id));

        // Navigate to action route
        context.go(action.route);
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 4.w),
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              _getQuickActionIcon(action.iconName),
              size: 32.r,
              color: actionColor,
            ),
            SizedBox(height: 8.h),
            Text(
              action.title,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  IconData _getQuickActionIcon(String iconName) {
    switch (iconName) {
      case 'search':
        return Icons.search;
      case 'add_circle':
        return Icons.add_circle;
      case 'assignment':
        return Icons.assignment;
      case 'security':
        return Icons.security;
      default:
        return Icons.flash_on;
    }
  }

  Widget _buildFeaturedProducts() {
    return Consumer(
      builder: (context, ref, child) {
        final productsAsync = ref.watch(featuredProductsProvider);

        return Container(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Products',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/products'),
                      child: Text(
                        'View All',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                height: 260
                    .h, // Further increased height to prevent bottom overflow
                child: productsAsync.when(
                  data: (products) {
                    if (products.isEmpty) {
                      return loading_widgets.EmptyStateWidget(
                        title: 'No Featured Products',
                        subtitle: 'Check back later for amazing deals!',
                        icon: Icons.shopping_bag,
                      );
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductCard(product);
                      },
                    );
                  },
                  loading: () => loading_widgets.LoadingListWidget(
                    itemCount: 5,
                    itemBuilder: () =>
                        const loading_widgets.ProductLoadingWidget(),
                  ),
                  error: (error, stack) => Center(
                    child: loading_widgets.ErrorWidget(
                      message: 'Failed to load featured products',
                      onRetry: () => ref.invalidate(featuredProductsProvider),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(Product product) {
    return GestureDetector(
      onTap: () {
        // Track product view
        ref.read(productViewProvider(product.id));

        // Navigate to product details
        context.go('/products/${product.id}');
      },
      child: Container(
        width: 180.w, // Increased width for better content fit
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              height: 110.h, // Slightly increased height for better proportions
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      Icons.car_repair,
                      size: 40.r,
                      color: Colors.grey[400],
                    ),
                  ),
                  if (product.isOnSale)
                    Positioned(
                      top: 8.h,
                      right: 8.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          '-${product.discountPercentage.toInt()}%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product Details
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(
                  14.w,
                ), // Increased padding for better spacing
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize:
                            15.sp, // Slightly increased for better readability
                        fontWeight: FontWeight.w500,
                        height: 1.2, // Added line height for better readability
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6.h), // Increased spacing
                    // Price section - Fixed overflow issue
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'TZS ${_formatPrice(product.price)}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (product.isOnSale) ...[
                          SizedBox(height: 2.h),
                          Text(
                            'TZS ${_formatPrice(product.originalPrice!)}',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 6.h), // Increased spacing
                    Row(
                      children: [
                        Icon(Icons.star, size: 12.r, color: Colors.amber),
                        SizedBox(width: 4.w),
                        Text(
                          product.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Flexible(
                          // Added Flexible to prevent overflow
                          child: Text(
                            '(${product.reviewCount})',
                            style: TextStyle(
                              fontSize: 10.sp,
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (!product.isInStock) ...[
                      SizedBox(height: 6.h), // Increased spacing
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          'Out of Stock',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatPrice(double price) {
    // Price is already in TZS from the database
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }

  Widget _buildCategories() {
    return Consumer(
      builder: (context, ref, child) {
        final categoriesAsync = ref.watch(parentCategoriesProvider);

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Shop by Category',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 16.h),
              categoriesAsync.when(
                data: (categories) {
                  if (categories.isEmpty) {
                    return loading_widgets.EmptyStateWidget(
                      title: 'No Categories Available',
                      subtitle: 'Categories will appear here soon!',
                      icon: Icons.category,
                    );
                  }

                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12.w,
                      mainAxisSpacing: 12.h,
                      childAspectRatio: 0.9,
                    ),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _buildCategoryCard(category);
                    },
                  );
                },
                loading: () => loading_widgets.LoadingGridWidget(
                  itemCount: 6,
                  itemBuilder: () =>
                      const loading_widgets.CategoryLoadingWidget(),
                ),
                error: (error, stack) => loading_widgets.ErrorWidget(
                  message: 'Failed to load categories',
                  onRetry: () => ref.invalidate(parentCategoriesProvider),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCategoryCard(Category category) {
    final categoryColor = Color(
      int.parse(category.colorHex.replaceFirst('#', '0xFF')),
    );

    return GestureDetector(
      onTap: () {
        // Track category view
        ref.read(categoryViewProvider(category.id));

        // Navigate to category products
        context.go('/products?category=${category.id}');
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: categoryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Icon(
                _getCategoryIcon(category.iconName),
                size: 24.r,
                color: categoryColor,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 2.h),
            Text(
              '${category.productCount} items',
              style: TextStyle(
                fontSize: 10.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'build':
        return Icons.build;
      case 'tire_repair':
        return Icons.tire_repair;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'oil_barrel':
        return Icons.oil_barrel;
      case 'car_crash':
        return Icons.car_crash;
      case 'settings':
        return Icons.settings;
      default:
        return Icons.category;
    }
  }

  Widget _buildServicesPromotion() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Services',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Complete vehicle solutions at your fingertips',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/support/latra'),
                  icon: Icon(Icons.assignment, size: 18.r),
                  label: Text('LATRA', style: TextStyle(fontSize: 12.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go('/support/insurance'),
                  icon: Icon(Icons.security, size: 18.r),
                  label: Text('Insurance', style: TextStyle(fontSize: 12.sp)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Activity',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outline.withValues(alpha: 0.2),
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(
                    context,
                  ).colorScheme.shadow.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.history,
                  size: 48.r,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                SizedBox(height: 12.h),
                Text(
                  'No recent activity',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Start shopping to see your activity here',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
