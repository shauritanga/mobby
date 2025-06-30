import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/errors/failures.dart';
import '../../../latra/domain/entities/latra_application.dart';
import '../../../latra/domain/entities/latra_document.dart';
import '../../domain/entities/verification_status.dart';
import '../../domain/repositories/admin_latra_repository.dart';
import '../datasources/admin_latra_remote_datasource.dart';

/// Admin LATRA repository implementation
class AdminLATRARepositoryImpl implements AdminLATRARepository {
  final AdminLATRARemoteDataSource remoteDataSource;
  final Connectivity connectivity;

  const AdminLATRARepositoryImpl({
    required this.remoteDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, List<LATRAApplication>>> getAllApplications({
    LATRAApplicationStatus? status,
    LATRAApplicationType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final applications = await remoteDataSource.getAllApplications(
        status: status,
        type: type,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
        page: page,
        limit: limit,
      );

      return Right(applications.cast<LATRAApplication>());
    } catch (e) {
      return Left(UnknownFailure('Failed to get applications: $e'));
    }
  }

  @override
  Future<Either<Failure, LATRAApplication?>> getApplicationById(
    String applicationId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final application = await remoteDataSource.getApplicationById(
        applicationId,
      );
      return Right(application);
    } catch (e) {
      return Left(UnknownFailure('Failed to get application: $e'));
    }
  }

  @override
  Future<Either<Failure, LATRAApplication>> updateApplicationStatus(
    String applicationId,
    LATRAApplicationStatus status,
    String adminId,
    String? notes,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final updatedApplication = await remoteDataSource.updateApplicationStatus(
        applicationId,
        status,
        adminId,
        notes,
      );

      return Right(updatedApplication);
    } catch (e) {
      return Left(UnknownFailure('Failed to update application status: $e'));
    }
  }

