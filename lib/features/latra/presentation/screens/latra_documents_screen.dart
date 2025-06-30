import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/latra_document.dart';
import '../providers/latra_providers.dart';
import '../providers/latra_state_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../widgets/document_card.dart';
import '../widgets/document_filter_chips.dart';
import '../widgets/document_upload_fab.dart';
import '../widgets/document_stats_header.dart';

/// LATRA Documents Screen for managing LATRA-related documents
/// Following specifications from FEATURES_DOCUMENTATION.md - LATRA Integration Feature
class LATRADocumentsScreen extends ConsumerStatefulWidget {
  final String? applicationId;

  const LATRADocumentsScreen({
    super.key,
    this.applicationId,
  });

  @override
  ConsumerState<LATRADocumentsScreen> createState() => _LATRADocumentsScreenState();
}

class _LATRADocumentsScreenState extends ConsumerState<LATRADocumentsScreen>
    with TickerProviderStateMixin {
  final _scrollController = ScrollController();
  late TabController _tabController;
  
  // Filter states
  LATRADocumentStatus? _selectedStatus;
  LATRADocumentType? _selectedType;
  bool _showExpiredOnly = false;
  bool _showExpiringSoon = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      if (widget.applicationId != null) {
        // Load documents for specific application
        ref.read(latraDocumentNotifierProvider.notifier)
            .loadApplicationDocuments(widget.applicationId!);
      } else {
        // Load all user documents
        ref.read(latraDocumentNotifierProvider.notifier)
            .loadUserDocuments(currentUser.id);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(currentUserProvider).value;
    final documentState = ref.watch(latraDocumentNotifierProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.applicationId != null 
            ? 'Application Documents' 
            : 'LATRA Documents'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () => _showSearchDialog(),
            icon: const Icon(Icons.search),
            tooltip: 'Search Documents',
          ),
          IconButton(
            onPressed: () => _refreshDocuments(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Verified'),
            Tab(text: 'Pending'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Document Statistics Header
          if (currentUser != null)
            DocumentStatsHeader(userId: currentUser.id),

          // Filter Chips
          DocumentFilterChips(
            selectedStatus: _selectedStatus,
            selectedType: _selectedType,
            showExpiredOnly: _showExpiredOnly,
            showExpiringSoon: _showExpiringSoon,
            onStatusChanged: (status) {
              setState(() {
                _selectedStatus = status;
              });
            },
            onTypeChanged: (type) {
              setState(() {
                _selectedType = type;
              });
            },
            onExpiredToggle: (value) {
              setState(() {
                _showExpiredOnly = value;
              });
            },
            onExpiringSoonToggle: (value) {
              setState(() {
                _showExpiringSoon = value;
              });
            },
          ),

          // Documents Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDocumentsList(null), // All documents
                _buildDocumentsList(LATRADocumentStatus.verified),
                _buildDocumentsList(LATRADocumentStatus.pending),
                _buildExpiredDocumentsList(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: DocumentUploadFAB(
        applicationId: widget.applicationId,
        onUploadSuccess: () => _refreshDocuments(),
      ),
    );
  }

  Widget _buildDocumentsList(LATRADocumentStatus? filterStatus) {
    final currentUser = ref.watch(currentUserProvider).value;
    if (currentUser == null) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, child) {
        final documentsAsync = widget.applicationId != null
            ? ref.watch(applicationDocumentsProvider(widget.applicationId!))
            : ref.watch(userLATRADocumentsProvider(currentUser.id));

        return documentsAsync.when(
          data: (documents) {
            final filteredDocuments = _filterDocuments(documents, filterStatus);
            
            if (filteredDocuments.isEmpty) {
              return _buildEmptyState(filterStatus);
            }

            return RefreshIndicator(
              onRefresh: _refreshDocuments,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16.w),
                itemCount: filteredDocuments.length,
                itemBuilder: (context, index) {
                  final document = filteredDocuments[index];
                  return DocumentCard(
                    document: document,
                    onTap: () => _showDocumentDetails(document),
                    onDownload: () => _downloadDocument(document),
                    onDelete: () => _deleteDocument(document),
                    onRenew: () => _renewDocument(document),
                  );
                },
              ),
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  Widget _buildExpiredDocumentsList() {
    final currentUser = ref.watch(currentUserProvider).value;
    if (currentUser == null) return const SizedBox.shrink();

    return Consumer(
      builder: (context, ref, child) {
        final expiredDocsAsync = ref.watch(expiredDocumentsProvider(currentUser.id));
        
        return expiredDocsAsync.when(
          data: (documents) {
            if (documents.isEmpty) {
              return _buildNoExpiredDocumentsState();
            }

            return RefreshIndicator(
              onRefresh: _refreshDocuments,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.all(16.w),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final document = documents[index];
                  return DocumentCard(
                    document: document,
                    onTap: () => _showDocumentDetails(document),
                    onDownload: () => _downloadDocument(document),
                    onDelete: () => _deleteDocument(document),
                    onRenew: () => _renewDocument(document),
                    showExpiryWarning: true,
                  );
                },
              ),
            );
          },
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error.toString()),
        );
      },
    );
  }

  List<LATRADocument> _filterDocuments(
    List<LATRADocument> documents,
    LATRADocumentStatus? statusFilter,
  ) {
    var filtered = documents.where((doc) {
      // Status filter
      if (statusFilter != null && doc.status != statusFilter) {
        return false;
      }

      // Additional status filter
      if (_selectedStatus != null && doc.status != _selectedStatus) {
        return false;
      }

      // Type filter
      if (_selectedType != null && doc.type != _selectedType) {
        return false;
      }

      // Expired filter
      if (_showExpiredOnly && !doc.isExpired) {
        return false;
      }

      // Expiring soon filter
      if (_showExpiringSoon && !doc.expiresSoon) {
        return false;
      }

      // Search query
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        return doc.title.toLowerCase().contains(query) ||
               doc.type.displayName.toLowerCase().contains(query) ||
               (doc.description?.toLowerCase().contains(query) ?? false);
      }

      return true;
    }).toList();

    // Sort by creation date (most recent first)
    filtered.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return filtered;
  }

  Widget _buildEmptyState(LATRADocumentStatus? filterStatus) {
    String title;
    String message;
    IconData icon;

    switch (filterStatus) {
      case LATRADocumentStatus.verified:
        title = 'No Verified Documents';
        message = 'You don\'t have any verified documents yet.';
        icon = Icons.verified;
        break;
      case LATRADocumentStatus.pending:
        title = 'No Pending Documents';
        message = 'All your documents have been processed.';
        icon = Icons.pending;
        break;
      case LATRADocumentStatus.rejected:
        title = 'No Rejected Documents';
        message = 'None of your documents have been rejected.';
        icon = Icons.cancel;
        break;
      default:
        title = 'No Documents Found';
        message = widget.applicationId != null
            ? 'No documents have been uploaded for this application.'
            : 'You haven\'t uploaded any LATRA documents yet.';
        icon = Icons.description_outlined;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.textSecondary,
            size: 64.w,
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (filterStatus == null) ...[
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => _showUploadDialog(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              icon: const Icon(Icons.upload_file),
              label: Text(
                'Upload Document',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNoExpiredDocumentsState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 64.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'All Documents Valid',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.success,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Great! None of your documents have expired.',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(32.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            color: AppColors.error,
            size: 64.w,
          ),
          SizedBox(height: 16.h),
          Text(
            'Error Loading Documents',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.error,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            error,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () => _refreshDocuments(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            child: Text(
              'Retry',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshDocuments() async {
    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser != null) {
      if (widget.applicationId != null) {
        ref.read(latraDocumentNotifierProvider.notifier)
            .loadApplicationDocuments(widget.applicationId!);
      } else {
        ref.read(latraDocumentNotifierProvider.notifier)
            .loadUserDocuments(currentUser.id);
      }
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Documents'),
        content: TextField(
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Enter search term...',
            prefixIcon: Icon(Icons.search),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _searchQuery = '';
              });
              Navigator.of(context).pop();
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showUploadDialog() {
    // Show document upload dialog
  }

  void _showDocumentDetails(LATRADocument document) {
    // Navigate to document details screen
  }

  void _downloadDocument(LATRADocument document) {
    // Download document
  }

  void _deleteDocument(LATRADocument document) {
    // Delete document with confirmation
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Document'),
        content: Text('Are you sure you want to delete "${document.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final success = await ref.read(latraDocumentNotifierProvider.notifier)
                  .deleteDocument(document.id);
              if (success) {
                _showSuccessSnackBar('Document deleted successfully');
              } else {
                _showErrorSnackBar('Failed to delete document');
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _renewDocument(LATRADocument document) {
    // Renew document
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
