import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities.dart';
import '../cubit/menu_cubit.dart';
import '../widgets/app_icons.dart';
import '../widgets/form_view.dart';
import '../widgets/menu_drawer.dart';

/// Single screen: menu in the drawer, selected form in the body.
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
        MenuLoaded() => _loaded(context, state),
      },
    );
  }

  Widget _loaded(BuildContext context, MenuLoaded state) {
    final cubit = context.read<MenuCubit>();
    final form = state.selected?.form;
    return Scaffold(
      appBar: AppBar(
        title: Text(form?.title ?? state.config.appTitle),
        actions: [
          IconButton(
            tooltip: 'Switch workspace',
            icon: const Icon(Icons.swap_horiz),
            onPressed: () =>
                _pickWorkspace(context, state.workspaces, state.current),
          ),
        ],
      ),
      drawer: MenuDrawer(
        workspace: state.current,
        menus: state.config.menus,
        selected: state.selected,
        onSelect: cubit.select,
      ),
      body: form == null
          ? const _PickFromMenuHint()
          : FormView(
              // New key per item so switching forms starts with empty fields.
              key: ValueKey(state.selected!.id),
              form: form,
              onCancel: () => cubit.select(null),
            ),
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

/// Shown until the user picks something from the drawer.
class _PickFromMenuHint extends StatelessWidget {
  const _PickFromMenuHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.menu, size: 56, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Pick an option from the menu',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the menu icon at the top left to see all options.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Scaffold.of(context).openDrawer(),
              icon: const Icon(Icons.menu),
              label: const Text('Open menu'),
            ),
          ],
        ),
      ),
    );
  }
}
