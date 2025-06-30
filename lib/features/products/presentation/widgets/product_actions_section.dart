import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product.dart';
import '../providers/product_providers_setup.dart';

class ProductActionsSection extends ConsumerStatefulWidget {
  final Product product;
  final VoidCallback onAddToCart;
  final VoidCallback onBuyNow;
  final VoidCallback onWishlistTap;

  const ProductActionsSection({
    super.key,
    required this.product,
    required this.onAddToCart,
    required this.onBuyNow,
    required this.onWishlistTap,
  });

  @override
  ConsumerState<ProductActionsSection> createState() => _ProductActionsSectionState();
}

class _ProductActionsSectionState extends ConsumerState<ProductActionsSection> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final isInWishlist = ref.isProductInWishlist(widget.product.id);
    
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Quantity selector
          _buildQuantitySelector(context),
          
          SizedBox(height: 16.h),
          
          // Action buttons
          Row(
            children: [
              // Wishlist button
              _buildWishlistButton(context, isInWishlist),
              
              SizedBox(width: 12.w),
              
              // Add to cart button
              Expanded(
                flex: 2,
                child: _buildAddToCartButton(context),
              ),
              
              SizedBox(width: 12.w),
              
              // Buy now button
              Expanded(
                flex: 2,
                child: _buildBuyNowButton(context),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Additional actions
          _buildAdditionalActions(context),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(BuildContext context) {
    return Row(
      children: [
        Text(
          'Quantity:',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        
        const Spacer(),
        
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).dividerColor,
            ),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Decrease button
              GestureDetector(
                onTap: _quantity > 1 ? () => setState(() => _quantity--) : null,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: _quantity > 1 
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(8.r),
                      bottomLeft: Radius.circular(8.r),
                    ),
                  ),
                  child: Icon(
                    Icons.remove,
                    size: 20.sp,
                    color: _quantity > 1 
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor,
                  ),
                ),
              ),
              
              // Quantity display
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(
                      color: Theme.of(context).dividerColor,
                    ),
                  ),
                ),
                child: Text(
                  _quantity.toString(),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              
              // Increase button
              GestureDetector(
                onTap: _quantity < (widget.product.stockQuantity ?? 99)
                    ? () => setState(() => _quantity++)
                    : null,
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: _quantity < (widget.product.stockQuantity ?? 99)
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.transparent,
                    borderRadius: BorderRadius.only(
                      topRight: Radius.circular(8.r),
                      bottomRight: Radius.circular(8.r),
                    ),
                  ),
                  child: Icon(
                    Icons.add,
                    size: 20.sp,
                    color: _quantity < (widget.product.stockQuantity ?? 99)
                        ? Theme.of(context).primaryColor
                        : Theme.of(context).hintColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWishlistButton(BuildContext context, bool isInWishlist) {
    return GestureDetector(
      onTap: widget.onWishlistTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: isInWishlist 
              ? Colors.red.withOpacity(0.1)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isInWishlist 
                ? Colors.red.withOpacity(0.3)
                : Theme.of(context).dividerColor,
          ),
        ),
        child: Icon(
          isInWishlist ? Icons.favorite : Icons.favorite_border,
          size: 24.sp,
          color: isInWishlist ? Colors.red : Theme.of(context).hintColor,
        ),
      ),
    );
  }

  Widget _buildAddToCartButton(BuildContext context) {
    final isOutOfStock = widget.product.isOutOfStock;
    
    return ElevatedButton.icon(
      onPressed: isOutOfStock ? null : widget.onAddToCart,
      icon: Icon(
        Icons.shopping_cart,
        size: 20.sp,
      ),
      label: Text(
        isOutOfStock ? 'Out of Stock' : 'Add to Cart',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: isOutOfStock 
            ? Theme.of(context).hintColor
            : Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildBuyNowButton(BuildContext context) {
    final isOutOfStock = widget.product.isOutOfStock;
    
    return OutlinedButton.icon(
      onPressed: isOutOfStock ? null : widget.onBuyNow,
      icon: Icon(
        Icons.flash_on,
        size: 20.sp,
      ),
      label: Text(
        'Buy Now',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: isOutOfStock 
            ? Theme.of(context).hintColor
            : Theme.of(context).primaryColor,
        side: BorderSide(
          color: isOutOfStock 
              ? Theme.of(context).hintColor
              : Theme.of(context).primaryColor,
        ),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  Widget _buildAdditionalActions(BuildContext context) {
    return Row(
      children: [
        // Compare button
        Expanded(
          child: TextButton.icon(
            onPressed: () => _addToCompare(),
            icon: Icon(
              Icons.compare_arrows,
              size: 16.sp,
            ),
            label: Text(
              'Compare',
              style: TextStyle(fontSize: 14.sp),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).hintColor,
            ),
          ),
        ),
        
        // Share button
        Expanded(
          child: TextButton.icon(
            onPressed: () => _shareProduct(),
            icon: Icon(
              Icons.share,
              size: 16.sp,
            ),
            label: Text(
              'Share',
              style: TextStyle(fontSize: 14.sp),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).hintColor,
            ),
          ),
        ),
        
        // Ask question button
        Expanded(
          child: TextButton.icon(
            onPressed: () => _askQuestion(),
            icon: Icon(
              Icons.help_outline,
              size: 16.sp,
            ),
            label: Text(
              'Ask',
              style: TextStyle(fontSize: 14.sp),
            ),
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).hintColor,
            ),
          ),
        ),
      ],
    );
  }

  void _addToCompare() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added ${widget.product.name} to compare list'),
        action: SnackBarAction(
          label: 'View',
          onPressed: () {
            // Navigate to compare screen
          },
        ),
      ),
    );
  }

  void _shareProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing ${widget.product.name}...'),
      ),
    );
  }

  void _askQuestion() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ask a Question'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Have a question about ${widget.product.name}?',
              style: TextStyle(fontSize: 16.sp),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Type your question here...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Question submitted! We\'ll get back to you soon.'),
                ),
              );
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
  }
}

