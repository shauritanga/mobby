import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../providers/vehicle_providers.dart';
import '../../domain/entities/document.dart';

/// Vehicle documents summary widget for displaying document overview
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class VehicleDocumentsSummary extends ConsumerWidget {
  final String vehicleId;

  const VehicleDocumentsSummary({super.key, required this.vehicleId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final documentsAsync = ref.watch(vehicleDocumentsProvider(vehicleId));

    return documentsAsync.when(
      data: (documents) => _buildDocumentsList(context, documents),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(context, error.toString()),
    );
  }

  Widget _buildDocumentsList(BuildContext context, List<Document> documents) {
    if (documents.isEmpty) {
      return _buildEmptyState(context);
    }

    // Group documents by type
    final groupedDocuments = <DocumentType, List<Document>>{};
    for (final document in documents) {
      groupedDocuments.putIfAbsent(document.type, () => []).add(document);
    }

    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        // Summary Stats
        _buildSummaryStats(context, documents),

        SizedBox(height: 16.h),

        // Documents by Type
        ...groupedDocuments.entries.map((entry) {
          final type = entry.key;
          final docs = entry.value;

          return Column(
            children: [
              _buildDocumentTypeSection(context, type, docs),
              SizedBox(height: 12.h),
            ],
          );
        }),

        SizedBox(height: 16.h),

        // Add Document Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push('/vehicles/$vehicleId/documents/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add Document'),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStats(BuildContext context, List<Document> documents) {
    final totalDocs = documents.length;
    final expiredDocs = documents.where((d) => d.isExpired).length;
    final expiringSoonDocs = documents.where((d) => d.isExpiringSoon).length;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Theme.of(context).primaryColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              Icons.description,
              totalDocs.toString(),
              'Total',
              Theme.of(context).primaryColor,
            ),
          ),

          Container(
            width: 1,
            height: 40.h,
            color: Theme.of(context).dividerColor,
          ),

          Expanded(
            child: _buildStatItem(
              context,
              Icons.warning,
              expiredDocs.toString(),
              'Expired',
              Colors.red,
            ),
          ),

          Container(
            width: 1,
            height: 40.h,
            color: Theme.of(context).dividerColor,
          ),

          Expanded(
            child: _buildStatItem(
              context,
              Icons.schedule,
              expiringSoonDocs.toString(),
              'Expiring Soon',
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, size: 20.sp, color: color),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: Theme.of(context).textTheme.bodySmall?.color,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildDocumentTypeSection(
    BuildContext context,
    DocumentType type,
    List<Document> documents,
  ) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.5),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        children: [
          // Section Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(7.r)),
            ),
            child: Row(
              children: [
                Icon(
                  _getDocumentTypeIcon(type),
                  size: 16.sp,
                  color: Theme.of(context).primaryColor,
                ),
                SizedBox(width: 8.w),
                Text(
                  type.displayName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.titleMedium?.color,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    documents.length.toString(),
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Documents List
          ...documents.map((document) => _buildDocumentItem(context, document)),
        ],
      ),
    );
  }

  Widget _buildDocumentItem(BuildContext context, Document document) {
    final isExpired = document.isExpired;
    final isExpiringSoon = document.isExpiringSoon;

    Color? statusColor;
    IconData? statusIcon;

    if (isExpired) {
      statusColor = Colors.red;
      statusIcon = Icons.error;
    } else if (isExpiringSoon) {
      statusColor = Colors.orange;
      statusIcon = Icons.schedule;
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor.withOpacity(0.5),
            width: 1,
          ),
        ),
      ),
      child: ListTile(
        title: Text(
          document.title,
          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
        ),
        subtitle: document.expiryDate != null
            ? Text(
                'Expires: ${_formatDate(document.expiryDate!)}',
                style: TextStyle(
                  fontSize: 10.sp,
                  color:
                      statusColor ??
                      Theme.of(context).textTheme.bodySmall?.color,
                ),
              )
            : null,
        trailing: statusIcon != null
            ? Icon(statusIcon, size: 16.sp, color: statusColor)
            : const Icon(Icons.arrow_forward_ios, size: 12),
        onTap: () =>
            context.push('/vehicles/$vehicleId/documents/${document.id}'),
        dense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description,
            size: 64.sp,
            color: Theme.of(context).hintColor,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Documents',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.titleMedium?.color,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Add documents to keep track of important vehicle paperwork',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () => context.push('/vehicles/$vehicleId/documents/add'),
            icon: const Icon(Icons.add),
            label: const Text('Add First Document'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(BuildContext context, String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 48.sp,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load documents',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 12.sp,
              color: Theme.of(context).hintColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  IconData _getDocumentTypeIcon(DocumentType type) {
    switch (type) {
      case DocumentType.registration:
        return Icons.assignment;
      case DocumentType.insurance:
        return Icons.security;
      case DocumentType.inspection:
        return Icons.verified;
      case DocumentType.license:
        return Icons.card_membership;
      case DocumentType.permit:
        return Icons.approval;
      case DocumentType.receipt:
        return Icons.receipt;
      case DocumentType.manual:
        return Icons.menu_book;
      case DocumentType.warranty:
        return Icons.verified_user;
      case DocumentType.photo:
        return Icons.photo;
      case DocumentType.other:
        return Icons.description;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
