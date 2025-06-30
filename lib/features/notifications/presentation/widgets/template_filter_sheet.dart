import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/template.dart';
import '../providers/templates_provider.dart';

class TemplateFilterSheet extends ConsumerStatefulWidget {
  const TemplateFilterSheet({super.key});

  @override
  ConsumerState<TemplateFilterSheet> createState() => _TemplateFilterSheetState();
}

class _TemplateFilterSheetState extends ConsumerState<TemplateFilterSheet> {
  TemplateType? _selectedType;
  TemplateCategory? _selectedCategory;
  bool? _isActive;
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 16.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16.h,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          // Title
          Text(
            'Filter Templates',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          // Search field
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              labelText: 'Search templates',
              hintText: 'Enter keywords...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _searchQuery = ''),
                    )
                  : null,
            ),
          ),
          SizedBox(height: 24.h),
          // Type filter
          Text(
            'Template Type',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildFilterChip(
                label: 'All Types',
                isSelected: _selectedType == null,
                onTap: () => setState(() => _selectedType = null),
                theme: theme,
              ),
              ...TemplateType.values.map((type) {
                return _buildFilterChip(
                  label: type.name.toUpperCase(),
                  isSelected: _selectedType == type,
                  onTap: () => setState(() => _selectedType = type),
                  theme: theme,
                );
              }),
            ],
          ),
          SizedBox(height: 24.h),
          // Category filter
          Text(
            'Category',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildFilterChip(
                label: 'All Categories',
                isSelected: _selectedCategory == null,
                onTap: () => setState(() => _selectedCategory = null),
                theme: theme,
              ),
              ...TemplateCategory.values.map((category) {
                return _buildFilterChip(
                  label: category.name.toUpperCase(),
                  isSelected: _selectedCategory == category,
                  onTap: () => setState(() => _selectedCategory = category),
                  theme: theme,
                );
              }),
            ],
          ),
          SizedBox(height: 24.h),
          // Status filter
          Text(
            'Status',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              _buildFilterChip(
                label: 'All',
                isSelected: _isActive == null,
                onTap: () => setState(() => _isActive = null),
                theme: theme,
              ),
              _buildFilterChip(
                label: 'Active',
                isSelected: _isActive == true,
                onTap: () => setState(() => _isActive = true),
                theme: theme,
              ),
              _buildFilterChip(
                label: 'Inactive',
                isSelected: _isActive == false,
                onTap: () => setState(() => _isActive = false),
                theme: theme,
              ),
            ],
          ),
          SizedBox(height: 32.h),
          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _clearFilters,
                  child: const Text('Clear All'),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  child: const Text('Apply Filters'),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required ThemeData theme,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onTap(),
      backgroundColor: theme.colorScheme.surface,
      selectedColor: theme.colorScheme.primaryContainer,
      checkmarkColor: theme.colorScheme.onPrimaryContainer,
      labelStyle: TextStyle(
        color: isSelected
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedCategory = null;
      _isActive = null;
      _searchQuery = '';
    });
    
    ref.read(templatesProvider.notifier).updateFilters(
      const TemplateFilters(),
    );
    
    Navigator.of(context).pop();
  }

  void _applyFilters() {
    final filters = TemplateFilters(
      type: _selectedType,
      category: _selectedCategory,
      isActive: _isActive,
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
    );
    
    ref.read(templatesProvider.notifier).updateFilters(filters);
    
    Navigator.of(context).pop();
  }
}
