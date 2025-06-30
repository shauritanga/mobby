import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/verification_status.dart';
import '../repositories/admin_latra_repository.dart';

/// Get integration statuses use case
class GetIntegrationStatuses implements UseCase<List<IntegrationStatus>, NoParams> {
  final AdminLATRARepository repository;

  const GetIntegrationStatuses(this.repository);

  @override
  Future<Either<Failure, List<IntegrationStatus>>> call(NoParams params) async {
    return await repository.getIntegrationStatuses();
  }
}

/// Get integration status use case
class GetIntegrationStatus implements UseCase<IntegrationStatus?, GetIntegrationStatusParams> {
  final AdminLATRARepository repository;

  const GetIntegrationStatus(this.repository);

  @override
  Future<Either<Failure, IntegrationStatus?>> call(GetIntegrationStatusParams params) async {
    if (params.serviceName.isEmpty) {
      return const Left(ValidationFailure('Service name is required'));
    }

    return await repository.getIntegrationStatus(params.serviceName);
  }
}

class GetIntegrationStatusParams extends Equatable {
  final String serviceName;

  const GetIntegrationStatusParams({
    required this.serviceName,
  });

  @override
  List<Object?> get props => [serviceName];
}

/// Update integration status use case
class UpdateIntegrationStatus implements UseCase<IntegrationStatus, UpdateIntegrationStatusParams> {
  final AdminLATRARepository repository;

  const UpdateIntegrationStatus(this.repository);

  @override
  Future<Either<Failure, IntegrationStatus>> call(UpdateIntegrationStatusParams params) async {
    if (params.serviceName.isEmpty) {
      return const Left(ValidationFailure('Service name is required'));
    }

    if (params.responseTime < 0) {
      return const Left(ValidationFailure('Response time must be non-negative'));
    }

    return await repository.updateIntegrationStatus(
      params.serviceName,
      params.health,
      params.responseTime,
      params.errorMessage,
      params.metrics,
    );
  }
}

class UpdateIntegrationStatusParams extends Equatable {
  final String serviceName;
  final IntegrationHealth health;
  final int responseTime;
  final String? errorMessage;
  final Map<String, dynamic> metrics;

  const UpdateIntegrationStatusParams({
    required this.serviceName,
    required this.health,
    required this.responseTime,
    this.errorMessage,
    this.metrics = const {},
  });

  @override
  List<Object?> get props => [serviceName, health, responseTime, errorMessage, metrics];
}

/// Get integration events use case
class GetIntegrationEvents implements UseCase<List<IntegrationEvent>, GetIntegrationEventsParams> {
  final AdminLATRARepository repository;

  const GetIntegrationEvents(this.repository);

  @override
  Future<Either<Failure, List<IntegrationEvent>>> call(GetIntegrationEventsParams params) async {
    return await repository.getIntegrationEvents(
      serviceName: params.serviceName,
      type: params.type,
      startDate: params.startDate,
      endDate: params.endDate,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetIntegrationEventsParams extends Equatable {
  final String? serviceName;
  final IntegrationEventType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int limit;

  const GetIntegrationEventsParams({
    this.serviceName,
    this.type,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.limit = 50,
  });

  @override
  List<Object?> get props => [serviceName, type, startDate, endDate, page, limit];
}

/// Add integration event use case
class AddIntegrationEvent implements UseCase<void, AddIntegrationEventParams> {
  final AdminLATRARepository repository;

  const AddIntegrationEvent(this.repository);

  @override
  Future<Either<Failure, void>> call(AddIntegrationEventParams params) async {
    if (params.serviceName.isEmpty) {
      return const Left(ValidationFailure('Service name is required'));
    }

    if (params.message.isEmpty) {
      return const Left(ValidationFailure('Message is required'));
    }

    return await repository.addIntegrationEvent(
      params.serviceName,
      params.type,
      params.message,
      params.data,
    );
  }
}

class AddIntegrationEventParams extends Equatable {
  final String serviceName;
  final IntegrationEventType type;
  final String message;
  final Map<String, dynamic> data;

  const AddIntegrationEventParams({
    required this.serviceName,
    required this.type,
    required this.message,
    this.data = const {},
  });

  @override
  List<Object?> get props => [serviceName, type, message, data];
}

/// Get integration analytics use case
class GetIntegrationAnalytics implements UseCase<Map<String, dynamic>, GetIntegrationAnalyticsParams> {
  final AdminLATRARepository repository;

  const GetIntegrationAnalytics(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetIntegrationAnalyticsParams params) async {
    return await repository.getIntegrationAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetIntegrationAnalyticsParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const GetIntegrationAnalyticsParams({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Get admin dashboard data use case
class GetAdminDashboardData implements UseCase<Map<String, dynamic>, NoParams> {
  final AdminLATRARepository repository;

  const GetAdminDashboardData(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(NoParams params) async {
    return await repository.getAdminDashboardData();
  }
}
