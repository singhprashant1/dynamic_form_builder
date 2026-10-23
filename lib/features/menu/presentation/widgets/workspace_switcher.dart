import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/presentation/app_icons.dart';
import '../../../../core/presentation/hex_color.dart';
import '../../domain/entities/workspace.dart';
import '../bloc/menu_bloc.dart';

/// App bar button that opens a sheet to switch workspace.
class WorkspaceSwitcherButton extends StatelessWidget {
  final List<Workspace> workspaces;
  final Workspace current;

  const WorkspaceSwitcherButton({
    super.key,
    required this.workspaces,
    required this.current,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: IconButton.filledTonal(
        tooltip: 'Switch workspace',
        icon: const Icon(Icons.swap_horiz),
        onPressed: () => _open(context),
      ),
    );
  }

  Future<void> _open(BuildContext context) async {
    final bloc = context.read<MenuBloc>();
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (ctx) =>
          _WorkspaceSheet(workspaces: workspaces, current: current),
    );
    if (selected != null) bloc.add(WorkspaceSelected(selected));
  }
}

class _WorkspaceSheet extends StatelessWidget {
  final List<Workspace> workspaces;
  final Workspace current;

  const _WorkspaceSheet({required this.workspaces, required this.current});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
            child: Text('Switch workspace', style: theme.textTheme.titleLarge),
          ),
          for (final w in workspaces) ...[
            _WorkspaceTile(
              workspace: w,
              selected: w.id == current.id,
              onTap: () => Navigator.of(context).pop(w.id),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _WorkspaceTile extends StatelessWidget {
  final Workspace workspace;
  final bool selected;
  final VoidCallback onTap;

  const _WorkspaceTile({
    required this.workspace,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = hexColor(workspace.color) ?? scheme.primary;
    return Card(
      color: selected ? accent.withValues(alpha: 0.10) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: selected ? accent : scheme.outlineVariant,
          width: selected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: accent,
          foregroundColor: Colors.white,
          child: Icon(AppIcons.of(workspace.icon)),
        ),
        title: Text(
          workspace.title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: workspace.description == null
            ? null
            : Text(workspace.description!),
        trailing: selected ? Icon(Icons.check_circle, color: accent) : null,
      ),
    );
  }
}

/// Banner at the top of the home screen describing the current workspace.
class WorkspaceBanner extends StatelessWidget {
  final Workspace workspace;

  const WorkspaceBanner({super.key, required this.workspace});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome back',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: scheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  workspace.title,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: scheme.onPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (workspace.description case final d?) ...[
                  const SizedBox(height: 4),
                  Text(
                    d,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            AppIcons.of(workspace.icon),
            size: 56,
            color: scheme.onPrimary.withValues(alpha: 0.9),
          ),
        ],
      ),
    );
  }
}
