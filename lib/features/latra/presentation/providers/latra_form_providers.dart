import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/latra_application.dart';
import '../../domain/entities/latra_document.dart';
import '../../../vehicles/domain/entities/vehicle.dart';
import '../../../vehicles/presentation/providers/vehicle_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import 'latra_providers.dart';

// LATRA Registration Form State
class LATRARegistrationFormState extends Equatable {
  final LATRAApplicationType? selectedType;
  final Vehicle? selectedVehicle;
  final Map<String, dynamic> formData;
  final List<String> requiredDocuments;
  final List<String> uploadedDocuments;
  final Map<String, String> validationErrors;
  final bool isValid;
  final double? applicationFee;

  const LATRARegistrationFormState({
    this.selectedType,
    this.selectedVehicle,
    this.formData = const {},
    this.requiredDocuments = const [],
    this.uploadedDocuments = const [],
    this.validationErrors = const {},
    this.isValid = false,
    this.applicationFee,
  });

  LATRARegistrationFormState copyWith({
    LATRAApplicationType? selectedType,
    Vehicle? selectedVehicle,
    Map<String, dynamic>? formData,
    List<String>? requiredDocuments,
    List<String>? uploadedDocuments,
    Map<String, String>? validationErrors,
    bool? isValid,
    double? applicationFee,
  }) {
    return LATRARegistrationFormState(
      selectedType: selectedType ?? this.selectedType,
      selectedVehicle: selectedVehicle ?? this.selectedVehicle,
      formData: formData ?? this.formData,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      uploadedDocuments: uploadedDocuments ?? this.uploadedDocuments,
      validationErrors: validationErrors ?? this.validationErrors,
      isValid: isValid ?? this.isValid,
      applicationFee: applicationFee ?? this.applicationFee,
    );
  }

  @override
  List<Object?> get props => [
    selectedType,
    selectedVehicle,
    formData,
    requiredDocuments,
    uploadedDocuments,
    validationErrors,
    isValid,
    applicationFee,
  ];
}

