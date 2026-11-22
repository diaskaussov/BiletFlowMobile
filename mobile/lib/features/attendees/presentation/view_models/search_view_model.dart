import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../events/presentation/controllers/active_event_controller.dart';
import '../../domain/entities/attendee.dart';
import '../../domain/usecases/attendee_usecases.dart';

enum SearchFilter { all, notArrived }

class SearchViewModel extends ChangeNotifier {
  SearchViewModel({
    required this._search,
    required this._active,
    String initialQuery = '',
  })  : _query = initialQuery {
    if (initialQuery.trim().length >= SearchAttendees.minQueryLength) _run();
  }

  final SearchAttendees _search;
  final ActiveEventController _active;

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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
