import 'package:bloc_test/bloc_test.dart';
import 'package:dynamic_form_builder/core/error/failures.dart';
import 'package:dynamic_form_builder/core/result/result.dart';
import 'package:dynamic_form_builder/features/menu/domain/entities/app_config.dart';
import 'package:dynamic_form_builder/features/menu/domain/entities/workspace.dart';
import 'package:dynamic_form_builder/features/menu/domain/repositories/menu_repository.dart';
import 'package:dynamic_form_builder/features/menu/domain/usecases/get_app_config.dart';
import 'package:dynamic_form_builder/features/menu/domain/usecases/get_workspaces.dart';
import 'package:dynamic_form_builder/features/menu/presentation/bloc/menu_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockMenuRepository extends Mock implements MenuRepository {}

void main() {
  late _MockMenuRepository repository;
  const sales = Workspace(id: 'sales', title: 'Sales');
  const hr = Workspace(id: 'hr', title: 'HR');
  const salesConfig = AppConfig(appTitle: 'Sales', menus: []);
  const hrConfig = AppConfig(appTitle: 'HR', menus: []);

  MenuBloc build() =>
      MenuBloc(GetWorkspaces(repository), GetAppConfig(repository));

  setUp(() {
    repository = _MockMenuRepository();
    when(() => repository.getWorkspaces())
        .thenAnswer((_) async => const Ok([sales, hr]));
    when(() => repository.getAppConfig('sales'))
        .thenAnswer((_) async => const Ok(salesConfig));
    when(() => repository.getAppConfig('hr'))
        .thenAnswer((_) async => const Ok(hrConfig));
  });

  blocTest<MenuBloc, MenuState>(
    'start opens the first workspace',
    build: build,
    act: (bloc) => bloc.add(const MenuStarted()),
    expect: () => [
      const MenuLoading(),
      const MenuLoaded(
        workspaces: [sales, hr],
        workspace: sales,
        config: salesConfig,
      ),
    ],
  );

  blocTest<MenuBloc, MenuState>(
    'selecting a workspace loads its config',
    build: build,
    seed: () => const MenuLoaded(
      workspaces: [sales, hr],
      workspace: sales,
      config: salesConfig,
    ),
    act: (bloc) => bloc.add(const WorkspaceSelected('hr')),
    expect: () => [
      const MenuLoading(),
      const MenuLoaded(
        workspaces: [sales, hr],
        workspace: hr,
        config: hrConfig,
      ),
    ],
  );

  blocTest<MenuBloc, MenuState>(
    'selecting the current workspace does nothing',
    build: build,
    seed: () => const MenuLoaded(
      workspaces: [sales, hr],
      workspace: sales,
      config: salesConfig,
    ),
    act: (bloc) => bloc.add(const WorkspaceSelected('sales')),
    expect: () => <MenuState>[],
  );

  blocTest<MenuBloc, MenuState>(
    'no workspaces → error',
    setUp: () =>
        when(() => repository.getWorkspaces())
            .thenAnswer((_) async => const Ok([])),
    build: build,
    act: (bloc) => bloc.add(const MenuStarted()),
    expect: () => [
      const MenuLoading(),
      const MenuError('No workspaces configured'),
    ],
  );

  blocTest<MenuBloc, MenuState>(
    'config failure → error',
    setUp: () =>
        when(() => repository.getAppConfig('sales'))
            .thenAnswer((_) async => const Err(LoadFailure('boom'))),
    build: build,
    act: (bloc) => bloc.add(const MenuStarted()),
    expect: () => [const MenuLoading(), const MenuError('boom')],
  );
}
