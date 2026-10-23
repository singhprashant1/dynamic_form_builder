part of 'dynamic_form_bloc.dart';

sealed class DynamicFormEvent extends Equatable {
  const DynamicFormEvent();

  @override
  List<Object?> get props => [];
}

final class FormFieldChanged extends DynamicFormEvent {
  final String key;
  final String value;

  const FormFieldChanged(this.key, this.value);

  @override
  List<Object?> get props => [key, value];
}

/// Validate, then send to [api] (from the pressed button's config).
final class FormSubmitted extends DynamicFormEvent {
  final ApiConfig? api;

  const FormSubmitted({this.api});

  @override
  List<Object?> get props => [api];
}

/// Re-send the last submission (e.g. from a "Retry" snackbar).
final class FormRetryRequested extends DynamicFormEvent {
  const FormRetryRequested();
}

final class FormResetRequested extends DynamicFormEvent {
  const FormResetRequested();
}
