import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/vehicle.dart';
import '../entities/document.dart';
import '../entities/maintenance_record.dart';

/// Vehicle repository interface
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
abstract class VehicleRepository {
  // Vehicle operations
  Future<Either<Failure, List<Vehicle>>> getUserVehicles(String userId);
  Future<Either<Failure, Vehicle?>> getVehicleById(String vehicleId);
  Future<Either<Failure, Vehicle>> createVehicle(Vehicle vehicle);
  Future<Either<Failure, Vehicle>> updateVehicle(Vehicle vehicle);
  Future<Either<Failure, void>> deleteVehicle(String vehicleId);

  // Vehicle search and filtering
  Future<Either<Failure, List<Vehicle>>> searchVehicles(
    String userId,
    String query,
  );
  Future<Either<Failure, List<Vehicle>>> getVehiclesByType(
    String userId,
    VehicleType type,
  );
  Future<Either<Failure, List<Vehicle>>> getVehiclesByStatus(
    String userId,
    VehicleStatus status,
  );

  // Document operations
  Future<Either<Failure, List<Document>>> getVehicleDocuments(String vehicleId);
  Future<Either<Failure, List<Document>>> getUserDocuments(String userId);
  Future<Either<Failure, Document?>> getDocumentById(String documentId);
  Future<Either<Failure, Document>> createDocument(Document document);
  Future<Either<Failure, Document>> updateDocument(Document document);
  Future<Either<Failure, void>> deleteDocument(String documentId);

  // Document filtering
  Future<Either<Failure, List<Document>>> getDocumentsByType(
    String vehicleId,
    DocumentType type,
  );
  Future<Either<Failure, List<Document>>> getExpiredDocuments(String userId);
  Future<Either<Failure, List<Document>>> getExpiringSoonDocuments(
    String userId,
  );

  // Maintenance operations
  Future<Either<Failure, List<MaintenanceRecord>>> getVehicleMaintenanceRecords(
    String vehicleId,
  );
  Future<Either<Failure, List<MaintenanceRecord>>> getUserMaintenanceRecords(
    String userId,
  );
  Future<Either<Failure, MaintenanceRecord?>> getMaintenanceRecordById(
    String recordId,
  );
  Future<Either<Failure, MaintenanceRecord>> createMaintenanceRecord(
    MaintenanceRecord record,
  );
  Future<Either<Failure, MaintenanceRecord>> updateMaintenanceRecord(
    MaintenanceRecord record,
  );
  Future<Either<Failure, void>> deleteMaintenanceRecord(String recordId);

  // Maintenance filtering and analytics
  Future<Either<Failure, List<MaintenanceRecord>>> getMaintenanceRecordsByType(
    String vehicleId,
    MaintenanceType type,
  );
  Future<Either<Failure, List<MaintenanceRecord>>> getOverdueMaintenanceRecords(
    String userId,
  );
  Future<Either<Failure, double>> getTotalMaintenanceCost(
    String vehicleId, {
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<Either<Failure, Map<String, dynamic>>> getMaintenanceStatistics(
    String vehicleId,
  );

  // File upload operations
  Future<Either<Failure, String>> uploadVehicleImage(
    String vehicleId,
    String filePath,
  );
  Future<Either<Failure, String>> uploadDocument(
    String documentId,
    String filePath,
  );
  Future<Either<Failure, String>> uploadMaintenanceReceipt(
    String recordId,
    String filePath,
  );
  Future<Either<Failure, void>> deleteFile(String fileUrl);

  // Vehicle validation
  Future<Either<Failure, bool>> validatePlateNumber(
    String plateNumber, {
    String? excludeVehicleId,
  });
  Future<Either<Failure, bool>> validateEngineNumber(
    String engineNumber, {
    String? excludeVehicleId,
  });
  Future<Either<Failure, bool>> validateChassisNumber(
    String chassisNumber, {
    String? excludeVehicleId,
  });
  Future<Either<Failure, bool>> validateVin(
    String vin, {
    String? excludeVehicleId,
  });

  // Vehicle insights and recommendations
  Future<Either<Failure, List<String>>> getMaintenanceRecommendations(
    String vehicleId,
  );
  Future<Either<Failure, Map<String, dynamic>>> getVehicleInsights(
    String vehicleId,
  );
  Future<Either<Failure, List<Document>>> getDocumentReminders(String userId);
  Future<Either<Failure, List<MaintenanceRecord>>> getUpcomingMaintenance(
    String userId,
  );

  // Bulk operations
  Future<Either<Failure, void>> bulkUpdateVehicleStatus(
    List<String> vehicleIds,
    VehicleStatus status,
  );
  Future<Either<Failure, void>> bulkDeleteDocuments(List<String> documentIds);
  Future<Either<Failure, List<Vehicle>>> importVehicles(
    String userId,
    List<Map<String, dynamic>> vehicleData,
  );

  // Cache operations
  Future<Either<Failure, void>> refreshVehicleCache(String userId);
  Future<Either<Failure, void>> clearVehicleCache(String userId);

  // Analytics and reporting
  Future<Either<Failure, Map<String, dynamic>>> getVehicleAnalytics(
    String userId,
  );
  Future<Either<Failure, Map<String, dynamic>>> getFleetSummary(String userId);
  Future<Either<Failure, List<Map<String, dynamic>>>> getMaintenanceTrends(
    String userId, {
    int months = 12,
  });

  // Notifications and reminders
  Future<Either<Failure, void>> scheduleDocumentReminder(
    String documentId,
    DateTime reminderDate,
  );
  Future<Either<Failure, void>> scheduleMaintenanceReminder(
    String recordId,
    DateTime reminderDate,
  );
  Future<Either<Failure, void>> cancelReminder(String reminderId);

  // Integration with other features
  Future<Either<Failure, void>> syncWithLATRA(String vehicleId);
  Future<Either<Failure, void>> syncWithInsurance(String vehicleId);
  Future<Either<Failure, List<Map<String, dynamic>>>> getCompatibleParts(
    String vehicleId,
  );
}
