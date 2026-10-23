import 'package:flutter/material.dart';

import '../../domain/entities/field_config.dart';
import '../../domain/entities/form_config.dart';
import '../../domain/entities/submit_response.dart';

enum SuccessChoice { newEntry, done }

/// Bottom sheet confirming a successful submit, with a summary of values.
class SubmitSuccessSheet extends StatelessWidget {
  final FormConfig form;
  final SubmitResponse response;
  final Map<String, String> values;

  const SubmitSuccessSheet({
    super.key,
    required this.form,
    required this.response,
    required this.values,
  });

  static Future<SuccessChoice?> show(
    BuildContext context, {
    required FormConfig form,
    required SubmitResponse response,
    required Map<String, String> values,
  }) => showModalBottomSheet<SuccessChoice>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) =>
        SubmitSuccessSheet(form: form, response: response, values: values),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final filled = form.fields.where(
      (f) => (values[f.key] ?? '').trim().isNotEmpty,
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: scheme.primaryContainer,
            child: Icon(
              Icons.check_rounded,
              size: 40,
              color: scheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            response.message,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleLarge,
          ),
          if (response.reference case final ref?) ...[
            const SizedBox(height: 8),
            Chip(
              avatar: const Icon(Icons.tag, size: 18),
              label: Text(ref),
              visualDensity: VisualDensity.compact,
            ),
          ],
          if (filled.isNotEmpty) ...[
            const SizedBox(height: 20),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    for (final f in filled)
                      ListTile(
                        dense: true,
                        title: Text(
                          f.label,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                        subtitle: Text(
                          f.type == FieldType.password
                              ? '••••••••'
                              : values[f.key]!.trim(),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          Row(
            spacing: 12,
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () =>
                      Navigator.of(context).pop(SuccessChoice.newEntry),
                  child: const Text('New entry'),
                ),
              ),
              Expanded(
                child: FilledButton(
                  onPressed: () =>
                      Navigator.of(context).pop(SuccessChoice.done),
                  child: const Text('Done'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
