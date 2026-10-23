import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/app_icons.dart';
import '../../domain/entities/button_config.dart';
import '../bloc/dynamic_form_bloc.dart';

/// Bottom bar with the form's buttons. Maps each [ButtonAction] to a bloc
/// event; [onCancel] is supplied by the host (page or tab).
class FormActionBar extends StatelessWidget {
  final VoidCallback onCancel;

  const FormActionBar({super.key, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<DynamicFormBloc>();
    final buttons = bloc.form.buttons;
    if (buttons.isEmpty) return const SizedBox.shrink();
    final scheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surface,
        border: Border(top: BorderSide(color: scheme.outlineVariant)),
      ),
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(16, 12, 16, 12),
        child: BlocSelector<DynamicFormBloc, DynamicFormState, bool>(
          selector: (s) => s.isSubmitting,
          builder: (context, submitting) => Row(
            spacing: 12,
            children: [
              for (final b in buttons)
                _wrap(
                  b,
                  _ActionButton(
                    config: b,
                    loading: submitting && b.action == ButtonAction.submit,
                    onPressed: submitting ? null : () => _handle(bloc, b),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Text buttons keep their natural width; others share the remaining row.
  Widget _wrap(ButtonConfig b, Widget child) =>
      b.variant == ButtonVariant.text ? child : Expanded(child: child);

  void _handle(DynamicFormBloc bloc, ButtonConfig b) {
    FocusManager.instance.primaryFocus?.unfocus();
    switch (b.action) {
      case ButtonAction.submit:
        bloc.add(FormSubmitted(api: b.api));
      case ButtonAction.reset:
        bloc.add(const FormResetRequested());
      case ButtonAction.cancel:
        onCancel();
    }
  }
}

class _ActionButton extends StatelessWidget {
  final ButtonConfig config;
  final bool loading;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.config,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final label = Text(config.label, overflow: TextOverflow.ellipsis);
    final iconData = AppIcons.maybe(config.icon);
    final icon = loading
        ? const SizedBox.square(
            dimension: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : iconData == null
        ? null
        : Icon(iconData, size: 20);

    return switch (config.variant) {
      ButtonVariant.filled => FilledButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: label,
      ),
      ButtonVariant.tonal => FilledButton.tonalIcon(
        onPressed: onPressed,
        icon: icon,
        label: label,
      ),
      ButtonVariant.outlined => OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: label,
      ),
      ButtonVariant.text => TextButton.icon(
        onPressed: onPressed,
        icon: icon,
        label: label,
      ),
    };
  }
}
