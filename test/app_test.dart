import 'package:dynamic_form_builder/data/json_data_source.dart';
import 'package:dynamic_form_builder/data/menu_repository_impl.dart';
import 'package:dynamic_form_builder/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // rootBundle caches across tests; a Future from a previous test's zone
  // never resolves in the next one.
  tearDown(rootBundle.clear);

  Future<void> startApp(WidgetTester tester) async {
    await tester.pumpWidget(
      App(repository: MenuRepositoryImpl(JsonDataSource(rootBundle))),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('menu → sub-menu → form: required check, reset, submit', (
    tester,
  ) async {
    await startApp(tester);
    expect(find.text('Sales & CRM'), findsOneWidget);

    await tester.tap(find.text('Customers'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Customer'));
    await tester.pumpAndSettle();
    expect(find.byType(TextFormField), findsNWidgets(4));

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('Full Name is required'), findsOneWidget);

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Prashant');
    await tester.tap(find.text('Reset'));
    await tester.pump();
    expect(find.text('Prashant'), findsNothing);

    await tester.enterText(fields.at(0), 'Prashant');
    await tester.enterText(fields.at(1), 'p@example.com');
    await tester.enterText(fields.at(2), '9876543210');
    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(find.text('New Customer submitted'), findsOneWidget);
  });

  testWidgets('switching workspace shows its menus', (tester) async {
    await startApp(tester);

    await tester.tap(find.byTooltip('Switch workspace'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('HR Portal'));
    await tester.pumpAndSettle();

    expect(find.text('HR Portal'), findsOneWidget);
    expect(find.text('Employees'), findsOneWidget);
  });
}
