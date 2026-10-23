import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/menu_models.dart';

/// Builds text fields and buttons from a [FormConfig].
class DynamicForm extends StatefulWidget {
  final FormConfig config;
  final ValueChanged<Map<String, String>> onSubmit;
  final VoidCallback? onCancel;

  const DynamicForm({
    super.key,
    required this.config,
    required this.onSubmit,
    this.onCancel,
  });

  @override
  State<DynamicForm> createState() => _DynamicFormState();
}

class _DynamicFormState extends State<DynamicForm> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers = {
    for (final f in widget.config.fields)
      f.key: TextEditingController(text: f.initialValue),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _handle(ButtonAction action) {
    switch (action) {
      case ButtonAction.submit:
        if (_formKey.currentState!.validate()) {
          widget.onSubmit({
            for (final e in _controllers.entries) e.key: e.value.text.trim(),
          });
        }
      case ButtonAction.reset:
        for (final f in widget.config.fields) {
          _controllers[f.key]!.text = f.initialValue ?? '';
        }
        _formKey.currentState!.reset();
      case ButtonAction.cancel:
        widget.onCancel?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final field in widget.config.fields) ...[
            _buildField(field),
            const SizedBox(height: 16),
          ],
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            runSpacing: 8,
            children: [for (final b in widget.config.buttons) _buildButton(b)],
          ),
        ],
      ),
    );
  }

  Widget _buildField(FieldConfig f) {
    return TextFormField(
      controller: _controllers[f.key],
      decoration: InputDecoration(
        labelText: f.required ? '${f.label} *' : f.label,
        hintText: f.hint,
        border: const OutlineInputBorder(),
      ),
      obscureText: f.type == FieldType.password,
      keyboardType: _keyboardFor(f.type),
      inputFormatters: f.type == FieldType.number
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      maxLines: f.type == FieldType.multiline ? f.maxLines.clamp(2, 10) : 1,
      maxLength: f.maxLength,
      validator: (v) => _validate(f, v ?? ''),
    );
  }

  TextInputType _keyboardFor(FieldType type) => switch (type) {
    FieldType.email => TextInputType.emailAddress,
    FieldType.number => TextInputType.number,
    FieldType.phone => TextInputType.phone,
    FieldType.multiline => TextInputType.multiline,
    _ => TextInputType.text,
  };

  String? _validate(FieldConfig f, String raw) {
    final value = raw.trim();
    if (value.isEmpty) {
      return f.required ? '${f.label} is required' : null;
    }
    if (f.minLength != null && value.length < f.minLength!) {
      return 'Minimum ${f.minLength} characters';
    }
    if (f.type == FieldType.email &&
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value)) {
      return 'Enter a valid email';
    }
    if (f.pattern != null && !RegExp(f.pattern!).hasMatch(value)) {
      return f.patternMessage ?? 'Invalid ${f.label}';
    }
    return null;
  }

  Widget _buildButton(ButtonConfig b) {
    void onPressed() => _handle(b.action);
    final child = Text(b.label);
    return switch (b.style) {
      ButtonStyleType.elevated => ElevatedButton(
        onPressed: onPressed,
        child: child,
      ),
      ButtonStyleType.outlined => OutlinedButton(
        onPressed: onPressed,
        child: child,
      ),
      ButtonStyleType.text => TextButton(onPressed: onPressed, child: child),
    };
  }
}
