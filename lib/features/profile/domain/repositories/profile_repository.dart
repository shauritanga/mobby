import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/address.dart';
import '../entities/payment_method.dart';
import '../entities/user_preferences.dart';
import '../../../auth/domain/entities/user.dart';

/// Profile repository interface following clean architecture
/// As specified in FEATURES_DOCUMENTATION.md - Data Sources: User API, Addresses API, Payments API
abstract class ProfileRepository {
  // User Profile Management
  Future<Either<Failure, User>> updateUserProfile({
    String? displayName,
    String? phoneNumber,
    String? photoUrl,
  });

  Future<Either<Failure, User?>> getUserProfile(String userId);

  Future<Either<Failure, void>> deleteUserAccount();

  // Address Management - Addresses API
  Future<Either<Failure, List<Address>>> getUserAddresses(String userId);

  Future<Either<Failure, Address>> getAddressById(String addressId);

  Future<Either<Failure, Address>> addAddress(Address address);

  Future<Either<Failure, Address>> updateAddress(Address address);

  Future<Either<Failure, void>> deleteAddress(String addressId);

  Future<Either<Failure, Address>> setDefaultAddress(
    String userId,
    String addressId,
  );

  // Payment Methods Management - Payments API
  Future<Either<Failure, List<PaymentMethod>>> getUserPaymentMethods(
    String userId,
  );

  Future<Either<Failure, PaymentMethod>> getPaymentMethodById(
    String paymentMethodId,
  );

  Future<Either<Failure, PaymentMethod>> addPaymentMethod(
    PaymentMethod paymentMethod,
  );

  Future<Either<Failure, PaymentMethod>> updatePaymentMethod(
    PaymentMethod paymentMethod,
  );

  Future<Either<Failure, void>> deletePaymentMethod(String paymentMethodId);

  Future<Either<Failure, PaymentMethod>> setDefaultPaymentMethod(
    String userId,
    String paymentMethodId,
  );

  // User Preferences Management
  Future<Either<Failure, UserPreferences>> getUserPreferences(String userId);

  Future<Either<Failure, UserPreferences>> updateUserPreferences(
    UserPreferences preferences,
  );

  Future<Either<Failure, UserPreferences>> resetUserPreferences(String userId);

  // Profile Analytics
  Future<Either<Failure, void>> trackProfileView(String userId);

  Future<Either<Failure, void>> trackPreferenceChange(
    String userId,
    String preference,
    dynamic value,
  );

  // Data Export/Import
  Future<Either<Failure, Map<String, dynamic>>> exportUserData(String userId);

  Future<Either<Failure, void>> importUserData(
    String userId,
    Map<String, dynamic> data,
  );

  // Cache Management
  Future<Either<Failure, void>> refreshProfileCache(String userId);

  Future<Either<Failure, void>> clearProfileCache(String userId);
}
