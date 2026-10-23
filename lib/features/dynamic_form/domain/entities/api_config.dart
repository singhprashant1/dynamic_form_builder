import 'package:equatable/equatable.dart';

enum HttpMethod { get, post, put, patch, delete }

/// Endpoint a submit button calls, plus the messages to show the user.
class ApiConfig extends Equatable {
  final String endpoint;
  final HttpMethod method;
  final String? successMessage;
  final String? errorMessage;

  /// Mock-only: simulated latency and forced failure. Ignored by a real
  /// HTTP repository.
  final Duration mockDelay;
  final bool mockFail;

  const ApiConfig({
    required this.endpoint,
    this.method = HttpMethod.post,
    this.successMessage,
    this.errorMessage,
    this.mockDelay = const Duration(milliseconds: 900),
    this.mockFail = false,
  });

  @override
  List<Object?> get props => [
    endpoint,
    method,
    successMessage,
    errorMessage,
    mockDelay,
    mockFail,
  ];
}
