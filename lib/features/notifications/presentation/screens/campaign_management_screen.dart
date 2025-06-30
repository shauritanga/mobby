import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/campaign.dart';
import '../providers/campaigns_provider.dart';
import '../widgets/campaign_card.dart';
import '../widgets/campaign_stats_card.dart';

class CampaignManagementScreen extends ConsumerStatefulWidget {
  const CampaignManagementScreen({super.key});

  @override
  ConsumerState<CampaignManagementScreen> createState() => _CampaignManagementScreenState();
}

class _CampaignManagementScreenState extends ConsumerState<CampaignManagementScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(campaignsProvider.notifier).loadCampaigns();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(campaignsProvider.notifier).loadCampaigns();
    }
  }

  @override
  Widget build(BuildContext context) {
    final campaignsState = ref.watch(campaignsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Campaign Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewCampaign(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'analytics',
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Analytics'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Active'),
            Tab(text: 'Draft'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildCampaignsList(campaignsState, null, theme),
          _buildCampaignsList(campaignsState, CampaignStatus.active, theme),
          _buildCampaignsList(campaignsState, CampaignStatus.draft, theme),
          _buildCampaignsList(campaignsState, CampaignStatus.completed, theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewCampaign,
        icon: const Icon(Icons.add),
        label: const Text('New Campaign'),
      ),
    );
  }

  Widget _buildCampaignsList(
    CampaignsState state,
    CampaignStatus? filterStatus,
    ThemeData theme,
  ) {
    if (state.isLoading && state.campaigns.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.campaigns.isEmpty) {
      return _buildErrorState(state.error!, theme);
    }

    final filteredCampaigns = filterStatus != null
        ? state.campaigns.where((c) => c.status == filterStatus).toList()
        : state.campaigns;

    if (filteredCampaigns.isEmpty) {
      return _buildEmptyState(filterStatus, theme);
    }

    return RefreshIndicator(
      onRefresh: () => _refreshCampaigns(),
      child: Column(
        children: [
          // Quick stats
          _buildQuickStats(filteredCampaigns, theme),
          // Campaigns list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              itemCount: filteredCampaigns.length + (state.hasMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= filteredCampaigns.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                final campaign = filteredCampaigns[index];
                return CampaignCard(
                  campaign: campaign,
                  onTap: () => _viewCampaignDetails(campaign),
                  onLaunch: () => _launchCampaign(campaign.id),
                  onPause: () => _pauseCampaign(campaign.id),
                  onEdit: () => _editCampaign(campaign),
                  onDelete: () => _deleteCampaign(campaign.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<Campaign> campaigns, ThemeData theme) {
    final activeCampaigns = campaigns.where((c) => c.status == CampaignStatus.active).length;
    final draftCampaigns = campaigns.where((c) => c.status == CampaignStatus.draft).length;
    final completedCampaigns = campaigns.where((c) => c.status == CampaignStatus.completed).length;

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', '${campaigns.length}', Icons.campaign, theme),
          _buildStatItem('Active', '$activeCampaigns', Icons.play_arrow, theme),
          _buildStatItem('Draft', '$draftCampaigns', Icons.edit, theme),
          _buildStatItem('Completed', '$completedCampaigns', Icons.check_circle, theme),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        SizedBox(height: 4.h),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load campaigns',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => _refreshCampaigns(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(CampaignStatus? filterStatus, ThemeData theme) {
    String title;
    String subtitle;

    switch (filterStatus) {
      case CampaignStatus.active:
        title = 'No active campaigns';
        subtitle = 'Launch a campaign to see it here.';
        break;
      case CampaignStatus.draft:
        title = 'No draft campaigns';
        subtitle = 'Create a new campaign to get started.';
        break;
      case CampaignStatus.completed:
        title = 'No completed campaigns';
        subtitle = 'Completed campaigns will appear here.';
        break;
      default:
        title = 'No campaigns yet';
        subtitle = 'Create your first campaign to reach your audience.';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.campaign,
              size: 64.w,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _createNewCampaign,
              icon: const Icon(Icons.add),
              label: const Text('Create Campaign'),
            ),
          ],
        ),
      ),
    );
  }

  void _createNewCampaign() {
    // Navigate to campaign creation screen
    // Navigator.of(context).pushNamed('/campaigns/create');
  }

  void _viewCampaignDetails(Campaign campaign) {
    // Navigate to campaign details screen
    // Navigator.of(context).pushNamed('/campaigns/${campaign.id}');
  }

  void _editCampaign(Campaign campaign) {
    // Navigate to campaign edit screen
    // Navigator.of(context).pushNamed('/campaigns/${campaign.id}/edit');
  }

  void _launchCampaign(String campaignId) {
    ref.read(campaignsProvider.notifier).launchCampaign(campaignId);
  }

  void _pauseCampaign(String campaignId) {
    ref.read(campaignsProvider.notifier).pauseCampaign(campaignId);
  }

  void _deleteCampaign(String campaignId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Campaign'),
        content: const Text('Are you sure you want to delete this campaign? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(campaignsProvider.notifier).deleteCampaign(campaignId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshCampaigns() async {
    await ref.read(campaignsProvider.notifier).loadCampaigns(refresh: true);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        _refreshCampaigns();
        break;
      case 'analytics':
        // Navigate to analytics screen
        break;
    }
  }
}

// Provider definitions (these would typically be in a separate file)
final campaignsProvider = StateNotifierProvider<CampaignsNotifier, CampaignsState>((ref) {
  // This would be properly injected with dependencies
  throw UnimplementedError('Provider not properly configured');
});
