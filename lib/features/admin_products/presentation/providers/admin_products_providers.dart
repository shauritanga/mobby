import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/admin_product.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/usecases/manage_products.dart';
import '../../domain/usecases/update_inventory.dart';
import '../../domain/usecases/manage_categories.dart';
import '../../domain/usecases/manage_suppliers.dart';
import '../../data/datasources/admin_products_remote_datasource.dart';
import '../../data/repositories/admin_products_repository_impl.dart';

// Data source providers
final adminProductsRemoteDataSourceProvider = Provider<AdminProductsRemoteDataSource>((ref) {
  return AdminProductsRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

// Repository provider
final adminProductsRepositoryProvider = Provider((ref) {
  return AdminProductsRepositoryImpl(
    remoteDataSource: ref.read(adminProductsRemoteDataSourceProvider),
  );
});

// Product Use Case Providers
final getProductsUseCaseProvider = Provider((ref) {
  return GetProducts(ref.read(adminProductsRepositoryProvider));
});

final getProductByIdUseCaseProvider = Provider((ref) {
  return GetProductById(ref.read(adminProductsRepositoryProvider));
});

final createProductUseCaseProvider = Provider((ref) {
  return CreateProduct(ref.read(adminProductsRepositoryProvider));
});

final updateProductUseCaseProvider = Provider((ref) {
  return UpdateProduct(ref.read(adminProductsRepositoryProvider));
});

final deleteProductUseCaseProvider = Provider((ref) {
  return DeleteProduct(ref.read(adminProductsRepositoryProvider));
});

final updateProductStatusUseCaseProvider = Provider((ref) {
  return UpdateProductStatus(ref.read(adminProductsRepositoryProvider));
});

final updateProductStockUseCaseProvider = Provider((ref) {
  return UpdateProductStock(ref.read(adminProductsRepositoryProvider));
});

final getLowStockProductsUseCaseProvider = Provider((ref) {
  return GetLowStockProducts(ref.read(adminProductsRepositoryProvider));
});

final getFeaturedProductsUseCaseProvider = Provider((ref) {
  return GetFeaturedProducts(ref.read(adminProductsRepositoryProvider));
});

final getProductsAnalyticsUseCaseProvider = Provider((ref) {
  return GetProductsAnalytics(ref.read(adminProductsRepositoryProvider));
});

final searchProductsUseCaseProvider = Provider((ref) {
  return SearchProducts(ref.read(adminProductsRepositoryProvider));
});

final bulkUpdateProductsUseCaseProvider = Provider((ref) {
  return BulkUpdateProducts(ref.read(adminProductsRepositoryProvider));
});

final exportProductsUseCaseProvider = Provider((ref) {
  return ExportProducts(ref.read(adminProductsRepositoryProvider));
});

final importProductsUseCaseProvider = Provider((ref) {
  return ImportProducts(ref.read(adminProductsRepositoryProvider));
});

// Inventory Use Case Providers
final getInventoryUseCaseProvider = Provider((ref) {
  return GetInventory(ref.read(adminProductsRepositoryProvider));
});

final getInventoryByIdUseCaseProvider = Provider((ref) {
  return GetInventoryById(ref.read(adminProductsRepositoryProvider));
});

final getInventoryByProductUseCaseProvider = Provider((ref) {
  return GetInventoryByProduct(ref.read(adminProductsRepositoryProvider));
});

final updateInventoryUseCaseProvider = Provider((ref) {
  return UpdateInventoryUseCase(ref.read(adminProductsRepositoryProvider));
});

final addInventoryMovementUseCaseProvider = Provider((ref) {
  return AddInventoryMovement(ref.read(adminProductsRepositoryProvider));
});

final getInventoryMovementsUseCaseProvider = Provider((ref) {
  return GetInventoryMovements(ref.read(adminProductsRepositoryProvider));
});

final getLowStockInventoryUseCaseProvider = Provider((ref) {
  return GetLowStockInventory(ref.read(adminProductsRepositoryProvider));
});

final getInventoryLocationsUseCaseProvider = Provider((ref) {
  return GetInventoryLocations(ref.read(adminProductsRepositoryProvider));
});

final getInventoryAnalyticsUseCaseProvider = Provider((ref) {
  return GetInventoryAnalytics(ref.read(adminProductsRepositoryProvider));
});

final exportInventoryUseCaseProvider = Provider((ref) {
  return ExportInventory(ref.read(adminProductsRepositoryProvider));
});

// Category Use Case Providers
final getCategoriesUseCaseProvider = Provider((ref) {
  return GetCategories(ref.read(adminProductsRepositoryProvider));
});

final getCategoryByIdUseCaseProvider = Provider((ref) {
  return GetCategoryById(ref.read(adminProductsRepositoryProvider));
});

final createCategoryUseCaseProvider = Provider((ref) {
  return CreateCategory(ref.read(adminProductsRepositoryProvider));
});

final updateCategoryUseCaseProvider = Provider((ref) {
  return UpdateCategory(ref.read(adminProductsRepositoryProvider));
});

final deleteCategoryUseCaseProvider = Provider((ref) {
  return DeleteCategory(ref.read(adminProductsRepositoryProvider));
});

final getRootCategoriesUseCaseProvider = Provider((ref) {
  return GetRootCategories(ref.read(adminProductsRepositoryProvider));
});

final getSubcategoriesUseCaseProvider = Provider((ref) {
  return GetSubcategories(ref.read(adminProductsRepositoryProvider));
});

final getFeaturedCategoriesUseCaseProvider = Provider((ref) {
  return GetFeaturedCategories(ref.read(adminProductsRepositoryProvider));
});

final moveCategoryUseCaseProvider = Provider((ref) {
  return MoveCategory(ref.read(adminProductsRepositoryProvider));
});

final reorderCategoriesUseCaseProvider = Provider((ref) {
  return ReorderCategories(ref.read(adminProductsRepositoryProvider));
});

// Supplier Use Case Providers
final getSuppliersUseCaseProvider = Provider((ref) {
  return GetSuppliers(ref.read(adminProductsRepositoryProvider));
});

final getSupplierByIdUseCaseProvider = Provider((ref) {
  return GetSupplierById(ref.read(adminProductsRepositoryProvider));
});

final createSupplierUseCaseProvider = Provider((ref) {
  return CreateSupplier(ref.read(adminProductsRepositoryProvider));
});

final updateSupplierUseCaseProvider = Provider((ref) {
  return UpdateSupplier(ref.read(adminProductsRepositoryProvider));
});

final deleteSupplierUseCaseProvider = Provider((ref) {
  return DeleteSupplier(ref.read(adminProductsRepositoryProvider));
});

final getPreferredSuppliersUseCaseProvider = Provider((ref) {
  return GetPreferredSuppliers(ref.read(adminProductsRepositoryProvider));
});

final getSupplierAnalyticsUseCaseProvider = Provider((ref) {
  return GetSupplierAnalytics(ref.read(adminProductsRepositoryProvider));
});

final updateSupplierStatusUseCaseProvider = Provider((ref) {
  return UpdateSupplierStatus(ref.read(adminProductsRepositoryProvider));
});

final updateSupplierRatingUseCaseProvider = Provider((ref) {
  return UpdateSupplierRating(ref.read(adminProductsRepositoryProvider));
});

final verifySupplierUseCaseProvider = Provider((ref) {
  return VerifySupplier(ref.read(adminProductsRepositoryProvider));
});

final setPreferredSupplierUseCaseProvider = Provider((ref) {
  return SetPreferredSupplier(ref.read(adminProductsRepositoryProvider));
});

// State providers for UI
class ProductsListState {
  final List<AdminProduct> products;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const ProductsListState({
    this.products = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  ProductsListState copyWith({
    List<AdminProduct>? products,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return ProductsListState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Products list provider
final productsListProvider = StateNotifierProvider<ProductsListNotifier, AsyncValue<ProductsListState>>((ref) {
  return ProductsListNotifier(ref);
});

class ProductsListNotifier extends StateNotifier<AsyncValue<ProductsListState>> {
  final Ref _ref;
  
  ProductsListNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> loadProducts({
    String? searchQuery,
    String? categoryId,
    String? supplierId,
    ProductStatus? status,
    ProductType? type,
    bool? isFeatured,
    bool? isLowStock,
    String? sortBy,
    bool sortDescending = false,
    bool refresh = false,
  }) async {
    try {
      final currentState = state.value;
      final page = refresh ? 1 : (currentState?.currentPage ?? 1);
      
      if (refresh) {
        state = const AsyncValue.loading();
      } else if (currentState != null) {
        state = AsyncValue.data(currentState.copyWith(isLoading: true));
      }

      final getProductsUseCase = _ref.read(getProductsUseCaseProvider);
      final params = GetProductsParams(
        searchQuery: searchQuery,
        categoryId: categoryId,
        supplierId: supplierId,
        status: status,
        type: type,
        isFeatured: isFeatured,
        isLowStock: isLowStock,
        sortBy: sortBy,
        sortDescending: sortDescending,
        page: page,
        limit: 20,
      );

      final newProducts = await getProductsUseCase(params);
      
      final existingProducts = refresh ? <AdminProduct>[] : (currentState?.products ?? []);
      final allProducts = [...existingProducts, ...newProducts];

      state = AsyncValue.data(ProductsListState(
        products: allProducts,
        isLoading: false,
        hasMore: newProducts.length >= 20,
        currentPage: page + 1,
      ));
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> refreshProducts({
    String? searchQuery,
    String? categoryId,
    String? supplierId,
    ProductStatus? status,
    ProductType? type,
    bool? isFeatured,
    bool? isLowStock,
    String? sortBy,
    bool sortDescending = false,
  }) async {
    return loadProducts(
      searchQuery: searchQuery,
      categoryId: categoryId,
      supplierId: supplierId,
      status: status,
      type: type,
      isFeatured: isFeatured,
      isLowStock: isLowStock,
      sortBy: sortBy,
      sortDescending: sortDescending,
      refresh: true,
    );
  }

  Future<void> loadMoreProducts() async {
    final currentState = state.value;
    if (currentState == null || !currentState.hasMore || currentState.isLoading) return;

    // This would use the same filters as the last query
    // For simplicity, we'll implement basic load more
    await loadProducts();
  }
}

// Individual data providers
final productsAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final getProductsAnalyticsUseCase = ref.read(getProductsAnalyticsUseCaseProvider);
  return await getProductsAnalyticsUseCase();
});

final lowStockProductsProvider = FutureProvider<List<AdminProduct>>((ref) async {
  final getLowStockProductsUseCase = ref.read(getLowStockProductsUseCaseProvider);
  return await getLowStockProductsUseCase();
});

final featuredProductsProvider = FutureProvider<List<AdminProduct>>((ref) async {
  final getFeaturedProductsUseCase = ref.read(getFeaturedProductsUseCaseProvider);
  return await getFeaturedProductsUseCase();
});

final inventoryAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final getInventoryAnalyticsUseCase = ref.read(getInventoryAnalyticsUseCaseProvider);
  return await getInventoryAnalyticsUseCase();
});

final lowStockInventoryProvider = FutureProvider<List<Inventory>>((ref) async {
  final getLowStockInventoryUseCase = ref.read(getLowStockInventoryUseCaseProvider);
  return await getLowStockInventoryUseCase();
});

final inventoryLocationsProvider = FutureProvider<List<InventoryLocation>>((ref) async {
  final getInventoryLocationsUseCase = ref.read(getInventoryLocationsUseCaseProvider);
  return await getInventoryLocationsUseCase();
});

final rootCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final getRootCategoriesUseCase = ref.read(getRootCategoriesUseCaseProvider);
  return await getRootCategoriesUseCase();
});

final featuredCategoriesProvider = FutureProvider<List<Category>>((ref) async {
  final getFeaturedCategoriesUseCase = ref.read(getFeaturedCategoriesUseCaseProvider);
  return await getFeaturedCategoriesUseCase();
});

final preferredSuppliersProvider = FutureProvider<List<Supplier>>((ref) async {
  final getPreferredSuppliersUseCase = ref.read(getPreferredSuppliersUseCaseProvider);
  return await getPreferredSuppliersUseCase();
});

final supplierAnalyticsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final getSupplierAnalyticsUseCase = ref.read(getSupplierAnalyticsUseCaseProvider);
  return await getSupplierAnalyticsUseCase();
});

// Product details provider
final productDetailsProvider = FutureProvider.family<AdminProduct?, String>((ref, productId) async {
  final getProductByIdUseCase = ref.read(getProductByIdUseCaseProvider);
  return await getProductByIdUseCase(productId);
});

// Category details provider
final categoryDetailsProvider = FutureProvider.family<Category?, String>((ref, categoryId) async {
  final getCategoryByIdUseCase = ref.read(getCategoryByIdUseCaseProvider);
  return await getCategoryByIdUseCase(categoryId);
});

// Supplier details provider
final supplierDetailsProvider = FutureProvider.family<Supplier?, String>((ref, supplierId) async {
  final getSupplierByIdUseCase = ref.read(getSupplierByIdUseCaseProvider);
  return await getSupplierByIdUseCase(supplierId);
});

// Subcategories provider
final subcategoriesProvider = FutureProvider.family<List<Category>, String>((ref, parentId) async {
  final getSubcategoriesUseCase = ref.read(getSubcategoriesUseCaseProvider);
  return await getSubcategoriesUseCase(parentId);
});
