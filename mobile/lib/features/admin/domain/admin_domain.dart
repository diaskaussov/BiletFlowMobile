import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../../../shared/domain/entities/people.dart';
import '../../auth/domain/entities/user_session.dart';

abstract interface class AdminRepository {
  Future<Result<List<UserAccount>>> users();

  Future<Result<List<EventInfo>>> events();

  Future<Result<List<OrderInfo>>> orders();

  Future<Result<void>> suspendUser(int id);

  Future<Result<void>> unsuspendUser(int id);

  Future<Result<void>> suspendEvent(int id);
}

/// P1: очереди, которые можно собрать из данных API. Жалоб на события,
/// заявок на активацию и эскалаций поддержки в API нет — они показываются
/// как недоступные, а не выдумываются.
class AdminQueues {
  const AdminQueues({
    required this.pendingPayments,
    required this.paidSalesEvents,
    required this.suspendedUsers,
    required this.recentRefunds,
    required this.totals,
  });

  /// Неоплаченные заказы — брошенные или не прошедшие оплату.
  final List<OrderInfo> pendingPayments;

  /// События с активными платными продажами — для проверки активаций.
  final List<EventInfo> paidSalesEvents;
  final List<UserAccount> suspendedUsers;
  final List<OrderInfo> recentRefunds;
  final ({int users, int events, int orders}) totals;
}

class GetAdminQueues {
  const GetAdminQueues(this._repo);

  final AdminRepository _repo;

  Future<Result<AdminQueues>> call() async {
    final results = await Future.wait([_repo.users(), _repo.events(), _repo.orders()]);
    for (final r in results) {
      if (r case Err(:final failure)) return Err(failure);
    }
    final users = results[0].valueOrNull! as List<UserAccount>;
    final events = results[1].valueOrNull! as List<EventInfo>;
    final orders = results[2].valueOrNull! as List<OrderInfo>;
    int newest(OrderInfo a, OrderInfo b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0));
    return Ok(AdminQueues(
      pendingPayments: orders.where((o) => o.status == OrderStatus.pending).toList()..sort(newest),
      paidSalesEvents: events.where((e) => e.paidSalesActivated && e.status != EventStatus.cancelled).toList(),
      suspendedUsers: users.where((u) => u.suspended).toList(),
      recentRefunds: orders.where((o) => o.status == OrderStatus.refunded).toList()..sort(newest),
      totals: (users: users.length, events: events.length, orders: orders.length),
    ));
  }
}

class AdminLists {
  const AdminLists(this._repo);

  final AdminRepository _repo;

  Future<Result<List<UserAccount>>> users() => _repo.users();

  Future<Result<List<EventInfo>>> events() async {
    final r = await _repo.events();
    return switch (r) {
      Ok(:final value) => Ok([...value]..sort((a, b) => (b.startsAt ?? DateTime(0)).compareTo(a.startsAt ?? DateTime(0)))),
      Err(:final failure) => Err(failure),
    };
  }

  Future<Result<List<OrderInfo>>> orders() async {
    final r = await _repo.orders();
    return switch (r) {
      Ok(:final value) => Ok([...value]..sort((a, b) => (b.createdAt ?? DateTime(0)).compareTo(a.createdAt ?? DateTime(0)))),
      Err(:final failure) => Err(failure),
    };
  }
}

/// P2: карточка события для модерации — событие, организатор, продажи.
class ModerationCase {
  const ModerationCase({required this.event, required this.orders, this.organizer});

  final EventInfo event;
  final UserAccount? organizer;
  final List<OrderInfo> orders;

  int get ticketsSold => orders
      .where((o) => o.status == OrderStatus.completed)
      .fold(0, (s, o) => s + o.ticketCount);

  double get collected =>
      orders.where((o) => o.status == OrderStatus.completed).fold(0, (s, o) => s + o.total);
}

class GetModerationCase {
  const GetModerationCase(this._repo);

  final AdminRepository _repo;

  Future<Result<ModerationCase>> call(int eventId) async {
    final results = await Future.wait([_repo.events(), _repo.orders(), _repo.users()]);
    for (final r in results) {
      if (r case Err(:final failure)) return Err(failure);
    }
    final event = (results[0].valueOrNull! as List<EventInfo>).where((e) => e.id == eventId).firstOrNull;
    if (event == null) return const Err(ServerFailure('Event not found.', statusCode: 404, code: 'eventNotFound'));
    final orders = (results[1].valueOrNull! as List<OrderInfo>).where((o) => o.eventId == eventId).toList();
    final organizer = (results[2].valueOrNull! as List<UserAccount>).where((u) => u.id == event.organizerId).firstOrNull;
    return Ok(ModerationCase(event: event, orders: orders, organizer: organizer));
  }
}

/// §4.12: блокировка пользователя или события. Причина обязательна для
/// журнала, хотя API её пока не принимает.
class ModerationActions {
  const ModerationActions(this._repo);

  final AdminRepository _repo;

  Future<Result<void>> suspendUser(UserAccount u, {required int currentAdminId}) async {
    if (u.id == currentAdminId) return const Err(ValidationFailure('You cannot suspend your own account.', code: 'selfSuspend'));
    if (u.role == UserRole.platformAdmin) return const Err(ValidationFailure('Platform admins cannot be suspended here.', code: 'adminSuspend'));
    if (u.suspended) return const Err(ValidationFailure('This user is already suspended.', code: 'userAlreadySuspended'));
    return _repo.suspendUser(u.id);
  }

  Future<Result<void>> unsuspendUser(UserAccount u) async {
    if (!u.suspended) return const Err(ValidationFailure('This user is not suspended.', code: 'userNotSuspended'));
    return _repo.unsuspendUser(u.id);
  }

  Future<Result<void>> suspendEvent(EventInfo e, String reason) async {
    if (reason.trim().length < 3) return const Err(ValidationFailure('Record the reason for suspending.', code: 'suspendReason'));
    return _repo.suspendEvent(e.id);
  }
}
