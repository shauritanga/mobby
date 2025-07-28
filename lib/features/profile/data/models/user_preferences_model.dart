import '../../domain/entities/user_preferences.dart';

/// User preferences model for data layer
/// Following Firebase integration pattern as specified in FEATURES_DOCUMENTATION.md
class UserPreferencesModel extends UserPreferences {
  const UserPreferencesModel({
    required super.userId,
    super.language,
    super.currency,
    super.notificationsEnabled,
    super.emailNotifications,
    super.smsNotifications,
    super.pushNotifications,
    super.marketingEmails,
    super.orderUpdates,
    super.promotionalOffers,
    super.expertRecommendations,
    super.theme,
    super.biometricAuth,
    super.autoBackup,
    super.favoriteCategories,
    super.preferredBrands,
    super.defaultAddressId,
    super.defaultPaymentMethodId,
    required super.createdAt,
    super.updatedAt,
  });

  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      userId: json['userId'] ?? '',
      language: json['language'] ?? 'en',
      currency: json['currency'] ?? 'TZS',
      notificationsEnabled: json['notificationsEnabled'] ?? true,
      emailNotifications: json['emailNotifications'] ?? true,
      smsNotifications: json['smsNotifications'] ?? true,
      pushNotifications: json['pushNotifications'] ?? true,
      marketingEmails: json['marketingEmails'] ?? false,
      orderUpdates: json['orderUpdates'] ?? true,
      promotionalOffers: json['promotionalOffers'] ?? true,
      expertRecommendations: json['expertRecommendations'] ?? true,
      theme: json['theme'] ?? 'system',
      biometricAuth: json['biometricAuth'] ?? false,
      autoBackup: json['autoBackup'] ?? true,
      favoriteCategories: List<String>.from(json['favoriteCategories'] ?? []),
      preferredBrands: List<String>.from(json['preferredBrands'] ?? []),
      defaultAddressId: json['defaultAddressId'] ?? '',
      defaultPaymentMethodId: json['defaultPaymentMethodId'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'language': language,
      'currency': currency,
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'pushNotifications': pushNotifications,
      'marketingEmails': marketingEmails,
      'orderUpdates': orderUpdates,
      'promotionalOffers': promotionalOffers,
      'expertRecommendations': expertRecommendations,
      'theme': theme,
      'biometricAuth': biometricAuth,
      'autoBackup': autoBackup,
      'favoriteCategories': favoriteCategories,
      'preferredBrands': preferredBrands,
      'defaultAddressId': defaultAddressId,
      'defaultPaymentMethodId': defaultPaymentMethodId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory UserPreferencesModel.fromEntity(UserPreferences preferences) {
    return UserPreferencesModel(
      userId: preferences.userId,
      language: preferences.language,
      currency: preferences.currency,
      notificationsEnabled: preferences.notificationsEnabled,
      emailNotifications: preferences.emailNotifications,
      smsNotifications: preferences.smsNotifications,
      pushNotifications: preferences.pushNotifications,
      marketingEmails: preferences.marketingEmails,
      orderUpdates: preferences.orderUpdates,
      promotionalOffers: preferences.promotionalOffers,
      expertRecommendations: preferences.expertRecommendations,
      theme: preferences.theme,
      biometricAuth: preferences.biometricAuth,
      autoBackup: preferences.autoBackup,
      favoriteCategories: preferences.favoriteCategories,
      preferredBrands: preferences.preferredBrands,
      defaultAddressId: preferences.defaultAddressId,
      defaultPaymentMethodId: preferences.defaultPaymentMethodId,
      createdAt: preferences.createdAt,
      updatedAt: preferences.updatedAt,
    );
  }

  UserPreferences toEntity() {
    return UserPreferences(
      userId: userId,
      language: language,
      currency: currency,
      notificationsEnabled: notificationsEnabled,
      emailNotifications: emailNotifications,
      smsNotifications: smsNotifications,
      pushNotifications: pushNotifications,
      marketingEmails: marketingEmails,
      orderUpdates: orderUpdates,
      promotionalOffers: promotionalOffers,
      expertRecommendations: expertRecommendations,
      theme: theme,
      biometricAuth: biometricAuth,
      autoBackup: autoBackup,
      favoriteCategories: favoriteCategories,
      preferredBrands: preferredBrands,
      defaultAddressId: defaultAddressId,
      defaultPaymentMethodId: defaultPaymentMethodId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Firebase specific factory
  factory UserPreferencesModel.fromFirestore(
    Map<String, dynamic> data,
    String userId,
  ) {
    return UserPreferencesModel(
      userId: userId,
      language: data['language'] ?? 'en',
      currency: data['currency'] ?? 'TZS',
      notificationsEnabled: data['notificationsEnabled'] ?? true,
      emailNotifications: data['emailNotifications'] ?? true,
      smsNotifications: data['smsNotifications'] ?? true,
      pushNotifications: data['pushNotifications'] ?? true,
      marketingEmails: data['marketingEmails'] ?? false,
      orderUpdates: data['orderUpdates'] ?? true,
      promotionalOffers: data['promotionalOffers'] ?? true,
      expertRecommendations: data['expertRecommendations'] ?? true,
      theme: data['theme'] ?? 'system',
      biometricAuth: data['biometricAuth'] ?? false,
      autoBackup: data['autoBackup'] ?? true,
      favoriteCategories: List<String>.from(data['favoriteCategories'] ?? []),
      preferredBrands: List<String>.from(data['preferredBrands'] ?? []),
      defaultAddressId: data['defaultAddressId'] ?? '',
      defaultPaymentMethodId: data['defaultPaymentMethodId'] ?? '',
      createdAt: data['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: data['updatedAt']?.toDate(),
    );
  }

  // Convert to Firestore format
  Map<String, dynamic> toFirestore() {
    return {
      'language': language,
      'currency': currency,
      'notificationsEnabled': notificationsEnabled,
      'emailNotifications': emailNotifications,
      'smsNotifications': smsNotifications,
      'pushNotifications': pushNotifications,
      'marketingEmails': marketingEmails,
      'orderUpdates': orderUpdates,
      'promotionalOffers': promotionalOffers,
      'expertRecommendations': expertRecommendations,
      'theme': theme,
      'biometricAuth': biometricAuth,
      'autoBackup': autoBackup,
      'favoriteCategories': favoriteCategories,
      'preferredBrands': preferredBrands,
      'defaultAddressId': defaultAddressId,
      'defaultPaymentMethodId': defaultPaymentMethodId,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }
}
