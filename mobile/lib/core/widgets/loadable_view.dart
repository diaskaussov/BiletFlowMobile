import 'package:flutter/material.dart';

import '../error/failure.dart';
import '../presentation/loadable.dart';
import '../theme/app_spacing.dart';
import 'state_views.dart';

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
        padding: const EdgeInsets.fromLTRB(AppSpacing.sideList, 48, AppSpacing.sideList, 16),
        child: MessageView(
          icon: f is NetworkFailure ? Icons.wifi_off : Icons.error_outline,
          title: f is NetworkFailure ? 'No connection' : 'Could not load',
          message: f.message,
          actionLabel: 'Try again',
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
    showMessage(context, failure.message);
  } else if (success != null) {
    showMessage(context, success);
  }
}
