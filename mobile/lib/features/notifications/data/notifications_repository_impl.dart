import '../../../core/error/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/request_guard.dart';
import '../../../core/utils/json_reader.dart';
import '../../../shared/data/models.dart';
import '../../../shared/domain/entities/support.dart';
import '../domain/notifications_domain.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  const NotificationsRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<Result<List<NotificationInfo>>> all() =>
      guard(() async => jsonList(await _api.get('/api/notifications')).map(Models.notification).toList());

  @override
  Future<Result<void>> markRead(int id) => guard(() => _api.post('/api/notifications/$id/read'));
}
