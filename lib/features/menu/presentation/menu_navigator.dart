import 'package:flutter/material.dart';

import '../../dynamic_form/presentation/pages/form_page.dart';
import '../domain/entities/menu_item.dart';
import 'pages/menu_page.dart';

/// Decides where a tapped [MenuItem] leads. Kept out of the widgets so list
/// UI and navigation rules change independently (SRP).
abstract final class MenuNavigator {
  static void open(BuildContext context, MenuItem item) {
    final Widget page;
    if (item.hasSubMenus) {
      page = MenuPage.of(item);
    } else if (item.form case final form?) {
      page = FormPage(form: form);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No content configured for "${item.title}"')),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}
