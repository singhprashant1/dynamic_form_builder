import 'package:equatable/equatable.dart';

/// Domain-level error. Presentation only ever sees these, never exceptions.
sealed class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

/// Config could not be read (missing asset, network error, etc.).
class LoadFailure extends Failure {
  const LoadFailure(super.message);
}

/// Config was read but is malformed.
class ParseFailure extends Failure {
  const ParseFailure(super.message);
}

/// Form submission was rejected.
class SubmissionFailure extends Failure {
  const SubmissionFailure(super.message);
}
