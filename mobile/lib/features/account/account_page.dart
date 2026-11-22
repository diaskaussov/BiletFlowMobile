import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../app/role_tab_bar.dart';
import '../../app/routes.dart';
import '../../core/config/app_config.dart';
import '../../core/config/server_address.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/buttons.dart';
import '../../core/widgets/data_blocks.dart';
import '../../core/widgets/screen_header.dart';
import '../auth/domain/entities/user_session.dart';
import '../auth/presentation/controllers/session_controller.dart';

/// Профиль для участника, организатора и админа платформы:
/// кто вошёл, уведомления, адрес сервера, выход.
class AccountPage extends StatelessWidget {
  const AccountPage({super.key, required this.base});

  /// Маршрут вкладки профиля этой роли — от него строятся дочерние.
  final String base;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>().session;
    final role = session?.role ?? UserRole.unknown;
    final roleLabel = switch (role) {
      UserRole.attendee => 'Attendee',
      UserRole.organizer => 'Organizer',
      UserRole.platformAdmin => 'Platform admin',
      UserRole.eventAdmin => 'Event admin',
      UserRole.unknown => 'Account',
    };

    return RoleScaffold(
      tabs: RoleTabs.of(role),
      current: base,
      title: 'Account',
      body: ListView(
        padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 22, AppSpacing.sideList, 24),
        children: [
          Text(session?.fullName ?? '', style: AppText.listTitle.copyWith(color: AppColors.ink)),
          Text(session?.email ?? '', style: AppText.meta.copyWith(color: AppColors.neutral600)),
          const SizedBox(height: 10),
          Align(alignment: Alignment.centerLeft, child: TagLabel(roleLabel, filled: true)),
          const SizedBox(height: AppSpacing.section),
          const SectionLabel('General'),
          ValueRow(
            label: 'Notifications',
            value: '',
            onTap: () => context.push(Routes.notifications(base)),
          ),
          if (role == UserRole.organizer)
            ValueRow(
              label: 'Organizer profile & payout',
              value: '',
              onTap: () => context.push(Routes.organizerProfile),
            ),
          const ValueRow(label: 'Language', value: 'English'),
          const SizedBox(height: AppSpacing.section),
          SecondaryButton(
            label: 'Sign out',
            onPressed: () => context.read<SessionController>().signOut(),
          ),
          const SizedBox(height: 14),
          Text(
            'BiletFlow ${AppConfig.appVersion} · ${context.watch<ServerAddress>().current}\n'
            'All payments in this build are demonstration only — no money moves.',
            style: AppText.finePrint.copyWith(color: AppColors.neutral600),
          ),
        ],
      ),
    );
  }
}
