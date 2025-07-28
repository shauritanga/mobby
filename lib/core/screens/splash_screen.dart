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

    try {
      // Check if it's first time user - properly await the FutureProvider
      final isFirstTime = await ref.read(isFirstTimeProvider.future);
      print('🔍 Splash: isFirstTime = $isFirstTime');

      if (isFirstTime) {
        // Show onboarding
        print('📱 Splash: Navigating to onboarding');
        if (mounted) context.go(AppConstants.onboardingRoute);
      } else {
        // Check authentication status
        print('🔍 Splash: Checking authentication status');
        try {
          final user = await ref.read(currentUserProvider.future);
          print('👤 Splash: User = ${user?.email ?? 'null'}');

          if (!mounted) return;

          if (user != null) {
            // User is authenticated, determine route based on role
            final defaultRoute = RoleHelper.getDefaultRoute(user);
            print('🏠 Splash: Navigating to $defaultRoute');
            context.go(defaultRoute);
          } else {
            // User is not authenticated, go to login
            print('🔐 Splash: Navigating to login');
            context.go(AppConstants.loginRoute);
          }
        } catch (e) {
          // If user check fails, go to login
          print('❌ Splash: User check failed, navigating to login: $e');
          if (mounted) context.go(AppConstants.loginRoute);
        }
      }
    } catch (e) {
      // If first time check fails, assume first time and show onboarding
      print('❌ Splash: First time check failed, showing onboarding: $e');
      if (mounted) context.go(AppConstants.onboardingRoute);
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
