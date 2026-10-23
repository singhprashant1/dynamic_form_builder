import 'package:flutter/material.dart';

import '../models/menu_models.dart';
import '../widgets/dynamic_form.dart';

class FormScreen extends StatelessWidget {
  final FormConfig form;

  const FormScreen({super.key, required this.form});

  void _onSubmit(BuildContext context, Map<String, String> values) {
    // TODO: replace with an API call once the backend is ready.
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Submitted'),
        content: Text(
          values.entries.map((e) => '${e.key}: ${e.value}').join('\n'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(form.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: DynamicForm(
          config: form,
          onSubmit: (values) => _onSubmit(context, values),
          onCancel: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}
