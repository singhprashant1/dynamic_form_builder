import 'package:bloc_test/bloc_test.dart';
import 'package:dynamic_form_builder/core/error/failures.dart';
import 'package:dynamic_form_builder/core/result/result.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/entities/api_config.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/entities/field_config.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/entities/form_config.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/entities/submit_response.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/repositories/form_repository.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/usecases/submit_form.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/usecases/validate_form.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/validators/field_validator.dart';
import 'package:dynamic_form_builder/features/dynamic_form/presentation/bloc/dynamic_form_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockFormRepository extends Mock implements FormRepository {}

void main() {
  const api = ApiConfig(endpoint: '/api/customers');
  const response = SubmitResponse(message: 'Saved', reference: 'REF-1');
  const form = FormConfig(
    id: 'customer',
    title: 'Customer',
    fields: [
      FieldConfig(
        key: 'name',
        type: FieldType.text,
        label: 'Name',
        required: true,
        initialValue: 'init',
      ),
    ],
  );

  late _MockFormRepository repository;

  setUpAll(() => registerFallbackValue(api));
  setUp(() => repository = _MockFormRepository());

  DynamicFormBloc build() => DynamicFormBloc(
    form: form,
    validateForm: const ValidateForm([RequiredValidator()]),
    submitForm: SubmitForm(repository),
  );

  void stubSubmit(Result<SubmitResponse> result) => when(
    () => repository.submit(
      formId: any(named: 'formId'),
      values: any(named: 'values'),
      api: any(named: 'api'),
    ),
  ).thenAnswer((_) async => result);

  test('starts with initial values', () {
    expect(build().state.values, {'name': 'init'});
  });

  blocTest<DynamicFormBloc, DynamicFormState>(
    'invalid submit shows errors and does not call repository',
    build: build,
    act: (bloc) => bloc
      ..add(const FormFieldChanged('name', ''))
      ..add(const FormSubmitted(api: api)),
    skip: 1,
    expect: () => [
      const DynamicFormState(
        values: {'name': ''},
        errors: {'name': 'Name is required'},
        submitAttempted: true,
      ),
    ],
    verify: (_) => verifyNever(
      () => repository.submit(
        formId: any(named: 'formId'),
        values: any(named: 'values'),
        api: any(named: 'api'),
      ),
    ),
  );

  blocTest<DynamicFormBloc, DynamicFormState>(
    'after a failed submit, editing re-validates live',
    build: build,
    seed: () => const DynamicFormState(
      values: {'name': ''},
      errors: {'name': 'Name is required'},
      submitAttempted: true,
    ),
    act: (bloc) => bloc.add(const FormFieldChanged('name', 'Bob')),
    expect: () => [
      const DynamicFormState(values: {'name': 'Bob'}, submitAttempted: true),
    ],
  );

  blocTest<DynamicFormBloc, DynamicFormState>(
    'valid submit sends trimmed values to the button API and emits success',
    setUp: () => stubSubmit(const Ok(response)),
    build: build,
    seed: () => const DynamicFormState(values: {'name': ' Bob '}),
    act: (bloc) => bloc.add(const FormSubmitted(api: api)),
    expect: () => [
      const DynamicFormState(
        values: {'name': ' Bob '},
        status: FormStatus.submitting,
        submitAttempted: true,
        lastApi: api,
      ),
      const DynamicFormState(
        values: {'name': ' Bob '},
        status: FormStatus.success,
        submitAttempted: true,
        lastApi: api,
        response: response,
      ),
    ],
    verify: (_) => verify(
      () => repository.submit(
        formId: 'customer',
        values: {'name': 'Bob'},
        api: api,
      ),
    ).called(1),
  );

  blocTest<DynamicFormBloc, DynamicFormState>(
    'API failure emits failure; retry re-sends with the same API',
    setUp: () => stubSubmit(const Err(SubmissionFailure('server down'))),
    build: build,
    act: (bloc) async {
      bloc.add(const FormSubmitted(api: api));
      await Future<void>.delayed(Duration.zero);
      bloc.add(const FormRetryRequested());
    },
    expect: () => [
      isA<DynamicFormState>().having(
        (s) => s.status,
        'status',
        FormStatus.submitting,
      ),
      const DynamicFormState(
        values: {'name': 'init'},
        status: FormStatus.failure,
        submitAttempted: true,
        lastApi: api,
        failureMessage: 'server down',
      ),
      isA<DynamicFormState>().having(
        (s) => s.status,
        'status',
        FormStatus.submitting,
      ),
      isA<DynamicFormState>().having(
        (s) => s.status,
        'status',
        FormStatus.failure,
      ),
    ],
    verify: (_) => verify(
      () => repository.submit(
        formId: 'customer',
        values: {'name': 'init'},
        api: api,
      ),
    ).called(2),
  );

  blocTest<DynamicFormBloc, DynamicFormState>(
    'reset restores initial values and bumps version',
    build: build,
    seed: () => const DynamicFormState(
      values: {'name': ''},
      errors: {'name': 'Name is required'},
      submitAttempted: true,
    ),
    act: (bloc) => bloc.add(const FormResetRequested()),
    expect: () => [
      const DynamicFormState(values: {'name': 'init'}, version: 1),
    ],
  );
}
