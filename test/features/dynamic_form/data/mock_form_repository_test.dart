import 'package:dynamic_form_builder/core/error/failures.dart';
import 'package:dynamic_form_builder/core/result/result.dart';
import 'package:dynamic_form_builder/features/dynamic_form/data/repositories/mock_form_repository.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/entities/api_config.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/entities/submit_response.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final repo = MockFormRepository(
    clock: () => DateTime.fromMillisecondsSinceEpoch(36 * 36),
  );

  test('no API → immediate local success', () async {
    final result = await repo.submit(formId: 'f', values: const {});
    expect(
      (result as Ok<SubmitResponse>).value.message,
      'Submitted successfully',
    );
  });

  test('API success returns configured message and a reference', () async {
    final result = await repo.submit(
      formId: 'f',
      values: const {'a': '1'},
      api: const ApiConfig(
        endpoint: '/x',
        successMessage: 'Saved!',
        mockDelay: Duration.zero,
      ),
    );
    expect(
      (result as Ok<SubmitResponse>).value,
      const SubmitResponse(message: 'Saved!', reference: 'REF-100'),
    );
  });

  test('mock.fail returns configured error message', () async {
    final result = await repo.submit(
      formId: 'f',
      values: const {},
      api: const ApiConfig(
        endpoint: '/x',
        errorMessage: 'Down',
        mockDelay: Duration.zero,
        mockFail: true,
      ),
    );
    expect(
      (result as Err<SubmitResponse>).failure,
      const SubmissionFailure('Down'),
    );
  });
}
