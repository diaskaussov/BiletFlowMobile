import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/error/result.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/request_guard.dart';
import '../../../core/utils/json_reader.dart';
import '../../../shared/data/models.dart';
import '../../../shared/domain/entities/commerce.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../../../shared/domain/entities/insights.dart';
import '../../../shared/domain/entities/people.dart';
import '../domain/organizer_events_domain.dart';
import '../domain/organizer_operations_domain.dart';

String? _iso(DateTime? t) => t?.toIso8601String().split('.').first;

Map<String, dynamic> _eventBody(EventDraft d) => {
      'title': d.title.trim(),
      'description': d.description.trim(),
      'category': d.category.trim(),
      if (d.imageUrl.trim().isNotEmpty) 'imageUrl': d.imageUrl.trim(),
      'venueName': d.venueName.trim(),
      'venueAddress': d.venueAddress.trim(),
      'city': d.city.trim(),
      'eventDate': ?_iso(d.startsAt),
      'eventEndDate': ?_iso(d.endsAt),
      'registrationOpenDate': ?_iso(d.registrationOpensAt),
      'registrationCloseDate': ?_iso(d.registrationClosesAt),
      'capacity': d.capacity,
      'visibility': d.visibility.wire,
      'assignedSeating': d.assignedSeating,
    };

Map<String, dynamic> _ticketTypeBody(TicketTypeDraft d) => {
      'name': d.name.trim(),
      'description': d.description.trim(),
      'price': d.price,
      'quantity': d.quantity,
      'free': d.isFree,
      'maxPerOrder': ?d.maxPerOrder,
      'salesStart': ?_iso(d.salesStart),
      'salesEnd': ?_iso(d.salesEnd),
    };

class OrganizerEventsRepositoryImpl implements OrganizerEventsRepository {
  const OrganizerEventsRepositoryImpl(this._api);

  final ApiClient _api;

  Future<Result<EventInfo>> _event(Future<dynamic> Function() call) =>
      guard(() async => Models.event(jsonObject(await call())));

  @override
  Future<Result<List<EventInfo>>> myEvents() =>
      guard(() async => jsonList(await _api.get('/api/events/my')).map(Models.event).toList());

  @override
  Future<Result<EventInfo>> event(int id) => _event(() => _api.get('/api/events/$id'));

  @override
  Future<Result<EventInfo>> create(EventDraft d) => _event(() => _api.post('/api/events', body: _eventBody(d)));

  @override
  Future<Result<EventInfo>> update(int id, EventDraft d) =>
      _event(() => _api.put('/api/events/$id', body: _eventBody(d)));

  @override
  Future<Result<EventInfo>> publish(int id) => _event(() => _api.post('/api/events/$id/publish'));

  @override
  Future<Result<EventInfo>> unpublish(int id) => _event(() => _api.post('/api/events/$id/unpublish'));

  @override
  Future<Result<EventInfo>> cancel(int id) => _event(() => _api.post('/api/events/$id/cancel'));

  @override
  Future<Result<EventInfo>> duplicate(int id) => _event(() => _api.post('/api/events/$id/duplicate'));

  @override
  Future<Result<List<TicketTypeInfo>>> ticketTypes(int eventId) => guard(() async =>
      jsonList(await _api.get('/api/events/$eventId/ticket-types/all')).map(Models.ticketType).toList());

  @override
  Future<Result<TicketTypeInfo>> createTicketType(int eventId, TicketTypeDraft d) => guard(() async =>
      Models.ticketType(jsonObject(await _api.post('/api/events/$eventId/ticket-types', body: _ticketTypeBody(d)))));

  @override
  Future<Result<TicketTypeInfo>> updateTicketType(int id, TicketTypeDraft d) => guard(() async =>
      Models.ticketType(jsonObject(await _api.put('/api/ticket-types/$id', body: _ticketTypeBody(d)))));

  @override
  Future<Result<void>> hideTicketType(int id) => guard(() => _api.post('/api/ticket-types/$id/hide'));

  @override
  Future<Result<List<SeatInfo>>> seats(int eventId) =>
      guard(() async => jsonList(await _api.get('/api/events/$eventId/seats')).map(Models.seat).toList());

  @override
  Future<Result<List<SeatInfo>>> setSeatMap(int eventId, List<SectionDraft> sections) => guard(() async {
        final body = {
          'sections': [
            for (final s in sections)
              {
                'name': s.name.trim(),
                'ticketTypeId': s.ticketTypeId,
                'rowCount': s.rows,
                'seatsPerRow': s.seatsPerRow,
              },
          ],
        };
        return jsonList(await _api.put('/api/events/$eventId/seats', body: body)).map(Models.seat).toList();
      });

  @override
  Future<Result<void>> clearSeatMap(int eventId) => guard(() => _api.delete('/api/events/$eventId/seats'));

  @override
  Future<Result<ActivationChecklist>> checklist(int eventId) => guard(() async =>
      Models.checklist(jsonObject(await _api.get('/api/events/$eventId/activation-checklist'))));

  @override
  Future<Result<void>> activate(int eventId) => guard(() => _api.post('/api/events/$eventId/activate'));

  @override
  Future<Result<OrganizerProfile>> profile() =>
      guard(() async => Models.organizerProfile(jsonObject(await _api.get('/api/organizer/profile'))));

