import 'package:flutter/material.dart';

import '../../../../core/presentation/status_view.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/menu_layout.dart';
import 'menu_tiles.dart';

/// Renders [items] in the given scrollable [layout] (grid, list, expandable).
/// Tabs need an app bar, so pages handle [MenuLayout.tabs] themselves; if it
/// reaches here (e.g. nested inside a tab) it falls back to a list.
class MenuLayoutView extends StatelessWidget {
  final List<MenuItem> items;
  final MenuLayout layout;
  final ValueChanged<MenuItem> onTap;

  /// Optional widget shown above the items (e.g. workspace banner).
  final Widget? header;

  const MenuLayoutView({
    super.key,
    required this.items,
    required this.layout,
    required this.onTap,
    this.header,
  });

  static const _padding = EdgeInsets.fromLTRB(16, 8, 16, 24);

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const StatusView(
        icon: Icons.inbox_outlined,
        title: 'Nothing here yet',
        message: 'This menu has no items configured.',
      );
    }

    return CustomScrollView(
      slivers: [
        if (header case final header?)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(child: header),
          ),
        SliverPadding(padding: _padding, sliver: _buildItems()),
      ],
    );
  }

  Widget _buildItems() => switch (layout) {
    MenuLayout.grid => SliverGrid.builder(
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 240,
        mainAxisExtent: 176,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) =>
          MenuGridCard(item: items[i], onTap: () => onTap(items[i])),
    ),
    MenuLayout.expandable => _separatedList(
      (item) => MenuExpandableTile(item: item, onTap: onTap),
    ),
    MenuLayout.list || MenuLayout.tabs => _separatedList(
      (item) => MenuListTile(item: item, onTap: () => onTap(item)),
    ),
  };

  Widget _separatedList(Widget Function(MenuItem) build) =>
      SliverList.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => build(items[i]),
      );
}
