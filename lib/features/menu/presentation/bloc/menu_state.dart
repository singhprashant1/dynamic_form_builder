part of 'menu_bloc.dart';

sealed class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

final class MenuLoading extends MenuState {
  const MenuLoading();
}

final class MenuLoaded extends MenuState {
  final List<Workspace> workspaces;
  final Workspace workspace;
  final AppConfig config;

  const MenuLoaded({
    required this.workspaces,
    required this.workspace,
    required this.config,
  });

  @override
  List<Object?> get props => [workspaces, workspace, config];
}

final class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}
