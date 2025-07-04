import '../entities/policy.dart';
import '../entities/claim.dart';
import '../repositories/insurance_repository.dart';

class ViewPoliciesParams {
  final String userId;
  final PolicyStatus? status;
  final PolicyType? type;
  final int page;
  final int limit;

  const ViewPoliciesParams({
    required this.userId,
    this.status,
    this.type,
    this.page = 1,
    this.limit = 20,
  });
}

class ViewPolicies {
  final InsuranceRepository repository;

  ViewPolicies(this.repository);

  Future<List<Policy>> call(ViewPoliciesParams params) async {
    return await repository.getUserPolicies(
      params.userId,
      status: params.status,
      type: params.type,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetPolicyDetails {
  final InsuranceRepository repository;

  GetPolicyDetails(this.repository);

  Future<Policy?> call(String policyId) async {
    return await repository.getPolicyById(policyId);
  }
}

class UpdatePolicy {
  final InsuranceRepository repository;

  UpdatePolicy(this.repository);

  Future<Policy> call(Policy policy) async {
    return await repository.updatePolicy(policy);
  }
}

class CancelPolicyParams {
  final String policyId;
  final String reason;

  const CancelPolicyParams({
    required this.policyId,
    required this.reason,
  });
}

class CancelPolicy {
  final InsuranceRepository repository;

  CancelPolicy(this.repository);

  Future<void> call(CancelPolicyParams params) async {
    return await repository.cancelPolicy(params.policyId, params.reason);
  }
}

class RenewPolicy {
  final InsuranceRepository repository;

  RenewPolicy(this.repository);

  Future<Policy> call(String policyId) async {
    return await repository.renewPolicy(policyId);
  }
}

class GetExpiringPolicies {
  final InsuranceRepository repository;

  GetExpiringPolicies(this.repository);

  Future<List<Policy>> call(String userId, {int daysAhead = 30}) async {
    return await repository.getExpiringPolicies(userId, daysAhead: daysAhead);
  }
}

class GetPolicyStatistics {
  final InsuranceRepository repository;

  GetPolicyStatistics(this.repository);

  Future<Map<String, dynamic>> call(String userId) async {
    return await repository.getPolicyStatistics(userId);
  }
}

// Claim-related use cases
class ViewClaimsParams {
  final String userId;
  final ClaimStatus? status;
  final ClaimType? type;
  final String? policyId;
  final int page;
  final int limit;

  const ViewClaimsParams({
    required this.userId,
    this.status,
    this.type,
    this.policyId,
    this.page = 1,
    this.limit = 20,
  });
}

class ViewClaims {
  final InsuranceRepository repository;

  ViewClaims(this.repository);

  Future<List<Claim>> call(ViewClaimsParams params) async {
    return await repository.getUserClaims(
      params.userId,
      status: params.status,
      type: params.type,
      policyId: params.policyId,
      page: params.page,
      limit: params.limit,
    );
  }
}

class GetClaimDetails {
  final InsuranceRepository repository;

  GetClaimDetails(this.repository);

  Future<Claim?> call(String claimId) async {
    return await repository.getClaimById(claimId);
  }
}

class CreateClaimParams {
  final String userId;
  final String policyId;
  final String policyNumber;
  final String providerId;
  final String providerName;
  final ClaimType type;
  final ClaimPriority priority;
  final String title;
  final String description;
  final DateTime incidentDate;
  final String incidentLocation;
  final double claimedAmount;

  const CreateClaimParams({
    required this.userId,
    required this.policyId,
    required this.policyNumber,
    required this.providerId,
    required this.providerName,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.incidentDate,
    required this.incidentLocation,
    required this.claimedAmount,
  });
}

class CreateClaim {
  final InsuranceRepository repository;

  CreateClaim(this.repository);

  Future<Claim> call(CreateClaimParams params) async {
    final claim = Claim(
      id: '', // Will be generated by the repository
      userId: params.userId,
      policyId: params.policyId,
      policyNumber: params.policyNumber,
      providerId: params.providerId,
      providerName: params.providerName,
      claimNumber: '', // Will be generated by the repository
      type: params.type,
      status: ClaimStatus.draft,
      priority: params.priority,
      title: params.title,
      description: params.description,
      incidentDate: params.incidentDate,
      incidentLocation: params.incidentLocation,
      claimedAmount: params.claimedAmount,
      currency: 'TZS', // Default currency
      documents: const [],
      events: const [],
      submittedAt: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    return await repository.createClaim(claim);
  }
}

class UpdateClaim {
  final InsuranceRepository repository;

  UpdateClaim(this.repository);

  Future<Claim> call(Claim claim) async {
    return await repository.updateClaim(claim);
  }
}

class SubmitClaim {
  final InsuranceRepository repository;

  SubmitClaim(this.repository);

  Future<void> call(String claimId) async {
    return await repository.submitClaim(claimId);
  }
}

class CancelClaim {
  final InsuranceRepository repository;

  CancelClaim(this.repository);

  Future<void> call(String claimId) async {
    return await repository.cancelClaim(claimId);
  }
}

class GetClaimsByPolicy {
  final InsuranceRepository repository;

  GetClaimsByPolicy(this.repository);

  Future<List<Claim>> call(String policyId) async {
    return await repository.getClaimsByPolicy(policyId);
  }
}
