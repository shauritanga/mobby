import 'package:flutter/material.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppTheme {
  // Primary brand colors for Mobby
  static const Color primaryColor = Color(0xFF1976D2); // Professional blue
  static const Color secondaryColor = Color(0xFF388E3C); // Success green
  static const Color errorColor = Color(0xFFD32F2F); // Error red
  static const Color warningColor = Color(0xFFFF9800); // Warning orange
  static const Color successColor = Color(0xFF4CAF50); // Success green

  // Light theme using FlexColorScheme
  static ThemeData get lightTheme {
    return FlexThemeData.light(
      scheme: FlexScheme.blue,
      primary: primaryColor,
      secondary: secondaryColor,
      error: errorColor,
      // Optimized surface mode for better readability with blue primary
      // Level surface mode provides better contrast and readability
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 5, // Reduced blend level for better contrast and readability
      subThemesData: FlexSubThemesData(
        // Optimized blend settings for better contrast
        blendOnLevel: 5, // Reduced for better text contrast on colored surfaces
        blendOnColors: false, // Keep false for maximum readability
        useMaterial3Typography: true,
        useM2StyleDividerInM3: false,
        // Interaction effects for better Material 3 feel
        interactionEffects: true,
        tintedDisabledControls: true,
        // Enhanced contrast settings for better readability
        // Global border radius for consistent design
        defaultRadius: 12.r,
        // Button styling
        elevatedButtonRadius: 12.r,
        elevatedButtonElevation: 1, // Reduced for M3 style
        elevatedButtonSchemeColor: SchemeColor.primary,
        // Input decoration with proper surface treatment
        inputDecoratorRadius: 12.r,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorUnfocusedHasBorder: true,
        inputDecoratorBorderWidth: 1.0,
        inputDecoratorFocusedBorderWidth: 2.0,
        inputDecoratorSchemeColor: SchemeColor.primary,
        // Card styling optimized for surface hierarchy
        cardRadius: 16.r,
        cardElevation: 1, // Material 3 style elevation
        // Navigation components with proper surface treatment
        navigationBarHeight: 70.h,
        navigationBarLabelBehavior:
            NavigationDestinationLabelBehavior.onlyShowSelected,
        navigationBarIndicatorSchemeColor: SchemeColor.secondaryContainer,
        navigationBarIndicatorOpacity: 1.0,
        navigationBarBackgroundSchemeColor: SchemeColor.surface,
        // Navigation rail
        navigationRailLabelType: NavigationRailLabelType.all,
        navigationRailIndicatorSchemeColor: SchemeColor.secondaryContainer,
        navigationRailIndicatorOpacity: 1.0,
        navigationRailBackgroundSchemeColor: SchemeColor.surface,
        // AppBar styling with proper surface treatment
        appBarBackgroundSchemeColor: SchemeColor.surface,
        appBarScrolledUnderElevation: 3,
        // Bottom sheet and dialog improvements
        bottomSheetBackgroundColor: SchemeColor.surface,
        bottomSheetRadius: 16.r,
        dialogBackgroundSchemeColor: SchemeColor.surface,
        dialogRadius: 16.r,
        // Snackbar improvements
        snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
        snackBarRadius: 8.r,
      ),
      // Use seeded color scheme for better Material 3 compliance
      keyColors: const FlexKeyColors(
        useKeyColors: true,
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
        keepSecondary: true,
        keepTertiary: true,
      ),
      // Use high contrast tones for better readability with blue primary
      tones: FlexTones.highContrast(Brightness.light),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      useMaterial3ErrorColors: true,
    ).copyWith(
      // Custom text theme with ScreenUtil
      textTheme: _buildTextTheme(Brightness.light),
      // Custom component themes
      appBarTheme: _buildAppBarTheme(Brightness.light),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
    );
  }

  // Dark theme using FlexColorScheme
  static ThemeData get darkTheme {
    return FlexThemeData.dark(
      scheme: FlexScheme.blue,
      primary: primaryColor,
      primaryLightRef:
          primaryColor, // Reference to light theme primary for fixed colors
      secondary: secondaryColor,
      secondaryLightRef:
          secondaryColor, // Reference to light theme secondary for fixed colors
      error: errorColor,
      // Optimized surface mode for dark theme readability
      // Level surface mode provides better contrast in dark mode
      surfaceMode: FlexSurfaceMode.levelSurfacesLowScaffold,
      blendLevel: 8, // Reduced blend level for better contrast in dark mode
      subThemesData: FlexSubThemesData(
        // Optimized blend settings for dark mode readability
        blendOnLevel: 8, // Reduced for better text contrast in dark mode
        blendOnColors: false, // Keep false for maximum readability
        useMaterial3Typography: true,
        useM2StyleDividerInM3: false, // Use M3 style dividers
        // Interaction effects for better Material 3 feel
        interactionEffects: true,
        tintedDisabledControls: true,
        // Global border radius for consistent design
        defaultRadius: 12.r,
        // Button styling
        elevatedButtonRadius: 12.r,
        elevatedButtonElevation: 1, // Reduced for M3 style
        elevatedButtonSchemeColor: SchemeColor.primary,
        // Input decoration with proper surface treatment
        inputDecoratorRadius: 12.r,
        inputDecoratorBorderType: FlexInputBorderType.outline,
        inputDecoratorUnfocusedHasBorder: true,
        inputDecoratorBorderWidth: 1.0,
        inputDecoratorFocusedBorderWidth: 2.0,
        inputDecoratorSchemeColor: SchemeColor.primary,
        // Card styling optimized for surface hierarchy
        cardRadius: 16.r,
        cardElevation: 1, // Material 3 style elevation
        // Navigation components with proper surface treatment
        navigationBarHeight: 70.h,
        navigationBarLabelBehavior:
            NavigationDestinationLabelBehavior.onlyShowSelected,
        navigationBarIndicatorSchemeColor: SchemeColor.secondaryContainer,
        navigationBarIndicatorOpacity: 1.0,
        navigationBarBackgroundSchemeColor: SchemeColor.surface,
        // Navigation rail
        navigationRailLabelType: NavigationRailLabelType.all,
        navigationRailIndicatorSchemeColor: SchemeColor.secondaryContainer,
        navigationRailIndicatorOpacity: 1.0,
        navigationRailBackgroundSchemeColor: SchemeColor.surface,
        // AppBar styling with proper surface treatment
        appBarBackgroundSchemeColor: SchemeColor.surface,
        appBarScrolledUnderElevation: 3,
        // Bottom sheet and dialog improvements
        bottomSheetBackgroundColor: SchemeColor.surface,
        bottomSheetRadius: 16.r,
        dialogBackgroundSchemeColor: SchemeColor.surface,
        dialogRadius: 16.r,
        // Snackbar improvements
        snackBarBackgroundSchemeColor: SchemeColor.inverseSurface,
        snackBarRadius: 8.r,
      ),
      // Use seeded color scheme for better Material 3 compliance
      keyColors: const FlexKeyColors(
        useKeyColors: true,
        useSecondary: true,
        useTertiary: true,
        keepPrimary: true,
        keepSecondary: true,
        keepTertiary: true,
      ),
      // Use high contrast tones for better readability in dark mode
      tones: FlexTones.highContrast(Brightness.dark),
      visualDensity: FlexColorScheme.comfortablePlatformDensity,
      useMaterial3: true,
      swapLegacyOnMaterial3: true,
      useMaterial3ErrorColors: true,
    ).copyWith(
      // Custom text theme with ScreenUtil
      textTheme: _buildTextTheme(Brightness.dark),
      // Custom component themes
      appBarTheme: _buildAppBarTheme(Brightness.dark),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      inputDecorationTheme: _buildInputDecorationTheme(),
    );
  }

  // Custom text theme with responsive sizing and enhanced contrast
  static TextTheme _buildTextTheme(Brightness brightness) {
    // Use high contrast colors for better readability
    final Color textColor = brightness == Brightness.light
        ? const Color(0xFF000000) // Pure black for light theme
        : const Color(0xFFFFFFFF); // Pure white for dark theme

    final Color secondaryTextColor = brightness == Brightness.light
        ? const Color(0xFF424242) // Dark gray for light theme
        : const Color(0xFFE0E0E0); // Light gray for dark theme

    return TextTheme(
      displayLarge: TextStyle(
        fontSize: 32.sp,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      displayMedium: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      displaySmall: TextStyle(
        fontSize: 24.sp,
        fontWeight: FontWeight.bold,
        color: textColor,
        height: 1.2,
      ),
      headlineLarge: TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      headlineMedium: TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      headlineSmall: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w600,
        color: textColor,
        height: 1.3,
      ),
      titleLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      titleMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      titleSmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      bodyLarge: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
      ),
      bodyMedium: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.normal,
        color: textColor,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.normal,
        color: secondaryTextColor,
        height: 1.5,
      ),
      labelLarge: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      labelMedium: TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        color: textColor,
        height: 1.4,
      ),
      labelSmall: TextStyle(
        fontSize: 10.sp,
        fontWeight: FontWeight.w500,
        color: secondaryTextColor,
        height: 1.4,
      ),
    );
  }

  // Custom AppBar theme
  static AppBarTheme _buildAppBarTheme(Brightness brightness) {
    return AppBarTheme(
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 1,
      toolbarHeight: 56.h,
      titleTextStyle: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600),
    );
  }

  // Custom ElevatedButton theme
  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        minimumSize: Size(120.w, 44.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 2,
        textStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
      ),
    );
  }

  // Custom InputDecoration theme
  static InputDecorationTheme _buildInputDecorationTheme() {
    return InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      labelStyle: TextStyle(fontSize: 14.sp),
      hintStyle: TextStyle(fontSize: 14.sp),
      errorStyle: TextStyle(fontSize: 12.sp),
    );
  }
}
