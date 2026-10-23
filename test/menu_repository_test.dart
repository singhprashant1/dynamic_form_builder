import 'package:dynamic_form_builder/data/json_data_source.dart';
import 'package:dynamic_form_builder/data/menu_repository_impl.dart';
import 'package:dynamic_form_builder/domain/entities.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final repository = MenuRepositoryImpl(JsonDataSource(rootBundle));

  test('loads the 4 workspaces', () async {
    final workspaces = await repository.getWorkspaces();
    expect(workspaces.map((w) => w.id), ['sales', 'hr', 'inventory', 'school']);
  });

  test('every workspace config maps to menus with forms', () async {
    for (final id in ['sales', 'hr', 'inventory', 'school']) {
      final config = await repository.getAppConfig(id);
      expect(config.menus, isNotEmpty, reason: id);
    }
  });

  test('maps nested sub-menus, fields and buttons', () async {
    final config = await repository.getAppConfig('sales');
    final customers = config.menus.first;
    expect(customers.title, 'Customers');
    final form = customers.subMenus.first.form!;
    expect(form.title, 'New Customer');
    expect(
      form.fields.first,
      const FieldConfig(
        key: 'name',
        type: FieldType.text,
        label: 'Full Name',
        hint: 'Enter full name',
        required: true,
      ),
    );
    expect(form.buttons.map((b) => b.action), [
      ButtonAction.reset,
      ButtonAction.submit,
    ]);
  });
}
