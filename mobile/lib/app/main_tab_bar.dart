import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/presentation/l10n.dart';
import '../core/widgets/floating_nav_bar.dart';
import 'routes.dart';

/// Вкладки контролёра (A3, A7, A8): Сканер · Гости · Статистика.
enum ScannerTab { scanner, guests, stats }

class ScannerTabBar extends StatelessWidget {
  const ScannerTabBar({super.key, required this.current});

  final ScannerTab current;

  static String route(ScannerTab t) => switch (t) {
        ScannerTab.scanner => Routes.scanner,
        ScannerTab.guests => Routes.search,
        ScannerTab.stats => Routes.stats,
      };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return FloatingNavBar(
      items: [
        NavItem(icon: LucideIcons.scanLine, label: l.navScanner),
        NavItem(icon: LucideIcons.users, label: l.navGuests),
        NavItem(icon: LucideIcons.chartPie, label: l.navStats),
      ],
      current: current.index,
      onSelect: (i) => context.go(route(ScannerTab.values[i])),
    );
  }
}
