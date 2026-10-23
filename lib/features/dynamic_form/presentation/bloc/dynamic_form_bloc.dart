import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/result/result.dart';
import '../../domain/entities/api_config.dart';
import '../../domain/entities/form_config.dart';
import '../../domain/entities/submit_response.dart';
import '../../domain/usecases/submit_form.dart';
import '../../domain/usecases/validate_form.dart';

part 'dynamic_form_event.dart';
part 'dynamic_form_state.dart';

class DynamicFormBloc extends Bloc<DynamicFormEvent, DynamicFormState> {
  final FormConfig form;
  final ValidateForm _validateForm;
  final SubmitForm _submitForm;

  DynamicFormBloc({
    required this.form,
    required this._validateForm,
    required this._submitForm,
  }) : super(DynamicFormState(values: form.initialValues)) {
    on<FormFieldChanged>(_onFieldChanged);
    on<FormSubmitted>((e, emit) => _submit(e.api, emit));
    on<FormRetryRequested>((_, emit) => _submit(state.lastApi, emit));
    on<FormResetRequested>(_onReset);
  }

  void _onFieldChanged(FormFieldChanged event, Emitter<DynamicFormState> emit) {
    final values = {...state.values, event.key: event.value};
    emit(
      state.copyWith(
        values: values,
        errors: state.submitAttempted ? _validateForm(form, values) : null,
        status: FormStatus.editing,
      ),
    );
  }

  Future<void> _submit(ApiConfig? api, Emitter<DynamicFormState> emit) async {
    if (state.isSubmitting) return;

    final errors = _validateForm(form, state.values);
    if (errors.isNotEmpty) {
      emit(
        state.copyWith(
          errors: errors,
          submitAttempted: true,
          status: FormStatus.editing,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        errors: const {},
        submitAttempted: true,
        status: FormStatus.submitting,
        lastApi: () => api,
      ),
    );

    final trimmed = state.values.map((k, v) => MapEntry(k, v.trim()));
    final result = await _submitForm(
      SubmitFormParams(formId: form.id, values: trimmed, api: api),
    );

    switch (result) {
      case Ok(:final value):
        emit(state.copyWith(status: FormStatus.success, response: value));
      case Err(:final failure):
        emit(
          state.copyWith(
            status: FormStatus.failure,
            failureMessage: failure.message,
          ),
        );
    }
  }

  void _onReset(FormResetRequested event, Emitter<DynamicFormState> emit) {
    emit(
      DynamicFormState(values: form.initialValues, version: state.version + 1),
    );
  }
}
