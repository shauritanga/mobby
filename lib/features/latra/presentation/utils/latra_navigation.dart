import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';

/// LATRA Navigation utility class for handling navigation to LATRA screens
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRANavigation {
  /// Navigate to LATRA main screen
  static void navigateToMain(BuildContext context) {
    context.push(AppConstants.latraRoute);
  }

  /// Navigate to vehicle registration screen
  static void navigateToVehicleRegistration(BuildContext context) {
    context.push(AppConstants.latraVehicleRegistrationRoute);
  }

  /// Navigate to license application screen
  static void navigateToLicenseApplication(BuildContext context) {
    context.push(AppConstants.latraLicenseApplicationRoute);
  }

  /// Navigate to status tracking screen
  static void navigateToStatusTracking(
    BuildContext context, {
    String? applicationId,
  }) {
    final route = applicationId != null
        ? '${AppConstants.latraStatusTrackingRoute}?applicationId=$applicationId'
        : AppConstants.latraStatusTrackingRoute;
    context.push(route);
  }

  /// Navigate to documents screen
  static void navigateToDocuments(
    BuildContext context, {
    String? applicationId,
  }) {
    final route = applicationId != null
        ? '${AppConstants.latraDocumentsRoute}?applicationId=$applicationId'
        : AppConstants.latraDocumentsRoute;
    context.push(route);
  }

  /// Navigate to specific application status tracking
  static void navigateToApplicationStatus(
    BuildContext context,
    String applicationId,
  ) {
    context.push(
      '${AppConstants.latraStatusTrackingRoute}?applicationId=$applicationId',
    );
  }

  /// Navigate to application documents
  static void navigateToApplicationDocuments(
    BuildContext context,
    String applicationId,
  ) {
    context.push(
      '${AppConstants.latraDocumentsRoute}?applicationId=$applicationId',
    );
  }

  /// Navigate back to LATRA main from any LATRA screen
  static void navigateBackToMain(BuildContext context) {
    context.go(AppConstants.latraRoute);
  }

  /// Pop current screen and return to previous
  static void goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppConstants.latraRoute);
    }
  }

  /// Check if current route is a LATRA route
  static bool isLATRARoute(String route) {
    return route.startsWith(AppConstants.latraRoute);
  }

  /// Get LATRA route name from path
  static String? getLATRARouteName(String path) {
    if (path == AppConstants.latraRoute) {
      return 'LATRA Services';
    } else if (path == AppConstants.latraVehicleRegistrationRoute) {
      return 'Vehicle Registration';
    } else if (path == AppConstants.latraLicenseApplicationRoute) {
      return 'License Application';
    } else if (path.startsWith(AppConstants.latraStatusTrackingRoute)) {
      return 'Status Tracking';
    } else if (path.startsWith(AppConstants.latraDocumentsRoute)) {
      return 'Documents';
    }
    return null;
  }

  /// Build LATRA route with query parameters
  static String buildRouteWithParams(
    String baseRoute,
    Map<String, String> params,
  ) {
    if (params.isEmpty) return baseRoute;
    
    final queryString = params.entries
        .map((entry) => '${entry.key}=${entry.value}')
        .join('&');
    
    return '$baseRoute?$queryString';
  }

  /// Extract query parameters from route
  static Map<String, String> extractQueryParams(String route) {
    final uri = Uri.parse(route);
    return uri.queryParameters;
  }

  /// Navigate with replacement (replaces current route)
  static void navigateWithReplacement(BuildContext context, String route) {
    context.pushReplacement(route);
  }

  /// Navigate and clear stack (removes all previous routes)
  static void navigateAndClearStack(BuildContext context, String route) {
    context.go(route);
  }

  /// Show LATRA screen as modal
  static Future<T?> showLATRAModal<T>(
    BuildContext context,
    Widget screen, {
    bool isScrollControlled = true,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      backgroundColor: Colors.transparent,
      builder: (context) => screen,
    );
  }

  /// Show LATRA dialog
  static Future<T?> showLATRADialog<T>(
    BuildContext context,
    Widget dialog, {
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      builder: (context) => dialog,
    );
  }

  /// Navigate to external LATRA website
  static Future<void> navigateToLATRAWebsite() async {
    // This would typically use url_launcher package
    // For now, we'll just show a placeholder
    // await launchUrl(Uri.parse('https://www.latra.go.tz'));
  }

  /// Navigate to LATRA contact information
  static Future<void> navigateToLATRAContact() async {
    // This would typically use url_launcher package for phone/email
    // For now, we'll just show a placeholder
    // await launchUrl(Uri.parse('tel:+255222110808'));
  }

  /// Get breadcrumb navigation for LATRA routes
  static List<BreadcrumbItem> getBreadcrumbs(String currentRoute) {
    final breadcrumbs = <BreadcrumbItem>[
      BreadcrumbItem(
        label: 'Support',
        route: AppConstants.supportRoute,
      ),
      BreadcrumbItem(
        label: 'LATRA',
        route: AppConstants.latraRoute,
      ),
    ];

    if (currentRoute == AppConstants.latraVehicleRegistrationRoute) {
      breadcrumbs.add(BreadcrumbItem(
        label: 'Vehicle Registration',
        route: currentRoute,
      ));
    } else if (currentRoute == AppConstants.latraLicenseApplicationRoute) {
      breadcrumbs.add(BreadcrumbItem(
        label: 'License Application',
        route: currentRoute,
      ));
    } else if (currentRoute.startsWith(AppConstants.latraStatusTrackingRoute)) {
      breadcrumbs.add(BreadcrumbItem(
        label: 'Status Tracking',
        route: currentRoute,
      ));
    } else if (currentRoute.startsWith(AppConstants.latraDocumentsRoute)) {
      breadcrumbs.add(BreadcrumbItem(
        label: 'Documents',
        route: currentRoute,
      ));
    }

    return breadcrumbs;
  }

  /// Navigate using breadcrumb
  static void navigateToBreadcrumb(BuildContext context, BreadcrumbItem item) {
    context.push(item.route);
  }
}

/// Breadcrumb item for navigation
class BreadcrumbItem {
  final String label;
  final String route;

  const BreadcrumbItem({
    required this.label,
    required this.route,
  });
}

/// LATRA Navigation Extensions
extension LATRANavigationExtension on BuildContext {
  /// Quick access to LATRA navigation methods
  void navigateToLATRAMain() => LATRANavigation.navigateToMain(this);
  
  void navigateToLATRAVehicleRegistration() => 
      LATRANavigation.navigateToVehicleRegistration(this);
  
  void navigateToLATRALicenseApplication() => 
      LATRANavigation.navigateToLicenseApplication(this);
  
  void navigateToLATRAStatusTracking({String? applicationId}) => 
      LATRANavigation.navigateToStatusTracking(this, applicationId: applicationId);
  
  void navigateToLATRADocuments({String? applicationId}) => 
      LATRANavigation.navigateToDocuments(this, applicationId: applicationId);
  
  void navigateToLATRAApplicationStatus(String applicationId) => 
      LATRANavigation.navigateToApplicationStatus(this, applicationId);
  
  void navigateToLATRAApplicationDocuments(String applicationId) => 
      LATRANavigation.navigateToApplicationDocuments(this, applicationId);
}
