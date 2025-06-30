import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_application.dart';
import '../providers/latra_form_providers.dart';
import '../providers/latra_state_providers.dart';
import '../providers/latra_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/license_type_selector.dart';
import '../widgets/requirements_checklist.dart';
import '../widgets/appointment_booking_section.dart';
import '../widgets/license_fee_display.dart';

/// License Application Screen for driving license applications
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LicenseApplicationScreen extends ConsumerStatefulWidget {
  const LicenseApplicationScreen({super.key});

  @override
  ConsumerState<LicenseApplicationScreen> createState() =>
      _LicenseApplicationScreenState();
}

class _LicenseApplicationScreenState
    extends ConsumerState<LicenseApplicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  // Form controllers
  final _fullNameController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _medicalCertificateController = TextEditingController();

  // License application state
  LicenseType? _selectedLicenseType;
  DateTime? _selectedAppointmentDate;
  TimeOfDay? _selectedAppointmentTime;
  String? _selectedOfficeLocation;
  final List<String> _completedRequirements = [];
  final List<String> _uploadedDocuments = [];

  @override
  void initState() {
    super.initState();
    _setupFormControllerListeners();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _nationalIdController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _medicalCertificateController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _setupFormControllerListeners() {
    _fullNameController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField('fullName', _fullNameController.text);
    });

    _nationalIdController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField('nationalId', _nationalIdController.text);
    });

    _phoneController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField('phone', _phoneController.text);
    });

    _addressController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField('address', _addressController.text);
    });

    _emergencyContactController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField(
            'emergencyContact',
            _emergencyContactController.text,
          );
    });

    _medicalCertificateController.addListener(() {
      ref
          .read(latraRegistrationFormProvider.notifier)
          .updateFormField(
            'medicalCertificate',
            _medicalCertificateController.text,
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    final applicationState = ref.watch(latraApplicationNotifierProvider);
    final currentUser = ref.watch(currentUserProvider).value;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('License Application'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Form(
            key: _formKey,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  _buildHeaderSection(),
                  SizedBox(height: 24.h),

                  // License Type Selection
                  LicenseTypeSelector(
                    selectedType: _selectedLicenseType,
                    onTypeSelected: (type) {
                      setState(() {
                        _selectedLicenseType = type;
                      });
                    },
                  ),
                  SizedBox(height: 24.h),

                  // Personal Information Form
                  if (_selectedLicenseType != null) ...[
                    _buildPersonalInformationSection(),
                    SizedBox(height: 24.h),

                    // Requirements Checklist
                    RequirementsChecklist(
                      licenseType: _selectedLicenseType!,
                      completedRequirements: _completedRequirements,
                      onRequirementCompleted: (requirement) {
                        setState(() {
                          if (!_completedRequirements.contains(requirement)) {
                            _completedRequirements.add(requirement);
                          }
                        });
                      },
                      onRequirementUncompleted: (requirement) {
                        setState(() {
                          _completedRequirements.remove(requirement);
                        });
                      },
                    ),
                    SizedBox(height: 24.h),

                    // Document Upload Section
                    _buildDocumentUploadSection(),
                    SizedBox(height: 24.h),

                    // Appointment Booking
                    AppointmentBookingSection(
                      selectedDate: _selectedAppointmentDate,
                      selectedTime: _selectedAppointmentTime,
                      selectedOffice: _selectedOfficeLocation,
                      onDateSelected: (date) {
                        setState(() {
                          _selectedAppointmentDate = date;
                        });
                      },
                      onTimeSelected: (time) {
                        setState(() {
                          _selectedAppointmentTime = time;
                        });
                      },
                      onOfficeSelected: (office) {
                        setState(() {
                          _selectedOfficeLocation = office;
                        });
                      },
                    ),
                    SizedBox(height: 24.h),

                    // License Fee Display
                    LicenseFeeDisplay(licenseType: _selectedLicenseType!),
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
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _canSubmitApplication() && currentUser != null
                        ? () => _submitLicenseApplication(currentUser.id)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      minimumSize: Size(double.infinity, 50.h),
                    ),
                    child: applicationState.isLoading
                        ? SizedBox(
                            width: 20.w,
                            height: 20.w,
                            child: const CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            'Submit License Application',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
          // Loading overlay
          if (applicationState.isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
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
          Row(
            children: [
              Icon(Icons.credit_card, color: Colors.white, size: 28.w),
              SizedBox(width: 12.w),
              Text(
                'Driving License Application',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            'Apply for a new driving license or renew your existing one through LATRA',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Personal Information',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _fullNameController,
          decoration: InputDecoration(
            labelText: 'Full Name',
            hintText: 'Enter your full name as per National ID',
            prefixIcon: const Icon(Icons.person),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Full name is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _nationalIdController,
          keyboardType: TextInputType.text,
          decoration: InputDecoration(
            labelText: 'National ID Number',
            hintText: 'Enter your National ID number',
            prefixIcon: const Icon(Icons.badge),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'National ID is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Phone Number',
            hintText: 'Enter your phone number',
            prefixIcon: const Icon(Icons.phone),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Phone number is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _addressController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: 'Address',
            hintText: 'Enter your residential address',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Address is required';
            }
            return null;
          },
        ),
        SizedBox(height: 16.h),
        TextFormField(
          controller: _emergencyContactController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Emergency Contact',
            hintText: 'Enter emergency contact number',
            prefixIcon: const Icon(Icons.emergency),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide(color: AppColors.primary),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Emergency contact is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDocumentUploadSection() {
    final requiredDocuments = _getRequiredDocuments();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Required Documents',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Upload all required documents for your license application',
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 16.h),

        ...requiredDocuments.map(
          (document) => _buildDocumentUploadItem(document),
        ),
      ],
    );
  }

  Widget _buildDocumentUploadItem(String document) {
    final isUploaded = _uploadedDocuments.contains(document);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isUploaded ? AppColors.success.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isUploaded ? AppColors.success : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isUploaded ? Icons.check_circle : Icons.upload_file,
            color: isUploaded ? AppColors.success : AppColors.primary,
            size: 24.w,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              document,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (!isUploaded)
            ElevatedButton(
              onPressed: () => _uploadDocument(document),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: Text('Upload', style: TextStyle(fontSize: 12.sp)),
            ),
        ],
      ),
    );
  }

  List<String> _getRequiredDocuments() {
    if (_selectedLicenseType == null) return [];

    switch (_selectedLicenseType!) {
      case LicenseType.learnerPermit:
        return ['National ID', 'Medical Certificate', 'Passport Photo'];
      case LicenseType.classA:
      case LicenseType.classB:
      case LicenseType.classC:
        return [
          'National ID',
          'Medical Certificate',
          'Passport Photo',
          'Learner Permit',
        ];
      case LicenseType.motorcycle:
        return ['National ID', 'Medical Certificate', 'Passport Photo'];
      case LicenseType.commercial:
        return [
          'National ID',
          'Medical Certificate',
          'Passport Photo',
          'Experience Certificate',
        ];
    }
  }

  void _uploadDocument(String document) {
    // Simulate document upload
    setState(() {
      _uploadedDocuments.add(document);
    });

    _showSuccessSnackBar('$document uploaded successfully');
  }

  bool _canSubmitApplication() {
    if (_selectedLicenseType == null) return false;
    if (_fullNameController.text.isEmpty) return false;
    if (_nationalIdController.text.isEmpty) return false;
    if (_phoneController.text.isEmpty) return false;
    if (_addressController.text.isEmpty) return false;
    if (_emergencyContactController.text.isEmpty) return false;
    if (_selectedAppointmentDate == null) return false;
    if (_selectedAppointmentTime == null) return false;
    if (_selectedOfficeLocation == null) return false;

    final requiredDocuments = _getRequiredDocuments();
    return requiredDocuments.every((doc) => _uploadedDocuments.contains(doc));
  }

  Future<void> _submitLicenseApplication(String userId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final formData = {
      'licenseType': _selectedLicenseType!.name,
      'fullName': _fullNameController.text,
      'nationalId': _nationalIdController.text,
      'phone': _phoneController.text,
      'address': _addressController.text,
      'emergencyContact': _emergencyContactController.text,
      'appointmentDate': _selectedAppointmentDate!.toIso8601String(),
      'appointmentTime':
          '${_selectedAppointmentTime!.hour}:${_selectedAppointmentTime!.minute}',
      'officeLocation': _selectedOfficeLocation!,
      'uploadedDocuments': _uploadedDocuments,
      'completedRequirements': _completedRequirements,
    };

    final success = await ref
        .read(latraApplicationNotifierProvider.notifier)
        .registerWithLATRA(
          userId: userId,
          vehicleId: '', // Not applicable for license applications
          type: LATRAApplicationType.licenseRenewal, // Use appropriate type
          formData: formData,
          description:
              'Driving License Application - ${_selectedLicenseType!.displayName}',
          autoSubmit: true,
        );

    if (success) {
      _showSuccessSnackBar('License application submitted successfully!');
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

/// License types enumeration
enum LicenseType {
  learnerPermit,
  classA,
  classB,
  classC,
  motorcycle,
  commercial;

  String get displayName {
    switch (this) {
      case LicenseType.learnerPermit:
        return 'Learner Permit';
      case LicenseType.classA:
        return 'Class A License';
      case LicenseType.classB:
        return 'Class B License';
      case LicenseType.classC:
        return 'Class C License';
      case LicenseType.motorcycle:
        return 'Motorcycle License';
      case LicenseType.commercial:
        return 'Commercial License';
    }
  }

  String get description {
    switch (this) {
      case LicenseType.learnerPermit:
        return 'Temporary permit for learning to drive';
      case LicenseType.classA:
        return 'Heavy vehicles and trucks';
      case LicenseType.classB:
        return 'Light vehicles and cars';
      case LicenseType.classC:
        return 'Motorcycles and scooters';
      case LicenseType.motorcycle:
        return 'Motorcycles only';
      case LicenseType.commercial:
        return 'Commercial vehicles';
    }
  }
}
