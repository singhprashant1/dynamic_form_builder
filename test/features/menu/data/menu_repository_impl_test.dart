import 'package:dynamic_form_builder/core/error/exceptions.dart';
import 'package:dynamic_form_builder/core/error/failures.dart';
import 'package:dynamic_form_builder/core/result/result.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/entities/api_config.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/entities/button_config.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/entities/field_config.dart';
import 'package:dynamic_form_builder/features/menu/data/datasources/menu_data_source.dart';
import 'package:dynamic_form_builder/features/menu/data/models/config_mapper.dart';
import 'package:dynamic_form_builder/features/menu/data/repositories/menu_repository_impl.dart';
import 'package:dynamic_form_builder/features/menu/domain/entities/app_config.dart';
import 'package:dynamic_form_builder/features/menu/domain/entities/menu_layout.dart';
import 'package:dynamic_form_builder/features/menu/domain/entities/workspace.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockDataSource extends Mock implements MenuDataSource {}

void main() {
  late _MockDataSource dataSource;
  late MenuRepositoryImpl repository;

  const index = {
    'workspaces': [
      {
        'id': 'hr',
        'title': 'HR',
        'icon': 'groups',
        'color': '#00897B',
        'source': 'hr.json',
      },
    ],
  };

  setUp(() {
    dataSource = _MockDataSource();
    repository = MenuRepositoryImpl(dataSource, const ConfigMapper());
    when(() => dataSource.fetchWorkspaces()).thenAnswer((_) async => index);
  });

  test('getWorkspaces maps the index without exposing source', () async {
    final result = await repository.getWorkspaces();
    expect((result as Ok<List<Workspace>>).value, const [
      Workspace(id: 'hr', title: 'HR', icon: 'groups', color: '#00897B'),
    ]);
  });

  test(
    'getAppConfig loads the workspace source and maps nested JSON',
    () async {
      when(() => dataSource.fetchConfig('hr.json')).thenAnswer(
        (_) async => {
          'appTitle': 'HR',
          'layout': 'tabs',
          'menus': [
            {
              'id': 'a',
              'title': 'A',
              'color': '#FF0000',
              'layout': 'expandable',
              'subMenus': [
                {
                  'id': 'a1',
                  'title': 'A1',
                  'form': {
                    'title': 'Form A1',
                    'fields': [
                      {
                        'key': 'mail',
                        'type': 'email',
                        'label': 'Mail',
                        'icon': 'email',
                      },
                      {'key': 'x', 'type': 'unknown', 'label': 'X'},
                    ],
                    'buttons': [
                      {
                        'label': 'Go',
                        'action': 'submit',
                        'style': 'tonal',
                        'api': {
                          'endpoint': '/go',
                          'method': 'PUT',
                          'mock': {'fail': true, 'delayMs': 10},
                        },
                      },
                    ],
                  },
                },
              ],
            },
          ],
        },
      );

      // No prior getWorkspaces call: repository loads the index itself.
      final result = await repository.getAppConfig('hr');

      final config = (result as Ok<AppConfig>).value;
      expect(config.layout, MenuLayout.tabs);
      final menu = config.menus.single;
      expect(menu.layout, MenuLayout.expandable);
      expect(menu.color, '#FF0000');
      final form = menu.subMenus.single.form!;
      expect(form.id, 'a1', reason: 'form id falls back to menu id');
      expect(form.fields.map((f) => f.type), [FieldType.email, FieldType.text]);
      expect(form.fields.first.icon, 'email');
      final button = form.buttons.single;
      expect(button.variant, ButtonVariant.tonal);
      expect(
        button.api,
        const ApiConfig(
          endpoint: '/go',
          method: HttpMethod.put,
          mockDelay: Duration(milliseconds: 10),
          mockFail: true,
        ),
      );
    },
  );

  test('unknown workspace → LoadFailure', () async {
    final result = await repository.getAppConfig('nope');
    expect((result as Err).failure, isA<LoadFailure>());
  });

  test('data source error → LoadFailure', () async {
    when(() => dataSource.fetchWorkspaces())
        .thenThrow(const DataSourceException('missing'));
    final result = await repository.getWorkspaces();
    expect((result as Err).failure, const LoadFailure('missing'));
  });

  test('malformed JSON → ParseFailure', () async {
    when(() => dataSource.fetchConfig('hr.json')).thenAnswer(
      (_) async => {
        'menus': [
          {'id': 1},
        ],
      },
    );
    final result = await repository.getAppConfig('hr');
    expect((result as Err).failure, isA<ParseFailure>());
  });
}
