import 'dart:typed_data';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../shared/domain/entities/commerce.dart';

abstract interface class TicketsRepository {
  Future<Result<List<OrderInfo>>> myOrders();

  Future<Result<List<TicketInfo>>> myTickets();

  Future<Result<OrderInfo>> order(int id);

  Future<Result<List<TicketInfo>>> ticketsForOrder(int orderId);

  Future<Result<Uint8List>> qr(int ticketId);

  Future<Result<Uint8List>> pdf(int ticketId);

  Future<Result<OrderInfo>> cancelOrder(int orderId);
}

/// Билеты одного события в «Моих билетах» (W8).
class TicketGroup {
  const TicketGroup({required this.eventId, required this.tickets, this.eventTitle, this.startsAt, this.venue});

  final int eventId;
  final String? eventTitle;
  final DateTime? startsAt;
  final String? venue;
  final List<TicketInfo> tickets;

  bool get allVoid => tickets.every((t) => t.status == TicketStatus.refunded || t.status == TicketStatus.cancelled);

  List<String> get seats => [for (final t in tickets) ?t.seat];
}

class MyTickets {
  const MyTickets({required this.upcoming, required this.past, required this.refunded});

  final List<TicketGroup> upcoming;
  final List<TicketGroup> past;
  final List<TicketGroup> refunded;
}

/// W8: билеты по событиям, разложенные на «впереди / прошли / возвращены».
class GetMyTickets {
  GetMyTickets(this._repo, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final TicketsRepository _repo;
  final DateTime Function() _clock;

  Future<Result<MyTickets>> call() async {
    final r = await _repo.myTickets();
    if (r case Err(:final failure)) return Err(failure);
    return Ok(groupTickets(r.valueOrNull!, _clock()));
  }
}

MyTickets groupTickets(List<TicketInfo> tickets, DateTime now) {
  final byEvent = <int, List<TicketInfo>>{};
  for (final t in tickets) {
    byEvent.putIfAbsent(t.eventId ?? -1, () => []).add(t);
  }
  final groups = [
    for (final MapEntry(:key, :value) in byEvent.entries)
      TicketGroup(
        eventId: key,
        eventTitle: value.first.eventTitle,
        startsAt: value.first.eventStartsAt,
        venue: value.first.eventVenue,
        tickets: value,
      ),
  ];
  final refunded = groups.where((g) => g.allVoid).toList();
  final live = groups.where((g) => !g.allVoid);
  bool isPast(TicketGroup g) =>
      g.startsAt != null && g.startsAt!.add(const Duration(hours: 12)).isBefore(now);
  final upcoming = live.where((g) => !isPast(g)).toList()
    ..sort((a, b) => (a.startsAt ?? DateTime(9999)).compareTo(b.startsAt ?? DateTime(9999)));
  final past = live.where(isPast).toList()
    ..sort((a, b) => (b.startsAt ?? DateTime(0)).compareTo(a.startsAt ?? DateTime(0)));
  return MyTickets(upcoming: upcoming, past: past, refunded: refunded);
}

class OrderDetails {
  const OrderDetails({required this.order, required this.tickets});

  final OrderInfo order;
  final List<TicketInfo> tickets;
}

/// W6: заказ и выпущенные по нему билеты.
class GetOrderDetails {
  const GetOrderDetails(this._repo);

  final TicketsRepository _repo;

  Future<Result<OrderDetails>> call(int orderId) async {
    final o = await _repo.order(orderId);
    if (o case Err(:final failure)) return Err(failure);
    final order = o.valueOrNull!;
    // Неоплаченный заказ ещё без билетов — это не ошибка.
    final t = await _repo.ticketsForOrder(orderId);
    return Ok(OrderDetails(order: order, tickets: t.valueOrNull ?? const []));
  }
}

/// W7: билет по id — отдельного эндпоинта нет, берём из «моих».
class GetTicket {
  const GetTicket(this._repo);

  final TicketsRepository _repo;

  Future<Result<TicketInfo>> call(int ticketId) async {
    final r = await _repo.myTickets();
    if (r case Err(:final failure)) return Err(failure);
    final found = r.valueOrNull!.where((t) => t.id == ticketId).firstOrNull;
    return found == null ? const Err(ServerFailure('Ticket not found.', statusCode: 404)) : Ok(found);
  }
}

class GetTicketFile {
  const GetTicketFile(this._repo);

  final TicketsRepository _repo;

  Future<Result<Uint8List>> qr(int ticketId) => _repo.qr(ticketId);

  Future<Result<Uint8List>> pdf(int ticketId) => _repo.pdf(ticketId);
}

/// Отмена заказа участником (§4.9). Уже использованный заказ отменить нельзя.
class CancelOrder {
  const CancelOrder(this._repo);

  final TicketsRepository _repo;

  Future<Result<OrderInfo>> call(OrderDetails details) async {
    final o = details.order;
    if (o.status == OrderStatus.cancelled || o.status == OrderStatus.refunded) {
      return const Err(ValidationFailure('This order is already cancelled.'));
    }
    if (details.tickets.any((t) => t.status == TicketStatus.checkedIn)) {
      return const Err(ValidationFailure('A ticket in this order was already used at the door.'));
    }
    return _repo.cancelOrder(o.id);
  }
}
