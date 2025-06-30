import '../../domain/entities/insurance_provider.dart';
import '../../domain/entities/policy.dart';
import '../../domain/entities/claim.dart';
import '../../domain/repositories/insurance_repository.dart';
import '../datasources/insurance_remote_datasource.dart';

import '../models/policy_model.dart';
import '../models/claim_model.dart';

class InsuranceRepositoryImpl implements InsuranceRepository {
  final InsuranceRemoteDataSource _remoteDataSource;

  InsuranceRepositoryImpl({required InsuranceRemoteDataSource remoteDataSource})
    : _remoteDataSource = remoteDataSource;

  @override
  Future<List<InsuranceProvider>> getInsuranceProviders({
    ProviderType? type,
    bool? isFeatured,
    bool? isRecommended,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final providers = await _remoteDataSource.getInsuranceProviders(
        types: type != null ? [type] : null,
        isFeatured: isFeatured,
        isRecommended: isRecommended,
        page: page,
        limit: limit,
      );
      return providers.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch insurance providers: $e');
    }
  }

  @override
  Future<InsuranceProvider?> getInsuranceProviderById(String providerId) async {
    try {
      final provider = await _remoteDataSource.getInsuranceProviderById(
        providerId,
      );
      return provider?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch insurance provider: $e');
    }
  }

  @override
  Future<List<InsuranceProvider>> searchInsuranceProviders({
    required String query,
    ProviderType? type,
    double? minRating,
    double? maxPremium,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final providers = await _remoteDataSource.searchInsuranceProviders(
        query: query,
        types: type != null ? [type] : null,
        minRating: minRating,
        maxPremium: maxPremium,
        page: page,
        limit: limit,
      );
      return providers.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to search insurance providers: $e');
    }
  }

  @override
  Future<List<InsuranceProvider>> getFeaturedProviders({int limit = 10}) async {
    try {
      final providers = await _remoteDataSource.getFeaturedProviders(
        limit: limit,
      );
      return providers.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured providers: $e');
    }
  }

  @override
  Future<List<InsuranceProvider>> getRecommendedProviders({
    required String userId,
    int limit = 10,
  }) async {
    try {
      final providers = await _remoteDataSource.getRecommendedProviders(
        userId: userId,
        limit: limit,
      );
      return providers.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch recommended providers: $e');
    }
  }

  @override
  Future<List<Policy>> getUserPolicies(
    String userId, {
    PolicyStatus? status,
    PolicyType? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final policies = await _remoteDataSource.getUserPolicies(
        userId,
        status: status,
        type: type,
        page: page,
        limit: limit,
      );
      return policies.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch user policies: $e');
    }
  }

  @override
  Future<Policy?> getPolicyById(String policyId) async {
    try {
      final policy = await _remoteDataSource.getPolicyById(policyId);
      return policy?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch policy: $e');
    }
  }

  @override
  Future<Policy> createPolicy(Policy policy) async {
    try {
      final policyModel = PolicyModel.fromEntity(policy);
      final createdPolicy = await _remoteDataSource.createPolicy(policyModel);
      return createdPolicy.toEntity();
    } catch (e) {
      throw Exception('Failed to create policy: $e');
    }
  }

  @override
  Future<Policy> updatePolicy(Policy policy) async {
    try {
      final policyModel = PolicyModel.fromEntity(policy);
      final updatedPolicy = await _remoteDataSource.updatePolicy(policyModel);
      return updatedPolicy.toEntity();
    } catch (e) {
      throw Exception('Failed to update policy: $e');
    }
  }

  @override
  Future<void> cancelPolicy(String policyId, String reason) async {
    try {
      await _remoteDataSource.cancelPolicy(policyId, reason);
    } catch (e) {
      throw Exception('Failed to cancel policy: $e');
    }
  }

  @override
  Future<Policy> renewPolicy(String policyId) async {
    try {
      final renewedPolicy = await _remoteDataSource.renewPolicy(policyId);
      return renewedPolicy.toEntity();
    } catch (e) {
      throw Exception('Failed to renew policy: $e');
    }
  }

