import 'package:flutter/material.dart';

import '../../domain/entities.dart';
import 'dynamic_field.dart';

/// Builds a form's fields and buttons from [FormConfig].
class FormView extends StatefulWidget {
  final FormConfig form;

  /// Called by a `cancel` button.
  final VoidCallback onCancel;

  const FormView({super.key, required this.form, required this.onCancel});

  @override
  State<FormView> createState() => _FormViewState();
}

class _FormViewState extends State<FormView> {
  final _formKey = GlobalKey<FormState>();
  late final _controllers = {
    for (final f in widget.form.fields) f.key: TextEditingController(),
  };

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onPressed(ButtonAction action) {
    switch (action) {
      case ButtonAction.submit:
        if (!_formKey.currentState!.validate()) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${widget.form.title} submitted')),
        );
      case ButtonAction.reset:
        for (final c in _controllers.values) {
          c.clear();
        }
        _formKey.currentState!.reset();
      case ButtonAction.cancel:
        widget.onCancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final field in widget.form.fields) ...[
            DynamicField(field: field, controller: _controllers[field.key]!),
            const SizedBox(height: 16),
          ],
          Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            children: [
              for (final b in widget.form.buttons)
                b.action == ButtonAction.submit
                    ? FilledButton(
                        onPressed: () => _onPressed(b.action),
                        child: Text(b.label),
                      )
                    : OutlinedButton(
                        onPressed: () => _onPressed(b.action),
                        child: Text(b.label),
                      ),
            ],
          ),
        ],
      ),
    );
  }
}
