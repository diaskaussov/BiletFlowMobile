import 'dart:typed_data';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/event_info.dart';

// ─── entities ──────────────────────────────────────────────────────────────

enum WhenFilter { any, today, weekend, next30 }

enum PriceFilter { any, free, under5000 }

/// Фильтры W1. Сервер их не поддерживает — применяются на телефоне.
class EventFilter {
  const EventFilter({
    this.query = '',
    this.city,
    this.category,
    this.when = WhenFilter.any,
    this.price = PriceFilter.any,
  });

  final String query;
  final String? city;
  final String? category;
  final WhenFilter when;
  final PriceFilter price;

  bool get isEmpty =>
      query.trim().isEmpty && city == null && category == null && when == WhenFilter.any && price == PriceFilter.any;

  int get activeCount =>
      [city, category].whereType<String>().length +
      (when == WhenFilter.any ? 0 : 1) +
      (price == PriceFilter.any ? 0 : 1);

  EventFilter copyWith({
    String? query,
    String? Function()? city,
    String? Function()? category,
    WhenFilter? when,
    PriceFilter? price,
  }) =>
      EventFilter(
        query: query ?? this.query,
        city: city == null ? this.city : city(),
        category: category == null ? this.category : category(),
        when: when ?? this.when,
        price: price ?? this.price,
      );
}

/// Карточка афиши: событие и самая низкая цена среди продаваемых типов.
class EventListing {
  const EventListing({required this.event, this.minPrice, this.hasTickets = true});

  final EventInfo event;

  /// null — цены неизвестны (типы не загрузились).
  final double? minPrice;
  final bool hasTickets;
}

/// Проверенный сервером промокод (W3, §4.14).
class PromoValidation {
  const PromoValidation({
    required this.code,
    required this.discountType,
    required this.discountValue,
    this.eventId,
    this.campaignName,
  });

  final String code;
  final DiscountType discountType;
  final double discountValue;
  final int? eventId;
  final String? campaignName;

  String get label => discountType == DiscountType.percentage
      ? '${discountValue.toStringAsFixed(discountValue % 1 == 0 ? 0 : 1)}% off'
      : '${discountValue.round()} ₸ off';

  double discountFor(double price) => switch (discountType) {
        DiscountType.percentage => (price * discountValue / 100).clamp(0, price),
        DiscountType.fixed => discountValue.clamp(0, price),
      };
}

class EventPageData {
  const EventPageData({required this.event, required this.ticketTypes});

  final EventInfo event;

  /// Только видимые типы, в порядке цены.
  final List<TicketTypeInfo> ticketTypes;
}

// ─── repository ────────────────────────────────────────────────────────────

abstract interface class CatalogRepository {
  Future<Result<List<EventInfo>>> publicEvents();

  Future<Result<EventInfo>> event(int id);

  Future<Result<List<TicketTypeInfo>>> ticketTypes(int eventId);

  Future<Result<PromoValidation>> validatePromo(String code);

  /// `.ics` события (§4.11).
  Future<Result<Uint8List>> calendarFile(int eventId);
}

// ─── use cases ─────────────────────────────────────────────────────────────

/// W1: афиша — только будущие опубликованные публичные события с ценой «от».
class BrowseEvents {
  BrowseEvents(this._repo, {DateTime Function()? clock}) : _clock = clock ?? DateTime.now;

  final CatalogRepository _repo;
  final DateTime Function() _clock;

  Future<Result<List<EventListing>>> call() async {
    final r = await _repo.publicEvents();
    if (r case Err(:final failure)) return Err(failure);
    final now = _clock();
    final events = r.valueOrNull!
        .where((e) =>
            e.status == EventStatus.published &&
            e.visibility == EventVisibility.public &&
            (e.isUpcoming(now) || e.isRunning(now)))
        .toList()
      ..sort((a, b) => (a.startsAt ?? DateTime(9999)).compareTo(b.startsAt ?? DateTime(9999)));
    final listings = await Future.wait(events.map((e) async {
      final types = (await _repo.ticketTypes(e.id)).valueOrNull;
      if (types == null) return EventListing(event: e);
      final onSale = types.where((t) => t.isOnSale(now)).toList();
      return EventListing(
        event: e,
        minPrice: onSale.isEmpty ? null : onSale.map((t) => t.price).reduce((a, b) => a < b ? a : b),
        hasTickets: onSale.isNotEmpty,
      );
    }));
    return Ok(listings);
  }
}

