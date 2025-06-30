import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../domain/entities/notification.dart' as domain;
import '../providers/notifications_provider.dart';
import '../../di/notifications_di.dart';

class NotificationFilterSheet extends ConsumerStatefulWidget {
  const NotificationFilterSheet({super.key});

  @override
  ConsumerState<NotificationFilterSheet> createState() =>
      _NotificationFilterSheetState();
}

class _NotificationFilterSheetState
    extends ConsumerState<NotificationFilterSheet> {
  NotificationType? _selectedType;
  NotificationStatus? _selectedStatus;
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
            'Filter Notifications',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          // Search field
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            decoration: InputDecoration(
              labelText: 'Search notifications',
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
            'Notification Type',
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
              ...NotificationType.values.map((type) {
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
                label: 'All Status',
                isSelected: _selectedStatus == null,
                onTap: () => setState(() => _selectedStatus = null),
                theme: theme,
              ),
              ...NotificationStatus.values.map((status) {
                return _buildFilterChip(
                  label: status.name.toUpperCase(),
                  isSelected: _selectedStatus == status,
                  onTap: () => setState(() => _selectedStatus = status),
                  theme: theme,
                );
              }),
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
      _selectedStatus = null;
      _searchQuery = '';
    });

    ref
        .read(notificationsProvider.notifier)
        .updateFilters(const NotificationFilters());

    Navigator.of(context).pop();
  }

  void _applyFilters() {
    final filters = NotificationFilters(
      type: _selectedType,
      status: _selectedStatus,
      searchQuery: _searchQuery.isNotEmpty ? _searchQuery : null,
    );

    ref.read(notificationsProvider.notifier).updateFilters(filters);

    Navigator.of(context).pop();
  }
}
