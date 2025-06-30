import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../../../../core/providers/core_providers.dart';
import '../../domain/entities/latra_application.dart';
import '../../domain/entities/latra_status.dart';
import '../../domain/entities/latra_document.dart';
import '../../domain/repositories/latra_repository.dart';
import '../../domain/usecases/register_with_latra_usecase.dart';
import '../../domain/usecases/track_status_usecase.dart';
import '../../domain/usecases/upload_documents_usecase.dart';
import '../../data/repositories/latra_repository_impl.dart';
import '../../data/datasources/latra_remote_datasource.dart';
import '../../data/datasources/latra_local_datasource.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// Data source providers
final latraRemoteDataSourceProvider = Provider<LATRARemoteDataSource>((ref) {
  return LATRARemoteDataSourceImpl(
    firestore: FirebaseFirestore.instance,
    storage: FirebaseStorage.instance,
  );
});

final latraLocalDataSourceProvider = Provider<LATRALocalDataSource>((ref) {
  final sharedPreferences = ref.watch(sharedPreferencesProvider);
  return LATRALocalDataSourceImpl(sharedPreferences);
});

// Repository provider
final latraRepositoryProvider = Provider<LATRARepository>((ref) {
  return LATRARepositoryImpl(
    remoteDataSource: ref.watch(latraRemoteDataSourceProvider),
    localDataSource: ref.watch(latraLocalDataSourceProvider),
    connectivity: Connectivity(),
  );
});

// Use case providers
final registerWithLATRAUseCaseProvider = Provider<RegisterWithLATRAUseCase>((ref) {
  return RegisterWithLATRAUseCase(ref.watch(latraRepositoryProvider));
});

final trackStatusUseCaseProvider = Provider<TrackStatusUseCase>((ref) {
  return TrackStatusUseCase(ref.watch(latraRepositoryProvider));
});

final getLatestStatusUseCaseProvider = Provider<GetLatestStatusUseCase>((ref) {
  return GetLatestStatusUseCase(ref.watch(latraRepositoryProvider));
});

final getUserStatusUpdatesUseCaseProvider = Provider<GetUserStatusUpdatesUseCase>((ref) {
  return GetUserStatusUpdatesUseCase(ref.watch(latraRepositoryProvider));
});

final uploadDocumentsUseCaseProvider = Provider<UploadDocumentsUseCase>((ref) {
  return UploadDocumentsUseCase(ref.watch(latraRepositoryProvider));
});

final getApplicationDocumentsUseCaseProvider = Provider<GetApplicationDocumentsUseCase>((ref) {
  return GetApplicationDocumentsUseCase(ref.watch(latraRepositoryProvider));
});

final getUserDocumentsUseCaseProvider = Provider<GetUserDocumentsUseCase>((ref) {
  return GetUserDocumentsUseCase(ref.watch(latraRepositoryProvider));
});

final deleteDocumentUseCaseProvider = Provider<DeleteDocumentUseCase>((ref) {
  return DeleteDocumentUseCase(ref.watch(latraRepositoryProvider));
});

// Application providers
final userLATRAApplicationsProvider = FutureProvider.family<List<LATRAApplication>, String>((ref, userId) async {
  final repository = ref.watch(latraRepositoryProvider);
  final result = await repository.getUserApplications(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (applications) => applications,
  );
});

final latraApplicationProvider = FutureProvider.family<LATRAApplication?, String>((ref, applicationId) async {
  final repository = ref.watch(latraRepositoryProvider);
  final result = await repository.getApplicationById(applicationId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (application) => application,
  );
});

// Status providers
final applicationStatusProvider = FutureProvider.family<List<LATRAStatus>, String>((ref, applicationId) async {
  final repository = ref.watch(latraRepositoryProvider);
  final result = await repository.getApplicationStatus(applicationId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (statusList) => statusList,
  );
});

final latestApplicationStatusProvider = FutureProvider.family<LATRAStatus?, String>((ref, applicationId) async {
  final repository = ref.watch(latraRepositoryProvider);
  final result = await repository.getLatestStatus(applicationId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (status) => status,
  );
});

final userStatusUpdatesProvider = FutureProvider.family<List<LATRAStatus>, String>((ref, userId) async {
  final repository = ref.watch(latraRepositoryProvider);
  final result = await repository.getUserStatusUpdates(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (statusList) => statusList,
  );
});

// Document providers
final applicationDocumentsProvider = FutureProvider.family<List<LATRADocument>, String>((ref, applicationId) async {
  final repository = ref.watch(latraRepositoryProvider);
  final result = await repository.getApplicationDocuments(applicationId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (documents) => documents,
  );
});

