import '../../../dynamic_form/domain/entities/api_config.dart';
import '../../../dynamic_form/domain/entities/button_config.dart';
import '../../../dynamic_form/domain/entities/field_config.dart';
import '../../../dynamic_form/domain/entities/form_config.dart';
import '../../domain/entities/app_config.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/menu_layout.dart';
import '../../domain/entities/workspace.dart';

/// A workspace plus where its config lives. `source` is a data-layer detail
/// and never reaches the domain.
typedef WorkspaceEntry = ({Workspace workspace, String source});

/// Maps raw JSON to domain entities. Keeps JSON knowledge out of the domain.
/// Throws [TypeError] on malformed input.
class ConfigMapper {
  const ConfigMapper();

  List<WorkspaceEntry> workspaces(Map<String, dynamic> json) =>
      _list(json['workspaces'], (w) {
        return (
          workspace: Workspace(
            id: w['id'] as String,
            title: w['title'] as String,
            description: w['description'] as String?,
            icon: w['icon'] as String?,
            color: w['color'] as String?,
          ),
          source: w['source'] as String,
        );
      });

  AppConfig appConfig(Map<String, dynamic> json) => AppConfig(
    appTitle: json['appTitle'] as String? ?? 'App',
    layout: _enum(MenuLayout.values, json['layout'], MenuLayout.grid),
    menus: _list(json['menus'], menuItem),
  );

  MenuItem menuItem(Map<String, dynamic> json) {
    final id = json['id'] as String;
    final form = json['form'] as Map<String, dynamic>?;
    return MenuItem(
      id: id,
      title: json['title'] as String,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      color: json['color'] as String?,
      layout: _enum(MenuLayout.values, json['layout'], MenuLayout.list),
      subMenus: _list(json['subMenus'], menuItem),
      form: form == null ? null : formConfig(form, fallbackId: id),
    );
  }

  FormConfig formConfig(
    Map<String, dynamic> json, {
    required String fallbackId,
  }) => FormConfig(
    id: json['id'] as String? ?? fallbackId,
    title: json['title'] as String? ?? '',
    description: json['description'] as String?,
    fields: _list(json['fields'], fieldConfig),
    buttons: _list(json['buttons'], buttonConfig),
  );

  FieldConfig fieldConfig(Map<String, dynamic> json) => FieldConfig(
    key: json['key'] as String,
    type: _enum(FieldType.values, json['type'], FieldType.text),
    label: json['label'] as String? ?? '',
    hint: json['hint'] as String?,
    icon: json['icon'] as String?,
    initialValue: json['initialValue'] as String?,
    required: json['required'] as bool? ?? false,
    minLength: json['minLength'] as int?,
    maxLength: json['maxLength'] as int?,
    maxLines: json['maxLines'] as int? ?? 1,
    pattern: json['pattern'] as String?,
    patternMessage: json['patternMessage'] as String?,
  );

  ButtonConfig buttonConfig(Map<String, dynamic> json) {
    final api = json['api'] as Map<String, dynamic>?;
    return ButtonConfig(
      label: json['label'] as String,
      action: _enum(ButtonAction.values, json['action'], ButtonAction.submit),
      variant: _enum(ButtonVariant.values, json['style'], ButtonVariant.filled),
      icon: json['icon'] as String?,
      api: api == null ? null : apiConfig(api),
    );
  }

  ApiConfig apiConfig(Map<String, dynamic> json) {
    final mock = json['mock'] as Map<String, dynamic>? ?? const {};
    return ApiConfig(
      endpoint: json['endpoint'] as String,
      method: _enum(
        HttpMethod.values,
        (json['method'] as String?)?.toLowerCase(),
        HttpMethod.post,
      ),
      successMessage: json['successMessage'] as String?,
      errorMessage: json['errorMessage'] as String?,
      mockDelay: Duration(milliseconds: mock['delayMs'] as int? ?? 900),
      mockFail: mock['fail'] as bool? ?? false,
    );
  }

  List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) map) =>
      (raw as List<dynamic>? ?? [])
          .map((e) => map(e as Map<String, dynamic>))
          .toList();

  T _enum<T extends Enum>(List<T> values, dynamic name, T fallback) =>
      values.firstWhere((v) => v.name == name, orElse: () => fallback);
}
