import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../../core/error/exceptions.dart';
import '../models/address_model.dart';
import '../models/payment_method_model.dart';
import '../models/user_preferences_model.dart';
import '../../../auth/data/models/user_model.dart';

/// Profile remote data source for Firebase integration
/// Following the specifications from FEATURES_DOCUMENTATION.md - Data Sources: User API, Addresses API, Payments API
abstract class ProfileRemoteDataSource {
  // User Profile Management
  Future<UserModel> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  });

  Future<UserModel?> getUserProfile(String userId);

  Future<void> deleteUserAccount();

  // Address Management - Addresses API
  Future<List<AddressModel>> getUserAddresses(String userId);

  Future<AddressModel> getAddressById(String addressId);

  Future<AddressModel> addAddress(AddressModel address);

  Future<AddressModel> updateAddress(AddressModel address);

  Future<void> deleteAddress(String addressId);

  Future<AddressModel> setDefaultAddress(String userId, String addressId);

  // Payment Methods Management - Payments API
  Future<List<PaymentMethodModel>> getUserPaymentMethods(String userId);

  Future<PaymentMethodModel> getPaymentMethodById(String paymentMethodId);

  Future<PaymentMethodModel> addPaymentMethod(PaymentMethodModel paymentMethod);

  Future<PaymentMethodModel> updatePaymentMethod(
    PaymentMethodModel paymentMethod,
  );

  Future<void> deletePaymentMethod(String paymentMethodId);

  Future<PaymentMethodModel> setDefaultPaymentMethod(
    String userId,
    String paymentMethodId,
  );

  // User Preferences Management
  Future<UserPreferencesModel> getUserPreferences(String userId);

  Future<UserPreferencesModel> updateUserPreferences(
    UserPreferencesModel preferences,
  );

  Future<UserPreferencesModel> resetUserPreferences(String userId);

  // Profile Analytics
  Future<void> trackProfileView(String userId);

  Future<void> trackPreferenceChange(
    String userId,
    String preference,
    dynamic value,
  );

  // Data Export/Import
  Future<Map<String, dynamic>> exportUserData(String userId);

  Future<void> importUserData(String userId, Map<String, dynamic> data);
}

