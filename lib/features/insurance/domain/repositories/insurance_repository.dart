import '../entities/insurance_provider.dart';
import '../entities/policy.dart';
import '../entities/claim.dart';

abstract class InsuranceRepository {
  // Insurance Providers
  Future<List<InsuranceProvider>> getInsuranceProviders({
    ProviderType? type,
    bool? isFeatured,
    bool? isRecommended,
    int page = 1,
    int limit = 20,
  });

  Future<InsuranceProvider?> getInsuranceProviderById(String providerId);

  Future<List<InsuranceProvider>> searchInsuranceProviders({
    required String query,
    ProviderType? type,
    double? minRating,
    double? maxPremium,
    int page = 1,
    int limit = 20,
  });

  Future<List<InsuranceProvider>> getFeaturedProviders({int limit = 5});

  Future<List<InsuranceProvider>> getRecommendedProviders({
    required String userId,
    int limit = 5,
  });

  // Policies
  Future<List<Policy>> getUserPolicies(
    String userId, {
    PolicyType? type,
    PolicyStatus? status,
    int page = 1,
    int limit = 20,
  });

  Future<Policy?> getPolicyById(String policyId);

  Future<Policy> createPolicy(Policy policy);

  Future<Policy> updatePolicy(Policy policy);

  Future<void> cancelPolicy(String policyId, String reason);

  Future<Policy> renewPolicy(String policyId);

  Future<List<Policy>> getExpiringPolicies(String userId, {int daysAhead = 30});

  Future<Map<String, dynamic>> getPolicyStatistics(String userId);

  // Claims
  Future<List<Claim>> getUserClaims(
    String userId, {
    String? policyId,
    ClaimType? type,
    ClaimStatus? status,
    int page = 1,
    int limit = 20,
  });

  Future<Claim?> getClaimById(String claimId);

  Future<Claim> createClaim(Claim claim);

  Future<Claim> updateClaim(Claim claim);

  Future<void> submitClaim(String claimId);

  Future<void> cancelClaim(String claimId);

  Future<List<Claim>> getActiveClaims(String userId);

  Future<List<Claim>> getClaimsByPolicy(String policyId);

  // Insurance Applications
  Future<String> submitInsuranceApplication({
    required String providerId,
    required String userId,
    required PolicyType type,
    required Map<String, dynamic> applicationData,
  });

  Future<Map<String, dynamic>> getApplicationStatus(String applicationId);

  Future<String> uploadDocument({
    required String entityId,
    required String entityType,
    required String fileName,
    required List<int> fileBytes,
  });

  Future<void> deleteDocument(String documentId);

  Future<Map<String, dynamic>> getInsuranceQuote({
    required String providerId,
    required PolicyType type,
    required Map<String, dynamic> quoteData,
  });

  // Statistics and Analytics
  Future<Map<String, dynamic>> getInsuranceStatistics(String userId);

  Future<Map<String, dynamic>> getClaimStatistics(String userId);

  // Notifications
  Future<void> subscribeToInsuranceUpdates(String userId);

  Future<void> unsubscribeFromInsuranceUpdates(String userId);
}
