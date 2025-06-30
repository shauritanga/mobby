import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/insurance_provider.dart';
import '../../domain/entities/policy.dart';
import '../../domain/entities/claim.dart';
import '../../domain/usecases/compare_insurance.dart';
import '../../domain/usecases/apply_for_insurance.dart';
import '../../domain/usecases/manage_policies.dart';
import '../../data/datasources/insurance_remote_datasource.dart';
import '../../data/repositories/insurance_repository_impl.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

// Parameter classes for providers
class GetInsuranceQuoteParams {
  final String providerId;
  final PolicyType type;
  final Map<String, dynamic> quoteData;

  const GetInsuranceQuoteParams({
    required this.providerId,
    required this.type,
    required this.quoteData,
  });
}

class CompareQuotesParams {
  final List<String> providerIds;
  final PolicyType type;
  final Map<String, dynamic> details;

  const CompareQuotesParams({
    required this.providerIds,
    required this.type,
    required this.details,
  });
}

// Data source providers
final insuranceRemoteDataSourceProvider = Provider<InsuranceRemoteDataSource>((
  ref,
) {
  return InsuranceRemoteDataSourceImpl(firestore: FirebaseFirestore.instance);
});

// Repository provider
final insuranceRepositoryProvider = Provider((ref) {
  return InsuranceRepositoryImpl(
    remoteDataSource: ref.read(insuranceRemoteDataSourceProvider),
  );
});

// Use case providers
final compareInsuranceUseCaseProvider = Provider((ref) {
  return CompareInsurance(ref.read(insuranceRepositoryProvider));
});

final getFeaturedProvidersUseCaseProvider = Provider((ref) {
  return GetFeaturedProviders(ref.read(insuranceRepositoryProvider));
});

final getRecommendedProvidersUseCaseProvider = Provider((ref) {
  return GetRecommendedProviders(ref.read(insuranceRepositoryProvider));
});

final getProviderDetailsUseCaseProvider = Provider((ref) {
  return GetInsuranceProviderDetails(ref.read(insuranceRepositoryProvider));
});

final getInsuranceQuoteUseCaseProvider = Provider((ref) {
  return GetInsuranceQuote(ref.read(insuranceRepositoryProvider));
});

// Note: CompareQuotes use case not implemented yet

final applyForInsuranceUseCaseProvider = Provider((ref) {
  return ApplyForInsurance(ref.read(insuranceRepositoryProvider));
});

final getApplicationStatusUseCaseProvider = Provider((ref) {
  return GetApplicationStatus(ref.read(insuranceRepositoryProvider));
});

final createPolicyUseCaseProvider = Provider((ref) {
  return CreatePolicy(ref.read(insuranceRepositoryProvider));
});

final uploadDocumentUseCaseProvider = Provider((ref) {
  return UploadDocument(ref.read(insuranceRepositoryProvider));
});

final deleteDocumentUseCaseProvider = Provider((ref) {
  return DeleteDocument(ref.read(insuranceRepositoryProvider));
});

final viewPoliciesUseCaseProvider = Provider((ref) {
  return ViewPolicies(ref.read(insuranceRepositoryProvider));
});

final getPolicyDetailsUseCaseProvider = Provider((ref) {
  return GetPolicyDetails(ref.read(insuranceRepositoryProvider));
});

final updatePolicyUseCaseProvider = Provider((ref) {
  return UpdatePolicy(ref.read(insuranceRepositoryProvider));
});

final cancelPolicyUseCaseProvider = Provider((ref) {
  return CancelPolicy(ref.read(insuranceRepositoryProvider));
});

final renewPolicyUseCaseProvider = Provider((ref) {
  return RenewPolicy(ref.read(insuranceRepositoryProvider));
});

final getExpiringPoliciesUseCaseProvider = Provider((ref) {
  return GetExpiringPolicies(ref.read(insuranceRepositoryProvider));
});

final getPolicyStatisticsUseCaseProvider = Provider((ref) {
  return GetPolicyStatistics(ref.read(insuranceRepositoryProvider));
});

final viewClaimsUseCaseProvider = Provider((ref) {
  return ViewClaims(ref.read(insuranceRepositoryProvider));
});

