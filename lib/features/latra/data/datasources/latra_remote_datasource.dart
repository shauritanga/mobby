import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

import '../models/latra_application_model.dart';
import '../models/latra_status_model.dart';
import '../models/latra_document_model.dart';
import '../../domain/entities/latra_application.dart';
import '../../domain/entities/latra_document.dart';
import '../../domain/entities/latra_status.dart';

/// LATRA remote data source for API integration
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
abstract class LATRARemoteDataSource {
  // Application operations
  Future<List<LATRAApplicationModel>> getUserApplications(String userId);
  Future<LATRAApplicationModel?> getApplicationById(String applicationId);
  Future<LATRAApplicationModel> createApplication(
    LATRAApplicationModel application,
  );
  Future<LATRAApplicationModel> updateApplication(
    LATRAApplicationModel application,
  );
  Future<void> deleteApplication(String applicationId);
  Future<LATRAApplicationModel> submitApplication(String applicationId);

  // Status operations
  Future<List<LATRAStatusModel>> getApplicationStatus(String applicationId);
  Future<LATRAStatusModel?> getLatestStatus(String applicationId);
  Future<List<LATRAStatusModel>> getUserStatusUpdates(String userId);

  // Document operations
  Future<List<LATRADocumentModel>> getApplicationDocuments(
    String applicationId,
  );
  Future<LATRADocumentModel?> getDocumentById(String documentId);
  Future<LATRADocumentModel> uploadDocument(
    String applicationId,
    String filePath,
    LATRADocumentType type,
    String title,
    String? description,
  );
  Future<void> deleteDocument(String documentId);
  Future<List<LATRADocumentModel>> getUserDocuments(String userId);

  // Application metadata
  Future<List<String>> getRequiredDocuments(LATRAApplicationType type);
  Future<double> getApplicationFee(LATRAApplicationType type);

  // Payment operations
  Future<String> initiatePayment(String applicationId, double amount);
  Future<bool> verifyPayment(String paymentReference);
}

/// Firebase implementation of LATRA remote data source
class LATRARemoteDataSourceImpl implements LATRARemoteDataSource {
  final FirebaseFirestore firestore;
  final FirebaseStorage storage;

  const LATRARemoteDataSourceImpl({
    required this.firestore,
    required this.storage,
  });

