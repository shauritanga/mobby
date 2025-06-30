import '../entities/admin_product.dart';
import '../entities/inventory.dart';
import '../entities/category.dart';
import '../entities/supplier.dart';

abstract class AdminProductsRepository {
  // Product operations
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
  });
  
  Future<AdminProduct?> getProductById(String productId);
  
  Future<AdminProduct> createProduct(AdminProduct product);
  
  Future<AdminProduct> updateProduct(AdminProduct product);
  
  Future<void> deleteProduct(String productId);
  
  Future<void> updateProductStatus(String productId, ProductStatus status);
  
  Future<void> updateProductStock(String productId, int quantity);
  
  Future<List<AdminProduct>> getProductsByCategory(String categoryId);
  
  Future<List<AdminProduct>> getProductsBySupplier(String supplierId);
  
  Future<List<AdminProduct>> getLowStockProducts();
  
  Future<List<AdminProduct>> getFeaturedProducts();
  
  Future<Map<String, dynamic>> getProductsAnalytics();

  // Inventory operations
  Future<List<Inventory>> getInventory({
    String? searchQuery,
    String? productId,
    String? locationId,
    InventoryStatus? status,
    bool? isLowStock,
    int page = 1,
    int limit = 20,
  });
  
  Future<Inventory?> getInventoryById(String inventoryId);
  
  Future<Inventory?> getInventoryByProduct(String productId, {String? variantId, String? locationId});
  
  Future<Inventory> updateInventory(Inventory inventory);
  
  Future<InventoryMovement> addInventoryMovement(InventoryMovement movement);
  
  Future<List<InventoryMovement>> getInventoryMovements({
    String? productId,
    String? locationId,
    InventoryMovementType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  });
  
  Future<List<Inventory>> getLowStockInventory();
  
  Future<List<InventoryLocation>> getInventoryLocations();
  
  Future<Map<String, dynamic>> getInventoryAnalytics();

  // Category operations
  Future<List<Category>> getCategories({
    String? searchQuery,
    String? parentId,
    CategoryStatus? status,
    bool? isFeatured,
    String? sortBy,
    bool sortDescending = false,
  });
  
  Future<Category?> getCategoryById(String categoryId);
  
  Future<Category> createCategory(Category category);
  
  Future<Category> updateCategory(Category category);
  
  Future<void> deleteCategory(String categoryId);
  
  Future<List<Category>> getRootCategories();
  
  Future<List<Category>> getSubcategories(String parentId);
  
  Future<List<Category>> getFeaturedCategories();
  
  Future<void> updateCategoryProductCount(String categoryId);

  // Supplier operations
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
  });
  
  Future<Supplier?> getSupplierById(String supplierId);
  
  Future<Supplier> createSupplier(Supplier supplier);
  
  Future<Supplier> updateSupplier(Supplier supplier);
  
  Future<void> deleteSupplier(String supplierId);
  
  Future<List<Supplier>> getPreferredSuppliers();
  
  Future<List<Supplier>> getSuppliersByCategory(String category);
  
  Future<Map<String, dynamic>> getSupplierAnalytics();

  // Bulk operations
  Future<void> bulkUpdateProductStatus(List<String> productIds, ProductStatus status);
  
  Future<void> bulkUpdateProductCategory(List<String> productIds, String categoryId);
  
  Future<void> bulkUpdateProductSupplier(List<String> productIds, String supplierId);
  
  Future<void> bulkDeleteProducts(List<String> productIds);

  // Import/Export operations
  Future<String> exportProducts({
    String format = 'csv',
    List<String>? productIds,
    Map<String, dynamic>? filters,
  });
  
  Future<Map<String, dynamic>> importProducts(String fileUrl, {bool validateOnly = false});
  
  Future<String> exportInventory({
    String format = 'csv',
    String? locationId,
    Map<String, dynamic>? filters,
  });

  // Search and filters
  Future<List<String>> getProductTags();
  
  Future<List<String>> getProductBrands();
  
  Future<Map<String, dynamic>> getProductFilters();
  
  Future<List<AdminProduct>> searchProducts(String query, {int limit = 10});
}
