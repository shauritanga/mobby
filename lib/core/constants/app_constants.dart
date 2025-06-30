class AppConstants {
  // App Info
  static const String appName = 'Mobby';
  static const String appVersion = '1.0.0';
  static const String appDescription =
      'Vehicle spare parts and accessories app';

  // API
  static const String baseUrl =
      'https://api.mobby.com'; // Replace with actual API URL
  static const int connectionTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String themeKey = 'theme_mode';
  static const String languageKey = 'language';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Image
  static const int maxImageSize = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedImageTypes = ['jpg', 'jpeg', 'png', 'webp'];

  // Validation
  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 50;
  static const int minUsernameLength = 3;
  static const int maxUsernameLength = 30;

  // Routes
  static const String splashRoute = '/';
  static const String onboardingRoute = '/onboarding';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String forgotPasswordRoute = '/forgot-password';
  static const String otpVerificationRoute = '/otp-verification';

  // Client Routes
  static const String homeRoute = '/home';
  static const String profileRoute = '/profile';
  static const String productsRoute = '/products';
  static const String cartRoute = '/home/cart';
  static const String vehiclesRoute = '/vehicles';
  static const String ordersRoute = '/profile/orders';
  static const String supportRoute = '/support';
  static const String latraRoute = '/support/latra';
  static const String latraVehicleRegistrationRoute =
      '/support/latra/vehicle-registration';
  static const String latraLicenseApplicationRoute =
      '/support/latra/license-application';
  static const String latraStatusTrackingRoute =
      '/support/latra/status-tracking';
  static const String latraDocumentsRoute = '/support/latra/documents';
  static const String insuranceRoute = '/support/insurance';
  static const String technicalAssistanceRoute =
      '/support/technical-assistance';
  static const String settingsRoute = '/profile/settings';

  // Admin Routes
  static const String adminDashboardRoute = '/admin/dashboard';
  static const String adminUsersRoute = '/admin/users';
  static const String adminProductsRoute = '/admin/products';
  static const String adminOrdersRoute = '/admin/orders';
  static const String adminSupportRoute = '/admin/support';
  static const String adminAnalyticsRoute = '/admin/analytics';
  static const String adminTicketsRoute = '/admin/support/tickets';
  static const String adminLatraRoute = '/admin/support/latra';
  static const String adminInsuranceRoute = '/admin/support/insurance';
  static const String adminReportsRoute = '/admin/analytics/reports';

  // Error Messages
  static const String networkErrorMessage =
      'Network connection error. Please check your internet connection.';
  static const String serverErrorMessage =
      'Server error. Please try again later.';
  static const String unknownErrorMessage =
      'An unknown error occurred. Please try again.';
  static const String validationErrorMessage =
      'Please check your input and try again.';
}
