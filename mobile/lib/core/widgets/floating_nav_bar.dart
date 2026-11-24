import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

class NavItem {
  const NavItem({required this.icon, required this.label, this.badge = false});

  final IconData icon;
  final String label;
  final bool badge;
}

/// Плавающая нижняя навигация-пилюля (BottomNav в TicketTon.pen):
/// 64 pt, скругление 32, активный пункт — тонированная капсула.
class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({super.key, required this.items, required this.current, required this.onSelect});

  final List<NavItem> items;
  final int current;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SafeArea(
      top: false,
      minimum: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: AppSizes.nav,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: c.navBackground,
            borderRadius: BorderRadius.circular(32),
            border: Border.all(color: c.border),
            boxShadow: [BoxShadow(color: c.shadow, blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: Row(
            children: [
              for (final (i, item) in items.indexed)
                Expanded(
                  child: Semantics(
                    selected: i == current,
                    button: true,
                    label: item.label,
                    child: Material(
                      color: i == current ? c.primaryTint : Colors.transparent,
                      borderRadius: BorderRadius.circular(26),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(26),
                        onTap: i == current ? null : () => onSelect(i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Icon(item.icon, size: 22, color: i == current ? c.primary : c.textMuted),
                                if (item.badge)
                                  Positioned(
                                    right: -2,
                                    top: -1,
                                    child: Container(
                                      width: 8,
                                      height: 8,
                                      decoration: BoxDecoration(color: c.danger, shape: BoxShape.circle),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            Text(
                              item.label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppText.tabItem.copyWith(
                                color: i == current ? c.primary : c.textMuted,
                                fontWeight: i == current ? FontWeight.w600 : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Шапка главного экрана роли (A3, M-B1): строка контекста, заголовок 28
/// и действие справа.
class LargeHeader extends StatelessWidget {
  const LargeHeader({super.key, required this.title, this.context_, this.action, this.onContextTap});

  final String title;

  /// Строка над заголовком (A3 «BiletFlow Demo Concert ⌄»).
  final String? context_;
  final VoidCallback? onContextTap;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (context_ != null)
                  InkWell(
                    onTap: onContextTap,
                    borderRadius: BorderRadius.circular(6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            context_!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.caption.copyWith(color: c.textMuted),
                          ),
                        ),
                        if (onContextTap != null) ...[
                          const SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: c.textMuted),
                        ],
                      ],
                    ),
                  ),
                Text(title, style: AppText.screenTitle.copyWith(color: c.text), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
          if (action != null) ...[const SizedBox(width: 12), action!],
        ],
      ),
    );
  }
}
