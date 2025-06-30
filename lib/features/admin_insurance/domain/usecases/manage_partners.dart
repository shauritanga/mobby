import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/insurance_partner.dart';
import '../repositories/admin_insurance_repository.dart';

/// Get all partners use case
class GetAllPartners implements UseCase<List<InsurancePartner>, GetAllPartnersParams> {
  final AdminInsuranceRepository repository;

  const GetAllPartners(this.repository);

  @override
  Future<Either<Failure, List<InsurancePartner>>> call(GetAllPartnersParams params) async {
    return await repository.getAllPartners(
      type: params.type,
      status: params.status,
      startDate: params.startDate,
      endDate: params.endDate,
      searchQuery: params.searchQuery,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetAllPartnersParams extends Equatable {
  final PartnerType? type;
  final PartnerStatus? status;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final int page;
  final int limit;

  const GetAllPartnersParams({
    this.type,
    this.status,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [type, status, startDate, endDate, searchQuery, page, limit];
}

/// Create partner use case
class CreatePartner implements UseCase<InsurancePartner, CreatePartnerParams> {
  final AdminInsuranceRepository repository;

  const CreatePartner(this.repository);

  @override
  Future<Either<Failure, InsurancePartner>> call(CreatePartnerParams params) async {
    if (params.partner.name.isEmpty) {
      return const Left(ValidationFailure('Partner name is required'));
    }

    if (params.partner.contact.email.isEmpty) {
      return const Left(ValidationFailure('Partner email is required'));
    }

    if (params.partner.licenseNumber.isEmpty) {
      return const Left(ValidationFailure('License number is required'));
    }

    return await repository.createPartner(params.partner);
  }
}

class CreatePartnerParams extends Equatable {
  final InsurancePartner partner;

  const CreatePartnerParams({
    required this.partner,
  });

  @override
  List<Object?> get props => [partner];
}

/// Update partner use case
class UpdatePartner implements UseCase<InsurancePartner, UpdatePartnerParams> {
  final AdminInsuranceRepository repository;

  const UpdatePartner(this.repository);

  @override
  Future<Either<Failure, InsurancePartner>> call(UpdatePartnerParams params) async {
    if (params.partner.id.isEmpty) {
      return const Left(ValidationFailure('Partner ID is required'));
    }

    if (params.partner.name.isEmpty) {
      return const Left(ValidationFailure('Partner name is required'));
    }

    return await repository.updatePartner(params.partner);
  }
}

class UpdatePartnerParams extends Equatable {
  final InsurancePartner partner;

  const UpdatePartnerParams({
    required this.partner,
  });

  @override
  List<Object?> get props => [partner];
}

/// Update partner status use case
class UpdatePartnerStatus implements UseCase<InsurancePartner, UpdatePartnerStatusParams> {
  final AdminInsuranceRepository repository;

  const UpdatePartnerStatus(this.repository);

  @override
  Future<Either<Failure, InsurancePartner>> call(UpdatePartnerStatusParams params) async {
    if (params.partnerId.isEmpty) {
      return const Left(ValidationFailure('Partner ID is required'));
    }

    if (params.adminId.isEmpty) {
      return const Left(ValidationFailure('Admin ID is required'));
    }

    return await repository.updatePartnerStatus(
      params.partnerId,
      params.status,
      params.adminId,
      params.reason,
    );
  }
}

class UpdatePartnerStatusParams extends Equatable {
  final String partnerId;
  final PartnerStatus status;
  final String adminId;
  final String? reason;

  const UpdatePartnerStatusParams({
    required this.partnerId,
    required this.status,
    required this.adminId,
    this.reason,
  });

  @override
  List<Object?> get props => [partnerId, status, adminId, reason];
}

/// Delete partner use case
class DeletePartner implements UseCase<void, DeletePartnerParams> {
  final AdminInsuranceRepository repository;

  const DeletePartner(this.repository);

  @override
  Future<Either<Failure, void>> call(DeletePartnerParams params) async {
    if (params.partnerId.isEmpty) {
      return const Left(ValidationFailure('Partner ID is required'));
    }

    return await repository.deletePartner(params.partnerId);
  }
}

class DeletePartnerParams extends Equatable {
  final String partnerId;

  const DeletePartnerParams({
    required this.partnerId,
  });

  @override
  List<Object?> get props => [partnerId];
}

/// Search partners use case
class SearchPartners implements UseCase<List<InsurancePartner>, SearchPartnersParams> {
  final AdminInsuranceRepository repository;

  const SearchPartners(this.repository);

  @override
  Future<Either<Failure, List<InsurancePartner>>> call(SearchPartnersParams params) async {
    if (params.query.isEmpty) {
      return const Left(ValidationFailure('Search query is required'));
    }

    return await repository.searchPartners(
      params.query,
      type: params.type,
      status: params.status,
      page: params.page,
      limit: params.limit,
    );
  }
}

class SearchPartnersParams extends Equatable {
  final String query;
  final PartnerType? type;
  final PartnerStatus? status;
  final int page;
  final int limit;

  const SearchPartnersParams({
    required this.query,
    this.type,
    this.status,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, type, status, page, limit];
}

/// Get partners analytics use case
class GetPartnersAnalytics implements UseCase<Map<String, dynamic>, GetPartnersAnalyticsParams> {
  final AdminInsuranceRepository repository;

  const GetPartnersAnalytics(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetPartnersAnalyticsParams params) async {
    return await repository.getPartnersAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetPartnersAnalyticsParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const GetPartnersAnalyticsParams({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}
