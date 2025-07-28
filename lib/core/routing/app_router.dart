import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobby/core/routing/admin_shell.dart';
import 'package:mobby/core/routing/client_shell.dart';
import 'package:mobby/core/screens/splash_screen.dart';
import '../constants/app_constants.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/register_screen.dart';
import '../../features/auth/presentation/screens/forgot_password_screen.dart';
import '../../features/auth/presentation/screens/otp_verification_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/profile/presentation/screens/profile_settings_screen.dart';
import '../../features/profile/presentation/screens/edit_profile_screen.dart';
import '../../features/profile/presentation/screens/orders_history_screen.dart';
import '../../features/auth/domain/usecases/verify_otp_usecase.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/vehicles/presentation/screens/vehicle_list_screen.dart';
import '../../features/vehicles/presentation/screens/add_edit_vehicle_screen.dart';
import '../../features/products/presentation/screens/product_list_screen.dart';
import '../../features/products/presentation/screens/product_detail_screen.dart';

import '../../features/vehicles/presentation/screens/vehicle_details_screen.dart';
import '../../features/latra/presentation/screens/latra_main_screen.dart';
import '../../features/latra/presentation/screens/latra_registration_screen.dart';
import '../../features/latra/presentation/screens/license_application_screen.dart';
import '../../features/latra/presentation/screens/latra_status_tracking_screen.dart';
import '../../features/latra/presentation/screens/latra_documents_screen.dart';

// Placeholder screens for routes not yet implemented
class PlaceholderScreen extends StatelessWidget {
  final String title;

  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text('$title - Coming Soon')),
    );
  }
}

