import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Profile loading shimmer widget for loading states
/// Following specifications from FEATURES_DOCUMENTATION.md
class ProfileLoadingShimmer extends StatefulWidget {
  const ProfileLoadingShimmer({super.key});

  @override
  State<ProfileLoadingShimmer> createState() => _ProfileLoadingShimmerState();
}

class _ProfileLoadingShimmerState extends State<ProfileLoadingShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Profile Header Shimmer
            _buildShimmerCard(
              child: Column(
                children: [
                  // Profile Picture
                  _buildShimmerCircle(100.w),
                  SizedBox(height: 16.h),
                  // Name
                  _buildShimmerBox(150.w, 20.h),
                  SizedBox(height: 8.h),
                  // Email
                  _buildShimmerBox(200.w, 16.h),
                  SizedBox(height: 16.h),
                  // Button
                  _buildShimmerBox(double.infinity, 48.h),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Stats Section Shimmer
            _buildShimmerCard(
              child: Row(
                children: [
                  Expanded(child: _buildStatShimmer()),
                  Container(width: 1, height: 40.h, color: Colors.grey[300]),
                  Expanded(child: _buildStatShimmer()),
                  Container(width: 1, height: 40.h, color: Colors.grey[300]),
                  Expanded(child: _buildStatShimmer()),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Quick Actions Shimmer
            _buildShimmerCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildShimmerBox(120.w, 16.h),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(child: _buildQuickActionShimmer()),
                      SizedBox(width: 12.w),
                      Expanded(child: _buildQuickActionShimmer()),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Expanded(child: _buildQuickActionShimmer()),
                      SizedBox(width: 12.w),
                      Expanded(child: _buildQuickActionShimmer()),
                    ],
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 16.h),
            
            // Menu Sections Shimmer
            ...List.generate(3, (index) => Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: _buildShimmerCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(140.w, 16.h),
                    SizedBox(height: 16.h),
                    ...List.generate(3, (itemIndex) => Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: _buildMenuItemShimmer(),
                    )),
                  ],
                ),
              ),
            )),
          ],
        );
      },
    );
  }

  Widget _buildShimmerCard({required Widget child}) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildShimmerBox(double width, double height) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.r),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: [
            (_animation.value - 1).clamp(0.0, 1.0),
            _animation.value.clamp(0.0, 1.0),
            (_animation.value + 1).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.grey[300]!,
            Colors.grey[100]!,
            Colors.grey[300]!,
          ],
          stops: [
            (_animation.value - 1).clamp(0.0, 1.0),
            _animation.value.clamp(0.0, 1.0),
            (_animation.value + 1).clamp(0.0, 1.0),
          ],
        ),
      ),
    );
  }

  Widget _buildStatShimmer() {
    return Column(
      children: [
        _buildShimmerCircle(40.w),
        SizedBox(height: 8.h),
        _buildShimmerBox(30.w, 18.h),
        SizedBox(height: 2.h),
        _buildShimmerBox(60.w, 12.h),
      ],
    );
  }

  Widget _buildQuickActionShimmer() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildShimmerCircle(40.w),
          SizedBox(height: 8.h),
          _buildShimmerBox(60.w, 12.h),
        ],
      ),
    );
  }

  Widget _buildMenuItemShimmer() {
    return Row(
      children: [
        _buildShimmerCircle(40.w),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBox(120.w, 16.h),
              SizedBox(height: 4.h),
              _buildShimmerBox(180.w, 14.h),
            ],
          ),
        ),
        _buildShimmerBox(16.w, 16.h),
      ],
    );
  }
}
