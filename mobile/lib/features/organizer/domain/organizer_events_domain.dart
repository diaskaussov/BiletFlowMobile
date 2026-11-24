import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../../../shared/domain/entities/insights.dart';
import '../../../shared/domain/entities/people.dart';

// ─── drafts ────────────────────────────────────────────────────────────────

/// Форма O2 (§4.2).
class EventDraft {
  const EventDraft({
    this.title = '',
    this.description = '',
    this.category = '',
    this.imageUrl = '',
    this.venueName = '',
    this.venueAddress = '',
    this.city = '',
    this.startsAt,
    this.endsAt,
    this.registrationOpensAt,
    this.registrationClosesAt,
    this.capacity,
    this.visibility = EventVisibility.public,
    this.assignedSeating = false,
  });

  factory EventDraft.from(EventInfo e) => EventDraft(
        title: e.title,
        description: e.description ?? '',
        category: e.category ?? '',
        imageUrl: e.imageUrl ?? '',
        venueName: e.venueName ?? '',
        venueAddress: e.venueAddress ?? '',
        city: e.city ?? '',
        startsAt: e.startsAt,
        endsAt: e.endsAt,
        registrationOpensAt: e.registrationOpensAt,
        registrationClosesAt: e.registrationClosesAt,
        capacity: e.capacity,
        visibility: e.visibility,
        assignedSeating: e.assignedSeating,
      );

  final String title;
  final String description;
  final String category;
  final String imageUrl;
  final String venueName;
  final String venueAddress;
  final String city;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final DateTime? registrationOpensAt;
  final DateTime? registrationClosesAt;
  final int? capacity;
  final EventVisibility visibility;
  final bool assignedSeating;

  EventDraft copyWith({
    String? title,
    String? description,
    String? category,
    String? imageUrl,
    String? venueName,
    String? venueAddress,
    String? city,
    DateTime? startsAt,
    DateTime? endsAt,
    DateTime? registrationOpensAt,
    DateTime? registrationClosesAt,
    int? Function()? capacity,
    EventVisibility? visibility,
    bool? assignedSeating,
  }) =>
      EventDraft(
        title: title ?? this.title,
        description: description ?? this.description,
        category: category ?? this.category,
        imageUrl: imageUrl ?? this.imageUrl,
        venueName: venueName ?? this.venueName,
        venueAddress: venueAddress ?? this.venueAddress,
        city: city ?? this.city,
        startsAt: startsAt ?? this.startsAt,
        endsAt: endsAt ?? this.endsAt,
        registrationOpensAt: registrationOpensAt ?? this.registrationOpensAt,
        registrationClosesAt: registrationClosesAt ?? this.registrationClosesAt,
        capacity: capacity == null ? this.capacity : capacity(),
        visibility: visibility ?? this.visibility,
        assignedSeating: assignedSeating ?? this.assignedSeating,
      );

  /// Ошибка формы или null — правила §4.2.
  Problem? validate() {
    if (title.trim().isEmpty) return const Problem('eventTitle', 'Give the event a title.');
    if (venueName.trim().isEmpty) return const Problem('eventVenue', 'Add the venue — events are physical (§4.2).');
    if (city.trim().isEmpty) return const Problem('eventCity', 'Add the city.');
    final s = startsAt;
    if (s == null) return const Problem('eventStart', 'Choose when the event starts.');
    if (endsAt != null && !endsAt!.isAfter(s)) return const Problem('eventEndOrder', 'The event must end after it starts.');
    if (registrationOpensAt != null &&
        registrationClosesAt != null &&
        !registrationClosesAt!.isAfter(registrationOpensAt!)) {
      return const Problem('regCloseOrder', 'Registration must close after it opens.');
    }
    if (registrationClosesAt != null && registrationClosesAt!.isAfter(endsAt ?? s)) {
      return const Problem('regCloseBeforeEnd', 'Registration must close before the event ends.');
    }
    if (capacity == null || capacity! < 1) return const Problem('capacityMin', 'Set a capacity of at least 1.');
    return null;
  }
}

/// Форма типа билета O3 (§4.3).
class TicketTypeDraft {
  const TicketTypeDraft({
    this.name = '',
    this.description = '',
    this.price = 0,
    this.quantity = 0,
    this.maxPerOrder,
    this.salesStart,
    this.salesEnd,
  });

  factory TicketTypeDraft.from(TicketTypeInfo t) => TicketTypeDraft(
        name: t.name,
        description: t.description ?? '',
        price: t.price,
        quantity: t.quantity,
        maxPerOrder: t.maxPerOrder,
        salesStart: t.salesStart,
        salesEnd: t.salesEnd,
      );

  final String name;
  final String description;
  final double price;
  final int quantity;
  final int? maxPerOrder;
  final DateTime? salesStart;
  final DateTime? salesEnd;

  bool get isFree => price == 0;

