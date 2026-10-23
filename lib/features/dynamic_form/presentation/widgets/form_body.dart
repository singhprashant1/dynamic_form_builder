import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../domain/entities/form_config.dart';
import '../bloc/dynamic_form_bloc.dart';
import 'field_builders.dart';
import 'form_action_bar.dart';
import 'form_fields.dart';
import 'submit_success_sheet.dart';

/// A complete form (fields + action bar + submit feedback) without a
/// Scaffold, so it can live in a page or inside a tab.
class FormBody extends StatelessWidget {
  final FormConfig form;

  /// Called for the cancel button and "Done" after a successful submit.
  final VoidCallback onClose;

  const FormBody({super.key, required this.form, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<DynamicFormBloc>(param1: form),
      child: BlocListener<DynamicFormBloc, DynamicFormState>(
        listenWhen: (p, c) => p.status != c.status,
        listener: _onStatusChanged,
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: Column(
            children: [
              Expanded(child: FormFields(registry: sl<FieldBuilderRegistry>())),
              FormActionBar(onCancel: onClose),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onStatusChanged(
    BuildContext context,
    DynamicFormState state,
  ) async {
    final bloc = context.read<DynamicFormBloc>();
    final messenger = ScaffoldMessenger.of(context);
    switch (state.status) {
      case FormStatus.success:
        final choice = await SubmitSuccessSheet.show(
          context,
          form: form,
          response: state.response!,
          values: state.values,
        );
        if (choice == SuccessChoice.done) {
          onClose();
        } else {
          bloc.add(const FormResetRequested());
        }
      case FormStatus.failure:
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Row(
                spacing: 12,
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  Expanded(
                    child: Text(state.failureMessage ?? 'Submission failed'),
                  ),
                ],
              ),
              backgroundColor: Theme.of(context).colorScheme.error,
              action: SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: () => bloc.add(const FormRetryRequested()),
              ),
            ),
          );
      case FormStatus.editing || FormStatus.submitting:
        break;
    }
  }
}
