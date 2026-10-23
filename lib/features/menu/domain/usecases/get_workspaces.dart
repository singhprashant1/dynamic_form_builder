import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/workspace.dart';
import '../repositories/menu_repository.dart';

class GetWorkspaces implements UseCase<List<Workspace>, NoParams> {
  final MenuRepository _repository;

  const GetWorkspaces(this._repository);

  @override
  Future<Result<List<Workspace>>> call(NoParams params) =>
      _repository.getWorkspaces();
}
