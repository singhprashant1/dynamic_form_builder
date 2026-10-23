import 'package:flutter/material.dart';

/// Maps icon names from JSON to Material icons. Add entries as needed.
const Map<String, IconData> _icons = {
  'person': Icons.person,
  'person_add': Icons.person_add,
  'search': Icons.search,
  'shopping_cart': Icons.shopping_cart,
  'add_shopping_cart': Icons.add_shopping_cart,
  'bar_chart': Icons.bar_chart,
  'today': Icons.today,
  'settings': Icons.settings,
  'home': Icons.home,
  'list': Icons.list,
  'edit': Icons.edit,
};

IconData iconFor(String? name) => _icons[name] ?? Icons.circle_outlined;
