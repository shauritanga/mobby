import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../domain/entities/product.dart';
import '../providers/product_providers_setup.dart';
import 'product_image_gallery.dart';

class ProductDetailAppBar extends ConsumerWidget {
  final Product product;
  final int selectedImageIndex;
  final ValueChanged<int> onImageChanged;
  final VoidCallback onWishlistTap;
  final VoidCallback onShareTap;

  const ProductDetailAppBar({
    super.key,
    required this.product,
    required this.selectedImageIndex,
    required this.onImageChanged,
    required this.onWishlistTap,
    required this.onShareTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInWishlist = ref.isProductInWishlist(product.id);

    return SliverAppBar(
      expandedHeight: 400.h,
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(8.w),
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
        child: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        // Wishlist button
        Container(
          margin: EdgeInsets.all(8.w),
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
          child: IconButton(
            icon: Icon(
              isInWishlist ? Icons.favorite : Icons.favorite_border,
              color: isInWishlist ? Colors.red : Colors.black,
            ),
            onPressed: onWishlistTap,
          ),
        ),

        // Share button
        Container(
          margin: EdgeInsets.all(8.w),
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
          child: IconButton(
            icon: const Icon(Icons.share, color: Colors.black),
            onPressed: onShareTap,
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: ProductImageGallery(
          product: product,
          selectedImageIndex: selectedImageIndex,
          onImageChanged: onImageChanged,
        ),
      ),
    );
  }
}
