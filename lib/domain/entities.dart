import 'package:equatable/equatable.dart';

/// One selectable config (Sales, HR, …) from `workspaces.json`.
class Workspace extends Equatable {
  final String id;
  final String title;
  final String? icon;

  const Workspace({required this.id, required this.title, this.icon});

  @override
  List<Object?> get props => [id, title, icon];
}

/// Menu tree of one workspace.
class AppConfig extends Equatable {
  final String appTitle;
  final List<MenuItem> menus;

  const AppConfig({required this.appTitle, required this.menus});

  @override
  List<Object?> get props => [appTitle, menus];
}

/// A menu entry: has [subMenus] (opens another list) or a [form].
class MenuItem extends Equatable {
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

  @override
  List<Object?> get props => [id, title, icon, subMenus, form];
}

class FormConfig extends Equatable {
  final String title;
  final List<FieldConfig> fields;
  final List<ButtonConfig> buttons;

  const FormConfig({
    required this.title,
    this.fields = const [],
    this.buttons = const [],
  });

  @override
  List<Object?> get props => [title, fields, buttons];
}

enum FieldType { text, email, number, phone, password, multiline }

class FieldConfig extends Equatable {
  final String key;
  final FieldType type;
  final String label;
  final String? hint;
  final bool required;

  const FieldConfig({
    required this.key,
    required this.type,
    required this.label,
    this.hint,
    this.required = false,
  });

  @override
  List<Object?> get props => [key, type, label, hint, required];
}

enum ButtonAction { submit, reset, cancel }

class ButtonConfig extends Equatable {
  final String label;
  final ButtonAction action;

  const ButtonConfig({required this.label, required this.action});

  @override
  List<Object?> get props => [label, action];
}
