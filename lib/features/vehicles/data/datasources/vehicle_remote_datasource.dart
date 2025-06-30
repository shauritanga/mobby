import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/vehicle_model.dart';
import '../models/document_model.dart';
import '../models/maintenance_record_model.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/entities/document.dart';

import 'dart:io';

/// Vehicle remote data source interface
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
abstract class VehicleRemoteDataSource {
  // Vehicle operations
  Future<List<VehicleModel>> getUserVehicles(String userId);
  Future<VehicleModel?> getVehicleById(String vehicleId);
  Future<VehicleModel> createVehicle(VehicleModel vehicle);
  Future<VehicleModel> updateVehicle(VehicleModel vehicle);
  Future<void> deleteVehicle(String vehicleId);

  // Document operations
  Future<List<DocumentModel>> getVehicleDocuments(String vehicleId);
  Future<List<DocumentModel>> getUserDocuments(String userId);
  Future<DocumentModel?> getDocumentById(String documentId);
  Future<DocumentModel> createDocument(DocumentModel document);
  Future<DocumentModel> updateDocument(DocumentModel document);
  Future<void> deleteDocument(String documentId);

  // Maintenance operations
  Future<List<MaintenanceRecordModel>> getVehicleMaintenanceRecords(
    String vehicleId,
  );
  Future<List<MaintenanceRecordModel>> getUserMaintenanceRecords(String userId);
  Future<MaintenanceRecordModel?> getMaintenanceRecordById(String recordId);
  Future<MaintenanceRecordModel> createMaintenanceRecord(
    MaintenanceRecordModel record,
  );
  Future<MaintenanceRecordModel> updateMaintenanceRecord(
    MaintenanceRecordModel record,
  );
  Future<void> deleteMaintenanceRecord(String recordId);

  // File operations
  Future<String> uploadVehicleImage(String vehicleId, String filePath);
  Future<String> uploadDocument(String documentId, String filePath);
  Future<String> uploadMaintenanceReceipt(String recordId, String filePath);
  Future<void> deleteFile(String fileUrl);

  // Validation operations
  Future<bool> validatePlateNumber(
    String plateNumber, {
    String? excludeVehicleId,
  });
  Future<bool> validateEngineNumber(
    String engineNumber, {
    String? excludeVehicleId,
  });
  Future<bool> validateChassisNumber(
    String chassisNumber, {
    String? excludeVehicleId,
  });
  Future<bool> validateVin(String vin, {String? excludeVehicleId});
}

