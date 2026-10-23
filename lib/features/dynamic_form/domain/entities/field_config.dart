import 'package:equatable/equatable.dart';

enum FieldType { text, email, number, phone, password, multiline }

class FieldConfig extends Equatable {
  final String key;
  final FieldType type;
  final String label;
  final String? hint;
  final String? icon;
  final String? initialValue;
  final bool required;
  final int? minLength;
  final int? maxLength;
  final int maxLines;
  final String? pattern;
  final String? patternMessage;

  const FieldConfig({
    required this.key,
    required this.type,
    required this.label,
    this.hint,
    this.icon,
    this.initialValue,
    this.required = false,
    this.minLength,
    this.maxLength,
    this.maxLines = 1,
    this.pattern,
    this.patternMessage,
  });

  @override
  List<Object?> get props => [
    key,
    type,
    label,
    hint,
    icon,
    initialValue,
    required,
    minLength,
    maxLength,
    maxLines,
    pattern,
    patternMessage,
  ];
}
