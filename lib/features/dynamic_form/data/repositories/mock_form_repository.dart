import 'package:flutter/foundation.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/result/result.dart';
import '../../domain/entities/api_config.dart';
import '../../domain/entities/submit_response.dart';
import '../../domain/repositories/form_repository.dart';

/// Simulates the backend described by each button's [ApiConfig]: waits
/// [ApiConfig.mockDelay], then succeeds or fails per [ApiConfig.mockFail].
/// Replace with an HTTP implementation and register it in DI.
class MockFormRepository implements FormRepository {
  final DateTime Function() _clock;

  MockFormRepository({DateTime Function()? clock})
    : _clock = clock ?? DateTime.now;

  @override
  Future<Result<SubmitResponse>> submit({
    required String formId,
    required Map<String, String> values,
    ApiConfig? api,
  }) async {
    if (api == null) {
      return const Ok(SubmitResponse(message: 'Submitted successfully'));
    }

    // Log keys only — values may contain passwords.
    debugPrint(
      '[mock] ${api.method.name.toUpperCase()} ${api.endpoint} '
      'fields=${values.keys.toList()}',
    );
    await Future<void>.delayed(api.mockDelay);

    if (api.mockFail) {
      return Err(SubmissionFailure(api.errorMessage ?? 'Request failed'));
    }
    final ref = _clock().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    return Ok(
      SubmitResponse(
        message: api.successMessage ?? 'Submitted successfully',
        reference: 'REF-$ref',
      ),
    );
  }
}
