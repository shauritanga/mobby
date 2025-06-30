import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/latra_integration_service.dart';
import '../providers/latra_notification_providers.dart';
import '../widgets/latra_home_integration.dart';
import '../widgets/latra_profile_integration.dart';
import '../widgets/latra_vehicle_integration.dart';
import '../../domain/entities/latra_application.dart';
import '../../domain/entities/latra_status.dart';
import '../../domain/entities/latra_document.dart';
import '../../../vehicles/domain/entities/vehicle.dart';

/// LATRA Integration Helper for managing cross-feature integration
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRAIntegrationHelper {
  static final _instance = LATRAIntegrationHelper._internal();
  factory LATRAIntegrationHelper() => _instance;
  LATRAIntegrationHelper._internal();

  /// Initialize LATRA integration
  static Future<void> initialize(WidgetRef ref, String userId) async {
    try {
      // Check for pending notifications
      await ref
          .read(latraNotificationActionsProvider)
          .checkAndCreatePendingNotifications(userId);

      // Load user LATRA summary
      await ref
          .read(latraIntegrationServiceProvider)
          .getUserLATRASummary(userId);
    } catch (e) {
      // Handle initialization error
      debugPrint('LATRA Integration initialization error: $e');
    }
  }

  /// Handle application status update
  static Future<void> handleStatusUpdate(
    WidgetRef ref,
    String userId,
    LATRAApplication application,
    LATRAStatus newStatus,
  ) async {
    try {
      // Create notification for status update
      await ref
          .read(latraNotificationActionsProvider)
          .createStatusNotification(userId, newStatus, application);

      // Update profile with LATRA information
      await ref
          .read(latraIntegrationServiceProvider)
          .updateProfileWithLATRAInfo(userId, application);

      // Handle specific status types
      await _handleSpecificStatusActions(ref, userId, application, newStatus);
    } catch (e) {
      debugPrint('Error handling status update: $e');
    }
  }

  /// Handle document expiry check
  static Future<void> handleDocumentExpiryCheck(
    WidgetRef ref,
    String userId,
    List<LATRADocument> documents,
  ) async {
    try {
      for (final document in documents) {
        if (document.expiresSoon || document.isExpired) {
          await ref
              .read(latraNotificationActionsProvider)
              .createDocumentExpiryNotification(userId, document);
        }
      }
    } catch (e) {
      debugPrint('Error checking document expiry: $e');
    }
  }

  /// Link application to vehicle
  static Future<bool> linkApplicationToVehicle(
    WidgetRef ref,
    String applicationId,
    String vehicleId,
  ) async {
    try {
      return await ref
          .read(latraIntegrationServiceProvider)
          .linkApplicationToVehicle(applicationId, vehicleId);
    } catch (e) {
      debugPrint('Error linking application to vehicle: $e');
      return false;
    }
  }

  /// Sync documents between LATRA and vehicle
  static Future<bool> syncDocumentsWithVehicle(
    WidgetRef ref,
    String applicationId,
    String vehicleId,
  ) async {
    try {
      return await ref
          .read(latraIntegrationServiceProvider)
          .syncDocumentsWithVehicle(applicationId, vehicleId);
    } catch (e) {
      debugPrint('Error syncing documents: $e');
      return false;
    }
  }

  /// Get LATRA widget for home screen
  static Widget getLATRAHomeWidget() {
    return const LATRAHomeIntegration();
  }

  /// Get LATRA widget for profile screen
  static Widget getLATRAProfileWidget() {
    return const LATRAProfileIntegration();
  }

  /// Get LATRA widget for vehicle screen
  static Widget getLATRAVehicleWidget(
    Vehicle vehicle, {
    bool showActions = true,
  }) {
    return LATRAVehicleIntegration(vehicle: vehicle, showActions: showActions);
  }

  /// Check if user has active LATRA applications
  static Future<bool> hasActiveApplications(
    WidgetRef ref,
    String userId,
  ) async {
    try {
      final summary = await ref
          .read(latraIntegrationServiceProvider)
          .getUserLATRASummary(userId);
      return summary.activeApplications > 0;
    } catch (e) {
      return false;
    }
  }

  /// Get pending actions count
  static Future<int> getPendingActionsCount(
    WidgetRef ref,
    String userId,
  ) async {
    try {
      final summary = await ref
          .read(latraIntegrationServiceProvider)
          .getUserLATRASummary(userId);
      return summary.pendingActions.length;
    } catch (e) {
      return 0;
    }
  }

  /// Get unread notifications count
  static Future<int> getUnreadNotificationsCount(
    WidgetRef ref,
    String userId,
  ) async {
    try {
      return await ref.read(unreadLATRANotificationsProvider(userId).future);
    } catch (e) {
      return 0;
    }
  }

  /// Handle application submission
  static Future<void> handleApplicationSubmission(
    WidgetRef ref,
    String userId,
    LATRAApplication application,
  ) async {
    try {
      // Update profile with new application
      await ref
          .read(latraIntegrationServiceProvider)
          .updateProfileWithLATRAInfo(userId, application);

      // Create submission notification
      final status = LATRAStatus(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        applicationId: application.id,
        userId: userId,
        type: LATRAStatusType.submitted,
        title: 'Application Submitted',
        description: 'Your application has been successfully submitted',
        timestamp: DateTime.now(),
      );

      await ref
          .read(latraNotificationActionsProvider)
          .createStatusNotification(userId, status, application);
    } catch (e) {
      debugPrint('Error handling application submission: $e');
    }
  }

  /// Handle document upload
  static Future<void> handleDocumentUpload(
    WidgetRef ref,
    String userId,
    String applicationId,
    LATRADocument document,
  ) async {
    try {
      // Check if this completes document requirements
      // This would typically check against application requirements

      // Create document uploaded notification if needed
      // Implementation would depend on specific requirements
    } catch (e) {
      debugPrint('Error handling document upload: $e');
    }
  }

  /// Get integration status
  static Future<LATRAIntegrationStatus> getIntegrationStatus(
    Ref ref,
    String userId,
  ) async {
    try {
      final summary = await ref
          .read(latraIntegrationServiceProvider)
          .getUserLATRASummary(userId);

      final unreadNotifications = await ref.read(
        unreadLATRANotificationsProvider(userId).future,
      );

      return LATRAIntegrationStatus(
        isActive: summary.totalApplications > 0,
        activeApplications: summary.activeApplications,
        pendingActions: summary.pendingActions.length,
        unreadNotifications: unreadNotifications,
        expiredDocuments: summary.expiredDocuments,
        expiringSoonDocuments: summary.expiringSoonDocuments,
        lastActivity: summary.lastApplicationDate,
      );
    } catch (e) {
      return LATRAIntegrationStatus.empty();
    }
  }

  /// Private helper methods
  static Future<void> _handleSpecificStatusActions(
    WidgetRef ref,
    String userId,
    LATRAApplication application,
    LATRAStatus status,
  ) async {
    switch (status.type) {
      case LATRAStatusType.documentsRequired:
        // Create document required notification
        await ref
            .read(latraNotificationActionsProvider)
            .createDocumentRequiredNotification(
              userId,
              application,
              ['Additional documents required'], // This would be dynamic
            );
        break;

      case LATRAStatusType.paymentRequired:
        // Create payment required notification
        await ref
            .read(latraNotificationActionsProvider)
            .createPaymentRequiredNotification(
              userId,
              application,
              application.applicationFee,
            );
        break;

      case LATRAStatusType.appointmentRequired:
        // Create appointment required notification
        await ref
            .read(latraNotificationActionsProvider)
            .createAppointmentRequiredNotification(userId, application);
        break;

      case LATRAStatusType.approved:
        // Create approval notification
        await ref
            .read(latraNotificationActionsProvider)
            .createApprovalNotification(userId, application);
        break;

      default:
        break;
    }
  }
}

