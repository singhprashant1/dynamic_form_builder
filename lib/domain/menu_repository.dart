import 'entities.dart';

/// What the UI needs. The data layer decides where it comes from.
abstract interface class MenuRepository {
  Future<List<Workspace>> getWorkspaces();

  Future<AppConfig> getAppConfig(String workspaceId);
}
