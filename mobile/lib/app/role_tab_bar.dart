import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_text_styles.dart';
import '../features/auth/domain/entities/user_session.dart';
import 'routes.dart';

class RoleTab {
  const RoleTab(this.label, this.route);

  final String label;
  final String route;
}

/// Вкладки каждой роли. Сканер (EVENT_ADMIN) использует свой MainTabBar.
abstract final class RoleTabs {
  static const attendee = [
    RoleTab('EVENTS', Routes.catalog),
    RoleTab('TICKETS', Routes.myTickets),
    RoleTab('SUPPORT', Routes.attendeeSupport),
    RoleTab('ACCOUNT', Routes.attendeeAccount),
  ];

  static const organizer = [
    RoleTab('EVENTS', Routes.organizer),
    RoleTab('SUPPORT', Routes.organizerSupport),
    RoleTab('ACCOUNT', Routes.organizerAccount),
  ];

  static const admin = [
    RoleTab('QUEUES', Routes.adminQueues),
    RoleTab('EVENTS', Routes.adminEvents),
    RoleTab('USERS', Routes.adminUsers),
    RoleTab('ACCOUNT', Routes.adminAccount),
  ];

  static List<RoleTab> of(UserRole role) => switch (role) {
        UserRole.attendee => attendee,
        UserRole.organizer => organizer,
        UserRole.platformAdmin => admin,
        _ => const [],
      };
}

/// Нижние вкладки: равные пункты, линия сверху, активный — accent (§04).
class RoleTabBar extends StatelessWidget {
  const RoleTabBar({super.key, required this.tabs, required this.current});

  final List<RoleTab> tabs;
  final String current;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            for (final (i, tab) in tabs.indexed) ...[
              if (i > 0)
                const SizedBox(height: 22, child: VerticalDivider(width: 1, color: AppColors.divider)),
              Expanded(
                child: Semantics(
                  button: true,
                  selected: tab.route == current,
                  child: InkWell(
                    onTap: tab.route == current ? null : () => context.go(tab.route),
                    child: SizedBox(
                      height: AppSizes.tabBar,
                      child: Center(
                        child: Text(
                          tab.label,
                          style: AppText.tabItem.copyWith(
                            color: tab.route == current ? AppColors.accent : AppColors.neutral600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Каркас главного экрана роли: заголовок 26 pt и вкладки снизу.
class RoleScaffold extends StatelessWidget {
  const RoleScaffold({
    super.key,
    required this.tabs,
    required this.current,
    required this.title,
    required this.body,
    this.subtitle,
    this.action,
  });

  final List<RoleTab> tabs;
  final String current;
  final String title;
  final String? subtitle;
  final Widget? action;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 18, AppSpacing.sideList, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: AppText.screenTitle.copyWith(color: AppColors.ink)),
                        if (subtitle != null)
                          Text(subtitle!, style: AppText.meta.copyWith(color: AppColors.neutral600)),
                      ],
                    ),
                  ),
                  ?action,
                ],
              ),
            ),
            const Divider(),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: RoleTabBar(tabs: tabs, current: current),
    );
  }
}
