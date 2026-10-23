import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/menu_models.dart';

/// Loads the menu/form config. Swap the body of [load] for an HTTP call
/// later; the rest of the app only depends on [AppConfig].
class MenuRepository {
  final String assetPath;

  const MenuRepository({this.assetPath = 'assets/data/menu.json'});

  Future<AppConfig> load() async {
    final raw = await rootBundle.loadString(assetPath);
    return AppConfig.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }
}
