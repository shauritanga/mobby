import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/commission.dart';

class CommissionListItem extends StatelessWidget {
  final Commission commission;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final ValueChanged<bool> onSelectionChanged;
  final ValueChanged<CommissionStatus> onStatusChanged;
  final Function(String paymentRef, String method) onProcessPayment;
  final Function(String reason, double amount, AdjustmentType type) onAddAdjustment;

  const CommissionListItem({
    super.key,
    required this.commission,
    required this.isSelected,
    required this.isSelectionMode,
    required this.onTap,
    required this.onSelectionChanged,
    required this.onStatusChanged,
    required this.onProcessPayment,
    required this.onAddAdjustment,
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
                  
                  // Commission Icon
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
                  
                  // Commission Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          commission.partnerName,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Policy: ${commission.policyNumber}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Earned ${DateFormat('MMM dd, yyyy').format(commission.earnedDate)}',
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
              
              // Commission Details Row
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
                          commission.type.displayName,
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Rate
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Rate',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${commission.commissionPercentage.toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Amount
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Amount',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          '${commission.currency} ${commission.finalAmount.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              
              SizedBox(height: 12.h),
              
              // Bottom Row - Tier and Actions
              Row(
                children: [
                  // Tier Badge
                  _buildTierBadge(context),
                  SizedBox(width: 8.w),
                  
                  // Payment Info
                  if (commission.isPaid && commission.paidDate != null) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.payment,
                            size: 10.r,
                            color: Colors.green,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Paid ${DateFormat('MMM dd').format(commission.paidDate!)}',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                  ],
                  
                  // Overdue indicator
                  if (commission.isOverdue) ...[
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning,
                            size: 10.r,
                            color: Colors.red,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            'Overdue',
                            style: TextStyle(
                              fontSize: 9.sp,
                              color: Colors.red,
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
                        if (commission.status == CommissionStatus.approved)
                          const PopupMenuItem(value: 'payment', child: Text('Process Payment')),
                        const PopupMenuItem(value: 'adjustment', child: Text('Add Adjustment')),
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
    switch (commission.type) {
      case CommissionType.newBusiness:
        return Icons.new_releases;
      case CommissionType.renewal:
        return Icons.refresh;
      case CommissionType.crossSell:
        return Icons.trending_up;
      case CommissionType.upsell:
        return Icons.upgrade;
      case CommissionType.referral:
        return Icons.person_add;
      case CommissionType.bonus:
        return Icons.star;
    }
  }

  Color _getTypeColor() {
    switch (commission.type) {
      case CommissionType.newBusiness:
        return Colors.blue;
      case CommissionType.renewal:
        return Colors.green;
      case CommissionType.crossSell:
        return Colors.orange;
      case CommissionType.upsell:
        return Colors.purple;
      case CommissionType.referral:
        return Colors.teal;
      case CommissionType.bonus:
        return Colors.amber;
    }
  }

  Widget _buildStatusBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (commission.status) {
      case CommissionStatus.pending:
        backgroundColor = Colors.orange.withValues(alpha: 0.1);
        textColor = Colors.orange;
        break;
      case CommissionStatus.approved:
        backgroundColor = Colors.green.withValues(alpha: 0.1);
        textColor = Colors.green;
        break;
      case CommissionStatus.paid:
        backgroundColor = Colors.blue.withValues(alpha: 0.1);
        textColor = Colors.blue;
        break;
      case CommissionStatus.disputed:
        backgroundColor = Colors.red.withValues(alpha: 0.1);
        textColor = Colors.red;
        break;
      case CommissionStatus.cancelled:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        break;
      case CommissionStatus.adjusted:
        backgroundColor = Colors.purple.withValues(alpha: 0.1);
        textColor = Colors.purple;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Text(
        commission.status.displayName,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildTierBadge(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    switch (commission.tier) {
      case CommissionTier.bronze:
        backgroundColor = Colors.brown.withValues(alpha: 0.1);
        textColor = Colors.brown;
        break;
      case CommissionTier.silver:
        backgroundColor = Colors.grey.withValues(alpha: 0.1);
        textColor = Colors.grey;
        break;
      case CommissionTier.gold:
        backgroundColor = Colors.amber.withValues(alpha: 0.1);
        textColor = Colors.amber;
        break;
      case CommissionTier.platinum:
        backgroundColor = Colors.blueGrey.withValues(alpha: 0.1);
        textColor = Colors.blueGrey;
        break;
      case CommissionTier.diamond:
        backgroundColor = Colors.cyan.withValues(alpha: 0.1);
        textColor = Colors.cyan;
        break;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        commission.tier.displayName,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  void _handleAction(BuildContext context, String action) {
    switch (action) {
      case 'status':
        _showStatusDialog(context);
        break;
      case 'payment':
        _showPaymentDialog(context);
        break;
      case 'adjustment':
        _showAdjustmentDialog(context);
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
          children: CommissionStatus.values.map((status) {
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

  void _showPaymentDialog(BuildContext context) {
    final paymentRefController = TextEditingController();
    String selectedMethod = 'Bank Transfer';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: paymentRefController,
              decoration: const InputDecoration(
                labelText: 'Payment Reference',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<String>(
              value: selectedMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method',
                border: OutlineInputBorder(),
              ),
              items: ['Bank Transfer', 'Mobile Money', 'Check', 'Cash']
                  .map((method) => DropdownMenuItem(
                        value: method,
                        child: Text(method),
                      ))
                  .toList(),
              onChanged: (value) => selectedMethod = value ?? selectedMethod,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (paymentRefController.text.isNotEmpty) {
                Navigator.of(context).pop();
                onProcessPayment(paymentRefController.text, selectedMethod);
              }
            },
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }

  void _showAdjustmentDialog(BuildContext context) {
    final reasonController = TextEditingController();
    final amountController = TextEditingController();
    AdjustmentType selectedType = AdjustmentType.correction;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Adjustment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              controller: amountController,
              decoration: const InputDecoration(
                labelText: 'Amount',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 16.h),
            DropdownButtonFormField<AdjustmentType>(
              value: selectedType,
              decoration: const InputDecoration(
                labelText: 'Type',
                border: OutlineInputBorder(),
              ),
              items: AdjustmentType.values
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      ))
                  .toList(),
              onChanged: (value) => selectedType = value ?? selectedType,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty && amountController.text.isNotEmpty) {
                final amount = double.tryParse(amountController.text) ?? 0.0;
                Navigator.of(context).pop();
                onAddAdjustment(reasonController.text, amount, selectedType);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}
