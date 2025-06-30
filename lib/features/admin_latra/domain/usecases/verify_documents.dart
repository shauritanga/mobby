import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../latra/domain/entities/latra_document.dart';
import '../entities/verification_status.dart';
import '../repositories/admin_latra_repository.dart';

/// Get all documents use case
class GetAllDocuments implements UseCase<List<LATRADocument>, GetAllDocumentsParams> {
  final AdminLATRARepository repository;

  const GetAllDocuments(this.repository);

  @override
  Future<Either<Failure, List<LATRADocument>>> call(GetAllDocumentsParams params) async {
    return await repository.getAllDocuments(
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

class GetAllDocumentsParams extends Equatable {
  final LATRADocumentStatus? status;
  final LATRADocumentType? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;
  final int page;
  final int limit;

  const GetAllDocumentsParams({
    this.status,
    this.type,
    this.startDate,
    this.endDate,
    this.searchQuery,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [status, type, startDate, endDate, searchQuery, page, limit];
}

/// Verify document use case
class VerifyDocument implements UseCase<VerificationStatus, VerifyDocumentParams> {
  final AdminLATRARepository repository;

  const VerifyDocument(this.repository);

  @override
  Future<Either<Failure, VerificationStatus>> call(VerifyDocumentParams params) async {
    if (params.documentId.isEmpty) {
      return const Left(ValidationFailure('Document ID is required'));
    }

    if (params.verifiedBy.isEmpty) {
      return const Left(ValidationFailure('Verifier ID is required'));
    }

    return await repository.verifyDocument(
      params.documentId,
      params.result,
      params.verifiedBy,
      params.notes,
      params.issues,
    );
  }
}

class VerifyDocumentParams extends Equatable {
  final String documentId;
  final VerificationResult result;
  final String verifiedBy;
  final String? notes;
  final List<String> issues;

  const VerifyDocumentParams({
    required this.documentId,
    required this.result,
    required this.verifiedBy,
    this.notes,
    this.issues = const [],
  });

  @override
  List<Object?> get props => [documentId, result, verifiedBy, notes, issues];
}

/// Get document verifications use case
class GetDocumentVerifications implements UseCase<List<VerificationStatus>, GetDocumentVerificationsParams> {
  final AdminLATRARepository repository;

  const GetDocumentVerifications(this.repository);

  @override
  Future<Either<Failure, List<VerificationStatus>>> call(GetDocumentVerificationsParams params) async {
    if (params.documentId.isEmpty) {
      return const Left(ValidationFailure('Document ID is required'));
    }

    return await repository.getDocumentVerifications(params.documentId);
  }
}

class GetDocumentVerificationsParams extends Equatable {
  final String documentId;

  const GetDocumentVerificationsParams({
    required this.documentId,
  });

  @override
  List<Object?> get props => [documentId];
}

/// Get verification history use case
class GetVerificationHistory implements UseCase<List<VerificationStatus>, GetVerificationHistoryParams> {
  final AdminLATRARepository repository;

  const GetVerificationHistory(this.repository);

  @override
  Future<Either<Failure, List<VerificationStatus>>> call(GetVerificationHistoryParams params) async {
    return await repository.getVerificationHistory(
      verifiedBy: params.verifiedBy,
      startDate: params.startDate,
      endDate: params.endDate,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetVerificationHistoryParams extends Equatable {
  final String? verifiedBy;
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int limit;

  const GetVerificationHistoryParams({
    this.verifiedBy,
    this.startDate,
    this.endDate,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [verifiedBy, startDate, endDate, page, limit];
}

/// Get verification analytics use case
class GetVerificationAnalytics implements UseCase<Map<String, dynamic>, GetVerificationAnalyticsParams> {
  final AdminLATRARepository repository;

  const GetVerificationAnalytics(this.repository);

  @override
  Future<Either<Failure, Map<String, dynamic>>> call(GetVerificationAnalyticsParams params) async {
    return await repository.getVerificationAnalytics(
      startDate: params.startDate,
      endDate: params.endDate,
    );
  }
}

class GetVerificationAnalyticsParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;

  const GetVerificationAnalyticsParams({
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Search documents use case
class SearchDocuments implements UseCase<List<LATRADocument>, SearchDocumentsParams> {
  final AdminLATRARepository repository;

  const SearchDocuments(this.repository);

  @override
  Future<Either<Failure, List<LATRADocument>>> call(SearchDocumentsParams params) async {
    if (params.query.isEmpty) {
      return const Left(ValidationFailure('Search query is required'));
    }

    return await repository.searchDocuments(
      params.query,
      status: params.status,
      type: params.type,
      page: params.page,
      limit: params.limit,
    );
  }
}

class SearchDocumentsParams extends Equatable {
  final String query;
  final LATRADocumentStatus? status;
  final LATRADocumentType? type;
  final int page;
  final int limit;

  const SearchDocumentsParams({
    required this.query,
    this.status,
    this.type,
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [query, status, type, page, limit];
}
