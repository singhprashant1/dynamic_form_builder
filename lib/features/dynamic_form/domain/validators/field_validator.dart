import '../entities/field_config.dart';

/// One validation rule. Add a new rule by adding a class, not by editing
/// existing ones (OCP). Returns an error message, or `null` when valid or
/// when the rule doesn't apply to [field].
abstract interface class FieldValidator {
  String? validate(FieldConfig field, String value);
}

class RequiredValidator implements FieldValidator {
  const RequiredValidator();

  @override
  String? validate(FieldConfig field, String value) =>
      field.required && value.isEmpty ? '${field.label} is required' : null;
}

class MinLengthValidator implements FieldValidator {
  const MinLengthValidator();

  @override
  String? validate(FieldConfig field, String value) {
    final min = field.minLength;
    if (min == null || value.isEmpty || value.length >= min) return null;
    return 'Minimum $min characters';
  }
}

class MaxLengthValidator implements FieldValidator {
  const MaxLengthValidator();

  @override
  String? validate(FieldConfig field, String value) {
    final max = field.maxLength;
    if (max == null || value.length <= max) return null;
    return 'Maximum $max characters';
  }
}

class EmailValidator implements FieldValidator {
  static final _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  const EmailValidator();

  @override
  String? validate(FieldConfig field, String value) {
    if (field.type != FieldType.email || value.isEmpty) return null;
    return _email.hasMatch(value) ? null : 'Enter a valid email';
  }
}

class PatternValidator implements FieldValidator {
  const PatternValidator();

  @override
  String? validate(FieldConfig field, String value) {
    final pattern = field.pattern;
    if (pattern == null || value.isEmpty) return null;
    return RegExp(pattern).hasMatch(value)
        ? null
        : field.patternMessage ?? 'Invalid ${field.label}';
  }
}
