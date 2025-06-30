import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mobby/features/latra/presentation/widgets/application_type_selector.dart';
import 'package:mobby/features/latra/domain/entities/latra_application.dart';

void main() {
  group('LATRA Widget Tests', () {
    testWidgets('ApplicationTypeSelector should render correctly', (
      WidgetTester tester,
    ) async {
      // Set up screen size for ScreenUtil
      tester.view.physicalSize = const Size(375, 812);
      tester.view.devicePixelRatio = 1.0;

      // Build our app and trigger a frame.
      await tester.pumpWidget(
        ProviderScope(
          child: ScreenUtilInit(
            designSize: const Size(375, 812),
            child: MaterialApp(
              home: Scaffold(
                body: ApplicationTypeSelector(
                  selectedType: LATRAApplicationType.vehicleRegistration,
                  onTypeSelected: (type) {},
                ),
              ),
            ),
          ),
        ),
      );

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify that the widget renders
      expect(find.byType(ApplicationTypeSelector), findsOneWidget);

      // Verify that vehicle registration option is visible
      expect(find.text('Vehicle Registration'), findsOneWidget);
    });
  });
}
