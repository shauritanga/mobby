import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/latra_application.dart';
import '../entities/latra_status.dart';
import '../entities/latra_document.dart';

/// LATRA repository interface
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
abstract class LATRARepository {
  // LATRA Application operations
  Future<Either<Failure, List<LATRAApplication>>> getUserApplications(
    String userId,
  );
  Future<Either<Failure, LATRAApplication?>> getApplicationById(
    String applicationId,
  );
  Future<Either<Failure, LATRAApplication>> createApplication(
    LATRAApplication application,
  );
  Future<Either<Failure, LATRAApplication>> updateApplication(
    LATRAApplication application,
  );
  Future<Either<Failure, void>> deleteApplication(String applicationId);
  Future<Either<Failure, LATRAApplication>> submitApplication(
    String applicationId,
  );
  Future<Either<Failure, void>> cancelApplication(String applicationId);

  // LATRA Status operations - Track Status use case
  Future<Either<Failure, List<LATRAStatus>>> getApplicationStatus(
    String applicationId,
  );
  Future<Either<Failure, LATRAStatus?>> getLatestStatus(String applicationId);
  Future<Either<Failure, List<LATRAStatus>>> getUserStatusUpdates(
    String userId,
  );

  // LATRA Document operations - Upload Documents use case
  Future<Either<Failure, List<LATRADocument>>> getApplicationDocuments(
    String applicationId,
  );
  Future<Either<Failure, LATRADocument?>> getDocumentById(String documentId);
  Future<Either<Failure, LATRADocument>> uploadDocument(
    String applicationId,
    String filePath,
    LATRADocumentType type,
    String title, {
    String? description,
  });
  Future<Either<Failure, void>> deleteDocument(String documentId);
  Future<Either<Failure, List<LATRADocument>>> getUserDocuments(String userId);

  // Application types and requirements
  Future<Either<Failure, List<LATRAApplicationType>>>
  getAvailableApplicationTypes();
  Future<Either<Failure, List<String>>> getRequiredDocuments(
    LATRAApplicationType type,
  );
  Future<Either<Failure, double>> getApplicationFee(LATRAApplicationType type);

  // Payment operations
  Future<Either<Failure, String>> initiatePayment(
    String applicationId,
    double amount,
  );
  Future<Either<Failure, bool>> verifyPayment(String paymentReference);

  // Search and filtering
  Future<Either<Failure, List<LATRAApplication>>> searchApplications(
    String userId,
    String query,
  );
  Future<Either<Failure, List<LATRAApplication>>> getApplicationsByStatus(
    String userId,
    LATRAApplicationStatus status,
  );
  Future<Either<Failure, List<LATRAApplication>>> getApplicationsByType(
    String userId,
    LATRAApplicationType type,
  );

  // Notifications and reminders
  Future<Either<Failure, void>> enableStatusNotifications(String applicationId);
  Future<Either<Failure, void>> disableStatusNotifications(
    String applicationId,
  );

  // Integration with vehicle management
  Future<Either<Failure, List<LATRAApplication>>> getVehicleApplications(
    String vehicleId,
  );
  Future<Either<Failure, LATRAApplication>> registerVehicleWithLATRA(
    String vehicleId,
    Map<String, dynamic> formData,
  );

  // Cache management
  Future<Either<Failure, void>> refreshApplicationsCache(String userId);
  Future<Either<Failure, void>> clearCache();
}