/// Firebase implementation of VehicleRemoteDataSource
class VehicleRemoteDataSourceImpl implements VehicleRemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  VehicleRemoteDataSourceImpl({required this.firestore, required this.storage});

  // Collection references
  CollectionReference get _vehiclesCollection =>
      firestore.collection('vehicles');
  CollectionReference get _documentsCollection =>
      firestore.collection('documents');
  CollectionReference get _maintenanceCollection =>
      firestore.collection('maintenance_records');

  @override
  Future<List<VehicleModel>> getUserVehicles(String userId) async {
    try {
      final querySnapshot = await _vehiclesCollection
          .where('userId', isEqualTo: userId)
          .where('status', isNotEqualTo: VehicleStatus.scrapped.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => VehicleModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleModel?> getVehicleById(String vehicleId) async {
    try {
      final docSnapshot = await _vehiclesCollection.doc(vehicleId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      return VehicleModel.fromFirestore(
        docSnapshot.data() as Map<String, dynamic>,
        docSnapshot.id,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleModel> createVehicle(VehicleModel vehicle) async {
    try {
      final docRef = await _vehiclesCollection.add(vehicle.toFirestore());

      final createdVehicle = vehicle.copyWithModel(id: docRef.id);

      // Update the document with the generated ID
      await docRef.update({'id': docRef.id});

      return createdVehicle;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<VehicleModel> updateVehicle(VehicleModel vehicle) async {
    try {
      await _vehiclesCollection.doc(vehicle.id).update(vehicle.toFirestore());
      return vehicle;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteVehicle(String vehicleId) async {
    try {
      // Soft delete by updating status
      await _vehiclesCollection.doc(vehicleId).update({
        'status': VehicleStatus.scrapped.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<DocumentModel>> getVehicleDocuments(String vehicleId) async {
    try {
      final querySnapshot = await _documentsCollection
          .where('vehicleId', isEqualTo: vehicleId)
          .where('status', isNotEqualTo: DocumentStatus.archived.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => DocumentModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<DocumentModel>> getUserDocuments(String userId) async {
    try {
      final querySnapshot = await _documentsCollection
          .where('userId', isEqualTo: userId)
          .where('status', isNotEqualTo: DocumentStatus.archived.name)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => DocumentModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DocumentModel?> getDocumentById(String documentId) async {
    try {
      final docSnapshot = await _documentsCollection.doc(documentId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      return DocumentModel.fromFirestore(
        docSnapshot.data() as Map<String, dynamic>,
        docSnapshot.id,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DocumentModel> createDocument(DocumentModel document) async {
    try {
      final docRef = await _documentsCollection.add(document.toFirestore());

      final createdDocument = document.copyWithModel(id: docRef.id);

      // Update the document with the generated ID
      await docRef.update({'id': docRef.id});

      return createdDocument;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<DocumentModel> updateDocument(DocumentModel document) async {
    try {
      await _documentsCollection
          .doc(document.id)
          .update(document.toFirestore());
      return document;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      // Soft delete by updating status
      await _documentsCollection.doc(documentId).update({
        'status': DocumentStatus.archived.name,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MaintenanceRecordModel>> getVehicleMaintenanceRecords(
    String vehicleId,
  ) async {
    try {
      final querySnapshot = await _maintenanceCollection
          .where('vehicleId', isEqualTo: vehicleId)
          .orderBy('serviceDate', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => MaintenanceRecordModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<List<MaintenanceRecordModel>> getUserMaintenanceRecords(
    String userId,
  ) async {
    try {
      final querySnapshot = await _maintenanceCollection
          .where('userId', isEqualTo: userId)
          .orderBy('serviceDate', descending: true)
          .get();

      return querySnapshot.docs
          .map(
            (doc) => MaintenanceRecordModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MaintenanceRecordModel?> getMaintenanceRecordById(
    String recordId,
  ) async {
    try {
      final docSnapshot = await _maintenanceCollection.doc(recordId).get();

      if (!docSnapshot.exists) {
        return null;
      }

      return MaintenanceRecordModel.fromFirestore(
        docSnapshot.data() as Map<String, dynamic>,
        docSnapshot.id,
      );
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MaintenanceRecordModel> createMaintenanceRecord(
    MaintenanceRecordModel record,
  ) async {
    try {
      final docRef = await _maintenanceCollection.add(record.toFirestore());

      final createdRecord = record.copyWithModel(id: docRef.id);

      // Update the document with the generated ID
      await docRef.update({'id': docRef.id});

      return createdRecord;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<MaintenanceRecordModel> updateMaintenanceRecord(
    MaintenanceRecordModel record,
  ) async {
    try {
      await _maintenanceCollection.doc(record.id).update(record.toFirestore());
      return record;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteMaintenanceRecord(String recordId) async {
    try {
      await _maintenanceCollection.doc(recordId).delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadVehicleImage(String vehicleId, String filePath) async {
    try {
      final file = File(filePath);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = storage.ref().child('vehicles/$vehicleId/images/$fileName');

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadDocument(String documentId, String filePath) async {
    try {
      final file = File(filePath);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = storage.ref().child('documents/$documentId/$fileName');

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<String> uploadMaintenanceReceipt(
    String recordId,
    String filePath,
  ) async {
    try {
      final file = File(filePath);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${file.path.split('/').last}';
      final ref = storage.ref().child(
        'maintenance/$recordId/receipts/$fileName',
      );

      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> deleteFile(String fileUrl) async {
    try {
      final ref = storage.refFromURL(fileUrl);
      await ref.delete();
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> validatePlateNumber(
    String plateNumber, {
    String? excludeVehicleId,
  }) async {
    try {
      Query query = _vehiclesCollection.where(
        'plateNumber',
        isEqualTo: plateNumber.toUpperCase(),
      );

      if (excludeVehicleId != null) {
        query = query.where(
          FieldPath.documentId,
          isNotEqualTo: excludeVehicleId,
        );
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> validateEngineNumber(
    String engineNumber, {
    String? excludeVehicleId,
  }) async {
    try {
      Query query = _vehiclesCollection.where(
        'engineNumber',
        isEqualTo: engineNumber,
      );

      if (excludeVehicleId != null) {
        query = query.where(
          FieldPath.documentId,
          isNotEqualTo: excludeVehicleId,
        );
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> validateChassisNumber(
    String chassisNumber, {
    String? excludeVehicleId,
  }) async {
    try {
      Query query = _vehiclesCollection.where(
        'chassisNumber',
        isEqualTo: chassisNumber,
      );

      if (excludeVehicleId != null) {
        query = query.where(
          FieldPath.documentId,
          isNotEqualTo: excludeVehicleId,
        );
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<bool> validateVin(String vin, {String? excludeVehicleId}) async {
    try {
      Query query = _vehiclesCollection.where('vin', isEqualTo: vin);

      if (excludeVehicleId != null) {
        query = query.where(
          FieldPath.documentId,
          isNotEqualTo: excludeVehicleId,
        );
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.isEmpty;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }
}
