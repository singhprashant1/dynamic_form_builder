import 'package:equatable/equatable.dart';

import 'api_config.dart';

enum ButtonAction { submit, reset, cancel }

enum ButtonVariant { filled, tonal, outlined, text }

class ButtonConfig extends Equatable {
  final String label;
  final ButtonAction action;
  final ButtonVariant variant;
  final String? icon;

  /// Where a [ButtonAction.submit] sends the form. `null` = local submit.
  final ApiConfig? api;

  const ButtonConfig({
    required this.label,
    required this.action,
    this.variant = ButtonVariant.filled,
    this.icon,
    this.api,
  });

  @override
  List<Object?> get props => [label, action, variant, icon, api];
}
