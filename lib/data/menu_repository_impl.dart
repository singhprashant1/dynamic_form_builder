import '../domain/entities.dart';
import '../domain/menu_repository.dart';
import 'json_data_source.dart';

/// Loads `workspaces.json` and each workspace's config, and maps the JSON
/// to domain entities. All JSON key names live in this file.
class MenuRepositoryImpl implements MenuRepository {
  static const _indexPath = 'assets/data/workspaces.json';

  final JsonDataSource _source;

  /// workspace id → config file path, filled by [getWorkspaces].
  final _paths = <String, String>{};

  MenuRepositoryImpl(this._source);

  @override
  Future<List<Workspace>> getWorkspaces() async {
    final json = await _source.load(_indexPath);
    final list = json['workspaces'] as List<dynamic>;
    return [
      for (final w in list.cast<Map<String, dynamic>>()) _rememberPath(w),
    ];
  }

  @override
  Future<AppConfig> getAppConfig(String workspaceId) async {
    if (_paths.isEmpty) await getWorkspaces();
    final path = _paths[workspaceId];
    if (path == null) throw ArgumentError('Unknown workspace "$workspaceId"');

    final json = await _source.load(path);
    return AppConfig(
      appTitle: json['appTitle'] as String,
      menus: _list(json['menus'], _menuItem),
    );
  }

  Workspace _rememberPath(Map<String, dynamic> w) {
    final id = w['id'] as String;
    _paths[id] = w['source'] as String;
    return Workspace(
      id: id,
      title: w['title'] as String,
      icon: w['icon'] as String?,
    );
  }

  MenuItem _menuItem(Map<String, dynamic> json) {
    final form = json['form'] as Map<String, dynamic>?;
    return MenuItem(
      id: json['id'] as String,
      title: json['title'] as String,
      icon: json['icon'] as String?,
      subMenus: _list(json['subMenus'], _menuItem),
      form: form == null ? null : _formConfig(form),
    );
  }

  FormConfig _formConfig(Map<String, dynamic> json) => FormConfig(
    title: json['title'] as String? ?? '',
    fields: _list(
      json['fields'],
      (f) => FieldConfig(
        key: f['key'] as String,
        type: _enum(FieldType.values, f['type'], FieldType.text),
        label: f['label'] as String? ?? '',
        hint: f['hint'] as String?,
        required: f['required'] as bool? ?? false,
      ),
    ),
    buttons: _list(
      json['buttons'],
      (b) => ButtonConfig(
        label: b['label'] as String,
        action: _enum(ButtonAction.values, b['action'], ButtonAction.submit),
      ),
    ),
  );

  List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) map) => [
    for (final e in (raw as List<dynamic>? ?? []))
      map(e as Map<String, dynamic>),
  ];

  /// Unknown values fall back instead of crashing.
  T _enum<T extends Enum>(List<T> values, dynamic name, T fallback) =>
      values.firstWhere((v) => v.name == name, orElse: () => fallback);
}