// LATRA Registration Form Notifier
class LATRARegistrationFormNotifier
    extends StateNotifier<LATRARegistrationFormState> {
  final Ref _ref;

  LATRARegistrationFormNotifier(this._ref)
    : super(const LATRARegistrationFormState());

  void selectApplicationType(LATRAApplicationType type) async {
    state = state.copyWith(selectedType: type);

    // Load required documents and fee
    await _loadRequiredDocuments(type);
    await _loadApplicationFee(type);
    _validateForm();
  }

  void selectVehicle(Vehicle vehicle) {
    state = state.copyWith(selectedVehicle: vehicle);

    // Auto-populate form data from vehicle
    final updatedFormData = Map<String, dynamic>.from(state.formData);
    updatedFormData.addAll({
      'vehicleId': vehicle.id,
      'make': vehicle.make,
      'model': vehicle.model,
      'year': vehicle.year,
      'plateNumber': vehicle.plateNumber,
      'engineNumber': vehicle.engineNumber,
      'chassisNumber': vehicle.chassisNumber,
      'vin': vehicle.vin,
    });

    state = state.copyWith(formData: updatedFormData);
    _validateForm();
  }

  void updateFormField(String key, dynamic value) {
    final updatedFormData = Map<String, dynamic>.from(state.formData);
    updatedFormData[key] = value;

    state = state.copyWith(formData: updatedFormData);
    _validateForm();
  }

  void addUploadedDocument(String documentType) {
    final updatedDocuments = [...state.uploadedDocuments, documentType];
    state = state.copyWith(uploadedDocuments: updatedDocuments);
    _validateForm();
  }

  void removeUploadedDocument(String documentType) {
    final updatedDocuments = state.uploadedDocuments
        .where((doc) => doc != documentType)
        .toList();
    state = state.copyWith(uploadedDocuments: updatedDocuments);
    _validateForm();
  }

  Future<void> _loadRequiredDocuments(LATRAApplicationType type) async {
    try {
      final repository = _ref.read(latraRepositoryProvider);
      final result = await repository.getRequiredDocuments(type);

      result.fold(
        (failure) => {}, // Handle error silently for now
        (documents) => state = state.copyWith(requiredDocuments: documents),
      );
    } catch (e) {
      // Handle error silently for now
    }
  }

  Future<void> _loadApplicationFee(LATRAApplicationType type) async {
    try {
      final repository = _ref.read(latraRepositoryProvider);
      final result = await repository.getApplicationFee(type);

      result.fold(
        (failure) => {}, // Handle error silently for now
        (fee) => state = state.copyWith(applicationFee: fee),
      );
    } catch (e) {
      // Handle error silently for now
    }
  }

  void _validateForm() {
    final errors = <String, String>{};

    // Validate application type
    if (state.selectedType == null) {
      errors['applicationType'] = 'Please select an application type';
    }

    // Validate vehicle selection
    if (state.selectedVehicle == null) {
      errors['vehicle'] = 'Please select a vehicle';
    }

    // Validate required form fields based on application type
    if (state.selectedType != null) {
      switch (state.selectedType!) {
        case LATRAApplicationType.vehicleRegistration:
          _validateVehicleRegistrationFields(errors);
          break;
        case LATRAApplicationType.licenseRenewal:
          _validateLicenseRenewalFields(errors);
          break;
        case LATRAApplicationType.ownershipTransfer:
          _validateOwnershipTransferFields(errors);
          break;
        case LATRAApplicationType.duplicateRegistration:
          _validateDuplicateRegistrationFields(errors);
          break;
        case LATRAApplicationType.temporaryPermit:
          _validateTemporaryPermitFields(errors);
          break;
      }
    }

    // Validate required documents
    final missingDocuments = state.requiredDocuments
        .where((doc) => !state.uploadedDocuments.contains(doc))
        .toList();

    if (missingDocuments.isNotEmpty) {
      errors['documents'] =
          'Missing required documents: ${missingDocuments.join(', ')}';
    }

    final isValid = errors.isEmpty;
    state = state.copyWith(validationErrors: errors, isValid: isValid);
  }

  void _validateVehicleRegistrationFields(Map<String, String> errors) {
    if (state.formData['ownerName']?.toString().isEmpty ?? true) {
      errors['ownerName'] = 'Owner name is required';
    }

    if (state.formData['ownerAddress']?.toString().isEmpty ?? true) {
      errors['ownerAddress'] = 'Owner address is required';
    }

    if (state.formData['ownerPhone']?.toString().isEmpty ?? true) {
      errors['ownerPhone'] = 'Owner phone number is required';
    }
  }

  void _validateLicenseRenewalFields(Map<String, String> errors) {
    if (state.formData['currentLicenseNumber']?.toString().isEmpty ?? true) {
      errors['currentLicenseNumber'] = 'Current license number is required';
    }

    if (state.formData['expiryDate'] == null) {
      errors['expiryDate'] = 'License expiry date is required';
    }
  }

  void _validateOwnershipTransferFields(Map<String, String> errors) {
    if (state.formData['newOwnerName']?.toString().isEmpty ?? true) {
      errors['newOwnerName'] = 'New owner name is required';
    }

    if (state.formData['newOwnerAddress']?.toString().isEmpty ?? true) {
      errors['newOwnerAddress'] = 'New owner address is required';
    }

    if (state.formData['transferReason']?.toString().isEmpty ?? true) {
      errors['transferReason'] = 'Transfer reason is required';
    }
  }

  void _validateDuplicateRegistrationFields(Map<String, String> errors) {
    if (state.formData['lostReason']?.toString().isEmpty ?? true) {
      errors['lostReason'] = 'Reason for duplicate is required';
    }

    if (state.formData['policeReportNumber']?.toString().isEmpty ?? true) {
      errors['policeReportNumber'] = 'Police report number is required';
    }
  }

  void _validateTemporaryPermitFields(Map<String, String> errors) {
    if (state.formData['permitReason']?.toString().isEmpty ?? true) {
      errors['permitReason'] = 'Permit reason is required';
    }

    if (state.formData['permitDuration'] == null) {
      errors['permitDuration'] = 'Permit duration is required';
    }
  }

  void reset() {
    state = const LATRARegistrationFormState();
  }
}

