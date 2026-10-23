import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/app_config.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/usecases/get_app_config.dart';
import '../../domain/usecases/get_workspaces.dart';

part 'menu_event.dart';
part 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final GetWorkspaces _getWorkspaces;
  final GetAppConfig _getAppConfig;

  MenuBloc(this._getWorkspaces, this._getAppConfig)
    : super(const MenuLoading()) {
    on<MenuStarted>(_onStarted);
    on<WorkspaceSelected>(_onWorkspaceSelected);
  }

  Future<void> _onStarted(MenuStarted event, Emitter<MenuState> emit) async {
    emit(const MenuLoading());
    switch (await _getWorkspaces(const NoParams())) {
      case Err(:final failure):
        emit(MenuError(failure.message));
      case Ok(value: final workspaces) when workspaces.isEmpty:
        emit(const MenuError('No workspaces configured'));
      case Ok(value: final workspaces):
        await _open(workspaces, workspaces.first, emit);
    }
  }

  Future<void> _onWorkspaceSelected(
    WorkspaceSelected event,
    Emitter<MenuState> emit,
  ) async {
    final current = state;
    if (current is! MenuLoaded) return;
    if (current.workspace.id == event.workspaceId) return;
    final target = current.workspaces.firstWhere(
      (w) => w.id == event.workspaceId,
      orElse: () => current.workspace,
    );
    emit(const MenuLoading());
    await _open(current.workspaces, target, emit);
  }

  Future<void> _open(
    List<Workspace> workspaces,
    Workspace workspace,
    Emitter<MenuState> emit,
  ) async {
    switch (await _getAppConfig(workspace.id)) {
      case Ok(:final value):
        emit(
          MenuLoaded(
            workspaces: workspaces,
            workspace: workspace,
            config: value,
          ),
        );
      case Err(:final failure):
        emit(MenuError(failure.message));
    }
  }
}
