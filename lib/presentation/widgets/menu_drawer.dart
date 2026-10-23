import 'package:flutter/material.dart';

import '../../domain/entities.dart';
import 'app_icons.dart';

/// Side menu built from the config. Items with sub-menus expand in place;
/// tapping an item with a form calls [onSelect] and closes the drawer.
class MenuDrawer extends StatelessWidget {
  final Workspace workspace;
  final List<MenuItem> menus;
  final MenuItem? selected;
  final ValueChanged<MenuItem> onSelect;

  const MenuDrawer({
    super.key,
    required this.workspace,
    required this.menus,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Drawer(
      child: SafeArea(
        child: ListView(
          children: [
            ListTile(
              leading: Icon(iconFor(workspace.icon)),
              title: Text(workspace.title, style: theme.textTheme.titleLarge),
            ),
            const Divider(),
            for (final item in menus) _tile(context, item, 0),
          ],
        ),
      ),
    );
  }

  Widget _tile(BuildContext context, MenuItem item, int depth) {
    final indent = EdgeInsets.only(left: 16.0 + depth * 16, right: 16);
    if (item.subMenus.isNotEmpty) {
      return ExpansionTile(
        tilePadding: indent,
        leading: Icon(iconFor(item.icon)),
        title: Text(item.title),
        initiallyExpanded: _contains(item, selected),
        children: [
          for (final child in item.subMenus) _tile(context, child, depth + 1),
        ],
      );
    }
    return ListTile(
      contentPadding: indent,
      leading: Icon(iconFor(item.icon)),
      title: Text(item.title),
      selected: item.id == selected?.id,
      onTap: () {
        Navigator.of(context).pop();
        onSelect(item);
      },
    );
  }

  /// Keeps the branch holding the current selection open.
  bool _contains(MenuItem item, MenuItem? target) =>
      target != null &&
      item.subMenus.any((c) => c.id == target.id || _contains(c, target));
}
