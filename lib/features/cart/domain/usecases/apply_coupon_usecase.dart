import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class ApplyCouponUseCase implements UseCase<Cart, ApplyCouponParams> {
  final CartRepository repository;

  ApplyCouponUseCase(this.repository);

  @override
  Future<Either<Failure, Cart>> call(ApplyCouponParams params) async {
    // Validate input
    if (params.couponCode.isEmpty) {
      return Left(ValidationFailure('Coupon code cannot be empty'));
    }

    return await repository.applyCoupon(
      params.userId,
      params.couponCode,
    );
  }
}

class ApplyCouponParams {
  final String userId;
  final String couponCode;

  ApplyCouponParams({
    required this.userId,
    required this.couponCode,
  });
}
