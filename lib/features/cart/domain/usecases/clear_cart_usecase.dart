import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class ClearCartUseCase implements UseCase<Cart, ClearCartParams> {
  final CartRepository repository;

  ClearCartUseCase(this.repository);

  @override
  Future<Either<Failure, Cart>> call(ClearCartParams params) async {
    return await repository.clearCart(params.userId);
  }
}

class ClearCartParams {
  final String userId;

  ClearCartParams({required this.userId});
}
