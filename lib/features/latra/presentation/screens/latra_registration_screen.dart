import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/constants.dart';
import '../../domain/entities/latra_application.dart';
import '../providers/latra_form_providers.dart';
import '../providers/latra_state_providers.dart';
import '../providers/latra_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/application_type_selector.dart';
import '../widgets/vehicle_selector.dart';
import '../widgets/required_documents_section.dart';
import '../widgets/application_fee_display.dart';

/// LATRA Registration Screen for vehicle registration with LATRA
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRARegistrationScreen extends ConsumerStatefulWidget {
  const LATRARegistrationScreen({super.key});

  @override
  ConsumerState<LATRARegistrationScreen> createState() =>
      _LATRARegistrationScreenState();
}

class _LATRARegistrationScreenState
    extends ConsumerState<LATRARegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _ownerNameController = TextEditingController();
  final _ownerAddressController = TextEditingController();
  final _ownerPhoneController = TextEditingController();
  final _currentLicenseController = TextEditingController();
  final _newOwnerNameController = TextEditingController();
  final _newOwnerAddressController = TextEditingController();
  final _transferReasonController = TextEditingController();
  final _lostReasonController = TextEditingController();
  final _policeReportController = TextEditingController();
  final _permitReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupFormControllerListeners();
  }

  @override
  void dispose() {
    _ownerNameController.dispose();
    _ownerAddressController.dispose();
    _ownerPhoneController.dispose();
    _currentLicenseController.dispose();
    _newOwnerNameController.dispose();
    _newOwnerAddressController.dispose();
    _transferReasonController.dispose();
    _lostReasonController.dispose();
    _policeReportController.dispose();
    _permitReasonController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupFormControllerListeners() {
    _ownerNameController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField('ownerName', _ownerNameController.text);
    });

    _ownerAddressController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField('ownerAddress', _ownerAddressController.text);
    });

    _ownerPhoneController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField('ownerPhone', _ownerPhoneController.text);
    });

    _currentLicenseController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField(
            'currentLicenseNumber',
            _currentLicenseController.text,
          );
    });

    _newOwnerNameController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField('newOwnerName', _newOwnerNameController.text);
    });

    _newOwnerAddressController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField('newOwnerAddress', _newOwnerAddressController.text);
    });

    _transferReasonController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField('transferReason', _transferReasonController.text);
    });

    _lostReasonController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField('lostReason', _lostReasonController.text);
    });

    _policeReportController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField('policeReportNumber', _policeReportController.text);
    });

    _permitReasonController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField('permitReason', _permitReasonController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(latraRegistrationFormProvider);
    final applicationState = ref.watch(latraApplicationNotifierProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'LATRA Registration'),
      body: LoadingOverlay(
        isLoading: applicationState.isLoading,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            padding: EdgeInsets.all(AppConstants.defaultPadding.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                _buildHeaderSection(),
                SizedBox(height: 24.h),

                // Application Type Selection
                ApplicationTypeSelector(
                  selectedType: formState.selectedType,
                  onTypeSelected: (type) {
                    ref
                        .read(latraRegistrationFormProvider.notifier)
                        .selectApplicationType(type);
                  },
                  error: formState.validationErrors['applicationType'],
                ),
                SizedBox(height: 24.h),

                // Vehicle Selection
                if (formState.selectedType != null) ...[
                  VehicleSelector(
                    selectedVehicle: formState.selectedVehicle,
                    onVehicleSelected: (vehicle) {
                      ref
                          .read(latraRegistrationFormProvider.notifier)
                          .selectVehicle(vehicle);
                    },
                    error: formState.validationErrors['vehicle'],
                  ),
                  SizedBox(height: 24.h),
                ],

                // Dynamic Form Fields based on Application Type
                if (formState.selectedType != null &&
                    formState.selectedVehicle != null) ...[
                  _buildDynamicFormFields(formState.selectedType!),
                  SizedBox(height: 24.h),

                  // Required Documents Section
                  RequiredDocumentsSection(
                    requiredDocuments: formState.requiredDocuments,
                    uploadedDocuments: formState.uploadedDocuments,
                    onDocumentUploaded: (documentType) {
                      ref
                          .read(latraRegistrationFormProvider.notifier)
                          .addUploadedDocument(documentType);
                    },
                    onDocumentRemoved: (documentType) {
                      ref
                          .read(latraRegistrationFormProvider.notifier)
                          .removeUploadedDocument(documentType);
                    },
                    error: formState.validationErrors['documents'],
                  ),
                  SizedBox(height: 24.h),

                  // Application Fee Display
                  if (formState.applicationFee != null)
                    ApplicationFeeDisplay(
                      fee: formState.applicationFee!,
                      applicationType: formState.selectedType!,
                    ),
                  SizedBox(height: 32.h),
                ],

                // Error Display
                if (applicationState.error != null)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(16.w),
                    margin: EdgeInsets.only(bottom: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Text(
                      applicationState.error!,
                      style: TextStyle(color: AppColors.error, fontSize: 14.sp),
                    ),
                  ),

                // Submit Button
                CustomButton(
                  text: 'Submit Application',
                  onPressed: formState.isValid && currentUser != null
                      ? () => _submitApplication(currentUser.id)
                      : null,
                  isLoading: applicationState.isLoading,
                ),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Register with LATRA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Complete your vehicle registration with Tanzania\'s Land Transport Regulatory Authority',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDynamicFormFields(LATRAApplicationType type) {
    switch (type) {
      case LATRAApplicationType.vehicleRegistration:
        return _buildVehicleRegistrationFields();
      case LATRAApplicationType.licenseRenewal:
        return _buildLicenseRenewalFields();
      case LATRAApplicationType.ownershipTransfer:
        return _buildOwnershipTransferFields();
      case LATRAApplicationType.duplicateRegistration:
        return _buildDuplicateRegistrationFields();
      case LATRAApplicationType.temporaryPermit:
        return _buildTemporaryPermitFields();
    }
  }

  Widget _buildVehicleRegistrationFields() {
    final formState = ref.watch(latraRegistrationFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Owner Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _ownerNameController,
          labelText: 'Owner Full Name',
          hintText: 'Enter owner\'s full name',
          prefixIcon: const Icon(Icons.person),
          validator: (value) => formState.validationErrors['ownerName'],
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _ownerAddressController,
          labelText: 'Owner Address',
          hintText: 'Enter owner\'s address',
          prefixIcon: const Icon(Icons.location_on),
          maxLines: 3,
          validator: (value) => formState.validationErrors['ownerAddress'],
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _ownerPhoneController,
          labelText: 'Phone Number',
          hintText: 'Enter phone number',
          prefixIcon: const Icon(Icons.phone),
          keyboardType: TextInputType.phone,
          validator: (value) => formState.validationErrors['ownerPhone'],
        ),
      ],
    );
  }

  Widget _buildLicenseRenewalFields() {
    final formState = ref.watch(latraRegistrationFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'License Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _currentLicenseController,
          labelText: 'Current License Number',
          hintText: 'Enter current license number',
          prefixIcon: const Icon(Icons.credit_card),
          validator: (value) =>
              formState.validationErrors['currentLicenseNumber'],
        ),
      ],
    );
  }

  Widget _buildOwnershipTransferFields() {
    final formState = ref.watch(latraRegistrationFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transfer Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _newOwnerNameController,
          labelText: 'New Owner Name',
          hintText: 'Enter new owner\'s name',
          prefixIcon: const Icon(Icons.person),
          validator: (value) => formState.validationErrors['newOwnerName'],
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _newOwnerAddressController,
          labelText: 'New Owner Address',
          hintText: 'Enter new owner\'s address',
          prefixIcon: const Icon(Icons.location_on),
          maxLines: 3,
          validator: (value) => formState.validationErrors['newOwnerAddress'],
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _transferReasonController,
          labelText: 'Transfer Reason',
          hintText: 'Enter reason for transfer',
          prefixIcon: const Icon(Icons.description),
          maxLines: 2,
          validator: (value) => formState.validationErrors['transferReason'],
        ),
      ],
    );
  }

  Widget _buildDuplicateRegistrationFields() {
    final formState = ref.watch(latraRegistrationFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Duplicate Request Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _lostReasonController,
          labelText: 'Reason for Duplicate',
          hintText: 'Enter reason (lost, damaged, etc.)',
          prefixIcon: const Icon(Icons.description),
          maxLines: 2,
          validator: (value) => formState.validationErrors['lostReason'],
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _policeReportController,
          labelText: 'Police Report Number',
          hintText: 'Enter police report number',
          prefixIcon: const Icon(Icons.security),
          validator: (value) =>
              formState.validationErrors['policeReportNumber'],
        ),
      ],
    );
  }

  Widget _buildTemporaryPermitFields() {
    final formState = ref.watch(latraRegistrationFormProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Permit Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        CustomTextField(
          controller: _permitReasonController,
          labelText: 'Permit Reason',
          hintText: 'Enter reason for temporary permit',
          prefixIcon: const Icon(Icons.description),
          maxLines: 2,
          validator: (value) => formState.validationErrors['permitReason'],
        ),
      ],
    );
  }

  Future<void> _submitApplication(String userId) async {
    final formState = ref.read(latraRegistrationFormProvider);

    if (!formState.isValid ||
        formState.selectedType == null ||
        formState.selectedVehicle == null) {
      _showErrorSnackBar('Please complete all required fields');
      return;
    }

    final success = await ref
        .read(latraApplicationNotifierProvider.notifier)
        .registerWithLATRA(
          userId: userId,
          vehicleId: formState.selectedVehicle!.id,
          type: formState.selectedType!,
          formData: formState.formData,
          description:
              'LATRA ${formState.selectedType!.displayName} application',
          autoSubmit: true,
        );

    if (success) {
      _showSuccessSnackBar('Application submitted successfully!');
      // Reset form
      ref.read(latraRegistrationFormProvider.notifier).reset();
      // Navigate back or to status screen
      Navigator.of(context).pop();
    } else {
      _showErrorSnackBar('Failed to submit application. Please try again.');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
