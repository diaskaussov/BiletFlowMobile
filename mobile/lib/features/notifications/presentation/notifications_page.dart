import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../core/error/result.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/formatters.dart';
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

class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NotificationsViewModel>();
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Notifications', onBack: () => context.pop()),
            Expanded(
              child: LoadableView<List<NotificationInfo>>(
                state: vm,
                isEmpty: (d) => d.isEmpty,
                empty: const Padding(
                  padding: EdgeInsets.all(AppSpacing.sideList),
                  child: MessageView(
                    icon: Icons.notifications_none,
                    title: 'Nothing new',
                    message: 'Order confirmations, refunds and support replies appear here.',
                  ),
                ),
                builder: (context, list) => ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sideList),
                  itemCount: list.length,
                  itemBuilder: (context, i) {
                    final n = list[i];
                    return InkWell(
                      onTap: () => vm.open(n),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: AppColors.divider)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 6, right: 10),
                              child: Container(
                                width: 8,
                                height: 8,
                                color: n.read ? Colors.transparent : AppColors.accent,
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(n.title, style: AppText.listTitle.copyWith(color: AppColors.ink, fontSize: 16)),
                                  const SizedBox(height: 2),
                                  Text(n.message, style: AppText.bodySecondary.copyWith(color: AppColors.neutral700)),
                                  if (n.createdAt != null)
                                    Text(Fmt.shortDateTime(n.createdAt!), style: AppText.meta.copyWith(color: AppColors.neutral500)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
