part of 'dynamic_form_bloc.dart';

enum FormStatus { editing, submitting, success, failure }

final class DynamicFormState extends Equatable {
  final Map<String, String> values;
  final Map<String, String> errors;
  final FormStatus status;

  /// Once true, fields re-validate on every change.
  final bool submitAttempted;

  /// Bumped on reset so field widgets rebuild with initial values.
  final int version;

  /// API of the most recent submit; reused by [FormRetryRequested].
  final ApiConfig? lastApi;

  final SubmitResponse? response;
  final String? failureMessage;

  const DynamicFormState({
    required this.values,
    this.errors = const {},
    this.status = FormStatus.editing,
    this.submitAttempted = false,
    this.version = 0,
    this.lastApi,
    this.response,
    this.failureMessage,
  });

  bool get isSubmitting => status == FormStatus.submitting;

  /// [response] and [failureMessage] are cleared unless passed, so they
  /// only live for the state that reports them.
  DynamicFormState copyWith({
    Map<String, String>? values,
    Map<String, String>? errors,
    FormStatus? status,
    bool? submitAttempted,
    ApiConfig? Function()? lastApi,
    SubmitResponse? response,
    String? failureMessage,
  }) => DynamicFormState(
    values: values ?? this.values,
    errors: errors ?? this.errors,
    status: status ?? this.status,
    submitAttempted: submitAttempted ?? this.submitAttempted,
    version: version,
    lastApi: lastApi != null ? lastApi() : this.lastApi,
    response: response,
    failureMessage: failureMessage,
  );

  @override
  List<Object?> get props => [
    values,
    errors,
    status,
    submitAttempted,
    version,
    lastApi,
    response,
    failureMessage,
  ];
}
