import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../domain/entities/product.dart';
import '../providers/product_providers_setup.dart';

class ProductCard extends ConsumerStatefulWidget {
  final Product product;
  final bool isGridView;
  final VoidCallback? onTap;
  final VoidCallback? onWishlistTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.isGridView,
    this.onTap,
    this.onWishlistTap,
  });

  @override
  ConsumerState<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends ConsumerState<ProductCard> with SingleTickerProviderStateMixin {
  bool _isPressed = false;

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isInWishlist = ref.isProductInWishlist(widget.product.id);
    
    return Card(
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: AnimatedScale(
        scale: _isPressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: InkWell(
          onTap: widget.onTap,
          onTapDown: _onTapDown,
          onTapUp: _onTapUp,
          onTapCancel: _onTapCancel,
          borderRadius: BorderRadius.circular(12.r),
          child: widget.isGridView ? _buildGridCard(context, isInWishlist) : _buildListCard(context, isInWishlist),
        ),
      ),
    );
  }

  Widget _buildGridCard(BuildContext context, bool isInWishlist) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Product Image
        Expanded(
          flex: 3,
          child: _buildProductImage(context, isInWishlist),
        ),
        
        // Product Info
        Expanded(
          flex: 2,
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  widget.product.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 4.h),
                
                // Brand
                Text(
                  widget.product.brandName,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                
                const Spacer(),
                
                // Price and Rating
                Row(
                  children: [
                    Expanded(
                      child: _buildPriceSection(context),
                    ),
                    _buildRatingSection(context),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildListCard(BuildContext context, bool isInWishlist) {
    return Padding(
      padding: EdgeInsets.all(12.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Product Image
          SizedBox(
            width: 100.w,
            height: 100.w,
            child: _buildProductImage(context, isInWishlist),
          ),
          
          SizedBox(width: 12.w),
          
          // Product Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Product Name
                Text(
                  widget.product.name,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                SizedBox(height: 4.h),
                
                // Brand
                Text(
                  widget.product.brandName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Theme.of(context).hintColor,
                  ),
                ),
                
                SizedBox(height: 8.h),
                
                // Short Description
                if (widget.product.shortDescription != null) ...[
                  Text(
                    widget.product.shortDescription!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Theme.of(context).hintColor,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                ],
                
                // Price, Rating, and Stock
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildPriceSection(context),
                          SizedBox(height: 4.h),
                          _buildStockStatus(context),
                        ],
                      ),
                    ),
                    _buildRatingSection(context),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductImage(BuildContext context, bool isInWishlist) {
    return Stack(
      children: [
        // Main Image
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
              bottomLeft: widget.isGridView ? Radius.zero : Radius.circular(12.r),
              bottomRight: widget.isGridView ? Radius.zero : Radius.circular(12.r),
            ),
            color: Theme.of(context).cardColor,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12.r),
              topRight: Radius.circular(12.r),
              bottomLeft: widget.isGridView ? Radius.zero : Radius.circular(12.r),
              bottomRight: widget.isGridView ? Radius.zero : Radius.circular(12.r),
            ),
            child: CachedNetworkImage(
              imageUrl: widget.product.imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[100],
                child: Icon(
                  Icons.image,
                  size: 40.sp,
                  color: Colors.grey[400],
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[100],
                child: Icon(
                  Icons.broken_image,
                  size: 40.sp,
                  color: Colors.grey[400],
                ),
              ),
            ),
          ),
        ),
        
        // Sale Badge
        if (widget.product.isOnSale)
          Positioned(
            top: 8.h,
            left: 8.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.error,
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Text(
                '-${widget.product.discountPercentage.toInt()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        
        // Wishlist Button
        Positioned(
          top: 8.h,
          right: 8.w,
          child: GestureDetector(
            onTap: widget.onWishlistTap,
            child: Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                isInWishlist ? Icons.favorite : Icons.favorite_border,
                size: 16.sp,
                color: isInWishlist ? Colors.red : Colors.grey[600],
              ),
            ),
          ),
        ),
        
        // Stock Status Overlay
        if (widget.product.isOutOfStock)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12.r),
                  topRight: Radius.circular(12.r),
                  bottomLeft: widget.isGridView ? Radius.zero : Radius.circular(12.r),
                  bottomRight: widget.isGridView ? Radius.zero : Radius.circular(12.r),
                ),
              ),
              child: Center(
                child: Text(
                  'OUT OF STOCK',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current Price
        Text(
          'TZS ${_formatPrice(widget.product.price)}',
          style: TextStyle(
            fontSize: widget.isGridView ? 14.sp : 16.sp,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).primaryColor,
          ),
        ),
        
        // Original Price (if on sale)
        if (widget.product.isOnSale && widget.product.originalPrice != null)
          Text(
            'TZS ${_formatPrice(widget.product.originalPrice!)}',
            style: TextStyle(
              fontSize: widget.isGridView ? 12.sp : 14.sp,
              color: Theme.of(context).hintColor,
              decoration: TextDecoration.lineThrough,
            ),
          ),
      ],
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: 14.sp,
          color: Colors.amber,
        ),
        SizedBox(width: 2.w),
        Text(
          widget.product.rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (widget.product.reviewCount > 0) ...[
          SizedBox(width: 2.w),
          Text(
            '(${widget.product.reviewCount})',
            style: TextStyle(
              fontSize: 10.sp,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStockStatus(BuildContext context) {
    Color statusColor;
    String statusText;
    
    if (widget.product.isOutOfStock) {
      statusColor = Theme.of(context).colorScheme.error;
      statusText = 'Out of Stock';
    } else if (widget.product.isLowStock) {
      statusColor = Colors.orange;
      statusText = 'Low Stock';
    } else {
      statusColor = Colors.green;
      statusText = 'In Stock';
    }
    
    return Row(
      children: [
        Container(
          width: 6.w,
          height: 6.w,
          decoration: BoxDecoration(
            color: statusColor,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 4.w),
        Text(
          statusText,
          style: TextStyle(
            fontSize: 11.sp,
            color: statusColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
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
