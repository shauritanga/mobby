import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../latra/domain/entities/latra_application.dart';
import '../repositories/admin_latra_repository.dart';

/// Get all applications use case
class GetAllApplications
    implements UseCase<List<LATRAApplication>, GetAllApplicationsParams> {
  final AdminLATRARepository repository;

  const GetAllApplications(this.repository);

  @override
  Future<Either<Failure, List<LATRAApplication>>> call(
    GetAllApplicationsParams params,
  ) async {
    return await repository.getAllApplications(
      status: params.status,
      type: params.type,
      startDate: params.startDate,
      endDate: params.endDate,
      searchQuery: params.searchQuery,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetAllApplicationsParams extends Equatable {
  final LATRAApplicationStatus? status;
  final LATRAApplicationType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final int page;
  final int limit;

  const GetAllApplicationsParams({
    this.status,
    this.type,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [
    status,
    type,
    startDate,
    endDate,
    searchQuery,
    page,
    limit,
  ];
}

/// Update application status use case
class UpdateApplicationStatus
    implements UseCase<LATRAApplication, UpdateApplicationStatusParams> {
  final AdminLATRARepository repository;

  const UpdateApplicationStatus(this.repository);

  @override
  Future<Either<Failure, LATRAApplication>> call(
    UpdateApplicationStatusParams params,
  ) async {
    if (params.applicationId.isEmpty) {
      return const Left(ValidationFailure('Application ID is required'));
    }

    if (params.adminId.isEmpty) {
      return const Left(ValidationFailure('Admin ID is required'));
    }

    return await repository.updateApplicationStatus(
      params.applicationId,
      params.status,
      params.adminId,
      params.notes,
    );
  }
}

class UpdateApplicationStatusParams extends Equatable {
  final String applicationId;
  final LATRAApplicationStatus status;
  final String adminId;
  final String? notes;

  const UpdateApplicationStatusParams({
    required this.applicationId,
    required this.status,
    required this.adminId,
    this.notes,
  });

  @override
  List<Object?> get props => [applicationId, status, adminId, notes];
}

/// Assign application use case
class AssignApplication
    implements UseCase<LATRAApplication, AssignApplicationParams> {
  final AdminLATRARepository repository;

  const AssignApplication(this.repository);

  @override
  Future<Either<Failure, LATRAApplication>> call(
    AssignApplicationParams params,
  ) async {
    if (params.applicationId.isEmpty) {
      return const Left(ValidationFailure('Application ID is required'));
    }

    if (params.assignedTo.isEmpty) {
      return const Left(ValidationFailure('Assignee ID is required'));
    }

    if (params.assignedBy.isEmpty) {
      return const Left(ValidationFailure('Assigner ID is required'));
    }

    return await repository.assignApplication(
      params.applicationId,
      params.assignedTo,
      params.assignedBy,
    );
  }
}

class AssignApplicationParams extends Equatable {
  final String applicationId;
  final String assignedTo;
  final String assignedBy;

  const AssignApplicationParams({
    required this.applicationId,
    required this.assignedTo,
    required this.assignedBy,
  });

  @override
  List<Object?> get props => [applicationId, assignedTo, assignedBy];
}

/// Add application notes use case
class AddApplicationNotes implements UseCase<void, AddApplicationNotesParams> {
  final AdminLATRARepository repository;

  const AddApplicationNotes(this.repository);

  @override
  Future<Either<Failure, void>> call(AddApplicationNotesParams params) async {
    if (params.applicationId.isEmpty) {
      return const Left(ValidationFailure('Application ID is required'));
    }

    if (params.notes.isEmpty) {
      return const Left(ValidationFailure('Notes cannot be empty'));
    }

    if (params.adminId.isEmpty) {
      return const Left(ValidationFailure('Admin ID is required'));
    }

    return await repository.addApplicationNotes(
      params.applicationId,
      params.notes,
      params.adminId,
    );
  }
}

class AddApplicationNotesParams extends Equatable {
  final String applicationId;
  final String notes;
  final String adminId;

  const AddApplicationNotesParams({
    required this.applicationId,
    required this.notes,
    required this.adminId,
  });

  @override
  List<Object?> get props => [applicationId, notes, adminId];
}

/// Get applications analytics use case
class GetApplicationsAnalytics
    implements UseCase<Map<String, dynamic>, GetApplicationsAnalyticsParams> {
  final AdminLATRARepository repository;

  const GetApplicationsAnalytics(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    GetApplicationsAnalyticsParams params,
  ) async {
    return await repository.getApplicationsAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetApplicationsAnalyticsParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const GetApplicationsAnalyticsParams({this.startDate, this.endDate});

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Bulk update application status use case
class BulkUpdateApplicationStatus
    implements UseCase<void, BulkUpdateApplicationStatusParams> {
  final AdminLATRARepository repository;

  const BulkUpdateApplicationStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(
    BulkUpdateApplicationStatusParams params,
  ) async {
    if (params.applicationIds.isEmpty) {
      return const Left(ValidationFailure('Application IDs are required'));
    }

    if (params.adminId.isEmpty) {
      return const Left(ValidationFailure('Admin ID is required'));
    }

    return await repository.bulkUpdateApplicationStatus(
      params.applicationIds,
      params.status,
      params.adminId,
      params.notes,
    );
  }
}

class BulkUpdateApplicationStatusParams extends Equatable {
  final List<String> applicationIds;
  final LATRAApplicationStatus status;
  final String adminId;
  final String? notes;

  const BulkUpdateApplicationStatusParams({
    required this.applicationIds,
    required this.status,
    required this.adminId,
    this.notes,
  });

  @override
  List<Object?> get props => [applicationIds, status, adminId, notes];
}

/// Search applications use case
class SearchApplications
    implements UseCase<List<LATRAApplication>, SearchApplicationsParams> {
  final AdminLATRARepository repository;

  const SearchApplications(this.repository);

  @override
  Future<Either<Failure, List<LATRAApplication>>> call(
    SearchApplicationsParams params,
  ) async {
    if (params.query.isEmpty) {
      return const Left(ValidationFailure('Search query is required'));
    }

    return await repository.searchApplications(
      params.query,
      status: params.status,
      type: params.type,
      page: params.page,
      limit: params.limit,
    );
  }
}

class SearchApplicationsParams extends Equatable {
  final String query;
  final LATRAApplicationStatus? status;
  final LATRAApplicationType? type;
  final int page;
  final int limit;

  const SearchApplicationsParams({
    required this.query,
    this.status,
    this.type,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, status, type, page, limit];
}
