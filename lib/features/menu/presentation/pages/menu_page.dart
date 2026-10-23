import 'package:flutter/material.dart';

import '../../../../core/presentation/status_view.dart';
import '../../../dynamic_form/presentation/widgets/form_body.dart';
import '../../domain/entities/menu_item.dart';
import '../../domain/entities/menu_layout.dart';
import '../menu_navigator.dart';
import '../widgets/menu_layout_view.dart';
import '../widgets/menu_tiles.dart';

/// Shows a set of menu items in their configured [layout]. Used for the
/// home screen and every sub-menu level.
class MenuPage extends StatelessWidget {
  final String title;
  final List<MenuItem> items;
  final MenuLayout layout;
  final List<Widget>? actions;
  final Widget? header;

  const MenuPage({
    super.key,
    required this.title,
    required this.items,
    required this.layout,
    this.actions,
    this.header,
  });

  /// Page for the children of [item].
  factory MenuPage.of(MenuItem item) =>
      MenuPage(title: item.title, items: item.subMenus, layout: item.layout);

  @override
  Widget build(BuildContext context) {
    if (layout == MenuLayout.tabs && items.isNotEmpty) {
      return _TabsScaffold(title: title, items: items, actions: actions);
    }
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: MenuLayoutView(
        items: items,
        layout: layout,
        header: header,
        onTap: (item) => MenuNavigator.open(context, item),
      ),
    );
  }
}

class _TabsScaffold extends StatelessWidget {
  final String title;
  final List<MenuItem> items;
  final List<Widget>? actions;

  const _TabsScaffold({required this.title, required this.items, this.actions});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: items.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
          actions: actions,
          bottom: TabBar(
            isScrollable: items.length > 3,
            tabAlignment: items.length > 3 ? TabAlignment.start : null,
            tabs: [
              for (final item in items)
                Tab(
                  icon: Icon(item.iconData),
                  text: item.title,
                  iconMargin: const EdgeInsets.only(bottom: 4),
                ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            for (final item in items) _KeepAlive(child: _TabContent(item)),
          ],
        ),
      ),
    );
  }
}

/// A tab shows its form inline, or its children in their own layout.
class _TabContent extends StatelessWidget {
  final MenuItem item;

  const _TabContent(this.item);

  @override
  Widget build(BuildContext context) {
    if (item.hasSubMenus) {
      return MenuLayoutView(
        items: item.subMenus,
        layout: item.layout,
        onTap: (child) => MenuNavigator.open(context, child),
      );
    }
    if (item.form case final form?) {
      return FormBody(
        form: form,
        onClose: () => Navigator.of(context).maybePop(),
      );
    }
    return const StatusView(
      icon: Icons.inbox_outlined,
      title: 'Nothing here yet',
    );
  }
}

/// Keeps a tab's state (e.g. typed form values) when switching tabs.
class _KeepAlive extends StatefulWidget {
  final Widget child;

  const _KeepAlive({required this.child});

  @override
  State<_KeepAlive> createState() => _KeepAliveState();
}

class _KeepAliveState extends State<_KeepAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}