  Problem? validate({int alreadySold = 0}) {
    if (name.trim().isEmpty) return const Problem('typeName', 'Name the ticket type.');
    if (price < 0) return const Problem('priceNegative', 'Price cannot be negative.');
    if (quantity < 1) return const Problem('quantityMin', 'Quantity must be at least 1.');
    if (quantity < alreadySold) {
      return Problem('quantityBelowSold', 'Quantity cannot go below the $alreadySold already sold.', {'count': alreadySold});
    }
    if (maxPerOrder != null && maxPerOrder! < 1) return const Problem('perOrderMin', 'Limit per order must be at least 1.');
    if (salesStart != null && salesEnd != null && !salesEnd!.isAfter(salesStart!)) {
      return const Problem('salesEndOrder', 'Sales must end after they start.');
    }
    return null;
  }
}

/// Секция схемы зала (§4.3.1): ряды × мест, привязанные к типу билета.
class SectionDraft {
  const SectionDraft({required this.name, required this.ticketTypeId, required this.rows, required this.seatsPerRow});

  final String name;
  final int ticketTypeId;
  final int rows;
  final int seatsPerRow;

  int get seats => rows * seatsPerRow;
}

/// Статусная группа O1.
enum DashboardGroup { active, upcoming, draft, completed, cancelled }

class DashboardEvent {
  const DashboardEvent({required this.event, required this.group, this.analytics});

  final EventInfo event;
  final DashboardGroup group;
  final EventAnalytics? analytics;
}

// ─── repository ────────────────────────────────────────────────────────────

abstract interface class OrganizerEventsRepository {
  Future<Result<List<EventInfo>>> myEvents();

  Future<Result<EventInfo>> event(int id);

  Future<Result<EventInfo>> create(EventDraft draft);

  Future<Result<EventInfo>> update(int id, EventDraft draft);

  Future<Result<EventInfo>> publish(int id);

  Future<Result<EventInfo>> unpublish(int id);

  Future<Result<EventInfo>> cancel(int id);

  Future<Result<EventInfo>> duplicate(int id);

  Future<Result<List<TicketTypeInfo>>> ticketTypes(int eventId);

  Future<Result<TicketTypeInfo>> createTicketType(int eventId, TicketTypeDraft draft);

  Future<Result<TicketTypeInfo>> updateTicketType(int id, TicketTypeDraft draft);

  Future<Result<void>> hideTicketType(int id);

  Future<Result<List<SeatInfo>>> seats(int eventId);

  Future<Result<List<SeatInfo>>> setSeatMap(int eventId, List<SectionDraft> sections);

  Future<Result<void>> clearSeatMap(int eventId);

  Future<Result<ActivationChecklist>> checklist(int eventId);

  Future<Result<void>> activate(int eventId);

  Future<Result<OrganizerProfile>> profile();

  Future<Result<OrganizerProfile>> saveProfile(OrganizerProfile profile);

  Future<Result<EventAnalytics>> analytics(int eventId);
}

// ─── use cases ─────────────────────────────────────────────────────────────

/// O1: события организатора по статусам с цифрами продаж.
class GetOrganizerDashboard {
  GetOrganizerDashboard(this._repo, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final OrganizerEventsRepository _repo;
  final DateTime Function() _clock;

  Future<Result<List<DashboardEvent>>> call() async {
    final r = await _repo.myEvents();
    if (r case Err(:final failure)) return Err(failure);
    final now = _clock();
    final events = r.valueOrNull!;
    final rows = await Future.wait(events.map((e) async {
      final group = groupOf(e, now);
      final a = group == DashboardGroup.draft ? null : (await _repo.analytics(e.id)).valueOrNull;
      return DashboardEvent(event: e, group: group, analytics: a);
    }));
    rows.sort((a, b) => (a.event.startsAt ?? DateTime(9999)).compareTo(b.event.startsAt ?? DateTime(9999)));
    return Ok(rows);
  }

  /// §4.16: Upcoming, Active, Completed, Cancelled (+ черновики).
  static DashboardGroup groupOf(EventInfo e, DateTime now) => switch (e.status) {
        EventStatus.draft => DashboardGroup.draft,
        EventStatus.cancelled => DashboardGroup.cancelled,
        EventStatus.completed => DashboardGroup.completed,
        EventStatus.published => e.isRunning(now)
            ? DashboardGroup.active
            : (e.isUpcoming(now) ? DashboardGroup.upcoming : DashboardGroup.completed),
      };
}

class SaveEvent {
  const SaveEvent(this._repo);

  final OrganizerEventsRepository _repo;

  Future<Result<EventInfo>> call(EventDraft draft, {int? eventId}) async {
    final problem = draft.validate();
    if (problem != null) return Err(problem.toFailure());
    return eventId == null ? _repo.create(draft) : _repo.update(eventId, draft);
  }
}

enum EventAction { publish, unpublish, cancel, duplicate }

/// Публикация, снятие, отмена, дублирование (§4.2, UC12).
class ChangeEventState {
  const ChangeEventState(this._repo);

  final OrganizerEventsRepository _repo;

