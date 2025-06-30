import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/application.dart';

class ApplicationListItem extends StatelessWidget {
  final InsuranceApplication application;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final ValueChanged<bool> onSelectionChanged;
  final ValueChanged<ApplicationStatus> onStatusChanged;
  final ValueChanged<ApplicationPriority> onPriorityChanged;
  final Function(String userId, String userName) onAssign;
  final ValueChanged<String> onAddNotes;

  const ApplicationListItem({
    super.key,
    required this.application,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onSelectionChanged,
    required this.onStatusChanged,
    required this.onPriorityChanged,
    required this.onAssign,
    required this.onAddNotes,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: isSelected 
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: isSelected
            ? BorderSide(color: Theme.of(context).colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  if (isSelectionMode) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: (value) => onSelectionChanged(value ?? false),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  
                  // Application Icon
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: _getTypeColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      _getTypeIcon(),
                      size: 20.r,
                      color: _getTypeColor(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  
                  // Application Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'App #${application.applicationNumber}',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          application.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Submitted ${DateFormat('MMM dd, yyyy').format(application.submittedDate)}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Status Badge
                  _buildStatusBadge(context),
                ],
              ),
              
              SizedBox(height: 12.h),
              
              // Application Details Row
              Row(
                children: [
                  // Type
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Type',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          application.type.displayName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Premium
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Premium',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          application.formattedPremium,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Coverage
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Coverage',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          _formatCurrency(application.requestedCoverageAmount),
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12.h),
              
              // Bottom Row - Priority and Actions
              Row(
                children: [
                  // Priority Badge
                  _buildPriorityBadge(context),
                  SizedBox(width: 8.w),
                  
                  // Assignment Info
                  if (application.isAssigned) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.person,
                            size: 10.r,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            application.assignedToName ?? 'Assigned',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.blue,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  
                  const Spacer(),
                  
                  // Actions
                  if (!isSelectionMode) ...[
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        size: 16.r,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      onSelected: (value) => _handleAction(context, value),
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'status', child: Text('Change Status')),
                        const PopupMenuItem(value: 'priority', child: Text('Change Priority')),
                        const PopupMenuItem(value: 'assign', child: Text('Assign')),
                        const PopupMenuItem(value: 'notes', child: Text('Add Notes')),
                        const PopupMenuItem(value: 'view', child: Text('View Details')),
                      ],
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon() {
    switch (application.type) {
      case ApplicationType.motor:
        return Icons.directions_car;
      case ApplicationType.health:
        return Icons.health_and_safety;
      case ApplicationType.life:
        return Icons.favorite;
      case ApplicationType.property:
        return Icons.home;
      case ApplicationType.travel:
        return Icons.flight;
      case ApplicationType.business:
        return Icons.business;
    }
  }

  Color _getTypeColor() {
    switch (application.type) {
      case ApplicationType.motor:
        return Colors.blue;
      case ApplicationType.health:
        return Colors.green;
      case ApplicationType.life:
        return Colors.red;
      case ApplicationType.property:
        return Colors.orange;
      case ApplicationType.travel:
        return Colors.purple;
      case ApplicationType.business:
        return Colors.teal;
    }
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (application.status) {
      case ApplicationStatus.pending:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        break;
      case ApplicationStatus.underReview:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        break;
      case ApplicationStatus.approved:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        break;
      case ApplicationStatus.rejected:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
      case ApplicationStatus.cancelled:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        break;
      case ApplicationStatus.expired:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        application.status.displayName,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (application.priority) {
      case ApplicationPriority.low:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        break;
      case ApplicationPriority.normal:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        break;
      case ApplicationPriority.high:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        break;
      case ApplicationPriority.urgent:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        application.priority.displayName,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    } else {
      return amount.toStringAsFixed(0);
    }
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'status':
        _showStatusDialog(context);
        break;
      case 'priority':
        _showPriorityDialog(context);
        break;
      case 'assign':
        _showAssignDialog(context);
        break;
      case 'notes':
        _showNotesDialog(context);
        break;
      case 'view':
        onTap();
        break;
    }
  }

  void _showStatusDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ApplicationStatus.values.map((status) {
            return ListTile(
              title: Text(status.displayName),
              onTap: () {
                Navigator.of(context).pop();
                onStatusChanged(status);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showPriorityDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ApplicationPriority.values.map((priority) {
            return ListTile(
              title: Text(priority.displayName),
              onTap: () {
                Navigator.of(context).pop();
                onPriorityChanged(priority);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showAssignDialog(BuildContext context) {
    // TODO: Implement proper user selection dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Assign Application'),
        content: const Text('User assignment feature coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showNotesDialog(BuildContext context) {
    final notesController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Notes'),
        content: TextField(
          controller: notesController,
          decoration: const InputDecoration(
            hintText: 'Enter notes...',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (notesController.text.isNotEmpty) {
                Navigator.of(context).pop();
                onAddNotes(notesController.text);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
