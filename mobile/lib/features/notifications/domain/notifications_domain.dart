import '../../../core/error/result.dart';
import '../../../shared/domain/entities/support.dart';

/// Уведомления (§4.10): подтверждения, возвраты, ответы поддержки.
abstract interface class NotificationsRepository {
  Future<Result<List<NotificationInfo>>> all();

  Future<Result<void>> markRead(int id);
}

class GetNotifications {
  const GetNotifications(this._repo);

  final NotificationsRepository _repo;

  /// Новые сверху.
  Future<Result<List<NotificationInfo>>> call() async {
    final r = await _repo.all();
    return switch (r) {
      Ok(:final value) => Ok([...value]..sort((a, b) =>
          (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)))),
      Err(:final failure) => Err(failure),
    };
  }
}

class MarkNotificationRead {
  const MarkNotificationRead(this._repo);

  final NotificationsRepository _repo;

  Future<Result<void>> call(int id) => _repo.markRead(id);
}
