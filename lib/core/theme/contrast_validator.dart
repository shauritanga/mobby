import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Utility class to validate contrast ratios for accessibility compliance
class ContrastValidator {
  /// Calculate the contrast ratio between two colors
  /// Returns a value between 1:1 (no contrast) and 21:1 (maximum contrast)
  static double calculateContrastRatio(Color foreground, Color background) {
    final double foregroundLuminance = _calculateLuminance(foreground);
    final double backgroundLuminance = _calculateLuminance(background);
    
    final double lighter = math.max(foregroundLuminance, backgroundLuminance);
    final double darker = math.min(foregroundLuminance, backgroundLuminance);
    
    return (lighter + 0.05) / (darker + 0.05);
  }
  
  /// Calculate the relative luminance of a color
  static double _calculateLuminance(Color color) {
    final double r = _linearizeColorComponent(color.red / 255.0);
    final double g = _linearizeColorComponent(color.green / 255.0);
    final double b = _linearizeColorComponent(color.blue / 255.0);
    
    return 0.2126 * r + 0.7152 * g + 0.0722 * b;
  }
  
  /// Linearize a color component for luminance calculation
  static double _linearizeColorComponent(double component) {
    if (component <= 0.03928) {
      return component / 12.92;
    } else {
      return math.pow((component + 0.055) / 1.055, 2.4).toDouble();
    }
  }
  
  /// Check if contrast ratio meets WCAG AA standards
  static bool meetsWCAG_AA(Color foreground, Color background, {bool isLargeText = false}) {
    final double ratio = calculateContrastRatio(foreground, background);
    return isLargeText ? ratio >= 3.0 : ratio >= 4.5;
  }
  
  /// Check if contrast ratio meets WCAG AAA standards
  static bool meetsWCAG_AAA(Color foreground, Color background, {bool isLargeText = false}) {
    final double ratio = calculateContrastRatio(foreground, background);
    return isLargeText ? ratio >= 4.5 : ratio >= 7.0;
  }
  
  /// Get a readable description of the contrast level
  static String getContrastDescription(double ratio) {
    if (ratio >= 7.0) return 'Excellent (AAA)';
    if (ratio >= 4.5) return 'Good (AA)';
    if (ratio >= 3.0) return 'Fair (AA Large)';
    return 'Poor (Fails WCAG)';
  }
  
  /// Validate theme colors and return a report
  static Map<String, dynamic> validateTheme(ThemeData theme) {
    final ColorScheme colorScheme = theme.colorScheme;
    final Map<String, dynamic> report = {};
    
    // Test primary combinations
    report['primary_on_surface'] = {
      'ratio': calculateContrastRatio(colorScheme.primary, colorScheme.surface),
      'description': getContrastDescription(
        calculateContrastRatio(colorScheme.primary, colorScheme.surface)
      ),
      'wcag_aa': meetsWCAG_AA(colorScheme.primary, colorScheme.surface),
      'wcag_aaa': meetsWCAG_AAA(colorScheme.primary, colorScheme.surface),
    };
    
    // Test text combinations
    report['on_surface_surface'] = {
      'ratio': calculateContrastRatio(colorScheme.onSurface, colorScheme.surface),
      'description': getContrastDescription(
        calculateContrastRatio(colorScheme.onSurface, colorScheme.surface)
      ),
      'wcag_aa': meetsWCAG_AA(colorScheme.onSurface, colorScheme.surface),
      'wcag_aaa': meetsWCAG_AAA(colorScheme.onSurface, colorScheme.surface),
    };
    
    // Test primary button text
    report['on_primary_primary'] = {
      'ratio': calculateContrastRatio(colorScheme.onPrimary, colorScheme.primary),
      'description': getContrastDescription(
        calculateContrastRatio(colorScheme.onPrimary, colorScheme.primary)
      ),
      'wcag_aa': meetsWCAG_AA(colorScheme.onPrimary, colorScheme.primary),
      'wcag_aaa': meetsWCAG_AAA(colorScheme.onPrimary, colorScheme.primary),
    };
    
    // Test surface variants
    report['surface_variant_contrast'] = {
      'ratio': calculateContrastRatio(colorScheme.surfaceVariant, colorScheme.surface),
      'description': getContrastDescription(
        calculateContrastRatio(colorScheme.surfaceVariant, colorScheme.surface)
      ),
      'subtle_differentiation': calculateContrastRatio(colorScheme.surfaceVariant, colorScheme.surface) > 1.1,
    };
    
    return report;
  }
  
  /// Print a formatted contrast report to debug console
  static void printContrastReport(ThemeData theme, {String? themeName}) {
    final report = validateTheme(theme);
    
    print('\n🎨 CONTRAST VALIDATION REPORT ${themeName != null ? "($themeName)" : ""}');
    print('=' * 50);
    
    report.forEach((key, value) {
      print('\n📊 $key:');
      print('   Ratio: ${value['ratio'].toStringAsFixed(2)}:1');
      print('   Level: ${value['description']}');
      if (value.containsKey('wcag_aa')) {
        print('   WCAG AA: ${value['wcag_aa'] ? "✅ Pass" : "❌ Fail"}');
        print('   WCAG AAA: ${value['wcag_aaa'] ? "✅ Pass" : "❌ Fail"}');
      }
      if (value.containsKey('subtle_differentiation')) {
        print('   Subtle Diff: ${value['subtle_differentiation'] ? "✅ Good" : "❌ Too Similar"}');
      }
    });
    
    print('\n' + '=' * 50);
  }
  
  /// Widget to display contrast information in debug mode
  static Widget buildContrastDebugWidget(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Contrast Debug Info',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          _buildContrastRow(
            'Text on Surface',
            theme.colorScheme.onSurface,
            theme.colorScheme.surface,
            theme.textTheme.bodySmall,
          ),
          _buildContrastRow(
            'Primary on Surface',
            theme.colorScheme.primary,
            theme.colorScheme.surface,
            theme.textTheme.bodySmall,
          ),
          _buildContrastRow(
            'Primary Button Text',
            theme.colorScheme.onPrimary,
            theme.colorScheme.primary,
            theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
  
  static Widget _buildContrastRow(
    String label,
    Color foreground,
    Color background,
    TextStyle? style,
  ) {
    final ratio = calculateContrastRatio(foreground, background);
    final description = getContrastDescription(ratio);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: style),
          ),
          Text(
            '${ratio.toStringAsFixed(1)}:1 ($description)',
            style: style?.copyWith(
              color: ratio >= 4.5 ? Colors.green : Colors.orange,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
