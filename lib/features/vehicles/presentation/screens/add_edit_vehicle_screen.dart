import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/vehicle_providers.dart';
import '../providers/vehicle_operations_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/vehicle_form_fields.dart';
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
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Vehicle' : 'Add Vehicle'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 3, // Increased for better Material 3 compliance
        surfaceTintColor: Theme.of(context).colorScheme.surfaceTint,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _showDeleteConfirmation,
            ),
        ],
      ),
      body: currentUserAsync.when(
        data: (user) {
          if (user == null) {
            return _buildNotSignedInState();
          }
          return _buildForm(user.id);
        },
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildForm(String userId) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Vehicle Images
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

                  SizedBox(height: 24.h),

                  // Basic Information Section
                  _buildSectionHeader('Basic Information'),
                  SizedBox(height: 16.h),

                  VehicleFormFields.makeField(
                    controller: _makeController,
                    validator: (value) {
                      if (value?.trim().isEmpty == true) {
                        return 'Vehicle make is required';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  VehicleFormFields.modelField(
                    controller: _modelController,
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
                        child: VehicleFormFields.yearField(
                          controller: _yearController,
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
                        child: VehicleFormFields.colorField(
                          controller: _colorController,
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

                  VehicleFormFields.vehicleTypeDropdown(
                    value: _selectedType,
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
                        child: VehicleFormFields.fuelTypeDropdown(
                          value: _selectedFuelType,
                          onChanged: (fuelType) {
                            setState(() {
                              _selectedFuelType = fuelType!;
                            });
                          },
                        ),
                      ),
                      SizedBox(width: 16.w),
                      Expanded(
                        child: VehicleFormFields.transmissionDropdown(
                          value: _selectedTransmission,
                          onChanged: (transmission) {
                            setState(() {
                              _selectedTransmission = transmission!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 24.h),

                  // Registration Information Section
                  _buildSectionHeader('Registration Information'),
                  SizedBox(height: 16.h),

                  VehicleFormFields.plateNumberField(
                    controller: _plateNumberController,
                    validator: (value) {
                      if (value?.trim().isEmpty == true) {
                        return 'Plate number is required';
                      }
                      return null;
                    },
                    onChanged: (value) => _validatePlateNumber(value),
                  ),

                  SizedBox(height: 16.h),

                  VehicleFormFields.engineNumberField(
                    controller: _engineNumberController,
                    validator: (value) {
                      if (value?.trim().isEmpty == true) {
                        return 'Engine number is required';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  VehicleFormFields.chassisNumberField(
                    controller: _chassisNumberController,
                    validator: (value) {
                      if (value?.trim().isEmpty == true) {
                        return 'Chassis number is required';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 16.h),

                  VehicleFormFields.vinField(controller: _vinController),

                  SizedBox(height: 16.h),

                  VehicleFormFields.registrationNumberField(
                    controller: _registrationNumberController,
                  ),

                  SizedBox(height: 16.h),

                  VehicleFormFields.mileageField(
                    controller: _mileageController,
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

                  SizedBox(height: 24.h),

                  // Dates Section
                  _buildSectionHeader('Important Dates'),
                  SizedBox(height: 16.h),

                  VehicleFormFields.dateField(
                    label: 'Registration Date',
                    value: _registrationDate,
                    onChanged: (date) {
                      setState(() {
                        _registrationDate = date;
                      });
                    },
                  ),

                  SizedBox(height: 16.h),

                  VehicleFormFields.dateField(
                    label: 'Insurance Expiry',
                    value: _insuranceExpiry,
                    onChanged: (date) {
                      setState(() {
                        _insuranceExpiry = date;
                      });
                    },
                  ),

                  SizedBox(height: 16.h),

                  VehicleFormFields.dateField(
                    label: 'Inspection Expiry',
                    value: _inspectionExpiry,
                    onChanged: (date) {
                      setState(() {
                        _inspectionExpiry = date;
                      });
                    },
                  ),

                  if (_isEditing) ...[
                    SizedBox(height: 24.h),

                    // Status Section
                    _buildSectionHeader('Vehicle Status'),
                    SizedBox(height: 16.h),

                    VehicleFormFields.statusDropdown(
                      value: _selectedStatus,
                      onChanged: (status) {
                        setState(() {
                          _selectedStatus = status!;
                        });
                      },
                    ),
                  ],

                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),

          // Save Button
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : () => _saveVehicle(userId),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: _isLoading
                    ? SizedBox(
                        width: 20.w,
                        height: 20.w,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Text(_isEditing ? 'Update Vehicle' : 'Add Vehicle'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: Theme.of(context).textTheme.titleMedium?.color,
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(String error) {
    return Center(
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
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildNotSignedInState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_car,
            size: 100.sp,
            color: Theme.of(context).hintColor,
          ),
          SizedBox(height: 24.h),
          Text(
            'Not Signed In',
            style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Text(
            'Please sign in to add vehicles',
            style: TextStyle(
              fontSize: 16.sp,
              color: Theme.of(context).hintColor,
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => context.go('/auth/login'),
            child: const Text('Sign In'),
          ),
        ],
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
            style: TextButton.styleFrom(foregroundColor: Colors.red),
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
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