// Router configuration
final goRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.splashRoute,
    routes: [
      // Splash Screen
      GoRoute(
        path: AppConstants.splashRoute,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Onboarding
      GoRoute(
        path: AppConstants.onboardingRoute,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),

      // Authentication Routes
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppConstants.registerRoute,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppConstants.forgotPasswordRoute,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppConstants.otpVerificationRoute,
        name: 'otp-verification',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return OtpVerificationScreen(
            phoneNumber: extra?['phoneNumber'],
            email: extra?['email'],
            type: extra?['type'] ?? OtpType.phone,
          );
        },
      ),

      // Client Shell with StatefulShellRoute
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ClientShell(navigationShell: navigationShell);
        },
        branches: [
          // Home Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: '/cart',
                    name: 'cart',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: 'Cart'),
                  ),
                ],
              ),
            ],
          ),
          // Products Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/products',
                name: 'products',
                builder: (context, state) => const ProductListScreen(),
                routes: [
                  GoRoute(
                    path: '/:productId',
                    name: 'product-details',
                    builder: (context, state) {
                      final productId = state.pathParameters['productId']!;
                      return ProductDetailScreen(productId: productId);
                    },
                  ),
                ],
              ),
            ],
          ),
          // Vehicles Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/vehicles',
                name: 'vehicles',
                builder: (context, state) => const VehicleListScreen(),
                routes: [
                  GoRoute(
                    path: '/add',
                    name: 'add-vehicle',
                    builder: (context, state) => const AddEditVehicleScreen(),
                  ),
                  GoRoute(
                    path: '/:vehicleId',
                    name: 'vehicle-details',
                    builder: (context, state) {
                      final vehicleId = state.pathParameters['vehicleId']!;
                      return VehicleDetailsScreen(vehicleId: vehicleId);
                    },
                    routes: [
                      GoRoute(
                        path: '/edit',
                        name: 'edit-vehicle',
                        builder: (context, state) {
                          final vehicleId = state.pathParameters['vehicleId']!;
                          return AddEditVehicleScreen(vehicleId: vehicleId);
                        },
                      ),
                      GoRoute(
                        path: '/documents',
                        name: 'vehicle-documents',
                        builder: (context, state) =>
                            const PlaceholderScreen(title: 'Vehicle Documents'),
                        routes: [
                          GoRoute(
                            path: '/add',
                            name: 'add-vehicle-document',
                            builder: (context, state) =>
                                const PlaceholderScreen(title: 'Add Document'),
                          ),
                          GoRoute(
                            path: '/:documentId',
                            name: 'vehicle-document-details',
                            builder: (context, state) {
                              final documentId =
                                  state.pathParameters['documentId']!;
                              return PlaceholderScreen(
                                title: 'Document $documentId',
                              );
                            },
                          ),
                        ],
                      ),
                      GoRoute(
                        path: '/maintenance',
                        name: 'vehicle-maintenance',
                        builder: (context, state) => const PlaceholderScreen(
                          title: 'Vehicle Maintenance',
                        ),
                        routes: [
                          GoRoute(
                            path: '/add',
                            name: 'add-vehicle-maintenance',
                            builder: (context, state) =>
                                const PlaceholderScreen(
                                  title: 'Add Maintenance',
                                ),
                          ),
                          GoRoute(
                            path: '/:recordId',
                            name: 'vehicle-maintenance-details',
                            builder: (context, state) {
                              final recordId =
                                  state.pathParameters['recordId']!;
                              return PlaceholderScreen(
                                title: 'Maintenance $recordId',
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          // Services Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/support',
                name: 'support',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Support'),
                routes: [
                  GoRoute(
                    path: '/latra',
                    name: 'latra',
                    builder: (context, state) => const LATRAMainScreen(),
                    routes: [
                      GoRoute(
                        path: '/vehicle-registration',
                        name: 'latra-vehicle-registration',
                        builder: (context, state) =>
                            const LATRARegistrationScreen(),
                      ),
                      GoRoute(
                        path: '/license-application',
                        name: 'latra-license-application',
                        builder: (context, state) =>
                            const LicenseApplicationScreen(),
                      ),
                      GoRoute(
                        path: '/status-tracking',
                        name: 'latra-status-tracking',
                        builder: (context, state) {
                          final applicationId =
                              state.uri.queryParameters['applicationId'];
                          return LATRAStatusTrackingScreen(
                            applicationId: applicationId,
                          );
                        },
                      ),
                      GoRoute(
                        path: '/documents',
                        name: 'latra-documents',
                        builder: (context, state) {
                          final applicationId =
                              state.uri.queryParameters['applicationId'];
                          return LATRADocumentsScreen(
                            applicationId: applicationId,
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: '/insurance',
                    name: 'insurance',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: 'Insurance Services'),
                  ),
                  GoRoute(
                    path: '/technical-assistance',
                    name: 'technical-assistance',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: 'Technical Assistance'),
                  ),
                ],
              ),
            ],
          ),
          // Profile Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
                routes: [
                  GoRoute(
                    path: '/edit',
                    name: 'edit-profile',
                    builder: (context, state) => const EditProfileScreen(),
                  ),
                  GoRoute(
                    path: '/orders',
                    name: 'orders',
                    builder: (context, state) => const OrdersHistoryScreen(),
                  ),
                  GoRoute(
                    path: '/settings',
                    name: 'settings',
                    builder: (context, state) => const ProfileSettingsScreen(),
                  ),
                  GoRoute(
                    path: '/addresses',
                    name: 'addresses',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: 'Address Book'),
                    routes: [
                      GoRoute(
                        path: '/add',
                        name: 'add-address',
                        builder: (context, state) =>
                            const PlaceholderScreen(title: 'Add Address'),
                      ),
                      GoRoute(
                        path: '/:addressId/edit',
                        name: 'edit-address',
                        builder: (context, state) {
                          final addressId = state.pathParameters['addressId']!;
                          return PlaceholderScreen(
                            title: 'Edit Address $addressId',
                          );
                        },
                      ),
                    ],
                  ),
                  GoRoute(
                    path: '/payment-methods',
                    name: 'payment-methods',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: 'Payment Methods'),
                    routes: [
                      GoRoute(
                        path: '/add',
                        name: 'add-payment-method',
                        builder: (context, state) => const PlaceholderScreen(
                          title: 'Add Payment Method',
                        ),
                      ),
                      GoRoute(
                        path: '/:paymentMethodId/edit',
                        name: 'edit-payment-method',
                        builder: (context, state) {
                          final paymentMethodId =
                              state.pathParameters['paymentMethodId']!;
                          return PlaceholderScreen(
                            title: 'Edit Payment Method $paymentMethodId',
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),

      // Admin Shell with StatefulShellRoute
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AdminShell(navigationShell: navigationShell);
        },
        branches: [
          // Admin Dashboard Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/dashboard',
                name: 'admin-dashboard',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Admin Dashboard'),
              ),
            ],
          ),
          // Admin Users Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/users',
                name: 'admin-users',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'User Management'),
                routes: [
                  GoRoute(
                    path: '/:userId',
                    name: 'admin-user-details',
                    builder: (context, state) {
                      final userId = state.pathParameters['userId']!;
                      return PlaceholderScreen(title: 'User $userId');
                    },
                  ),
                ],
              ),
            ],
          ),
          // Admin Products Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/products',
                name: 'admin-products',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Product Management'),
                routes: [
                  GoRoute(
                    path: '/add',
                    name: 'admin-add-product',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: 'Add Product'),
                  ),
                  GoRoute(
                    path: '/:productId',
                    name: 'admin-product-details',
                    builder: (context, state) {
                      final productId = state.pathParameters['productId']!;
                      return PlaceholderScreen(
                        title: 'Edit Product $productId',
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          // Admin Orders Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/orders',
                name: 'admin-orders',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Order Management'),
                routes: [
                  GoRoute(
                    path: '/:orderId',
                    name: 'admin-order-details',
                    builder: (context, state) {
                      final orderId = state.pathParameters['orderId']!;
                      return PlaceholderScreen(title: 'Order $orderId');
                    },
                  ),
                ],
              ),
            ],
          ),
          // Admin Support Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/support',
                name: 'admin-support',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Support Management'),
                routes: [
                  GoRoute(
                    path: '/tickets',
                    name: 'admin-tickets',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: 'Support Tickets'),
                  ),
                  GoRoute(
                    path: '/latra',
                    name: 'admin-latra',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: 'LATRA Management'),
                  ),
                  GoRoute(
                    path: '/insurance',
                    name: 'admin-insurance',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: 'Insurance Management'),
                  ),
                ],
              ),
            ],
          ),
          // Admin Analytics Branch
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/analytics',
                name: 'admin-analytics',
                builder: (context, state) =>
                    const PlaceholderScreen(title: 'Analytics'),
                routes: [
                  GoRoute(
                    path: '/reports',
                    name: 'admin-reports',
                    builder: (context, state) =>
                        const PlaceholderScreen(title: 'Reports'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    ],

    // Error handling
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page not found',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(state.error.toString()),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
