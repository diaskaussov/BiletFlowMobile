import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../app/role_tab_bar.dart';
import '../../../app/routes.dart';
import '../../../core/error/result.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/support.dart';
import '../domain/notifications_domain.dart';

class NotificationsViewModel extends Loadable<List<NotificationInfo>> {
  NotificationsViewModel(GetNotifications get, this._markRead) : super(get.call);

  final MarkNotificationRead _markRead;

  Future<void> open(NotificationInfo n) async {
    if (n.read) return;
    final r = await _markRead(n.id);
    if (r is Ok) {
      setData([
        for (final x in data ?? const <NotificationInfo>[])
          x.id == n.id
              ? NotificationInfo(id: x.id, title: x.title, message: x.message, type: x.type, read: true, createdAt: x.createdAt)
              : x,
      ]);
    }
  }
}

/// Уведомления: вкладка организатора или экран из профиля участника.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, this.tabs});

  /// Если задано — экран открыт как вкладка с плавающей навигацией.
  final List<RoleTab>? tabs;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<NotificationsViewModel>();
    final body = LoadableView<List<NotificationInfo>>(
      state: vm,
      isEmpty: (d) => d.isEmpty,
      empty: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.side),
          child: MessageView(icon: LucideIcons.bellOff, title: l.noNotifications, message: l.noNotificationsHint),
        ),
      ),
      builder: (context, list) => ListView.separated(
        padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 24),
        itemCount: list.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final n = list[i];
          return AppCard(
            onTap: () => vm.open(n),
            color: n.read ? null : c.primaryTint,
            borderColor: n.read ? null : c.primary.withValues(alpha: 0.3),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: n.read ? c.neutralSoft : c.primarySoft, shape: BoxShape.circle),
                  child: Icon(LucideIcons.bell, size: 18, color: n.read ? c.textMuted : c.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(n.title, style: AppText.cardTitle.copyWith(color: c.text)),
                      const SizedBox(height: 2),
                      Text(n.message, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
                      if (n.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(Fmt.ago(n.createdAt!), style: AppText.caption.copyWith(color: c.textMuted)),
                      ],
                    ],
                  ),
                ),
                if (!n.read) Container(width: 8, height: 8, margin: const EdgeInsets.only(top: 6), decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle)),
              ],
            ),
          );
        },
      ),
    );
    final t = tabs;
    if (t != null) {
      return RoleScaffold(tabs: t, current: Routes.organizerNotifications, title: l.notifications, body: body);
    }
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l.notifications, onBack: () => context.pop()),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }
}
