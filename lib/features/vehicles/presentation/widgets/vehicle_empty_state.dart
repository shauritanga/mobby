import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Vehicle empty state widget for when no vehicles are found
/// Following specifications from FEATURES_DOCUMENTATION.md - Vehicle Management Feature
class VehicleEmptyState extends StatefulWidget {
  final VoidCallback? onAddVehicle;
  final VoidCallback? onRefresh;
  final String? title;
  final String? subtitle;
  final String? actionText;

  const VehicleEmptyState({
    super.key,
    this.onAddVehicle,
    this.onRefresh,
    this.title,
    this.subtitle,
    this.actionText,
  });

  @override
  State<VehicleEmptyState> createState() => _VehicleEmptyStateState();
}

class _VehicleEmptyStateState extends State<VehicleEmptyState>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _floatController;
  late AnimationController _fadeController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _floatAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);

    _floatController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _floatAnimation = Tween<double>(begin: -10.0, end: 10.0).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeOut));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _fadeController, curve: Curves.easeOutBack),
        );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _floatController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(24.w),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Enhanced animated icon
                AnimatedBuilder(
                  animation: _floatAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(0, _floatAnimation.value),
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.2),
                                Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.05),
                                Colors.transparent,
                              ],
                              stops: const [0.3, 0.7, 1.0],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.1),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            Icons.directions_car_rounded,
                            size: 60.sp,
                            color: Theme.of(
                              context,
                            ).colorScheme.primary.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                    );
                  },
                ),

                SizedBox(height: 24.h),

                // Enhanced title with animation
                Text(
                  widget.title ?? 'No Vehicles Yet',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 12.h),

                // Enhanced subtitle with better styling
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    widget.subtitle ??
                        'Add your first vehicle to get started with vehicle management and tracking.',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.7),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                SizedBox(height: 32.h),

                // Enhanced action buttons with animations
                Column(
                  children: [
                    if (widget.onAddVehicle != null)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.8),
                            ],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: ElevatedButton.icon(
                          onPressed: widget.onAddVehicle,
                          icon: const Icon(Icons.add_rounded),
                          label: Text(
                            widget.actionText ?? 'Add Your First Vehicle',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            textStyle: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                    if (widget.onAddVehicle != null && widget.onRefresh != null)
                      SizedBox(height: 16.h),

                    if (widget.onRefresh != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: widget.onRefresh,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Refresh'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 18.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            side: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.outline.withValues(alpha: 0.5),
                              width: 1.5,
                            ),
                            textStyle: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 24.h),

                // Enhanced help text with better styling
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withValues(alpha: 0.3),
                        Theme.of(
                          context,
                        ).colorScheme.secondaryContainer.withValues(alpha: 0.2),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withValues(alpha: 0.2),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.shadow.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Icon(
                              Icons.lightbulb_outline_rounded,
                              size: 20.sp,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Text(
                            'Getting Started',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 16.h),

                      Text(
                        'With vehicle management, you can:\n'
                        '• Track vehicle documents and renewals\n'
                        '• Manage maintenance schedules\n'
                        '• Store vehicle photos and information\n'
                        '• Get alerts for important dates',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.8),
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
