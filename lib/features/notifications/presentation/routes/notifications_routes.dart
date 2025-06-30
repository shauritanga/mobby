import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/notification_center_screen.dart';
import '../screens/campaign_management_screen.dart';
import '../screens/templates_screen.dart';

class NotificationsRoutes {
  static const String notificationCenter = '/notifications';
  static const String campaignManagement = '/notifications/campaigns';
  static const String templates = '/notifications/templates';
  static const String createCampaign = '/notifications/campaigns/create';
  static const String editCampaign = '/notifications/campaigns/:id/edit';
  static const String campaignDetails = '/notifications/campaigns/:id';
  static const String createTemplate = '/notifications/templates/create';
  static const String editTemplate = '/notifications/templates/:id/edit';
  static const String templateDetails = '/notifications/templates/:id';

  static List<RouteBase> get routes => [
    GoRoute(
      path: notificationCenter,
      name: 'notification-center',
      builder: (context, state) => const NotificationCenterScreen(),
    ),
    GoRoute(
      path: campaignManagement,
      name: 'campaign-management',
      builder: (context, state) => const CampaignManagementScreen(),
      routes: [
        GoRoute(
          path: '/create',
          name: 'create-campaign',
          builder: (context, state) => const CreateCampaignScreen(),
        ),
        GoRoute(
          path: '/:id',
          name: 'campaign-details',
          builder: (context, state) {
            final campaignId = state.pathParameters['id']!;
            return CampaignDetailsScreen(campaignId: campaignId);
          },
          routes: [
            GoRoute(
              path: '/edit',
              name: 'edit-campaign',
              builder: (context, state) {
                final campaignId = state.pathParameters['id']!;
                return EditCampaignScreen(campaignId: campaignId);
              },
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: templates,
      name: 'templates',
      builder: (context, state) => const TemplatesScreen(),
      routes: [
        GoRoute(
          path: '/create',
          name: 'create-template',
          builder: (context, state) => const CreateTemplateScreen(),
        ),
        GoRoute(
          path: '/:id',
          name: 'template-details',
          builder: (context, state) {
            final templateId = state.pathParameters['id']!;
            return TemplateDetailsScreen(templateId: templateId);
          },
          routes: [
            GoRoute(
              path: '/edit',
              name: 'edit-template',
              builder: (context, state) {
                final templateId = state.pathParameters['id']!;
                return EditTemplateScreen(templateId: templateId);
              },
            ),
          ],
        ),
      ],
    ),
  ];
}

// Placeholder screens for routes that would be implemented
class CreateCampaignScreen extends StatelessWidget {
  const CreateCampaignScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Campaign')),
      body: const Center(
        child: Text('Create Campaign Screen - To be implemented'),
      ),
    );
  }
}

class CampaignDetailsScreen extends StatelessWidget {
  final String campaignId;

  const CampaignDetailsScreen({
    super.key,
    required this.campaignId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Campaign Details')),
      body: Center(
        child: Text('Campaign Details Screen - ID: $campaignId'),
      ),
    );
  }
}

class EditCampaignScreen extends StatelessWidget {
  final String campaignId;

  const EditCampaignScreen({
    super.key,
    required this.campaignId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Campaign')),
      body: Center(
        child: Text('Edit Campaign Screen - ID: $campaignId'),
      ),
    );
  }
}

class CreateTemplateScreen extends StatelessWidget {
  const CreateTemplateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Template')),
      body: const Center(
        child: Text('Create Template Screen - To be implemented'),
      ),
    );
  }
}

class TemplateDetailsScreen extends StatelessWidget {
  final String templateId;

  const TemplateDetailsScreen({
    super.key,
    required this.templateId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Template Details')),
      body: Center(
        child: Text('Template Details Screen - ID: $templateId'),
      ),
    );
  }
}

class EditTemplateScreen extends StatelessWidget {
  final String templateId;

  const EditTemplateScreen({
    super.key,
    required this.templateId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Template')),
      body: Center(
        child: Text('Edit Template Screen - ID: $templateId'),
      ),
    );
  }
}
