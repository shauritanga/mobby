import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/application.dart';
import '../../domain/entities/commission.dart';
import '../../domain/entities/insurance_partner.dart';
import '../models/application_model.dart';
import '../models/commission_model.dart';
import '../models/insurance_partner_model.dart';

/// Admin insurance remote data source interface
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin Insurance Management Feature
abstract class AdminInsuranceRemoteDataSource {
  // Partner Management
  Future<List<InsurancePartnerModel>> getAllPartners({
    PartnerType? type,
    PartnerStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  Future<InsurancePartnerModel?> getPartnerById(String partnerId);
  Future<InsurancePartnerModel> createPartner(InsurancePartnerModel partner);
  Future<InsurancePartnerModel> updatePartner(InsurancePartnerModel partner);
  Future<InsurancePartnerModel> updatePartnerStatus(
    String partnerId,
    PartnerStatus status,
    String adminId,
    String? reason,
  );
  Future<void> deletePartner(String partnerId);
  Future<List<InsurancePartnerModel>> searchPartners(
    String query, {
    PartnerType? type,
    PartnerStatus? status,
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getPartnersAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Application Processing
  Future<List<InsuranceApplicationModel>> getAllApplications({
    ApplicationType? type,
    ApplicationStatus? status,
    ApplicationPriority? priority,
    String? partnerId,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  Future<InsuranceApplicationModel?> getApplicationById(String applicationId);
  Future<InsuranceApplicationModel> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
    String adminId,
    String? reason,
  );
  Future<InsuranceApplicationModel> assignApplication(
    String applicationId,
    String assignedTo,
    String assignedBy,
  );
  Future<InsuranceApplicationModel> updateApplicationPriority(
    String applicationId,
    ApplicationPriority priority,
    String adminId,
  );
  Future<void> addApplicationNote(
    String applicationId,
    String content,
    String addedBy,
    bool isInternal,
  );
  Future<List<InsuranceApplicationModel>> getApplicationsByAssignee(
    String assigneeId,
  );
  Future<List<InsuranceApplicationModel>> searchApplications(
    String query, {
    ApplicationType? type,
    ApplicationStatus? status,
    ApplicationPriority? priority,
    String? partnerId,
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getApplicationsAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? partnerId,
  });

  // Commission Tracking
  Future<List<CommissionModel>> getAllCommissions({
    CommissionType? type,
    CommissionStatus? status,
    CommissionTier? tier,
    String? partnerId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  Future<CommissionModel?> getCommissionById(String commissionId);
  Future<CommissionModel> updateCommissionStatus(
    String commissionId,
    CommissionStatus status,
    String adminId,
    String? notes,
  );
  Future<CommissionModel> processCommissionPayment(
    String commissionId,
    String paymentReference,
    String paymentMethod,
    String processedBy,
  );
  Future<CommissionModel> addCommissionAdjustment(
    String commissionId,
    String reason,
    double amount,
    AdjustmentType type,
    String adjustedBy,
    String? notes,
  );
  Future<List<CommissionModel>> getCommissionsByPartner(
    String partnerId, {
    CommissionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<List<CommissionModel>> searchCommissions(
    String query, {
    CommissionType? type,
    CommissionStatus? status,
    String? partnerId,
    int page = 1,
    int limit = 20,
  });
  Future<Map<String, dynamic>> getCommissionsAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? partnerId,
  });

  // Bulk Operations
  Future<void> bulkUpdateApplicationStatus(
    List<String> applicationIds,
    ApplicationStatus status,
    String adminId,
    String? reason,
  );
  Future<void> bulkAssignApplications(
    List<String> applicationIds,
    String assignedTo,
    String assignedBy,
  );
  Future<void> bulkUpdateCommissionStatus(
    List<String> commissionIds,
    CommissionStatus status,
    String adminId,
    String? notes,
  );
  Future<void> bulkProcessCommissionPayments(
    List<String> commissionIds,
    String paymentMethod,
    String processedBy,
  );

  // Reports and Analytics
  Future<Map<String, dynamic>> generatePartnerReport({
    DateTime? startDate,
    DateTime? endDate,
    PartnerType? type,
    PartnerStatus? status,
  });
  Future<Map<String, dynamic>> generateApplicationReport({
    DateTime? startDate,
    DateTime? endDate,
    ApplicationType? type,
    ApplicationStatus? status,
    String? partnerId,
  });
  Future<Map<String, dynamic>> generateCommissionReport({
    DateTime? startDate,
    DateTime? endDate,
    CommissionType? type,
    CommissionStatus? status,
    String? partnerId,
  });
  Future<Map<String, dynamic>> getAdminDashboardData();
}

/// Admin insurance remote data source implementation
class AdminInsuranceRemoteDataSourceImpl
    implements AdminInsuranceRemoteDataSource {
  final FirebaseFirestore _firestore;

  AdminInsuranceRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<InsurancePartnerModel>> getAllPartners({
    PartnerType? type,
    PartnerStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🔍 Fetching insurance partners (page: $page, limit: $limit)');

      Query query = _firestore.collection('insurancePartners');

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        // For search, we'll use a simple name-based search
        // In production, consider using Algolia or similar for better search
        query = query
            .where('name', isGreaterThanOrEqualTo: searchQuery)
            .where('name', isLessThan: '${searchQuery}z');
      }

      query = query.orderBy('createdAt', descending: true).limit(limit);

      if (page > 1) {
        // For pagination, we'd need to implement proper cursor-based pagination
        // This is a simplified version
        query = query.startAfter([(page - 1) * limit]);
      }

      final querySnapshot = await query.get();

      final partners = querySnapshot.docs
          .map(
            (doc) => InsurancePartnerModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      print('✅ Found ${partners.length} insurance partners');
      return partners;
    } catch (e) {
      print('❌ Error fetching insurance partners: $e');
      throw Exception('Failed to fetch insurance partners: $e');
    }
  }

  @override
  Future<InsurancePartnerModel?> getPartnerById(String partnerId) async {
    try {
      print('🔍 Fetching partner by ID: $partnerId');

      final doc = await _firestore
          .collection('insurancePartners')
          .doc(partnerId)
          .get();

      if (!doc.exists) {
        print('❌ Partner not found: $partnerId');
        return null;
      }

      final partner = InsurancePartnerModel.fromFirestore(doc.data()!, doc.id);

      print('✅ Found partner: ${partner.name}');
      return partner;
    } catch (e) {
      print('❌ Error fetching partner: $e');
      throw Exception('Failed to fetch partner: $e');
    }
  }

  @override
  Future<InsurancePartnerModel> createPartner(
    InsurancePartnerModel partner,
  ) async {
    try {
      print('🔄 Creating new partner: ${partner.name}');

      final docRef = _firestore.collection('insurancePartners').doc();
      final now = DateTime.now();

      final newPartner = InsurancePartnerModel.fromEntity(
        partner.copyWith(id: docRef.id, createdAt: now, updatedAt: now),
      );

      await docRef.set(newPartner.toFirestore());

      print('✅ Partner created successfully: ${newPartner.id}');
      return newPartner;
    } catch (e) {
      print('❌ Error creating partner: $e');
      throw Exception('Failed to create partner: $e');
    }
  }

  @override
  Future<InsurancePartnerModel> updatePartner(
    InsurancePartnerModel partner,
  ) async {
    try {
      print('🔄 Updating partner: ${partner.id}');

      final updatedPartner = InsurancePartnerModel.fromEntity(
        partner.copyWith(updatedAt: DateTime.now()),
      );

      await _firestore
          .collection('insurancePartners')
          .doc(partner.id)
          .update(updatedPartner.toFirestore());

      print('✅ Partner updated successfully: ${partner.id}');
      return updatedPartner;
    } catch (e) {
      print('❌ Error updating partner: $e');
      throw Exception('Failed to update partner: $e');
    }
  }

  @override
  Future<InsurancePartnerModel> updatePartnerStatus(
    String partnerId,
    PartnerStatus status,
    String adminId,
    String? reason,
  ) async {
    try {
      print('🔄 Updating partner status: $partnerId to ${status.name}');

      final partnerDoc = await _firestore
          .collection('insurancePartners')
          .doc(partnerId)
          .get();

      if (!partnerDoc.exists) {
        throw Exception('Partner not found: $partnerId');
      }

      final partner = InsurancePartnerModel.fromFirestore(
        partnerDoc.data()!,
        partnerDoc.id,
      );

      final updatedPartner = InsurancePartnerModel.fromEntity(
        partner.copyWith(status: status, updatedAt: DateTime.now()),
      );

      await _firestore
          .collection('insurancePartners')
          .doc(partnerId)
          .update(updatedPartner.toFirestore());

      // Log the status change
      await _firestore.collection('partnerStatusHistory').add({
        'partnerId': partnerId,
        'fromStatus': partner.status.name,
        'toStatus': status.name,
        'changedBy': adminId,
        'reason': reason,
        'changedAt': DateTime.now().toIso8601String(),
      });

      print('✅ Partner status updated successfully: $partnerId');
      return updatedPartner;
    } catch (e) {
      print('❌ Error updating partner status: $e');
      throw Exception('Failed to update partner status: $e');
    }
  }

  @override
  Future<void> deletePartner(String partnerId) async {
    try {
      print('🔄 Deleting partner: $partnerId');

      await _firestore.collection('insurancePartners').doc(partnerId).delete();

      print('✅ Partner deleted successfully: $partnerId');
    } catch (e) {
      print('❌ Error deleting partner: $e');
      throw Exception('Failed to delete partner: $e');
    }
  }

  @override
  Future<List<InsurancePartnerModel>> searchPartners(
    String query, {
    PartnerType? type,
    PartnerStatus? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🔍 Searching partners with query: $query');

      Query firestoreQuery = _firestore.collection('insurancePartners');

      if (type != null) {
        firestoreQuery = firestoreQuery.where('type', isEqualTo: type.name);
      }

      if (status != null) {
        firestoreQuery = firestoreQuery.where('status', isEqualTo: status.name);
      }

      // Simple text search - in production, use a proper search service
      firestoreQuery = firestoreQuery
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThan: '${query}z')
          .limit(limit);

      final querySnapshot = await firestoreQuery.get();

      final partners = querySnapshot.docs
          .map(
            (doc) => InsurancePartnerModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      print('✅ Found ${partners.length} partners matching query');
      return partners;
    } catch (e) {
      print('❌ Error searching partners: $e');
      throw Exception('Failed to search partners: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPartnersAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print('🔍 Fetching partners analytics');

      Query query = _firestore.collection('insurancePartners');

      if (startDate != null) {
        query = query.where('createdAt', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('createdAt', isLessThanOrEqualTo: endDate);
      }

      final querySnapshot = await query.get();
      final partners = querySnapshot.docs
          .map(
            (doc) => InsurancePartnerModel.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList();

      // Calculate analytics
      final totalPartners = partners.length;
      final activePartners = partners
          .where((p) => p.status == PartnerStatus.active)
          .length;
      final pendingPartners = partners
          .where((p) => p.status == PartnerStatus.pending)
          .length;
      final suspendedPartners = partners
          .where((p) => p.status == PartnerStatus.suspended)
          .length;
      final verifiedPartners = partners.where((p) => p.isVerified).length;
      final featuredPartners = partners.where((p) => p.isFeatured).length;

      final totalRevenue = partners.fold<double>(
        0.0,
        (sum, p) => sum + p.financials.totalRevenue,
      );
      final totalCommissions = partners.fold<double>(
        0.0,
        (sum, p) => sum + p.financials.totalCommissions,
      );
      final outstandingCommissions = partners.fold<double>(
        0.0,
        (sum, p) => sum + p.financials.outstandingCommissions,
      );

      final analytics = {
        'totalPartners': totalPartners,
        'activePartners': activePartners,
        'pendingPartners': pendingPartners,
        'suspendedPartners': suspendedPartners,
        'verifiedPartners': verifiedPartners,
        'featuredPartners': featuredPartners,
        'totalRevenue': totalRevenue,
        'totalCommissions': totalCommissions,
        'outstandingCommissions': outstandingCommissions,
        'averageRating': partners.isNotEmpty
            ? partners.fold<double>(
                    0.0,
                    (sum, p) => sum + p.rating.overallRating,
                  ) /
                  partners.length
            : 0.0,
        'generatedAt': DateTime.now().toIso8601String(),
      };

      print('✅ Partners analytics generated successfully');
      return analytics;
    } catch (e) {
      print('❌ Error fetching partners analytics: $e');
      throw Exception('Failed to fetch partners analytics: $e');
    }
  }

  // Application Processing Methods - Placeholder implementations
  @override
  Future<List<InsuranceApplicationModel>> getAllApplications({
    ApplicationType? type,
    ApplicationStatus? status,
    ApplicationPriority? priority,
    String? partnerId,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    // TODO: Implement application fetching
    return [];
  }

  @override
  Future<InsuranceApplicationModel?> getApplicationById(
    String applicationId,
  ) async {
    // TODO: Implement application fetching by ID
    return null;
  }

  @override
  Future<InsuranceApplicationModel> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
    String adminId,
    String? reason,
  ) async {
    // TODO: Implement application status update
    throw UnimplementedError();
  }

  @override
  Future<InsuranceApplicationModel> assignApplication(
    String applicationId,
    String assignedTo,
    String assignedBy,
  ) async {
    // TODO: Implement application assignment
    throw UnimplementedError();
  }

  @override
  Future<InsuranceApplicationModel> updateApplicationPriority(
    String applicationId,
    ApplicationPriority priority,
    String adminId,
  ) async {
    // TODO: Implement application priority update
    throw UnimplementedError();
  }

  @override
  Future<void> addApplicationNote(
    String applicationId,
    String content,
    String addedBy,
    bool isInternal,
  ) async {
    // TODO: Implement application note addition
  }

  @override
  Future<List<InsuranceApplicationModel>> getApplicationsByAssignee(
    String assigneeId,
  ) async {
    // TODO: Implement applications by assignee
    return [];
  }

  @override
  Future<List<InsuranceApplicationModel>> searchApplications(
    String query, {
    ApplicationType? type,
    ApplicationStatus? status,
    ApplicationPriority? priority,
    String? partnerId,
    int page = 1,
    int limit = 20,
  }) async {
    // TODO: Implement application search
    return [];
  }

  @override
  Future<Map<String, dynamic>> getApplicationsAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? partnerId,
  }) async {
    // TODO: Implement applications analytics
    return {};
  }

  // Commission Tracking Methods - Placeholder implementations
  @override
  Future<List<CommissionModel>> getAllCommissions({
    CommissionType? type,
    CommissionStatus? status,
    CommissionTier? tier,
    String? partnerId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    // TODO: Implement commission fetching
    return [];
  }

  @override
  Future<CommissionModel?> getCommissionById(String commissionId) async {
    // TODO: Implement commission fetching by ID
    return null;
  }

  @override
  Future<CommissionModel> updateCommissionStatus(
    String commissionId,
    CommissionStatus status,
    String adminId,
    String? notes,
  ) async {
    // TODO: Implement commission status update
    throw UnimplementedError();
  }

  @override
  Future<CommissionModel> processCommissionPayment(
    String commissionId,
    String paymentReference,
    String paymentMethod,
    String processedBy,
  ) async {
    // TODO: Implement commission payment processing
    throw UnimplementedError();
  }

  @override
  Future<CommissionModel> addCommissionAdjustment(
    String commissionId,
    String reason,
    double amount,
    AdjustmentType type,
    String adjustedBy,
    String? notes,
  ) async {
    // TODO: Implement commission adjustment
    throw UnimplementedError();
  }

  @override
  Future<List<CommissionModel>> getCommissionsByPartner(
    String partnerId, {
    CommissionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // TODO: Implement commissions by partner
    return [];
  }

  @override
  Future<List<CommissionModel>> searchCommissions(
    String query, {
    CommissionType? type,
    CommissionStatus? status,
    String? partnerId,
    int page = 1,
    int limit = 20,
  }) async {
    // TODO: Implement commission search
    return [];
  }

  @override
  Future<Map<String, dynamic>> getCommissionsAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? partnerId,
  }) async {
    // TODO: Implement commissions analytics
    return {};
  }

  // Bulk Operations - Placeholder implementations
  @override
  Future<void> bulkUpdateApplicationStatus(
    List<String> applicationIds,
    ApplicationStatus status,
    String adminId,
    String? reason,
  ) async {
    // TODO: Implement bulk application status update
  }

  @override
  Future<void> bulkAssignApplications(
    List<String> applicationIds,
    String assignedTo,
    String assignedBy,
  ) async {
    // TODO: Implement bulk application assignment
  }

  @override
  Future<void> bulkUpdateCommissionStatus(
    List<String> commissionIds,
    CommissionStatus status,
    String adminId,
    String? notes,
  ) async {
    // TODO: Implement bulk commission status update
  }

  @override
  Future<void> bulkProcessCommissionPayments(
    List<String> commissionIds,
    String paymentMethod,
    String processedBy,
  ) async {
    // TODO: Implement bulk commission payment processing
  }

  // Reports and Analytics - Placeholder implementations
  @override
  Future<Map<String, dynamic>> generatePartnerReport({
    DateTime? startDate,
    DateTime? endDate,
    PartnerType? type,
    PartnerStatus? status,
  }) async {
    // TODO: Implement partner report generation
    return {};
  }

  @override
  Future<Map<String, dynamic>> generateApplicationReport({
    DateTime? startDate,
    DateTime? endDate,
    ApplicationType? type,
    ApplicationStatus? status,
    String? partnerId,
  }) async {
    // TODO: Implement application report generation
    return {};
  }

  @override
  Future<Map<String, dynamic>> generateCommissionReport({
    DateTime? startDate,
    DateTime? endDate,
    CommissionType? type,
    CommissionStatus? status,
    String? partnerId,
  }) async {
    // TODO: Implement commission report generation
    return {};
  }

  @override
  Future<Map<String, dynamic>> getAdminDashboardData() async {
    // TODO: Implement admin dashboard data
    return {};
  }
}
