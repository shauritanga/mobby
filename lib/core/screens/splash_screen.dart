// Splash Screen with authentication flow
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobby/core/constants/app_constants.dart';
import 'package:mobby/core/utils/role_helper.dart';
import 'package:mobby/features/auth/presentation/providers/auth_providers.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  _initializeApp() async {
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    // Check if it's first time user
    final isFirstTimeAsync = ref.read(isFirstTimeProvider);
    final isFirstTime = isFirstTimeAsync.when(
      data: (value) => value,
      loading: () => true,
      error: (_, __) => true,
    );

    if (isFirstTime) {
      // Show onboarding
      context.go(AppConstants.onboardingRoute);
    } else {
      // Check authentication status
      final currentUserAsync = ref.read(currentUserProvider);
      final user = currentUserAsync.when(
        data: (value) => value,
        loading: () => null,
        error: (_, __) => null,
      );

      if (user != null) {
        // User is authenticated, determine route based on role
        final defaultRoute = RoleHelper.getDefaultRoute(user);
        context.go(defaultRoute);
      } else {
        // User is not authenticated, go to login
        context.go(AppConstants.loginRoute);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.directions_car, size: 100.r, color: Colors.white),
            SizedBox(height: 20.h),
            Text(
              'Mobby',
              style: TextStyle(
                fontSize: 32.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Vehicle Spare Parts & Services',
              style: TextStyle(fontSize: 16.sp, color: Colors.white70),
            ),
            SizedBox(height: 40.h),
            CircularProgressIndicator(color: Colors.white),
          ],
        ),
      ),
    );
  }
}
