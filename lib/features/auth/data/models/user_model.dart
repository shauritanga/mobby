import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.phoneNumber,
    super.displayName,
    super.photoUrl,
    required super.isEmailVerified,
    required super.isPhoneVerified,
    required super.createdAt,
    super.updatedAt,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] as String?,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      isEmailVerified: map['isEmailVerified'] as bool,
      isPhoneVerified: map['isPhoneVerified'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // For backward compatibility
  factory UserModel.fromJson(Map<String, dynamic> json) =>
      UserModel.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      phoneNumber: user.phoneNumber,
      displayName: user.displayName,
      photoUrl: user.photoUrl,
      isEmailVerified: user.isEmailVerified,
      isPhoneVerified: user.isPhoneVerified,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
    );
  }

  User toEntity() {
    return User(
      id: id,
      email: email,
      phoneNumber: phoneNumber,
      displayName: displayName,
      photoUrl: photoUrl,
      isEmailVerified: isEmailVerified,
      isPhoneVerified: isPhoneVerified,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Firebase specific factory
  factory UserModel.fromFirebaseUser(
    dynamic firebaseUser, {
    Map<String, dynamic>? additionalData,
  }) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      phoneNumber: firebaseUser.phoneNumber,
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isEmailVerified: firebaseUser.emailVerified ?? false,
      isPhoneVerified: firebaseUser.phoneNumber != null,
      createdAt: additionalData?['createdAt']?.toDate() ?? DateTime.now(),
      updatedAt: additionalData?['updatedAt']?.toDate(),
    );
  }

  // Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'phoneNumber': phoneNumber,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'isEmailVerified': isEmailVerified,
      'isPhoneVerified': isPhoneVerified,
      'createdAt': createdAt,
      'updatedAt': updatedAt ?? DateTime.now(),
    };
  }
}
