import 'package:flutter/material.dart';

import '../models/menu_models.dart';
import '../utils/icon_mapper.dart';
import 'form_screen.dart';

/// Renders a list of menu items. Reused recursively for every sub-menu level.
class MenuScreen extends StatelessWidget {
  final String title;
  final List<MenuItem> items;

  const MenuScreen({super.key, required this.title, required this.items});

  void _open(BuildContext context, MenuItem item) {
    final Widget page;
    if (item.hasSubMenus) {
      page = MenuScreen(title: item.title, items: item.subMenus);
    } else if (item.form != null) {
      page = FormScreen(form: item.form!);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No content configured for "${item.title}"')),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: ListView.separated(
        itemCount: items.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, i) {
          final item = items[i];
          return ListTile(
            leading: Icon(iconFor(item.icon)),
            title: Text(item.title),
            trailing: Icon(
              item.hasSubMenus
                  ? Icons.chevron_right
                  : Icons.description_outlined,
            ),
            onTap: () => _open(context, item),
          );
        },
      ),
    );
  }
}
