import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/cart.dart';

class CartSummary extends StatefulWidget {
  final Cart cart;
  final ValueChanged<String>? onApplyCoupon;
  final VoidCallback? onRemoveCoupon;

  const CartSummary({
    super.key,
    required this.cart,
    this.onApplyCoupon,
    this.onRemoveCoupon,
  });

  @override
  State<CartSummary> createState() => _CartSummaryState();
}

class _CartSummaryState extends State<CartSummary> {
  final TextEditingController _couponController = TextEditingController();
  bool _showCouponField = false;

  @override
  void dispose() {
    _couponController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Order Summary',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
          ),
          
          Divider(
            height: 1,
            color: Theme.of(context).dividerColor,
          ),
          
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Subtotal
                _buildSummaryRow(
                  'Subtotal (${widget.cart.items.length} items)',
                  'TZS ${_formatPrice(widget.cart.subtotal)}',
                  isSubtotal: true,
                ),
                
                SizedBox(height: 8.h),
                
                // Discount
                if (widget.cart.discount > 0)
                  _buildSummaryRow(
                    'Discount',
                    '-TZS ${_formatPrice(widget.cart.discount)}',
                    isDiscount: true,
                  ),
                
                // Coupon discount
                if (widget.cart.couponDiscount > 0) ...[
                  SizedBox(height: 8.h),
                  _buildSummaryRow(
                    'Coupon (${widget.cart.appliedCoupon})',
                    '-TZS ${_formatPrice(widget.cart.couponDiscount)}',
                    isDiscount: true,
                    showRemove: true,
                    onRemove: widget.onRemoveCoupon,
                  ),
                ],
                
                SizedBox(height: 8.h),
                
                // Shipping
                _buildSummaryRow(
                  'Shipping',
                  widget.cart.shippingCost > 0 
                      ? 'TZS ${_formatPrice(widget.cart.shippingCost)}'
                      : 'FREE',
                  isShipping: widget.cart.shippingCost == 0,
                ),
                
                // Tax
                if (widget.cart.tax > 0) ...[
                  SizedBox(height: 8.h),
                  _buildSummaryRow(
                    'Tax',
                    'TZS ${_formatPrice(widget.cart.tax)}',
                  ),
                ],
                
                SizedBox(height: 16.h),
                
                Divider(
                  color: Theme.of(context).dividerColor,
                ),
                
                SizedBox(height: 16.h),
                
                // Total
                _buildSummaryRow(
                  'Total',
                  'TZS ${_formatPrice(widget.cart.total)}',
                  isTotal: true,
                ),
                
                SizedBox(height: 16.h),
                
                // Coupon section
                _buildCouponSection(),
                
                // Savings summary
                if (widget.cart.totalSavings > 0) ...[
                  SizedBox(height: 16.h),
                  _buildSavingsSummary(),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(
    String label,
    String value, {
    bool isSubtotal = false,
    bool isDiscount = false,
    bool isShipping = false,
    bool isTotal = false,
    bool showRemove = false,
    VoidCallback? onRemove,
  }) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 16.sp : 14.sp,
              fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
              color: isTotal 
                  ? Theme.of(context).textTheme.headlineSmall?.color
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        
        if (showRemove) ...[
          GestureDetector(
            onTap: onRemove,
            child: Container(
              padding: EdgeInsets.all(4.w),
              child: Icon(
                Icons.close,
                size: 16.sp,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
        
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18.sp : 14.sp,
            fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600,
            color: isTotal 
                ? Theme.of(context).primaryColor
                : isDiscount 
                    ? Colors.green
                    : isShipping
                        ? Colors.green
                        : Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildCouponSection() {
    if (widget.cart.appliedCoupon != null) {
      return Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: Colors.green.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 20.sp,
              color: Colors.green,
            ),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                'Coupon "${widget.cart.appliedCoupon}" applied',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.green[700],
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        if (!_showCouponField) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => setState(() => _showCouponField = true),
              icon: Icon(Icons.local_offer, size: 18.sp),
              label: const Text('Apply Coupon'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
              ),
            ),
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  decoration: InputDecoration(
                    hintText: 'Enter coupon code',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              
              SizedBox(width: 8.w),
              
              ElevatedButton(
                onPressed: () => _applyCoupon(),
                child: const Text('Apply'),
              ),
            ],
          ),
          
          SizedBox(height: 8.h),
          
          TextButton(
            onPressed: () => setState(() {
              _showCouponField = false;
              _couponController.clear();
            }),
            child: const Text('Cancel'),
          ),
        ],
      ],
    );
  }

  Widget _buildSavingsSummary() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.green.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.savings,
            size: 20.sp,
            color: Colors.green,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You\'re saving',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green[700],
                  ),
                ),
                Text(
                  'TZS ${_formatPrice(widget.cart.totalSavings)}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _applyCoupon() {
    final couponCode = _couponController.text.trim().toUpperCase();
    if (couponCode.isNotEmpty) {
      widget.onApplyCoupon?.call(couponCode);
      setState(() {
        _showCouponField = false;
        _couponController.clear();
      });
    }
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}

class CartBreakdown extends StatelessWidget {
  final Cart cart;

  const CartBreakdown({
    super.key,
    required this.cart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Price Breakdown',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
          
          SizedBox(height: 12.h),
          
          ...cart.items.map((item) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${item.product.name} (${item.quantity}x)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  'TZS ${_formatPrice(item.product.price * item.quantity)}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  String _formatPrice(double price) {
    return price
        .toStringAsFixed(0)
        .replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
  }
}