final getClaimDetailsUseCaseProvider = Provider((ref) {
  return GetClaimDetails(ref.read(insuranceRepositoryProvider));
});

final createClaimUseCaseProvider = Provider((ref) {
  return CreateClaim(ref.read(insuranceRepositoryProvider));
});

final updateClaimUseCaseProvider = Provider((ref) {
  return UpdateClaim(ref.read(insuranceRepositoryProvider));
});

final submitClaimUseCaseProvider = Provider((ref) {
  return SubmitClaim(ref.read(insuranceRepositoryProvider));
});

final cancelClaimUseCaseProvider = Provider((ref) {
  return CancelClaim(ref.read(insuranceRepositoryProvider));
});

final getClaimsByPolicyUseCaseProvider = Provider((ref) {
  return GetClaimsByPolicy(ref.read(insuranceRepositoryProvider));
});

// State providers for UI
class InsuranceProvidersState {
  final List<InsuranceProvider> providers;
  final bool isLoading;
  final String? error;
  final bool hasMore;
  final int currentPage;

  const InsuranceProvidersState({
    this.providers = const [],
    this.isLoading = false,
    this.error,
    this.hasMore = true,
    this.currentPage = 1,
  });

  InsuranceProvidersState copyWith({
    List<InsuranceProvider>? providers,
    bool? isLoading,
    String? error,
    bool? hasMore,
    int? currentPage,
  }) {
    return InsuranceProvidersState(
      providers: providers ?? this.providers,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

// Insurance providers list provider
final insuranceProvidersProvider =
    StateNotifierProvider<
      InsuranceProvidersNotifier,
      AsyncValue<InsuranceProvidersState>
    >((ref) {
      return InsuranceProvidersNotifier(ref);
    });

class InsuranceProvidersNotifier
    extends StateNotifier<AsyncValue<InsuranceProvidersState>> {
  final Ref _ref;

  InsuranceProvidersNotifier(this._ref) : super(const AsyncValue.loading());

  Future<void> loadProviders({
    List<ProviderType>? types,
    bool? isFeatured,
    bool? isRecommended,
    bool? isVerified,
    bool refresh = false,
  }) async {
    try {
      if (refresh) {
        state = const AsyncValue.loading();
      } else if (state.value != null) {
        state = AsyncValue.data(state.value!.copyWith(isLoading: true));
      }

      final compareInsuranceUseCase = _ref.read(
        compareInsuranceUseCaseProvider,
      );
      final params = CompareInsuranceParams(
        type: types?.first,
        isFeatured: isFeatured,
        isRecommended: isRecommended,
        page: 1,
        limit: 20,
      );
      final providers = await compareInsuranceUseCase(params);

      state = AsyncValue.data(
        InsuranceProvidersState(
          providers: providers,
          isLoading: false,
          hasMore: providers.length >= 20,
          currentPage: 1,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> loadMoreProviders() async {
    final currentState = state.value;
    if (currentState == null ||
        currentState.isLoading ||
        !currentState.hasMore) {
      return;
    }

    try {
      state = AsyncValue.data(currentState.copyWith(isLoading: true));

      final compareInsuranceUseCase = _ref.read(
        compareInsuranceUseCaseProvider,
      );
      final params = CompareInsuranceParams(
        page: currentState.currentPage + 1,
        limit: 20,
      );
      final newProviders = await compareInsuranceUseCase(params);

      final allProviders = [...currentState.providers, ...newProviders];
      state = AsyncValue.data(
        InsuranceProvidersState(
          providers: allProviders,
          isLoading: false,
          hasMore: newProviders.length >= 20,
          currentPage: currentState.currentPage + 1,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> searchProviders({
    String? query,
    List<ProviderType>? types,
    double? minRating,
    double? maxPremium,
  }) async {
    try {
      state = const AsyncValue.loading();

      final compareInsuranceUseCase = _ref.read(
        compareInsuranceUseCaseProvider,
      );
      final params = CompareInsuranceParams(
        query: query,
        type: types?.first,
        minRating: minRating,
        maxPremium: maxPremium,
        page: 1,
        limit: 20,
      );
      final providers = await compareInsuranceUseCase(params);

      state = AsyncValue.data(
        InsuranceProvidersState(
          providers: providers,
          isLoading: false,
          hasMore: providers.length >= 20,
          currentPage: 1,
        ),
      );
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

// Individual provider provider
final providerDetailsProvider =
    FutureProvider.family<InsuranceProvider?, String>((ref, providerId) async {
      final getProviderDetailsUseCase = ref.read(
        getProviderDetailsUseCaseProvider,
      );
      return await getProviderDetailsUseCase(providerId);
    });

// Featured providers provider
final featuredProvidersProvider = FutureProvider<List<InsuranceProvider>>((
  ref,
) async {
  final getFeaturedProvidersUseCase = ref.read(
    getFeaturedProvidersUseCaseProvider,
  );
  return await getFeaturedProvidersUseCase();
});

// Recommended providers provider
final recommendedProvidersProvider = FutureProvider<List<InsuranceProvider>>((
  ref,
) async {
  final user = ref.read(currentUserProvider).value;
  if (user == null) throw Exception('User not authenticated');

  final getRecommendedProvidersUseCase = ref.read(
    getRecommendedProvidersUseCaseProvider,
  );
  return await getRecommendedProvidersUseCase(user.id);
});

// Insurance quote provider
final insuranceQuoteProvider =
    FutureProvider.family<Map<String, dynamic>, GetInsuranceQuoteParams>((
      ref,
      params,
    ) async {
      final getInsuranceQuoteUseCase = ref.read(
        getInsuranceQuoteUseCaseProvider,
      );
      return await getInsuranceQuoteUseCase(
        providerId: params.providerId,
        type: params.type,
        quoteData: params.quoteData,
      );
    });

// Compare quotes provider - TODO: Implement CompareQuotes use case
// final compareQuotesProvider = ...

// User policies provider
final userPoliciesProvider = FutureProvider<List<Policy>>((ref) async {
  final user = ref.read(currentUserProvider).value;
  if (user == null) throw Exception('User not authenticated');

  final viewPoliciesUseCase = ref.read(viewPoliciesUseCaseProvider);
  final params = ViewPoliciesParams(userId: user.id);
  return await viewPoliciesUseCase(params);
});

// Individual policy provider
final policyDetailsProvider = FutureProvider.family<Policy?, String>((
  ref,
  policyId,
) async {
  final getPolicyDetailsUseCase = ref.read(getPolicyDetailsUseCaseProvider);
  return await getPolicyDetailsUseCase(policyId);
});

// Policy statistics provider
final policyStatisticsProvider = FutureProvider<Map<String, dynamic>>((
  ref,
) async {
  final user = ref.read(currentUserProvider).value;
  if (user == null) throw Exception('User not authenticated');

  final getPolicyStatisticsUseCase = ref.read(
    getPolicyStatisticsUseCaseProvider,
  );
  return await getPolicyStatisticsUseCase(user.id);
});

// Expiring policies provider
final expiringPoliciesProvider = FutureProvider<List<Policy>>((ref) async {
  final user = ref.read(currentUserProvider).value;
  if (user == null) throw Exception('User not authenticated');

  final getExpiringPoliciesUseCase = ref.read(
    getExpiringPoliciesUseCaseProvider,
  );
  return await getExpiringPoliciesUseCase(user.id);
});

// User claims provider
final userClaimsProvider = FutureProvider<List<Claim>>((ref) async {
  final user = ref.read(currentUserProvider).value;
  if (user == null) throw Exception('User not authenticated');

  final viewClaimsUseCase = ref.read(viewClaimsUseCaseProvider);
  final params = ViewClaimsParams(userId: user.id);
  return await viewClaimsUseCase(params);
});

// Individual claim provider
final claimDetailsProvider = FutureProvider.family<Claim?, String>((
  ref,
  claimId,
) async {
  final getClaimDetailsUseCase = ref.read(getClaimDetailsUseCaseProvider);
  return await getClaimDetailsUseCase(claimId);
});

// Claims by policy provider
final claimsByPolicyProvider = FutureProvider.family<List<Claim>, String>((
  ref,
  policyId,
) async {
  final getClaimsByPolicyUseCase = ref.read(getClaimsByPolicyUseCaseProvider);
  return await getClaimsByPolicyUseCase(policyId);
});
