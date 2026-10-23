import '../../../../core/result/result.dart';
import '../entities/api_config.dart';
import '../entities/submit_response.dart';

/// Where submitted form data goes. Implemented in the data layer (DIP).
abstract interface class FormRepository {
  Future<Result<SubmitResponse>> submit({
    required String formId,
    required Map<String, String> values,
    ApiConfig? api,
  });
}
