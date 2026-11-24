import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../core/widgets/floating_nav_bar.dart';
import '../core/widgets/state_views.dart';
import '../features/events/presentation/controllers/active_event_controller.dart';
import 'routes.dart';

enum MainTab { events, scan, settings }

/// Вкладки сотрудника на входе.
class MainTabBar extends StatelessWidget {
  const MainTabBar({super.key, required this.current});

  final MainTab current;

  void _go(BuildContext context, MainTab tab) {
    switch (tab) {
      case MainTab.events:
        context.go(Routes.events);
      case MainTab.scan:
        if (context.read<ActiveEventController>().event == null) {
          showMessage(context, 'Choose an event to scan for first.');
          return;
        }
        context.push(Routes.scanner);
      case MainTab.settings:
        context.go(Routes.settings);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingNavBar(
      items: const [
        NavItem(icon: LucideIcons.calendar, label: 'Events'),
        NavItem(icon: LucideIcons.scanLine, label: 'Scan'),
        NavItem(icon: LucideIcons.settings, label: 'Settings'),
      ],
      current: current.index,
      onSelect: (i) => _go(context, MainTab.values[i]),
    );
  }
}
