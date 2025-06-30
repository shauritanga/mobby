/// App constants for consistent values across the application
class AppConstants {
  // Padding and spacing
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double extraLargePadding = 32.0;

  // Border radius
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);

  // API endpoints
  static const String baseUrl = 'https://api.mobby.app';
  static const String latraApiUrl = 'https://latra.go.tz/api';

  // File upload limits
  static const int maxFileSize = 10 * 1024 * 1024; // 10MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];
  static const List<String> allowedDocumentTypes = ['pdf', 'doc', 'docx'];

  // Validation
  static const int minPasswordLength = 8;
  static const int maxNameLength = 50;
  static const int maxDescriptionLength = 500;

  // Currency
  static const String currency = 'TZS';
  static const String currencySymbol = 'TSh';

  // Date formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  // LATRA specific constants
  static const String latraApplicationPrefix = 'LATRA-';
  static const int latraApplicationNumberLength = 12;
  static const List<String> latraOfficeLocations = [
    'Dar es Salaam - Headquarters',
    'Arusha Regional Office',
    'Mwanza Regional Office',
    'Dodoma Regional Office',
    'Mbeya Regional Office',
  ];

  // Vehicle types
  static const List<String> vehicleTypes = [
    'Car',
    'Motorcycle',
    'Truck',
    'Bus',
    'Trailer',
  ];

  // License types
  static const List<String> licenseTypes = [
    'Learner Permit',
    'Class A License',
    'Class B License',
    'Class C License',
    'Motorcycle License',
    'Commercial License',
  ];

  // Error messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unknownError = 'An unknown error occurred.';
  static const String validationError = 'Please check your input and try again.';

  // Success messages
  static const String applicationSubmitted = 'Application submitted successfully!';
  static const String documentUploaded = 'Document uploaded successfully!';
  static const String profileUpdated = 'Profile updated successfully!';
}
