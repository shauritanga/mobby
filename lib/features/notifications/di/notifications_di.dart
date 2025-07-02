import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobby/features/notifications/notifications_feature.dart';

// Domain
import '../domain/repositories/notifications_repository.dart';
import '../domain/repositories/campaigns_repository.dart';
import '../domain/repositories/templates_repository.dart';
import '../domain/usecases/send_notification.dart';
import '../domain/usecases/get_user_notifications.dart';
import '../domain/usecases/manage_campaigns.dart';
import '../domain/usecases/manage_templates.dart';

// Data
import '../data/datasources/notifications_remote_datasource.dart';
import '../data/datasources/campaigns_remote_datasource.dart';
import '../data/datasources/templates_remote_datasource.dart';
import '../data/repositories/notifications_repository_impl.dart';
import '../data/repositories/campaigns_repository_impl.dart';
import '../data/repositories/templates_repository_impl.dart';

// Presentation
import '../presentation/providers/notifications_provider.dart';
import '../presentation/providers/campaigns_provider.dart';
import '../presentation/providers/templates_provider.dart';

// External dependencies
final firebaseFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Data Sources
final notificationsRemoteDataSourceProvider =
    Provider<NotificationsRemoteDataSource>((ref) {
      final firestore = ref.watch(firebaseFirestoreProvider);
      return NotificationsRemoteDataSourceImpl(firestore);
    });

final campaignsRemoteDataSourceProvider = Provider<CampaignsRemoteDataSource>((
  ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return CampaignsRemoteDataSourceImpl(firestore);
});

final templatesRemoteDataSourceProvider = Provider<TemplatesRemoteDataSource>((
  ref,
) {
  final firestore = ref.watch(firebaseFirestoreProvider);
  return TemplatesRemoteDataSourceImpl(firestore);
});

// Repositories
final notificationsRepositoryProvider = Provider<NotificationsRepository>((
  ref,
) {
  final remoteDataSource = ref.watch(notificationsRemoteDataSourceProvider);
  return NotificationsRepositoryImpl(remoteDataSource: remoteDataSource);
});

final campaignsRepositoryProvider = Provider<CampaignsRepository>((ref) {
  final remoteDataSource = ref.watch(campaignsRemoteDataSourceProvider);
  return CampaignsRepositoryImpl(remoteDataSource: remoteDataSource);
});

final templatesRepositoryProvider = Provider<TemplatesRepository>((ref) {
  final remoteDataSource = ref.watch(templatesRemoteDataSourceProvider);
  return TemplatesRepositoryImpl(remoteDataSource: remoteDataSource);
});

// Use Cases - Notifications
final sendNotificationProvider = Provider<SendNotification>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return SendNotification(repository);
});

final sendBulkNotificationProvider = Provider<SendBulkNotification>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return SendBulkNotification(repository);
});

final getUserNotificationsProvider = Provider<GetUserNotifications>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return GetUserNotifications(repository);
});

final markNotificationAsReadProvider = Provider<MarkNotificationAsRead>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return MarkNotificationAsRead(repository);
});

final markAllNotificationsAsReadProvider = Provider<MarkAllNotificationsAsRead>(
  (ref) {
    final repository = ref.watch(notificationsRepositoryProvider);
    return MarkAllNotificationsAsRead(repository);
  },
);

final getUnreadCountProvider = Provider<GetUnreadCount>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return GetUnreadCount(repository);
});

final deleteNotificationProvider = Provider<DeleteNotification>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return DeleteNotification(repository);
});

final getNotificationStatsProvider = Provider<GetNotificationStats>((ref) {
  final repository = ref.watch(notificationsRepositoryProvider);
  return GetNotificationStats(repository);
});

// Use Cases - Campaigns
final getCampaignsProvider = Provider<GetCampaigns>((ref) {
  final repository = ref.watch(campaignsRepositoryProvider);
  return GetCampaigns(repository);
});

final createCampaignProvider = Provider<CreateCampaign>((ref) {
  final repository = ref.watch(campaignsRepositoryProvider);
  return CreateCampaign(repository);
});

final updateCampaignProvider = Provider<UpdateCampaign>((ref) {
  final repository = ref.watch(campaignsRepositoryProvider);
  return UpdateCampaign(repository);
});

final deleteCampaignProvider = Provider<DeleteCampaign>((ref) {
  final repository = ref.watch(campaignsRepositoryProvider);
  return DeleteCampaign(repository);
});

final launchCampaignProvider = Provider<LaunchCampaign>((ref) {
  final repository = ref.watch(campaignsRepositoryProvider);
  return LaunchCampaign(repository);
});

final pauseCampaignProvider = Provider<PauseCampaign>((ref) {
  final repository = ref.watch(campaignsRepositoryProvider);
  return PauseCampaign(repository);
});

