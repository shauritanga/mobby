import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/campaign_model.dart';
import '../../domain/entities/campaign.dart';

abstract class CampaignsRemoteDataSource {
  Future<List<CampaignModel>> getCampaigns({
    int page = 1,
    int limit = 20,
    CampaignStatus? status,
    CampaignType? type,
  });

  Future<CampaignModel?> getCampaign(String campaignId);
  Future<CampaignModel> createCampaign(CampaignModel campaign);
  Future<CampaignModel> updateCampaign(CampaignModel campaign);
  Future<void> deleteCampaign(String campaignId);
  Future<CampaignModel> launchCampaign(String campaignId);
  Future<CampaignModel> pauseCampaign(String campaignId);
  Future<CampaignModel> resumeCampaign(String campaignId);
  Future<CampaignModel> stopCampaign(String campaignId);
  Future<CampaignModel> scheduleCampaign(
    String campaignId,
    DateTime scheduledAt,
  );
  Future<int> estimateAudience(CampaignTarget target);
  Future<List<String>> getTargetUserIds(CampaignTarget target);
  Future<void> updateCampaignTarget(String campaignId, CampaignTarget target);
  Future<CampaignStatsModel> getCampaignStats(String campaignId);
  Future<Map<String, dynamic>> getCampaignAnalytics(
    String campaignId, {
    DateTime? startDate,
    DateTime? endDate,
  });
}

class CampaignsRemoteDataSourceImpl implements CampaignsRemoteDataSource {
  final FirebaseFirestore _firestore;

  CampaignsRemoteDataSourceImpl(this._firestore);

  @override
  Future<List<CampaignModel>> getCampaigns({
    int page = 1,
    int limit = 20,
    CampaignStatus? status,
    CampaignType? type,
  }) async {
    try {
      Query query = _firestore
          .collection('campaigns')
          .orderBy('createdAt', descending: true);

      if (status != null) {
        query = query.where('status', isEqualTo: status.name);
      }

      if (type != null) {
        query = query.where('type', isEqualTo: type.name);
      }

      final querySnapshot = await query.limit(limit).get();

      final campaigns = querySnapshot.docs
          .map(
            (doc) => CampaignModel.fromJson({
              'id': doc.id,
              ...doc.data() as Map<String, dynamic>,
            }),
          )
          .toList();

      return campaigns;
    } catch (e) {
      throw Exception('Failed to fetch campaigns: $e');
    }
  }

  @override
  Future<CampaignModel?> getCampaign(String campaignId) async {
    try {
      final doc = await _firestore
          .collection('campaigns')
          .doc(campaignId)
          .get();

      if (!doc.exists) {
        return null;
      }

      return CampaignModel.fromJson({'id': doc.id, ...doc.data()!});
    } catch (e) {
      throw Exception('Failed to fetch campaign: $e');
    }
  }

  @override
  Future<CampaignModel> createCampaign(CampaignModel campaign) async {
    try {
      final campaignData = campaign.toJson();
      campaignData.remove('id');

      final docRef = await _firestore.collection('campaigns').add(campaignData);

      final createdCampaign = CampaignModel.fromEntity(
        campaign.copyWith(id: docRef.id),
      );
      return createdCampaign;
    } catch (e) {
      throw Exception('Failed to create campaign: $e');
    }
  }

  @override
  Future<CampaignModel> updateCampaign(CampaignModel campaign) async {
    try {
      await _firestore
          .collection('campaigns')
          .doc(campaign.id)
          .update(campaign.toJson());

      return campaign;
    } catch (e) {
      throw Exception('Failed to update campaign: $e');
    }
  }

  @override
  Future<void> deleteCampaign(String campaignId) async {
    try {
      await _firestore.collection('campaigns').doc(campaignId).delete();
    } catch (e) {
      throw Exception('Failed to delete campaign: $e');
    }
  }

