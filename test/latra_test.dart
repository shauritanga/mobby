import 'package:flutter_test/flutter_test.dart';
import 'package:mobby/features/latra/domain/entities/latra_application.dart';
import 'package:mobby/features/latra/domain/entities/latra_status.dart';
import 'package:mobby/features/latra/domain/entities/latra_document.dart';

void main() {
  group('LATRA Entities Tests', () {
    test('LATRAApplication should be created correctly', () {
      final application = LATRAApplication(
        id: 'test-id',
        userId: 'user-id',
        applicationNumber: 'APP-001',
        type: LATRAApplicationType.vehicleRegistration,
        status: LATRAApplicationStatus.draft,
        title: 'Test Application',
        description: 'Test Description',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(application.id, 'test-id');
      expect(application.type, LATRAApplicationType.vehicleRegistration);
      expect(application.status, LATRAApplicationStatus.draft);
    });

    test('LATRAApplicationType should have correct display names', () {
      expect(
        LATRAApplicationType.vehicleRegistration.displayName,
        'Vehicle Registration',
      );
      expect(
        LATRAApplicationType.licenseRenewal.displayName,
        'License Renewal',
      );
      expect(
        LATRAApplicationType.ownershipTransfer.displayName,
        'Ownership Transfer',
      );
    });

    test('LATRAApplicationStatus should have correct display names', () {
      expect(LATRAApplicationStatus.draft.displayName, 'Draft');
      expect(LATRAApplicationStatus.pending.displayName, 'Pending');
      expect(LATRAApplicationStatus.approved.displayName, 'Approved');
    });

    test('LATRAStatus should be created correctly', () {
      final status = LATRAStatus(
        id: 'status-id',
        applicationId: 'app-id',
        userId: 'user-id',
        type: LATRAStatusType.submitted,
        title: 'Application Submitted',
        description: 'Your application has been submitted',
        timestamp: DateTime.now(),
      );

      expect(status.id, 'status-id');
      expect(status.type, LATRAStatusType.submitted);
      expect(status.requiresAction, false);
    });

    test('LATRADocument should be created correctly', () {
      final document = LATRADocument(
        id: 'doc-id',
        applicationId: 'app-id',
        userId: 'user-id',
        type: LATRADocumentType.nationalId,
        title: 'National ID',
        fileUrl: 'https://example.com/doc.pdf',
        fileName: 'national_id.pdf',
        fileType: 'application/pdf',
        fileSize: 1024,
        status: LATRADocumentStatus.pending,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      expect(document.id, 'doc-id');
      expect(document.type, LATRADocumentType.nationalId);
      expect(document.status, LATRADocumentStatus.pending);
    });
  });
}
