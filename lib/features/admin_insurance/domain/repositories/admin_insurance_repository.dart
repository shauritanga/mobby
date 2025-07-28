import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/application.dart';
import '../entities/commission.dart';
import '../entities/insurance_partner.dart';

/// Admin insurance repository interface
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin Insurance Management Feature
abstract class AdminInsuranceRepository {
  // Partner Management
  Future<Either<Failure, List<InsurancePartner>>> getAllPartners({
    PartnerType? type,
    PartnerStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, InsurancePartner?>> getPartnerById(String partnerId);

  Future<Either<Failure, InsurancePartner>> createPartner(
    InsurancePartner partner,
  );

  Future<Either<Failure, InsurancePartner>> updatePartner(
    InsurancePartner partner,
  );

  Future<Either<Failure, InsurancePartner>> updatePartnerStatus(
    String partnerId,
    PartnerStatus status,
    String adminId,
    String? reason,
  );

  Future<Either<Failure, void>> deletePartner(String partnerId);

  Future<Either<Failure, List<InsurancePartner>>> searchPartners(
    String query, {
    PartnerType? type,
    PartnerStatus? status,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, Map<String, dynamic>>> getPartnersAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Application Processing
  Future<Either<Failure, List<InsuranceApplication>>> getAllApplications({
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

  Future<Either<Failure, InsuranceApplication?>> getApplicationById(
    String applicationId,
  );

  Future<Either<Failure, InsuranceApplication>> updateApplicationStatus(
    String applicationId,
    ApplicationStatus status,
    String adminId,
    String? reason,
  );

  Future<Either<Failure, InsuranceApplication>> assignApplication(
    String applicationId,
    String assignedTo,
    String assignedBy,
  );

  Future<Either<Failure, InsuranceApplication>> updateApplicationPriority(
    String applicationId,
    ApplicationPriority priority,
    String adminId,
  );

  Future<Either<Failure, void>> addApplicationNote(
    String applicationId,
    String content,
    String addedBy,
    bool isInternal,
  );

  Future<Either<Failure, List<InsuranceApplication>>> getApplicationsByAssignee(
    String assigneeId,
  );

  Future<Either<Failure, List<InsuranceApplication>>> searchApplications(
    String query, {
    ApplicationType? type,
    ApplicationStatus? status,
    ApplicationPriority? priority,
    String? partnerId,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, Map<String, dynamic>>> getApplicationsAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? partnerId,
  });

  // Commission Tracking
  Future<Either<Failure, List<Commission>>> getAllCommissions({
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

  Future<Either<Failure, Commission?>> getCommissionById(String commissionId);

  Future<Either<Failure, Commission>> updateCommissionStatus(
    String commissionId,
    CommissionStatus status,
    String adminId,
    String? notes,
  );

  Future<Either<Failure, Commission>> processCommissionPayment(
    String commissionId,
    String paymentReference,
    String paymentMethod,
    String processedBy,
  );

  Future<Either<Failure, Commission>> addCommissionAdjustment(
    String commissionId,
    String reason,
    double amount,
    AdjustmentType type,
    String adjustedBy,
    String? notes,
  );

  Future<Either<Failure, List<Commission>>> getCommissionsByPartner(
    String partnerId, {
    CommissionStatus? status,
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<Either<Failure, List<Commission>>> searchCommissions(
    String query, {
    CommissionType? type,
    CommissionStatus? status,
    String? partnerId,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, Map<String, dynamic>>> getCommissionsAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? partnerId,
  });

  // Bulk Operations
  Future<Either<Failure, void>> bulkUpdateApplicationStatus(
    List<String> applicationIds,
    ApplicationStatus status,
    String adminId,
    String? reason,
  );

  Future<Either<Failure, void>> bulkAssignApplications(
    List<String> applicationIds,
    String assignedTo,
    String assignedBy,
  );

  Future<Either<Failure, void>> bulkUpdateCommissionStatus(
    List<String> commissionIds,
    CommissionStatus status,
    String adminId,
    String? notes,
  );

  Future<Either<Failure, void>> bulkProcessCommissionPayments(
    List<String> commissionIds,
    String paymentMethod,
    String processedBy,
  );

  // Reports and Analytics
  Future<Either<Failure, Map<String, dynamic>>> generatePartnerReport({
    DateTime? startDate,
    DateTime? endDate,
    PartnerType? type,
    PartnerStatus? status,
  });

  Future<Either<Failure, Map<String, dynamic>>> generateApplicationReport({
    DateTime? startDate,
    DateTime? endDate,
    ApplicationType? type,
    ApplicationStatus? status,
    String? partnerId,
  });

  Future<Either<Failure, Map<String, dynamic>>> generateCommissionReport({
    DateTime? startDate,
    DateTime? endDate,
    CommissionType? type,
    CommissionStatus? status,
    String? partnerId,
  });

  Future<Either<Failure, Map<String, dynamic>>> getAdminDashboardData();

  // Integration with existing insurance features
  Future<Either<Failure, List<InsuranceApplication>>> getApplicationsForPolicy(
    String policyId,
  );

  Future<Either<Failure, List<Commission>>> getCommissionsForPolicy(
    String policyId,
  );
}