  @override
  Future<CampaignModel> launchCampaign(String campaignId) async {
    try {
      await _firestore.collection('campaigns').doc(campaignId).update({
        'status': CampaignStatus.active.name,
        'launchedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedCampaign = await getCampaign(campaignId);
      return updatedCampaign!;
    } catch (e) {
      throw Exception('Failed to launch campaign: $e');
    }
  }

  @override
  Future<CampaignModel> pauseCampaign(String campaignId) async {
    try {
      await _firestore.collection('campaigns').doc(campaignId).update({
        'status': CampaignStatus.paused.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedCampaign = await getCampaign(campaignId);
      return updatedCampaign!;
    } catch (e) {
      throw Exception('Failed to pause campaign: $e');
    }
  }

  @override
  Future<CampaignModel> resumeCampaign(String campaignId) async {
    try {
      await _firestore.collection('campaigns').doc(campaignId).update({
        'status': CampaignStatus.active.name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedCampaign = await getCampaign(campaignId);
      return updatedCampaign!;
    } catch (e) {
      throw Exception('Failed to resume campaign: $e');
    }
  }

  @override
  Future<CampaignModel> stopCampaign(String campaignId) async {
    try {
      await _firestore.collection('campaigns').doc(campaignId).update({
        'status': CampaignStatus.completed.name,
        'completedAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedCampaign = await getCampaign(campaignId);
      return updatedCampaign!;
    } catch (e) {
      throw Exception('Failed to stop campaign: $e');
    }
  }

  @override
  Future<CampaignModel> scheduleCampaign(
    String campaignId,
    DateTime scheduledAt,
  ) async {
    try {
      await _firestore.collection('campaigns').doc(campaignId).update({
        'status': CampaignStatus.scheduled.name,
        'schedule.startDate': Timestamp.fromDate(scheduledAt),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      final updatedCampaign = await getCampaign(campaignId);
      return updatedCampaign!;
    } catch (e) {
      throw Exception('Failed to schedule campaign: $e');
    }
  }

  @override
  Future<int> estimateAudience(CampaignTarget target) async {
    try {
      Query query = _firestore.collection('users');

      switch (target.audience) {
        case TargetAudience.all:
          break;
        case TargetAudience.newUsers:
          final thirtyDaysAgo = DateTime.now().subtract(
            const Duration(days: 30),
          );
          query = query.where(
            'createdAt',
            isGreaterThan: Timestamp.fromDate(thirtyDaysAgo),
          );
          break;
        case TargetAudience.activeUsers:
          final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
          query = query.where(
            'lastActiveAt',
            isGreaterThan: Timestamp.fromDate(sevenDaysAgo),
          );
          break;
        case TargetAudience.inactiveUsers:
          final thirtyDaysAgo = DateTime.now().subtract(
            const Duration(days: 30),
          );
          query = query.where(
            'lastActiveAt',
            isLessThan: Timestamp.fromDate(thirtyDaysAgo),
          );
          break;
        case TargetAudience.premiumUsers:
          query = query.where('isPremium', isEqualTo: true);
          break;
        case TargetAudience.custom:
          if (target.userIds != null) {
            return target.userIds!.length;
          }
          // Apply custom filters if provided
          if (target.filters != null) {
            for (final entry in target.filters!.entries) {
              query = query.where(entry.key, isEqualTo: entry.value);
            }
          }
          break;
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.length;
    } catch (e) {
      throw Exception('Failed to estimate audience: $e');
    }
  }

  @override
  Future<List<String>> getTargetUserIds(CampaignTarget target) async {
    try {
      if (target.userIds != null) {
        return target.userIds!;
      }

      Query query = _firestore.collection('users');

      switch (target.audience) {
        case TargetAudience.all:
          break;
        case TargetAudience.newUsers:
          final thirtyDaysAgo = DateTime.now().subtract(
            const Duration(days: 30),
          );
          query = query.where(
            'createdAt',
            isGreaterThan: Timestamp.fromDate(thirtyDaysAgo),
          );
          break;
        case TargetAudience.activeUsers:
          final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
          query = query.where(
            'lastActiveAt',
            isGreaterThan: Timestamp.fromDate(sevenDaysAgo),
          );
          break;
        case TargetAudience.inactiveUsers:
          final thirtyDaysAgo = DateTime.now().subtract(
            const Duration(days: 30),
          );
          query = query.where(
            'lastActiveAt',
            isLessThan: Timestamp.fromDate(thirtyDaysAgo),
          );
          break;
        case TargetAudience.premiumUsers:
          query = query.where('isPremium', isEqualTo: true);
          break;
        case TargetAudience.custom:
          if (target.filters != null) {
            for (final entry in target.filters!.entries) {
              query = query.where(entry.key, isEqualTo: entry.value);
            }
          }
          break;
      }

      final querySnapshot = await query.get();
      return querySnapshot.docs.map((doc) => doc.id).toList();
    } catch (e) {
      throw Exception('Failed to get target user IDs: $e');
    }
  }

  @override
  Future<void> updateCampaignTarget(
    String campaignId,
    CampaignTarget target,
  ) async {
    try {
      await _firestore.collection('campaigns').doc(campaignId).update({
        'target': CampaignTargetModel.fromEntity(target).toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to update campaign target: $e');
    }
  }

  @override
  Future<CampaignStatsModel> getCampaignStats(String campaignId) async {
    try {
      // Get notifications for this campaign
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('campaignId', isEqualTo: campaignId)
          .get();

      int totalSent = 0;
      int delivered = 0;
      int opened = 0;
      int clicked = 0;
      int failed = 0;

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final status = data['status'] as String;

        totalSent++;

        switch (status) {
          case 'delivered':
            delivered++;
            break;
          case 'read':
            opened++;
            delivered++; // Read implies delivered
            break;
          case 'failed':
            failed++;
            break;
        }

        // Check if notification was clicked (has action tracking)
        if (data['clickedAt'] != null) {
          clicked++;
        }
      }

      final deliveryRate = totalSent > 0 ? (delivered / totalSent) * 100 : 0.0;
      final openRate = delivered > 0 ? (opened / delivered) * 100 : 0.0;
      final clickRate = opened > 0 ? (clicked / opened) * 100 : 0.0;

      return CampaignStatsModel(
        totalSent: totalSent,
        delivered: delivered,
        opened: opened,
        clicked: clicked,
        failed: failed,
        deliveryRate: deliveryRate,
        openRate: openRate,
        clickRate: clickRate,
      );
    } catch (e) {
      throw Exception('Failed to get campaign stats: $e');
    }
  }

  @override
  Future<Map<String, dynamic>> getCampaignAnalytics(
    String campaignId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('notifications')
          .where('campaignId', isEqualTo: campaignId);

      if (startDate != null) {
        query = query.where(
          'createdAt',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate),
        );
      }

      if (endDate != null) {
        query = query.where(
          'createdAt',
          isLessThanOrEqualTo: Timestamp.fromDate(endDate),
        );
      }

      final querySnapshot = await query.get();

      final analytics = <String, dynamic>{
        'totalNotifications': querySnapshot.docs.length,
        'statusBreakdown': <String, int>{},
        'channelBreakdown': <String, int>{},
        'typeBreakdown': <String, int>{},
        'dailyStats': <String, Map<String, int>>{},
      };

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final status = data['status'] as String;
        final channels = List<String>.from(data['channels'] ?? []);
        final type = data['type'] as String;
        final createdAt = (data['createdAt'] as Timestamp).toDate();
        final dateKey =
            '${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}';

        // Status breakdown
        analytics['statusBreakdown'][status] =
            (analytics['statusBreakdown'][status] ?? 0) + 1;

        // Channel breakdown
        for (final channel in channels) {
          analytics['channelBreakdown'][channel] =
              (analytics['channelBreakdown'][channel] ?? 0) + 1;
        }

        // Type breakdown
        analytics['typeBreakdown'][type] =
            (analytics['typeBreakdown'][type] ?? 0) + 1;

        // Daily stats
        if (analytics['dailyStats'][dateKey] == null) {
          analytics['dailyStats'][dateKey] = <String, int>{
            'sent': 0,
            'delivered': 0,
            'opened': 0,
            'failed': 0,
          };
        }

        analytics['dailyStats'][dateKey]['sent'] =
            analytics['dailyStats'][dateKey]['sent']! + 1;

        if (status == 'delivered' || status == 'read') {
          analytics['dailyStats'][dateKey]['delivered'] =
              analytics['dailyStats'][dateKey]['delivered']! + 1;
        }

        if (status == 'read') {
          analytics['dailyStats'][dateKey]['opened'] =
              analytics['dailyStats'][dateKey]['opened']! + 1;
        }

        if (status == 'failed') {
          analytics['dailyStats'][dateKey]['failed'] =
              analytics['dailyStats'][dateKey]['failed']! + 1;
        }
      }

      return analytics;
    } catch (e) {
      throw Exception('Failed to get campaign analytics: $e');
    }
  }
}
