import '../../../../core/result/result.dart';
import '../entities/app_config.dart';
import '../entities/workspace.dart';

/// Source of workspaces and their menu/form configs (DIP).
abstract interface class MenuRepository {
  Future<Result<List<Workspace>>> getWorkspaces();

  Future<Result<AppConfig>> getAppConfig(String workspaceId);
}
