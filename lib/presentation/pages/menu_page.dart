import 'package:flutter/material.dart';

import '../../domain/entities.dart';
import '../widgets/app_icons.dart';
import 'form_page.dart';

/// A list of menu items. Reused for the home screen and every sub-menu.
class MenuPage extends StatelessWidget {
  final String title;
  final List<MenuItem> items;
  final List<Widget>? actions;

  const MenuPage({
    super.key,
    required this.title,
    required this.items,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final item = items[i];
          return ListTile(
            leading: Icon(iconFor(item.icon)),
            title: Text(item.title),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(context, item),
          );
        },
      ),
    );
  }

  /// Sub-menus → another MenuPage; form → FormPage.
  void _open(BuildContext context, MenuItem item) {
    final form = item.form;
    final Widget page;
    if (item.subMenus.isNotEmpty) {
      page = MenuPage(title: item.title, items: item.subMenus);
    } else if (form != null) {
      page = FormPage(form: form);
    } else {
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}
