import '../../domain/entities/campaign.dart';
import '../../domain/entities/notification.dart';
import '../../domain/repositories/campaigns_repository.dart';
import '../datasources/campaigns_remote_datasource.dart';
import '../models/campaign_model.dart';

class CampaignsRepositoryImpl implements CampaignsRepository {
  final CampaignsRemoteDataSource remoteDataSource;

  CampaignsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<Campaign>> getCampaigns({
    int page = 1,
    int limit = 20,
    CampaignStatus? status,
    CampaignType? type,
  }) async {
    final campaigns = await remoteDataSource.getCampaigns(
      page: page,
      limit: limit,
      status: status,
      type: type,
    );
    return campaigns.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Campaign?> getCampaign(String campaignId) async {
    final campaign = await remoteDataSource.getCampaign(campaignId);
    return campaign?.toEntity();
  }

  @override
  Future<Campaign> createCampaign(Campaign campaign) async {
    final campaignModel = CampaignModel.fromEntity(campaign);
    final createdModel = await remoteDataSource.createCampaign(campaignModel);
    return createdModel.toEntity();
  }

  @override
  Future<Campaign> updateCampaign(Campaign campaign) async {
    final campaignModel = CampaignModel.fromEntity(campaign);
    final updatedModel = await remoteDataSource.updateCampaign(campaignModel);
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteCampaign(String campaignId) async {
    await remoteDataSource.deleteCampaign(campaignId);
  }

  @override
  Future<Campaign> launchCampaign(String campaignId) async {
    final campaign = await remoteDataSource.launchCampaign(campaignId);
    return campaign.toEntity();
  }

  @override
  Future<Campaign> pauseCampaign(String campaignId) async {
    final campaign = await remoteDataSource.pauseCampaign(campaignId);
    return campaign.toEntity();
  }

  @override
  Future<Campaign> resumeCampaign(String campaignId) async {
    final campaign = await remoteDataSource.resumeCampaign(campaignId);
    return campaign.toEntity();
  }

  @override
  Future<Campaign> stopCampaign(String campaignId) async {
    final campaign = await remoteDataSource.stopCampaign(campaignId);
    return campaign.toEntity();
  }

  @override
  Future<Campaign> scheduleCampaign(
    String campaignId,
    DateTime scheduledAt,
  ) async {
    final campaign = await remoteDataSource.scheduleCampaign(
      campaignId,
      scheduledAt,
    );
    return campaign.toEntity();
  }

  @override
  Future<int> estimateAudience(CampaignTarget target) async {
    return await remoteDataSource.estimateAudience(target);
  }

  @override
  Future<List<String>> getTargetUserIds(CampaignTarget target) async {
    return await remoteDataSource.getTargetUserIds(target);
  }

  @override
  Future<void> updateCampaignTarget(
    String campaignId,
    CampaignTarget target,
  ) async {
    await remoteDataSource.updateCampaignTarget(campaignId, target);
  }

  @override
  Future<CampaignStats> getCampaignStats(String campaignId) async {
    final stats = await remoteDataSource.getCampaignStats(campaignId);
    return stats; // CampaignStatsModel extends CampaignStats
  }

  @override
  Future<Map<String, dynamic>> getCampaignAnalytics(
    String campaignId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    return await remoteDataSource.getCampaignAnalytics(
      campaignId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getCampaignPerformanceReport(
    String campaignId,
  ) async {
    // This would generate a detailed performance report
    final analytics = await remoteDataSource.getCampaignAnalytics(campaignId);
    final stats = await remoteDataSource.getCampaignStats(campaignId);

    return [
      {
        'section': 'Overview',
        'data': {
          'totalSent': stats.totalSent,
          'delivered': stats.delivered,
          'opened': stats.opened,
          'clicked': stats.clicked,
          'failed': stats.failed,
        },
      },
      {
        'section': 'Performance Metrics',
        'data': {
          'deliveryRate': '${stats.deliveryRate.toStringAsFixed(2)}%',
          'openRate': '${stats.openRate.toStringAsFixed(2)}%',
          'clickRate': '${stats.clickRate.toStringAsFixed(2)}%',
        },
      },
      {'section': 'Channel Breakdown', 'data': analytics['channelBreakdown']},
      {'section': 'Daily Performance', 'data': analytics['dailyStats']},
    ];
  }

  @override
  Future<Campaign> duplicateCampaign(String campaignId, String newName) async {
    final originalCampaign = await remoteDataSource.getCampaign(campaignId);
    if (originalCampaign == null) {
      throw Exception('Campaign not found');
    }

    final duplicatedCampaign = originalCampaign.copyWith(
      id: '', // Will be generated
      name: newName,
      status: CampaignStatus.draft,
      launchedAt: null,
      completedAt: null,
      stats: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final createdModel = await remoteDataSource.createCampaign(
      CampaignModel.fromEntity(duplicatedCampaign),
    );
    return createdModel.toEntity();
  }

  @override
  Future<Campaign> createCampaignFromTemplate(
    String templateId,
    String name,
    CampaignTarget target,
  ) async {
    final campaign = Campaign(
      id: '', // Will be generated
      name: name,
      description: 'Campaign created from template',
      type: CampaignType.oneTime,
      status: CampaignStatus.draft,
      templateId: templateId,
      target: target,
      schedule: const CampaignSchedule(),
      channels: [NotificationChannel.push], // Default channel
      createdBy: 'system', // This should come from the current user
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await createCampaign(campaign);
  }

  @override
  Future<void> bulkUpdateCampaignStatus(
    List<String> campaignIds,
    CampaignStatus status,
  ) async {
    // This would require implementing bulk operations in the data source
    for (final campaignId in campaignIds) {
      final campaign = await remoteDataSource.getCampaign(campaignId);
      if (campaign != null) {
        final updatedCampaign = campaign.copyWith(
          status: status,
          updatedAt: DateTime.now(),
        );
        await remoteDataSource.updateCampaign(
          CampaignModel.fromEntity(updatedCampaign),
        );
      }
    }
  }

  @override
  Future<void> bulkDeleteCampaigns(List<String> campaignIds) async {
    // This would require implementing bulk operations in the data source
    for (final campaignId in campaignIds) {
      await remoteDataSource.deleteCampaign(campaignId);
    }
  }

  @override
  Future<List<Campaign>> searchCampaigns(
    String query, {
    int page = 1,
    int limit = 20,
  }) async {
    // This would require implementing search in the data source
    // For now, we'll get all campaigns and filter locally
    final campaigns = await remoteDataSource.getCampaigns(
      page: page,
      limit: limit * 2, // Get more to account for filtering
    );

    final filtered = campaigns
        .where(
          (campaign) =>
              campaign.name.toLowerCase().contains(query.toLowerCase()) ||
              campaign.description.toLowerCase().contains(query.toLowerCase()),
        )
        .take(limit)
        .toList();

    return filtered.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Campaign>> getCampaignsByCreator(
    String creatorId, {
    int page = 1,
    int limit = 20,
  }) async {
    // This would require implementing creator filtering in the data source
    // For now, we'll get all campaigns and filter locally
    final campaigns = await remoteDataSource.getCampaigns(
      page: page,
      limit: limit * 2, // Get more to account for filtering
    );

    final filtered = campaigns
        .where((campaign) => campaign.createdBy == creatorId)
        .take(limit)
        .toList();

    return filtered.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Campaign>> getCampaignsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int page = 1,
    int limit = 20,
  }) async {
    // This would require implementing date range filtering in the data source
    // For now, we'll get all campaigns and filter locally
    final campaigns = await remoteDataSource.getCampaigns(
      page: page,
      limit: limit * 2, // Get more to account for filtering
    );

    final filtered = campaigns
        .where(
          (campaign) =>
              campaign.createdAt.isAfter(startDate) &&
              campaign.createdAt.isBefore(endDate),
        )
        .take(limit)
        .toList();

    return filtered.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Campaign>> getScheduledCampaigns() async {
    final campaigns = await remoteDataSource.getCampaigns(
      status: CampaignStatus.scheduled,
      limit: 100, // Get more scheduled campaigns
    );
    return campaigns.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Campaign>> getActiveCampaigns() async {
    final campaigns = await remoteDataSource.getCampaigns(
      status: CampaignStatus.active,
      limit: 100, // Get more active campaigns
    );
    return campaigns.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Campaign>> getCompletedCampaigns({
    int page = 1,
    int limit = 20,
  }) async {
    final campaigns = await remoteDataSource.getCampaigns(
      page: page,
      limit: limit,
      status: CampaignStatus.completed,
    );
    return campaigns.map((model) => model.toEntity()).toList();
  }

  @override
  Stream<Campaign> watchCampaign(String campaignId) {
    // This would require implementing real-time listeners
    throw UnimplementedError('Real-time campaign watching not implemented yet');
  }

  @override
  Stream<List<Campaign>> watchCampaigns() {
    // This would require implementing real-time listeners
    throw UnimplementedError(
      'Real-time campaigns watching not implemented yet',
    );
  }

  @override
  Stream<CampaignStats> watchCampaignStats(String campaignId) {
    // This would require implementing real-time listeners
    throw UnimplementedError(
      'Real-time campaign stats watching not implemented yet',
    );
  }
}
