import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/vehicle.dart';

/// Vehicle form fields widget for vehicle registration forms
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class VehicleFormFields {
  static Widget makeField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged != null ? (_) => onChanged() : null,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Vehicle Make *',
        hintText: 'e.g., Toyota, Honda, BMW',
        prefixIcon: const Icon(Icons.directions_car),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  static Widget modelField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged != null ? (_) => onChanged() : null,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Vehicle Model *',
        hintText: 'e.g., Camry, Civic, X5',
        prefixIcon: const Icon(Icons.car_rental),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  static Widget yearField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged != null ? (_) => onChanged() : null,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      decoration: InputDecoration(
        labelText: 'Year *',
        hintText: 'e.g., 2020',
        prefixIcon: const Icon(Icons.calendar_today),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  static Widget colorField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged != null ? (_) => onChanged() : null,
      textCapitalization: TextCapitalization.words,
      decoration: InputDecoration(
        labelText: 'Color *',
        hintText: 'e.g., White, Black, Red',
        prefixIcon: const Icon(Icons.palette),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  static Widget plateNumberField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: 'Plate Number *',
        hintText: 'e.g., T123ABC',
        prefixIcon: const Icon(Icons.confirmation_number),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  static Widget engineNumberField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged != null ? (_) => onChanged() : null,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: 'Engine Number *',
        hintText: 'Engine identification number',
        prefixIcon: const Icon(Icons.settings),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  static Widget chassisNumberField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged != null ? (_) => onChanged() : null,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: 'Chassis Number *',
        hintText: 'Chassis identification number',
        prefixIcon: const Icon(Icons.build),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  static Widget vinField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged != null ? (_) => onChanged() : null,
      textCapitalization: TextCapitalization.characters,
      maxLength: 17,
      decoration: InputDecoration(
        labelText: 'VIN (Optional)',
        hintText: '17-character Vehicle Identification Number',
        prefixIcon: const Icon(Icons.fingerprint),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
        counterText: '',
      ),
    );
  }

  static Widget registrationNumberField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged != null ? (_) => onChanged() : null,
      textCapitalization: TextCapitalization.characters,
      decoration: InputDecoration(
        labelText: 'Registration Number (Optional)',
        hintText: 'Official registration number',
        prefixIcon: const Icon(Icons.assignment),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  static Widget mileageField({
    required TextEditingController controller,
    String? Function(String?)? validator,
    VoidCallback? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      onChanged: onChanged != null ? (_) => onChanged() : null,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        labelText: 'Mileage (Optional)',
        hintText: 'Current mileage in kilometers',
        prefixIcon: const Icon(Icons.speed),
        suffixText: 'km',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }

  static Widget vehicleTypeDropdown({
    required VehicleType value,
    required void Function(VehicleType?) onChanged,
  }) {
    return DropdownButtonFormField<VehicleType>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Vehicle Type *',
        prefixIcon: const Icon(Icons.category),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      items: VehicleType.values.map((type) {
        return DropdownMenuItem(value: type, child: Text(type.displayName));
      }).toList(),
    );
  }

  static Widget fuelTypeDropdown({
    required FuelType value,
    required void Function(FuelType?) onChanged,
  }) {
    return DropdownButtonFormField<FuelType>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Fuel Type *',
        prefixIcon: const Icon(Icons.local_gas_station),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      items: FuelType.values.map((type) {
        return DropdownMenuItem(value: type, child: Text(type.displayName));
      }).toList(),
    );
  }

  static Widget transmissionDropdown({
    required TransmissionType value,
    required void Function(TransmissionType?) onChanged,
  }) {
    return DropdownButtonFormField<TransmissionType>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Transmission *',
        prefixIcon: const Icon(Icons.settings_applications),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      items: TransmissionType.values.map((type) {
        return DropdownMenuItem(value: type, child: Text(type.displayName));
      }).toList(),
    );
  }

  static Widget statusDropdown({
    required VehicleStatus value,
    required void Function(VehicleStatus?) onChanged,
  }) {
    return DropdownButtonFormField<VehicleStatus>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: 'Vehicle Status *',
        prefixIcon: const Icon(Icons.info),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
      items: VehicleStatus.values.map((status) {
        return DropdownMenuItem(value: status, child: Text(status.displayName));
      }).toList(),
    );
  }

  static Widget dateField({
    required String label,
    required DateTime? value,
    required void Function(DateTime?) onChanged,
    bool isRequired = false,
  }) {
    return Builder(
      builder: (context) => InkWell(
        onTap: () async {
          final selectedDate = await showDatePicker(
            context: context,
            initialDate: value ?? DateTime.now(),
            firstDate: DateTime(1900),
            lastDate: DateTime(2100),
          );
          if (selectedDate != null) {
            onChanged(selectedDate);
          }
        },
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: isRequired ? '$label *' : label,
            prefixIcon: const Icon(Icons.calendar_today),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            suffixIcon: value != null
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () => onChanged(null),
                  )
                : null,
          ),
          child: Text(
            value != null
                ? '${value.day}/${value.month}/${value.year}'
                : 'Select date',
            style: TextStyle(
              color: value != null ? null : Theme.of(context).hintColor,
            ),
          ),
        ),
      ),
    );
  }
}
