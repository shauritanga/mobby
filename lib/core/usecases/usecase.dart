import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Base class for all use cases
/// Following clean architecture principles
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case with no parameters
abstract class NoParamsUseCase<Type> {
  Future<Either<Failure, Type>> call();
}

/// Parameters class for use cases that don't need parameters
class NoParams {
  const NoParams();
}
