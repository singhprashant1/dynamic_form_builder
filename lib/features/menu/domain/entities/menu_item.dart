import 'package:equatable/equatable.dart';

import '../../../dynamic_form/domain/entities/form_config.dart';
import 'menu_layout.dart';

/// A menu entry. Has [subMenus] (rendered with [layout]) or a [form] (leaf).
class MenuItem extends Equatable {
  final String id;
  final String title;
  final String? description;
  final String? icon;

  /// Accent colour as `#RRGGBB`; falls back to the theme colour.
  final String? color;

  /// How [subMenus] are rendered.
  final MenuLayout layout;
  final List<MenuItem> subMenus;
  final FormConfig? form;

  const MenuItem({
    required this.id,
    required this.title,
    this.description,
    this.icon,
    this.color,
    this.layout = MenuLayout.list,
    this.subMenus = const [],
    this.form,
  });

  bool get hasSubMenus => subMenus.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    icon,
    color,
    layout,
    subMenus,
    form,
  ];
}