// Document Upload Form State
class DocumentUploadFormState extends Equatable {
  final LATRADocumentType? selectedType;
  final String title;
  final String description;
  final String? filePath;
  final Map<String, String> validationErrors;
  final bool isValid;

  const DocumentUploadFormState({
    this.selectedType,
    this.title = '',
    this.description = '',
    this.filePath,
    this.validationErrors = const {},
    this.isValid = false,
  });

  DocumentUploadFormState copyWith({
    LATRADocumentType? selectedType,
    String? title,
    String? description,
    String? filePath,
    Map<String, String>? validationErrors,
    bool? isValid,
  }) {
    return DocumentUploadFormState(
      selectedType: selectedType ?? this.selectedType,
      title: title ?? this.title,
      description: description ?? this.description,
      filePath: filePath ?? this.filePath,
      validationErrors: validationErrors ?? this.validationErrors,
      isValid: isValid ?? this.isValid,
    );
  }

  @override
  List<Object?> get props => [
    selectedType,
    title,
    description,
    filePath,
    validationErrors,
    isValid,
  ];
}

// Document Upload Form Notifier
class DocumentUploadFormNotifier
    extends StateNotifier<DocumentUploadFormState> {
  DocumentUploadFormNotifier() : super(const DocumentUploadFormState());

  void selectDocumentType(LATRADocumentType type) {
    state = state.copyWith(selectedType: type);

    // Auto-populate title based on document type
    state = state.copyWith(title: type.displayName);
    _validateForm();
  }

  void updateTitle(String title) {
    state = state.copyWith(title: title);
    _validateForm();
  }

  void updateDescription(String description) {
    state = state.copyWith(description: description);
    _validateForm();
  }

  void selectFile(String filePath) {
    state = state.copyWith(filePath: filePath);
    _validateForm();
  }

  void _validateForm() {
    final errors = <String, String>{};

    // Validate document type
    if (state.selectedType == null) {
      errors['documentType'] = 'Please select a document type';
    }

    // Validate title
    if (state.title.isEmpty) {
      errors['title'] = 'Document title is required';
    }

    // Validate file selection
    if (state.filePath == null || state.filePath!.isEmpty) {
      errors['file'] = 'Please select a file to upload';
    }

    final isValid = errors.isEmpty;
    state = state.copyWith(validationErrors: errors, isValid: isValid);
  }

  void reset() {
    state = const DocumentUploadFormState();
  }
}

// Form Providers
final latraRegistrationFormProvider =
    StateNotifierProvider<
      LATRARegistrationFormNotifier,
      LATRARegistrationFormState
    >((ref) {
      return LATRARegistrationFormNotifier(ref);
    });

final documentUploadFormProvider =
    StateNotifierProvider<DocumentUploadFormNotifier, DocumentUploadFormState>((
      ref,
    ) {
      return DocumentUploadFormNotifier();
    });

// Helper providers for form data
final userVehiclesForLATRAProvider = FutureProvider<List<Vehicle>>((ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return [];

  return ref.watch(userVehiclesProvider(currentUser.id).future);
});

final applicationTypesWithFeesProvider =
    FutureProvider<Map<LATRAApplicationType, double>>((ref) async {
      final types = await ref.watch(availableApplicationTypesProvider.future);
      final feesMap = <LATRAApplicationType, double>{};

      for (final type in types) {
        try {
          final fee = await ref.watch(applicationFeeProvider(type).future);
          feesMap[type] = fee;
        } catch (e) {
          feesMap[type] = 0.0;
        }
      }

      return feesMap;
    });

final documentTypesProvider = Provider<List<LATRADocumentType>>((ref) {
  return LATRADocumentType.values;
});
