import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/status_view.dart';
import '../bloc/menu_bloc.dart';
import '../widgets/workspace_switcher.dart';
import 'menu_page.dart';

/// Root page. Expects a [MenuBloc] above it (provided in `App`).
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) => AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: switch (state) {
          MenuLoading() => const Scaffold(
            key: ValueKey('loading'),
            body: Center(child: CircularProgressIndicator()),
          ),
          MenuError(:final message) => Scaffold(
            key: const ValueKey('error'),
            body: StatusView(
              icon: Icons.cloud_off,
              title: 'Couldn\'t load menu',
              message: message,
              actionLabel: 'Retry',
              onAction: () => context.read<MenuBloc>().add(const MenuStarted()),
            ),
          ),
          MenuLoaded(:final workspaces, :final workspace, :final config) =>
            MenuPage(
              key: ValueKey(workspace.id),
              title: config.appTitle,
              items: config.menus,
              layout: config.layout,
              header: WorkspaceBanner(workspace: workspace),
              actions: [
                if (workspaces.length > 1)
                  WorkspaceSwitcherButton(
                    workspaces: workspaces,
                    current: workspace,
                  ),
              ],
            ),
        },
      ),
    );
  }
}
