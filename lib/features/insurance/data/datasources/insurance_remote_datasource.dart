import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/insurance_provider_model.dart';
import '../models/policy_model.dart';
import '../models/claim_model.dart';
import '../../domain/entities/insurance_provider.dart';
import '../../domain/entities/policy.dart';
import '../../domain/entities/claim.dart';

abstract class InsuranceRemoteDataSource {
  // Insurance Provider operations
  Future<List<InsuranceProviderModel>> getInsuranceProviders({
    List<ProviderType>? types,
    bool? isFeatured,
    bool? isRecommended,
    bool? isVerified,
    int page = 1,
    int limit = 20,
  });

  Future<InsuranceProviderModel?> getInsuranceProviderById(String providerId);

  Future<List<InsuranceProviderModel>> searchInsuranceProviders({
    required String query,
    List<ProviderType>? types,
    double? minRating,
    double? maxPremium,
    int page = 1,
    int limit = 20,
  });

  Future<List<InsuranceProviderModel>> getFeaturedProviders({int limit = 10});

  Future<List<InsuranceProviderModel>> getRecommendedProviders({
    required String userId,
    int limit = 10,
  });

  // Policy operations
  Future<List<PolicyModel>> getUserPolicies(
    String userId, {
    PolicyStatus? status,
    PolicyType? type,
    int page = 1,
    int limit = 20,
  });

  Future<PolicyModel?> getPolicyById(String policyId);

  Future<PolicyModel> createPolicy(PolicyModel policy);

  Future<PolicyModel> updatePolicy(PolicyModel policy);

  Future<void> cancelPolicy(String policyId, String reason);

  Future<PolicyModel> renewPolicy(String policyId);

  Future<List<PolicyModel>> getExpiringPolicies(
    String userId, {
    int daysAhead = 30,
  });

  Future<Map<String, dynamic>> getPolicyStatistics(String userId);

  // Claim operations
  Future<List<ClaimModel>> getUserClaims(
    String userId, {
    ClaimStatus? status,
    ClaimType? type,
    String? policyId,
    int page = 1,
    int limit = 20,
  });

  Future<ClaimModel?> getClaimById(String claimId);

  Future<ClaimModel> createClaim(ClaimModel claim);

  Future<ClaimModel> updateClaim(ClaimModel claim);

  Future<void> submitClaim(String claimId);

  Future<void> cancelClaim(String claimId);

  Future<List<ClaimModel>> getClaimsByPolicy(String policyId);

  // Quote operations
  Future<Map<String, dynamic>> getInsuranceQuote({
    required String providerId,
    required PolicyType type,
    required Map<String, dynamic> details,
  });

  Future<List<Map<String, dynamic>>> compareQuotes({
    required List<String> providerIds,
    required PolicyType type,
    required Map<String, dynamic> details,
  });

  // Application operations
  Future<String> submitInsuranceApplication({
    required String providerId,
    required PolicyType type,
    required Map<String, dynamic> applicationData,
  });

  Future<Map<String, dynamic>> getApplicationStatus(String applicationId);

  // Document operations
  Future<String> uploadDocument({
    required String entityId,
    required String entityType,
    required String fileName,
    required List<int> fileBytes,
  });

  Future<void> deleteDocument(String documentId);
}

class InsuranceRemoteDataSourceImpl implements InsuranceRemoteDataSource {
  final FirebaseFirestore _firestore;