  Future<Result<EventInfo>> call(EventInfo e, EventAction action) async {
    switch (action) {
      case EventAction.publish:
        final types = await _repo.ticketTypes(e.id);
        if (types case Err(:final failure)) return Err(failure);
        if (types.valueOrNull!.where((t) => !t.hidden).isEmpty) {
          return const Err(ValidationFailure('Add at least one ticket type before publishing.', code: 'publishNeedsType'));
        }
        return _repo.publish(e.id);
      case EventAction.unpublish:
        return _repo.unpublish(e.id);
      case EventAction.cancel:
        if (e.status == EventStatus.cancelled) {
          return const Err(ValidationFailure('This event is already cancelled.', code: 'eventAlreadyCancelled'));
        }
        return _repo.cancel(e.id);
      case EventAction.duplicate:
        return _repo.duplicate(e.id);
    }
  }
}

class ManageTicketTypes {
  const ManageTicketTypes(this._repo);

  final OrganizerEventsRepository _repo;

  Future<Result<List<TicketTypeInfo>>> list(int eventId) => _repo.ticketTypes(eventId);

  Future<Result<TicketTypeInfo>> save(int eventId, TicketTypeDraft draft, {TicketTypeInfo? existing}) async {
    final problem = draft.validate(alreadySold: existing?.sold ?? 0);
    if (problem != null) return Err(problem.toFailure());
    return existing == null ? _repo.createTicketType(eventId, draft) : _repo.updateTicketType(existing.id, draft);
  }

  Future<Result<void>> hide(TicketTypeInfo t) => _repo.hideTicketType(t.id);
}

class ManageSeatMap {
  const ManageSeatMap(this._repo);

  final OrganizerEventsRepository _repo;

  Future<Result<List<SeatInfo>>> load(int eventId) => _repo.seats(eventId);

  Future<Result<List<SeatInfo>>> save(int eventId, List<SectionDraft> sections) async {
    if (sections.isEmpty) return const Err(ValidationFailure('Add at least one section.', code: 'sectionsEmpty'));
    final names = <String>{};
    for (final s in sections) {
      if (s.name.trim().isEmpty) return const Err(ValidationFailure('Every section needs a name.', code: 'sectionName'));
      if (!names.add(s.name.trim().toUpperCase())) {
        return Err(ValidationFailure('Section "${s.name}" is listed twice.', code: 'sectionTwice', args: {'name': s.name}));
      }
      if (s.rows < 1 || s.seatsPerRow < 1) {
        return const Err(ValidationFailure('Rows and seats per row must be at least 1.', code: 'rowsMin'));
      }
    }
    return _repo.setSeatMap(eventId, sections);
  }

  Future<Result<void>> clear(int eventId) => _repo.clearSeatMap(eventId);
}

/// O4: чек-лист и активация платных продаж для одного события (§4.5).
class PaidSalesActivation {
  const PaidSalesActivation(this._repo);

  final OrganizerEventsRepository _repo;

  Future<Result<ActivationChecklist>> checklist(int eventId) => _repo.checklist(eventId);

  Future<Result<void>> activate(int eventId, {required bool termsAccepted}) async {
    if (!termsAccepted) return const Err(ValidationFailure('Accept the paid-event terms first.', code: 'termsRequired'));
    final c = await _repo.checklist(eventId);
    if (c case Err(:final failure)) return Err(failure);
    final list = c.valueOrNull!;
    if (list.alreadyActivated) return const Err(ValidationFailure('Paid sales are already active.', code: 'salesAlreadyActive'));
    if (!list.hasPaidTicketType) return const Err(ValidationFailure('Add a paid ticket type first.', code: 'needPaidType'));
    if (!list.payoutVerified) return const Err(ValidationFailure('Connect a payout account first.', code: 'needPayout'));
    return _repo.activate(eventId);
  }
}

class ManageOrganizerProfile {
  const ManageOrganizerProfile(this._repo);

  final OrganizerEventsRepository _repo;

  static final _email = RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$');

  Future<Result<OrganizerProfile>> load() => _repo.profile();

  Future<Result<OrganizerProfile>> save(OrganizerProfile p) async {
    if (p.organizationName.trim().isEmpty) return const Err(ValidationFailure('Enter the organization name.', code: 'orgName'));
    if (p.contactEmail.isNotEmpty && !_email.hasMatch(p.contactEmail.trim())) {
      return const Err(ValidationFailure('Contact email is not valid.', code: 'contactEmail'));
    }
    return _repo.saveProfile(p);
  }
}

class GetManagedEvent {
  const GetManagedEvent(this._repo);

  final OrganizerEventsRepository _repo;

  Future<Result<EventInfo>> call(int id) => _repo.event(id);

  Future<Result<EventAnalytics>> analytics(int id) => _repo.analytics(id);

  /// id событий организатора — для входящих поддержки.
  Future<Result<List<int>>> ids() async {
    final r = await _repo.myEvents();
    return switch (r) {
      Ok(:final value) => Ok([for (final e in value) e.id]),
      Err(:final failure) => Err(failure),
    };
  }
}
