import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities.dart';
import '../../domain/menu_repository.dart';

part 'menu_state.dart';

/// Loads the workspaces and the selected workspace's menu config.
class MenuCubit extends Cubit<MenuState> {
  final MenuRepository _repository;

  MenuCubit(this._repository) : super(const MenuLoading());

  /// Loads all workspaces and opens the first one. Also used for retry.
  Future<void> load() async {
    emit(const MenuLoading());
    try {
      final workspaces = await _repository.getWorkspaces();
      await _open(workspaces, workspaces.first);
    } catch (e) {
      emit(MenuError('Could not load menu: $e'));
    }
  }

  Future<void> selectWorkspace(Workspace workspace) async {
    final current = state;
    if (current is! MenuLoaded || current.current == workspace) return;
    emit(const MenuLoading());
    try {
      await _open(current.workspaces, workspace);
    } catch (e) {
      emit(MenuError('Could not load ${workspace.title}: $e'));
    }
  }

  Future<void> _open(List<Workspace> workspaces, Workspace workspace) async {
    final config = await _repository.getAppConfig(workspace.id);
    emit(
      MenuLoaded(workspaces: workspaces, current: workspace, config: config),
    );
  }
}
