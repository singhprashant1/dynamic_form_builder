import 'package:dynamic_form_builder/app.dart';
import 'package:dynamic_form_builder/core/di/injection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(configureDependencies);
  tearDown(() async {
    await sl.reset();
    // rootBundle caches across tests; a Future from a previous test's zone
    // never resolves in the next one.
    rootBundle.clear();
  });

  Future<void> startApp(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.5;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const App());
    await tester.pumpAndSettle();
  }

  Future<void> switchWorkspace(WidgetTester tester, String title) async {
    await tester.tap(find.byTooltip('Switch workspace'));
    await tester.pumpAndSettle();
    await tester.tap(find.text(title).last);
    await tester.pumpAndSettle();
  }

  testWidgets('grid → list → form: validation, live re-validate, reset', (
    tester,
  ) async {
    await startApp(tester);

    expect(find.text('Sales & CRM'), findsWidgets);
    expect(find.text('Customers'), findsOneWidget);

    await tester.tap(find.text('Customers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Customer'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(4));

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Full Name is required'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).first, 'Prashant');
    await tester.pump();
    expect(find.text('Full Name is required'), findsNothing);

    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(find.text('Prashant'), findsNothing);
  });

  testWidgets('mock API success shows the success sheet; Done pops', (
    tester,
  ) async {
    await startApp(tester);

    await tester.tap(find.text('Settings'));
    await tester.pumpAndSettle();

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'oldpass');
    await tester.enterText(fields.at(1), 'newpassword');
    await tester.tap(find.text('Update'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();
    expect(find.text('Password updated'), findsOneWidget);
    expect(find.text('••••••••'), findsNWidgets(2), reason: 'masked');

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    expect(find.text('Change Password'), findsNothing);
    expect(find.text('Customers'), findsOneWidget);
  });

  testWidgets('tabs layout renders forms inline', (tester) async {
    await startApp(tester);

    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();

    expect(find.byType(TabBar), findsOneWidget);
    expect(find.text('Place Order'), findsOneWidget);

    await tester.tap(find.text('Reports'));
    await tester.pumpAndSettle();
    expect(find.text('Daily Report'), findsOneWidget);
  });

  testWidgets('switching workspace re-renders with that config layout', (
    tester,
  ) async {
    await startApp(tester);

    await switchWorkspace(tester, 'HR Portal');
    expect(find.text('Employees'), findsOneWidget);

    // Payroll uses the expandable layout.
    await tester.tap(find.text('Payroll'));
    await tester.pumpAndSettle();
    expect(find.text('Request Payslip'), findsNothing);
    await tester.tap(find.text('Salary'));
    await tester.pumpAndSettle();
    expect(find.text('Request Payslip'), findsOneWidget);
  });

  testWidgets('mock API failure shows error snackbar with retry', (
    tester,
  ) async {
    await startApp(tester);
    await switchWorkspace(tester, 'Inventory');

    await tester.tap(find.text('ERP Sync'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'secret');
    await tester.tap(find.text('Sync Now'));
    await tester.pumpAndSettle();

    expect(
      find.text('ERP server is unreachable. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('every workspace config loads', (tester) async {
    await startApp(tester);
    for (final title in ['HR Portal', 'Inventory', 'School Admin']) {
      await switchWorkspace(tester, title);
      expect(find.text("Couldn't load menu"), findsNothing, reason: title);
      expect(find.text(title), findsWidgets);
    }
    // School root uses tabs.
    expect(find.byType(TabBar), findsOneWidget);
  });
}
