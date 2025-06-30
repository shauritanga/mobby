import '../../domain/entities/admin_product.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/supplier.dart';
import '../../domain/repositories/admin_products_repository.dart';
import '../datasources/admin_products_remote_datasource.dart';
import '../models/admin_product_model.dart';
import '../models/inventory_model.dart';
import '../models/category_model.dart';
import '../models/supplier_model.dart';

class AdminProductsRepositoryImpl implements AdminProductsRepository {
  final AdminProductsRemoteDataSource _remoteDataSource;

  AdminProductsRepositoryImpl({
    required AdminProductsRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<List<AdminProduct>> getProducts({
    String? searchQuery,
    String? categoryId,
    String? supplierId,
    ProductStatus? status,
    ProductType? type,
    bool? isFeatured,
    bool? isLowStock,
    String? sortBy,
    bool sortDescending = false,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final products = await _remoteDataSource.getProducts(
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
        limit: limit,
      );
      return products.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<AdminProduct?> getProductById(String productId) async {
    try {
      final product = await _remoteDataSource.getProductById(productId);
      return product?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  @override
  Future<AdminProduct> createProduct(AdminProduct product) async {
    try {
      final productModel = AdminProductModel.fromEntity(product);
      final createdProduct = await _remoteDataSource.createProduct(productModel);
      return createdProduct.toEntity();
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<AdminProduct> updateProduct(AdminProduct product) async {
    try {
      final productModel = AdminProductModel.fromEntity(product);
      final updatedProduct = await _remoteDataSource.updateProduct(productModel);
      return updatedProduct.toEntity();
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _remoteDataSource.deleteProduct(productId);
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  @override
  Future<void> updateProductStatus(String productId, ProductStatus status) async {
    try {
      await _remoteDataSource.updateProductStatus(productId, status);
    } catch (e) {
      throw Exception('Failed to update product status: $e');
    }
  }

  @override
  Future<void> updateProductStock(String productId, int quantity) async {
    try {
      await _remoteDataSource.updateProductStock(productId, quantity);
    } catch (e) {
      throw Exception('Failed to update product stock: $e');
    }
  }

  @override
  Future<List<AdminProduct>> getProductsByCategory(String categoryId) async {
    try {
      final products = await _remoteDataSource.getProductsByCategory(categoryId);
      return products.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  @override
  Future<List<AdminProduct>> getProductsBySupplier(String supplierId) async {
    try {
      final products = await _remoteDataSource.getProductsBySupplier(supplierId);
      return products.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch products by supplier: $e');
    }
  }

  @override
  Future<List<AdminProduct>> getLowStockProducts() async {
    try {
      final products = await _remoteDataSource.getLowStockProducts();
      return products.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch low stock products: $e');
    }
  }

  @override
  Future<List<AdminProduct>> getFeaturedProducts() async {
    try {
      final products = await _remoteDataSource.getFeaturedProducts();
      return products.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getProductsAnalytics() async {
    try {
      return await _remoteDataSource.getProductsAnalytics();
    } catch (e) {
      throw Exception('Failed to fetch products analytics: $e');
    }
  }

  @override
  Future<List<Inventory>> getInventory({
    String? searchQuery,
    String? productId,
    String? locationId,
    InventoryStatus? status,
    bool? isLowStock,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final inventory = await _remoteDataSource.getInventory(
        searchQuery: searchQuery,
        productId: productId,
        locationId: locationId,
        status: status,
        isLowStock: isLowStock,
        page: page,
        limit: limit,
      );
      return inventory.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory: $e');
    }
  }

  @override
  Future<Inventory?> getInventoryById(String inventoryId) async {
    try {
      final inventory = await _remoteDataSource.getInventoryById(inventoryId);
      return inventory?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch inventory: $e');
    }
  }

  @override
  Future<Inventory?> getInventoryByProduct(String productId, {String? variantId, String? locationId}) async {
    try {
      final inventory = await _remoteDataSource.getInventoryByProduct(
        productId,
        variantId: variantId,
        locationId: locationId,
      );
      return inventory?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch inventory by product: $e');
    }
  }

  @override
  Future<Inventory> updateInventory(Inventory inventory) async {
    try {
      final inventoryModel = InventoryModel.fromEntity(inventory);
      final updatedInventory = await _remoteDataSource.updateInventory(inventoryModel);
      return updatedInventory.toEntity();
    } catch (e) {
      throw Exception('Failed to update inventory: $e');
    }
  }

  @override
  Future<InventoryMovement> addInventoryMovement(InventoryMovement movement) async {
    try {
      final movementModel = InventoryMovementModel.fromEntity(movement);
      final addedMovement = await _remoteDataSource.addInventoryMovement(movementModel);
      return addedMovement.toEntity();
    } catch (e) {
      throw Exception('Failed to add inventory movement: $e');
    }
  }

  @override
  Future<List<InventoryMovement>> getInventoryMovements({
    String? productId,
    String? locationId,
    InventoryMovementType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final movements = await _remoteDataSource.getInventoryMovements(
        productId: productId,
        locationId: locationId,
        type: type,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );
      return movements.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory movements: $e');
    }
  }

  @override
  Future<List<Inventory>> getLowStockInventory() async {
    try {
      final inventory = await _remoteDataSource.getLowStockInventory();
      return inventory.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch low stock inventory: $e');
    }
  }

  @override
  Future<List<InventoryLocation>> getInventoryLocations() async {
    try {
      final locations = await _remoteDataSource.getInventoryLocations();
      return locations.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory locations: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getInventoryAnalytics() async {
    try {
      return await _remoteDataSource.getInventoryAnalytics();
    } catch (e) {
      throw Exception('Failed to fetch inventory analytics: $e');
    }
  }

  @override
  Future<List<Category>> getCategories({
    String? searchQuery,
    String? parentId,
    CategoryStatus? status,
    bool? isFeatured,
    String? sortBy,
    bool sortDescending = false,
  }) async {
    try {
      final categories = await _remoteDataSource.getCategories(
        searchQuery: searchQuery,
        parentId: parentId,
        status: status,
        isFeatured: isFeatured,
        sortBy: sortBy,
        sortDescending: sortDescending,
      );
      return categories.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<Category?> getCategoryById(String categoryId) async {
    try {
      final category = await _remoteDataSource.getCategoryById(categoryId);
      return category?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }

  @override
  Future<Category> createCategory(Category category) async {
    try {
      final categoryModel = CategoryModel.fromEntity(category);
      final createdCategory = await _remoteDataSource.createCategory(categoryModel);
      return createdCategory.toEntity();
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  @override
  Future<Category> updateCategory(Category category) async {
    try {
      final categoryModel = CategoryModel.fromEntity(category);
      final updatedCategory = await _remoteDataSource.updateCategory(categoryModel);
      return updatedCategory.toEntity();
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _remoteDataSource.deleteCategory(categoryId);
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  @override
  Future<List<Category>> getRootCategories() async {
    try {
      final categories = await _remoteDataSource.getRootCategories();
      return categories.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch root categories: $e');
    }
  }

  @override
  Future<List<Category>> getSubcategories(String parentId) async {
    try {
      final categories = await _remoteDataSource.getSubcategories(parentId);
      return categories.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch subcategories: $e');
    }
  }

  @override
  Future<List<Category>> getFeaturedCategories() async {
    try {
      final categories = await _remoteDataSource.getFeaturedCategories();
      return categories.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured categories: $e');
    }
  }

  @override
  Future<void> updateCategoryProductCount(String categoryId) async {
    try {
      await _remoteDataSource.updateCategoryProductCount(categoryId);
    } catch (e) {
      throw Exception('Failed to update category product count: $e');
    }
  }

  // Implement remaining methods with similar pattern...
  // For brevity, I'll implement the key ones and add placeholders for others

  @override
  Future<List<Supplier>> getSuppliers({
    String? searchQuery,
    SupplierStatus? status,
    SupplierType? type,
    bool? isPreferred,
    bool? isVerified,
    String? sortBy,
    bool sortDescending = false,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final suppliers = await _remoteDataSource.getSuppliers(
        searchQuery: searchQuery,
        status: status,
        type: type,
        isPreferred: isPreferred,
        isVerified: isVerified,
        sortBy: sortBy,
        sortDescending: sortDescending,
        page: page,
        limit: limit,
      );
      return suppliers.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch suppliers: $e');
    }
  }

  @override
  Future<Supplier?> getSupplierById(String supplierId) async {
    try {
      final supplier = await _remoteDataSource.getSupplierById(supplierId);
      return supplier?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch supplier: $e');
    }
  }

  @override
  Future<Supplier> createSupplier(Supplier supplier) async {
    try {
      final supplierModel = SupplierModel.fromEntity(supplier);
      final createdSupplier = await _remoteDataSource.createSupplier(supplierModel);
      return createdSupplier.toEntity();
    } catch (e) {
      throw Exception('Failed to create supplier: $e');
    }
  }

  @override
  Future<Supplier> updateSupplier(Supplier supplier) async {
    try {
      final supplierModel = SupplierModel.fromEntity(supplier);
      final updatedSupplier = await _remoteDataSource.updateSupplier(supplierModel);
      return updatedSupplier.toEntity();
    } catch (e) {
      throw Exception('Failed to update supplier: $e');
    }
  }

  @override
  Future<void> deleteSupplier(String supplierId) async {
    try {
      await _remoteDataSource.deleteSupplier(supplierId);
    } catch (e) {
      throw Exception('Failed to delete supplier: $e');
    }
  }

  // Placeholder implementations for remaining methods
  @override
  Future<List<Supplier>> getPreferredSuppliers() async {
    return await _remoteDataSource.getPreferredSuppliers().then((suppliers) => suppliers.map((s) => s.toEntity()).toList());
  }

  @override
  Future<List<Supplier>> getSuppliersByCategory(String category) async {
    return await _remoteDataSource.getSuppliersByCategory(category).then((suppliers) => suppliers.map((s) => s.toEntity()).toList());
  }

  @override
  Future<Map<String, dynamic>> getSupplierAnalytics() async {
    return await _remoteDataSource.getSupplierAnalytics();
  }

  @override
  Future<void> bulkUpdateProductStatus(List<String> productIds, ProductStatus status) async {
    return await _remoteDataSource.bulkUpdateProductStatus(productIds, status);
  }

  @override
  Future<void> bulkUpdateProductCategory(List<String> productIds, String categoryId) async {
    return await _remoteDataSource.bulkUpdateProductCategory(productIds, categoryId);
  }

  @override
  Future<void> bulkUpdateProductSupplier(List<String> productIds, String supplierId) async {
    return await _remoteDataSource.bulkUpdateProductSupplier(productIds, supplierId);
  }

  @override
  Future<void> bulkDeleteProducts(List<String> productIds) async {
    return await _remoteDataSource.bulkDeleteProducts(productIds);
  }

  @override
  Future<String> exportProducts({String format = 'csv', List<String>? productIds, Map<String, dynamic>? filters}) async {
    return await _remoteDataSource.exportProducts(format: format, productIds: productIds, filters: filters);
  }

  @override
  Future<Map<String, dynamic>> importProducts(String fileUrl, {bool validateOnly = false}) async {
    return await _remoteDataSource.importProducts(fileUrl, validateOnly: validateOnly);
  }

  @override
  Future<String> exportInventory({String format = 'csv', String? locationId, Map<String, dynamic>? filters}) async {
    return await _remoteDataSource.exportInventory(format: format, locationId: locationId, filters: filters);
  }

  @override
  Future<List<String>> getProductTags() async {
    return await _remoteDataSource.getProductTags();
  }

  @override
  Future<List<String>> getProductBrands() async {
    return await _remoteDataSource.getProductBrands();
  }

  @override
  Future<Map<String, dynamic>> getProductFilters() async {
    return await _remoteDataSource.getProductFilters();
  }

  @override
  Future<List<AdminProduct>> searchProducts(String query, {int limit = 10}) async {
    final products = await _remoteDataSource.searchProducts(query, limit: limit);
    return products.map((model) => model.toEntity()).toList();
  }
}