class QuantitySelector extends StatefulWidget {
  final int initialQuantity;
  final int maxQuantity;
  final ValueChanged<int> onQuantityChanged;

  const QuantitySelector({
    super.key,
    this.initialQuantity = 1,
    this.maxQuantity = 99,
    required this.onQuantityChanged,
  });

  @override
  State<QuantitySelector> createState() => _QuantitySelectorState();
}

class _QuantitySelectorState extends State<QuantitySelector> {
  late int _quantity;

  @override
  void initState() {
    super.initState();
    _quantity = widget.initialQuantity;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Decrease button
          _buildQuantityButton(
            icon: Icons.remove,
            onTap: _quantity > 1 ? _decreaseQuantity : null,
            isLeft: true,
          ),
          
          // Quantity display
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              border: Border.symmetric(
                vertical: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Text(
              _quantity.toString(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Increase button
          _buildQuantityButton(
            icon: Icons.add,
            onTap: _quantity < widget.maxQuantity ? _increaseQuantity : null,
            isLeft: false,
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isLeft,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: onTap != null 
              ? Theme.of(context).primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.only(
            topLeft: isLeft ? Radius.circular(8.r) : Radius.zero,
            bottomLeft: isLeft ? Radius.circular(8.r) : Radius.zero,
            topRight: !isLeft ? Radius.circular(8.r) : Radius.zero,
            bottomRight: !isLeft ? Radius.circular(8.r) : Radius.zero,
          ),
        ),
        child: Icon(
          icon,
          size: 20.sp,
          color: onTap != null 
              ? Theme.of(context).primaryColor
              : Theme.of(context).hintColor,
        ),
      ),
    );
  }

  void _decreaseQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
      widget.onQuantityChanged(_quantity);
    }
  }

  void _increaseQuantity() {
    if (_quantity < widget.maxQuantity) {
      setState(() {
        _quantity++;
      });
      widget.onQuantityChanged(_quantity);
    }
  }
}
