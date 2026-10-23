part of 'menu_bloc.dart';

sealed class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

/// Load workspaces and open the first one. Also used for retry.
final class MenuStarted extends MenuEvent {
  const MenuStarted();
}

final class WorkspaceSelected extends MenuEvent {
  final String workspaceId;

  const WorkspaceSelected(this.workspaceId);

  @override
  List<Object?> get props => [workspaceId];
}
