import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/order.dart';

class OrderFiltersPanel extends ConsumerStatefulWidget {
  final OrderStatus? selectedStatus;
  final OrderPriority? selectedPriority;
  final PaymentStatus? selectedPaymentStatus;
  final String? selectedAssignedTo;
  final DateTime? startDate;
  final DateTime? endDate;
  final Function({
    OrderStatus? status,
    OrderPriority? priority,
    PaymentStatus? paymentStatus,
    String? assignedTo,
    DateTime? startDate,
    DateTime? endDate,
  }) onFiltersChanged;

  const OrderFiltersPanel({
    super.key,
    this.selectedStatus,
    this.selectedPriority,
    this.selectedPaymentStatus,
    this.selectedAssignedTo,
    this.startDate,
    this.endDate,
    required this.onFiltersChanged,
  });

  @override
  ConsumerState<OrderFiltersPanel> createState() => _OrderFiltersPanelState();
}

class _OrderFiltersPanelState extends ConsumerState<OrderFiltersPanel> {
  OrderStatus? _selectedStatus;
  OrderPriority? _selectedPriority;
  PaymentStatus? _selectedPaymentStatus;
  String? _selectedAssignedTo;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.selectedStatus;
    _selectedPriority = widget.selectedPriority;
    _selectedPaymentStatus = widget.selectedPaymentStatus;
    _selectedAssignedTo = widget.selectedAssignedTo;
    _startDate = widget.startDate;
    _endDate = widget.endDate;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: 8.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Filter Orders',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _clearFilters,
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Apply'),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filters Content
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Filter
                  _buildStatusFilter(),
                  SizedBox(height: 16.h),

                  // Priority Filter
                  _buildPriorityFilter(),
                  SizedBox(height: 16.h),

                  // Payment Status Filter
                  _buildPaymentStatusFilter(),
                  SizedBox(height: 16.h),

                  // Date Range Filter
                  _buildDateRangeFilter(),
                  SizedBox(height: 16.h),

                  // Assignment Filter
                  _buildAssignmentFilter(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Status',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildFilterChip(
              'All',
              _selectedStatus == null,
              () => setState(() => _selectedStatus = null),
            ),
            ...OrderStatus.values.map((status) => _buildFilterChip(
              status.displayName,
              _selectedStatus == status,
              () => setState(() => _selectedStatus = status),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildPriorityFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildFilterChip(
              'All',
              _selectedPriority == null,
              () => setState(() => _selectedPriority = null),
            ),
            ...OrderPriority.values.map((priority) => _buildFilterChip(
              priority.displayName,
              _selectedPriority == priority,
              () => setState(() => _selectedPriority = priority),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildPaymentStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Status',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildFilterChip(
              'All',
              _selectedPaymentStatus == null,
              () => setState(() => _selectedPaymentStatus = null),
            ),
            ...PaymentStatus.values.map((status) => _buildFilterChip(
              status.displayName,
              _selectedPaymentStatus == status,
              () => setState(() => _selectedPaymentStatus = status),
            )),
          ],
        ),
      ],
    );
  }

  Widget _buildDateRangeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date Range',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectStartDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    _startDate != null
                        ? '${_startDate!.day}/${_startDate!.month}/${_startDate!.year}'
                        : 'Start Date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _startDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              'to',
              style: TextStyle(
                fontSize: 12.sp,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: InkWell(
                onTap: () => _selectEndDate(context),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    _endDate != null
                        ? '${_endDate!.day}/${_endDate!.month}/${_endDate!.year}'
                        : 'End Date',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: _endDate != null
                          ? Theme.of(context).colorScheme.onSurface
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAssignmentFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Assignment',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            _buildFilterChip(
              'All',
              _selectedAssignedTo == null,
              () => setState(() => _selectedAssignedTo = null),
            ),
            _buildFilterChip(
              'Unassigned',
              _selectedAssignedTo == 'unassigned',
              () => setState(() => _selectedAssignedTo = 'unassigned'),
            ),
            _buildFilterChip(
              'Assigned to Me',
              _selectedAssignedTo == 'me',
              () => setState(() => _selectedAssignedTo = 'me'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  void _selectStartDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _startDate = date);
    }
  }

  void _selectEndDate(BuildContext context) async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _endDate = date);
    }
  }

  void _clearFilters() {
    setState(() {
      _selectedStatus = null;
      _selectedPriority = null;
      _selectedPaymentStatus = null;
      _selectedAssignedTo = null;
      _startDate = null;
      _endDate = null;
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(
      status: _selectedStatus,
      priority: _selectedPriority,
      paymentStatus: _selectedPaymentStatus,
      assignedTo: _selectedAssignedTo,
      startDate: _startDate,
      endDate: _endDate,
    );
    Navigator.of(context).pop();
  }
}
