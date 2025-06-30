import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class CartLoadingState extends StatelessWidget {
  const CartLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Column(
        children: [
          // Loading header
          _buildLoadingHeader(context),
          
          // Loading items
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: 3,
              itemBuilder: (context, index) => _buildLoadingItem(context),
            ),
          ),
          
          // Loading summary
          _buildLoadingSummary(context),
          
          // Loading checkout button
          _buildLoadingCheckoutButton(context),
        ],
      ),
    );
  }

  Widget _buildLoadingHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        children: [
          // Header content
          Row(
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              
              SizedBox(width: 16.w),
              
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 120.w,
                      height: 24.h,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      width: 80.w,
                      height: 16.h,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          // Stats placeholders
          Row(
            children: List.generate(3, (index) => Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 20.w,
                      height: 20.w,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    SizedBox(height: 6.h),
                    Container(
                      width: 40.w,
                      height: 14.h,
                      color: Colors.white.withOpacity(0.3),
                    ),
                    Container(
                      width: 30.w,
                      height: 11.h,
                      color: Colors.white.withOpacity(0.3),
                    ),
                  ],
                ),
              ),
            )),
          ),
          
          SizedBox(height: 16.h),
          
          // Action buttons placeholders
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25.r),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingItem(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Image placeholder
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
          
          SizedBox(width: 12.w),
          
          // Content placeholder
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16.h,
                  color: Colors.grey[200],
                ),
                SizedBox(height: 4.h),
                Container(
                  width: 100.w,
                  height: 12.h,
                  color: Colors.grey[200],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      width: 60.w,
                      height: 16.h,
                      color: Colors.grey[200],
                    ),
                    const Spacer(),
                    Container(
                      width: 80.w,
                      height: 32.h,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Container(
                      width: 80.w,
                      height: 14.h,
                      color: Colors.grey[200],
                    ),
                    const Spacer(),
                    Container(
                      width: 20.w,
                      height: 18.h,
                      color: Colors.grey[200],
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      width: 20.w,
                      height: 18.h,
                      color: Colors.grey[200],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSummary(BuildContext context) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120.w,
            height: 18.h,
            color: Colors.grey[200],
          ),
          
          SizedBox(height: 16.h),
          
          ...List.generate(4, (index) => Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              children: [
                Container(
                  width: 100.w,
                  height: 14.h,
                  color: Colors.grey[200],
                ),
                const Spacer(),
                Container(
                  width: 80.w,
                  height: 14.h,
                  color: Colors.grey[200],
                ),
              ],
            ),
          )),
          
          SizedBox(height: 16.h),
          
          Container(
            width: double.infinity,
            height: 1,
            color: Colors.grey[200],
          ),
          
          SizedBox(height: 16.h),
          
          Row(
            children: [
              Container(
                width: 60.w,
                height: 16.h,
                color: Colors.grey[200],
              ),
              const Spacer(),
              Container(
                width: 100.w,
                height: 18.h,
                color: Colors.grey[200],
              ),
            ],
          ),
          
          SizedBox(height: 16.h),
          
          Container(
            width: double.infinity,
            height: 40.h,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8.r),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCheckoutButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Colors.grey[200]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 80.w,
                  height: 14.h,
                  color: Colors.grey[200],
                ),
                SizedBox(height: 4.h),
                Container(
                  width: 100.w,
                  height: 20.h,
                  color: Colors.grey[200],
                ),
              ],
            ),
            
            const Spacer(),
            
            Container(
              width: 120.w,
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(25.r),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
