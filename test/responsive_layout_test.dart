import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todo_app/core/widgets/responsive_layout.dart';

void main() {
  const mobileKey = Key('mobile_layout');
  const desktopKey = Key('desktop_layout');

  const mobileWidget = SizedBox(key: mobileKey, child: Text('Mobile'));
  const desktopWidget = SizedBox(key: desktopKey, child: Text('Desktop'));

  testWidgets(
    'ResponsiveLayout renders mobileLayout when width is below breakpoint',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(500, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobileLayout: mobileWidget,
            desktopLayout: desktopWidget,
            breakpoint: 768.0,
          ),
        ),
      );

      expect(find.byKey(mobileKey), findsOneWidget);
      expect(find.byKey(desktopKey), findsNothing);
    },
  );

  testWidgets(
    'ResponsiveLayout renders desktopLayout when width is equal to or above breakpoint',
    (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      await tester.pumpWidget(
        const MaterialApp(
          home: ResponsiveLayout(
            mobileLayout: mobileWidget,
            desktopLayout: desktopWidget,
            breakpoint: 768.0,
          ),
        ),
      );

      expect(find.byKey(desktopKey), findsOneWidget);
      expect(find.byKey(mobileKey), findsNothing);
    },
  );

  testWidgets('ResponsiveLayout works with default breakpoint', (
    WidgetTester tester,
  ) async {
    // Default breakpoint is 768.0.
    // Width 700: should be mobile.
    tester.view.physicalSize = const Size(700, 800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: ResponsiveLayout(
          mobileLayout: mobileWidget,
          desktopLayout: desktopWidget,
        ),
      ),
    );

    expect(find.byKey(mobileKey), findsOneWidget);
    expect(find.byKey(desktopKey), findsNothing);
  });
}
