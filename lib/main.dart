import 'package:flutter/material.dart';

import 'models/menu_models.dart';
import 'screens/menu_screen.dart';
import 'services/menu_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dynamic Form Builder',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const HomeLoader(),
    );
  }
}

/// Loads the JSON config, then shows the top-level menu.
class HomeLoader extends StatefulWidget {
  const HomeLoader({super.key});

  @override
  State<HomeLoader> createState() => _HomeLoaderState();
}

class _HomeLoaderState extends State<HomeLoader> {
  late final Future<AppConfig> _config = const MenuRepository().load();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<AppConfig>(
      future: _config,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Failed to load menu: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final config = snapshot.data!;
        return MenuScreen(title: config.appTitle, items: config.menus);
      },
    );
  }
}
