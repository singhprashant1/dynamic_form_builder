import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/presentation/app_theme.dart';
import 'core/presentation/hex_color.dart';
import 'features/menu/presentation/bloc/menu_bloc.dart';
import 'features/menu/presentation/pages/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<MenuBloc>()..add(const MenuStarted()),
      // Theme follows the active workspace colour; keep the previous colour
      // while a new workspace is loading.
      child: BlocBuilder<MenuBloc, MenuState>(
        buildWhen: (_, curr) => curr is MenuLoaded,
        builder: (context, state) {
          final seed = switch (state) {
            MenuLoaded(:final workspace) => hexColor(workspace.color),
            _ => null,
          };
          return MaterialApp(
            title: 'Dynamic Form Builder',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light(seed ?? AppTheme.defaultSeed),
            darkTheme: AppTheme.dark(seed ?? AppTheme.defaultSeed),
            home: const HomePage(),
          );
        },
      ),
    );
  }
}
