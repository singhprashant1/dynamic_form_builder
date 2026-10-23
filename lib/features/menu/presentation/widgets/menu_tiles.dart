import 'package:flutter/material.dart';

import '../../../../core/presentation/app_icons.dart';
import '../../../../core/presentation/hex_color.dart';
import '../../domain/entities/menu_item.dart';

extension MenuItemPresentation on MenuItem {
  Color accent(BuildContext context) =>
      hexColor(color) ?? Theme.of(context).colorScheme.primary;

  IconData get iconData => AppIcons.of(icon);

  /// "3 options", "Form", or `null`.
  String? get metaLabel => hasSubMenus
      ? '${subMenus.length} ${subMenus.length == 1 ? 'option' : 'options'}'
      : form != null
      ? 'Form'
      : null;
}

/// Rounded, tinted icon badge in the item's accent colour.
class MenuIconBadge extends StatelessWidget {
  final MenuItem item;
  final double size;

  const MenuIconBadge({super.key, required this.item, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final accent = item.accent(context);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(item.iconData, color: accent, size: size * 0.52),
    );
  }
}

/// Card for the grid layout.
class MenuGridCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const MenuGridCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MenuIconBadge(item: item),
              const Spacer(),
              Text(
                item.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (item.description case final d?)
                Text(
                  d,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(color: muted),
                ),
              if (item.metaLabel case final meta?) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      meta,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: item.accent(context),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.arrow_forward, size: 16, color: muted),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Card row for the list layout.
class MenuListTile extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onTap;

  const MenuListTile({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: MenuIconBadge(item: item, size: 44),
        title: Text(
          item.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: item.description == null ? null : Text(item.description!),
        trailing: Icon(
          item.hasSubMenus ? Icons.chevron_right : Icons.edit_note,
          color: theme.colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// Collapsible card for the expandable layout. Children open on tap.
class MenuExpandableTile extends StatelessWidget {
  final MenuItem item;
  final ValueChanged<MenuItem> onTap;

  const MenuExpandableTile({
    super.key,
    required this.item,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!item.hasSubMenus) {
      return MenuListTile(item: item, onTap: () => onTap(item));
    }
    final theme = Theme.of(context);
    final accent = item.accent(context);
    return Card(
      child: ExpansionTile(
        shape: const Border(),
        collapsedShape: const Border(),
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: MenuIconBadge(item: item, size: 44),
        title: Text(
          item.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(item.description ?? item.metaLabel ?? ''),
        childrenPadding: const EdgeInsets.only(bottom: 8),
        children: [
          for (final child in item.subMenus)
            ListTile(
              contentPadding: const EdgeInsets.only(left: 28, right: 16),
              leading: Icon(child.iconData, color: accent),
              title: Text(child.title),
              subtitle: child.description == null
                  ? null
                  : Text(child.description!),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => onTap(child),
            ),
        ],
      ),
    );
  }
}
