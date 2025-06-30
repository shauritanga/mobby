import 'package:flutter/material.dart';

/// App color constants for Mobby application
/// Following specifications from FEATURES_DOCUMENTATION.md
class AppColors {
  // Primary brand colors
  static const Color primary = Color(0xFF1976D2); // Professional blue
  static const Color primaryLight = Color(0xFF42A5F5);
  static const Color primaryDark = Color(0xFF1565C0);
  
  // Secondary colors
  static const Color secondary = Color(0xFF388E3C); // Success green
  static const Color secondaryLight = Color(0xFF66BB6A);
  static const Color secondaryDark = Color(0xFF2E7D32);
  
  // Status colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFD32F2F);
  static const Color info = Color(0xFF2196F3);
  
  // Text colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textDisabled = Color(0xFFBDBDBD);
  
  // Background colors
  static const Color background = Color(0xFFFAFAFA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);
  
  // Border and divider colors
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFEEEEEE);
  
  // Shadow colors
  static const Color shadow = Color(0x1A000000);
  static const Color shadowLight = Color(0x0D000000);
  
  // Overlay colors
  static const Color overlay = Color(0x80000000);
  static const Color overlayLight = Color(0x40000000);
  
  // Gradient colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient successGradient = LinearGradient(
    colors: [success, secondaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  // Vehicle type colors
  static const Color carColor = Color(0xFF2196F3);
  static const Color motorcycleColor = Color(0xFFFF5722);
  static const Color truckColor = Color(0xFF795548);
  static const Color busColor = Color(0xFF9C27B0);
  static const Color vanColor = Color(0xFF607D8B);
  static const Color suvColor = Color(0xFF4CAF50);
  static const Color pickupColor = Color(0xFFFF9800);
  
  // LATRA specific colors
  static const Color latraPrimary = Color(0xFF1976D2);
  static const Color latraSecondary = Color(0xFF388E3C);
  static const Color latraWarning = Color(0xFFFF9800);
  static const Color latraError = Color(0xFFD32F2F);
  
  // Status indicator colors
  static const Color statusPending = Color(0xFFFF9800);
  static const Color statusApproved = Color(0xFF4CAF50);
  static const Color statusRejected = Color(0xFFD32F2F);
  static const Color statusDraft = Color(0xFF9E9E9E);
  static const Color statusUnderReview = Color(0xFF2196F3);
  
  // Document status colors
  static const Color documentVerified = Color(0xFF4CAF50);
  static const Color documentPending = Color(0xFFFF9800);
  static const Color documentRejected = Color(0xFFD32F2F);
  static const Color documentExpired = Color(0xFF757575);
  
  // Helper methods
  static Color getVehicleTypeColor(String vehicleType) {
    switch (vehicleType.toLowerCase()) {
      case 'car':
        return carColor;
      case 'motorcycle':
        return motorcycleColor;
      case 'truck':
        return truckColor;
      case 'bus':
        return busColor;
      case 'van':
        return vanColor;
      case 'suv':
        return suvColor;
      case 'pickup':
        return pickupColor;
      default:
        return primary;
    }
  }
  
  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return statusPending;
      case 'approved':
        return statusApproved;
      case 'rejected':
        return statusRejected;
      case 'draft':
        return statusDraft;
      case 'under_review':
      case 'underreview':
        return statusUnderReview;
      default:
        return textSecondary;
    }
  }
  
  static Color getDocumentStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return documentVerified;
      case 'pending':
        return documentPending;
      case 'rejected':
        return documentRejected;
      case 'expired':
        return documentExpired;
      default:
        return textSecondary;
    }
  }
}
