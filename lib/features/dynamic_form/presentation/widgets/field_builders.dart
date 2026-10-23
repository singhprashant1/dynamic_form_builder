import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/presentation/app_icons.dart';
import '../../domain/entities/field_config.dart';

/// Builds the widget for one field type. To support a new type (dropdown,
/// checkbox, date…) add a [FieldBuilder] and register it in
/// [FieldBuilderRegistry] — no existing builder changes (OCP).
abstract interface class FieldBuilder {
  bool supports(FieldType type);

  Widget build({
    required FieldConfig field,
    required String value,
    required String? error,
    required ValueChanged<String> onChanged,
    required TextInputAction inputAction,
  });
}

class FieldBuilderRegistry {
  final List<FieldBuilder> _builders;

  const FieldBuilderRegistry(this._builders);

  FieldBuilder resolve(FieldType type) => _builders.firstWhere(
    (b) => b.supports(type),
    orElse: () => throw UnsupportedError('No FieldBuilder for $type'),
  );
}

/// Handles every text-like field type.
class TextFieldBuilder implements FieldBuilder {
  const TextFieldBuilder();

  @override
  bool supports(FieldType type) => switch (type) {
    FieldType.text ||
    FieldType.email ||
    FieldType.number ||
    FieldType.phone ||
    FieldType.password ||
    FieldType.multiline => true,
  };

  @override
  Widget build({
    required FieldConfig field,
    required String value,
    required String? error,
    required ValueChanged<String> onChanged,
    required TextInputAction inputAction,
  }) => _DynamicTextField(
    field: field,
    value: value,
    error: error,
    onChanged: onChanged,
    inputAction: inputAction,
  );
}

class _DynamicTextField extends StatefulWidget {
  final FieldConfig field;
  final String value;
  final String? error;
  final ValueChanged<String> onChanged;
  final TextInputAction inputAction;

  const _DynamicTextField({
    required this.field,
    required this.value,
    required this.error,
    required this.onChanged,
    required this.inputAction,
  });

  @override
  State<_DynamicTextField> createState() => _DynamicTextFieldState();
}

class _DynamicTextFieldState extends State<_DynamicTextField> {
  late bool _obscured = widget.field.type == FieldType.password;

  @override
  Widget build(BuildContext context) {
    final field = widget.field;
    final isPassword = field.type == FieldType.password;
    final isMultiline = field.type == FieldType.multiline;
    final icon = AppIcons.maybe(field.icon);

    return TextFormField(
      initialValue: widget.value,
      onChanged: widget.onChanged,
      obscureText: _obscured,
      keyboardType: _keyboardFor(field.type),
      textInputAction: isMultiline
          ? TextInputAction.newline
          : widget.inputAction,
      textCapitalization: field.type == FieldType.text
          ? TextCapitalization.sentences
          : TextCapitalization.none,
      inputFormatters: switch (field.type) {
        FieldType.number ||
        FieldType.phone => [FilteringTextInputFormatter.digitsOnly],
        _ => null,
      },
      minLines: isMultiline ? 3 : 1,
      maxLines: isMultiline ? field.maxLines.clamp(3, 10) : 1,
      maxLength: field.maxLength,
      decoration: InputDecoration(
        labelText: field.required ? '${field.label} *' : field.label,
        hintText: field.hint,
        errorText: widget.error,
        alignLabelWithHint: isMultiline,
        prefixIcon: icon == null ? null : Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                tooltip: _obscured ? 'Show' : 'Hide',
                icon: Icon(_obscured ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscured = !_obscured),
              )
            : null,
      ),
    );
  }

  TextInputType _keyboardFor(FieldType type) => switch (type) {
    FieldType.email => TextInputType.emailAddress,
    FieldType.number => TextInputType.number,
    FieldType.phone => TextInputType.phone,
    FieldType.multiline => TextInputType.multiline,
    FieldType.password => TextInputType.visiblePassword,
    FieldType.text => TextInputType.text,
  };
}
