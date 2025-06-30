import 'package:equatable/equatable.dart';

/// User preferences entity for app settings and preferences
/// Following the specifications from FEATURES_DOCUMENTATION.md
class UserPreferences extends Equatable {
  final String userId;
  final String language;
  final String currency;
  final bool notificationsEnabled;
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final bool marketingEmails;
  final bool orderUpdates;
  final bool promotionalOffers;
  final bool expertRecommendations;
  final String theme; // light, dark, system
  final bool biometricAuth;
  final bool autoBackup;
  final List<String> favoriteCategories;
  final List<String> preferredBrands;
  final String defaultAddressId;
  final String defaultPaymentMethodId;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const UserPreferences({
    required this.userId,
    this.language = 'en',
    this.currency = 'TZS',
    this.notificationsEnabled = true,
    this.emailNotifications = true,
    this.smsNotifications = true,
    this.pushNotifications = true,
    this.marketingEmails = false,
    this.orderUpdates = true,
    this.promotionalOffers = true,
    this.expertRecommendations = true,
    this.theme = 'system',
    this.biometricAuth = false,
    this.autoBackup = true,
    this.favoriteCategories = const [],
    this.preferredBrands = const [],
    this.defaultAddressId = '',
    this.defaultPaymentMethodId = '',
    required this.createdAt,
    this.updatedAt,
  });

  UserPreferences copyWith({
    String? userId,
    String? language,
    String? currency,
    bool? notificationsEnabled,
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
    bool? marketingEmails,
    bool? orderUpdates,
    bool? promotionalOffers,
    bool? expertRecommendations,
    String? theme,
    bool? biometricAuth,
    bool? autoBackup,
    List<String>? favoriteCategories,
    List<String>? preferredBrands,
    String? defaultAddressId,
    String? defaultPaymentMethodId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserPreferences(
      userId: userId ?? this.userId,
      language: language ?? this.language,
      currency: currency ?? this.currency,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      marketingEmails: marketingEmails ?? this.marketingEmails,
      orderUpdates: orderUpdates ?? this.orderUpdates,
      promotionalOffers: promotionalOffers ?? this.promotionalOffers,
      expertRecommendations: expertRecommendations ?? this.expertRecommendations,
      theme: theme ?? this.theme,
      biometricAuth: biometricAuth ?? this.biometricAuth,
      autoBackup: autoBackup ?? this.autoBackup,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      preferredBrands: preferredBrands ?? this.preferredBrands,
      defaultAddressId: defaultAddressId ?? this.defaultAddressId,
      defaultPaymentMethodId: defaultPaymentMethodId ?? this.defaultPaymentMethodId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Check if any notifications are enabled
  bool get hasNotificationsEnabled {
    return notificationsEnabled && 
           (emailNotifications || smsNotifications || pushNotifications);
  }

  /// Get notification preferences summary
  Map<String, bool> get notificationPreferences {
    return {
      'email': emailNotifications,
      'sms': smsNotifications,
      'push': pushNotifications,
      'marketing': marketingEmails,
      'orders': orderUpdates,
      'promotions': promotionalOffers,
      'expert_recommendations': expertRecommendations,
    };
  }

  @override
  List<Object?> get props => [
        userId,
        language,
        currency,
        notificationsEnabled,
        emailNotifications,
        smsNotifications,
        pushNotifications,
        marketingEmails,
        orderUpdates,
        promotionalOffers,
        expertRecommendations,
        theme,
        biometricAuth,
        autoBackup,
        favoriteCategories,
        preferredBrands,
        defaultAddressId,
        defaultPaymentMethodId,
        createdAt,
        updatedAt,
      ];
}

/// Supported languages
enum SupportedLanguage {
  english('en', 'English'),
  swahili('sw', 'Kiswahili');

  const SupportedLanguage(this.code, this.displayName);
  final String code;
  final String displayName;
}

/// Theme options
enum ThemeOption {
  light('light', 'Light'),
  dark('dark', 'Dark'),
  system('system', 'System');

  const ThemeOption(this.value, this.displayName);
  final String value;
  final String displayName;
}
