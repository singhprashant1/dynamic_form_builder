import 'package:bloc_test/bloc_test.dart';
import 'package:dynamic_form_builder/domain/entities.dart';
import 'package:dynamic_form_builder/domain/menu_repository.dart';
import 'package:dynamic_form_builder/presentation/cubit/menu_cubit.dart';
import 'package:flutter_test/flutter_test.dart';

const sales = Workspace(id: 'sales', title: 'Sales');
const hr = Workspace(id: 'hr', title: 'HR');

class _FakeRepository implements MenuRepository {
  bool fail = false;

  @override
  Future<List<Workspace>> getWorkspaces() async {
    if (fail) throw Exception('boom');
    return const [sales, hr];
  }

  @override
  Future<AppConfig> getAppConfig(String id) async =>
      AppConfig(appTitle: id, menus: const []);
}

void main() {
  blocTest<MenuCubit, MenuState>(
    'load opens the first workspace',
    build: () => MenuCubit(_FakeRepository()),
    act: (cubit) => cubit.load(),
    expect: () => [
      const MenuLoading(),
      const MenuLoaded(
        workspaces: [sales, hr],
        current: sales,
        config: AppConfig(appTitle: 'sales', menus: []),
      ),
    ],
  );

  blocTest<MenuCubit, MenuState>(
    'selectWorkspace loads that config',
    build: () => MenuCubit(_FakeRepository()),
    seed: () => const MenuLoaded(
      workspaces: [sales, hr],
      current: sales,
      config: AppConfig(appTitle: 'sales', menus: []),
    ),
    act: (cubit) => cubit.selectWorkspace(hr),
    expect: () => [
      const MenuLoading(),
      const MenuLoaded(
        workspaces: [sales, hr],
        current: hr,
        config: AppConfig(appTitle: 'hr', menus: []),
      ),
    ],
  );

  blocTest<MenuCubit, MenuState>(
    'select stores the picked item; null clears it',
    build: () => MenuCubit(_FakeRepository()),
    seed: () => const MenuLoaded(
      workspaces: [sales, hr],
      current: sales,
      config: AppConfig(appTitle: 'sales', menus: []),
    ),
    act: (cubit) => cubit
      ..select(const MenuItem(id: 'a', title: 'A'))
      ..select(null),
    expect: () => [
      const MenuLoaded(
        workspaces: [sales, hr],
        current: sales,
        config: AppConfig(appTitle: 'sales', menus: []),
        selected: MenuItem(id: 'a', title: 'A'),
      ),
      const MenuLoaded(
        workspaces: [sales, hr],
        current: sales,
        config: AppConfig(appTitle: 'sales', menus: []),
      ),
    ],
  );

  blocTest<MenuCubit, MenuState>(
    'load failure emits error',
    build: () => MenuCubit(_FakeRepository()..fail = true),
    act: (cubit) => cubit.load(),
    expect: () => [const MenuLoading(), isA<MenuError>()],
  );
}
