import '../../../../core/services/firebase_service.dart';
import '../../domain/entities/product.dart';
import '../models/product_model.dart';

/// Firebase datasource for products
class FirebaseProductsDatasource {
  final FirebaseService _firebaseService;

  FirebaseProductsDatasource(this._firebaseService);

  /// Upload sample products to Firebase
  Future<void> uploadSampleProducts(List<Product> products) async {
    try {
      final batch = _firebaseService.batch();

      for (final product in products) {
        final productModel = ProductModel.fromEntity(product);
        final docRef = _firebaseService.productsCollection.doc(product.id);
        batch.set(docRef, productModel.toMap());
      }

      await _firebaseService.commitBatch(batch);
      print('Successfully uploaded ${products.length} products to Firebase');
    } catch (e) {
      print('Error uploading products to Firebase: $e');
      throw Exception('Failed to upload products: $e');
    }
  }

  /// Get all products from Firebase
  Future<List<Product>> getAllProducts() async {
    try {
      print('🔍 FirebaseProductsDatasource: Fetching all products...');
      final querySnapshot = await _firebaseService.getCollection('products');
      print(
        '📦 FirebaseProductsDatasource: Got ${querySnapshot.docs.length} documents',
      );

      final products = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure the document ID is included in the data
        data['id'] = doc.id;
        return ProductModel.fromMap(data).toEntity();
      }).toList();

      print(
        '✅ FirebaseProductsDatasource: Converted to ${products.length} Product entities',
      );
      return products;
    } catch (e) {
      print('❌ FirebaseProductsDatasource: Error fetching products: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  /// Get product by ID from Firebase
  Future<Product?> getProductById(String productId) async {
    try {
      final docSnapshot = await _firebaseService.getDocument(
        'products',
        productId,
      );

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        // Ensure the document ID is included in the data
        data['id'] = docSnapshot.id;
        return ProductModel.fromMap(data).toEntity();
      }

      return null;
    } catch (e) {
      print('Error fetching product $productId from Firebase: $e');
      throw Exception('Failed to fetch product: $e');
    }
  }

  /// Get products by category from Firebase
  Future<List<Product>> getProductsByCategory(String categoryId) async {
    try {
      final querySnapshot = await _firebaseService.getDocumentsWhere(
        'products',
        'categoryId',
        categoryId,
      );

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure the document ID is included in the data
        data['id'] = doc.id;
        return ProductModel.fromMap(data).toEntity();
      }).toList();
    } catch (e) {
      print('Error fetching products by category from Firebase: $e');
      throw Exception('Failed to fetch products by category: $e');
    }
  }

  /// Get products by brand from Firebase
  Future<List<Product>> getProductsByBrand(String brandId) async {
    try {
      final querySnapshot = await _firebaseService.getDocumentsWhere(
        'products',
        'brandId',
        brandId,
      );

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure the document ID is included in the data
        data['id'] = doc.id;
        return ProductModel.fromMap(data).toEntity();
      }).toList();
    } catch (e) {
      print('Error fetching products by brand from Firebase: $e');
      throw Exception('Failed to fetch products by brand: $e');
    }
  }

  /// Get featured products from Firebase
  Future<List<Product>> getFeaturedProducts() async {
    try {
      final querySnapshot = await _firebaseService.getDocumentsWhere(
        'products',
        'isFeatured',
        true,
      );

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        // Ensure the document ID is included in the data
        data['id'] = doc.id;
        return ProductModel.fromMap(data).toEntity();
      }).toList();
    } catch (e) {
      print('Error fetching featured products from Firebase: $e');
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  /// Get products on sale from Firebase
  Future<List<Product>> getProductsOnSale() async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('products')
          .where('originalPrice', isNull: false)
          .get();

      return querySnapshot.docs
          .map((doc) {
            final data = doc.data();
            return ProductModel.fromMap(data).toEntity();
          })
          .where((product) => product.isOnSale)
          .toList();
    } catch (e) {
      print('Error fetching products on sale from Firebase: $e');
      throw Exception('Failed to fetch products on sale: $e');
    }
  }

  /// Search products by name or description
  Future<List<Product>> searchProducts(String query) async {
    try {
      // Note: Firestore doesn't support full-text search natively
      // This is a basic implementation - for production, consider using Algolia or similar
      final querySnapshot = await _firebaseService.getCollection('products');

      final allProducts = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ProductModel.fromMap(data).toEntity();
      }).toList();

      final lowercaseQuery = query.toLowerCase();
      return allProducts
          .where(
            (product) =>
                product.name.toLowerCase().contains(lowercaseQuery) ||
                product.description.toLowerCase().contains(lowercaseQuery) ||
                product.tags.any(
                  (tag) => tag.toLowerCase().contains(lowercaseQuery),
                ),
          )
          .toList();
    } catch (e) {
      print('Error searching products in Firebase: $e');
      throw Exception('Failed to search products: $e');
    }
  }

  /// Stream all products from Firebase
  Stream<List<Product>> streamAllProducts() {
    try {
      return _firebaseService.streamCollection('products').map((querySnapshot) {
        return querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return ProductModel.fromMap(data).toEntity();
        }).toList();
      });
    } catch (e) {
      print('Error streaming products from Firebase: $e');
      throw Exception('Failed to stream products: $e');
    }
  }

  /// Add a new product to Firebase
  Future<void> addProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      await _firebaseService.setDocument(
        'products',
        product.id,
        productModel.toMap(),
      );
    } catch (e) {
      print('Error adding product to Firebase: $e');
      throw Exception('Failed to add product: $e');
    }
  }

  /// Update a product in Firebase
  Future<void> updateProduct(Product product) async {
    try {
      final productModel = ProductModel.fromEntity(product);
      await _firebaseService.updateDocument(
        'products',
        product.id,
        productModel.toMap(),
      );
    } catch (e) {
      print('Error updating product in Firebase: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  /// Delete a product from Firebase
  Future<void> deleteProduct(String productId) async {
    try {
      await _firebaseService.deleteDocument('products', productId);
    } catch (e) {
      print('Error deleting product from Firebase: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Check if products collection exists and has data
  Future<bool> hasProducts() async {
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection('products')
          .limit(1)
          .get();

      return querySnapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error checking if products exist in Firebase: $e');
      return false;
    }
  }
}