final getCampaignStatsProvider = Provider<GetCampaignStats>((ref) {
  final repository = ref.watch(campaignsRepositoryProvider);
  return GetCampaignStats(repository);
});

final estimateAudienceProvider = Provider<EstimateAudience>((ref) {
  final repository = ref.watch(campaignsRepositoryProvider);
  return EstimateAudience(repository);
});

// Use Cases - Templates
final getTemplatesProvider = Provider<GetTemplates>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return GetTemplates(repository);
});

final createTemplateProvider = Provider<CreateTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return CreateTemplate(repository);
});

final updateTemplateProvider = Provider<UpdateTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return UpdateTemplate(repository);
});

final deleteTemplateProvider = Provider<DeleteTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return DeleteTemplate(repository);
});

final validateTemplateProvider = Provider<ValidateTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return ValidateTemplate(repository);
});

final previewTemplateProvider = Provider<PreviewTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return PreviewTemplate(repository);
});

final duplicateTemplateProvider = Provider<DuplicateTemplate>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return DuplicateTemplate(repository);
});

final getTemplatesByTypeProvider = Provider<GetTemplatesByType>((ref) {
  final repository = ref.watch(templatesRepositoryProvider);
  return GetTemplatesByType(repository);
});

// Presentation Providers
final notificationsProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
      return NotificationsNotifier(
        getUserNotifications: ref.watch(getUserNotificationsProvider),
        markAsRead: ref.watch(markNotificationAsReadProvider),
        markAllAsRead: ref.watch(markAllNotificationsAsReadProvider),
        getUnreadCount: ref.watch(getUnreadCountProvider),
        deleteNotification: ref.watch(deleteNotificationProvider),
      );
    });

final sendNotificationStateProvider =
    StateNotifierProvider<SendNotificationNotifier, SendNotificationState>((
      ref,
    ) {
      return SendNotificationNotifier(
        sendNotification: ref.watch(sendNotificationProvider),
        sendBulkNotification: ref.watch(sendBulkNotificationProvider),
      );
    });

final campaignsProvider =
    StateNotifierProvider<CampaignsNotifier, CampaignsState>((ref) {
      return CampaignsNotifier(
        getCampaigns: ref.watch(getCampaignsProvider),
        createCampaign: ref.watch(createCampaignProvider),
        updateCampaign: ref.watch(updateCampaignProvider),
        deleteCampaign: ref.watch(deleteCampaignProvider),
        launchCampaign: ref.watch(launchCampaignProvider),
        pauseCampaign: ref.watch(pauseCampaignProvider),
        getCampaignStats: ref.watch(getCampaignStatsProvider),
        estimateAudience: ref.watch(estimateAudienceProvider),
      );
    });

final campaignStatsProvider =
    StateNotifierProvider<CampaignStatsNotifier, CampaignStatsState>((ref) {
      return CampaignStatsNotifier(
        getCampaignStats: ref.watch(getCampaignStatsProvider),
      );
    });

final templatesProvider =
    StateNotifierProvider<TemplatesNotifier, TemplatesState>((ref) {
      return TemplatesNotifier(
        getTemplates: ref.watch(getTemplatesProvider),
        createTemplate: ref.watch(createTemplateProvider),
        updateTemplate: ref.watch(updateTemplateProvider),
        deleteTemplate: ref.watch(deleteTemplateProvider),
        validateTemplate: ref.watch(validateTemplateProvider),
        previewTemplate: ref.watch(previewTemplateProvider),
        duplicateTemplate: ref.watch(duplicateTemplateProvider),
        getTemplatesByType: ref.watch(getTemplatesByTypeProvider),
      );
    });

final templateEditorProvider =
    StateNotifierProvider<TemplateEditorNotifier, TemplateEditorState>((ref) {
      return TemplateEditorNotifier(
        validateTemplate: ref.watch(validateTemplateProvider),
        previewTemplate: ref.watch(previewTemplateProvider),
      );
    });

// Helper providers for specific use cases
final unreadNotificationsCountProvider = FutureProvider.family<int, String>((
  ref,
  userId,
) async {
  final getUnreadCount = ref.watch(getUnreadCountProvider);
  final result = await getUnreadCount(GetUnreadCountParams(userId: userId));
  return result.fold((failure) => 0, (count) => count);
});

final notificationStatsProvider =
    FutureProvider.family<Map<String, int>, String>((ref, userId) async {
      final getStats = ref.watch(getNotificationStatsProvider);
      final result = await getStats(GetNotificationStatsParams(userId: userId));
      return result.fold((failure) => {}, (stats) => stats);
    });

final templatesByTypeProvider =
    FutureProvider.family<List<Template>, TemplateType>((ref, type) async {
      final getTemplatesByType = ref.watch(getTemplatesByTypeProvider);
      final result = await getTemplatesByType(
        GetTemplatesByTypeParams(type: type),
      );
      return result.fold((failure) => [], (templates) => templates);
    });