  InsuranceRemoteDataSourceImpl({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<InsuranceProviderModel>> getInsuranceProviders({
    List<ProviderType>? types,
    bool? isFeatured,
    bool? isRecommended,
    bool? isVerified,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Fetching insurance providers

      Query query = _firestore
          .collection('insuranceProviders')
          .where('status', isEqualTo: ProviderStatus.active.name);

      if (types != null && types.isNotEmpty) {
        query = query.where(
          'types',
          arrayContainsAny: types.map((t) => t.name).toList(),
        );
      }

      if (isFeatured != null) {
        query = query.where('isFeatured', isEqualTo: isFeatured);
      }

      if (isRecommended != null) {
        query = query.where('isRecommended', isEqualTo: isRecommended);
      }

      if (isVerified != null) {
        query = query.where('isVerified', isEqualTo: isVerified);
      }

      query = query.orderBy('rating.overallRating', descending: true);

      if (page > 1) {
        final offset = (page - 1) * limit;
        query = query.limit(offset + limit);
      } else {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      if (page > 1) {
        final offset = (page - 1) * limit;
        docs = docs.skip(offset).toList();
      }

      final providers = docs
          .map(
            (doc) => InsuranceProviderModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      return providers;
    } catch (e) {
      throw Exception('Failed to fetch insurance providers: $e');
    }
  }

  @override
  Future<InsuranceProviderModel?> getInsuranceProviderById(
    String providerId,
  ) async {
    try {
      // Fetching insurance provider details

      final doc = await _firestore
          .collection('insuranceProviders')
          .doc(providerId)
          .get();

      if (!doc.exists) {
        // Insurance provider not found
        return null;
      }

      final provider = InsuranceProviderModel.fromJson({
        'id': doc.id,
        ...doc.data()!,
      });
      return provider;
    } catch (e) {
      throw Exception('Failed to fetch insurance provider: $e');
    }
  }

  @override
  Future<List<InsuranceProviderModel>> searchInsuranceProviders({
    required String query,
    List<ProviderType>? types,
    double? minRating,
    double? maxPremium,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Searching insurance providers

      Query firestoreQuery = _firestore
          .collection('insuranceProviders')
          .where('status', isEqualTo: ProviderStatus.active.name);

      if (types != null && types.isNotEmpty) {
        firestoreQuery = firestoreQuery.where(
          'types',
          arrayContainsAny: types.map((t) => t.name).toList(),
        );
      }

      if (minRating != null) {
        firestoreQuery = firestoreQuery.where(
          'rating.overallRating',
          isGreaterThanOrEqualTo: minRating,
        );
      }

      if (maxPremium != null) {
        firestoreQuery = firestoreQuery.where(
          'maxPremium',
          isLessThanOrEqualTo: maxPremium,
        );
      }

      firestoreQuery = firestoreQuery.orderBy(
        'rating.overallRating',
        descending: true,
      );

      if (page > 1) {
        final offset = (page - 1) * limit;
        firestoreQuery = firestoreQuery.limit(offset + limit);
      } else {
        firestoreQuery = firestoreQuery.limit(limit);
      }

      final querySnapshot = await firestoreQuery.get();

      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      if (page > 1) {
        final offset = (page - 1) * limit;
        docs = docs.skip(offset).toList();
      }

      List<InsuranceProviderModel> providers = docs
          .map(
            (doc) => InsuranceProviderModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      // Apply text search filter
      providers = providers
          .where(
            (provider) =>
                provider.name.toLowerCase().contains(query.toLowerCase()) ||
                provider.shortName.toLowerCase().contains(
                  query.toLowerCase(),
                ) ||
                provider.description.toLowerCase().contains(
                  query.toLowerCase(),
                ),
          )
          .toList();

      return providers;
    } catch (e) {
      throw Exception('Failed to search insurance providers: $e');
    }
  }

  @override
  Future<List<InsuranceProviderModel>> getFeaturedProviders({
    int limit = 10,
  }) async {
    try {
      // Fetching featured insurance providers

      final querySnapshot = await _firestore
          .collection('insuranceProviders')
          .where('status', isEqualTo: ProviderStatus.active.name)
          .where('isFeatured', isEqualTo: true)
          .orderBy('rating.overallRating', descending: true)
          .limit(limit)
          .get();

      final providers = querySnapshot.docs
          .map(
            (doc) =>
                InsuranceProviderModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();

      return providers;
    } catch (e) {
      throw Exception('Failed to fetch featured providers: $e');
    }
  }

  @override
  Future<List<InsuranceProviderModel>> getRecommendedProviders({
    required String userId,
    int limit = 10,
  }) async {
    try {
      // Fetching recommended providers for user

      // For now, return top-rated verified providers
      // In a real implementation, this would use ML/AI to recommend based on user profile
      final querySnapshot = await _firestore
          .collection('insuranceProviders')
          .where('status', isEqualTo: ProviderStatus.active.name)
          .where('isVerified', isEqualTo: true)
          .orderBy('rating.overallRating', descending: true)
          .limit(limit)
          .get();

      final providers = querySnapshot.docs
          .map(
            (doc) =>
                InsuranceProviderModel.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();

      return providers;
    } catch (e) {
      throw Exception('Failed to fetch recommended providers: $e');
    }
  }

  @override
  Future<List<PolicyModel>> getUserPolicies(
    String userId, {
    PolicyStatus? status,
    PolicyType? type,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      // Fetching policies for user

      Query query = _firestore
          .collection('policies')
          .where('userId', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      query = query.orderBy('createdAt', descending: true);

      if (page > 1) {
        final offset = (page - 1) * limit;
        query = query.limit(offset + limit);
      } else {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      if (page > 1) {
        final offset = (page - 1) * limit;
        docs = docs.skip(offset).toList();
      }

      final policies = docs
          .map(
            (doc) => PolicyModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      return policies;
    } catch (e) {
      throw Exception('Failed to fetch policies: $e');
    }
  }

  @override
  Future<PolicyModel?> getPolicyById(String policyId) async {
    try {
      final doc = await _firestore.collection('policies').doc(policyId).get();

      if (!doc.exists) return null;

      return PolicyModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch policy: $e');
    }
  }

  @override
  Future<PolicyModel> createPolicy(PolicyModel policy) async {
    try {
      // Creating new policy

      final policyData = policy.toJson();
      policyData.remove('id');

      // Generate policy number
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      policyData['policyNumber'] = 'POL-$timestamp';

      final docRef = await _firestore.collection('policies').add(policyData);

      final createdPolicy = PolicyModel.fromJson({
        'id': docRef.id,
        ...policyData,
      });

      return createdPolicy;
    } catch (e) {
      throw Exception('Failed to create policy: $e');
    }
  }

  @override
  Future<PolicyModel> updatePolicy(PolicyModel policy) async {
    try {
      await _firestore
          .collection('policies')
          .doc(policy.id)
          .update(policy.toJson());
      return policy;
    } catch (e) {
      throw Exception('Failed to update policy: $e');
    }
  }

  @override
  Future<void> cancelPolicy(String policyId, String reason) async {
    try {
      await _firestore.collection('policies').doc(policyId).update({
        'status': PolicyStatus.cancelled.name,
        'cancellationReason': reason,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel policy: $e');
    }
  }

  @override
  Future<PolicyModel> renewPolicy(String policyId) async {
    try {
      final policy = await getPolicyById(policyId);
      if (policy == null) throw Exception('Policy not found');

      final renewedPolicy = PolicyModel.fromJson({
        ...policy.toJson(),
        'id': '', // Will be generated
        'status': PolicyStatus.active.name,
        'startDate': DateTime.now().toIso8601String(),
        'endDate': DateTime.now()
            .add(const Duration(days: 365))
            .toIso8601String(),
        'renewalDate': null,
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });

      return await createPolicy(renewedPolicy);
    } catch (e) {
      throw Exception('Failed to renew policy: $e');
    }
  }

  @override
  Future<List<PolicyModel>> getExpiringPolicies(
    String userId, {
    int daysAhead = 30,
  }) async {
    try {
      final expiryDate = DateTime.now().add(Duration(days: daysAhead));

      final querySnapshot = await _firestore
          .collection('policies')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: PolicyStatus.active.name)
          .where('endDate', isLessThanOrEqualTo: expiryDate)
          .get();

      return querySnapshot.docs
          .map((doc) => PolicyModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch expiring policies: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getPolicyStatistics(String userId) async {
    try {
      final policiesQuery = await _firestore
          .collection('policies')
          .where('userId', isEqualTo: userId)
          .get();

      final policies = policiesQuery.docs;
      final totalPolicies = policies.length;

      int activePolicies = 0;
      int expiredPolicies = 0;
      int cancelledPolicies = 0;
      double totalPremiums = 0.0;
      double totalCoverage = 0.0;

      for (final doc in policies) {
        final data = doc.data();
        final status = data['status'] as String?;
        final premiumAmount =
            (data['premiumAmount'] as num?)?.toDouble() ?? 0.0;
        final coverageAmount =
            (data['totalCoverageAmount'] as num?)?.toDouble() ?? 0.0;

        totalPremiums += premiumAmount;
        totalCoverage += coverageAmount;

        switch (status) {
          case 'active':
            activePolicies++;
            break;
          case 'expired':
            expiredPolicies++;
            break;
          case 'cancelled':
            cancelledPolicies++;
            break;
        }
      }

      return {
        'totalPolicies': totalPolicies,
        'activePolicies': activePolicies,
        'expiredPolicies': expiredPolicies,
        'cancelledPolicies': cancelledPolicies,
        'totalPremiums': totalPremiums,
        'totalCoverage': totalCoverage,
        'currency': 'TZS',
      };
    } catch (e) {
      throw Exception('Failed to fetch policy statistics: $e');
    }
  }

  @override
  Future<List<ClaimModel>> getUserClaims(
    String userId, {
    ClaimStatus? status,
    ClaimType? type,
    String? policyId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      Query query = _firestore
          .collection('claims')
          .where('userId', isEqualTo: userId);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      if (policyId != null) {
        query = query.where('policyId', isEqualTo: policyId);
      }

      query = query.orderBy('submittedAt', descending: true);

      if (page > 1) {
        final offset = (page - 1) * limit;
        query = query.limit(offset + limit);
      } else {
        query = query.limit(limit);
      }

      final querySnapshot = await query.get();

      List<QueryDocumentSnapshot> docs = querySnapshot.docs;
      if (page > 1) {
        final offset = (page - 1) * limit;
        docs = docs.skip(offset).toList();
      }

      return docs
          .map(
            (doc) => ClaimModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch claims: $e');
    }
  }

  @override
  Future<ClaimModel?> getClaimById(String claimId) async {
    try {
      final doc = await _firestore.collection('claims').doc(claimId).get();

      if (!doc.exists) return null;

      return ClaimModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch claim: $e');
    }
  }

  @override
  Future<ClaimModel> createClaim(ClaimModel claim) async {
    try {
      final claimData = claim.toJson();
      claimData.remove('id');

      // Generate claim number
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      claimData['claimNumber'] = 'CLM-$timestamp';

      final docRef = await _firestore.collection('claims').add(claimData);

      return ClaimModel.fromJson({'id': docRef.id, ...claimData});
    } catch (e) {
      throw Exception('Failed to create claim: $e');
    }
  }

  @override
  Future<ClaimModel> updateClaim(ClaimModel claim) async {
    try {
      await _firestore
          .collection('claims')
          .doc(claim.id)
          .update(claim.toJson());
      return claim;
    } catch (e) {
      throw Exception('Failed to update claim: $e');
    }
  }

  @override
  Future<void> submitClaim(String claimId) async {
    try {
      await _firestore.collection('claims').doc(claimId).update({
        'status': ClaimStatus.submitted.name,
        'submittedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to submit claim: $e');
    }
  }

  @override
  Future<void> cancelClaim(String claimId) async {
    try {
      await _firestore.collection('claims').doc(claimId).update({
        'status': ClaimStatus.closed.name,
        'closedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to cancel claim: $e');
    }
  }

  @override
  Future<List<ClaimModel>> getClaimsByPolicy(String policyId) async {
    try {
      final querySnapshot = await _firestore
          .collection('claims')
          .where('policyId', isEqualTo: policyId)
          .orderBy('submittedAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ClaimModel.fromJson({'id': doc.id, ...doc.data()}))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch claims by policy: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getInsuranceQuote({
    required String providerId,
    required PolicyType type,
    required Map<String, dynamic> details,
  }) async {
    try {
      // In a real implementation, this would call the provider's API
      // For now, we'll simulate a quote calculation
      final provider = await getInsuranceProviderById(providerId);
      if (provider == null) throw Exception('Provider not found');

      final baseAmount =
          provider.minPremium +
          ((provider.maxPremium - provider.minPremium) * 0.5);

      // Simulate quote calculation based on details
      final riskFactor = _calculateRiskFactor(type, details);
      final premium = baseAmount * riskFactor;

      return {
        'providerId': providerId,
        'providerName': provider.name,
        'type': type.name,
        'premium': premium,
        'currency': provider.currency,
        'coverageAmount': premium * 10, // 10x coverage
        'validUntil': DateTime.now()
            .add(const Duration(days: 30))
            .toIso8601String(),
        'terms': {
          'deductible': premium * 0.1,
          'paymentFrequency': 'monthly',
          'processingTime': provider.processingTimeInDays,
        },
        'generatedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get insurance quote: $e');
    }
  }

  double _calculateRiskFactor(PolicyType type, Map<String, dynamic> details) {
    // Simple risk calculation - in reality this would be much more complex
    double baseFactor = 1.0;

    switch (type) {
      case PolicyType.automotive:
        final age = details['driverAge'] as int? ?? 30;
        final experience = details['drivingExperience'] as int? ?? 5;
        baseFactor = age < 25 ? 1.5 : (age > 60 ? 1.3 : 1.0);
        baseFactor *= experience < 2 ? 1.4 : (experience > 10 ? 0.9 : 1.0);
        break;
      case PolicyType.health:
        final age = details['age'] as int? ?? 30;
        baseFactor = age < 30 ? 0.8 : (age > 50 ? 1.4 : 1.0);
        break;
      case PolicyType.life:
        final age = details['age'] as int? ?? 30;
        baseFactor = age < 25 ? 0.7 : (age > 55 ? 1.8 : 1.0);
        break;
      default:
        baseFactor = 1.0;
    }

    return baseFactor;
  }

  @override
  Future<List<Map<String, dynamic>>> compareQuotes({
    required List<String> providerIds,
    required PolicyType type,
    required Map<String, dynamic> details,
  }) async {
    try {
      final quotes = <Map<String, dynamic>>[];

      for (final providerId in providerIds) {
        try {
          final quote = await getInsuranceQuote(
            providerId: providerId,
            type: type,
            details: details,
          );
          quotes.add(quote);
        } catch (e) {
          // Failed to get quote from provider
        }
      }

      // Sort by premium (lowest first)
      quotes.sort(
        (a, b) => (a['premium'] as double).compareTo(b['premium'] as double),
      );

      return quotes;
    } catch (e) {
      throw Exception('Failed to compare quotes: $e');
    }
  }

  @override
  Future<String> submitInsuranceApplication({
    required String providerId,
    required PolicyType type,
    required Map<String, dynamic> applicationData,
  }) async {
    try {
      final applicationId = 'APP-${DateTime.now().millisecondsSinceEpoch}';

      await _firestore
          .collection('insuranceApplications')
          .doc(applicationId)
          .set({
            'id': applicationId,
            'providerId': providerId,
            'type': type.name,
            'status': 'submitted',
            'applicationData': applicationData,
            'submittedAt': FieldValue.serverTimestamp(),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return applicationId;
    } catch (e) {
      throw Exception('Failed to submit insurance application: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getApplicationStatus(
    String applicationId,
  ) async {
    try {
      final doc = await _firestore
          .collection('insuranceApplications')
          .doc(applicationId)
          .get();

      if (!doc.exists) throw Exception('Application not found');

      return doc.data()!;
    } catch (e) {
      throw Exception('Failed to get application status: $e');
    }
  }

  @override
  Future<String> uploadDocument({
    required String entityId,
    required String entityType,
    required String fileName,
    required List<int> fileBytes,
  }) async {
    try {
      // In a real implementation, this would upload to Firebase Storage
      // For now, we'll simulate the upload
      final documentId = 'DOC-${DateTime.now().millisecondsSinceEpoch}';

      await _firestore.collection('documents').doc(documentId).set({
        'id': documentId,
        'entityId': entityId,
        'entityType': entityType,
        'fileName': fileName,
        'size': fileBytes.length,
        'url': 'https://storage.example.com/$documentId',
        'uploadedAt': FieldValue.serverTimestamp(),
      });

      return documentId;
    } catch (e) {
      throw Exception('Failed to upload document: $e');
    }
  }

  @override
  Future<void> deleteDocument(String documentId) async {
    try {
      await _firestore.collection('documents').doc(documentId).delete();
    } catch (e) {
      throw Exception('Failed to delete document: $e');
    }
  }
}
