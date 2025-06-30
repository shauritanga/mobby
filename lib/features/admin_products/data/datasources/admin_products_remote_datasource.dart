import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_product_model.dart';
import '../models/inventory_model.dart';
import '../models/category_model.dart';
import '../models/supplier_model.dart';
import '../../domain/entities/admin_product.dart';
import '../../domain/entities/inventory.dart';
import '../../domain/entities/category.dart';
import '../../domain/entities/supplier.dart';

abstract class AdminProductsRemoteDataSource {
  // Product operations
  Future<List<AdminProductModel>> getProducts({
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

  Future<AdminProductModel?> getProductById(String productId);
  Future<AdminProductModel> createProduct(AdminProductModel product);
  Future<AdminProductModel> updateProduct(AdminProductModel product);
  Future<void> deleteProduct(String productId);
  Future<void> updateProductStatus(String productId, ProductStatus status);
  Future<void> updateProductStock(String productId, int quantity);
  Future<List<AdminProductModel>> getProductsByCategory(String categoryId);
  Future<List<AdminProductModel>> getProductsBySupplier(String supplierId);
  Future<List<AdminProductModel>> getLowStockProducts();
  Future<List<AdminProductModel>> getFeaturedProducts();
  Future<Map<String, dynamic>> getProductsAnalytics();

  // Inventory operations
  Future<List<InventoryModel>> getInventory({
    String? searchQuery,
    String? productId,
    String? locationId,
    InventoryStatus? status,
    bool? isLowStock,
    int page = 1,
    int limit = 20,
  });

  Future<InventoryModel?> getInventoryById(String inventoryId);
  Future<InventoryModel?> getInventoryByProduct(
    String productId, {
    String? variantId,
    String? locationId,
  });
  Future<InventoryModel> updateInventory(InventoryModel inventory);
  Future<InventoryMovementModel> addInventoryMovement(
    InventoryMovementModel movement,
  );
  Future<List<InventoryMovementModel>> getInventoryMovements({
    String? productId,
    String? locationId,
    InventoryMovementType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  });
  Future<List<InventoryModel>> getLowStockInventory();
  Future<List<InventoryLocationModel>> getInventoryLocations();
  Future<Map<String, dynamic>> getInventoryAnalytics();

  // Category operations
  Future<List<CategoryModel>> getCategories({
    String? searchQuery,
    String? parentId,
    CategoryStatus? status,
    bool? isFeatured,
    String? sortBy,
    bool sortDescending = false,
  });

  Future<CategoryModel?> getCategoryById(String categoryId);
  Future<CategoryModel> createCategory(CategoryModel category);
  Future<CategoryModel> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String categoryId);
  Future<List<CategoryModel>> getRootCategories();
  Future<List<CategoryModel>> getSubcategories(String parentId);
  Future<List<CategoryModel>> getFeaturedCategories();
  Future<void> updateCategoryProductCount(String categoryId);

  // Supplier operations
  Future<List<SupplierModel>> getSuppliers({
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

  Future<SupplierModel?> getSupplierById(String supplierId);
  Future<SupplierModel> createSupplier(SupplierModel supplier);
  Future<SupplierModel> updateSupplier(SupplierModel supplier);
  Future<void> deleteSupplier(String supplierId);
  Future<List<SupplierModel>> getPreferredSuppliers();
  Future<List<SupplierModel>> getSuppliersByCategory(String category);
  Future<Map<String, dynamic>> getSupplierAnalytics();

  // Bulk operations
  Future<void> bulkUpdateProductStatus(
    List<String> productIds,
    ProductStatus status,
  );
  Future<void> bulkUpdateProductCategory(
    List<String> productIds,
    String categoryId,
  );
  Future<void> bulkUpdateProductSupplier(
    List<String> productIds,
    String supplierId,
  );
  Future<void> bulkDeleteProducts(List<String> productIds);

  // Import/Export operations
  Future<String> exportProducts({
    String format = 'csv',
    List<String>? productIds,
    Map<String, dynamic>? filters,
  });
  Future<Map<String, dynamic>> importProducts(
    String fileUrl, {
    bool validateOnly = false,
  });
  Future<String> exportInventory({
    String format = 'csv',
    String? locationId,
    Map<String, dynamic>? filters,
  });

  // Search and filters
  Future<List<String>> getProductTags();
  Future<List<String>> getProductBrands();
  Future<Map<String, dynamic>> getProductFilters();
  Future<List<AdminProductModel>> searchProducts(
    String query, {
    int limit = 10,
  });
}

class AdminProductsRemoteDataSourceImpl
    implements AdminProductsRemoteDataSource {
  final FirebaseFirestore _firestore;

  AdminProductsRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<AdminProductModel>> getProducts({
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
      Query query = _firestore.collection('adminProducts');

      // Apply filters
      if (categoryId != null) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }

      if (supplierId != null) {
        query = query.where('supplierId', isEqualTo: supplierId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (isFeatured != null) {
        query = query.where('isFeatured', isEqualTo: isFeatured);
      }

      if (isLowStock == true) {
        query = query.where('isLowStock', isEqualTo: true);
      }

      // Apply sorting
      final sortField = sortBy ?? 'updatedAt';
      query = query.orderBy(sortField, descending: sortDescending);

      // Apply pagination
      if (page > 1) {
        final offset = (page - 1) * limit;
        query = query.limit(offset + limit);
      } else {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      if (page > 1) {
        final offset = (page - 1) * limit;
        docs = docs.skip(offset).toList();
      }

      final products = docs
          .map(
            (doc) => AdminProductModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      // Apply search query filter (client-side for simplicity)
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final filteredProducts = products.where((product) {
          final query = searchQuery.toLowerCase();
          return product.name.toLowerCase().contains(query) ||
              product.description.toLowerCase().contains(query) ||
              product.sku.toLowerCase().contains(query) ||
              product.tags.any((tag) => tag.toLowerCase().contains(query));
        }).toList();

        return filteredProducts;
      }

      return products;
    } catch (e) {
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<AdminProductModel?> getProductById(String productId) async {
    try {
      final doc = await _firestore
          .collection('adminProducts')
          .doc(productId)
          .get();

      if (!doc.exists) return null;

      return AdminProductModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch product: $e');
    }
  }

  @override
  Future<AdminProductModel> createProduct(AdminProductModel product) async {
    try {
      final productData = product.toJson();
      productData.remove('id');

      // Add additional fields
      productData['createdAt'] = FieldValue.serverTimestamp();
      productData['updatedAt'] = FieldValue.serverTimestamp();
      productData['isLowStock'] =
          product.stockQuantity <= (product.lowStockThreshold ?? 10);

      final docRef = await _firestore
          .collection('adminProducts')
          .add(productData);

      // Get the created product with server timestamp
      final createdDoc = await docRef.get();
      return AdminProductModel.fromJson({
        'id': docRef.id,
        ...createdDoc.data()!,
      });
    } catch (e) {
      throw Exception('Failed to create product: $e');
    }
  }

  @override
  Future<AdminProductModel> updateProduct(AdminProductModel product) async {
    try {
      final productData = product.toJson();
      productData['updatedAt'] = FieldValue.serverTimestamp();
      productData['isLowStock'] =
          product.stockQuantity <= (product.lowStockThreshold ?? 10);

      await _firestore
          .collection('adminProducts')
          .doc(product.id)
          .update(productData);

      // Return updated product
      final updatedDoc = await _firestore
          .collection('adminProducts')
          .doc(product.id)
          .get();
      return AdminProductModel.fromJson({
        'id': product.id,
        ...updatedDoc.data()!,
      });
    } catch (e) {
      throw Exception('Failed to update product: $e');
    }
  }

  @override
  Future<void> deleteProduct(String productId) async {
    try {
      await _firestore.collection('adminProducts').doc(productId).delete();
    } catch (e) {
      throw Exception('Failed to delete product: $e');
    }
  }

  @override
  Future<void> updateProductStatus(
    String productId,
    ProductStatus status,
  ) async {
    try {
      await _firestore.collection('adminProducts').doc(productId).update({
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product status: $e');
    }
  }

  @override
  Future<void> updateProductStock(String productId, int quantity) async {
    try {
      final productDoc = await _firestore
          .collection('adminProducts')
          .doc(productId)
          .get();
      if (!productDoc.exists) {
        throw Exception('Product not found');
      }

      final productData = productDoc.data()!;
      final lowStockThreshold = productData['lowStockThreshold'] as int? ?? 10;

      await _firestore.collection('adminProducts').doc(productId).update({
        'stockQuantity': quantity,
        'isLowStock': quantity <= lowStockThreshold,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update product stock: $e');
    }
  }

  @override
  Future<List<AdminProductModel>> getProductsByCategory(
    String categoryId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('adminProducts')
          .where('categoryId', isEqualTo: categoryId)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map(
            (doc) => AdminProductModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  @override
  Future<List<AdminProductModel>> getProductsBySupplier(
    String supplierId,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('adminProducts')
          .where('supplierId', isEqualTo: supplierId)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map(
            (doc) => AdminProductModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch products by supplier: $e');
    }
  }

  @override
  Future<List<AdminProductModel>> getLowStockProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('adminProducts')
          .where('isLowStock', isEqualTo: true)
          .where('status', isEqualTo: ProductStatus.active.name)
          .orderBy('stockQuantity')
          .get();

      return querySnapshot.docs
          .map(
            (doc) => AdminProductModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch low stock products: $e');
    }
  }

  @override
  Future<List<AdminProductModel>> getFeaturedProducts() async {
    try {
      final querySnapshot = await _firestore
          .collection('adminProducts')
          .where('isFeatured', isEqualTo: true)
          .where('status', isEqualTo: ProductStatus.active.name)
          .orderBy('updatedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => AdminProductModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getProductsAnalytics() async {
    try {
      final productsSnapshot = await _firestore
          .collection('adminProducts')
          .get();
      final totalProducts = productsSnapshot.docs.length;

      int activeProducts = 0;
      int lowStockProducts = 0;
      int featuredProducts = 0;
      double totalValue = 0.0;

      for (final doc in productsSnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String?;
        final isLowStock = data['isLowStock'] as bool? ?? false;
        final isFeatured = data['isFeatured'] as bool? ?? false;
        final price = (data['price'] as num?)?.toDouble() ?? 0.0;
        final stockQuantity = data['stockQuantity'] as int? ?? 0;

        if (status == ProductStatus.active.name) activeProducts++;
        if (isLowStock) lowStockProducts++;
        if (isFeatured) featuredProducts++;
        totalValue += price * stockQuantity;
      }

      return {
        'totalProducts': totalProducts,
        'activeProducts': activeProducts,
        'inactiveProducts': totalProducts - activeProducts,
        'lowStockProducts': lowStockProducts,
        'featuredProducts': featuredProducts,
        'totalInventoryValue': totalValue,
        'averageProductValue': totalProducts > 0
            ? totalValue / totalProducts
            : 0.0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to fetch products analytics: $e');
    }
  }

  @override
  Future<List<InventoryModel>> getInventory({
    String? searchQuery,
    String? productId,
    String? locationId,
    InventoryStatus? status,
    bool? isLowStock,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore.collection('inventory');

      if (productId != null) {
        query = query.where('productId', isEqualTo: productId);
      }

      if (locationId != null) {
        query = query.where('locationId', isEqualTo: locationId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (isLowStock == true) {
        query = query.where('isLowStock', isEqualTo: true);
      }

      query = query.orderBy('updatedAt', descending: true);

      if (page > 1) {
        final offset = (page - 1) * limit;
        query = query.limit(offset + limit);
      } else {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      if (page > 1) {
        final offset = (page - 1) * limit;
        docs = docs.skip(offset).toList();
      }

      final inventory = docs
          .map(
            (doc) => InventoryModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      // Apply search query filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final filteredInventory = inventory.where((inv) {
          final query = searchQuery.toLowerCase();
          return inv.productName.toLowerCase().contains(query) ||
              inv.productSku.toLowerCase().contains(query) ||
              inv.locationName.toLowerCase().contains(query);
        }).toList();

        return filteredInventory;
      }

      return inventory;
    } catch (e) {
      throw Exception('Failed to fetch inventory: $e');
    }
  }

  @override
  Future<InventoryModel?> getInventoryById(String inventoryId) async {
    try {
      final doc = await _firestore
          .collection('inventory')
          .doc(inventoryId)
          .get();

      if (!doc.exists) return null;

      return InventoryModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch inventory: $e');
    }
  }

  @override
  Future<InventoryModel?> getInventoryByProduct(
    String productId, {
    String? variantId,
    String? locationId,
  }) async {
    try {
      Query query = _firestore
          .collection('inventory')
          .where('productId', isEqualTo: productId);

      if (variantId != null) {
        query = query.where('variantId', isEqualTo: variantId);
      }

      if (locationId != null) {
        query = query.where('locationId', isEqualTo: locationId);
      }

      final querySnapshot = await query.limit(1).get();

      if (querySnapshot.docs.isEmpty) return null;

      final doc = querySnapshot.docs.first;
      return InventoryModel.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      throw Exception('Failed to fetch inventory by product: $e');
    }
  }

  @override
  Future<InventoryModel> updateInventory(InventoryModel inventory) async {
    try {
      final inventoryData = inventory.toJson();
      inventoryData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('inventory')
          .doc(inventory.id)
          .update(inventoryData);

      final updatedDoc = await _firestore
          .collection('inventory')
          .doc(inventory.id)
          .get();
      return InventoryModel.fromJson({
        'id': inventory.id,
        ...updatedDoc.data()!,
      });
    } catch (e) {
      throw Exception('Failed to update inventory: $e');
    }
  }

  @override
  Future<InventoryMovementModel> addInventoryMovement(
    InventoryMovementModel movement,
  ) async {
    try {
      final movementData = movement.toJson();
      movementData.remove('id');
      movementData['timestamp'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection('inventoryMovements')
          .add(movementData);

      final createdDoc = await docRef.get();
      return InventoryMovementModel.fromJson({
        'id': docRef.id,
        ...createdDoc.data()!,
      });
    } catch (e) {
      throw Exception('Failed to add inventory movement: $e');
    }
  }

  @override
  Future<List<InventoryMovementModel>> getInventoryMovements({
    String? productId,
    String? locationId,
    InventoryMovementType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      Query query = _firestore.collection('inventoryMovements');

      if (productId != null) {
        query = query.where('productId', isEqualTo: productId);
      }

      if (locationId != null) {
        query = query.where('locationId', isEqualTo: locationId);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      query = query.orderBy('timestamp', descending: true);

      if (page > 1) {
        final offset = (page - 1) * limit;
        query = query.limit(offset + limit);
      } else {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      if (page > 1) {
        final offset = (page - 1) * limit;
        docs = docs.skip(offset).toList();
      }

      return docs
          .map(
            (doc) => InventoryMovementModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch inventory movements: $e');
    }
  }

  @override
  Future<List<InventoryModel>> getLowStockInventory() async {
    try {
      final querySnapshot = await _firestore
          .collection('inventory')
          .where('isLowStock', isEqualTo: true)
          .orderBy('quantity')
          .get();

      return querySnapshot.docs
          .map((doc) => InventoryModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch low stock inventory: $e');
    }
  }

  @override
  Future<List<InventoryLocationModel>> getInventoryLocations() async {
    try {
      final querySnapshot = await _firestore
          .collection('inventoryLocations')
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return querySnapshot.docs
          .map(
            (doc) =>
                InventoryLocationModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      // Return default location if none exist
      return [
        InventoryLocationModel(
          id: 'default',
          name: 'Main Warehouse',
          code: 'MAIN',
          address: 'Default Location',
          isDefault: true,
        ),
      ];
    }
  }

  @override
  Future<Map<String, dynamic>> getInventoryAnalytics() async {
    try {
      final inventorySnapshot = await _firestore.collection('inventory').get();
      final totalItems = inventorySnapshot.docs.length;

      int lowStockItems = 0;
      double totalValue = 0.0;

      for (final doc in inventorySnapshot.docs) {
        final data = doc.data();
        final isLowStock = data['isLowStock'] as bool? ?? false;
        final totalItemValue = (data['totalValue'] as num?)?.toDouble() ?? 0.0;

        if (isLowStock) lowStockItems++;
        totalValue += totalItemValue;
      }

      return {
        'totalItems': totalItems,
        'lowStockItems': lowStockItems,
        'totalValue': totalValue,
        'averageValue': totalItems > 0 ? totalValue / totalItems : 0.0,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to fetch inventory analytics: $e');
    }
  }

  // Category operations
  @override
  Future<List<CategoryModel>> getCategories({
    String? searchQuery,
    String? parentId,
    CategoryStatus? status,
    bool? isFeatured,
    String? sortBy,
    bool sortDescending = false,
  }) async {
    try {
      Query query = _firestore.collection('categories');

      if (parentId != null) {
        query = query.where('parentId', isEqualTo: parentId);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (isFeatured != null) {
        query = query.where('isFeatured', isEqualTo: isFeatured);
      }

      final sortField = sortBy ?? 'sortOrder';
      query = query.orderBy(sortField, descending: sortDescending);

      final querySnapshot = await query.get();

      final categories = querySnapshot.docs
          .map(
            (doc) => CategoryModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      // Apply search query filter
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final filteredCategories = categories.where((category) {
          final query = searchQuery.toLowerCase();
          return category.name.toLowerCase().contains(query) ||
              category.description.toLowerCase().contains(query);
        }).toList();

        return filteredCategories;
      }

      return categories;
    } catch (e) {
      throw Exception('Failed to fetch categories: $e');
    }
  }

  @override
  Future<CategoryModel?> getCategoryById(String categoryId) async {
    try {
      final doc = await _firestore
          .collection('categories')
          .doc(categoryId)
          .get();

      if (!doc.exists) return null;

      return CategoryModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch category: $e');
    }
  }

  @override
  Future<CategoryModel> createCategory(CategoryModel category) async {
    try {
      final categoryData = category.toJson();
      categoryData.remove('id');
      categoryData['createdAt'] = FieldValue.serverTimestamp();
      categoryData['updatedAt'] = FieldValue.serverTimestamp();

      final docRef = await _firestore
          .collection('categories')
          .add(categoryData);

      final createdDoc = await docRef.get();
      return CategoryModel.fromJson({'id': docRef.id, ...createdDoc.data()!});
    } catch (e) {
      throw Exception('Failed to create category: $e');
    }
  }

  @override
  Future<CategoryModel> updateCategory(CategoryModel category) async {
    try {
      final categoryData = category.toJson();
      categoryData['updatedAt'] = FieldValue.serverTimestamp();

      await _firestore
          .collection('categories')
          .doc(category.id)
          .update(categoryData);

      final updatedDoc = await _firestore
          .collection('categories')
          .doc(category.id)
          .get();
      return CategoryModel.fromJson({'id': category.id, ...updatedDoc.data()!});
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  @override
  Future<void> deleteCategory(String categoryId) async {
    try {
      await _firestore.collection('categories').doc(categoryId).delete();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getRootCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .where('parentId', isNull: true)
          .where('status', isEqualTo: CategoryStatus.active.name)
          .orderBy('sortOrder')
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      // Return sample categories if none exist
      return [
        CategoryModel(
          id: 'electronics',
          name: 'Electronics',
          description: 'Electronic devices and accessories',
          status: CategoryStatus.active,
          seo: const CategorySEOModel(),
          customFields: const {},
          childrenIds: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'system',
        ),
        CategoryModel(
          id: 'automotive',
          name: 'Automotive',
          description: 'Car parts and accessories',
          status: CategoryStatus.active,
          seo: const CategorySEOModel(),
          customFields: const {},
          childrenIds: const [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          createdBy: 'system',
        ),
      ];
    }
  }

  @override
  Future<List<CategoryModel>> getSubcategories(String parentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .where('parentId', isEqualTo: parentId)
          .where('status', isEqualTo: CategoryStatus.active.name)
          .orderBy('sortOrder')
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch subcategories: $e');
    }
  }

  @override
  Future<List<CategoryModel>> getFeaturedCategories() async {
    try {
      final querySnapshot = await _firestore
          .collection('categories')
          .where('isFeatured', isEqualTo: true)
          .where('status', isEqualTo: CategoryStatus.active.name)
          .orderBy('sortOrder')
          .get();

      return querySnapshot.docs
          .map((doc) => CategoryModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch featured categories: $e');
    }
  }

  @override
  Future<void> updateCategoryProductCount(String categoryId) async {
    try {
      final productsSnapshot = await _firestore
          .collection('adminProducts')
          .where('categoryId', isEqualTo: categoryId)
          .get();

      await _firestore.collection('categories').doc(categoryId).update({
        'productCount': productsSnapshot.docs.length,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update category product count: $e');
    }
  }

  // Supplier operations - Stub implementations
  @override
  Future<List<SupplierModel>> getSuppliers({
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
    // Return sample suppliers for now
    return [
      SupplierModel(
        id: 'supplier1',
        name: 'Tech Supplies Ltd',
        type: SupplierType.manufacturer,
        status: SupplierStatus.active,
        contact: const SupplierContactModel(email: 'contact@techsupplies.com'),
        address: const SupplierAddressModel(
          street: '123 Tech Street',
          city: 'Dar es Salaam',
          state: 'Dar es Salaam',
          postalCode: '12345',
          country: 'Tanzania',
        ),
        paymentTerms: const SupplierPaymentTermsModel(
          paymentDays: 30,
          currency: 'TZS',
        ),
        categories: const ['electronics'],
        customFields: const {},
        tags: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        createdBy: 'system',
      ),
    ];
  }

  @override
  Future<SupplierModel?> getSupplierById(String supplierId) async {
    return null; // Stub implementation
  }

  @override
  Future<SupplierModel> createSupplier(SupplierModel supplier) async {
    return supplier; // Stub implementation
  }

  @override
  Future<SupplierModel> updateSupplier(SupplierModel supplier) async {
    return supplier; // Stub implementation
  }

  @override
  Future<void> deleteSupplier(String supplierId) async {
    // Stub implementation
  }

  @override
  Future<List<SupplierModel>> getPreferredSuppliers() async {
    return []; // Stub implementation
  }

  @override
  Future<List<SupplierModel>> getSuppliersByCategory(String category) async {
    return []; // Stub implementation
  }

  @override
  Future<Map<String, dynamic>> getSupplierAnalytics() async {
    return {
      'totalSuppliers': 0,
      'activeSuppliers': 0,
      'preferredSuppliers': 0,
      'lastUpdated': DateTime.now().toIso8601String(),
    };
  }

  // Bulk operations - Stub implementations
  @override
  Future<void> bulkUpdateProductStatus(
    List<String> productIds,
    ProductStatus status,
  ) async {
    // Stub implementation
  }

  @override
  Future<void> bulkUpdateProductCategory(
    List<String> productIds,
    String categoryId,
  ) async {
    // Stub implementation
  }

  @override
  Future<void> bulkUpdateProductSupplier(
    List<String> productIds,
    String supplierId,
  ) async {
    // Stub implementation
  }

  @override
  Future<void> bulkDeleteProducts(List<String> productIds) async {
    // Stub implementation
  }

  // Import/Export operations - Stub implementations
  @override
  Future<String> exportProducts({
    String format = 'csv',
    List<String>? productIds,
    Map<String, dynamic>? filters,
  }) async {
    return 'export-url'; // Stub implementation
  }

  @override
  Future<Map<String, dynamic>> importProducts(
    String fileUrl, {
    bool validateOnly = false,
  }) async {
    return {'success': true, 'imported': 0}; // Stub implementation
  }

  @override
  Future<String> exportInventory({
    String format = 'csv',
    String? locationId,
    Map<String, dynamic>? filters,
  }) async {
    return 'export-url'; // Stub implementation
  }

  // Search and filters - Stub implementations
  @override
  Future<List<String>> getProductTags() async {
    return ['electronics', 'automotive', 'accessories']; // Stub implementation
  }

  @override
  Future<List<String>> getProductBrands() async {
    return ['Samsung', 'Apple', 'Toyota']; // Stub implementation
  }

  @override
  Future<Map<String, dynamic>> getProductFilters() async {
    return {
      'categories': [],
      'suppliers': [],
      'brands': [],
      'tags': [],
    }; // Stub implementation
  }

  @override
  Future<List<AdminProductModel>> searchProducts(
    String query, {
    int limit = 10,
  }) async {
    return []; // Stub implementation
  }
}
