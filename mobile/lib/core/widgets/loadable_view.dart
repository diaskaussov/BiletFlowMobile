import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../error/failure.dart';
import '../presentation/loadable.dart';
import '../theme/app_spacing.dart';
import 'state_views.dart';
import '../presentation/failure_text.dart';
import '../presentation/l10n.dart';
import '../theme/app_palette.dart';

/// Отрисовка [Loadable]: индикатор, ошибка с повтором или контент.
/// Pull-to-refresh перезагружает данные.
class LoadableView<T> extends StatelessWidget {
  const LoadableView({
    super.key,
    required this.state,
    required this.builder,
    this.isEmpty,
    this.empty,
    this.refreshable = true,
  });

  final Loadable<T> state;
  final Widget Function(BuildContext context, T data) builder;
  final bool Function(T data)? isEmpty;
  final Widget? empty;
  final bool refreshable;

  @override
  Widget build(BuildContext context) {
    final data = state.data;
    if (data == null) {
      if (state.isLoading || state.failure == null) return const LoadingView();
      final f = state.failure!;
      return Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.side, 48, AppSpacing.side, 16),
        child: MessageView(
          icon: f is NetworkFailure ? LucideIcons.wifiOff : LucideIcons.circleAlert,
          tone: Tone.danger,
          title: f is NetworkFailure ? context.l10n.noConnectionTitle : context.l10n.loadFailedTitle,
          message: f.text(context),
          actionLabel: context.l10n.tryAgain,
          onAction: state.load,
        ),
      );
    }
    final content = (isEmpty?.call(data) ?? false) && empty != null
        ? ListView(children: [empty!])
        : builder(context, data);
    if (!refreshable) return content;
    return RefreshIndicator(onRefresh: state.load, child: content);
  }
}

/// Показать результат действия: ошибку или сообщение об успехе.
void reportResult(BuildContext context, Failure? failure, {String? success}) {
  if (!context.mounted) return;
  if (failure != null) {
    showMessage(context, failure.text(context));
  } else if (success != null) {
    showMessage(context, success);
  }
}
