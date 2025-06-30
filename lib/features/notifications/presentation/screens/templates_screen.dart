import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/template.dart';
import '../providers/templates_provider.dart';
import '../widgets/template_card.dart';
import '../widgets/template_filter_sheet.dart';

class TemplatesScreen extends ConsumerStatefulWidget {
  const TemplatesScreen({super.key});

  @override
  ConsumerState<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends ConsumerState<TemplatesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(templatesProvider.notifier).loadTemplates();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(templatesProvider.notifier).loadTemplates();
    }
  }

  @override
  Widget build(BuildContext context) {
    final templatesState = ref.watch(templatesProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Templates'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _createNewTemplate(),
          ),
          PopupMenuButton<String>(
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: ListTile(
                  leading: Icon(Icons.refresh),
                  title: Text('Refresh'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.upload),
                  title: Text('Import Templates'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.download),
                  title: Text('Export Templates'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Push'),
            Tab(text: 'Email'),
            Tab(text: 'SMS'),
            Tab(text: 'In-App'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTemplatesList(templatesState, null, theme),
          _buildTemplatesList(templatesState, TemplateType.push, theme),
          _buildTemplatesList(templatesState, TemplateType.email, theme),
          _buildTemplatesList(templatesState, TemplateType.sms, theme),
          _buildTemplatesList(templatesState, TemplateType.inApp, theme),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createNewTemplate,
        icon: const Icon(Icons.add),
        label: const Text('New Template'),
      ),
    );
  }

  Widget _buildTemplatesList(
    TemplatesState state,
    TemplateType? filterType,
    ThemeData theme,
  ) {
    if (state.isLoading && state.templates.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null && state.templates.isEmpty) {
      return _buildErrorState(state.error!, theme);
    }

    final filteredTemplates = filterType != null
        ? state.templates.where((t) => t.type == filterType).toList()
        : state.templates;

    if (filteredTemplates.isEmpty) {
      return _buildEmptyState(filterType, theme);
    }

    return RefreshIndicator(
      onRefresh: () => _refreshTemplates(),
      child: Column(
        children: [
          // Quick stats
          _buildQuickStats(filteredTemplates, theme),
          // Templates grid
          Expanded(
            child: GridView.builder(
              controller: _scrollController,
              padding: EdgeInsets.all(16.w),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12.w,
                mainAxisSpacing: 12.h,
                childAspectRatio: 0.8,
              ),
              itemCount: filteredTemplates.length + (state.hasMore ? 2 : 0),
              itemBuilder: (context, index) {
                if (index >= filteredTemplates.length) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final template = filteredTemplates[index];
                return TemplateCard(
                  template: template,
                  onTap: () => _viewTemplateDetails(template),
                  onEdit: () => _editTemplate(template),
                  onDuplicate: () => _duplicateTemplate(template),
                  onDelete: () => _deleteTemplate(template.id),
                  onPreview: () => _previewTemplate(template),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(List<Template> templates, ThemeData theme) {
    final activeTemplates = templates.where((t) => t.isActive).length;
    final defaultTemplates = templates.where((t) => t.isDefault).length;
    final totalUsage = templates.fold<int>(0, (sum, t) => sum + t.usageCount);

    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Total', '${templates.length}', Icons.description, theme),
          _buildStatItem('Active', '$activeTemplates', Icons.check_circle, theme),
          _buildStatItem('Default', '$defaultTemplates', Icons.star, theme),
          _buildStatItem('Usage', '$totalUsage', Icons.trending_up, theme),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, ThemeData theme) {
    return Column(
      children: [
        Icon(icon, color: theme.colorScheme.primary),
        SizedBox(height: 4.h),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildErrorState(String error, ThemeData theme) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64.w,
              color: theme.colorScheme.error,
            ),
            SizedBox(height: 16.h),
            Text(
              'Failed to load templates',
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: () => _refreshTemplates(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(TemplateType? filterType, ThemeData theme) {
    String title;
    String subtitle;

    if (filterType != null) {
      title = 'No ${filterType.name.toUpperCase()} templates';
      subtitle = 'Create a ${filterType.name} template to get started.';
    } else {
      title = 'No templates yet';
      subtitle = 'Create your first template to streamline your notifications.';
    }

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 64.w,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 16.h),
            Text(
              title,
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _createNewTemplate,
              icon: const Icon(Icons.add),
              label: const Text('Create Template'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const TemplateFilterSheet(),
    );
  }

  void _createNewTemplate() {
    // Navigate to template creation screen
    // Navigator.of(context).pushNamed('/templates/create');
  }

  void _viewTemplateDetails(Template template) {
    // Navigate to template details screen
    // Navigator.of(context).pushNamed('/templates/${template.id}');
  }

  void _editTemplate(Template template) {
    // Navigate to template edit screen
    // Navigator.of(context).pushNamed('/templates/${template.id}/edit');
  }

  void _duplicateTemplate(Template template) {
    showDialog(
      context: context,
      builder: (context) => _DuplicateTemplateDialog(template: template),
    );
  }

  void _deleteTemplate(String templateId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Template'),
        content: const Text('Are you sure you want to delete this template? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(templatesProvider.notifier).deleteTemplate(templateId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _previewTemplate(Template template) {
    // Show template preview dialog
    showDialog(
      context: context,
      builder: (context) => _TemplatePreviewDialog(template: template),
    );
  }

  Future<void> _refreshTemplates() async {
    await ref.read(templatesProvider.notifier).loadTemplates(refresh: true);
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'refresh':
        _refreshTemplates();
        break;
      case 'import':
        // Handle import
        break;
      case 'export':
        // Handle export
        break;
    }
  }
}

// Duplicate Template Dialog
class _DuplicateTemplateDialog extends ConsumerStatefulWidget {
  final Template template;

  const _DuplicateTemplateDialog({required this.template});

  @override
  ConsumerState<_DuplicateTemplateDialog> createState() => _DuplicateTemplateDialogState();
}

class _DuplicateTemplateDialogState extends ConsumerState<_DuplicateTemplateDialog> {
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.text = '${widget.template.name} (Copy)';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Duplicate Template'),
      content: TextField(
        controller: _nameController,
        decoration: const InputDecoration(
          labelText: 'New template name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_nameController.text.trim().isNotEmpty) {
              Navigator.of(context).pop();
              ref.read(templatesProvider.notifier).duplicateTemplate(
                widget.template.id,
                _nameController.text.trim(),
              );
            }
          },
          child: const Text('Duplicate'),
        ),
      ],
    );
  }
}

// Template Preview Dialog
class _TemplatePreviewDialog extends StatelessWidget {
  final Template template;

  const _TemplatePreviewDialog({required this.template});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: 400.w,
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Template Preview',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              template.name,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            if (template.content.subject != null) ...[
              Text(
                'Subject: ${template.content.subject}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
            ],
            Text(
              'Title: ${template.content.title}',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              template.content.body,
              style: theme.textTheme.bodyMedium,
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Provider definitions (these would typically be in a separate file)
final templatesProvider = StateNotifierProvider<TemplatesNotifier, TemplatesState>((ref) {
  // This would be properly injected with dependencies
  throw UnimplementedError('Provider not properly configured');
});
