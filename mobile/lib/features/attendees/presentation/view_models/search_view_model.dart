import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../events/presentation/controllers/active_event_controller.dart';
import '../../domain/entities/attendee.dart';
import '../../domain/usecases/attendee_usecases.dart';
import '../../../../core/presentation/safe_notifier.dart';

enum SearchFilter { all, notArrived }

class SearchViewModel extends ChangeNotifier with SafeNotifier {
  SearchViewModel({
    required this._search,
    required this._active,
    this._checkIn,
    this.staffName = '',
    String initialQuery = '',
  })  : _query = initialQuery {
    if (initialQuery.trim().length >= SearchAttendees.minQueryLength) _run();
  }

  final SearchAttendees _search;
  final ActiveEventController _active;
  final CheckInAttendee? _checkIn;
  final String staffName;

  /// id гостя, у которого сейчас идёт отметка — кнопка показывает загрузку.
  String? checkingId;

  static const _debounce = Duration(milliseconds: 300);

  String _query;
  SearchFilter _filter = SearchFilter.all;
  List<Attendee> _results = const [];
  bool _isLoading = false;
  bool _hasSearched = false;
  Failure? _failure;
  Timer? _timer;
  int _requestId = 0;

  String get query => _query;
  SearchFilter get filter => _filter;
  bool get isLoading => _isLoading;
  Failure? get failure => _failure;
  String? get eventTitle => _active.event?.title;

  bool get isQueryTooShort => _query.trim().length < SearchAttendees.minQueryLength;

  /// C2: искали, ничего не нашли.
  bool get showNoMatches => _hasSearched && !_isLoading && _failure == null && _results.isEmpty;

  int get allCount => _results.length;
  int get notArrivedCount => _results.where((a) => a.notArrivedCount > 0).length;

  List<Attendee> get visible => switch (_filter) {
        SearchFilter.all => _results,
        SearchFilter.notArrived => _results.where((a) => a.notArrivedCount > 0).toList(),
      };

  void setQuery(String value) {
    _query = value;
    _timer?.cancel();
    if (isQueryTooShort) {
      _results = const [];
      _hasSearched = false;
      _failure = null;
      _isLoading = false;
      notifyListeners();
      return;
    }
    _timer = Timer(_debounce, _run);
    notifyListeners();
  }

  void setFilter(SearchFilter f) {
    _filter = f;
    notifyListeners();
  }

  Future<void> refresh() => _run();

  Future<void> _run() async {
    final event = _active.event;
    if (event == null || isQueryTooShort) return;
    final id = ++_requestId;
    _isLoading = true;
    _failure = null;
    notifyListeners();

    final result = await _search(eventId: event.id, query: _query);
    if (id != _requestId) return; // пришёл ответ на устаревший запрос

    _isLoading = false;
    _hasSearched = true;
    switch (result) {
      case Ok(:final value):
        _results = value;
      case Err(:final failure):
        _failure = failure;
    }
    notifyListeners();
  }

  /// A7 «Отметить вход»: все действительные билеты заказа гостя.
  Future<Failure?> checkIn(Attendee a) async {
    final event = _active.event;
    final use = _checkIn;
    if (event == null || use == null || checkingId != null) return null;
    final ids = [for (final t in a.tickets) if (t.canCheckIn) t.id];
    checkingId = a.id;
    notifyListeners();
    final r = await use(eventId: event.id, attendee: a, ticketIds: ids, staffName: staffName);
    checkingId = null;
    switch (r) {
      case Ok(:final value):
        _results = [for (final x in _results) x.id == value.id ? value : x];
        _active.adjustCheckedIn(ids.length);
        notifyListeners();
        return null;
      case Err(:final failure):
        notifyListeners();
        return failure;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
