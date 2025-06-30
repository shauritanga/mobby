import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../latra/domain/entities/latra_application.dart';
import '../../../latra/domain/entities/latra_document.dart';
import '../entities/verification_status.dart';

/// Admin LATRA repository interface
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin LATRA Management Feature
abstract class AdminLATRARepository {
  // Application Queue Management
  Future<Either<Failure, List<LATRAApplication>>> getAllApplications({
    LATRAApplicationStatus? status,
    LATRAApplicationType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, LATRAApplication?>> getApplicationById(String applicationId);
  
  Future<Either<Failure, LATRAApplication>> updateApplicationStatus(
    String applicationId,
    LATRAApplicationStatus status,
    String adminId,
    String? notes,
  );

  Future<Either<Failure, LATRAApplication>> assignApplication(
    String applicationId,
    String assignedTo,
    String assignedBy,
  );

  Future<Either<Failure, void>> addApplicationNotes(
    String applicationId,
    String notes,
    String adminId,
  );

  Future<Either<Failure, Map<String, dynamic>>> getApplicationsAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Document Verification Management
  Future<Either<Failure, List<LATRADocument>>> getAllDocuments({
    LATRADocumentStatus? status,
    LATRADocumentType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, LATRADocument?>> getDocumentById(String documentId);

  Future<Either<Failure, VerificationStatus>> verifyDocument(
    String documentId,
    VerificationResult result,
    String verifiedBy,
    String? notes,
    List<String> issues,
  );

  Future<Either<Failure, List<VerificationStatus>>> getDocumentVerifications(
    String documentId,
  );

  Future<Either<Failure, List<VerificationStatus>>> getVerificationHistory({
    String? verifiedBy,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, Map<String, dynamic>>> getVerificationAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Integration Status Monitoring
  Future<Either<Failure, List<IntegrationStatus>>> getIntegrationStatuses();

  Future<Either<Failure, IntegrationStatus?>> getIntegrationStatus(String serviceName);

  Future<Either<Failure, IntegrationStatus>> updateIntegrationStatus(
    String serviceName,
    IntegrationHealth health,
    int responseTime,
    String? errorMessage,
    Map<String, dynamic> metrics,
  );

  Future<Either<Failure, List<IntegrationEvent>>> getIntegrationEvents({
    String? serviceName,
    IntegrationEventType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  });

  Future<Either<Failure, void>> addIntegrationEvent(
    String serviceName,
    IntegrationEventType type,
    String message,
    Map<String, dynamic> data,
  );

  Future<Either<Failure, Map<String, dynamic>>> getIntegrationAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  });

  // Admin Operations
  Future<Either<Failure, List<LATRAApplication>>> getApplicationsByAssignee(
    String assigneeId,
  );

  Future<Either<Failure, List<VerificationStatus>>> getVerificationsByVerifier(
    String verifierId,
  );

  Future<Either<Failure, Map<String, dynamic>>> getAdminDashboardData();

  // Bulk Operations
  Future<Either<Failure, void>> bulkUpdateApplicationStatus(
    List<String> applicationIds,
    LATRAApplicationStatus status,
    String adminId,
    String? notes,
  );

  Future<Either<Failure, void>> bulkAssignApplications(
    List<String> applicationIds,
    String assignedTo,
    String assignedBy,
  );

  // Search and Filtering
  Future<Either<Failure, List<LATRAApplication>>> searchApplications(
    String query,
    {
    LATRAApplicationStatus? status,
    LATRAApplicationType? type,
    int page = 1,
    int limit = 20,
  });

  Future<Either<Failure, List<LATRADocument>>> searchDocuments(
    String query,
    {
    LATRADocumentStatus? status,
    LATRADocumentType? type,
    int page = 1,
    int limit = 20,
  });

  // Reports and Export
  Future<Either<Failure, Map<String, dynamic>>> generateApplicationsReport({
    DateTime? startDate,
    DateTime? endDate,
    LATRAApplicationStatus? status,
    LATRAApplicationType? type,
  });

  Future<Either<Failure, Map<String, dynamic>>> generateVerificationReport({
    DateTime? startDate,
    DateTime? endDate,
    String? verifiedBy,
  });

  Future<Either<Failure, Map<String, dynamic>>> generateIntegrationReport({
    DateTime? startDate,
    DateTime? endDate,
    String? serviceName,
  });
}
