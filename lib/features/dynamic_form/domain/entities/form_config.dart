import 'package:equatable/equatable.dart';

import 'button_config.dart';
import 'field_config.dart';

class FormConfig extends Equatable {
  final String id;
  final String title;
  final String? description;
  final List<FieldConfig> fields;
  final List<ButtonConfig> buttons;

  const FormConfig({
    required this.id,
    required this.title,
    this.description,
    this.fields = const [],
    this.buttons = const [],
  });

  /// Initial value for every field, keyed by [FieldConfig.key].
  Map<String, String> get initialValues => {
    for (final f in fields) f.key: f.initialValue ?? '',
  };

  @override
  List<Object?> get props => [id, title, description, fields, buttons];
}