  @override
  Future<List<LATRAApplicationModel>> getUserApplications(String userId) async {
    final querySnapshot = await firestore
        .collection('latra_applications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => LATRAApplicationModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<LATRAApplicationModel?> getApplicationById(
    String applicationId,
  ) async {
    final docSnapshot = await firestore
        .collection('latra_applications')
        .doc(applicationId)
        .get();

    if (!docSnapshot.exists) return null;

    return LATRAApplicationModel.fromFirestore(
      docSnapshot.data()!,
      docSnapshot.id,
    );
  }

  @override
  Future<LATRAApplicationModel> createApplication(
    LATRAApplicationModel application,
  ) async {
    final docRef = firestore.collection('latra_applications').doc();

    // Generate application number
    final applicationNumber = 'LATRA-${DateTime.now().millisecondsSinceEpoch}';

    final updatedApplication = application.copyWith(
      id: docRef.id,
      applicationNumber: applicationNumber,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(updatedApplication.toFirestore());

    return updatedApplication;
  }

  @override
  Future<LATRAApplicationModel> updateApplication(
    LATRAApplicationModel application,
  ) async {
    final updatedApplication = application.copyWith(updatedAt: DateTime.now());

    await firestore
        .collection('latra_applications')
        .doc(application.id)
        .update(updatedApplication.toFirestore());

    return updatedApplication;
  }

  @override
  Future<void> deleteApplication(String applicationId) async {
    await firestore
        .collection('latra_applications')
        .doc(applicationId)
        .delete();
  }

  @override
  Future<LATRAApplicationModel> submitApplication(String applicationId) async {
    final application = await getApplicationById(applicationId);
    if (application == null) {
      throw Exception('Application not found');
    }

    final updatedApplication = application.copyWith(
      status: LATRAApplicationStatus.pending,
      submissionDate: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await updateApplication(updatedApplication);

    // Create initial status
    await _createStatusUpdate(
      applicationId,
      application.userId,
      'Application Submitted',
      'Your application has been submitted successfully',
    );

    return updatedApplication;
  }

  @override
  Future<List<LATRAStatusModel>> getApplicationStatus(
    String applicationId,
  ) async {
    final querySnapshot = await firestore
        .collection('latra_status')
        .where('applicationId', isEqualTo: applicationId)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => LATRAStatusModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<LATRAStatusModel?> getLatestStatus(String applicationId) async {
    final querySnapshot = await firestore
        .collection('latra_status')
        .where('applicationId', isEqualTo: applicationId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    return LATRAStatusModel.fromFirestore(doc.data(), doc.id);
  }

  @override
  Future<List<LATRAStatusModel>> getUserStatusUpdates(String userId) async {
    final querySnapshot = await firestore
        .collection('latra_status')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => LATRAStatusModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<LATRADocumentModel>> getApplicationDocuments(
    String applicationId,
  ) async {
    final querySnapshot = await firestore
        .collection('latra_documents')
        .where('applicationId', isEqualTo: applicationId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => LATRADocumentModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<LATRADocumentModel?> getDocumentById(String documentId) async {
    final docSnapshot = await firestore
        .collection('latra_documents')
        .doc(documentId)
        .get();

    if (!docSnapshot.exists) return null;

    return LATRADocumentModel.fromFirestore(
      docSnapshot.data()!,
      docSnapshot.id,
    );
  }

  @override
  Future<LATRADocumentModel> uploadDocument(
    String applicationId,
    String filePath,
    LATRADocumentType type,
    String title,
    String? description,
  ) async {
    final file = File(filePath);
    final fileName = file.path.split('/').last;
    final fileExtension = fileName.split('.').last;

    // Upload file to Firebase Storage
    final storageRef = storage
        .ref()
        .child('latra_documents')
        .child(applicationId)
        .child('${DateTime.now().millisecondsSinceEpoch}.$fileExtension');

    final uploadTask = await storageRef.putFile(file);
    final downloadUrl = await uploadTask.ref.getDownloadURL();

    // Get file metadata
    final fileSize = await file.length();

    // Create document record
    final docRef = firestore.collection('latra_documents').doc();

    final document = LATRADocumentModel(
      id: docRef.id,
      applicationId: applicationId,
      userId: '', // Will be set from application
      type: type,
      title: title,
      description: description,
      fileUrl: downloadUrl,
      fileName: fileName,
      fileType: fileExtension,
      fileSize: fileSize,
      status: LATRADocumentStatus.pending,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await docRef.set(document.toFirestore());

    return document;
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    // Get document to delete file from storage
    final document = await getDocumentById(documentId);
    if (document != null) {
      try {
        await storage.refFromURL(document.fileUrl).delete();
      } catch (e) {
        // File might not exist, continue with document deletion
      }
    }

    await firestore.collection('latra_documents').doc(documentId).delete();
  }

  @override
  Future<List<LATRADocumentModel>> getUserDocuments(String userId) async {
    final querySnapshot = await firestore
        .collection('latra_documents')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();

    return querySnapshot.docs
        .map((doc) => LATRADocumentModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<String>> getRequiredDocuments(LATRAApplicationType type) async {
    // This would typically come from a configuration collection
    // For now, return hardcoded requirements
    switch (type) {
      case LATRAApplicationType.vehicleRegistration:
        return [
          'National ID',
          'Purchase Receipt',
          'Insurance Certificate',
          'Inspection Certificate',
        ];
      case LATRAApplicationType.licenseRenewal:
        return ['National ID', 'Current License', 'Medical Certificate'];
      case LATRAApplicationType.ownershipTransfer:
        return [
          'National ID',
          'Vehicle Registration',
          'Transfer Agreement',
          'Tax Clearance',
        ];
      default:
        return ['National ID'];
    }
  }

  @override
  Future<double> getApplicationFee(LATRAApplicationType type) async {
    // This would typically come from a configuration collection
    // For now, return hardcoded fees in TZS
    switch (type) {
      case LATRAApplicationType.vehicleRegistration:
        return 50000.0; // 50,000 TZS
      case LATRAApplicationType.licenseRenewal:
        return 30000.0; // 30,000 TZS
      case LATRAApplicationType.ownershipTransfer:
        return 25000.0; // 25,000 TZS
      case LATRAApplicationType.duplicateRegistration:
        return 15000.0; // 15,000 TZS
      case LATRAApplicationType.temporaryPermit:
        return 10000.0; // 10,000 TZS
    }
  }

  @override
  Future<String> initiatePayment(String applicationId, double amount) async {
    // This would integrate with a payment gateway
    // For now, return a mock payment reference
    final paymentRef = 'PAY-${DateTime.now().millisecondsSinceEpoch}';

    // Update application with payment reference
    final application = await getApplicationById(applicationId);
    if (application != null) {
      await updateApplication(
        application.copyWith(paymentReference: paymentRef),
      );
    }

    return paymentRef;
  }

  @override
  Future<bool> verifyPayment(String paymentReference) async {
    // This would verify payment with the payment gateway
    // For now, return true for demo purposes
    return true;
  }

  /// Helper method to create status updates
  Future<void> _createStatusUpdate(
    String applicationId,
    String userId,
    String title,
    String description,
  ) async {
    final docRef = firestore.collection('latra_status').doc();

    final status = LATRAStatusModel(
      id: docRef.id,
      applicationId: applicationId,
      userId: userId,
      type: LATRAStatusType.submitted,
      title: title,
      description: description,
      timestamp: DateTime.now(),
    );

    await docRef.set(status.toFirestore());
  }
}
