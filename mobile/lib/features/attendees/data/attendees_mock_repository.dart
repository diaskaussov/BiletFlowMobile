import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../domain/entities/attendee.dart';
import '../domain/repositories/attendees_repository.dart';

/// МОК. В API нет поиска участников для EVENT_ADMIN
/// (`GET /api/orders/event/{id}` доступен только ORGANIZER).
/// Данные из макетов C1–C3, одинаковые для любого события, живут до
/// перезапуска приложения. Заменить на remote-реализацию, когда бэкенд
/// добавит эндпоинты поиска и ручной отметки.
class AttendeesMockRepository implements AttendeesRepository {
  AttendeesMockRepository({DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Map<int, List<Attendee>> _byEvent = {};

  static const _latency = Duration(milliseconds: 350);

  List<Attendee> _attendees(int eventId) => _byEvent.putIfAbsent(eventId, _seed);

  List<Attendee> _seed() {
    final now = _clock();
    final today = DateTime(now.year, now.month, now.day);
    final paid = today.subtract(const Duration(days: 3)).add(const Duration(hours: 14, minutes: 2));
    return [
      Attendee(
        id: 'A-1001',
        fullName: 'Dias Sagynbek',
        email: 'd.sagynbek@mail.kz',
        orderNumber: 'ORD-0412',
        tickets: [
          AttendeeTicket(
            id: 'TCK-8F42-19KD',
            type: 'VIP Balcony',
            seat: 'Sec B / R12 / S7',
            status: AttendeeTicketStatus.checkedIn,
            checkedInAt: now.subtract(const Duration(minutes: 4)),
            checkedInBy: 'Gate 3',
          ),
        ],
        history: [AttendeeHistoryEntry(at: paid, text: 'Order paid, 1 ticket issued')],
      ),
      Attendee(
        id: 'A-1002',
        fullName: 'Nurgul Sagynbekova',
        email: 'n.sagynbekova@mail.kz',
        orderNumber: 'ORD-0188',
        tickets: const [
          AttendeeTicket(id: 'TCK-9B21-55MN', type: 'General Admission', status: AttendeeTicketStatus.valid),
          AttendeeTicket(id: 'TCK-9B21-56MN', type: 'General Admission', status: AttendeeTicketStatus.valid),
        ],
        history: [
          AttendeeHistoryEntry(at: paid, text: 'Order paid, 2 tickets issued'),
          AttendeeHistoryEntry(at: paid, text: 'Tickets emailed'),
          AttendeeHistoryEntry(
            at: paid.add(const Duration(days: 2, hours: 4, minutes: 38)),
            text: 'Ticket PDF downloaded',
          ),
        ],
      ),
      Attendee(
        id: 'A-1003',
        fullName: 'Ruslan Sagyndykov',
        email: 'r.sagyndykov@sdu.edu.kz',
        orderNumber: 'ORD-0233',
        tickets: const [
          AttendeeTicket(id: 'TCK-4D18-02QA', type: 'Student', status: AttendeeTicketStatus.valid),
        ],
        history: [AttendeeHistoryEntry(at: paid, text: 'Registered, 1 ticket issued')],
      ),
      Attendee(
        id: 'A-1004',
        fullName: 'Madina Zhaksylyk',
        email: 'm.zhaksylyk@gmail.com',
        orderNumber: 'ORD-0301',
        tickets: [
          AttendeeTicket(
            id: 'TCK-3A77-04PL',
            type: 'General Admission',
            status: AttendeeTicketStatus.checkedIn,
            checkedInAt: now.subtract(const Duration(minutes: 32)),
            checkedInBy: 'T. Abenov',
          ),
        ],
        history: [AttendeeHistoryEntry(at: paid, text: 'Order paid, 1 ticket issued')],
      ),
      Attendee(
        id: 'A-1005',
        fullName: 'Aliya Serikova',
        email: 'aliya.serikova@mail.kz',
        orderNumber: 'ORD-0277',
        tickets: const [
          AttendeeTicket(id: 'TCK-5C10-77RS', type: 'Student', status: AttendeeTicketStatus.refunded),
        ],
        history: [
          AttendeeHistoryEntry(at: paid, text: 'Order paid, 1 ticket issued'),
          AttendeeHistoryEntry(at: paid.add(const Duration(days: 1)), text: 'Order refunded'),
        ],
      ),
    ];
  }

  @override
  Future<Result<List<Attendee>>> search({required int eventId, required String query}) async {
    await Future<void>.delayed(_latency);
    final q = query.toLowerCase();
    final found = _attendees(eventId).where((a) {
      return a.fullName.toLowerCase().contains(q) ||
          (a.email?.toLowerCase().contains(q) ?? false) ||
          a.tickets.any((t) => t.id.toLowerCase().contains(q));
    }).toList();
    return Ok(found);
  }

  @override
  Future<Result<Attendee>> getById({required int eventId, required String attendeeId}) async {
    await Future<void>.delayed(_latency);
    final a = _find(eventId, attendeeId);
    return a == null ? const Err(ServerFailure('Attendee not found.', statusCode: 404)) : Ok(a);
  }

  @override
  Future<Result<Attendee>> checkIn({
    required int eventId,
    required String attendeeId,
    required List<String> ticketIds,
    required String staffName,
  }) async {
    await Future<void>.delayed(_latency);
    final a = _find(eventId, attendeeId);
    if (a == null) return const Err(ServerFailure('Attendee not found.', statusCode: 404));
    final now = _clock();
    final updated = a.copyWith(
      tickets: [
        for (final t in a.tickets)
          ticketIds.contains(t.id) && t.canCheckIn
              ? t.copyWith(status: AttendeeTicketStatus.checkedIn, checkedInAt: now, checkedInBy: staffName)
              : t,
      ],
      history: [
        ...a.history,
        AttendeeHistoryEntry(
          at: now,
          text: 'Checked in manually by $staffName (${ticketIds.length} '
              '${ticketIds.length == 1 ? 'ticket' : 'tickets'})',
        ),
      ],
    );
    _replace(eventId, updated);
    return Ok(updated);
  }

  @override
  Future<Result<Attendee>> undoCheckIn({
    required int eventId,
    required String attendeeId,
    required String ticketId,
    required String reason,
    required String staffName,
  }) async {
    await Future<void>.delayed(_latency);
    final a = _find(eventId, attendeeId);
    if (a == null) return const Err(ServerFailure('Attendee not found.', statusCode: 404));
    final updated = a.copyWith(
      tickets: [
        for (final t in a.tickets)
          t.id == ticketId && t.status == AttendeeTicketStatus.checkedIn
              ? t.copyWith(status: AttendeeTicketStatus.valid, clearCheckIn: true)
              : t,
      ],
      history: [
        ...a.history,
        AttendeeHistoryEntry(at: _clock(), text: 'Check-in reversed by $staffName — $reason'),
      ],
    );
    _replace(eventId, updated);
    return Ok(updated);
  }

  Attendee? _find(int eventId, String id) =>
      _attendees(eventId).where((a) => a.id == id).firstOrNull;

  void _replace(int eventId, Attendee updated) {
    final list = _attendees(eventId);
    final i = list.indexWhere((a) => a.id == updated.id);
    if (i >= 0) list[i] = updated;
  }
}
