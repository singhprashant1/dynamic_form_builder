import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../../../core/error/exceptions.dart';

/// Returns raw JSON. Add a remote implementation (HTTP) later and swap it in
/// DI; nothing above the data layer changes.
abstract interface class MenuDataSource {
  /// The workspace index: `{"workspaces": [...]}`.
  Future<Map<String, dynamic>> fetchWorkspaces();

  /// One workspace config, located by the index entry's `source`.
  Future<Map<String, dynamic>> fetchConfig(String source);
}

class AssetMenuDataSource implements MenuDataSource {
  final AssetBundle _bundle;
  final String _indexPath;

  const AssetMenuDataSource(
    this._bundle, {
    this._indexPath = 'assets/data/workspaces.json',
  });

  @override
  Future<Map<String, dynamic>> fetchWorkspaces() => _load(_indexPath);

  @override
  Future<Map<String, dynamic>> fetchConfig(String source) => _load(source);

  Future<Map<String, dynamic>> _load(String path) async {
    try {
      final raw = await _bundle.loadString(path);
      return jsonDecode(raw) as Map<String, dynamic>;
    } on FormatException catch (e) {
      throw DataSourceException('Invalid JSON in $path: ${e.message}');
    } on FlutterError catch (e) {
      throw DataSourceException('Cannot read $path: ${e.message}');
    }
  }
}
