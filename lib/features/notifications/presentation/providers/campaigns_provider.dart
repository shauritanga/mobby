import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/campaign.dart';
import '../../domain/entities/notification.dart';
import '../../domain/usecases/manage_campaigns.dart';

// State classes
class CampaignsState {
  final List<Campaign> campaigns;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const CampaignsState({
    this.campaigns = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  CampaignsState copyWith({
    List<Campaign>? campaigns,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return CampaignsState(
      campaigns: campaigns ?? this.campaigns,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

class CampaignFilters {
  final CampaignStatus? status;
  final CampaignType? type;
  final String? searchQuery;

  const CampaignFilters({
    this.status,
    this.type,
    this.searchQuery,
  });

  CampaignFilters copyWith({
    CampaignStatus? status,
    CampaignType? type,
    String? searchQuery,
  }) {
    return CampaignFilters(
      status: status ?? this.status,
      type: type ?? this.type,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

// Campaigns Provider
class CampaignsNotifier extends StateNotifier<CampaignsState> {
  final GetCampaigns _getCampaigns;
  final CreateCampaign _createCampaign;
  final UpdateCampaign _updateCampaign;
  final DeleteCampaign _deleteCampaign;
  final LaunchCampaign _launchCampaign;
  final PauseCampaign _pauseCampaign;
  final GetCampaignStats _getCampaignStats;
  final EstimateAudience _estimateAudience;

  CampaignsNotifier({
    required GetCampaigns getCampaigns,
    required CreateCampaign createCampaign,
    required UpdateCampaign updateCampaign,
    required DeleteCampaign deleteCampaign,
    required LaunchCampaign launchCampaign,
    required PauseCampaign pauseCampaign,
    required GetCampaignStats getCampaignStats,
    required EstimateAudience estimateAudience,
  })  : _getCampaigns = getCampaigns,
        _createCampaign = createCampaign,
        _updateCampaign = updateCampaign,
        _deleteCampaign = deleteCampaign,
        _launchCampaign = launchCampaign,
        _pauseCampaign = pauseCampaign,
        _getCampaignStats = getCampaignStats,
        _estimateAudience = estimateAudience,
        super(const CampaignsState());

  CampaignFilters _filters = const CampaignFilters();

  Future<void> loadCampaigns({bool refresh = false}) async {
    if (refresh) {
      state = state.copyWith(
        campaigns: [],
        currentPage: 1,
        hasMore: true,
        error: null,
      );
    }

    if (state.isLoading || !state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _getCampaigns(GetCampaignsParams(
        page: state.currentPage,
        limit: 20,
        status: _filters.status,
        type: _filters.type,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (campaigns) {
          final allCampaigns = state.currentPage == 1
              ? campaigns
              : [...state.campaigns, ...campaigns];

          state = state.copyWith(
            campaigns: allCampaigns,
            isLoading: false,
            hasMore: campaigns.length == 20,
            currentPage: state.currentPage + 1,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> createCampaign({
    required String name,
    required String description,
    required CampaignType type,
    required String templateId,
    required CampaignTarget target,
    required CampaignSchedule schedule,
    required List<NotificationChannel> channels,
    Map<String, dynamic>? content,
    required String createdBy,
  }) async {
    try {
      final result = await _createCampaign(CreateCampaignParams(
        name: name,
        description: description,
        type: type,
        templateId: templateId,
        target: target,
        schedule: schedule,
        channels: channels,
        content: content,
        createdBy: createdBy,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (campaign) {
          // Add to local state
          final updatedCampaigns = [campaign, ...state.campaigns];
          state = state.copyWith(
            campaigns: updatedCampaigns,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateCampaign(Campaign campaign) async {
    try {
      final result = await _updateCampaign(UpdateCampaignParams(
        campaign: campaign,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (updatedCampaign) {
          // Update in local state
          final updatedCampaigns = state.campaigns.map((c) {
            return c.id == updatedCampaign.id ? updatedCampaign : c;
          }).toList();

          state = state.copyWith(
            campaigns: updatedCampaigns,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteCampaign(String campaignId) async {
    try {
      final result = await _deleteCampaign(DeleteCampaignParams(
        campaignId: campaignId,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (_) {
          // Remove from local state
          final updatedCampaigns = state.campaigns
              .where((campaign) => campaign.id != campaignId)
              .toList();

          state = state.copyWith(
            campaigns: updatedCampaigns,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> launchCampaign(String campaignId) async {
    try {
      final result = await _launchCampaign(LaunchCampaignParams(
        campaignId: campaignId,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (updatedCampaign) {
          // Update in local state
          final updatedCampaigns = state.campaigns.map((c) {
            return c.id == updatedCampaign.id ? updatedCampaign : c;
          }).toList();

          state = state.copyWith(
            campaigns: updatedCampaigns,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }





  Future<void> pauseCampaign(String campaignId) async {
    try {
      final result = await _pauseCampaign(PauseCampaignParams(
        campaignId: campaignId,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(error: failure.message);
        },
        (updatedCampaign) {
          // Update in local state
          final updatedCampaigns = state.campaigns.map((c) {
            return c.id == updatedCampaign.id ? updatedCampaign : c;
          }).toList();

          state = state.copyWith(
            campaigns: updatedCampaigns,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<int> estimateAudience(CampaignTarget target) async {
    try {
      final result = await _estimateAudience(EstimateAudienceParams(
        target: target,
      ));

      return result.fold(
        (failure) => 0,
        (estimate) => estimate,
      );
    } catch (e) {
      return 0;
    }
  }

  void updateFilters(CampaignFilters filters) {
    _filters = filters;
    loadCampaigns(refresh: true);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Campaign Stats Provider
class CampaignStatsState {
  final Map<String, CampaignStats> stats;
  final bool isLoading;
  final String? error;

  const CampaignStatsState({
    this.stats = const {},
    this.isLoading = false,
    this.error,
  });

  CampaignStatsState copyWith({
    Map<String, CampaignStats>? stats,
    bool? isLoading,
    String? error,
  }) {
    return CampaignStatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class CampaignStatsNotifier extends StateNotifier<CampaignStatsState> {
  final GetCampaignStats _getCampaignStats;

  CampaignStatsNotifier({
    required GetCampaignStats getCampaignStats,
  })  : _getCampaignStats = getCampaignStats,
        super(const CampaignStatsState());

  Future<void> loadCampaignStats(String campaignId) async {
    if (state.stats.containsKey(campaignId)) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _getCampaignStats(GetCampaignStatsParams(
        campaignId: campaignId,
      ));

      result.fold(
        (failure) {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
          );
        },
        (stats) {
          final updatedStats = Map<String, CampaignStats>.from(state.stats);
          updatedStats[campaignId] = stats;

          state = state.copyWith(
            stats: updatedStats,
            isLoading: false,
            error: null,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  CampaignStats? getStatsForCampaign(String campaignId) {
    return state.stats[campaignId];
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
