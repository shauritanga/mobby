import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../latra/data/models/latra_application_model.dart';
import '../../../latra/data/models/latra_document_model.dart';
import '../../../latra/domain/entities/latra_application.dart';
import '../../../latra/domain/entities/latra_document.dart';
import '../models/verification_status_model.dart';

/// Admin LATRA remote data source interface
abstract class AdminLATRARemoteDataSource {
  // Application Queue Management
  Future<List<LATRAApplicationModel>> getAllApplications({
    LATRAApplicationStatus? status,
    LATRAApplicationType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  Future<LATRAApplicationModel?> getApplicationById(String applicationId);

  Future<LATRAApplicationModel> updateApplicationStatus(
    String applicationId,
    LATRAApplicationStatus status,
    String adminId,
    String? notes,
  );

  Future<LATRAApplicationModel> assignApplication(
    String applicationId,
    String assignedTo,
    String assignedBy,
  );

  Future<void> addApplicationNotes(
    String applicationId,
    String notes,
    String adminId,
  );

  Future<Map<String, dynamic>> getApplicationsAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Document Verification Management
  Future<List<LATRADocumentModel>> getAllDocuments({
    LATRADocumentStatus? status,
    LATRADocumentType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  Future<LATRADocumentModel?> getDocumentById(String documentId);

  Future<VerificationStatusModel> verifyDocument(
    String documentId,
    String result,
    String verifiedBy,
    String verifierName,
    String? notes,
    List<String> issues,
  );

  Future<List<VerificationStatusModel>> getDocumentVerifications(
    String documentId,
  );

  Future<List<VerificationStatusModel>> getVerificationHistory({
    String? verifiedBy,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });

  Future<Map<String, dynamic>> getVerificationAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Integration Status Monitoring
  Future<List<IntegrationStatusModel>> getIntegrationStatuses();
  Future<IntegrationStatusModel?> getIntegrationStatus(String serviceName);
  Future<IntegrationStatusModel> updateIntegrationStatus(
    String serviceName,
    String health,
    int responseTime,
    String? errorMessage,
    Map<String, dynamic> metrics,
  );

  Future<List<IntegrationEventModel>> getIntegrationEvents({
    String? serviceName,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  });

  Future<void> addIntegrationEvent(
    String serviceName,
    String type,
    String message,
    Map<String, dynamic> data,
  );

  Future<Map<String, dynamic>> getIntegrationAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Admin Operations
  Future<List<LATRAApplicationModel>> getApplicationsByAssignee(
    String assigneeId,
  );
  Future<List<VerificationStatusModel>> getVerificationsByVerifier(
    String verifierId,
  );
  Future<Map<String, dynamic>> getAdminDashboardData();

  // Bulk Operations
  Future<void> bulkUpdateApplicationStatus(
    List<String> applicationIds,
    LATRAApplicationStatus status,
    String adminId,
    String? notes,
  );

  Future<void> bulkAssignApplications(
    List<String> applicationIds,
    String assignedTo,
    String assignedBy,
  );

  // Search and Filtering
  Future<List<LATRAApplicationModel>> searchApplications(
    String query, {
    LATRAApplicationStatus? status,
    LATRAApplicationType? type,
    int page = 1,
    int limit = 20,
  });

  Future<List<LATRADocumentModel>> searchDocuments(
    String query, {
    LATRADocumentStatus? status,
    LATRADocumentType? type,
    int page = 1,
    int limit = 20,
  });
}

/// Firebase implementation of admin LATRA remote data source
class AdminLATRARemoteDataSourceImpl implements AdminLATRARemoteDataSource {
  final FirebaseFirestore firestore;

  const AdminLATRARemoteDataSourceImpl({required this.firestore});

  @override
  Future<List<LATRAApplicationModel>> getAllApplications({
    LATRAApplicationStatus? status,
    LATRAApplicationType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    Query query = firestore.collection('latra_applications');

    // Apply filters
    if (status != null) {
      query = query.where('status', isEqualTo: status.name);
    }

    if (type != null) {
      query = query.where('type', isEqualTo: type.name);
    }

    if (startDate != null) {
      query = query.where(
        'createdAt',
        isGreaterThanOrEqualTo: startDate.toIso8601String(),
      );
    }

    if (endDate != null) {
      query = query.where(
        'createdAt',
        isLessThanOrEqualTo: endDate.toIso8601String(),
      );
    }

    // Apply pagination
    query = query.orderBy('createdAt', descending: true);
    query = query.limit(limit);

    if (page > 1) {
      final offset = (page - 1) * limit;
      final offsetQuery = firestore
          .collection('latra_applications')
          .orderBy('createdAt', descending: true)
          .limit(offset);
      final offsetSnapshot = await offsetQuery.get();
      if (offsetSnapshot.docs.isNotEmpty) {
        query = query.startAfterDocument(offsetSnapshot.docs.last);
      }
    }

    final querySnapshot = await query.get();

    return querySnapshot.docs
        .map(
          (doc) => LATRAApplicationModel.fromFirestore(
            doc.data() as Map<String, dynamic>,
            doc.id,
          ),
        )
        .toList();
  }

  @override
  Future<LATRAApplicationModel?> getApplicationById(
    String applicationId,
  ) async {
    final doc = await firestore
        .collection('latra_applications')
        .doc(applicationId)
        .get();

    if (!doc.exists) return null;

    return LATRAApplicationModel.fromFirestore(doc.data()!, doc.id);
  }

  @override
  Future<LATRAApplicationModel> updateApplicationStatus(
    String applicationId,
    LATRAApplicationStatus status,
    String adminId,
    String? notes,
  ) async {
    final updateData = {
      'status': status.name,
      'updatedAt': FieldValue.serverTimestamp(),
      'updatedBy': adminId,
    };

    if (notes != null) {
      updateData['adminNotes'] = notes;
    }

    await firestore
        .collection('latra_applications')
        .doc(applicationId)
        .update(updateData);

    // Add status history entry
    await firestore
        .collection('latra_applications')
        .doc(applicationId)
        .collection('status_history')
        .add({
          'status': status.name,
          'changedBy': adminId,
          'notes': notes,
          'timestamp': FieldValue.serverTimestamp(),
        });

    final updatedDoc = await firestore
        .collection('latra_applications')
        .doc(applicationId)
        .get();
    return LATRAApplicationModel.fromFirestore(
      updatedDoc.data()!,
      updatedDoc.id,
    );
  }

  @override
  Future<LATRAApplicationModel> assignApplication(
    String applicationId,
    String assignedTo,
    String assignedBy,
  ) async {
    await firestore.collection('latra_applications').doc(applicationId).update({
      'assignedTo': assignedTo,
      'assignedBy': assignedBy,
      'assignedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    final updatedDoc = await firestore
        .collection('latra_applications')
        .doc(applicationId)
        .get();
    return LATRAApplicationModel.fromFirestore(
      updatedDoc.data()!,
      updatedDoc.id,
    );
  }

  @override
  Future<void> addApplicationNotes(
    String applicationId,
    String notes,
    String adminId,
  ) async {
    await firestore
        .collection('latra_applications')
        .doc(applicationId)
        .collection('notes')
        .add({
          'content': notes,
          'addedBy': adminId,
          'timestamp': FieldValue.serverTimestamp(),
        });

    await firestore.collection('latra_applications').doc(applicationId).update({
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Map<String, dynamic>> getApplicationsAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // This is a simplified implementation
    // In a real app, you might use Cloud Functions or aggregation queries

    Query query = firestore.collection('latra_applications');

    if (startDate != null) {
      query = query.where(
        'createdAt',
        isGreaterThanOrEqualTo: startDate.toIso8601String(),
      );
    }

    if (endDate != null) {
      query = query.where(
        'createdAt',
        isLessThanOrEqualTo: endDate.toIso8601String(),
      );
    }

    final snapshot = await query.get();

    final analytics = <String, dynamic>{
      'totalApplications': snapshot.docs.length,
      'pendingApplications': 0,
      'approvedApplications': 0,
      'rejectedApplications': 0,
      'processingApplications': 0,
    };

    for (final doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final status = data['status'] as String?;

      switch (status) {
        case 'pending':
        case 'submitted':
          analytics['pendingApplications']++;
          break;
        case 'approved':
        case 'completed':
          analytics['approvedApplications']++;
          break;
        case 'rejected':
        case 'cancelled':
          analytics['rejectedApplications']++;
          break;
        case 'processing':
        case 'underReview':
          analytics['processingApplications']++;
          break;
      }
    }

    return analytics;
  }

  // Stub implementations for remaining methods
  @override
  Future<List<LATRADocumentModel>> getAllDocuments({
    LATRADocumentStatus? status,
    LATRADocumentType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    // Implementation would be similar to getAllApplications
    return [];
  }

  @override
  Future<LATRADocumentModel?> getDocumentById(String documentId) async {
    // Implementation would fetch document by ID
    return null;
  }

  @override
  Future<VerificationStatusModel> verifyDocument(
    String documentId,
    String result,
    String verifiedBy,
    String verifierName,
    String? notes,
    List<String> issues,
  ) async {
    final verificationData = {
      'documentId': documentId,
      'result': result,
      'verifiedBy': verifiedBy,
      'verifierName': verifierName,
      'notes': notes,
      'issues': issues,
      'verificationDate': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final docRef = await firestore
        .collection('document_verifications')
        .add(verificationData);
    final doc = await docRef.get();

    return VerificationStatusModel.fromFirestore(doc.data()!, doc.id);
  }

  @override
  Future<List<VerificationStatusModel>> getDocumentVerifications(
    String documentId,
  ) async {
    final snapshot = await firestore
        .collection('document_verifications')
        .where('documentId', isEqualTo: documentId)
        .orderBy('verificationDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => VerificationStatusModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<VerificationStatusModel>> getVerificationHistory({
    String? verifiedBy,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    // Implementation would be similar to getAllApplications
    return [];
  }

  @override
  Future<Map<String, dynamic>> getVerificationAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Implementation would calculate verification metrics
    return {
      'totalVerifications': 0,
      'approvedVerifications': 0,
      'rejectedVerifications': 0,
      'pendingVerifications': 0,
    };
  }

  @override
  Future<List<IntegrationStatusModel>> getIntegrationStatuses() async {
    final snapshot = await firestore.collection('integration_statuses').get();

    return snapshot.docs
        .map((doc) => IntegrationStatusModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<IntegrationStatusModel?> getIntegrationStatus(
    String serviceName,
  ) async {
    final snapshot = await firestore
        .collection('integration_statuses')
        .where('serviceName', isEqualTo: serviceName)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return IntegrationStatusModel.fromFirestore(
      snapshot.docs.first.data(),
      snapshot.docs.first.id,
    );
  }

  @override
  Future<IntegrationStatusModel> updateIntegrationStatus(
    String serviceName,
    String health,
    int responseTime,
    String? errorMessage,
    Map<String, dynamic> metrics,
  ) async {
    final statusData = {
      'serviceName': serviceName,
      'health': health,
      'lastCheck': FieldValue.serverTimestamp(),
      'responseTime': responseTime,
      'errorMessage': errorMessage,
      'metrics': metrics,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    // Try to update existing status or create new one
    final existingSnapshot = await firestore
        .collection('integration_statuses')
        .where('serviceName', isEqualTo: serviceName)
        .limit(1)
        .get();

    DocumentReference docRef;
    if (existingSnapshot.docs.isNotEmpty) {
      docRef = existingSnapshot.docs.first.reference;
      await docRef.update(statusData);
    } else {
      statusData['createdAt'] = FieldValue.serverTimestamp();
      docRef = await firestore
          .collection('integration_statuses')
          .add(statusData);
    }

    final doc = await docRef.get();
    return IntegrationStatusModel.fromFirestore(
      doc.data()! as Map<String, dynamic>,
      doc.id,
    );
  }

  @override
  Future<List<IntegrationEventModel>> getIntegrationEvents({
    String? serviceName,
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    // Implementation would be similar to getAllApplications
    return [];
  }

  @override
  Future<void> addIntegrationEvent(
    String serviceName,
    String type,
    String message,
    Map<String, dynamic> data,
  ) async {
    await firestore.collection('integration_events').add({
      'serviceName': serviceName,
      'type': type,
      'message': message,
      'data': data,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<Map<String, dynamic>> getIntegrationAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Implementation would calculate integration metrics
    return {
      'totalServices': 0,
      'healthyServices': 0,
      'warningServices': 0,
      'downServices': 0,
      'averageResponseTime': 0,
    };
  }

  @override
  Future<List<LATRAApplicationModel>> getApplicationsByAssignee(
    String assigneeId,
  ) async {
    final snapshot = await firestore
        .collection('latra_applications')
        .where('assignedTo', isEqualTo: assigneeId)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => LATRAApplicationModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<List<VerificationStatusModel>> getVerificationsByVerifier(
    String verifierId,
  ) async {
    final snapshot = await firestore
        .collection('document_verifications')
        .where('verifiedBy', isEqualTo: verifierId)
        .orderBy('verificationDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => VerificationStatusModel.fromFirestore(doc.data(), doc.id))
        .toList();
  }

  @override
  Future<Map<String, dynamic>> getAdminDashboardData() async {
    // Implementation would aggregate data for admin dashboard
    return {
      'totalApplications': 0,
      'pendingApplications': 0,
      'totalDocuments': 0,
      'pendingVerifications': 0,
      'integrationHealth': 'healthy',
    };
  }

  @override
  Future<void> bulkUpdateApplicationStatus(
    List<String> applicationIds,
    LATRAApplicationStatus status,
    String adminId,
    String? notes,
  ) async {
    final batch = firestore.batch();

    for (final applicationId in applicationIds) {
      final docRef = firestore
          .collection('latra_applications')
          .doc(applicationId);
      batch.update(docRef, {
        'status': status.name,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': adminId,
        if (notes != null) 'adminNotes': notes,
      });
    }

    await batch.commit();
  }

  @override
  Future<void> bulkAssignApplications(
    List<String> applicationIds,
    String assignedTo,
    String assignedBy,
  ) async {
    final batch = firestore.batch();

    for (final applicationId in applicationIds) {
      final docRef = firestore
          .collection('latra_applications')
          .doc(applicationId);
      batch.update(docRef, {
        'assignedTo': assignedTo,
        'assignedBy': assignedBy,
        'assignedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  @override
  Future<List<LATRAApplicationModel>> searchApplications(
    String query, {
    LATRAApplicationStatus? status,
    LATRAApplicationType? type,
    int page = 1,
    int limit = 20,
  }) async {
    // Implementation would use Firestore text search or Algolia
    // For now, return empty list
    return [];
  }

  @override
  Future<List<LATRADocumentModel>> searchDocuments(
    String query, {
    LATRADocumentStatus? status,
    LATRADocumentType? type,
    int page = 1,
    int limit = 20,
  }) async {
    // Implementation would use Firestore text search or Algolia
    // For now, return empty list
    return [];
  }
}
