// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preferences_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserPreferencesModel _$UserPreferencesModelFromJson(
        Map<String, dynamic> json) =>
    UserPreferencesModel(
      userId: json['userId'] as String,
      language: json['language'] as String? ?? 'en',
      currency: json['currency'] as String? ?? 'TZS',
      notificationsEnabled: json['notificationsEnabled'] as bool? ?? true,
      emailNotifications: json['emailNotifications'] as bool? ?? true,
      smsNotifications: json['smsNotifications'] as bool? ?? true,
      pushNotifications: json['pushNotifications'] as bool? ?? true,
      marketingEmails: json['marketingEmails'] as bool? ?? false,
      orderUpdates: json['orderUpdates'] as bool? ?? true,
      promotionalOffers: json['promotionalOffers'] as bool? ?? true,
      expertRecommendations: json['expertRecommendations'] as bool? ?? true,
      theme: json['theme'] as String? ?? 'system',
      biometricAuth: json['biometricAuth'] as bool? ?? false,
      autoBackup: json['autoBackup'] as bool? ?? true,
      favoriteCategories: (json['favoriteCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      preferredBrands: (json['preferredBrands'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      defaultAddressId: json['defaultAddressId'] as String? ?? '',
      defaultPaymentMethodId: json['defaultPaymentMethodId'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$UserPreferencesModelToJson(
        UserPreferencesModel instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'language': instance.language,
      'currency': instance.currency,
      'notificationsEnabled': instance.notificationsEnabled,
      'emailNotifications': instance.emailNotifications,
      'smsNotifications': instance.smsNotifications,
      'pushNotifications': instance.pushNotifications,
      'marketingEmails': instance.marketingEmails,
      'orderUpdates': instance.orderUpdates,
      'promotionalOffers': instance.promotionalOffers,
      'expertRecommendations': instance.expertRecommendations,
      'theme': instance.theme,
      'biometricAuth': instance.biometricAuth,
      'autoBackup': instance.autoBackup,
      'favoriteCategories': instance.favoriteCategories,
      'preferredBrands': instance.preferredBrands,
      'defaultAddressId': instance.defaultAddressId,
      'defaultPaymentMethodId': instance.defaultPaymentMethodId,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