/// Применение фильтров W1 — чистая функция, покрыта тестами.
List<EventListing> applyFilter(List<EventListing> all, EventFilter f, DateTime now) {
  final q = f.query.trim().toLowerCase();
  final today = DateTime(now.year, now.month, now.day);
  bool when(DateTime? start) {
    if (f.when == WhenFilter.any) return true;
    if (start == null) return false;
    final day = DateTime(start.year, start.month, start.day);
    return switch (f.when) {
      WhenFilter.any => true,
      WhenFilter.today => day == today,
      WhenFilter.weekend => () {
          final saturday = today.add(Duration(days: (DateTime.saturday - today.weekday) % 7));
          return day == saturday || day == saturday.add(const Duration(days: 1));
        }(),
      WhenFilter.next30 => !day.isBefore(today) && day.isBefore(today.add(const Duration(days: 30))),
    };
  }

  return all.where((l) {
    final e = l.event;
    if (q.isNotEmpty) {
      final hay = [e.title, e.venueName, e.city, e.category, e.organizerName]
          .whereType<String>()
          .join(' ')
          .toLowerCase();
      if (!hay.contains(q)) return false;
    }
    if (f.city != null && e.city?.toLowerCase() != f.city!.toLowerCase()) return false;
    if (f.category != null && e.category?.toLowerCase() != f.category!.toLowerCase()) return false;
    if (!when(e.startsAt)) return false;
    switch (f.price) {
      case PriceFilter.any:
        break;
      case PriceFilter.free:
        if (l.minPrice != 0) return false;
      case PriceFilter.under5000:
        if (l.minPrice == null || l.minPrice! >= 5000) return false;
    }
    return true;
  }).toList();
}

/// W2: событие и видимые типы билетов.
class GetEventPage {
  const GetEventPage(this._repo);

  final CatalogRepository _repo;

  Future<Result<EventPageData>> call(int eventId) async {
    final results = await Future.wait([_repo.event(eventId), _repo.ticketTypes(eventId)]);
    final e = results[0] as Result<EventInfo>;
    final t = results[1] as Result<List<TicketTypeInfo>>;
    if (e case Err(:final failure)) return Err(failure);
    if (t case Err(:final failure)) return Err(failure);
    final types = t.valueOrNull!.where((x) => !x.hidden).toList()
      ..sort((a, b) => a.price.compareTo(b.price));
    return Ok(EventPageData(event: e.valueOrNull!, ticketTypes: types));
  }
}

/// Событие и его `.ics` — для календаря на экранах заказа и билета.
class GetEvent {
  const GetEvent(this._repo);

  final CatalogRepository _repo;

  Future<Result<EventInfo>> call(int id) => _repo.event(id);

  Future<Result<Uint8List>> calendar(int id) => _repo.calendarFile(id);
}

/// W3: промокод проверяется сервером и должен относиться к этому событию.
class ApplyPromo {
  const ApplyPromo(this._repo);

  final CatalogRepository _repo;

  Future<Result<PromoValidation>> call({required String code, required int eventId}) async {
    final c = code.trim().toUpperCase();
    if (c.isEmpty) return const Err(ValidationFailure('Enter a promo code.', code: 'promoEmpty'));
    final r = await _repo.validatePromo(c);
    return switch (r) {
      Ok(:final value) when value.eventId != null && value.eventId != eventId =>
        const Err(ValidationFailure('This code is for a different event.', code: 'promoOtherEvent')),
      Ok() => r,
      Err(failure: ServerFailure(:final message)) => Err(ValidationFailure(message)),
      Err() => r,
    };
  }
}

/// Ссылка Campaign QR → событие и код. Формат сервера:
/// `…/events/{id}?promo=CODE`; старый вид `/e/{id}` тоже понимаем.
({int? eventId, String? code}) parseCampaignLink(String raw) {
  final uri = Uri.tryParse(raw.trim());
  if (uri == null) return (eventId: null, code: null);
  final code = uri.queryParameters['promo'] ?? uri.queryParameters['code'] ?? uri.queryParameters['c'];
  final segments = uri.pathSegments;
  int? eventId;
  for (var i = 0; i < segments.length - 1; i++) {
    if (segments[i] == 'events' || segments[i] == 'e') {
      eventId = int.tryParse(segments[i + 1]);
    }
  }
  return (eventId: eventId, code: code);
}