  @override
  Future<Result<OrganizerProfile>> saveProfile(OrganizerProfile p) => guard(() async {
        await _api.post('/api/organizer/profile', body: {
          'organizationName': p.organizationName.trim(),
          'description': p.description.trim(),
          'contactEmail': p.contactEmail.trim(),
          'contactPhone': p.contactPhone.trim(),
          'website': p.website.trim(),
          'payoutBankName': p.payoutBankName.trim(),
          'payoutAccountNumber': p.payoutAccountNumber.trim(),
          'payoutAccountHolder': p.payoutAccountHolder.trim(),
        });
        return Models.organizerProfile(jsonObject(await _api.get('/api/organizer/profile')));
      });

  @override
  Future<Result<EventAnalytics>> analytics(int eventId) =>
      guard(() async => Models.analytics(jsonObject(await _api.get('/api/analytics/events/$eventId'))));
}

/// Коды кампаний, созданных на этом устройстве. В списке кампаний сервер
/// код не отдаёт — без этого организатор не увидел бы код и QR.
class CampaignCodeStore {
  const CampaignCodeStore(this._prefs);

  final SharedPreferencesAsync _prefs;

  static String _key(int id) => 'campaign.code.$id';

  Future<void> save(int id, String code) => _prefs.setString(_key(id), code);

  Future<String?> code(int id) => _prefs.getString(_key(id));
}

class OrganizerOperationsRepositoryImpl implements OrganizerOperationsRepository {
  const OrganizerOperationsRepositoryImpl(this._api, this._codes);

  final ApiClient _api;
  final CampaignCodeStore _codes;

  @override
  Future<Result<List<OrderInfo>>> orders(int eventId) =>
      guard(() async => jsonList(await _api.get('/api/orders/event/$eventId')).map(Models.order).toList());

  @override
  Future<Result<List<TicketInfo>>> tickets(int eventId) =>
      guard(() async => jsonList(await _api.get('/api/tickets/event/$eventId')).map(Models.ticket).toList());

  @override
  Future<Result<void>> refund(int orderId, String reason) =>
      guard(() => _api.post('/api/orders/$orderId/refund', body: {'reason': reason}));

  @override
  Future<Result<List<AuditEntry>>> timeline(int eventId) => guard(() async =>
      jsonList(await _api.get('/api/analytics/events/$eventId/timeline')).map(Models.audit).toList());

  @override
  Future<Result<CheckInOverview>> checkInOverview(int eventId) => guard(() async {
        final j = jsonObject(await _api.get('/api/checkin/stats/$eventId'));
        return CheckInOverview(
          registered: j.integer(['totalRegistered']) ?? 0,
          checkedIn: j.integer(['checkedIn']) ?? 0,
          notCheckedIn: j.integer(['notCheckedIn']) ?? 0,
          cancelled: j.integer(['cancelled']) ?? 0,
          refunded: j.integer(['refunded']) ?? 0,
          reversed: j.integer(['reversed']) ?? 0,
          byTicketType: [
            for (final t in jsonList(j['byTicketType']))
              (
                name: t.str(['name']) ?? 'Ticket',
                registered: t.integer(['registered']) ?? 0,
                checkedIn: t.integer(['checkedIn']) ?? 0,
              ),
          ],
          recent: [
            for (final r in jsonList(j['recentCheckIns']))
              (
                who: r.str(['attendeeName', 'name']) ?? 'Attendee',
                at: r.date(['checkedInAt', 'timestamp'], naiveIsUtc: true),
                by: r.str(['checkedInBy']),
              ),
          ],
        );
      });

  @override
  Future<Result<List<CampaignInfo>>> campaigns(int eventId) => guard(() async {
        final list = jsonList(await _api.get('/api/promo/campaigns/event/$eventId')).map(Models.campaign).toList();
        return [
          for (final c in list)
            c.code != null
                ? c
                : CampaignInfo(
                    id: c.id,
                    name: c.name,
                    code: await _codes.code(c.id),
                    eventId: c.eventId,
                    eventTitle: c.eventTitle,
                    discountType: c.discountType,
                    discountValue: c.discountValue,
                    maxRedemptions: c.maxRedemptions,
                    redemptions: c.redemptions,
                    validFrom: c.validFrom,
                    validTo: c.validTo,
                    active: c.active,
                  ),
        ];
      });

  @override
  Future<Result<CreatedCampaign>> createCampaign(int eventId, CampaignDraft d) => guard(() async {
        final j = jsonObject(await _api.post('/api/promo/campaigns', body: {
          'eventId': eventId,
          'name': d.name.trim(),
          'discountType': d.discountType.wire,
          'discountValue': d.discountValue,
          'maxRedemptions': ?d.maxRedemptions,
          'validFrom': ?_iso(d.validFrom),
          'validTo': ?_iso(d.validTo),
        }));
        final created = CreatedCampaign(
          id: j.integer(['campaignId', 'id']) ?? 0,
          code: j.str(['promoCode', 'code']) ?? '',
          link: j.str(['campaignLink', 'link']) ?? '/events/$eventId',
        );
        if (created.code.isNotEmpty) await _codes.save(created.id, created.code);
        return created;
      });

  @override
  Future<Result<void>> deactivateCampaign(int id) => guard(() => _api.post('/api/promo/campaigns/$id/deactivate'));

  @override
  Future<Result<List<StaffAssignment>>> staff(int eventId) =>
      guard(() async => jsonList(await _api.get('/api/staff/event/$eventId')).map(Models.staff).toList());

  @override
  Future<Result<StaffAssignment>> assignStaff(int eventId, int userId) => guard(() async =>
      Models.staff(jsonObject(await _api.post('/api/staff/assign', body: {'eventId': eventId, 'userId': userId}))));

  @override
  Future<Result<void>> removeStaff(int assignmentId) => guard(() => _api.delete('/api/staff/$assignmentId'));
}
