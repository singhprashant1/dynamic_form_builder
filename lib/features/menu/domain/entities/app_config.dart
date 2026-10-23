import 'package:equatable/equatable.dart';

import 'menu_item.dart';
import 'menu_layout.dart';

class AppConfig extends Equatable {
  final String appTitle;

  /// How the top-level [menus] are rendered.
  final MenuLayout layout;
  final List<MenuItem> menus;

  const AppConfig({
    required this.appTitle,
    required this.menus,
    this.layout = MenuLayout.grid,
  });

  @override
  List<Object?> get props => [appTitle, layout, menus];
}
