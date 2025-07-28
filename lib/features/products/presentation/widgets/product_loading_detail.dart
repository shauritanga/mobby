import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ProductLoadingDetail extends StatelessWidget {
  const ProductLoadingDetail({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar with image placeholder
          SliverAppBar(
            expandedHeight: 400.h,
            pinned: true,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            elevation: 0,
            leading: Container(
              margin: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: Colors.black),
            ),
            actions: [
              Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.favorite_border, color: Colors.black),
              ),
              Container(
                margin: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.share, color: Colors.black),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          // Product content
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Product info section
                _buildProductInfoLoading(context),

                // Product actions section
                _buildProductActionsLoading(context),

                SizedBox(height: 16.h),

                // Tabbed content
                _buildTabbedContentLoading(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfoLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(16.w),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Brand and category placeholders
            Row(
              children: [
                Container(
                  width: 80.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(
                  width: 100.w,
                  height: 24.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
              ],
            ),

            SizedBox(height: 8.h),

            // Product name placeholder
            Container(
              width: double.infinity,
              height: 28.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),

            SizedBox(height: 4.h),

            Container(
              width: 200.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),

            SizedBox(height: 8.h),

            // Rating placeholder
            Row(
              children: [
                Row(
                  children: List.generate(
                    5,
                    (index) => Padding(
                      padding: EdgeInsets.only(right: 2.w),
                      child: Container(
                        width: 16.w,
                        height: 16.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Container(width: 40.w, height: 16.h, color: Colors.white),
                SizedBox(width: 8.w),
                Container(width: 80.w, height: 16.h, color: Colors.white),
              ],
            ),

            SizedBox(height: 16.h),

            // Price placeholder
            Container(
              width: 150.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),

            SizedBox(height: 16.h),

            // Stock status placeholder
            Container(
              width: 120.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),

            SizedBox(height: 16.h),

            // Description placeholder
            Container(
              width: double.infinity,
              height: 16.h,
              color: Colors.white,
            ),
            SizedBox(height: 4.h),
            Container(
              width: double.infinity,
              height: 16.h,
              color: Colors.white,
            ),
            SizedBox(height: 4.h),
            Container(width: 250.w, height: 16.h, color: Colors.white),

            SizedBox(height: 16.h),

            // Key features placeholder
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 120.w, height: 18.h, color: Colors.white),
                SizedBox(height: 8.h),
                ...List.generate(
                  3,
                  (index) => Padding(
                    padding: EdgeInsets.only(bottom: 4.h),
                    child: Row(
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Container(
                          width: 200.w + (index * 20.w),
                          height: 14.h,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductActionsLoading(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border(
            top: BorderSide(color: Theme.of(context).dividerColor, width: 1),
            bottom: BorderSide(color: Theme.of(context).dividerColor, width: 1),
          ),
        ),
        child: Column(
          children: [
            // Quantity selector placeholder
            Row(
              children: [
                Container(width: 80.w, height: 16.h, color: Colors.white),
                const Spacer(),
                Container(
                  width: 120.w,
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
              ],
            ),

            SizedBox(height: 16.h),

            // Action buttons placeholder
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Container(
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            // Additional actions placeholder
            Row(
              children: List.generate(
                3,
                (index) => Expanded(
                  child: Container(
                    height: 32.h,
                    margin: EdgeInsets.symmetric(horizontal: 4.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabbedContentLoading(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      child: Column(
        children: [
          // Tab bar placeholder
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                  width: 1,
                ),
              ),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Row(
                children: List.generate(
                  3,
                  (index) => Expanded(
                    child: Container(
                      height: 32.h,
                      margin: EdgeInsets.symmetric(horizontal: 8.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tab content placeholder
          Container(
            height: 400.h,
            padding: EdgeInsets.all(16.w),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Section title
                  Container(width: 150.w, height: 20.h, color: Colors.white),

                  SizedBox(height: 16.h),

                  // Content blocks - using Expanded to fit available space
                  Expanded(
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (context, index) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Container(
                          width: double.infinity,
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