  @override
  Future<List<Policy>> getExpiringPolicies(
    String userId, {
    int daysAhead = 30,
  }) async {
    try {
      final policies = await _remoteDataSource.getExpiringPolicies(
        userId,
        daysAhead: daysAhead,
      );
      return policies.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch expiring policies: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPolicyStatistics(String userId) async {
    try {
      return await _remoteDataSource.getPolicyStatistics(userId);
    } catch (e) {
      throw Exception('Failed to fetch policy statistics: $e');
    }
  }

  @override
  Future<List<Claim>> getUserClaims(
    String userId, {
    ClaimStatus? status,
    ClaimType? type,
    String? policyId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final claims = await _remoteDataSource.getUserClaims(
        userId,
        status: status,
        type: type,
        policyId: policyId,
        page: page,
        limit: limit,
      );
      return claims.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch user claims: $e');
    }
  }

  @override
  Future<Claim?> getClaimById(String claimId) async {
    try {
      final claim = await _remoteDataSource.getClaimById(claimId);
      return claim?.toEntity();
    } catch (e) {
      throw Exception('Failed to fetch claim: $e');
    }
  }

  @override
  Future<Claim> createClaim(Claim claim) async {
    try {
      final claimModel = ClaimModel.fromEntity(claim);
      final createdClaim = await _remoteDataSource.createClaim(claimModel);
      return createdClaim.toEntity();
    } catch (e) {
      throw Exception('Failed to create claim: $e');
    }
  }

  @override
  Future<Claim> updateClaim(Claim claim) async {
    try {
      final claimModel = ClaimModel.fromEntity(claim);
      final updatedClaim = await _remoteDataSource.updateClaim(claimModel);
      return updatedClaim.toEntity();
    } catch (e) {
      throw Exception('Failed to update claim: $e');
    }
  }

  @override
  Future<void> submitClaim(String claimId) async {
    try {
      await _remoteDataSource.submitClaim(claimId);
    } catch (e) {
      throw Exception('Failed to submit claim: $e');
    }
  }

  @override
  Future<void> cancelClaim(String claimId) async {
    try {
      await _remoteDataSource.cancelClaim(claimId);
    } catch (e) {
      throw Exception('Failed to cancel claim: $e');
    }
  }

  @override
  Future<List<Claim>> getActiveClaims(String userId) async {
    try {
      final claims = await _remoteDataSource.getUserClaims(
        userId,
        status: ClaimStatus.submitted,
      );
      return claims.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch active claims: $e');
    }
  }

  @override
  @override
  Future<List<Claim>> getClaimsByPolicy(String policyId) async {
    try {
      final claims = await _remoteDataSource.getClaimsByPolicy(policyId);
      return claims.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to fetch claims by policy: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getInsuranceQuote({
    required String providerId,
    required PolicyType type,
    required Map<String, dynamic> quoteData,
  }) async {
    try {
      return await _remoteDataSource.getInsuranceQuote(
        providerId: providerId,
        type: type,
        details: quoteData,
      );
    } catch (e) {
      throw Exception('Failed to get insurance quote: $e');
    }
  }

  Future<List<Map<String, dynamic>>> compareQuotes({
    required List<String> providerIds,
    required PolicyType type,
    required Map<String, dynamic> details,
  }) async {
    try {
      return await _remoteDataSource.compareQuotes(
        providerIds: providerIds,
        type: type,
        details: details,
      );
    } catch (e) {
      throw Exception('Failed to compare quotes: $e');
    }
  }

  @override
  Future<String> submitInsuranceApplication({
    required String providerId,
    required String userId,
    required PolicyType type,
    required Map<String, dynamic> applicationData,
  }) async {
    try {
      return await _remoteDataSource.submitInsuranceApplication(
        providerId: providerId,
        type: type,
        applicationData: applicationData,
      );
    } catch (e) {
      throw Exception('Failed to submit insurance application: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getApplicationStatus(
    String applicationId,
  ) async {
    try {
      return await _remoteDataSource.getApplicationStatus(applicationId);
    } catch (e) {
      throw Exception('Failed to get application status: $e');
    }
  }

  @override
  @override
  Future<String> uploadDocument({
    required String entityId,
    required String entityType,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      return await _remoteDataSource.uploadDocument(
        entityId: entityId,
        entityType: entityType,
        fileName: fileName,
        fileBytes: fileBytes,
      );
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  @override
  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      await _remoteDataSource.deleteDocument(documentId);
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getInsuranceStatistics(String userId) async {
    try {
      // TODO: Implement insurance statistics calculation
      final policies = await getUserPolicies(userId);
      final claims = await getUserClaims(userId);

      return {
        'totalPolicies': policies.length,
        'activePolicies': policies
            .where((p) => p.status == PolicyStatus.active)
            .length,
        'totalClaims': claims.length,
        'pendingClaims': claims
            .where((c) => c.status == ClaimStatus.submitted)
            .length,
        'totalPremiumPaid': policies.fold<double>(
          0,
          (sum, p) => sum + p.premiumAmount,
        ),
        'totalClaimAmount': claims.fold<double>(
          0,
          (sum, c) => sum + c.claimedAmount,
        ),
      };
    } catch (e) {
      throw Exception('Failed to fetch insurance statistics: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getClaimStatistics(String userId) async {
    try {
      final claims = await getUserClaims(userId);

      return {
        'totalClaims': claims.length,
        'approvedClaims': claims
            .where((c) => c.status == ClaimStatus.approved)
            .length,
        'rejectedClaims': claims
            .where((c) => c.status == ClaimStatus.rejected)
            .length,
        'pendingClaims': claims
            .where((c) => c.status == ClaimStatus.submitted)
            .length,
        'totalClaimAmount': claims.fold<double>(
          0,
          (sum, c) => sum + c.claimedAmount,
        ),
        'averageProcessingTime': 7, // days - placeholder
      };
    } catch (e) {
      throw Exception('Failed to fetch claim statistics: $e');
    }
  }

  @override
  Future<void> subscribeToInsuranceUpdates(String userId) async {
    try {
      // TODO: Implement real-time subscription to insurance updates
      // This would typically involve setting up Firebase listeners or WebSocket connections
    } catch (e) {
      throw Exception('Failed to subscribe to insurance updates: $e');
    }
  }

  @override
  Future<void> unsubscribeFromInsuranceUpdates(String userId) async {
    try {
      // TODO: Implement unsubscription from insurance updates
      // This would typically involve removing Firebase listeners or closing WebSocket connections
    } catch (e) {
      throw Exception('Failed to unsubscribe from insurance updates: $e');
    }
  }

  Future<void> subscribeToUpdates(String userId) async {
    // TODO: Implement real-time updates subscription
  }

  Future<void> unsubscribeFromUpdates(String userId) async {
    // TODO: Implement real-time updates unsubscription
  }
}
