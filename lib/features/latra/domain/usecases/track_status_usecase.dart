import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/latra_status.dart';
import '../repositories/latra_repository.dart';

/// Track Status use case
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class TrackStatusUseCase
    implements UseCase<List<LATRAStatus>, TrackStatusParams> {
  final LATRARepository repository;

  const TrackStatusUseCase(this.repository);

  @override
  Future<Either<Failure, List<LATRAStatus>>> call(
    TrackStatusParams params,
  ) async {
    // Validate required parameters
    if (params.applicationId.isEmpty) {
      return const Left(ValidationFailure('Application ID is required'));
    }

    // Get application status history
    final statusResult = await repository.getApplicationStatus(
      params.applicationId,
    );
    if (statusResult.isLeft()) {
      return statusResult;
    }

    final statusList = statusResult.fold((l) => <LATRAStatus>[], (r) => r);

    // Sort by timestamp (most recent first)
    statusList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Filter by status type if specified
    if (params.statusType != null) {
      final filteredList = statusList
          .where((status) => status.type == params.statusType)
          .toList();
      return Right(filteredList);
    }

    // Limit results if specified
    if (params.limit != null && params.limit! > 0) {
      final limitedList = statusList.take(params.limit!).toList();
      return Right(limitedList);
    }

    return Right(statusList);
  }
}

/// Get Latest Status use case
class GetLatestStatusUseCase
    implements UseCase<LATRAStatus?, GetLatestStatusParams> {
  final LATRARepository repository;

  const GetLatestStatusUseCase(this.repository);

  @override
  Future<Either<Failure, LATRAStatus?>> call(
    GetLatestStatusParams params,
  ) async {
    // Validate required parameters
    if (params.applicationId.isEmpty) {
      return const Left(ValidationFailure('Application ID is required'));
    }

    // Get latest status
    return await repository.getLatestStatus(params.applicationId);
  }
}

/// Get User Status Updates use case
class GetUserStatusUpdatesUseCase
    implements UseCase<List<LATRAStatus>, GetUserStatusUpdatesParams> {
  final LATRARepository repository;

  const GetUserStatusUpdatesUseCase(this.repository);

  @override
  Future<Either<Failure, List<LATRAStatus>>> call(
    GetUserStatusUpdatesParams params,
  ) async {
    // Validate required parameters
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure('User ID is required'));
    }

    // Get user status updates
    final statusResult = await repository.getUserStatusUpdates(params.userId);
    if (statusResult.isLeft()) {
      return statusResult;
    }

    final statusList = statusResult.fold((l) => <LATRAStatus>[], (r) => r);

    // Sort by timestamp (most recent first)
    statusList.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // Filter by date range if specified
    if (params.fromDate != null || params.toDate != null) {
      final filteredList = statusList.where((status) {
        if (params.fromDate != null &&
            status.timestamp.isBefore(params.fromDate!)) {
          return false;
        }
        if (params.toDate != null && status.timestamp.isAfter(params.toDate!)) {
          return false;
        }
        return true;
      }).toList();
      return Right(filteredList);
    }

    // Limit results if specified
    if (params.limit != null && params.limit! > 0) {
      final limitedList = statusList.take(params.limit!).toList();
      return Right(limitedList);
    }

    return Right(statusList);
  }
}

/// Parameters for Track Status use case
class TrackStatusParams extends Equatable {
  final String applicationId;
  final LATRAStatusType? statusType;
  final int? limit;

  const TrackStatusParams({
    required this.applicationId,
    this.statusType,
    this.limit,
  });

  @override
  List<Object?> get props => [applicationId, statusType, limit];
}

/// Parameters for Get Latest Status use case
class GetLatestStatusParams extends Equatable {
  final String applicationId;

  const GetLatestStatusParams({required this.applicationId});

  @override
  List<Object?> get props => [applicationId];
}

/// Parameters for Get User Status Updates use case
class GetUserStatusUpdatesParams extends Equatable {
  final String userId;
  final DateTime? fromDate;
  final DateTime? toDate;
  final int? limit;

  const GetUserStatusUpdatesParams({
    required this.userId,
    this.fromDate,
    this.toDate,
    this.limit,
  });

  @override
  List<Object?> get props => [userId, fromDate, toDate, limit];
}
