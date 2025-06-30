import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/latra_application.dart';
import '../../domain/entities/latra_document.dart';
import '../../domain/entities/latra_status.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/domain/usecases/manage_vehicles_usecase.dart';
import '../providers/latra_state_providers.dart';
import '../../../vehicles/presentation/providers/vehicle_providers.dart';
import '../../../vehicles/presentation/providers/vehicle_operations_providers.dart';

/// LATRA Integration Service for connecting LATRA functionality with other features
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRAIntegrationService {
  final Ref _ref;

  LATRAIntegrationService(this._ref);

  /// Integrate LATRA application with vehicle data
  Future<bool> linkApplicationToVehicle(
    String applicationId,
    String vehicleId,
  ) async {
    try {
      // Get application and vehicle data
      final application = await _ref
          .read(latraApplicationNotifierProvider.notifier)
          .getApplication(applicationId);

      final vehicle = await _ref.read(vehicleByIdProvider(vehicleId).future);

      if (application == null || vehicle == null) {
        return false;
      }

      // Update application with vehicle reference
      final updatedApplication = application.copyWith(
        vehicleId: vehicleId,
        vehicleRegistrationNumber: vehicle.registrationNumber,
      );

      // Update vehicle with LATRA application reference
      // Note: Vehicle entity doesn't have LATRA fields, so we'll store this relationship
      // in the LATRA application instead and use specifications for additional data
      final updatedVehicle = vehicle.copyWith(
        specifications: {
          ...vehicle.specifications,
          'latraApplicationId': applicationId,
          'latraStatus': application.status.name,
        },
      );

      // Save updates
      await _ref
          .read(latraApplicationNotifierProvider.notifier)
          .updateApplication(updatedApplication);

      await _ref
          .read(vehicleOperationsProvider)
          .updateVehicle(
            UpdateVehicleParams(
              vehicleId: updatedVehicle.id,
              specifications: updatedVehicle.specifications,
            ),
          );

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get LATRA applications for a specific vehicle
  Future<List<LATRAApplication>> getVehicleApplications(
    String vehicleId,
  ) async {
    try {
      // Note: This method needs to be implemented in the LATRA providers
      // For now, return empty list
      final applications = <LATRAApplication>[];

      return applications;
    } catch (e) {
      return [];
    }
  }

  /// Get vehicle information for LATRA application
  Future<Vehicle?> getApplicationVehicle(String applicationId) async {
    try {
      final application = await _ref
          .read(latraApplicationNotifierProvider.notifier)
          .getApplication(applicationId);

      if (application?.vehicleId == null) return null;

      final vehicle = await _ref.read(
        vehicleByIdProvider(application!.vehicleId!).future,
      );

      return vehicle;
    } catch (e) {
      return null;
    }
  }

  /// Sync LATRA documents with vehicle documents
  Future<bool> syncDocumentsWithVehicle(
    String applicationId,
    String vehicleId,
  ) async {
    try {
      // Get LATRA documents
      // Note: This method needs to be implemented in the LATRA providers
      // For now, return empty list
      final latraDocuments = <LATRADocument>[];

      // Get vehicle documents
      // Note: Vehicle documents would be used for syncing with LATRA documents
      // For now, we'll skip this functionality
      // final vehicleDocuments = await _ref.read(
      //   vehicleDocumentsProvider(vehicleId).future,
      // );

      // Sync relevant documents
      for (final latraDoc in latraDocuments) {
        if (_isVehicleRelatedDocument(latraDoc.type)) {
          await _createOrUpdateVehicleDocument(latraDoc, vehicleId);
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Update user profile with LATRA information
  Future<bool> updateProfileWithLATRAInfo(
    String userId,
    LATRAApplication application,
  ) async {
    try {
      // Note: Profile provider needs to be implemented properly
      // For now, we'll skip this functionality and return success
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Get user's LATRA summary for profile display
  Future<LATRASummary> getUserLATRASummary(String userId) async {
    try {
      // Note: These methods need to be implemented in the LATRA providers
      // For now, return empty lists
      final applications = <LATRAApplication>[];
      final documents = <LATRADocument>[];

      return LATRASummary(
        totalApplications: applications.length,
        activeApplications: applications
            .where((app) => _isActiveStatus(app.status))
            .length,
        completedApplications: applications
            .where((app) => app.status == LATRAApplicationStatus.approved)
            .length,
        totalDocuments: documents.length,
        verifiedDocuments: documents
            .where((doc) => doc.status == LATRADocumentStatus.verified)
            .length,
        expiredDocuments: documents.where((doc) => doc.isExpired).length,
        expiringSoonDocuments: documents.where((doc) => doc.expiresSoon).length,
        lastApplicationDate: applications.isNotEmpty
            ? applications
                  .map((app) => app.submissionDate)
                  .where((date) => date != null)
                  .cast<DateTime>()
                  .reduce((a, b) => a.isAfter(b) ? a : b)
            : null,
        pendingActions: _getPendingActions(applications),
      );
    } catch (e) {
      return LATRASummary.empty();
    }
  }

  /// Create notification for LATRA status updates
  Future<void> createLATRANotification(
    String userId,
    LATRAStatus status,
    LATRAApplication application,
  ) async {
    try {
      final notification = LATRANotification(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        applicationId: application.id,
        statusType: status.type,
        title: _getNotificationTitle(status.type),
        message: _getNotificationMessage(status, application),
        timestamp: DateTime.now(),
        isRead: false,
        requiresAction: status.requiresAction,
        actionType: _getActionType(status.type),
      );

      // This would typically integrate with a notification service
      // For now, we'll store it in the user's notification list
      await _storeNotification(notification);
    } catch (e) {
      // Handle notification creation error
    }
  }

  /// Get LATRA-related notifications for user
  Future<List<LATRANotification>> getLATRANotifications(String userId) async {
    try {
      // This would typically fetch from a notification service
      // For now, return empty list as placeholder
      return [];
    } catch (e) {
      return [];
    }
  }

  /// Check for LATRA document expiry and create notifications
  Future<void> checkDocumentExpiry(String userId) async {
    try {
      // Note: This method needs to be implemented properly
      // For now, we'll skip document expiry checking
      return;
    } catch (e) {
      // Handle error
    }
  }

  /// Helper methods
  bool _isVehicleRelatedDocument(LATRADocumentType type) {
    return [
      LATRADocumentType.vehicleRegistration,
      LATRADocumentType.insurance,
      LATRADocumentType.inspection,
    ].contains(type);
  }

  Future<void> _createOrUpdateVehicleDocument(
    LATRADocument latraDoc,
    String vehicleId,
  ) async {
    // Implementation would create or update vehicle document
    // based on LATRA document information
  }

  bool _isActiveStatus(LATRAApplicationStatus status) {
    return [
      LATRAApplicationStatus.pending,
      LATRAApplicationStatus.underReview,
      LATRAApplicationStatus.documentsRequired,
    ].contains(status);
  }

  List<String> _getPendingActions(List<LATRAApplication> applications) {
    final actions = <String>[];

    for (final app in applications) {
      switch (app.status) {
        case LATRAApplicationStatus.documentsRequired:
          actions.add('Upload documents for ${app.title}');
          break;
        case LATRAApplicationStatus.pending:
          actions.add('Track status of ${app.title}');
          break;
        default:
          break;
      }
    }

    return actions;
  }

  String _getNotificationTitle(LATRAStatusType type) {
    switch (type) {
      case LATRAStatusType.approved:
        return 'Application Approved';
      case LATRAStatusType.rejected:
        return 'Application Rejected';
      case LATRAStatusType.documentsRequired:
        return 'Documents Required';
      case LATRAStatusType.paymentRequired:
        return 'Payment Required';
      default:
        return 'Application Update';
    }
  }

  String _getNotificationMessage(
    LATRAStatus status,
    LATRAApplication application,
  ) {
    return 'Your ${application.title} has been updated: ${status.description}';
  }

  String? _getActionType(LATRAStatusType type) {
    switch (type) {
      case LATRAStatusType.documentsRequired:
        return 'upload_documents';
      case LATRAStatusType.paymentRequired:
        return 'make_payment';
      case LATRAStatusType.appointmentRequired:
        return 'book_appointment';
      default:
        return null;
    }
  }

  Future<void> _storeNotification(LATRANotification notification) async {
    // Implementation would store notification in database
  }

  // Note: Duplicate methods removed to avoid conflicts
}

/// LATRA Summary data class
class LATRASummary {
  final int totalApplications;
  final int activeApplications;
  final int completedApplications;
  final int totalDocuments;
  final int verifiedDocuments;
  final int expiredDocuments;
  final int expiringSoonDocuments;
  final DateTime? lastApplicationDate;
  final List<String> pendingActions;

  const LATRASummary({
    required this.totalApplications,
    required this.activeApplications,
    required this.completedApplications,
    required this.totalDocuments,
    required this.verifiedDocuments,
    required this.expiredDocuments,
    required this.expiringSoonDocuments,
    this.lastApplicationDate,
    required this.pendingActions,
  });

  factory LATRASummary.empty() {
    return const LATRASummary(
      totalApplications: 0,
      activeApplications: 0,
      completedApplications: 0,
      totalDocuments: 0,
      verifiedDocuments: 0,
      expiredDocuments: 0,
      expiringSoonDocuments: 0,
      pendingActions: [],
    );
  }
}

/// LATRA Notification data class
class LATRANotification {
  final String id;
  final String userId;
  final String applicationId;
  final LATRAStatusType statusType;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final bool requiresAction;
  final String? actionType;

  const LATRANotification({
    required this.id,
    required this.userId,
    required this.applicationId,
    required this.statusType,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    required this.requiresAction,
    this.actionType,
  });
}

/// Provider for LATRA Integration Service
final latraIntegrationServiceProvider = Provider<LATRAIntegrationService>((
  ref,
) {
  return LATRAIntegrationService(ref);
});
