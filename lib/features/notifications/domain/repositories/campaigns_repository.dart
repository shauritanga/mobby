import '../entities/campaign.dart';

abstract class CampaignsRepository {
  // Campaign CRUD operations
  Future<List<Campaign>> getCampaigns({
    int page = 1,
    int limit = 20,
    CampaignStatus? status,
    CampaignType? type,
  });

  Future<Campaign?> getCampaign(String campaignId);

  Future<Campaign> createCampaign(Campaign campaign);

  Future<Campaign> updateCampaign(Campaign campaign);

  Future<void> deleteCampaign(String campaignId);

  // Campaign lifecycle management
  Future<Campaign> launchCampaign(String campaignId);

  Future<Campaign> pauseCampaign(String campaignId);

  Future<Campaign> resumeCampaign(String campaignId);

  Future<Campaign> stopCampaign(String campaignId);

  Future<Campaign> scheduleCampaign(String campaignId, DateTime scheduledAt);

  // Campaign targeting
  Future<int> estimateAudience(CampaignTarget target);

  Future<List<String>> getTargetUserIds(CampaignTarget target);

  Future<void> updateCampaignTarget(String campaignId, CampaignTarget target);

  // Campaign analytics
  Future<CampaignStats> getCampaignStats(String campaignId);

  Future<Map<String, dynamic>> getCampaignAnalytics(
    String campaignId, {
    DateTime? startDate,
    DateTime? endDate,
  });

  Future<List<Map<String, dynamic>>> getCampaignPerformanceReport(
    String campaignId,
  );

  // Campaign templates
  Future<Campaign> duplicateCampaign(String campaignId, String newName);

  Future<Campaign> createCampaignFromTemplate(
    String templateId,
    String name,
    CampaignTarget target,
  );

  // Bulk operations
  Future<void> bulkUpdateCampaignStatus(
    List<String> campaignIds,
    CampaignStatus status,
  );

  Future<void> bulkDeleteCampaigns(List<String> campaignIds);

  // Search and filter
  Future<List<Campaign>> searchCampaigns(
    String query, {
    int page = 1,
    int limit = 20,
  });

  Future<List<Campaign>> getCampaignsByCreator(
    String creatorId, {
    int page = 1,
    int limit = 20,
  });

  Future<List<Campaign>> getCampaignsByDateRange(
    DateTime startDate,
    DateTime endDate, {
    int page = 1,
    int limit = 20,
  });

  // Campaign scheduling
  Future<List<Campaign>> getScheduledCampaigns();

  Future<List<Campaign>> getActiveCampaigns();

  Future<List<Campaign>> getCompletedCampaigns({
    int page = 1,
    int limit = 20,
  });

  // Real-time updates
  Stream<Campaign> watchCampaign(String campaignId);

  Stream<List<Campaign>> watchCampaigns();

  Stream<CampaignStats> watchCampaignStats(String campaignId);
}
