import 'package:dynamic_form_builder/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders menus from JSON and opens a form', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Orders'), findsOneWidget);

    await tester.tap(find.text('Customer'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add Customer'));
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(4));

    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();
    expect(find.text('Full Name is required'), findsOneWidget);
  });
}
