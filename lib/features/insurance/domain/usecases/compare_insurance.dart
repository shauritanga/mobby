import '../entities/insurance_provider.dart';
import '../entities/policy.dart';
import '../repositories/insurance_repository.dart';

class CompareInsuranceParams {
  final ProviderType? type;
  final bool? isFeatured;
  final bool? isRecommended;
  final String? query;
  final double? minRating;
  final double? maxPremium;
  final int page;
  final int limit;

  const CompareInsuranceParams({
    this.type,
    this.isFeatured,
    this.isRecommended,
    this.query,
    this.minRating,
    this.maxPremium,
    this.page = 1,
    this.limit = 20,
  });
}

class CompareInsurance {
  final InsuranceRepository repository;

  CompareInsurance(this.repository);

  Future<List<InsuranceProvider>> call(CompareInsuranceParams params) async {
    if (params.query != null) {
      return await repository.searchInsuranceProviders(
        query: params.query!,
        type: params.type,
        minRating: params.minRating,
        maxPremium: params.maxPremium,
        page: params.page,
        limit: params.limit,
      );
    }

    return await repository.getInsuranceProviders(
      type: params.type,
      isFeatured: params.isFeatured,
      isRecommended: params.isRecommended,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetInsuranceProviderDetails {
  final InsuranceRepository repository;

  GetInsuranceProviderDetails(this.repository);

  Future<InsuranceProvider?> call(String providerId) async {
    return await repository.getInsuranceProviderById(providerId);
  }
}

class GetFeaturedProviders {
  final InsuranceRepository repository;

  GetFeaturedProviders(this.repository);

  Future<List<InsuranceProvider>> call({int limit = 5}) async {
    return await repository.getFeaturedProviders(limit: limit);
  }
}

class GetRecommendedProviders {
  final InsuranceRepository repository;

  GetRecommendedProviders(this.repository);

  Future<List<InsuranceProvider>> call(String userId, {int limit = 5}) async {
    return await repository.getRecommendedProviders(
      userId: userId,
      limit: limit,
    );
  }
}

class GetInsuranceQuote {
  final InsuranceRepository repository;

  GetInsuranceQuote(this.repository);

  Future<Map<String, dynamic>> call({
    required String providerId,
    required PolicyType type,
    required Map<String, dynamic> quoteData,
  }) async {
    return await repository.getInsuranceQuote(
      providerId: providerId,
      type: type,
      quoteData: quoteData,
    );
  }
}
