import 'dart:ui';

import 'package:intl/intl.dart';

import '../../l10n/app_localizations.dart';

/// Форматы TicketTon: «22 дек 2026, 19:00», «3 420 000 ₸», 24-часовое время.
/// Язык берётся из `Intl.defaultLocale`, его выставляет AppearanceController.
abstract final class Fmt {
  static const thinSpace = '\u2009';

  static AppLocalizations get _l {
    final code = (Intl.defaultLocale ?? 'ru').split(RegExp('[_-]')).first;
    return lookupAppLocalizations(Locale(AppLocalizations.supportedLocales.any((l) => l.languageCode == code) ? code : 'ru'));
  }

  /// Убирает точки сокращений («дек.» → «дек»), как в макетах.
  static String _clean(String s) => s.replaceAll('.', '');

  static String count(int value) {
    final digits = value.abs().toString();
    final buf = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(thinSpace);
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  static String percent(int part, int total) => total <= 0 ? '0%' : '${(part * 100 / total).round()}%';

  static String time(DateTime t) => DateFormat('HH:mm').format(t);

  static String timeWithSeconds(DateTime t) => DateFormat('HH:mm:ss').format(t);

  /// «22 дек 2026, 19:00»
  static String dateTime(DateTime t) => _clean(DateFormat('d MMM y, HH:mm').format(t));

  /// «пт, 25 дек · 20:30» — над названием события в списках.
  static String dayStamp(DateTime t) => _clean(DateFormat('EEE, d MMM · HH:mm').format(t));

  /// «22 ноя, 14:12» — время заказа, сообщения.
  static String shortDateTime(DateTime t) => _clean(DateFormat('d MMM, HH:mm').format(t));

  /// «22 дек 2026»
  static String date(DateTime t) => _clean(DateFormat('d MMM y').format(t));

  /// «Сегодня, 19:00» или полная дата.
  static String relativeDay(DateTime t, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final sameDay = t.year == n.year && t.month == n.month && t.day == n.day;
    return sameDay ? '${_l.today}, ${time(t)}' : dateTime(t);
  }

  /// «4 мин назад».
  static String ago(DateTime t, {DateTime? now}) {
    final d = (now ?? DateTime.now()).difference(t);
    final l = _l;
    if (d.inMinutes < 1) return l.agoJustNow;
    if (d.inMinutes < 60) return l.agoMinutes(d.inMinutes);
    if (d.inHours < 24) return l.agoHours(d.inHours);
    return l.agoDays(d.inDays);
  }

  /// «4 500 ₸», «Бесплатно».
  static String money(num value, {bool freeWord = true}) {
    if (value == 0 && freeWord) return _l.free;
    return '${count(value.round())} ₸';
  }

  /// «4,1 млн ₸» для крупных итогов на плитках.
  static String moneyShort(num value) {
    if (value.abs() >= 1000000) {
      return '${NumberFormat('0.0').format(value / 1000000)} ${_l.millionShort} ₸';
    }
    return money(value, freeWord: false);
  }

  /// «22 дек 2026, 19:00 — 23:00»
  static String range(DateTime start, DateTime? end) {
    final day = dateTime(start);
    if (end == null) return day;
    final sameDay = end.year == start.year && end.month == start.month && end.day == start.day;
    return sameDay ? '$day — ${time(end)}' : '$day — ${dateTime(end)}';
  }

  /// Таймер удержания «09:41».
  static String countdown(Duration d) {
    final s = d.isNegative ? 0 : d.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }
}
