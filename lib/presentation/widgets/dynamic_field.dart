import 'package:flutter/material.dart';

import '../../domain/entities.dart';

/// One text field, configured by [FieldConfig.type].
class DynamicField extends StatelessWidget {
  final FieldConfig field;
  final TextEditingController controller;

  const DynamicField({
    super.key,
    required this.field,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final multiline = field.type == FieldType.multiline;
    return TextFormField(
      controller: controller,
      obscureText: field.type == FieldType.password,
      keyboardType: switch (field.type) {
        FieldType.email => TextInputType.emailAddress,
        FieldType.number => TextInputType.number,
        FieldType.phone => TextInputType.phone,
        FieldType.multiline => TextInputType.multiline,
        FieldType.text || FieldType.password => TextInputType.text,
      },
      maxLines: multiline ? 4 : 1,
      decoration: InputDecoration(
        labelText: field.required ? '${field.label} *' : field.label,
        hintText: field.hint,
        border: const OutlineInputBorder(),
      ),
      validator: (value) => field.required && (value ?? '').trim().isEmpty
          ? '${field.label} is required'
          : null,
    );
  }
}
