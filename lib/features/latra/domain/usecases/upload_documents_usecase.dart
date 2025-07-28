import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/latra_document.dart';
import '../repositories/latra_repository.dart';

/// Upload Documents use case
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class UploadDocumentsUseCase
    implements UseCase<LATRADocument, UploadDocumentsParams> {
  final LATRARepository repository;

  const UploadDocumentsUseCase(this.repository);

  @override
  Future<Either<Failure, LATRADocument>> call(
    UploadDocumentsParams params,
  ) async {
    // Validate required parameters
    if (params.applicationId.isEmpty) {
      return const Left(ValidationFailure('Application ID is required'));
    }

    if (params.filePath.isEmpty) {
      return const Left(ValidationFailure('File path is required'));
    }

    if (params.title.isEmpty) {
      return const Left(ValidationFailure('Document title is required'));
    }

    // Upload document
    return await repository.uploadDocument(
      params.applicationId,
      params.filePath,
      params.type,
      params.title,
      description: params.description,
    );
  }
}

/// Get Application Documents use case
class GetApplicationDocumentsUseCase
    implements UseCase<List<LATRADocument>, GetApplicationDocumentsParams> {
  final LATRARepository repository;

  const GetApplicationDocumentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<LATRADocument>>> call(
    GetApplicationDocumentsParams params,
  ) async {
    // Validate required parameters
    if (params.applicationId.isEmpty) {
      return const Left(ValidationFailure('Application ID is required'));
    }

    // Get application documents
    final documentsResult = await repository.getApplicationDocuments(
      params.applicationId,
    );
    if (documentsResult.isLeft()) {
      return documentsResult;
    }

    final documents = documentsResult.fold((l) => <LATRADocument>[], (r) => r);

    // Filter by document type if specified
    if (params.documentType != null) {
      final filteredDocuments = documents
          .where((doc) => doc.type == params.documentType)
          .toList();
      return Right(filteredDocuments);
    }

    // Filter by status if specified
    if (params.status != null) {
      final filteredDocuments = documents
          .where((doc) => doc.status == params.status)
          .toList();
      return Right(filteredDocuments);
    }

    // Sort by creation date (most recent first)
    documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Right(documents);
  }
}

/// Get User Documents use case
class GetUserDocumentsUseCase
    implements UseCase<List<LATRADocument>, GetUserDocumentsParams> {
  final LATRARepository repository;

  const GetUserDocumentsUseCase(this.repository);

  @override
  Future<Either<Failure, List<LATRADocument>>> call(
    GetUserDocumentsParams params,
  ) async {
    // Validate required parameters
    if (params.userId.isEmpty) {
      return const Left(ValidationFailure('User ID is required'));
    }

    // Get user documents
    final documentsResult = await repository.getUserDocuments(params.userId);
    if (documentsResult.isLeft()) {
      return documentsResult;
    }

    final documents = documentsResult.fold((l) => <LATRADocument>[], (r) => r);

    // Filter by document type if specified
    if (params.documentType != null) {
      final filteredDocuments = documents
          .where((doc) => doc.type == params.documentType)
          .toList();
      return Right(filteredDocuments);
    }

    // Filter by status if specified
    if (params.status != null) {
      final filteredDocuments = documents
          .where((doc) => doc.status == params.status)
          .toList();
      return Right(filteredDocuments);
    }

    // Filter expired documents if specified
    if (params.includeExpired == false) {
      final nonExpiredDocuments = documents
          .where((doc) => !doc.isExpired)
          .toList();
      return Right(nonExpiredDocuments);
    }

    // Sort by creation date (most recent first)
    documents.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Right(documents);
  }
}

/// Delete Document use case
class DeleteDocumentUseCase implements UseCase<void, DeleteDocumentParams> {
  final LATRARepository repository;

  const DeleteDocumentUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteDocumentParams params) async {
    // Validate required parameters
    if (params.documentId.isEmpty) {
      return const Left(ValidationFailure('Document ID is required'));
    }

    // Delete document
    return await repository.deleteDocument(params.documentId);
  }
}

/// Parameters for Upload Documents use case
class UploadDocumentsParams extends Equatable {
  final String applicationId;
  final String filePath;
  final LATRADocumentType type;
  final String title;
  final String? description;

  const UploadDocumentsParams({
    required this.applicationId,
    required this.filePath,
    required this.type,
    required this.title,
    this.description,
  });

  @override
  List<Object?> get props => [
    applicationId,
    filePath,
    type,
    title,
    description,
  ];
}

/// Parameters for Get Application Documents use case
class GetApplicationDocumentsParams extends Equatable {
  final String applicationId;
  final LATRADocumentType? documentType;
  final LATRADocumentStatus? status;

  const GetApplicationDocumentsParams({
    required this.applicationId,
    this.documentType,
    this.status,
  });

  @override
  List<Object?> get props => [applicationId, documentType, status];
}

/// Parameters for Get User Documents use case
class GetUserDocumentsParams extends Equatable {
  final String userId;
  final LATRADocumentType? documentType;
  final LATRADocumentStatus? status;
  final bool includeExpired;

  const GetUserDocumentsParams({
    required this.userId,
    this.documentType,
    this.status,
    this.includeExpired = true,
  });

  @override
  List<Object?> get props => [userId, documentType, status, includeExpired];
}

/// Parameters for Delete Document use case
class DeleteDocumentParams extends Equatable {
  final String documentId;

  const DeleteDocumentParams({required this.documentId});

  @override
  List<Object?> get props => [documentId];
}
