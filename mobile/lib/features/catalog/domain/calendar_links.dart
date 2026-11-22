import '../../../shared/domain/entities/event_info.dart';

/// Ссылки «добавить в календарь» без доступа к календарю пользователя
/// (§4.11): Google и Outlook открываются в браузере с заполненной формой.
abstract final class CalendarLinks {
  static String _stamp(DateTime t) {
    final u = t.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${u.year}${two(u.month)}${two(u.day)}T${two(u.hour)}${two(u.minute)}${two(u.second)}Z';
  }

  static Uri? google(EventInfo e) {
    final start = e.startsAt;
    if (start == null) return null;
    final end = e.endsAt ?? start.add(const Duration(hours: 2));
    return Uri.https('calendar.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': e.title,
      'dates': '${_stamp(start)}/${_stamp(end)}',
      'location': e.fullAddress,
      'details': e.description ?? '',
    });
  }

  static Uri? outlook(EventInfo e) {
    final start = e.startsAt;
    if (start == null) return null;
    final end = e.endsAt ?? start.add(const Duration(hours: 2));
    return Uri.https('outlook.live.com', '/calendar/0/deeplink/compose', {
      'subject': e.title,
      'startdt': start.toUtc().toIso8601String(),
      'enddt': end.toUtc().toIso8601String(),
      'location': e.fullAddress,
      'body': e.description ?? '',
      'path': '/calendar/action/compose',
      'rru': 'addevent',
    });
  }
}
