import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/application.dart';
import '../repositories/admin_insurance_repository.dart';

/// Get all applications use case
class GetAllApplications
    implements UseCase<List<InsuranceApplication>, GetAllApplicationsParams> {
  final AdminInsuranceRepository repository;

  const GetAllApplications(this.repository);

  @override
  Future<Either<Failure, List<InsuranceApplication>>> call(
    GetAllApplicationsParams params,
  ) async {
    return await repository.getAllApplications(
      type: params.type,
      status: params.status,
      priority: params.priority,
      partnerId: params.partnerId,
      assignedTo: params.assignedTo,
      startDate: params.startDate,
      endDate: params.endDate,
      searchQuery: params.searchQuery,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetAllApplicationsParams extends Equatable {
  final ApplicationType? type;
  final ApplicationStatus? status;
  final ApplicationPriority? priority;
  final String? partnerId;
  final String? assignedTo;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final int page;
  final int limit;

  const GetAllApplicationsParams({
    this.type,
    this.status,
    this.priority,
    this.partnerId,
    this.assignedTo,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [
    type,
    status,
    priority,
    partnerId,
    assignedTo,
    startDate,
    endDate,
    searchQuery,
    page,
    limit,
  ];
}

/// Update application status use case
class UpdateApplicationStatus
    implements UseCase<InsuranceApplication, UpdateApplicationStatusParams> {
  final AdminInsuranceRepository repository;

  const UpdateApplicationStatus(this.repository);

  @override
  Future<Either<Failure, InsuranceApplication>> call(
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
      params.reason,
    );
  }
}

class UpdateApplicationStatusParams extends Equatable {
  final String applicationId;
  final ApplicationStatus status;
  final String adminId;
  final String? reason;

  const UpdateApplicationStatusParams({
    required this.applicationId,
    required this.status,
    required this.adminId,
    this.reason,
  });

  @override
  List<Object?> get props => [applicationId, status, adminId, reason];
}

/// Assign application use case
class AssignApplication
    implements UseCase<InsuranceApplication, AssignApplicationParams> {
  final AdminInsuranceRepository repository;

  const AssignApplication(this.repository);

  @override
  Future<Either<Failure, InsuranceApplication>> call(
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

/// Update application priority use case
class UpdateApplicationPriority
    implements UseCase<InsuranceApplication, UpdateApplicationPriorityParams> {
  final AdminInsuranceRepository repository;

  const UpdateApplicationPriority(this.repository);

  @override
  Future<Either<Failure, InsuranceApplication>> call(
    UpdateApplicationPriorityParams params,
  ) async {
    if (params.applicationId.isEmpty) {
      return const Left(ValidationFailure('Application ID is required'));
    }

    if (params.adminId.isEmpty) {
      return const Left(ValidationFailure('Admin ID is required'));
    }

    return await repository.updateApplicationPriority(
      params.applicationId,
      params.priority,
      params.adminId,
    );
  }
}

class UpdateApplicationPriorityParams extends Equatable {
  final String applicationId;
  final ApplicationPriority priority;
  final String adminId;

  const UpdateApplicationPriorityParams({
    required this.applicationId,
    required this.priority,
    required this.adminId,
  });

  @override
  List<Object?> get props => [applicationId, priority, adminId];
}

/// Add application note use case
class AddApplicationNote implements UseCase<void, AddApplicationNoteParams> {
  final AdminInsuranceRepository repository;

  const AddApplicationNote(this.repository);

  @override
  Future<Either<Failure, void>> call(AddApplicationNoteParams params) async {
    if (params.applicationId.isEmpty) {
      return const Left(ValidationFailure('Application ID is required'));
    }

    if (params.content.isEmpty) {
      return const Left(ValidationFailure('Note content cannot be empty'));
    }

    if (params.addedBy.isEmpty) {
      return const Left(ValidationFailure('Added by ID is required'));
    }

    return await repository.addApplicationNote(
      params.applicationId,
      params.content,
      params.addedBy,
      params.isInternal,
    );
  }
}

class AddApplicationNoteParams extends Equatable {
  final String applicationId;
  final String content;
  final String addedBy;
  final bool isInternal;

  const AddApplicationNoteParams({
    required this.applicationId,
    required this.content,
    required this.addedBy,
    required this.isInternal,
  });

  @override
  List<Object?> get props => [applicationId, content, addedBy, isInternal];
}

/// Get applications by assignee use case
class GetApplicationsByAssignee
    implements
        UseCase<List<InsuranceApplication>, GetApplicationsByAssigneeParams> {
  final AdminInsuranceRepository repository;

  const GetApplicationsByAssignee(this.repository);

  @override
  Future<Either<Failure, List<InsuranceApplication>>> call(
    GetApplicationsByAssigneeParams params,
  ) async {
    if (params.assigneeId.isEmpty) {
      return const Left(ValidationFailure('Assignee ID is required'));
    }

    return await repository.getApplicationsByAssignee(params.assigneeId);
  }
}

class GetApplicationsByAssigneeParams extends Equatable {
  final String assigneeId;

  const GetApplicationsByAssigneeParams({required this.assigneeId});

  @override
  List<Object?> get props => [assigneeId];
}

/// Search applications use case
class SearchApplications
    implements UseCase<List<InsuranceApplication>, SearchApplicationsParams> {
  final AdminInsuranceRepository repository;

  const SearchApplications(this.repository);

  @override
  Future<Either<Failure, List<InsuranceApplication>>> call(
    SearchApplicationsParams params,
  ) async {
    if (params.query.isEmpty) {
      return const Left(ValidationFailure('Search query is required'));
    }

    return await repository.searchApplications(
      params.query,
      type: params.type,
      status: params.status,
      priority: params.priority,
      partnerId: params.partnerId,
      page: params.page,
      limit: params.limit,
    );
  }
}

class SearchApplicationsParams extends Equatable {
  final String query;
  final ApplicationType? type;
  final ApplicationStatus? status;
  final ApplicationPriority? priority;
  final String? partnerId;
  final int page;
  final int limit;

  const SearchApplicationsParams({
    required this.query,
    this.type,
    this.status,
    this.priority,
    this.partnerId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [
    query,
    type,
    status,
    priority,
    partnerId,
    page,
    limit,
  ];
}

/// Get applications analytics use case
class GetApplicationsAnalytics
    implements UseCase<Map<String, dynamic>, GetApplicationsAnalyticsParams> {
  final AdminInsuranceRepository repository;

  const GetApplicationsAnalytics(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(
    GetApplicationsAnalyticsParams params,
  ) async {
    return await repository.getApplicationsAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
      partnerId: params.partnerId,
    );
  }
}

class GetApplicationsAnalyticsParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? partnerId;

  const GetApplicationsAnalyticsParams({
    this.startDate,
    this.endDate,
    this.partnerId,
  });

  @override
  List<Object?> get props => [startDate, endDate, partnerId];
}

/// Bulk update application status use case
class BulkUpdateApplicationStatus
    implements UseCase<void, BulkUpdateApplicationStatusParams> {
  final AdminInsuranceRepository repository;

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
      params.reason,
    );
  }
}

class BulkUpdateApplicationStatusParams extends Equatable {
  final List<String> applicationIds;
  final ApplicationStatus status;
  final String adminId;
  final String? reason;

  const BulkUpdateApplicationStatusParams({
    required this.applicationIds,
    required this.status,
    required this.adminId,
    this.reason,
  });

  @override
  List<Object?> get props => [applicationIds, status, adminId, reason];
}
