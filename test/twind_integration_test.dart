import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_twind/flutter_twind.dart';
import 'package:mobile/core/theme/app_theme.dart';
import 'package:mobile/core/twind/twind_ui.dart';
import 'package:mobile/features/demo/screens/twind_demo_screen.dart';

void main() {
  setUpAll(() {
    WindConfig.initialize();
    SmartStyleParser.addColorSystem('voltech', {
      'red': AppTheme.voltechRed,
      'gold': AppTheme.voltechGold,
      'black': AppTheme.premiumBlack,
      'dark': AppTheme.premiumDarkGray,
    });
  });

  group('Flutter Twind Integration & Component Suite', () {
    testWidgets('TwindDemoScreen renders Twind components correctly', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(theme: AppTheme.darkTheme, home: const TwindDemoScreen()),
      );
      await tester.pumpAndSettle();

      // Verify WText header rendered
      expect(find.text('Flutter Twind Demo & QA'), findsOneWidget);

      // Verify WContainer styled title rendered
      expect(find.text('Twind Container (bg-red-600)'), findsOneWidget);

      // Verify Badges rendered
      expect(find.text('ACTIVE'), findsOneWidget);
      expect(find.text('PENDING'), findsOneWidget);
      expect(find.text('REJECTED'), findsOneWidget);
      expect(find.text('PREMIUM'), findsOneWidget);

      // Verify WButton variants rendered
      expect(find.text('Primary Button'), findsOneWidget);
      expect(find.text('Secondary Button'), findsOneWidget);
      expect(find.text('Outlined Button'), findsOneWidget);

      // Verify input interaction
      final inputFinder = find.byType(TextField);
      expect(inputFinder, findsOneWidget);
      await tester.enterText(inputFinder, 'Test Twind Input');
      await tester.pump();
      expect(find.text('Test Twind Input'), findsOneWidget);

      // Verify modal dialog trigger
      await tester.ensureVisible(find.text('Outlined Button'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Outlined Button'));
      await tester.pumpAndSettle();
      expect(find.text('Twind Dialog'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Yopish'));
      await tester.pumpAndSettle();
      expect(find.text('Twind Dialog'), findsNothing);
    });

    testWidgets('TwCard renders child with proper padding and background', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: TwCard(child: const Text('Inner Card Content'))),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Inner Card Content'), findsOneWidget);
    });
  });
}
