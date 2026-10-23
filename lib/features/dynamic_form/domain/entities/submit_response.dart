import 'package:equatable/equatable.dart';

class SubmitResponse extends Equatable {
  final String message;

  /// Server-issued reference (ticket no., order id…), if any.
  final String? reference;

  const SubmitResponse({required this.message, this.reference});

  @override
  List<Object?> get props => [message, reference];
}
