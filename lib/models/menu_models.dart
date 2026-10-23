/// Root of the JSON config.
class AppConfig {
  final String appTitle;
  final List<MenuItem> menus;

  const AppConfig({required this.appTitle, required this.menus});

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
    appTitle: json['appTitle'] as String? ?? 'App',
    menus: _list(json['menus'], MenuItem.fromJson),
  );
}

/// A menu entry. Has either [subMenus] (navigates deeper) or a [form] (leaf).
class MenuItem {
  final String id;
  final String title;
  final String? icon;
  final List<MenuItem> subMenus;
  final FormConfig? form;

  const MenuItem({
    required this.id,
    required this.title,
    this.icon,
    this.subMenus = const [],
    this.form,
  });

  bool get hasSubMenus => subMenus.isNotEmpty;

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
    id: json['id'] as String,
    title: json['title'] as String,
    icon: json['icon'] as String?,
    subMenus: _list(json['subMenus'], MenuItem.fromJson),
    form: json['form'] == null
        ? null
        : FormConfig.fromJson(json['form'] as Map<String, dynamic>),
  );
}

class FormConfig {
  final String title;
  final List<FieldConfig> fields;
  final List<ButtonConfig> buttons;

  const FormConfig({
    required this.title,
    required this.fields,
    required this.buttons,
  });

  factory FormConfig.fromJson(Map<String, dynamic> json) => FormConfig(
    title: json['title'] as String? ?? '',
    fields: _list(json['fields'], FieldConfig.fromJson),
    buttons: _list(json['buttons'], ButtonConfig.fromJson),
  );
}

enum FieldType { text, email, number, phone, password, multiline }

class FieldConfig {
  final String key;
  final FieldType type;
  final String label;
  final String? hint;
  final String? initialValue;
  final bool required;
  final int? minLength;
  final int? maxLength;
  final int maxLines;
  final String? pattern;
  final String? patternMessage;

  const FieldConfig({
    required this.key,
    required this.type,
    required this.label,
    this.hint,
    this.initialValue,
    this.required = false,
    this.minLength,
    this.maxLength,
    this.maxLines = 1,
    this.pattern,
    this.patternMessage,
  });

  factory FieldConfig.fromJson(Map<String, dynamic> json) => FieldConfig(
    key: json['key'] as String,
    type: FieldType.values.firstWhere(
      (t) => t.name == json['type'],
      orElse: () => FieldType.text,
    ),
    label: json['label'] as String? ?? '',
    hint: json['hint'] as String?,
    initialValue: json['initialValue'] as String?,
    required: json['required'] as bool? ?? false,
    minLength: json['minLength'] as int?,
    maxLength: json['maxLength'] as int?,
    maxLines: json['maxLines'] as int? ?? 1,
    pattern: json['pattern'] as String?,
    patternMessage: json['patternMessage'] as String?,
  );
}

enum ButtonAction { submit, reset, cancel }

enum ButtonStyleType { elevated, outlined, text }

class ButtonConfig {
  final String label;
  final ButtonAction action;
  final ButtonStyleType style;

  const ButtonConfig({
    required this.label,
    required this.action,
    this.style = ButtonStyleType.elevated,
  });

  factory ButtonConfig.fromJson(Map<String, dynamic> json) => ButtonConfig(
    label: json['label'] as String,
    action: ButtonAction.values.firstWhere(
      (a) => a.name == json['action'],
      orElse: () => ButtonAction.submit,
    ),
    style: ButtonStyleType.values.firstWhere(
      (s) => s.name == json['style'],
      orElse: () => ButtonStyleType.elevated,
    ),
  );
}

List<T> _list<T>(dynamic raw, T Function(Map<String, dynamic>) fromJson) =>
    (raw as List<dynamic>? ?? [])
        .map((e) => fromJson(e as Map<String, dynamic>))
        .toList();
