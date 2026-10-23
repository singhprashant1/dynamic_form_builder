import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/dynamic_form_bloc.dart';
import 'field_builders.dart';

/// Scrollable list of the form's fields, driven by [DynamicFormBloc].
class FormFields extends StatelessWidget {
  final FieldBuilderRegistry registry;

  const FormFields({super.key, required this.registry});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DynamicFormBloc>();
    final form = bloc.form;
    final theme = Theme.of(context);

    return BlocBuilder<DynamicFormBloc, DynamicFormState>(
      buildWhen: (p, c) =>
          p.errors != c.errors ||
          p.version != c.version ||
          p.isSubmitting != c.isSubmitting,
      builder: (context, state) => AbsorbPointer(
        absorbing: state.isSubmitting,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          children: [
            if (form.description case final description?) ...[
              Text(
                description,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
            ],
            for (final (i, field) in form.fields.indexed) ...[
              KeyedSubtree(
                // New key on reset → field re-reads its initial value.
                key: ValueKey('${field.key}_${state.version}'),
                child: registry
                    .resolve(field.type)
                    .build(
                      field: field,
                      value: state.values[field.key] ?? '',
                      error: state.errors[field.key],
                      onChanged: (v) =>
                          bloc.add(FormFieldChanged(field.key, v)),
                      inputAction: i == form.fields.length - 1
                          ? TextInputAction.done
                          : TextInputAction.next,
                    ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }
}
