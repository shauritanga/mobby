import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../domain/entities/admin_product.dart';
import '../providers/admin_products_providers.dart';
import '../widgets/product_list_item.dart';
import '../widgets/product_filters_panel.dart';
import '../widgets/product_search_bar.dart';
import '../widgets/products_analytics_card.dart';

class AdminProductsListScreen extends ConsumerStatefulWidget {
  const AdminProductsListScreen({super.key});

  @override
  ConsumerState<AdminProductsListScreen> createState() => _AdminProductsListScreenState();
}

class _AdminProductsListScreenState extends ConsumerState<AdminProductsListScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  
  // Filter state
  String? _selectedCategoryId;
  String? _selectedSupplierId;
  ProductStatus? _selectedStatus;
  ProductType? _selectedType;
  bool? _isFeatured;
  bool? _isLowStock;
  String _sortBy = 'updatedAt';
  bool _sortDescending = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    
    // Load initial products
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      _loadMoreProducts();
    }
  }

  void _loadProducts({bool refresh = false}) {
    ref.read(productsListProvider.notifier).loadProducts(
      searchQuery: _searchController.text.isNotEmpty ? _searchController.text : null,
      categoryId: _selectedCategoryId,
      supplierId: _selectedSupplierId,
      status: _selectedStatus,
      type: _selectedType,
      isFeatured: _isFeatured,
      isLowStock: _isLowStock,
      sortBy: _sortBy,
      sortDescending: _sortDescending,
      refresh: refresh,
    );
  }

  void _loadMoreProducts() {
    ref.read(productsListProvider.notifier).loadMoreProducts();
  }

  void _onSearchChanged(String query) {
    // Debounce search
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_searchController.text == query) {
        _loadProducts(refresh: true);
      }
    });
  }

  void _onFiltersChanged({
    String? categoryId,
    String? supplierId,
    ProductStatus? status,
    ProductType? type,
    bool? isFeatured,
    bool? isLowStock,
  }) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedSupplierId = supplierId;
      _selectedStatus = status;
      _selectedType = type;
      _isFeatured = isFeatured;
      _isLowStock = isLowStock;
    });
    _loadProducts(refresh: true);
  }

  void _onSortChanged(String sortBy, bool descending) {
    setState(() {
      _sortBy = sortBy;
      _sortDescending = descending;
    });
    _loadProducts(refresh: true);
  }

  void _navigateToAddProduct() {
    context.push('/admin/products/add');
  }

  void _navigateToProductDetails(String productId) {
    context.push('/admin/products/$productId');
  }

  void _showFiltersPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProductFiltersPanel(
        selectedCategoryId: _selectedCategoryId,
        selectedSupplierId: _selectedSupplierId,
        selectedStatus: _selectedStatus,
        selectedType: _selectedType,
        isFeatured: _isFeatured,
        isLowStock: _isLowStock,
        onFiltersChanged: _onFiltersChanged,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(productsListProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerLowest,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // App Bar
          SliverAppBar(
            expandedHeight: 120.h,
            floating: false,
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Products',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              titlePadding: EdgeInsets.only(left: 16.w, bottom: 16.h),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: _showFiltersPanel,
                tooltip: 'Filters',
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.sort,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onSelected: (value) {
                  final parts = value.split('_');
                  final sortBy = parts[0];
                  final descending = parts[1] == 'desc';
                  _onSortChanged(sortBy, descending);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'name_asc', child: Text('Name (A-Z)')),
                  const PopupMenuItem(value: 'name_desc', child: Text('Name (Z-A)')),
                  const PopupMenuItem(value: 'price_asc', child: Text('Price (Low-High)')),
                  const PopupMenuItem(value: 'price_desc', child: Text('Price (High-Low)')),
                  const PopupMenuItem(value: 'stockQuantity_asc', child: Text('Stock (Low-High)')),
                  const PopupMenuItem(value: 'stockQuantity_desc', child: Text('Stock (High-Low)')),
                  const PopupMenuItem(value: 'updatedAt_desc', child: Text('Recently Updated')),
                  const PopupMenuItem(value: 'createdAt_desc', child: Text('Recently Created')),
                ],
              ),
              IconButton(
                icon: Icon(
                  Icons.refresh,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
                onPressed: () => _loadProducts(refresh: true),
                tooltip: 'Refresh',
              ),
            ],
          ),

          // Analytics Card
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: const ProductsAnalyticsCard(),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: ProductSearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onFilterPressed: _showFiltersPanel,
              ),
            ),
          ),

          SizedBox(height: 16.h).sliver,

          // Products List
          productsAsync.when(
            data: (productsState) => _buildProductsList(productsState),
            loading: () => _buildLoadingState(),
            error: (error, stack) => _buildErrorState(error.toString()),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddProduct,
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        icon: const Icon(Icons.add),
        label: const Text('Add Product'),
      ),
    );
  }

  Widget _buildProductsList(ProductsListState productsState) {
    if (productsState.products.isEmpty && !productsState.isLoading) {
      return _buildEmptyState();
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < productsState.products.length) {
            final product = productsState.products[index];
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
              child: ProductListItem(
                product: product,
                onTap: () => _navigateToProductDetails(product.id),
                onStatusChanged: (status) => _updateProductStatus(product.id, status),
                onStockChanged: (quantity) => _updateProductStock(product.id, quantity),
              ),
            );
          } else if (productsState.hasMore) {
            return Padding(
              padding: EdgeInsets.all(16.w),
              child: Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            );
          }
          return null;
        },
        childCount: productsState.products.length + (productsState.hasMore ? 1 : 0),
      ),
    );
  }

  Widget _buildLoadingState() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          child: _buildSkeletonCard(),
        ),
        childCount: 10,
      ),
    );
  }

  Widget _buildSkeletonCard() {
    return Container(
      height: 120.h,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64.r,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              SizedBox(height: 16.h),
              Text(
                'No Products Found',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Start by adding your first product or adjust your filters',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton.icon(
                onPressed: _navigateToAddProduct,
                icon: const Icon(Icons.add),
                label: const Text('Add Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return SliverToBoxAdapter(
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(32.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64.r,
                color: Theme.of(context).colorScheme.error,
              ),
              SizedBox(height: 16.h),
              Text(
                'Error Loading Products',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                error,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: 24.h),
              ElevatedButton(
                onPressed: () => _loadProducts(refresh: true),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateProductStatus(String productId, ProductStatus status) async {
    try {
      final updateProductStatusUseCase = ref.read(updateProductStatusUseCaseProvider);
      await updateProductStatusUseCase(productId, status);
      
      // Refresh the products list
      _loadProducts(refresh: true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product status updated to ${status.name}'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update product status: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  void _updateProductStock(String productId, int quantity) async {
    try {
      final updateProductStockUseCase = ref.read(updateProductStockUseCaseProvider);
      await updateProductStockUseCase(productId, quantity);
      
      // Refresh the products list
      _loadProducts(refresh: true);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Product stock updated to $quantity'),
            backgroundColor: Theme.of(context).colorScheme.primary,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update product stock: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

extension SliverBoxWidget on Widget {
  Widget get sliver => SliverToBoxAdapter(child: this);
}
