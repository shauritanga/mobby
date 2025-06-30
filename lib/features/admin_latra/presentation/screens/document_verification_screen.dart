import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../latra/domain/entities/latra_document.dart';
import '../../domain/entities/verification_status.dart';
import '../providers/admin_latra_providers.dart';
import '../widgets/document_filters_panel.dart';
import '../widgets/document_list_item.dart';
import '../widgets/document_search_bar.dart';
import '../widgets/verification_analytics_card.dart';

/// Document Verification Screen for Admin LATRA Management
/// Following specifications from FEATURES_DOCUMENTATION.md - Admin LATRA Management Feature
class DocumentVerificationScreen extends ConsumerStatefulWidget {
  const DocumentVerificationScreen({super.key});

  @override
  ConsumerState<DocumentVerificationScreen> createState() => _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState extends ConsumerState<DocumentVerificationScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Load more documents
      final currentFilters = ref.read(documentFiltersProvider);
      ref.read(documentFiltersProvider.notifier).state = currentFilters.copyWith(
        page: currentFilters.page + 1,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filters = ref.watch(documentFiltersProvider);
    final documentsAsync = ref.watch(documentsProvider(filters));

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Document Verification',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showVerificationHistory,
            tooltip: 'Verification History',
          ),
        ],
      ),
      body: Column(
        children: [
          // Analytics Card
          Padding(
            padding: EdgeInsets.all(16.w),
            child: const VerificationAnalyticsCard(),
          ),

          // Search Bar
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: DocumentSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onFilterPressed: _showFiltersPanel,
            ),
          ),

          SizedBox(height: 16.h),

          // Documents List
          Expanded(
            child: documentsAsync.when(
              data: (documents) => _buildDocumentsList(documents),
              loading: () => _buildLoadingList(),
              error: (error, stack) => _buildErrorState(error.toString()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList(List<LATRADocument> documents) {
    if (documents.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      child: ListView.builder(
        controller: _scrollController,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: documents.length,
        itemBuilder: (context, index) {
          final document = documents[index];

          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: DocumentListItem(
              document: document,
              onTap: () => _onDocumentTap(document),
              onVerify: (result, notes, issues) => _verifyDocument(document.id, result, notes, issues),
              onViewHistory: () => _viewDocumentHistory(document),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingList() {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: 10,
      itemBuilder: (context, index) => Padding(
        padding: EdgeInsets.only(bottom: 12.h),
        child: _buildSkeletonItem(),
      ),
    );
  }

  Widget _buildSkeletonItem() {
    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        height: 140.h,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 16.h,
              width: 200.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 12.h,
              width: 150.w,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(6.r),
              ),
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(
                  height: 12.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                const Spacer(),
                Container(
                  height: 24.h,
                  width: 60.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Container(
                  height: 32.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  height: 32.h,
                  width: 80.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.description_outlined,
            size: 64.r,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          SizedBox(height: 16.h),
          Text(
            'No Documents Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'There are no documents matching your current filters.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.r,
            color: Theme.of(context).colorScheme.error,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error Loading Documents',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 14.sp,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: _refreshData,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    final currentFilters = ref.read(documentFiltersProvider);
    ref.read(documentFiltersProvider.notifier).state = currentFilters.copyWith(
      searchQuery: query.isEmpty ? null : query,
      page: 1, // Reset to first page
    );
  }

  void _showFiltersPanel() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DocumentFiltersPanel(
        currentFilters: ref.read(documentFiltersProvider),
        onFiltersChanged: (filters) {
          ref.read(documentFiltersProvider.notifier).state = filters.copyWith(page: 1);
        },
      ),
    );
  }

  Future<void> _refreshData() async {
    ref.invalidate(documentsProvider);
    ref.invalidate(verificationAnalyticsProvider);
  }

  void _onDocumentTap(LATRADocument document) {
    // Navigate to document details
    // TODO: Implement navigation to document details screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View details for ${document.fileName}')),
    );
  }

  void _verifyDocument(String documentId, VerificationResult result, String? notes, List<String> issues) {
    // TODO: Implement document verification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Verify document: ${result.displayName}')),
    );
  }

  void _viewDocumentHistory(LATRADocument document) {
    // TODO: Implement document verification history view
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('View history for ${document.fileName}')),
    );
  }

  void _showVerificationHistory() {
    // TODO: Implement verification history screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Show verification history')),
    );
  }
}
