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
}
