import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class RemoveFromCartUseCase implements UseCase<Cart, RemoveFromCartParams> {
  final CartRepository repository;

  RemoveFromCartUseCase(this.repository);

  @override
  Future<Either<Failure, Cart>> call(RemoveFromCartParams params) async {
    return await repository.removeFromCart(
      params.userId,
      params.itemId,
    );
  }
}

class RemoveFromCartParams {
  final String userId;
  final String itemId;

  RemoveFromCartParams({
    required this.userId,
    required this.itemId,
  });
}