  @override
  Future<Either<Failure, LATRAApplication>> assignApplication(
    String applicationId,
    String assignedTo,
    String assignedBy,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final assignedApplication = await remoteDataSource.assignApplication(
        applicationId,
        assignedTo,
        assignedBy,
      );

      return Right(assignedApplication);
    } catch (e) {
      return Left(UnknownFailure('Failed to assign application: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addApplicationNotes(
    String applicationId,
    String notes,
    String adminId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.addApplicationNotes(applicationId, notes, adminId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to add application notes: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getApplicationsAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final analytics = await remoteDataSource.getApplicationsAnalytics(
        startDate: startDate,
        endDate: endDate,
      );

      return Right(analytics);
    } catch (e) {
      return Left(UnknownFailure('Failed to get applications analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LATRADocument>>> getAllDocuments({
    LATRADocumentStatus? status,
    LATRADocumentType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final documents = await remoteDataSource.getAllDocuments(
        status: status,
        type: type,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
        page: page,
        limit: limit,
      );

      return Right(documents.cast<LATRADocument>());
    } catch (e) {
      return Left(UnknownFailure('Failed to get documents: $e'));
    }
  }

  @override
  Future<Either<Failure, LATRADocument?>> getDocumentById(
    String documentId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final document = await remoteDataSource.getDocumentById(documentId);
      return Right(document);
    } catch (e) {
      return Left(UnknownFailure('Failed to get document: $e'));
    }
  }

  @override
  Future<Either<Failure, VerificationStatus>> verifyDocument(
    String documentId,
    VerificationResult result,
    String verifiedBy,
    String? notes,
    List<String> issues,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Get verifier name (in a real app, this would come from user service)
      const verifierName = 'Admin User'; // Placeholder

      final verification = await remoteDataSource.verifyDocument(
        documentId,
        result.name,
        verifiedBy,
        verifierName,
        notes,
        issues,
      );

      return Right(verification.toEntity());
    } catch (e) {
      return Left(UnknownFailure('Failed to verify document: $e'));
    }
  }

  @override
  Future<Either<Failure, List<VerificationStatus>>> getDocumentVerifications(
    String documentId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final verifications = await remoteDataSource.getDocumentVerifications(
        documentId,
      );
      return Right(verifications.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(UnknownFailure('Failed to get document verifications: $e'));
    }
  }

  @override
  Future<Either<Failure, List<VerificationStatus>>> getVerificationHistory({
    String? verifiedBy,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final verifications = await remoteDataSource.getVerificationHistory(
        verifiedBy: verifiedBy,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );

      return Right(verifications.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(UnknownFailure('Failed to get verification history: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getVerificationAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final analytics = await remoteDataSource.getVerificationAnalytics(
        startDate: startDate,
        endDate: endDate,
      );

      return Right(analytics);
    } catch (e) {
      return Left(UnknownFailure('Failed to get verification analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, List<IntegrationStatus>>>
  getIntegrationStatuses() async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final statuses = await remoteDataSource.getIntegrationStatuses();
      return Right(statuses.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(UnknownFailure('Failed to get integration statuses: $e'));
    }
  }

  @override
  Future<Either<Failure, IntegrationStatus?>> getIntegrationStatus(
    String serviceName,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final status = await remoteDataSource.getIntegrationStatus(serviceName);
      return Right(status?.toEntity());
    } catch (e) {
      return Left(UnknownFailure('Failed to get integration status: $e'));
    }
  }

  @override
  Future<Either<Failure, IntegrationStatus>> updateIntegrationStatus(
    String serviceName,
    IntegrationHealth health,
    int responseTime,
    String? errorMessage,
    Map<String, dynamic> metrics,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final status = await remoteDataSource.updateIntegrationStatus(
        serviceName,
        health.name,
        responseTime,
        errorMessage,
        metrics,
      );

      return Right(status.toEntity());
    } catch (e) {
      return Left(UnknownFailure('Failed to update integration status: $e'));
    }
  }

  @override
  Future<Either<Failure, List<IntegrationEvent>>> getIntegrationEvents({
    String? serviceName,
    IntegrationEventType? type,
    DateTime? startDate,
    DateTime? endDate,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final events = await remoteDataSource.getIntegrationEvents(
        serviceName: serviceName,
        type: type?.name,
        startDate: startDate,
        endDate: endDate,
        page: page,
        limit: limit,
      );

      return Right(events.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(UnknownFailure('Failed to get integration events: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> addIntegrationEvent(
    String serviceName,
    IntegrationEventType type,
    String message,
    Map<String, dynamic> data,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.addIntegrationEvent(
        serviceName,
        type.name,
        message,
        data,
      );

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to add integration event: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getIntegrationAnalytics({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final analytics = await remoteDataSource.getIntegrationAnalytics(
        startDate: startDate,
        endDate: endDate,
      );

      return Right(analytics);
    } catch (e) {
      return Left(UnknownFailure('Failed to get integration analytics: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LATRAApplication>>> getApplicationsByAssignee(
    String assigneeId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final applications = await remoteDataSource.getApplicationsByAssignee(
        assigneeId,
      );
      return Right(applications.cast<LATRAApplication>());
    } catch (e) {
      return Left(UnknownFailure('Failed to get applications by assignee: $e'));
    }
  }

  @override
  Future<Either<Failure, List<VerificationStatus>>> getVerificationsByVerifier(
    String verifierId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final verifications = await remoteDataSource.getVerificationsByVerifier(
        verifierId,
      );
      return Right(verifications.map((model) => model.toEntity()).toList());
    } catch (e) {
      return Left(
        UnknownFailure('Failed to get verifications by verifier: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAdminDashboardData() async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final dashboardData = await remoteDataSource.getAdminDashboardData();
      return Right(dashboardData);
    } catch (e) {
      return Left(UnknownFailure('Failed to get admin dashboard data: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> bulkUpdateApplicationStatus(
    List<String> applicationIds,
    LATRAApplicationStatus status,
    String adminId,
    String? notes,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.bulkUpdateApplicationStatus(
        applicationIds,
        status,
        adminId,
        notes,
      );

      return const Right(null);
    } catch (e) {
      return Left(
        UnknownFailure('Failed to bulk update application status: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> bulkAssignApplications(
    List<String> applicationIds,
    String assignedTo,
    String assignedBy,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.bulkAssignApplications(
        applicationIds,
        assignedTo,
        assignedBy,
      );

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to bulk assign applications: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LATRAApplication>>> searchApplications(
    String query, {
    LATRAApplicationStatus? status,
    LATRAApplicationType? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final applications = await remoteDataSource.searchApplications(
        query,
        status: status,
        type: type,
        page: page,
        limit: limit,
      );

      return Right(applications.cast<LATRAApplication>());
    } catch (e) {
      return Left(UnknownFailure('Failed to search applications: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LATRADocument>>> searchDocuments(
    String query, {
    LATRADocumentStatus? status,
    LATRADocumentType? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final documents = await remoteDataSource.searchDocuments(
        query,
        status: status,
        type: type,
        page: page,
        limit: limit,
      );

      return Right(documents.cast<LATRADocument>());
    } catch (e) {
      return Left(UnknownFailure('Failed to search documents: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateApplicationsReport({
    DateTime? startDate,
    DateTime? endDate,
    LATRAApplicationStatus? status,
    LATRAApplicationType? type,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // For now, return basic analytics as report
      final analytics = await remoteDataSource.getApplicationsAnalytics(
        startDate: startDate,
        endDate: endDate,
      );

      return Right({
        ...analytics,
        'reportType': 'applications',
        'generatedAt': DateTime.now().toIso8601String(),
        'filters': {
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
          'status': status?.name,
          'type': type?.name,
        },
      });
    } catch (e) {
      return Left(UnknownFailure('Failed to generate applications report: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateVerificationReport({
    DateTime? startDate,
    DateTime? endDate,
    String? verifiedBy,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // For now, return basic analytics as report
      final analytics = await remoteDataSource.getVerificationAnalytics(
        startDate: startDate,
        endDate: endDate,
      );

      return Right({
        ...analytics,
        'reportType': 'verifications',
        'generatedAt': DateTime.now().toIso8601String(),
        'filters': {
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
          'verifiedBy': verifiedBy,
        },
      });
    } catch (e) {
      return Left(UnknownFailure('Failed to generate verification report: $e'));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> generateIntegrationReport({
    DateTime? startDate,
    DateTime? endDate,
    String? serviceName,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();
      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // For now, return basic analytics as report
      final analytics = await remoteDataSource.getIntegrationAnalytics(
        startDate: startDate,
        endDate: endDate,
      );

      return Right({
        ...analytics,
        'reportType': 'integration',
        'generatedAt': DateTime.now().toIso8601String(),
        'filters': {
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
          'serviceName': serviceName,
        },
      });
    } catch (e) {
      return Left(UnknownFailure('Failed to generate integration report: $e'));
    }
  }
}
