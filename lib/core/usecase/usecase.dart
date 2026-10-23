import '../result/result.dart';

/// A single application action. One class per use case (SRP).
abstract interface class UseCase<T, Params> {
  Future<Result<T>> call(Params params);
}

/// Params placeholder for use cases that take no input.
class NoParams {
  const NoParams();
}
