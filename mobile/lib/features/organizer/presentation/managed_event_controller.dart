import 'package:flutter/foundation.dart';

import '../../../core/error/failure.dart';
import '../../../core/error/result.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../domain/organizer_events_domain.dart';

/// Событие, открытое у организатора: шапка всех вкладок (M-B3…M-B8)
/// берёт его отсюда, чтобы при переходе между чипсами не мигала.
class ManagedEventController extends ChangeNotifier {
  ManagedEventController({required this._get, required this._change});

  final GetManagedEvent _get;
  final ChangeEventState _change;

  final Map<int, EventInfo> _events = {};
  bool isBusy = false;

  EventInfo? of(int id) => _events[id];

  void put(EventInfo e) {
    _events[e.id] = e;
    notifyListeners();
  }

  Future<void> ensure(int id, {bool force = false}) async {
    if (!force && _events.containsKey(id)) return;
    final r = await _get(id);
    if (r case Ok(:final value)) put(value);
  }

  /// Публикация, снятие, отмена, копия. Возвращает новое событие или ошибку.
  Future<(EventInfo?, Failure?)> act(EventInfo e, EventAction action) async {
    isBusy = true;
    notifyListeners();
    final r = await _change(e, action);
    isBusy = false;
    switch (r) {
      case Ok(:final value):
        if (action != EventAction.duplicate) {
          // Ответ сервера может прийти без части полей — перечитываем событие.
          await ensure(e.id, force: true);
        }
        notifyListeners();
        return (value, null);
      case Err(:final failure):
        notifyListeners();
        return (null, failure);
    }
  }
}
