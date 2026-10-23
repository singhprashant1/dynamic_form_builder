import 'package:equatable/equatable.dart';

import '../../../../core/result/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/api_config.dart';
import '../entities/submit_response.dart';
import '../repositories/form_repository.dart';

class SubmitForm implements UseCase<SubmitResponse, SubmitFormParams> {
  final FormRepository _repository;

  const SubmitForm(this._repository);

  @override
  Future<Result<SubmitResponse>> call(SubmitFormParams params) => _repository
      .submit(formId: params.formId, values: params.values, api: params.api);
}

class SubmitFormParams extends Equatable {
  final String formId;
  final Map<String, String> values;
  final ApiConfig? api;

  const SubmitFormParams({
    required this.formId,
    required this.values,
    this.api,
  });

  @override
  List<Object?> get props => [formId, values, api];
}
