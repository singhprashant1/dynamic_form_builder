import 'package:dynamic_form_builder/features/dynamic_form/domain/entities/field_config.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/entities/form_config.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/usecases/validate_form.dart';
import 'package:dynamic_form_builder/features/dynamic_form/domain/validators/field_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const validate = ValidateForm([
    RequiredValidator(),
    MinLengthValidator(),
    MaxLengthValidator(),
    EmailValidator(),
    PatternValidator(),
  ]);

  const form = FormConfig(
    id: 'f',
    title: 'F',
    fields: [
      FieldConfig(
        key: 'name',
        type: FieldType.text,
        label: 'Name',
        required: true,
        minLength: 3,
      ),
      FieldConfig(key: 'email', type: FieldType.email, label: 'Email'),
      FieldConfig(
        key: 'phone',
        type: FieldType.phone,
        label: 'Phone',
        pattern: r'^[0-9]{10}$',
        patternMessage: 'Bad phone',
      ),
    ],
  );

  test('valid input yields no errors', () {
    expect(
      validate(form, {
        'name': 'Prashant',
        'email': 'a@b.co',
        'phone': '9876543210',
      }),
      isEmpty,
    );
  });

  test('optional empty fields are skipped', () {
    expect(validate(form, {'name': 'Bob'}), isEmpty);
  });

  test('reports the first failing rule per field', () {
    expect(validate(form, {'name': '', 'email': 'nope', 'phone': '12'}), {
      'name': 'Name is required',
      'email': 'Enter a valid email',
      'phone': 'Bad phone',
    });
    expect(validate(form, {'name': 'ab'}), {'name': 'Minimum 3 characters'});
  });

  test('whitespace-only counts as empty', () {
    expect(validate(form, {'name': '   '}), {'name': 'Name is required'});
  });
}
