import 'package:flutter/material.dart';

import '../../domain/entities/form_config.dart';
import '../widgets/form_body.dart';

class FormPage extends StatelessWidget {
  final FormConfig form;

  const FormPage({super.key, required this.form});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(form.title)),
      body: FormBody(
        form: form,
        onClose: () => Navigator.of(context).maybePop(),
      ),
    );
  }
}
