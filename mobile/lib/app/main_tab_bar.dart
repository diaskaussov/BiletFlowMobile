import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../core/widgets/state_views.dart';
import '../features/events/presentation/controllers/active_event_controller.dart';
import 'routes.dart';

enum MainTab { events, scan, settings }

/// Нижние вкладки A3/A6: три равных пункта, линия сверху, активный — accent.
class MainTabBar extends StatelessWidget {
  const MainTabBar({super.key, required this.current});

  final MainTab current;

  void _go(BuildContext context, MainTab tab) {
    if (tab == current) return;
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
    Widget item(MainTab tab, String label) {
      final active = tab == current;
      return Expanded(
        child: Semantics(
          selected: active,
          button: true,
          child: InkWell(
            onTap: () => _go(context, tab),
            child: SizedBox(
              height: AppSizes.tabBar,
              child: Center(
                child: Text(
                  label,
                  style: AppText.tabItem.copyWith(
                    color: active ? AppColors.accent : AppColors.neutral600,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    const divider = SizedBox(
      height: 22,
      child: VerticalDivider(width: 1, color: AppColors.divider),
    );

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            item(MainTab.events, 'EVENTS'),
            divider,
            item(MainTab.scan, 'SCAN'),
            divider,
            item(MainTab.settings, 'SETTINGS'),
          ],
        ),
      ),
    );
  }
}
