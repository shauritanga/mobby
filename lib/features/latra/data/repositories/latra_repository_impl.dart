import 'package:dartz/dartz.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/error/failures.dart';
import '../../domain/entities/latra_application.dart';
import '../../domain/entities/latra_status.dart';
import '../../domain/entities/latra_document.dart';
import '../../domain/repositories/latra_repository.dart';
import '../datasources/latra_remote_datasource.dart';
import '../datasources/latra_local_datasource.dart';
import '../models/latra_application_model.dart';

/// LATRA repository implementation
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRARepositoryImpl implements LATRARepository {
  final LATRARemoteDataSource remoteDataSource;
  final LATRALocalDataSource localDataSource;
  final Connectivity connectivity;

  const LATRARepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivity,
  });

  @override
  Future<Either<Failure, List<LATRAApplication>>> getUserApplications(
    String userId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Return cached data when offline
        final cachedApplications = await localDataSource
            .getCachedUserApplications(userId);
        return Right(cachedApplications);
      }

      // Fetch from remote
      final remoteApplications = await remoteDataSource.getUserApplications(
        userId,
      );

      // Cache the results
      await localDataSource.cacheUserApplications(userId, remoteApplications);

      return Right(remoteApplications);
    } catch (e) {
      // Fallback to cached data on error
      try {
        final cachedApplications = await localDataSource
            .getCachedUserApplications(userId);
        return Right(cachedApplications);
      } catch (cacheError) {
        return Left(UnknownFailure('Failed to get user applications: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, LATRAApplication?>> getApplicationById(
    String applicationId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Return cached data when offline
        final cachedApplication = await localDataSource
            .getCachedApplicationById(applicationId);
        return Right(cachedApplication);
      }

      // Fetch from remote
      final remoteApplication = await remoteDataSource.getApplicationById(
        applicationId,
      );

      // Cache the result if found
      if (remoteApplication != null) {
        await localDataSource.cacheApplication(remoteApplication);
      }

      return Right(remoteApplication);
    } catch (e) {
      // Fallback to cached data on error
      try {
        final cachedApplication = await localDataSource
            .getCachedApplicationById(applicationId);
        return Right(cachedApplication);
      } catch (cacheError) {
        return Left(UnknownFailure('Failed to get application: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, LATRAApplication>> createApplication(
    LATRAApplication application,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final applicationModel = LATRAApplicationModel.fromEntity(application);
      final createdApplication = await remoteDataSource.createApplication(
        applicationModel,
      );

      // Cache the created application
      await localDataSource.cacheApplication(createdApplication);

      return Right(createdApplication);
    } catch (e) {
      return Left(UnknownFailure('Failed to create application: $e'));
    }
  }

  @override
  Future<Either<Failure, LATRAApplication>> updateApplication(
    LATRAApplication application,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final applicationModel = LATRAApplicationModel.fromEntity(application);
      final updatedApplication = await remoteDataSource.updateApplication(
        applicationModel,
      );

      // Cache the updated application
      await localDataSource.cacheApplication(updatedApplication);

      return Right(updatedApplication);
    } catch (e) {
      return Left(UnknownFailure('Failed to update application: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteApplication(String applicationId) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.deleteApplication(applicationId);

      // Remove from cache
      await localDataSource.removeCachedApplication(applicationId);

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to delete application: $e'));
    }
  }

  @override
  Future<Either<Failure, LATRAApplication>> submitApplication(
    String applicationId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final submittedApplication = await remoteDataSource.submitApplication(
        applicationId,
      );

      // Cache the updated application
      await localDataSource.cacheApplication(submittedApplication);

      return Right(submittedApplication);
    } catch (e) {
      return Left(UnknownFailure('Failed to submit application: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelApplication(String applicationId) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Get current application
      final applicationResult = await getApplicationById(applicationId);
      if (applicationResult.isLeft()) {
        return Left(applicationResult.fold((l) => l, (r) => throw Exception()));
      }

      final application = applicationResult.fold((l) => null, (r) => r);
      if (application == null) {
        return const Left(NotFoundFailure('Application not found'));
      }

      // Update status to cancelled
      final updatedApplication = LATRAApplicationModel.fromEntity(application)
          .copyWith(
            status: LATRAApplicationStatus.cancelled,
            updatedAt: DateTime.now(),
          );

      await remoteDataSource.updateApplication(updatedApplication);

      // Cache the updated application
      await localDataSource.cacheApplication(updatedApplication);

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to cancel application: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LATRAStatus>>> getApplicationStatus(
    String applicationId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Return cached data when offline
        final cachedStatus = await localDataSource.getCachedApplicationStatus(
          applicationId,
        );
        return Right(cachedStatus);
      }

      // Fetch from remote
      final remoteStatus = await remoteDataSource.getApplicationStatus(
        applicationId,
      );

      // Cache the results
      await localDataSource.cacheApplicationStatus(applicationId, remoteStatus);

      return Right(remoteStatus);
    } catch (e) {
      // Fallback to cached data on error
      try {
        final cachedStatus = await localDataSource.getCachedApplicationStatus(
          applicationId,
        );
        return Right(cachedStatus);
      } catch (cacheError) {
        return Left(UnknownFailure('Failed to get application status: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, LATRAStatus?>> getLatestStatus(
    String applicationId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Return cached data when offline
        final cachedStatus = await localDataSource.getCachedLatestStatus(
          applicationId,
        );
        return Right(cachedStatus);
      }

      // Fetch from remote
      final remoteStatus = await remoteDataSource.getLatestStatus(
        applicationId,
      );

      // Cache the result if found
      if (remoteStatus != null) {
        await localDataSource.cacheStatus(remoteStatus);
      }

      return Right(remoteStatus);
    } catch (e) {
      // Fallback to cached data on error
      try {
        final cachedStatus = await localDataSource.getCachedLatestStatus(
          applicationId,
        );
        return Right(cachedStatus);
      } catch (cacheError) {
        return Left(UnknownFailure('Failed to get latest status: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, List<LATRAStatus>>> getUserStatusUpdates(
    String userId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      // Fetch from remote
      final remoteStatus = await remoteDataSource.getUserStatusUpdates(userId);

      return Right(remoteStatus);
    } catch (e) {
      return Left(UnknownFailure('Failed to get user status updates: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LATRADocument>>> getApplicationDocuments(
    String applicationId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Return cached data when offline
        final cachedDocuments = await localDataSource
            .getCachedApplicationDocuments(applicationId);
        return Right(cachedDocuments);
      }

      // Fetch from remote
      final remoteDocuments = await remoteDataSource.getApplicationDocuments(
        applicationId,
      );

      // Cache the results
      await localDataSource.cacheApplicationDocuments(
        applicationId,
        remoteDocuments,
      );

      return Right(remoteDocuments);
    } catch (e) {
      // Fallback to cached data on error
      try {
        final cachedDocuments = await localDataSource
            .getCachedApplicationDocuments(applicationId);
        return Right(cachedDocuments);
      } catch (cacheError) {
        return Left(UnknownFailure('Failed to get application documents: $e'));
      }
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

      // Fetch from remote
      final remoteDocument = await remoteDataSource.getDocumentById(documentId);

      // Cache the result if found
      if (remoteDocument != null) {
        await localDataSource.cacheDocument(remoteDocument);
      }

      return Right(remoteDocument);
    } catch (e) {
      return Left(UnknownFailure('Failed to get document: $e'));
    }
  }

  @override
  Future<Either<Failure, LATRADocument>> uploadDocument(
    String applicationId,
    String filePath,
    LATRADocumentType type,
    String title, {
    String? description,
  }) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final uploadedDocument = await remoteDataSource.uploadDocument(
        applicationId,
        filePath,
        type,
        title,
        description,
      );

      // Cache the uploaded document
      await localDataSource.cacheDocument(uploadedDocument);

      return Right(uploadedDocument);
    } catch (e) {
      return Left(UnknownFailure('Failed to upload document: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteDocument(String documentId) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      await remoteDataSource.deleteDocument(documentId);

      // Remove from cache
      await localDataSource.removeCachedDocument(documentId);

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to delete document: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LATRADocument>>> getUserDocuments(
    String userId,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        // Return cached data when offline
        final cachedDocuments = await localDataSource.getCachedUserDocuments(
          userId,
        );
        return Right(cachedDocuments);
      }

      // Fetch from remote
      final remoteDocuments = await remoteDataSource.getUserDocuments(userId);

      return Right(remoteDocuments);
    } catch (e) {
      // Fallback to cached data on error
      try {
        final cachedDocuments = await localDataSource.getCachedUserDocuments(
          userId,
        );
        return Right(cachedDocuments);
      } catch (cacheError) {
        return Left(UnknownFailure('Failed to get user documents: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, List<LATRAApplicationType>>>
  getAvailableApplicationTypes() async {
    try {
      // Return all available application types
      return Right(LATRAApplicationType.values);
    } catch (e) {
      return Left(UnknownFailure('Failed to get application types: $e'));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getRequiredDocuments(
    LATRAApplicationType type,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final requiredDocuments = await remoteDataSource.getRequiredDocuments(
        type,
      );
      return Right(requiredDocuments);
    } catch (e) {
      return Left(UnknownFailure('Failed to get required documents: $e'));
    }
  }

  @override
  Future<Either<Failure, double>> getApplicationFee(
    LATRAApplicationType type,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final fee = await remoteDataSource.getApplicationFee(type);
      return Right(fee);
    } catch (e) {
      return Left(UnknownFailure('Failed to get application fee: $e'));
    }
  }

  @override
  Future<Either<Failure, String>> initiatePayment(
    String applicationId,
    double amount,
  ) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final paymentReference = await remoteDataSource.initiatePayment(
        applicationId,
        amount,
      );
      return Right(paymentReference);
    } catch (e) {
      return Left(UnknownFailure('Failed to initiate payment: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> verifyPayment(String paymentReference) async {
    try {
      final connectivityResult = await connectivity.checkConnectivity();

      if (connectivityResult.contains(ConnectivityResult.none)) {
        return const Left(NetworkFailure('No internet connection'));
      }

      final isVerified = await remoteDataSource.verifyPayment(paymentReference);
      return Right(isVerified);
    } catch (e) {
      return Left(UnknownFailure('Failed to verify payment: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LATRAApplication>>> searchApplications(
    String userId,
    String query,
  ) async {
    try {
      final applicationsResult = await getUserApplications(userId);
      if (applicationsResult.isLeft()) {
        return applicationsResult;
      }

      final applications = applicationsResult.fold(
        (l) => <LATRAApplication>[],
        (r) => r,
      );

      // Simple search implementation
      final filteredApplications = applications
          .where(
            (app) =>
                app.title.toLowerCase().contains(query.toLowerCase()) ||
                app.description.toLowerCase().contains(query.toLowerCase()) ||
                app.applicationNumber.toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();

      return Right(filteredApplications);
    } catch (e) {
      return Left(UnknownFailure('Failed to search applications: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LATRAApplication>>> getApplicationsByStatus(
    String userId,
    LATRAApplicationStatus status,
  ) async {
    try {
      final applicationsResult = await getUserApplications(userId);
      if (applicationsResult.isLeft()) {
        return applicationsResult;
      }

      final applications = applicationsResult.fold(
        (l) => <LATRAApplication>[],
        (r) => r,
      );
      final filteredApplications = applications
          .where((app) => app.status == status)
          .toList();

      return Right(filteredApplications);
    } catch (e) {
      return Left(UnknownFailure('Failed to get applications by status: $e'));
    }
  }

  @override
  Future<Either<Failure, List<LATRAApplication>>> getApplicationsByType(
    String userId,
    LATRAApplicationType type,
  ) async {
    try {
      final applicationsResult = await getUserApplications(userId);
      if (applicationsResult.isLeft()) {
        return applicationsResult;
      }

      final applications = applicationsResult.fold(
        (l) => <LATRAApplication>[],
        (r) => r,
      );
      final filteredApplications = applications
          .where((app) => app.type == type)
          .toList();

      return Right(filteredApplications);
    } catch (e) {
      return Left(UnknownFailure('Failed to get applications by type: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> enableStatusNotifications(
    String applicationId,
  ) async {
    // This would typically integrate with a notification service
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> disableStatusNotifications(
    String applicationId,
  ) async {
    // This would typically integrate with a notification service
    return const Right(null);
  }

  @override
  Future<Either<Failure, List<LATRAApplication>>> getVehicleApplications(
    String vehicleId,
  ) async {
    try {
      // This would need to be implemented based on how vehicle applications are stored
      // For now, return empty list
      return const Right([]);
    } catch (e) {
      return Left(UnknownFailure('Failed to get vehicle applications: $e'));
    }
  }

  @override
  Future<Either<Failure, LATRAApplication>> registerVehicleWithLATRA(
    String vehicleId,
    Map<String, dynamic> formData,
  ) async {
    try {
      // This would create a vehicle registration application
      // Implementation would depend on the specific requirements
      return const Left(UnknownFailure('Not implemented yet'));
    } catch (e) {
      return Left(UnknownFailure('Failed to register vehicle with LATRA: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> refreshApplicationsCache(String userId) async {
    try {
      await localDataSource.clearUserCache(userId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to refresh cache: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCache() async {
    try {
      await localDataSource.clearAllCache();
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure('Failed to clear cache: $e'));
    }
  }
}
