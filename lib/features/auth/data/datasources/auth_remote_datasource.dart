import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';
import '../models/auth_token_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<UserModel> signInWithPhoneNumber({
    required String phoneNumber,
    required String verificationCode,
  });

  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  });

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> sendEmailVerification();

  Future<void> sendPhoneVerification({required String phoneNumber});

  Future<UserModel> verifyPhoneNumber({required String verificationCode});

  Future<UserModel> verifyEmailWithCode({required String verificationCode});

  Future<void> signOut();

  Future<UserModel?> getCurrentUser();

  Stream<UserModel?> get authStateChanges;

  Future<AuthTokenModel?> getCurrentToken();

  Future<AuthTokenModel> refreshToken();

  Future<UserModel> updateProfile({String? displayName, String? photoUrl});

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> deleteAccount();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  // Store verification ID for phone auth
  String? _verificationId;

  AuthRemoteDataSourceImpl({
    required FirebaseAuth firebaseAuth,
    required FirebaseFirestore firestore,
  }) : _firebaseAuth = firebaseAuth,
       _firestore = firestore;

  @override
  Future<UserModel> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthenticationException('Sign in failed');
      }

      return await _getUserWithAdditionalData(credential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw AuthenticationException('Sign in failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
    String? phoneNumber,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (credential.user == null) {
        throw const AuthenticationException('Sign up failed');
      }

      // Update display name
      await credential.user!.updateDisplayName(displayName);

      // Create user document in Firestore
      final userModel = UserModel.fromFirebaseUser(credential.user!);
      await _createUserDocument(userModel);

      return userModel;
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw AuthenticationException('Sign up failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw AuthenticationException('Password reset failed: ${e.toString()}');
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException('No user signed in');
      }
      await user.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw AuthenticationException(
        'Email verification failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> sendPhoneVerification({required String phoneNumber}) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          // Auto-verification completed
        },
        verificationFailed: (FirebaseAuthException e) {
          throw AuthenticationException(_getFirebaseAuthErrorMessage(e));
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw AuthenticationException(
        'Phone verification failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> verifyPhoneNumber({
    required String verificationCode,
  }) async {
    try {
      if (_verificationId == null) {
        throw const AuthenticationException('No verification ID available');
      }

      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: verificationCode,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );

      if (userCredential.user == null) {
        throw const AuthenticationException('Phone verification failed');
      }

      return await _getUserWithAdditionalData(userCredential.user!);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw AuthenticationException(
        'Phone verification failed: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserModel> signInWithPhoneNumber({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    // This method assumes verification was already sent
    return await verifyPhoneNumber(verificationCode: verificationCode);
  }

  @override
  Future<UserModel> verifyEmailWithCode({
    required String verificationCode,
  }) async {
    // Firebase doesn't support email verification with custom codes
    // This would need to be implemented with a custom backend
    throw const AuthenticationException(
      'Email verification with code not supported',
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      throw AuthenticationException('Sign out failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      return await _getUserWithAdditionalData(user);
    } catch (e) {
      throw AuthenticationException('Get current user failed: ${e.toString()}');
    }
  }

  @override
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      return await _getUserWithAdditionalData(user);
    });
  }

  @override
  Future<AuthTokenModel?> getCurrentToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return null;

      final idToken = await user.getIdToken();
      if (idToken == null) {
        throw const AuthenticationException('Failed to get ID token');
      }
      return AuthTokenModel.fromFirebaseToken(idToken);
    } catch (e) {
      throw AuthenticationException('Get token failed: ${e.toString()}');
    }
  }

  @override
  Future<AuthTokenModel> refreshToken() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException('No user signed in');
      }

      final idToken = await user.getIdToken(true); // Force refresh
      if (idToken == null) {
        throw const AuthenticationException('Failed to refresh ID token');
      }
      return AuthTokenModel.fromFirebaseToken(idToken);
    } catch (e) {
      throw AuthenticationException('Token refresh failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel> updateProfile({
    String? displayName,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException('No user signed in');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      await user.reload();
      return await _getUserWithAdditionalData(_firebaseAuth.currentUser!);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw AuthenticationException('Profile update failed: ${e.toString()}');
    }
  }

  @override
  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException('No user signed in');
      }

      // Re-authenticate user
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Update password
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw AuthenticationException('Password update failed: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException('No user signed in');
      }

      // Delete user document from Firestore
      await _firestore.collection('users').doc(user.uid).delete();

      // Delete Firebase Auth user
      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(_getFirebaseAuthErrorMessage(e));
    } catch (e) {
      throw AuthenticationException('Account deletion failed: ${e.toString()}');
    }
  }

  // Helper methods
  Future<UserModel> _getUserWithAdditionalData(User firebaseUser) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();
      final additionalData = doc.exists ? doc.data() : null;

      return UserModel.fromFirebaseUser(
        firebaseUser,
        additionalData: additionalData,
      );
    } catch (e) {
      // If Firestore fails, return user with Firebase data only
      return UserModel.fromFirebaseUser(firebaseUser);
    }
  }

  Future<void> _createUserDocument(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toFirestore());
    } catch (e) {
      // Log error but don't throw - user creation should still succeed
      // TODO: Replace with proper logging framework
      // ignore: avoid_print
      print('Failed to create user document: $e');
    }
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'This operation is not allowed.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'invalid-verification-id':
        return 'Invalid verification ID.';
      default:
        return e.message ?? 'An authentication error occurred.';
    }
  }
}
