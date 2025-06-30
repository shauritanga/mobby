import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/latra_application.dart';
import '../../domain/entities/latra_status.dart';
import '../../domain/entities/latra_document.dart';
import '../../domain/repositories/latra_repository.dart';
import '../../domain/usecases/register_with_latra_usecase.dart';
import '../../domain/usecases/track_status_usecase.dart';
import '../../domain/usecases/upload_documents_usecase.dart';
import 'latra_providers.dart';

// LATRA Application State
class LATRAApplicationState extends Equatable {
  final bool isLoading;
  final String? error;
  final LATRAApplication? application;
  final List<LATRAApplication> applications;

  const LATRAApplicationState({
    this.isLoading = false,
    this.error,
    this.application,
    this.applications = const [],
  });

  LATRAApplicationState copyWith({
    bool? isLoading,
    String? error,
    LATRAApplication? application,
    List<LATRAApplication>? applications,
  }) {
    return LATRAApplicationState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      application: application ?? this.application,
      applications: applications ?? this.applications,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, application, applications];
}

// LATRA Status State
class LATRAStatusState extends Equatable {
  final bool isLoading;
  final String? error;
  final List<LATRAStatus> statusList;
  final LATRAStatus? latestStatus;

  const LATRAStatusState({
    this.isLoading = false,
    this.error,
    this.statusList = const [],
    this.latestStatus,
  });

  LATRAStatusState copyWith({
    bool? isLoading,
    String? error,
    List<LATRAStatus>? statusList,
    LATRAStatus? latestStatus,
  }) {
    return LATRAStatusState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      statusList: statusList ?? this.statusList,
      latestStatus: latestStatus ?? this.latestStatus,
    );
  }

  @override
  List<Object?> get props => [isLoading, error, statusList, latestStatus];
}

// LATRA Document State
class LATRADocumentState extends Equatable {
  final bool isLoading;
  final bool isUploading;
  final String? error;
  final List<LATRADocument> documents;
  final double uploadProgress;

  const LATRADocumentState({
    this.isLoading = false,
    this.isUploading = false,
    this.error,
    this.documents = const [],
    this.uploadProgress = 0.0,
  });

  LATRADocumentState copyWith({
    bool? isLoading,
    bool? isUploading,
    String? error,
    List<LATRADocument>? documents,
    double? uploadProgress,
  }) {
    return LATRADocumentState(
      isLoading: isLoading ?? this.isLoading,
      isUploading: isUploading ?? this.isUploading,
      error: error,
      documents: documents ?? this.documents,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    isUploading,
    error,
    documents,
    uploadProgress,
  ];
}

// LATRA Application State Notifier
class LATRAApplicationNotifier extends StateNotifier<LATRAApplicationState> {
  final RegisterWithLATRAUseCase _registerWithLATRAUseCase;
  final LATRARepository _repository;

  LATRAApplicationNotifier(this._registerWithLATRAUseCase, this._repository)
    : super(const LATRAApplicationState());

  Future<void> loadUserApplications(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getUserApplications(userId);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (applications) =>
          state = state.copyWith(isLoading: false, applications: applications),
    );
  }

  Future<void> loadApplication(String applicationId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.getApplicationById(applicationId);
    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (application) =>
          state = state.copyWith(isLoading: false, application: application),
    );
  }

  Future<bool> registerWithLATRA({
    required String userId,
    required String vehicleId,
    required LATRAApplicationType type,
    required Map<String, dynamic> formData,
    String? description,
    bool autoSubmit = false,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    final params = RegisterWithLATRAParams(
      userId: userId,
      vehicleId: vehicleId,
      type: type,
      formData: formData,
      description: description,
      autoSubmit: autoSubmit,
    );

    final result = await _registerWithLATRAUseCase(params);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (application) {
        state = state.copyWith(isLoading: false, application: application);
        return true;
      },
    );
  }

  Future<bool> submitApplication(String applicationId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.submitApplication(applicationId);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (application) {
        state = state.copyWith(isLoading: false, application: application);
        return true;
      },
    );
  }

  Future<bool> cancelApplication(String applicationId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.cancelApplication(applicationId);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> updateApplication(LATRAApplication application) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.updateApplication(application);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (updatedApplication) {
        state = state.copyWith(
          isLoading: false,
          application: updatedApplication,
        );
        return true;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const LATRAApplicationState();
  }

  Future getApplication(String applicationId) async {}
}

// LATRA Status State Notifier
class LATRAStatusNotifier extends StateNotifier<LATRAStatusState> {
  final TrackStatusUseCase _trackStatusUseCase;
  final GetLatestStatusUseCase _getLatestStatusUseCase;
  final GetUserStatusUpdatesUseCase _getUserStatusUpdatesUseCase;

  LATRAStatusNotifier(
    this._trackStatusUseCase,
    this._getLatestStatusUseCase,
    this._getUserStatusUpdatesUseCase,
  ) : super(const LATRAStatusState());