/// LATRA Integration Status data class
class LATRAIntegrationStatus {
  final bool isActive;
  final int activeApplications;
  final int pendingActions;
  final int unreadNotifications;
  final int expiredDocuments;
  final int expiringSoonDocuments;
  final DateTime? lastActivity;

  const LATRAIntegrationStatus({
    required this.isActive,
    required this.activeApplications,
    required this.pendingActions,
    required this.unreadNotifications,
    required this.expiredDocuments,
    required this.expiringSoonDocuments,
    this.lastActivity,
  });

  factory LATRAIntegrationStatus.empty() {
    return const LATRAIntegrationStatus(
      isActive: false,
      activeApplications: 0,
      pendingActions: 0,
      unreadNotifications: 0,
      expiredDocuments: 0,
      expiringSoonDocuments: 0,
    );
  }

  bool get hasAlerts =>
      pendingActions > 0 || expiredDocuments > 0 || expiringSoonDocuments > 0;
  bool get hasNotifications => unreadNotifications > 0;
  bool get requiresAttention => hasAlerts || hasNotifications;
}

/// Provider for LATRA integration status
final latraIntegrationStatusProvider =
    FutureProvider.family<LATRAIntegrationStatus, String>((ref, userId) async {
      return await LATRAIntegrationHelper.getIntegrationStatus(ref, userId);
    });