final userLATRADocumentsProvider = FutureProvider.family<List<LATRADocument>, String>((ref, userId) async {
  final repository = ref.watch(latraRepositoryProvider);
  final result = await repository.getUserDocuments(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (documents) => documents,
  );
});

// Application metadata providers
final availableApplicationTypesProvider = FutureProvider<List<LATRAApplicationType>>((ref) async {
  final repository = ref.watch(latraRepositoryProvider);
  final result = await repository.getAvailableApplicationTypes();
  return result.fold(
    (failure) => throw Exception(failure.message),
    (types) => types,
  );
});

final requiredDocumentsProvider = FutureProvider.family<List<String>, LATRAApplicationType>((ref, type) async {
  final repository = ref.watch(latraRepositoryProvider);
  final result = await repository.getRequiredDocuments(type);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (documents) => documents,
  );
});

final applicationFeeProvider = FutureProvider.family<double, LATRAApplicationType>((ref, type) async {
  final repository = ref.watch(latraRepositoryProvider);
  final result = await repository.getApplicationFee(type);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (fee) => fee,
  );
});

// Filtered application providers
final pendingApplicationsProvider = FutureProvider.family<List<LATRAApplication>, String>((ref, userId) async {
  final applications = await ref.watch(userLATRAApplicationsProvider(userId).future);
  return applications.where((app) => app.isPending).toList();
});

final completedApplicationsProvider = FutureProvider.family<List<LATRAApplication>, String>((ref, userId) async {
  final applications = await ref.watch(userLATRAApplicationsProvider(userId).future);
  return applications.where((app) => app.isCompleted).toList();
});

final rejectedApplicationsProvider = FutureProvider.family<List<LATRAApplication>, String>((ref, userId) async {
  final applications = await ref.watch(userLATRAApplicationsProvider(userId).future);
  return applications.where((app) => app.isRejected).toList();
});

// Document status providers
final verifiedDocumentsProvider = FutureProvider.family<List<LATRADocument>, String>((ref, userId) async {
  final documents = await ref.watch(userLATRADocumentsProvider(userId).future);
  return documents.where((doc) => doc.isVerified).toList();
});

final pendingDocumentsProvider = FutureProvider.family<List<LATRADocument>, String>((ref, userId) async {
  final documents = await ref.watch(userLATRADocumentsProvider(userId).future);
  return documents.where((doc) => doc.isPending).toList();
});

final expiredDocumentsProvider = FutureProvider.family<List<LATRADocument>, String>((ref, userId) async {
  final documents = await ref.watch(userLATRADocumentsProvider(userId).future);
  return documents.where((doc) => doc.isExpired).toList();
});

final expiringSoonDocumentsProvider = FutureProvider.family<List<LATRADocument>, String>((ref, userId) async {
  final documents = await ref.watch(userLATRADocumentsProvider(userId).future);
  return documents.where((doc) => doc.expiresSoon).toList();
});

// Statistics providers
final latraStatisticsProvider = FutureProvider.family<Map<String, int>, String>((ref, userId) async {
  final applications = await ref.watch(userLATRAApplicationsProvider(userId).future);
  final documents = await ref.watch(userLATRADocumentsProvider(userId).future);

  return {
    'totalApplications': applications.length,
    'pendingApplications': applications.where((app) => app.isPending).length,
    'completedApplications': applications.where((app) => app.isCompleted).length,
    'rejectedApplications': applications.where((app) => app.isRejected).length,
    'totalDocuments': documents.length,
    'verifiedDocuments': documents.where((doc) => doc.isVerified).length,
    'pendingDocuments': documents.where((doc) => doc.isPending).length,
    'expiredDocuments': documents.where((doc) => doc.isExpired).length,
    'expiringSoonDocuments': documents.where((doc) => doc.expiresSoon).length,
  };
});

// Current user providers (convenience providers)
final currentUserLATRAApplicationsProvider = FutureProvider<List<LATRAApplication>>((ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return [];
  
  return ref.watch(userLATRAApplicationsProvider(currentUser.id).future);
});

final currentUserLATRADocumentsProvider = FutureProvider<List<LATRADocument>>((ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return [];
  
  return ref.watch(userLATRADocumentsProvider(currentUser.id).future);
});

final currentUserLATRAStatisticsProvider = FutureProvider<Map<String, int>>((ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return {};
  
  return ref.watch(latraStatisticsProvider(currentUser.id).future);
});

final currentUserStatusUpdatesProvider = FutureProvider<List<LATRAStatus>>((ref) async {
  final currentUser = ref.watch(currentUserProvider).value;
  if (currentUser == null) return [];
  
  return ref.watch(userStatusUpdatesProvider(currentUser.id).future);
});
