import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/profile_repository.dart';
import '../entities/payment_method.dart';

/// Manage Payments Use Cases
/// Following the specifications from FEATURES_DOCUMENTATION.md - Use Cases: Manage Payments

// Get User Payment Methods
class GetUserPaymentMethodsUseCase
    implements UseCase<List<PaymentMethod>, String> {
  final ProfileRepository repository;

  GetUserPaymentMethodsUseCase(this.repository);

  @override
  Future<Either<Failure, List<PaymentMethod>>> call(String userId) async {
    return await repository.getUserPaymentMethods(userId);
  }
}

// Add Payment Method
class AddPaymentMethodUseCase implements UseCase<PaymentMethod, PaymentMethod> {
  final ProfileRepository repository;

  AddPaymentMethodUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentMethod>> call(
    PaymentMethod paymentMethod,
  ) async {
    return await repository.addPaymentMethod(paymentMethod);
  }
}

// Update Payment Method
class UpdatePaymentMethodUseCase
    implements UseCase<PaymentMethod, PaymentMethod> {
  final ProfileRepository repository;

  UpdatePaymentMethodUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentMethod>> call(
    PaymentMethod paymentMethod,
  ) async {
    return await repository.updatePaymentMethod(paymentMethod);
  }
}

// Delete Payment Method
class DeletePaymentMethodUseCase implements UseCase<void, String> {
  final ProfileRepository repository;

  DeletePaymentMethodUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(String paymentMethodId) async {
    return await repository.deletePaymentMethod(paymentMethodId);
  }
}

// Set Default Payment Method
class SetDefaultPaymentMethodUseCase
    implements UseCase<PaymentMethod, SetDefaultPaymentMethodParams> {
  final ProfileRepository repository;

  SetDefaultPaymentMethodUseCase(this.repository);

  @override
  Future<Either<Failure, PaymentMethod>> call(
    SetDefaultPaymentMethodParams params,
  ) async {
    return await repository.setDefaultPaymentMethod(
      params.userId,
      params.paymentMethodId,
    );
  }
}

class SetDefaultPaymentMethodParams {
  final String userId;
  final String paymentMethodId;

  SetDefaultPaymentMethodParams({
    required this.userId,
    required this.paymentMethodId,
  });
}
