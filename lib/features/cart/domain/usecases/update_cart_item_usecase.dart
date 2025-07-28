import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class UpdateCartItemUseCase implements UseCase<Cart, UpdateCartItemParams> {
  final CartRepository repository;

  UpdateCartItemUseCase(this.repository);

  @override
  Future<Either<Failure, Cart>> call(UpdateCartItemParams params) async {
    // Validate input
    if (params.quantity < 0) {
      return Left(ValidationFailure('Quantity cannot be negative'));
    }

    return await repository.updateCartItemQuantity(
      params.userId,
      params.itemId,
      params.quantity,
    );
  }
}

class UpdateCartItemParams {
  final String userId;
  final String itemId;
  final int quantity;

  UpdateCartItemParams({
    required this.userId,
    required this.itemId,
    required this.quantity,
  });
}
