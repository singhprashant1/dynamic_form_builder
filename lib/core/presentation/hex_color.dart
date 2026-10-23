import 'package:flutter/material.dart';

/// Parses `#RRGGBB` / `#AARRGGBB` from JSON. Returns `null` if invalid.
Color? hexColor(String? hex) {
  if (hex == null) return null;
  var digits = hex.replaceFirst('#', '');
  if (digits.length == 6) digits = 'FF$digits';
  if (digits.length != 8) return null;
  final value = int.tryParse(digits, radix: 16);
  return value == null ? null : Color(value);
}
