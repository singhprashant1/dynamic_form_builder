import 'dart:convert';

import 'package:flutter/services.dart';

/// Reads a JSON asset and decodes it. Swap for an HTTP version later.
class JsonDataSource {
  final AssetBundle _bundle;

  const JsonDataSource(this._bundle);

  Future<Map<String, dynamic>> load(String path) async {
    final raw = await _bundle.loadString(path);
    return jsonDecode(raw) as Map<String, dynamic>;
  }
}
