import '../entities/form_config.dart';
import '../validators/field_validator.dart';

/// Runs every [FieldValidator] against every field. First error per field wins.
/// Synchronous, so it doesn't implement the async [UseCase] interface.
class ValidateForm {
  final List<FieldValidator> _validators;

  const ValidateForm(this._validators);

  /// Returns field key → error message. Empty map means the form is valid.
  Map<String, String> call(FormConfig form, Map<String, String> values) {
    final errors = <String, String>{};
    for (final field in form.fields) {
      final value = (values[field.key] ?? '').trim();
      for (final validator in _validators) {
        final error = validator.validate(field, value);
        if (error != null) {
          errors[field.key] = error;
          break;
        }
      }
    }
    return errors;
  }
}
