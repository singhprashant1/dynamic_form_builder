import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_config.dart';
import '../repositories/menu_repository.dart';

/// Loads the menu config of one workspace, by workspace id.
class GetAppConfig implements UseCase<AppConfig, String> {
  final MenuRepository _repository;

  const GetAppConfig(this._repository);

  @override
  Future<Result<AppConfig>> call(String workspaceId) =>
      _repository.getAppConfig(workspaceId);
}
