import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

/// Firebase service for managing Firestore operations
class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();
  factory FirebaseService() => _instance;
  FirebaseService._internal();

  late final FirebaseFirestore _firestore;

  /// Initialize Firebase service
  Future<void> initialize() async {
    await Firebase.initializeApp();
    _firestore = FirebaseFirestore.instance;
  }

  /// Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  /// Products collection reference
  CollectionReference get productsCollection => _firestore.collection('products');

  /// Categories collection reference
  CollectionReference get categoriesCollection => _firestore.collection('categories');

  /// Brands collection reference
  CollectionReference get brandsCollection => _firestore.collection('brands');

  /// Add a single document to a collection
  Future<DocumentReference> addDocument(
    String collection,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _firestore.collection(collection).add(data);
    } catch (e) {
      throw Exception('Failed to add document to $collection: $e');
    }
  }

  /// Add a document with custom ID
  Future<void> setDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).set(data);
    } catch (e) {
      throw Exception('Failed to set document in $collection: $e');
    }
  }

  /// Get a document by ID
  Future<DocumentSnapshot> getDocument(
    String collection,
    String documentId,
  ) async {
    try {
      return await _firestore.collection(collection).doc(documentId).get();
    } catch (e) {
      throw Exception('Failed to get document from $collection: $e');
    }
  }

  /// Get all documents from a collection
  Future<QuerySnapshot> getCollection(String collection) async {
    try {
      return await _firestore.collection(collection).get();
    } catch (e) {
      throw Exception('Failed to get collection $collection: $e');
    }
  }

  /// Get documents with query
  Future<QuerySnapshot> getDocumentsWhere(
    String collection,
    String field,
    dynamic value,
  ) async {
    try {
      return await _firestore
          .collection(collection)
          .where(field, isEqualTo: value)
          .get();
    } catch (e) {
      throw Exception('Failed to query collection $collection: $e');
    }
  }

  /// Update a document
  Future<void> updateDocument(
    String collection,
    String documentId,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).update(data);
    } catch (e) {
      throw Exception('Failed to update document in $collection: $e');
    }
  }

  /// Delete a document
  Future<void> deleteDocument(
    String collection,
    String documentId,
  ) async {
    try {
      await _firestore.collection(collection).doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document from $collection: $e');
    }
  }

  /// Batch write operations
  WriteBatch batch() => _firestore.batch();

  /// Commit batch operations
  Future<void> commitBatch(WriteBatch batch) async {
    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to commit batch: $e');
    }
  }

  /// Stream documents from a collection
  Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  /// Stream a specific document
  Stream<DocumentSnapshot> streamDocument(
    String collection,
    String documentId,
  ) {
    return _firestore.collection(collection).doc(documentId).snapshots();
  }
}
