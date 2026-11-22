import 'package:intl/intl.dart';

/// Форматы из §08 спеки: тонкий пробел между тысячами, 24-часовое время,
/// секунды только на экранах результата.
abstract final class Fmt {
  static const thinSpace = ' ';

  static String count(int value) {
    final digits = value.abs().toString();
    final buf = StringBuffer(value < 0 ? '-' : '');
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(thinSpace);
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  static String percent(int part, int total) =>
      total <= 0 ? '0%' : '${(part * 100 / total).round()}%';

  static String time(DateTime t) => DateFormat('HH:mm').format(t);

  static String timeWithSeconds(DateTime t) => DateFormat('HH:mm:ss').format(t);

  /// «SAT 12 SEP · 14:00»
  static String dayStamp(DateTime t) =>
      DateFormat('EEE d MMM · HH:mm').format(t).toUpperCase();

  /// «Fri 25 Sep, 20:30»
  static String dateTime(DateTime t) => DateFormat('EEE d MMM, HH:mm').format(t);

  /// «29 Aug 14:02»
  static String shortDateTime(DateTime t) => DateFormat('d MMM HH:mm').format(t);

  /// «Today, 19:00» / «Sat 12 Sep, 14:00»
  static String relativeDay(DateTime t, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final sameDay = t.year == n.year && t.month == n.month && t.day == n.day;
    return sameDay ? 'Today, ${time(t)}' : dateTime(t);
  }

  /// «4 min ago», «32 minutes ago» в стиле макетов.
  static String ago(DateTime t, {DateTime? now}) {
    final d = (now ?? DateTime.now()).difference(t);
    if (d.inSeconds < 60) return '${d.inSeconds.clamp(0, 59)} s ago';
    if (d.inMinutes < 60) return '${d.inMinutes} min ago';
    if (d.inHours < 24) return '${d.inHours} h ago';
    return '${d.inDays} d ago';
  }

  /// «4 500 ₸», «Free» — суммы в KZT (§7 SRS).
  static String money(num value, {bool freeWord = true}) {
    if (value == 0 && freeWord) return 'Free';
    final whole = value.round();
    return '${count(whole)} ₸';
  }

  /// «4.1M ₸» для крупных итогов на плитках.
  static String moneyShort(num value) {
    final v = value.abs();
    if (v >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}M ₸';
    return money(value, freeWord: false);
  }

  /// «Sat 12 Sep 2026 · 19:00 — 23:00»
  static String range(DateTime start, DateTime? end) {
    final day = DateFormat('EEE d MMM y · HH:mm').format(start);
    if (end == null) return day;
    final sameDay = end.year == start.year && end.month == start.month && end.day == start.day;
    return sameDay ? '$day — ${time(end)}' : '$day — ${DateFormat('d MMM HH:mm').format(end)}';
  }

  /// «19 Dec 2026»
  static String date(DateTime t) => DateFormat('d MMM y').format(t);

  /// Длительность таймера удержания «09:41».
  static String countdown(Duration d) {
    final s = d.isNegative ? 0 : d.inSeconds;
    return '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';
  }
}
