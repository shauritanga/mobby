import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart.dart';
import '../repositories/cart_repository.dart';

class GetCartUseCase implements UseCase<Cart, GetCartParams> {
  final CartRepository repository;

  GetCartUseCase(this.repository);

  @override
  Future<Either<Failure, Cart>> call(GetCartParams params) async {
    return await repository.getUserCart(params.userId);
  }
}

class GetCartParams {
  final String userId;

  GetCartParams({required this.userId});
}
