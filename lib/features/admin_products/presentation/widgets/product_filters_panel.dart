import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/admin_product.dart';
import '../providers/admin_products_providers.dart';

class ProductFiltersPanel extends ConsumerStatefulWidget {
  final String? selectedCategoryId;
  final String? selectedSupplierId;
  final ProductStatus? selectedStatus;
  final ProductType? selectedType;
  final bool? isFeatured;
  final bool? isLowStock;
  final Function({
    String? categoryId,
    String? supplierId,
    ProductStatus? status,
    ProductType? type,
    bool? isFeatured,
    bool? isLowStock,
  })
  onFiltersChanged;

  const ProductFiltersPanel({
    super.key,
    this.selectedCategoryId,
    this.selectedSupplierId,
    this.selectedStatus,
    this.selectedType,
    this.isFeatured,
    this.isLowStock,
    required this.onFiltersChanged,
  });

  @override
  ConsumerState<ProductFiltersPanel> createState() =>
      _ProductFiltersPanelState();
}

class _ProductFiltersPanelState extends ConsumerState<ProductFiltersPanel> {
  String? _selectedCategoryId;
  String? _selectedSupplierId;
  ProductStatus? _selectedStatus;
  ProductType? _selectedType;
  bool? _isFeatured;
  bool? _isLowStock;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.selectedCategoryId;
    _selectedSupplierId = widget.selectedSupplierId;
    _selectedStatus = widget.selectedStatus;
    _selectedType = widget.selectedType;
    _isFeatured = widget.isFeatured;
    _isLowStock = widget.isLowStock;
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
            width: 40.w,
            height: 4.h,
            margin: EdgeInsets.only(top: 12.h),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Text(
                  'Filter Products',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _clearFilters,
                  child: Text(
                    'Clear All',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
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
                  // Category Filter
                  _buildCategoryFilter(),
                  SizedBox(height: 16.h),

                  // Supplier Filter
                  _buildSupplierFilter(),
                  SizedBox(height: 16.h),

                  // Status Filter
                  _buildStatusFilter(),
                  SizedBox(height: 16.h),

                  // Type Filter
                  _buildTypeFilter(),
                  SizedBox(height: 16.h),

                  // Quick Filters
                  _buildQuickFilters(),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
          ),

          // Action Buttons
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    child: const Text('Apply Filters'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    final categoriesAsync = ref.watch(rootCategoriesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        categoriesAsync.when(
          data: (categories) => DropdownButtonFormField<String>(
            value: _selectedCategoryId,
            decoration: InputDecoration(
              hintText: 'Select category',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Categories'),
              ),
              ...categories.map(
                (category) => DropdownMenuItem<String>(
                  value: category.id,
                  child: Text(category.name),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategoryId = value;
              });
            },
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error loading categories'),
        ),
      ],
    );
  }

  Widget _buildSupplierFilter() {
    final suppliersAsync = ref.watch(preferredSuppliersProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Supplier',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        suppliersAsync.when(
          data: (suppliers) => DropdownButtonFormField<String>(
            value: _selectedSupplierId,
            decoration: InputDecoration(
              hintText: 'Select supplier',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
            ),
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text('All Suppliers'),
              ),
              ...suppliers.map(
                (supplier) => DropdownMenuItem<String>(
                  value: supplier.id,
                  child: Text(supplier.name),
                ),
              ),
            ],
            onChanged: (value) {
              setState(() {
                _selectedSupplierId = value;
              });
            },
          ),
          loading: () => const CircularProgressIndicator(),
          error: (error, stack) => Text('Error loading suppliers'),
        ),
      ],
    );
  }

  Widget _buildStatusFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Status',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<ProductStatus>(
          value: _selectedStatus,
          decoration: InputDecoration(
            hintText: 'Select status',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
          ),
          items: [
            const DropdownMenuItem<ProductStatus>(
              value: null,
              child: Text('All Statuses'),
            ),
            ...ProductStatus.values.map(
              (status) => DropdownMenuItem<ProductStatus>(
                value: status,
                child: Text(status.name),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedStatus = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Type',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 8.h),
        DropdownButtonFormField<ProductType>(
          value: _selectedType,
          decoration: InputDecoration(
            hintText: 'Select type',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 8.h,
            ),
          ),
          items: [
            const DropdownMenuItem<ProductType>(
              value: null,
              child: Text('All Types'),
            ),
            ...ProductType.values.map(
              (type) => DropdownMenuItem<ProductType>(
                value: type,
                child: Text(type.name),
              ),
            ),
          ],
          onChanged: (value) {
            setState(() {
              _selectedType = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildQuickFilters() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Filters',
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
              child: CheckboxListTile(
                title: Text('Featured', style: TextStyle(fontSize: 12.sp)),
                value: _isFeatured ?? false,
                onChanged: (value) {
                  setState(() {
                    _isFeatured = value == true ? true : null;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
            Expanded(
              child: CheckboxListTile(
                title: Text('Low Stock', style: TextStyle(fontSize: 12.sp)),
                value: _isLowStock ?? false,
                onChanged: (value) {
                  setState(() {
                    _isLowStock = value == true ? true : null;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedSupplierId = null;
      _selectedStatus = null;
      _selectedType = null;
      _isFeatured = null;
      _isLowStock = null;
    });
  }

  void _applyFilters() {
    widget.onFiltersChanged(
      categoryId: _selectedCategoryId,
      supplierId: _selectedSupplierId,
      status: _selectedStatus,
      type: _selectedType,
      isFeatured: _isFeatured,
      isLowStock: _isLowStock,
    );
    Navigator.of(context).pop();
  }
}
