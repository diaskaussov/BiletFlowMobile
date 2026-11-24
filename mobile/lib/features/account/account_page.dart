import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../app/role_tab_bar.dart';
import '../../app/routes.dart';
import '../../core/config/app_config.dart';
import '../../core/config/server_address.dart';
import '../../core/presentation/l10n.dart';
import '../../core/theme/app_palette.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/data_blocks.dart';
import '../../core/widgets/screen_header.dart';
import '../admin/presentation/admin_pages.dart' show roleLabel, roleTone;
import '../auth/domain/entities/user_session.dart';
import '../auth/presentation/controllers/session_controller.dart';
import '../settings/presentation/appearance_section.dart';

/// Профиль участника, организатора и админа платформы:
/// кто вошёл, уведомления, язык и тема, выход.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key, required this.base});

  /// Маршрут вкладки профиля этой роли — от него строятся дочерние.
  final String base;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final session = context.watch<SessionController>().session;
    final role = session?.role ?? UserRole.unknown;
    final tabs = RoleTabs.of(role);
    final isTab = tabs.any((t) => t.route == base);

    final body = ListView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 24),
      children: [
        AppCard(
          child: Row(children: [
            InitialAvatar(session?.fullName ?? '?', size: 52),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(session?.fullName ?? '', style: AppText.headerTitle.copyWith(color: c.text)),
                  Text(session?.email ?? '', style: AppText.meta.copyWith(color: c.textMuted)),
                  const SizedBox(height: 6),
                  TagLabel(roleLabel(l, role), tone: roleTone(role), dot: false),
                ],
              ),
            ),
          ]),
        ),
        const SizedBox(height: AppSpacing.section),
        SectionLabel(l.generalSection),
        if (role != UserRole.organizer)
          ValueRow(icon: LucideIcons.bell, label: l.notifications, value: '', onTap: () => context.push(Routes.notifications(base))),
        if (role == UserRole.organizer)
          ValueRow(icon: LucideIcons.building2, label: l.organizerProfile, value: '', onTap: () => context.push(Routes.organizerProfile)),
        const SizedBox(height: AppSpacing.section),
        const AppearanceSection(),
        const SizedBox(height: AppSpacing.section),
        SecondaryButton(
          label: l.signOut,
          icon: LucideIcons.logOut,
          tone: Tone.danger,
          onPressed: () => context.read<SessionController>().signOut(),
        ),
        const SizedBox(height: 14),
        Text(
          'BiletFlow ${AppConfig.appVersion} · ${l.server}: ${context.watch<ServerAddress>().current}\n${l.demoFootnote}',
          textAlign: TextAlign.center,
          style: AppText.finePrint.copyWith(color: c.textMuted),
        ),
      ],
    );

    if (isTab) return RoleScaffold(tabs: tabs, current: base, title: l.navProfile, body: body);
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          ScreenHeader(title: l.navProfile, onBack: () => context.pop()),
          Expanded(child: body),
        ]),
      ),
    );
  }
}
