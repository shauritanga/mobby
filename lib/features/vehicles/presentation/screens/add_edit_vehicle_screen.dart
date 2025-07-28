import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/vehicle_providers.dart';
import '../providers/vehicle_operations_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

import '../widgets/vehicle_image_picker.dart';
import '../../domain/entities/vehicle.dart';
import '../../domain/usecases/manage_vehicles_usecase.dart';

/// Add/Edit Vehicle Screen
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
/// Implement vehicle registration and editing screen with form validation and image upload
class AddEditVehicleScreen extends ConsumerStatefulWidget {
  final String? vehicleId;

  const AddEditVehicleScreen({super.key, this.vehicleId});

  @override
  ConsumerState<AddEditVehicleScreen> createState() =>
      _AddEditVehicleScreenState();
}

class _AddEditVehicleScreenState extends ConsumerState<AddEditVehicleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _makeController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController();
  final _colorController = TextEditingController();
  final _plateNumberController = TextEditingController();
  final _engineNumberController = TextEditingController();
  final _chassisNumberController = TextEditingController();
  final _vinController = TextEditingController();
  final _registrationNumberController = TextEditingController();
  final _mileageController = TextEditingController();

  VehicleType _selectedType = VehicleType.car;
  FuelType _selectedFuelType = FuelType.petrol;
  TransmissionType _selectedTransmission = TransmissionType.manual;
  VehicleStatus _selectedStatus = VehicleStatus.active;
  DateTime? _registrationDate;
  DateTime? _insuranceExpiry;
  DateTime? _inspectionExpiry;
  List<String> _imageUrls = [];
  String? _selectedImagePath;
  bool _isLoading = false;

  bool get _isEditing => widget.vehicleId != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadVehicleData();
    }
  }

  @override
  void dispose() {
    _makeController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _colorController.dispose();
    _plateNumberController.dispose();
    _engineNumberController.dispose();
    _chassisNumberController.dispose();
    _vinController.dispose();
    _registrationNumberController.dispose();
    _mileageController.dispose();
    super.dispose();
  }

  void _loadVehicleData() {
    if (widget.vehicleId != null) {
      ref.listen(vehicleByIdProvider(widget.vehicleId!), (previous, next) {
        next.when(
          data: (vehicle) {
            if (vehicle != null) {
              _populateForm(vehicle);
            }
          },
          loading: () {},
          error: (error, stack) {
            _showErrorSnackBar('Failed to load vehicle data: $error');
          },
        );
      });
    }
  }

  void _populateForm(Vehicle vehicle) {
    setState(() {
      _makeController.text = vehicle.make;
      _modelController.text = vehicle.model;
      _yearController.text = vehicle.year.toString();
      _colorController.text = vehicle.color;
      _plateNumberController.text = vehicle.plateNumber;
      _engineNumberController.text = vehicle.engineNumber;
      _chassisNumberController.text = vehicle.chassisNumber;
      _vinController.text = vehicle.vin ?? '';
      _registrationNumberController.text = vehicle.registrationNumber ?? '';
      _mileageController.text = vehicle.mileage?.toString() ?? '';
      _selectedType = vehicle.type;
      _selectedFuelType = vehicle.fuelType;
      _selectedTransmission = vehicle.transmission;
      _selectedStatus = vehicle.status;
      _registrationDate = vehicle.registrationDate;
      _insuranceExpiry = vehicle.insuranceExpiry;
      _inspectionExpiry = vehicle.inspectionExpiry;
      _imageUrls = List.from(vehicle.imageUrls);
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: _buildCleanAppBar(context),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return _buildNotSignedInState();
          }
          return _buildCleanForm(user.id);
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  PreferredSizeWidget _buildCleanAppBar(BuildContext context) {
    return AppBar(
      title: Text(_isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
      actions: [
        if (_isEditing)
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: _showDeleteConfirmation,
            tooltip: 'Delete Vehicle',
          ),
      ],
    );
  }

  Widget _buildCleanForm(String userId) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Image Section
                  _buildImageSection(),

                  SizedBox(height: 32.h),

                  // Basic Information
                  _buildBasicInfoSection(),

                  SizedBox(height: 24.h),

                  // Registration Details
                  _buildRegistrationSection(),

                  SizedBox(height: 24.h),

                  // Additional Information
                  _buildAdditionalInfoSection(),

                  if (_isEditing) ...[
                    SizedBox(height: 24.h),
                    _buildStatusSection(),
                  ],

                  SizedBox(height: 100.h), // Space for floating button
                ],
              ),
            ),
          ),

          // Save Button
          _buildSaveButton(userId),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  'Vehicle Photos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'Add photos to showcase your vehicle',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: 20.h),
            VehicleImagePicker(
              imageUrls: _imageUrls,
              selectedImagePath: _selectedImagePath,
              onImageSelected: (imagePath) {
                setState(() {
                  _selectedImagePath = imagePath;
                });
              },
              onImageRemoved: (index) {
                setState(() {
                  if (index < _imageUrls.length) {
                    _imageUrls.removeAt(index);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSection(
      title: 'Basic Information',
      children: [
        _buildTextField(
          controller: _makeController,
          label: 'Vehicle Make',
          hint: 'e.g., Toyota, Honda, BMW',
          validator: (value) {
            if (value?.trim().isEmpty == true) {
              return 'Vehicle make is required';
            }
            return null;
          },
        ),

        SizedBox(height: 16.h),

        _buildTextField(
          controller: _modelController,
          label: 'Vehicle Model',
          hint: 'e.g., Camry, Civic, X5',
          validator: (value) {
            if (value?.trim().isEmpty == true) {
              return 'Vehicle model is required';
            }
            return null;
          },
        ),

        SizedBox(height: 16.h),

        Row(
          children: [
            Expanded(
              child: _buildTextField(
                controller: _yearController,
                label: 'Year',
                hint: '2024',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.trim().isEmpty == true) {
                    return 'Year is required';
                  }
                  final year = int.tryParse(value!);
                  if (year == null ||
                      year < 1900 ||
                      year > DateTime.now().year + 1) {
                    return 'Invalid year';
                  }
                  return null;
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildTextField(
                controller: _colorController,
                label: 'Color',
                hint: 'White, Black, Red',
                validator: (value) {
                  if (value?.trim().isEmpty == true) {
                    return 'Color is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        SizedBox(height: 16.h),

        _buildDropdown<VehicleType>(
          value: _selectedType,
          label: 'Vehicle Type',
          items: VehicleType.values,
          itemBuilder: (type) => type.displayName,
          onChanged: (type) {
            setState(() {
              _selectedType = type!;
            });
          },
        ),

        SizedBox(height: 16.h),

        Row(
          children: [
            Expanded(
              child: _buildDropdown<FuelType>(
                value: _selectedFuelType,
                label: 'Fuel Type',
                items: FuelType.values,
                itemBuilder: (fuel) => fuel.displayName,
                onChanged: (fuel) {
                  setState(() {
                    _selectedFuelType = fuel!;
                  });
                },
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _buildDropdown<TransmissionType>(
                value: _selectedTransmission,
                label: 'Transmission',
                items: TransmissionType.values,
                itemBuilder: (trans) => trans.displayName,
                onChanged: (trans) {
                  setState(() {
                    _selectedTransmission = trans!;
                  });
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegistrationSection() {
    return _buildSection(
      title: 'Registration Details',
      children: [
        _buildTextField(
          controller: _plateNumberController,
          label: 'Plate Number',
          hint: 'T123ABC',
          textCapitalization: TextCapitalization.characters,
          validator: (value) {
            if (value?.trim().isEmpty == true) {
              return 'Plate number is required';
            }
            return null;
          },
          onChanged: (value) => _validatePlateNumber(value),
        ),

        SizedBox(height: 16.h),

        _buildTextField(
          controller: _engineNumberController,
          label: 'Engine Number',
          hint: 'ENG123456789',
          validator: (value) {
            if (value?.trim().isEmpty == true) {
              return 'Engine number is required';
            }
            return null;
          },
        ),

        SizedBox(height: 16.h),

        _buildTextField(
          controller: _chassisNumberController,
          label: 'Chassis Number',
          hint: 'CHS123456789',
          validator: (value) {
            if (value?.trim().isEmpty == true) {
              return 'Chassis number is required';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAdditionalInfoSection() {
    return _buildSection(
      title: 'Additional Information',
      children: [
        _buildTextField(
          controller: _vinController,
          label: 'VIN (Optional)',
          hint: 'Vehicle Identification Number',
        ),

        SizedBox(height: 16.h),

        _buildTextField(
          controller: _registrationNumberController,
          label: 'Registration Number (Optional)',
          hint: 'Registration certificate number',
        ),

        SizedBox(height: 16.h),

        _buildTextField(
          controller: _mileageController,
          label: 'Mileage (Optional)',
          hint: 'Current mileage in km',
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value?.trim().isNotEmpty == true) {
              final mileage = int.tryParse(value!);
              if (mileage == null || mileage < 0) {
                return 'Invalid mileage';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildStatusSection() {
    return _buildSection(
      title: 'Vehicle Status',
      children: [
        _buildDropdown<VehicleStatus>(
          value: _selectedStatus,
          label: 'Status',
          items: VehicleStatus.values,
          itemBuilder: (status) => status.displayName,
          onChanged: (status) {
            setState(() {
              _selectedStatus = status!;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 16.h),
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 4.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(labelText: label, hintText: hint),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required String label,
    required List<T> items,
    required String Function(T) itemBuilder,
    required void Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(labelText: label),
      items: items.map((item) {
        return DropdownMenuItem<T>(value: item, child: Text(itemBuilder(item)));
      }).toList(),
    );
  }

  Widget _buildSaveButton(String userId) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 48.h,
          child: ElevatedButton(
            onPressed: _isLoading ? null : () => _saveVehicle(userId),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: _isLoading
                ? SizedBox(
                    width: 20.w,
                    height: 20.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  )
                : Text(
                    _isEditing ? 'Update Vehicle' : 'Add Vehicle',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          SizedBox(height: 16.h),
          Text(
            'Loading vehicle data...',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.sp,
              color: Theme.of(context).colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load vehicle',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.pop(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotSignedInState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.directions_car_outlined,
              size: 64.sp,
              color: Theme.of(context).colorScheme.primary,
            ),
            SizedBox(height: 16.h),
            Text(
              'Authentication Required',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Please sign in to add or edit vehicles',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton(
              onPressed: () => context.go('/auth/login'),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }

  void _validatePlateNumber(String value) {
    // TODO: Implement real-time plate number validation
  }

  Future<void> _saveVehicle(String userId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final operations = ref.read(vehicleOperationsProvider);

      // Upload image if selected
      if (_selectedImagePath != null) {
        // TODO: Upload image and get URL
        // For now, we'll add it to the list
        _imageUrls.add(_selectedImagePath!);
      }

      if (_isEditing) {
        // Update existing vehicle
        final params = UpdateVehicleParams(
          vehicleId: widget.vehicleId!,
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text),
          color: _colorController.text.trim(),
          plateNumber: _plateNumberController.text.trim(),
          engineNumber: _engineNumberController.text.trim(),
          chassisNumber: _chassisNumberController.text.trim(),
          type: _selectedType,
          fuelType: _selectedFuelType,
          transmission: _selectedTransmission,
          mileage: _mileageController.text.trim().isNotEmpty
              ? int.parse(_mileageController.text)
              : null,
          vin: _vinController.text.trim().isNotEmpty
              ? _vinController.text.trim()
              : null,
          registrationNumber:
              _registrationNumberController.text.trim().isNotEmpty
              ? _registrationNumberController.text.trim()
              : null,
          registrationDate: _registrationDate,
          insuranceExpiry: _insuranceExpiry,
          inspectionExpiry: _inspectionExpiry,
          imageUrls: _imageUrls,
          status: _selectedStatus,
        );

        await operations.updateVehicle(params);

        if (mounted) {
          _showSuccessSnackBar('Vehicle updated successfully');
          context.pop();
        }
      } else {
        // Create new vehicle
        final params = CreateVehicleParams(
          userId: userId,
          make: _makeController.text.trim(),
          model: _modelController.text.trim(),
          year: int.parse(_yearController.text),
          color: _colorController.text.trim(),
          plateNumber: _plateNumberController.text.trim(),
          engineNumber: _engineNumberController.text.trim(),
          chassisNumber: _chassisNumberController.text.trim(),
          type: _selectedType,
          fuelType: _selectedFuelType,
          transmission: _selectedTransmission,
          mileage: _mileageController.text.trim().isNotEmpty
              ? int.parse(_mileageController.text)
              : null,
          vin: _vinController.text.trim().isNotEmpty
              ? _vinController.text.trim()
              : null,
          registrationNumber:
              _registrationNumberController.text.trim().isNotEmpty
              ? _registrationNumberController.text.trim()
              : null,
          registrationDate: _registrationDate,
          insuranceExpiry: _insuranceExpiry,
          inspectionExpiry: _inspectionExpiry,
          imageUrls: _imageUrls,
        );

        await operations.createVehicle(params);

        if (mounted) {
          _showSuccessSnackBar('Vehicle added successfully');
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to save vehicle: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Vehicle'),
        content: const Text(
          'Are you sure you want to delete this vehicle? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteVehicle();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteVehicle() async {
    if (widget.vehicleId == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = ref.read(currentUserProvider).value;
      if (currentUser != null) {
        final operations = ref.read(vehicleOperationsProvider);
        await operations.deleteVehicle(widget.vehicleId!, currentUser.id);

        if (mounted) {
          _showSuccessSnackBar('Vehicle deleted successfully');
          context.pop();
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Failed to delete vehicle: $e');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onError,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}
