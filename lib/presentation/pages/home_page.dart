import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities.dart';
import '../cubit/menu_cubit.dart';
import '../widgets/app_icons.dart';
import 'menu_page.dart';

/// Shows loading / error, or the top-level menu of the current workspace.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuCubit, MenuState>(
      builder: (context, state) => switch (state) {
        MenuLoading() => const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
        MenuError(:final message) => Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: () => context.read<MenuCubit>().load(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
        MenuLoaded(:final workspaces, :final current, :final config) =>
          MenuPage(
            title: config.appTitle,
            items: config.menus,
            actions: [
              IconButton(
                tooltip: 'Switch workspace',
                icon: const Icon(Icons.swap_horiz),
                onPressed: () => _pickWorkspace(context, workspaces, current),
              ),
            ],
          ),
      },
    );
  }

  Future<void> _pickWorkspace(
    BuildContext context,
    List<Workspace> workspaces,
    Workspace current,
  ) async {
    final cubit = context.read<MenuCubit>();
    final picked = await showModalBottomSheet<Workspace>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final w in workspaces)
              ListTile(
                leading: Icon(iconFor(w.icon)),
                title: Text(w.title),
                trailing: w == current ? const Icon(Icons.check) : null,
                onTap: () => Navigator.of(ctx).pop(w),
              ),
          ],
        ),
      ),
    );
    if (picked != null) cubit.selectWorkspace(picked);
  }
}
