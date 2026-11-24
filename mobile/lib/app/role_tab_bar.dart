import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../core/presentation/l10n.dart';
import '../core/widgets/floating_nav_bar.dart';
import '../features/auth/domain/entities/user_session.dart';
import 'routes.dart';

class RoleTab {
  const RoleTab(this.label, this.route, this.icon);

  final String Function(AppLocalizations l) label;
  final String route;
  final IconData icon;
}

String _events(AppLocalizations l) => l.navEvents;
String _tickets(AppLocalizations l) => l.navTickets;
String _support(AppLocalizations l) => l.navSupport;
String _profile(AppLocalizations l) => l.navProfile;
String _alerts(AppLocalizations l) => l.navAlerts;
String _queues(AppLocalizations l) => l.navQueues;
String _users(AppLocalizations l) => l.navUsers;
String _orders(AppLocalizations l) => l.navOrders;

/// Вкладки ролей по TicketTon.pen. Сканер (EVENT_ADMIN) использует свои.
abstract final class RoleTabs {
  static const attendee = [
    RoleTab(_events, Routes.catalog, LucideIcons.calendar),
    RoleTab(_tickets, Routes.myTickets, LucideIcons.ticket),
    RoleTab(_support, Routes.attendeeSupport, LucideIcons.lifeBuoy),
    RoleTab(_profile, Routes.attendeeAccount, LucideIcons.user),
  ];

  static const organizer = [
    RoleTab(_events, Routes.organizer, LucideIcons.calendar),
    RoleTab(_support, Routes.organizerSupport, LucideIcons.lifeBuoy),
    RoleTab(_alerts, Routes.organizerNotifications, LucideIcons.bell),
    RoleTab(_profile, Routes.organizerAccount, LucideIcons.user),
  ];

  static const admin = [
    RoleTab(_queues, Routes.adminQueues, LucideIcons.inbox),
    RoleTab(_users, Routes.adminUsers, LucideIcons.users),
    RoleTab(_events, Routes.adminEvents, LucideIcons.calendar),
    RoleTab(_orders, Routes.adminOrders, LucideIcons.receipt),
  ];

  static List<RoleTab> of(UserRole role) => switch (role) {
        UserRole.attendee => attendee,
        UserRole.organizer => organizer,
        UserRole.platformAdmin => admin,
        _ => const [],
      };
}

class RoleTabBar extends StatelessWidget {
  const RoleTabBar({super.key, required this.tabs, required this.current});

  final List<RoleTab> tabs;
  final String current;

  @override
  Widget build(BuildContext context) {
    final index = tabs.indexWhere((t) => t.route == current);
    return FloatingNavBar(
      items: [for (final t in tabs) NavItem(icon: t.icon, label: t.label(context.l10n))],
      current: index < 0 ? 0 : index,
      onSelect: (i) => context.go(tabs[i].route),
    );
  }
}

/// Каркас главного экрана роли: крупная шапка и плавающая навигация.
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

  /// Строка над заголовком.
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
            LargeHeader(title: title, context_: subtitle, action: action),
            Expanded(child: body),
          ],
        ),
      ),
      bottomNavigationBar: RoleTabBar(tabs: tabs, current: current),
    );
  }
}