  Future<void> trackApplicationStatus(String applicationId) async {
    state = state.copyWith(isLoading: true, error: null);

    final params = TrackStatusParams(applicationId: applicationId);
    final result = await _trackStatusUseCase(params);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (statusList) => state = state.copyWith(
        isLoading: false,
        statusList: statusList,
        latestStatus: statusList.isNotEmpty ? statusList.first : null,
      ),
    );
  }

  Future<void> getLatestStatus(String applicationId) async {
    state = state.copyWith(isLoading: true, error: null);

    final params = GetLatestStatusParams(applicationId: applicationId);
    final result = await _getLatestStatusUseCase(params);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (status) =>
          state = state.copyWith(isLoading: false, latestStatus: status),
    );
  }

  Future<void> getUserStatusUpdates(String userId, {int? limit}) async {
    state = state.copyWith(isLoading: true, error: null);

    final params = GetUserStatusUpdatesParams(userId: userId, limit: limit);
    final result = await _getUserStatusUpdatesUseCase(params);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (statusList) =>
          state = state.copyWith(isLoading: false, statusList: statusList),
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const LATRAStatusState();
  }
}

// LATRA Document State Notifier
class LATRADocumentNotifier extends StateNotifier<LATRADocumentState> {
  final UploadDocumentsUseCase _uploadDocumentsUseCase;
  final GetApplicationDocumentsUseCase _getApplicationDocumentsUseCase;
  final GetUserDocumentsUseCase _getUserDocumentsUseCase;
  final DeleteDocumentUseCase _deleteDocumentUseCase;

  LATRADocumentNotifier(
    this._uploadDocumentsUseCase,
    this._getApplicationDocumentsUseCase,
    this._getUserDocumentsUseCase,
    this._deleteDocumentUseCase,
  ) : super(const LATRADocumentState());

  Future<void> loadApplicationDocuments(String applicationId) async {
    state = state.copyWith(isLoading: true, error: null);

    final params = GetApplicationDocumentsParams(applicationId: applicationId);
    final result = await _getApplicationDocumentsUseCase(params);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (documents) =>
          state = state.copyWith(isLoading: false, documents: documents),
    );
  }

  Future<void> loadUserDocuments(String userId) async {
    state = state.copyWith(isLoading: true, error: null);

    final params = GetUserDocumentsParams(userId: userId);
    final result = await _getUserDocumentsUseCase(params);

    result.fold(
      (failure) =>
          state = state.copyWith(isLoading: false, error: failure.message),
      (documents) =>
          state = state.copyWith(isLoading: false, documents: documents),
    );
  }

  Future<bool> uploadDocument({
    required String applicationId,
    required String filePath,
    required LATRADocumentType type,
    required String title,
    String? description,
  }) async {
    state = state.copyWith(isUploading: true, error: null, uploadProgress: 0.0);

    final params = UploadDocumentsParams(
      applicationId: applicationId,
      filePath: filePath,
      type: type,
      title: title,
      description: description,
    );

    // Simulate upload progress
    for (int i = 0; i <= 100; i += 10) {
      await Future.delayed(const Duration(milliseconds: 100));
      state = state.copyWith(uploadProgress: i / 100);
    }

    final result = await _uploadDocumentsUseCase(params);
    return result.fold(
      (failure) {
        state = state.copyWith(
          isUploading: false,
          error: failure.message,
          uploadProgress: 0.0,
        );
        return false;
      },
      (document) {
        final updatedDocuments = [...state.documents, document];
        state = state.copyWith(
          isUploading: false,
          documents: updatedDocuments,
          uploadProgress: 1.0,
        );
        return true;
      },
    );
  }

  Future<bool> deleteDocument(String documentId) async {
    state = state.copyWith(isLoading: true, error: null);

    final params = DeleteDocumentParams(documentId: documentId);
    final result = await _deleteDocumentUseCase(params);

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        final updatedDocuments = state.documents
            .where((doc) => doc.id != documentId)
            .toList();
        state = state.copyWith(isLoading: false, documents: updatedDocuments);
        return true;
      },
    );
  }

  void updateUploadProgress(double progress) {
    state = state.copyWith(uploadProgress: progress);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const LATRADocumentState();
  }
}

// State Notifier Providers
final latraApplicationNotifierProvider =
    StateNotifierProvider<LATRAApplicationNotifier, LATRAApplicationState>((
      ref,
    ) {
      return LATRAApplicationNotifier(
        ref.watch(registerWithLATRAUseCaseProvider),
        ref.watch(latraRepositoryProvider),
      );
    });

final latraStatusNotifierProvider =
    StateNotifierProvider<LATRAStatusNotifier, LATRAStatusState>((ref) {
      return LATRAStatusNotifier(
        ref.watch(trackStatusUseCaseProvider),
        ref.watch(getLatestStatusUseCaseProvider),
        ref.watch(getUserStatusUpdatesUseCaseProvider),
      );
    });

final latraDocumentNotifierProvider =
    StateNotifierProvider<LATRADocumentNotifier, LATRADocumentState>((ref) {
      return LATRADocumentNotifier(
        ref.watch(uploadDocumentsUseCaseProvider),
        ref.watch(getApplicationDocumentsUseCaseProvider),
        ref.watch(getUserDocumentsUseCaseProvider),
        ref.watch(deleteDocumentUseCaseProvider),
      );
    });
