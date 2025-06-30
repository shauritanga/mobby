import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/commission.dart';
import '../repositories/admin_insurance_repository.dart';

/// Get all commissions use case
class GetAllCommissions implements UseCase<List<Commission>, GetAllCommissionsParams> {
  final AdminInsuranceRepository repository;

  const GetAllCommissions(this.repository);

  @override
  Future<Either<Failure, List<Commission>>> call(GetAllCommissionsParams params) async {
    return await repository.getAllCommissions(
      type: params.type,
      status: params.status,
      tier: params.tier,
      partnerId: params.partnerId,
      startDate: params.startDate,
      endDate: params.endDate,
      searchQuery: params.searchQuery,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetAllCommissionsParams extends Equatable {
  final CommissionType? type;
  final CommissionStatus? status;
  final CommissionTier? tier;
  final String? partnerId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final int page;
  final int limit;

  const GetAllCommissionsParams({
    this.type,
    this.status,
    this.tier,
    this.partnerId,
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
        tier,
        partnerId,
        startDate,
        endDate,
        searchQuery,
        page,
        limit,
      ];
}

/// Update commission status use case
class UpdateCommissionStatus implements UseCase<Commission, UpdateCommissionStatusParams> {
  final AdminInsuranceRepository repository;

  const UpdateCommissionStatus(this.repository);

  @override
  Future<Either<Failure, Commission>> call(UpdateCommissionStatusParams params) async {
    if (params.commissionId.isEmpty) {
      return const Left(ValidationFailure('Commission ID is required'));
    }

    if (params.adminId.isEmpty) {
      return const Left(ValidationFailure('Admin ID is required'));
    }

    return await repository.updateCommissionStatus(
      params.commissionId,
      params.status,
      params.adminId,
      params.notes,
    );
  }
}

class UpdateCommissionStatusParams extends Equatable {
  final String commissionId;
  final CommissionStatus status;
  final String adminId;
  final String? notes;

  const UpdateCommissionStatusParams({
    required this.commissionId,
    required this.status,
    required this.adminId,
    this.notes,
  });

  @override
  List<Object?> get props => [commissionId, status, adminId, notes];
}

/// Process commission payment use case
class ProcessCommissionPayment implements UseCase<Commission, ProcessCommissionPaymentParams> {
  final AdminInsuranceRepository repository;

  const ProcessCommissionPayment(this.repository);

  @override
  Future<Either<Failure, Commission>> call(ProcessCommissionPaymentParams params) async {
    if (params.commissionId.isEmpty) {
      return const Left(ValidationFailure('Commission ID is required'));
    }

    if (params.paymentReference.isEmpty) {
      return const Left(ValidationFailure('Payment reference is required'));
    }

    if (params.paymentMethod.isEmpty) {
      return const Left(ValidationFailure('Payment method is required'));
    }

    if (params.processedBy.isEmpty) {
      return const Left(ValidationFailure('Processed by ID is required'));
    }

    return await repository.processCommissionPayment(
      params.commissionId,
      params.paymentReference,
      params.paymentMethod,
      params.processedBy,
    );
  }
}

class ProcessCommissionPaymentParams extends Equatable {
  final String commissionId;
  final String paymentReference;
  final String paymentMethod;
  final String processedBy;

  const ProcessCommissionPaymentParams({
    required this.commissionId,
    required this.paymentReference,
    required this.paymentMethod,
    required this.processedBy,
  });

  @override
  List<Object?> get props => [commissionId, paymentReference, paymentMethod, processedBy];
}

/// Add commission adjustment use case
class AddCommissionAdjustment implements UseCase<Commission, AddCommissionAdjustmentParams> {
  final AdminInsuranceRepository repository;

  const AddCommissionAdjustment(this.repository);

  @override
  Future<Either<Failure, Commission>> call(AddCommissionAdjustmentParams params) async {
    if (params.commissionId.isEmpty) {
      return const Left(ValidationFailure('Commission ID is required'));
    }

    if (params.reason.isEmpty) {
      return const Left(ValidationFailure('Adjustment reason is required'));
    }

    if (params.adjustedBy.isEmpty) {
      return const Left(ValidationFailure('Adjusted by ID is required'));
    }

    return await repository.addCommissionAdjustment(
      params.commissionId,
      params.reason,
      params.amount,
      params.type,
      params.adjustedBy,
      params.notes,
    );
  }
}

class AddCommissionAdjustmentParams extends Equatable {
  final String commissionId;
  final String reason;
  final double amount;
  final AdjustmentType type;
  final String adjustedBy;
  final String? notes;

  const AddCommissionAdjustmentParams({
    required this.commissionId,
    required this.reason,
    required this.amount,
    required this.type,
    required this.adjustedBy,
    this.notes,
  });

  @override
  List<Object?> get props => [commissionId, reason, amount, type, adjustedBy, notes];
}

/// Get commissions by partner use case
class GetCommissionsByPartner implements UseCase<List<Commission>, GetCommissionsByPartnerParams> {
  final AdminInsuranceRepository repository;

  const GetCommissionsByPartner(this.repository);

  @override
  Future<Either<Failure, List<Commission>>> call(GetCommissionsByPartnerParams params) async {
    if (params.partnerId.isEmpty) {
      return const Left(ValidationFailure('Partner ID is required'));
    }

    return await repository.getCommissionsByPartner(
      params.partnerId,
      status: params.status,
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetCommissionsByPartnerParams extends Equatable {
  final String partnerId;
  final CommissionStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const GetCommissionsByPartnerParams({
    required this.partnerId,
    this.status,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [partnerId, status, startDate, endDate];
}

/// Search commissions use case
class SearchCommissions implements UseCase<List<Commission>, SearchCommissionsParams> {
  final AdminInsuranceRepository repository;

  const SearchCommissions(this.repository);

  @override
  Future<Either<Failure, List<Commission>>> call(SearchCommissionsParams params) async {
    if (params.query.isEmpty) {
      return const Left(ValidationFailure('Search query is required'));
    }

    return await repository.searchCommissions(
      params.query,
      type: params.type,
      status: params.status,
      partnerId: params.partnerId,
      page: params.page,
      limit: params.limit,
    );
  }
}

class SearchCommissionsParams extends Equatable {
  final String query;
  final CommissionType? type;
  final CommissionStatus? status;
  final String? partnerId;
  final int page;
  final int limit;

  const SearchCommissionsParams({
    required this.query,
    this.type,
    this.status,
    this.partnerId,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, type, status, partnerId, page, limit];
}

/// Get commissions analytics use case
class GetCommissionsAnalytics implements UseCase<Map<String, dynamic>, GetCommissionsAnalyticsParams> {
  final AdminInsuranceRepository repository;

  const GetCommissionsAnalytics(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetCommissionsAnalyticsParams params) async {
    return await repository.getCommissionsAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
      partnerId: params.partnerId,
    );
  }
}

class GetCommissionsAnalyticsParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? partnerId;

  const GetCommissionsAnalyticsParams({
    this.startDate,
    this.endDate,
    this.partnerId,
  });

  @override
  List<Object?> get props => [startDate, endDate, partnerId];
}

/// Bulk update commission status use case
class BulkUpdateCommissionStatus implements UseCase<void, BulkUpdateCommissionStatusParams> {
  final AdminInsuranceRepository repository;

  const BulkUpdateCommissionStatus(this.repository);

  @override
  Future<Either<Failure, void>> call(BulkUpdateCommissionStatusParams params) async {
    if (params.commissionIds.isEmpty) {
      return const Left(ValidationFailure('Commission IDs are required'));
    }

    if (params.adminId.isEmpty) {
      return const Left(ValidationFailure('Admin ID is required'));
    }

    return await repository.bulkUpdateCommissionStatus(
      params.commissionIds,
      params.status,
      params.adminId,
      params.notes,
    );
  }
}

class BulkUpdateCommissionStatusParams extends Equatable {
  final List<String> commissionIds;
  final CommissionStatus status;
  final String adminId;
  final String? notes;

  const BulkUpdateCommissionStatusParams({
    required this.commissionIds,
    required this.status,
    required this.adminId,
    this.notes,
  });

  @override
  List<Object?> get props => [commissionIds, status, adminId, notes];
}

/// Bulk process commission payments use case
class BulkProcessCommissionPayments implements UseCase<void, BulkProcessCommissionPaymentsParams> {
  final AdminInsuranceRepository repository;

  const BulkProcessCommissionPayments(this.repository);

  @override
  Future<Either<Failure, void>> call(BulkProcessCommissionPaymentsParams params) async {
    if (params.commissionIds.isEmpty) {
      return const Left(ValidationFailure('Commission IDs are required'));
    }

    if (params.paymentMethod.isEmpty) {
      return const Left(ValidationFailure('Payment method is required'));
    }

    if (params.processedBy.isEmpty) {
      return const Left(ValidationFailure('Processed by ID is required'));
    }

    return await repository.bulkProcessCommissionPayments(
      params.commissionIds,
      params.paymentMethod,
      params.processedBy,
    );
  }
}

class BulkProcessCommissionPaymentsParams extends Equatable {
  final List<String> commissionIds;
  final String paymentMethod;
  final String processedBy;

  const BulkProcessCommissionPaymentsParams({
    required this.commissionIds,
    required this.paymentMethod,
    required this.processedBy,
  });

  @override
  List<Object?> get props => [commissionIds, paymentMethod, processedBy];
}
