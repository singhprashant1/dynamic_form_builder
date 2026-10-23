import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/app_config.dart';
import '../../domain/entities/workspace.dart';
import '../../domain/repositories/menu_repository.dart';
import '../datasources/menu_data_source.dart';
import '../models/config_mapper.dart';

class MenuRepositoryImpl implements MenuRepository {
  final MenuDataSource _dataSource;
  final ConfigMapper _mapper;

  /// workspace id → config source, filled by [getWorkspaces].
  final _sources = <String, String>{};

  MenuRepositoryImpl(this._dataSource, this._mapper);

  @override
  Future<Result<List<Workspace>>> getWorkspaces() async {
    final result = await _guard(
      _dataSource.fetchWorkspaces,
      _mapper.workspaces,
    );
    switch (result) {
      case Ok(:final value):
        _sources
          ..clear()
          ..addEntries(value.map((e) => MapEntry(e.workspace.id, e.source)));
        return Ok([for (final e in value) e.workspace]);
      case Err(:final failure):
        return Err(failure);
    }
  }

  @override
  Future<Result<AppConfig>> getAppConfig(String workspaceId) async {
    if (!_sources.containsKey(workspaceId)) {
      if (await getWorkspaces() case Err(:final failure)) return Err(failure);
    }
    final source = _sources[workspaceId];
    if (source == null) {
      return Err(LoadFailure('Unknown workspace "$workspaceId"'));
    }
    return _guard(() => _dataSource.fetchConfig(source), _mapper.appConfig);
  }

  /// Fetches JSON and maps it, converting errors to [Failure]s.
  Future<Result<T>> _guard<T>(
    Future<Map<String, dynamic>> Function() fetch,
    T Function(Map<String, dynamic>) map,
  ) async {
    final Map<String, dynamic> json;
    try {
      json = await fetch();
    } on DataSourceException catch (e) {
      return Err(LoadFailure(e.message));
    }
    try {
      return Ok(map(json));
    } on TypeError catch (e) {
      return Err(ParseFailure('Malformed config: $e'));
    }
  }
}