class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final FirebaseFirestore _firestore;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  ProfileRemoteDataSourceImpl({
    required FirebaseFirestore firestore,
    required firebase_auth.FirebaseAuth firebaseAuth,
  }) : _firestore = firestore,
       _firebaseAuth = firebaseAuth;

  @override
  Future<UserModel> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  }) async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException('No user signed in');
      }

      // Update Firebase Auth profile
      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoUrl != null) {
        await user.updatePhotoURL(photoUrl);
      }

      // Update Firestore user document
      final userDoc = _firestore.collection('users').doc(user.uid);
      final updateData = <String, dynamic>{
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (displayName != null) updateData['displayName'] = displayName;
      if (phoneNumber != null) updateData['phoneNumber'] = phoneNumber;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;

      await userDoc.update(updateData);

      // Reload user and get updated data
      await user.reload();
      final updatedUser = _firebaseAuth.currentUser!;
      final userSnapshot = await userDoc.get();

      return UserModel.fromFirebaseUser(
        updatedUser,
        additionalData: userSnapshot.data(),
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthenticationException(e.message ?? 'Profile update failed');
    } catch (e) {
      throw ServerException('Profile update failed: ${e.toString()}');
    }
  }

  @override
  Future<UserModel?> getUserProfile(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (!userDoc.exists) {
        return null;
      }

      final userData = userDoc.data()!;
      return UserModel.fromJson({'id': userId, ...userData});
    } catch (e) {
      throw ServerException('Failed to get user profile: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUserAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) {
        throw const AuthenticationException('No user signed in');
      }

      // Delete user data from Firestore
      final batch = _firestore.batch();

      // Delete user document
      batch.delete(_firestore.collection('users').doc(user.uid));

      // Delete user addresses
      final addressesQuery = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: user.uid)
          .get();

      for (final doc in addressesQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user payment methods
      final paymentMethodsQuery = await _firestore
          .collection('payment_methods')
          .where('userId', isEqualTo: user.uid)
          .get();

      for (final doc in paymentMethodsQuery.docs) {
        batch.delete(doc.reference);
      }

      // Delete user preferences
      batch.delete(_firestore.collection('user_preferences').doc(user.uid));

      await batch.commit();

      // Delete Firebase Auth account
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthenticationException(e.message ?? 'Account deletion failed');
    } catch (e) {
      throw ServerException('Account deletion failed: ${e.toString()}');
    }
  }

  @override
  Future<List<AddressModel>> getUserAddresses(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: userId)
          .orderBy('isDefault', descending: true)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => AddressModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get user addresses: ${e.toString()}');
    }
  }

  @override
  Future<AddressModel> getAddressById(String addressId) async {
    try {
      final doc = await _firestore.collection('addresses').doc(addressId).get();

      if (!doc.exists) {
        throw const ServerException('Address not found');
      }

      return AddressModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Failed to get address: ${e.toString()}');
    }
  }

  @override
  Future<AddressModel> addAddress(AddressModel address) async {
    try {
      final docRef = await _firestore
          .collection('addresses')
          .add(address.toFirestore());
      final doc = await docRef.get();

      return AddressModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Failed to add address: ${e.toString()}');
    }
  }

  @override
  Future<AddressModel> updateAddress(AddressModel address) async {
    try {
      await _firestore
          .collection('addresses')
          .doc(address.id)
          .update(address.toFirestore());

      return address;
    } catch (e) {
      throw ServerException('Failed to update address: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteAddress(String addressId) async {
    try {
      await _firestore.collection('addresses').doc(addressId).delete();
    } catch (e) {
      throw ServerException('Failed to delete address: ${e.toString()}');
    }
  }

  @override
  Future<AddressModel> setDefaultAddress(
    String userId,
    String addressId,
  ) async {
    try {
      final batch = _firestore.batch();

      // Remove default from all user addresses
      final userAddresses = await _firestore
          .collection('addresses')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in userAddresses.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Set new default address
      batch.update(_firestore.collection('addresses').doc(addressId), {
        'isDefault': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      // Return updated address
      return await getAddressById(addressId);
    } catch (e) {
      throw ServerException('Failed to set default address: ${e.toString()}');
    }
  }

  // Payment Methods Implementation continues...
  @override
  Future<List<PaymentMethodModel>> getUserPaymentMethods(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('payment_methods')
          .where('userId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .orderBy('isDefault', descending: true)
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => PaymentMethodModel.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw ServerException('Failed to get payment methods: ${e.toString()}');
    }
  }

  @override
  Future<PaymentMethodModel> getPaymentMethodById(
    String paymentMethodId,
  ) async {
    try {
      final doc = await _firestore
          .collection('payment_methods')
          .doc(paymentMethodId)
          .get();

      if (!doc.exists) {
        throw const ServerException('Payment method not found');
      }

      return PaymentMethodModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Failed to get payment method: ${e.toString()}');
    }
  }

  @override
  Future<PaymentMethodModel> addPaymentMethod(
    PaymentMethodModel paymentMethod,
  ) async {
    try {
      final docRef = await _firestore
          .collection('payment_methods')
          .add(paymentMethod.toFirestore());
      final doc = await docRef.get();

      return PaymentMethodModel.fromFirestore(doc.data()!, doc.id);
    } catch (e) {
      throw ServerException('Failed to add payment method: ${e.toString()}');
    }
  }

  @override
  Future<PaymentMethodModel> updatePaymentMethod(
    PaymentMethodModel paymentMethod,
  ) async {
    try {
      await _firestore
          .collection('payment_methods')
          .doc(paymentMethod.id)
          .update(paymentMethod.toFirestore());

      return paymentMethod;
    } catch (e) {
      throw ServerException('Failed to update payment method: ${e.toString()}');
    }
  }

  @override
  Future<void> deletePaymentMethod(String paymentMethodId) async {
    try {
      await _firestore
          .collection('payment_methods')
          .doc(paymentMethodId)
          .delete();
    } catch (e) {
      throw ServerException('Failed to delete payment method: ${e.toString()}');
    }
  }

  @override
  Future<PaymentMethodModel> setDefaultPaymentMethod(
    String userId,
    String paymentMethodId,
  ) async {
    try {
      final batch = _firestore.batch();

      // Remove default from all user payment methods
      final userPaymentMethods = await _firestore
          .collection('payment_methods')
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in userPaymentMethods.docs) {
        batch.update(doc.reference, {'isDefault': false});
      }

      // Set new default payment method
      batch.update(
        _firestore.collection('payment_methods').doc(paymentMethodId),
        {'isDefault': true, 'updatedAt': FieldValue.serverTimestamp()},
      );

      await batch.commit();

      // Return updated payment method
      return await getPaymentMethodById(paymentMethodId);
    } catch (e) {
      throw ServerException(
        'Failed to set default payment method: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserPreferencesModel> getUserPreferences(String userId) async {
    try {
      final doc = await _firestore
          .collection('user_preferences')
          .doc(userId)
          .get();

      if (!doc.exists) {
        // Create default preferences if they don't exist
        final defaultPreferences = UserPreferencesModel(
          userId: userId,
          createdAt: DateTime.now(),
        );

        await _firestore
            .collection('user_preferences')
            .doc(userId)
            .set(defaultPreferences.toFirestore());

        return defaultPreferences;
      }

      return UserPreferencesModel.fromFirestore(doc.data()!, userId);
    } catch (e) {
      throw ServerException('Failed to get user preferences: ${e.toString()}');
    }
  }

  @override
  Future<UserPreferencesModel> updateUserPreferences(
    UserPreferencesModel preferences,
  ) async {
    try {
      await _firestore
          .collection('user_preferences')
          .doc(preferences.userId)
          .set(preferences.toFirestore(), SetOptions(merge: true));

      return preferences;
    } catch (e) {
      throw ServerException(
        'Failed to update user preferences: ${e.toString()}',
      );
    }
  }

  @override
  Future<UserPreferencesModel> resetUserPreferences(String userId) async {
    try {
      final defaultPreferences = UserPreferencesModel(
        userId: userId,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('user_preferences')
          .doc(userId)
          .set(defaultPreferences.toFirestore());

      return defaultPreferences;
    } catch (e) {
      throw ServerException(
        'Failed to reset user preferences: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> trackProfileView(String userId) async {
    try {
      await _firestore.collection('analytics').add({
        'userId': userId,
        'event': 'profile_view',
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Analytics failures should not break the app
      print('Failed to track profile view: $e');
    }
  }

  @override
  Future<void> trackPreferenceChange(
    String userId,
    String preference,
    dynamic value,
  ) async {
    try {
      await _firestore.collection('analytics').add({
        'userId': userId,
        'event': 'preference_change',
        'preference': preference,
        'value': value,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Analytics failures should not break the app
      print('Failed to track preference change: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> exportUserData(String userId) async {
    try {
      final userData = <String, dynamic>{};

      // Get user profile
      final userProfile = await getUserProfile(userId);
      if (userProfile != null) {
        userData['profile'] = userProfile.toJson();
      }

      // Get addresses
      final addresses = await getUserAddresses(userId);
      userData['addresses'] = addresses.map((a) => a.toJson()).toList();

      // Get payment methods
      final paymentMethods = await getUserPaymentMethods(userId);
      userData['paymentMethods'] = paymentMethods
          .map((p) => p.toJson())
          .toList();

      // Get preferences
      final preferences = await getUserPreferences(userId);
      userData['preferences'] = preferences.toJson();

      return userData;
    } catch (e) {
      throw ServerException('Failed to export user data: ${e.toString()}');
    }
  }

  @override
  Future<void> importUserData(String userId, Map<String, dynamic> data) async {
    try {
      final batch = _firestore.batch();

      // Import addresses
      if (data['addresses'] != null) {
        for (final addressData in data['addresses']) {
          final address = AddressModel.fromJson(addressData);
          final docRef = _firestore.collection('addresses').doc();
          batch.set(docRef, address.toFirestore());
        }
      }

      // Import payment methods
      if (data['paymentMethods'] != null) {
        for (final paymentData in data['paymentMethods']) {
          final paymentMethod = PaymentMethodModel.fromJson(paymentData);
          final docRef = _firestore.collection('payment_methods').doc();
          batch.set(docRef, paymentMethod.toFirestore());
        }
      }

      // Import preferences
      if (data['preferences'] != null) {
        final preferences = UserPreferencesModel.fromJson(data['preferences']);
        batch.set(
          _firestore.collection('user_preferences').doc(userId),
          preferences.toFirestore(),
        );
      }

      await batch.commit();
    } catch (e) {
      throw ServerException('Failed to import user data: ${e.toString()}');
    }
  }
}
