import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../auth/presentation/controllers/session_controller.dart';
import '../../../events/presentation/controllers/active_event_controller.dart';
import '../../domain/entities/attendee.dart';
import '../../domain/usecases/attendee_usecases.dart';

class AttendeeViewModel extends ChangeNotifier {
  AttendeeViewModel({
    required this.attendeeId,
    required GetAttendee getAttendee,
    required this._checkIn,
    required this._undo,
    required this._active,
    required this._session,
  })  : _get = getAttendee;

  final String attendeeId;
  final GetAttendee _get;
  final CheckInAttendee _checkIn;
  final UndoAttendeeCheckIn _undo;
  final ActiveEventController _active;
  final SessionController _session;

  Attendee? _attendee;
  bool _isLoading = true;
  bool _isBusy = false;
  Failure? _failure;

  Attendee? get attendee => _attendee;
  bool get isLoading => _isLoading;
  bool get isBusy => _isBusy;
  Failure? get failure => _failure;
  String get staffName => _session.session?.shortName ?? 'You';

  int? get _eventId => _active.event?.id;

  Future<void> load() async {
    final eventId = _eventId;
    if (eventId == null) return;
    _isLoading = true;
    notifyListeners();
    final r = await _get(eventId: eventId, attendeeId: attendeeId);
    switch (r) {
      case Ok(:final value):
        _attendee = value;
      case Err(:final failure):
        _failure = failure;
    }
    _isLoading = false;
    notifyListeners();
  }

  /// null — успех. При отказе сервера карточка перечитывается: часть
  /// билетов могла пройти до отказа.
  Future<Failure?> checkIn(List<String> ticketIds) async {
    final a = _attendee;
    final eventId = _eventId;
    if (a == null || eventId == null || _isBusy) return null;
    _isBusy = true;
    notifyListeners();
    final before = a.notArrivedCount;
    final r = await _checkIn(eventId: eventId, attendee: a, ticketIds: ticketIds, staffName: staffName);
    _isBusy = false;
    switch (r) {
      case Ok(:final value):
        _attendee = value;
        _active.adjustCheckedIn(before - value.notArrivedCount);
        notifyListeners();
        return null;
      case Err(:final failure):
        notifyListeners();
        await load();
        return failure;
    }
  }

  Future<Failure?> undo(String ticketId, String reason) async {
    final eventId = _eventId;
    if (eventId == null) return null;
    final r = await _undo(
      eventId: eventId,
      attendeeId: attendeeId,
      ticketId: ticketId,
      reason: reason,
      staffName: staffName,
    );
    switch (r) {
      case Ok(:final value):
        _attendee = value;
        _active.adjustCheckedIn(-1);
        notifyListeners();
        return null;
      case Err(:final failure):
        return failure;
    }
  }
}
