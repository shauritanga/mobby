import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/banner.dart' as banner_entity;
import '../../domain/entities/product.dart';
import '../providers/home_providers.dart';

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
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          // Tesla-inspired minimalist app bar
          SliverAppBar(
            expandedHeight: 80.h,
            floating: true,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 8.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Top row with greeting and minimal actions
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _getGreeting(),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                          fontWeight: FontWeight.w400,
                                        ),
                                  ),
                                  SizedBox(height: 2.h),
                                  Text(
                                    'Find your car parts',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            // Minimal action buttons
                            Row(
                              children: [
                                _buildActionButton(
                                  icon: Icons.shopping_cart_outlined,
                                  onPressed: () => context.push('/home/cart'),
                                ),
                                SizedBox(width: 8.w),
                                _buildActionButton(
                                  icon: Icons.notifications_outlined,
                                  onPressed: () {
                                    // TODO: Navigate to notifications
                                  },
                                ),
                              ],
                            ),
                          ],
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
                SizedBox(height: 8.h),

                // Advertisement Banner Section
                _buildAdvertisementBanner(),

                // Featured Products Section
                _buildFeaturedProducts(),

                // Services Promotion Section
                _buildServicesPromotion(),

                // Bottom spacing
                SizedBox(height: 100.h), // Space for bottom navigation
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      width: 44.w,
      height: 44.w,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: IconButton(
        icon: Icon(
          icon,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          size: 20.r,
        ),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
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
              return const SizedBox.shrink(); // Hide if no banners
            }

            // Start auto-scroll when banners are loaded
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _startBannerAutoScroll(banners.length);
            });

            return _buildBannerCarousel(banners);
          },
          loading: () => _buildBannerSkeleton(),
          error: (error, stack) => const SizedBox.shrink(), // Hide on error
        );
      },
    );
  }

  Widget _buildBannerSkeleton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      height: 230.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerCarousel(List<banner_entity.Banner> banners) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
      height: 230.h,
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
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(24.r),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          bannerColor,
                          bannerColor.withValues(alpha: 0.8),
                          bannerColor.withValues(alpha: 0.9),
                        ],
                        stops: const [0.0, 0.6, 1.0],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: bannerColor.withValues(alpha: 0.4),
                          blurRadius: 25,
                          offset: const Offset(0, 12),
                          spreadRadius: 2,
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Stack(
                      children: [
                        // Background pattern/decoration
                        Positioned(
                          top: -20,
                          right: -20,
                          child: Container(
                            width: 120.w,
                            height: 120.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.1),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: -30,
                          right: 20.w,
                          child: Container(
                            width: 80.w,
                            height: 80.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.05),
                            ),
                          ),
                        ),
                        // Main content
                        Padding(
                          padding: EdgeInsets.all(24.w),
                          child: Row(
                            children: [
                              // Left side - Text content
                              Expanded(
                                flex: 3,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    // Promotional badge
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 10.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        'SPECIAL OFFER',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.2,
                                            ),
                                      ),
                                    ),
                                    SizedBox(height: 10.h),
                                    // Main title
                                    Text(
                                      banner.title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .headlineMedium
                                          ?.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w900,
                                            height: 1.0,
                                            letterSpacing: -0.5,
                                            shadows: [
                                              Shadow(
                                                color: Colors.black.withValues(
                                                  alpha: 0.3,
                                                ),
                                                offset: const Offset(0, 2),
                                                blurRadius: 4,
                                              ),
                                            ],
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 6.h),
                                    // Subtitle
                                    Text(
                                      banner.subtitle,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium
                                          ?.copyWith(
                                            color: Colors.white.withValues(
                                              alpha: 0.9,
                                            ),
                                            height: 1.2,
                                            fontWeight: FontWeight.w500,
                                          ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 12.h),
                                    // Call-to-action button
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20.w,
                                        vertical: 10.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(
                                          30.r,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          ),
                                          BoxShadow(
                                            color: Colors.white.withValues(
                                              alpha: 0.1,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, -2),
                                          ),
                                        ],
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            banner.actionText,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(
                                                  color: bannerColor,
                                                  fontWeight: FontWeight.w800,
                                                  letterSpacing: 0.5,
                                                ),
                                          ),
                                          SizedBox(width: 8.w),
                                          Icon(
                                            Icons.arrow_forward_rounded,
                                            color: bannerColor,
                                            size: 18.r,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Right side - Visual element
                              Expanded(
                                flex: 1,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 80.w,
                                      height: 80.w,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.15,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          20.r,
                                        ),
                                        border: Border.all(
                                          color: Colors.white.withValues(
                                            alpha: 0.3,
                                          ),
                                          width: 2,
                                        ),
                                      ),
                                      child: Icon(
                                        Icons.local_offer_rounded,
                                        color: Colors.white,
                                        size: 40.r,
                                      ),
                                    ),
                                    SizedBox(height: 12.h),
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8.w,
                                        vertical: 4.h,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.2,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          12.r,
                                        ),
                                      ),
                                      child: Text(
                                        'LIMITED',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: 1.0,
                                            ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 20.h),
          // Tesla-style minimal indicators
          if (banners.length > 1)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: banners.asMap().entries.map((entry) {
                final isActive = _currentBannerIndex == entry.key;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: isActive ? 24.w : 8.w,
                  height: 8.h,
                  margin: EdgeInsets.symmetric(horizontal: 4.w),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.r),
                    color: isActive
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

  Widget _buildFeaturedProducts() {
    return Consumer(
      builder: (context, ref, child) {
        final productsAsync = ref.watch(featuredProductsProvider);

        return Container(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Featured Products',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                    ),
                    TextButton(
                      onPressed: () => context.go('/products'),
                      style: TextButton.styleFrom(
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 8.h,
                        ),
                      ),
                      child: Text(
                        'View All',
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                height: 275.h,
                child: productsAsync.when(
                  data: (products) {
                    print(
                      '📦 Featured products loaded: ${products.length} items',
                    );

                    if (products.isEmpty) {
                      return _buildEmptyProductsState();
                    }

                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 8.h,
                      ),
                      itemCount: products.length,
                      itemBuilder: (context, index) {
                        final product = products[index];
                        return _buildProductCard(product);
                      },
                    );
                  },
                  loading: () {
                    print('⏳ Loading featured products...');
                    return _buildProductsSkeleton();
                  },
                  error: (error, stack) {
                    print('❌ Error loading featured products: $error');
                    return _buildProductsError(error.toString());
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductsSkeleton() {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          width: 240.w,
          margin: EdgeInsets.only(right: 20.w),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 6),
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
        width: 260.w,
        margin: EdgeInsets.only(right: 20.w),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Theme.of(
              context,
            ).colorScheme.outline.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.12),
              blurRadius: 20,
              offset: const Offset(2, 8),
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Theme.of(
                context,
              ).colorScheme.shadow.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with premium design
            Container(
              height: 140.h,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(product.imageUrl),
                  fit: BoxFit.cover,
                ),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                    Theme.of(context).colorScheme.surfaceContainer,
                  ],
                ),

                borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
              ),
              child: Stack(
                children: [
                  // Background pattern
                  Positioned(
                    top: -10,
                    right: -10,
                    child: Container(
                      width: 60.w,
                      height: 60.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.05),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -15,
                    left: -15,
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.03),
                      ),
                    ),
                  ),
                  // Main product icon
                  Center(
                    child: Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.2),
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.car_repair,
                        size: 32.r,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  if (product.isOnSale)
                    Positioned(
                      top: 16.h,
                      right: 16.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.error,
                              Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16.r),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '-${product.discountPercentage.toInt()}%',
                          style: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            // Product Details with compact spacing
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      product.name,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                        color: Theme.of(context).colorScheme.onSurface,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2.h),
                    // Price section with compact design
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 6.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'TZS ${_formatPrice(product.price)}',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Theme.of(context).colorScheme.primary,
                                  letterSpacing: -0.3,
                                ),
                          ),
                          if (product.isOnSale) ...[
                            SizedBox(height: 1.h),
                            Text(
                              'TZS ${_formatPrice(product.originalPrice!)}',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                                    decoration: TextDecoration.lineThrough,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: 2.h),
                    // Rating and stock status with premium design
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(
                              color: Colors.amber.withValues(alpha: 0.2),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.star_rounded,
                                size: 12.r,
                                color: Colors.amber,
                              ),
                              SizedBox(width: 2.w),
                              Text(
                                product.rating.toStringAsFixed(1),
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber.shade700,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            '(${product.reviewCount} reviews)',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w500,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    if (!product.isInStock) ...[
                      SizedBox(height: 2.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 3.h,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.1),
                              Theme.of(
                                context,
                              ).colorScheme.error.withValues(alpha: 0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.error.withValues(alpha: 0.2),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 14.r,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              'Out of Stock',
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ],
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

  Widget _buildServicesPromotion() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.secondary,
            Theme.of(context).colorScheme.secondary.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.secondary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Services',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Complete vehicle solutions at your fingertips',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildServiceButton(
                  icon: Icons.assignment_outlined,
                  label: 'LATRA',
                  onPressed: () => context.go('/support/latra'),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildServiceButton(
                  icon: Icons.security_outlined,
                  label: 'Insurance',
                  onPressed: () => context.go('/support/insurance'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.white, size: 20.r),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyProductsState() {
    return Container(
      height: 275.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 48.r,
              color: Theme.of(context).colorScheme.outline,
            ),
            SizedBox(height: 16.h),
            Text(
              'No Featured Products',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Featured products will appear here once they are added to the store.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsError(String error) {
    return Container(
      height: 275.h,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48.r,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Error Loading Products',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Unable to load featured products. Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                // Refresh the provider
                ref.invalidate(featuredProductsProvider);
              },
              child: Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
