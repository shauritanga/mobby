// Notifications & Communication Feature Export File
// This file provides a single entry point for the entire notifications feature

// Domain Exports
import 'package:mobby/features/notifications/domain/entities/notification.dart';

export 'domain/entities/notification.dart';
export 'domain/entities/campaign.dart';
export 'domain/entities/template.dart';
export 'domain/repositories/notifications_repository.dart';
export 'domain/repositories/campaigns_repository.dart';
export 'domain/repositories/templates_repository.dart';

// Use Cases Exports
export 'domain/usecases/send_notification.dart';
export 'domain/usecases/get_user_notifications.dart';
export 'domain/usecases/manage_campaigns.dart';
export 'domain/usecases/manage_templates.dart';

// Data Layer Exports
export 'data/models/notification_model.dart';
export 'data/models/campaign_model.dart';
export 'data/models/template_model.dart';
export 'data/datasources/notifications_remote_datasource.dart';
export 'data/datasources/campaigns_remote_datasource.dart';
export 'data/datasources/templates_remote_datasource.dart';
export 'data/repositories/notifications_repository_impl.dart';
export 'data/repositories/campaigns_repository_impl.dart';
export 'data/repositories/templates_repository_impl.dart';

// Presentation Layer Exports
export 'presentation/screens/notification_center_screen.dart';
export 'presentation/screens/campaign_management_screen.dart';
export 'presentation/screens/templates_screen.dart';
export 'presentation/providers/notifications_provider.dart';
export 'presentation/providers/campaigns_provider.dart';
export 'presentation/providers/templates_provider.dart';
export 'presentation/widgets/notification_card.dart';
export 'presentation/widgets/campaign_card.dart';
export 'presentation/widgets/template_card.dart';
export 'presentation/widgets/campaign_stats_card.dart';
export 'presentation/routes/notifications_routes.dart';

// Dependency Injection
export 'di/notifications_di.dart'
    hide
        notificationsProvider,
        campaignsProvider,
        campaignStatsProvider,
        templatesProvider;

/// Notifications & Communication Feature
///
/// This feature provides comprehensive notification and communication management
/// capabilities for the Mobby app, including:
///
/// ## Core Features:
/// - **Notification Center**: View, manage, and interact with notifications
/// - **Campaign Management**: Create, launch, and monitor notification campaigns
/// - **Template Management**: Design and manage reusable notification templates
///
/// ## Supported Notification Types:
/// - Order notifications
/// - Payment notifications
/// - Shipping updates
/// - Insurance notifications
/// - LATRA integration notifications
/// - System notifications
/// - Marketing campaigns
/// - Reminders
///
/// ## Supported Channels:
/// - Push notifications
/// - Email notifications
/// - SMS notifications
/// - In-app notifications
///
/// ## Key Capabilities:
///
/// ### Notification Management:
/// - Send individual and bulk notifications
/// - Schedule notifications for future delivery
/// - Real-time notification status tracking
/// - Mark notifications as read/unread
/// - Delete and manage notification history
/// - Search and filter notifications
/// - Unread count tracking
/// - Device token management for push notifications
/// - User notification preferences
///
/// ### Campaign Management:
/// - Create and manage notification campaigns
/// - Audience targeting and segmentation
/// - Campaign scheduling and automation
/// - Real-time campaign analytics and statistics
/// - Campaign performance tracking
/// - A/B testing capabilities
/// - Campaign templates and duplication
///
/// ### Template Management:
/// - Create reusable notification templates
/// - Variable substitution system
/// - Template validation and preview
/// - Multi-channel template support
/// - Template categorization and organization
/// - Usage tracking and analytics
/// - Template import/export functionality
///
/// ## Architecture:
///
/// The feature follows clean architecture principles with:
/// - **Domain Layer**: Entities, use cases, and repository interfaces
/// - **Data Layer**: Models, data sources, and repository implementations
/// - **Presentation Layer**: Screens, providers, and widgets
///
/// ## Dependencies:
/// - Firebase Firestore for data persistence
/// - Riverpod for state management
/// - Flutter ScreenUtil for responsive design
/// - Go Router for navigation
///
/// ## Usage:
///
/// ```dart
/// // Import the feature
/// import 'package:mobby/features/notifications/notifications_feature.dart';
///
/// // Use in your app
/// class MyApp extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     return MaterialApp.router(
///       routerConfig: GoRouter(
///         routes: [
///           ...NotificationsRoutes.routes,
///           // Other routes
///         ],
///       ),
///     );
///   }
/// }
///
/// // Access notification providers
/// final notificationsState = ref.watch(notificationsProvider);
/// final campaignsState = ref.watch(campaignsProvider);
/// final templatesState = ref.watch(templatesProvider);
///
/// // Send a notification
/// await ref.read(sendNotificationStateProvider.notifier).sendNotification(
///   userId: 'user123',
///   title: 'Order Confirmed',
///   body: 'Your order has been confirmed and is being processed.',
///   type: NotificationType.order,
///   channels: [NotificationChannel.push, NotificationChannel.email],
/// );
/// ```
///
/// ## Integration:
///
/// To integrate this feature into your app:
///
/// 1. Add the routes to your router configuration
/// 2. Ensure Firebase is properly configured
/// 3. Add the necessary dependencies to your pubspec.yaml
/// 4. Initialize the providers in your app
///
/// ## Testing:
///
/// The feature includes comprehensive unit tests for:
/// - Domain entities and use cases
/// - Data models and repositories
/// - Presentation providers and logic
///
/// ## Performance:
///
/// The feature is optimized for performance with:
/// - Pagination for large datasets
/// - Efficient state management
/// - Optimistic UI updates
/// - Caching for frequently accessed data
/// - Real-time updates where appropriate
///
/// ## Security:
///
/// Security considerations include:
/// - User authentication and authorization
/// - Data validation and sanitization
/// - Secure API communication
/// - Privacy-compliant data handling
///
/// ## Scalability:
///
/// The feature is designed to scale with:
/// - Modular architecture
/// - Efficient database queries
/// - Proper error handling
/// - Monitoring and analytics
///
/// For more detailed documentation, see the individual component files.
class NotificationsFeature {
  static const String name = 'Notifications & Communication';
  static const String version = '1.0.0';
  static const String description =
      'Comprehensive notification and communication management system';

  /// Feature capabilities
  static const List<String> capabilities = [
    'Notification Center',
    'Campaign Management',
    'Template Management',
    'Multi-channel Support',
    'Real-time Analytics',
    'Audience Targeting',
    'Scheduling & Automation',
    'Template Variables',
    'Performance Tracking',
    'User Preferences',
  ];

  /// Supported notification types
  static const List<NotificationType> supportedTypes = NotificationType.values;

  /// Supported notification channels
  static const List<NotificationChannel> supportedChannels =
      NotificationChannel.values;

  /// Feature status
  static const bool isEnabled = true;
  static const bool isStable = true;
  static const bool isProduction = true;
}
