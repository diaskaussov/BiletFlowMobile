import '../../../core/error/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/request_guard.dart';
import '../../../core/utils/json_reader.dart';
import '../../../shared/data/models.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../../../shared/domain/entities/people.dart';
import '../domain/admin_domain.dart';

/// `/api/admin/*`. Ответ `users` содержит хэш пароля и токены — модель
/// [Models.user] их не читает, но бэкенду нужно убрать их из ответа.
class AdminRepositoryImpl implements AdminRepository {
  const AdminRepositoryImpl(this._api);

  final ApiClient _api;

  @override
  Future<Result<List<UserAccount>>> users() =>
      guard(() async => jsonList(await _api.get('/api/admin/users')).map(Models.user).toList());

  @override
  Future<Result<List<EventInfo>>> events() =>
      guard(() async => jsonList(await _api.get('/api/admin/events')).map(Models.event).toList());

  @override
  Future<Result<List<OrderInfo>>> orders() =>
      guard(() async => jsonList(await _api.get('/api/admin/orders')).map(Models.order).toList());

  @override
  Future<Result<void>> suspendUser(int id) => guard(() => _api.post('/api/admin/users/$id/suspend'));

  @override
  Future<Result<void>> unsuspendUser(int id) => guard(() => _api.post('/api/admin/users/$id/unsuspend'));

  @override
  Future<Result<void>> suspendEvent(int id) => guard(() => _api.post('/api/admin/events/$id/suspend'));
}
