import '../../domain/entities/auth_token.dart';

class AuthTokenModel extends AuthToken {
  const AuthTokenModel({
    required super.accessToken,
    super.refreshToken,
    required super.expiresAt,
    super.tokenType,
  });

  factory AuthTokenModel.fromMap(Map<String, dynamic> map) {
    return AuthTokenModel(
      accessToken: map['accessToken'] as String,
      refreshToken: map['refreshToken'] as String?,
      expiresAt: DateTime.parse(map['expiresAt'] as String),
      tokenType: map['tokenType'] as String? ?? 'Bearer',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresAt': expiresAt.toIso8601String(),
      'tokenType': tokenType,
    };
  }

  // For backward compatibility
  factory AuthTokenModel.fromJson(Map<String, dynamic> json) =>
      AuthTokenModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  factory AuthTokenModel.fromEntity(AuthToken token) {
    return AuthTokenModel(
      accessToken: token.accessToken,
      refreshToken: token.refreshToken,
      expiresAt: token.expiresAt,
      tokenType: token.tokenType,
    );
  }

  AuthToken toEntity() {
    return AuthToken(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
      tokenType: tokenType,
    );
  }

  // Firebase specific factory - create from Firebase ID token
  factory AuthTokenModel.fromFirebaseToken(
    String idToken, {
    Duration? expiryDuration,
  }) {
    return AuthTokenModel(
      accessToken: idToken,
      refreshToken: null, // Firebase handles refresh automatically
      expiresAt: DateTime.now().add(expiryDuration ?? const Duration(hours: 1)),
      tokenType: 'Bearer',
    );
  }
}
