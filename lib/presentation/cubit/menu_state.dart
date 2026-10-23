part of 'menu_cubit.dart';

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
  final Workspace current;
  final AppConfig config;

  const MenuLoaded({
    required this.workspaces,
    required this.current,
    required this.config,
  });

  @override
  List<Object?> get props => [workspaces, current, config];
}

final class MenuError extends MenuState {
  final String message;

  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}
