import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/formatters.dart';

void main() {
  test('thin space as thousands separator (§08)', () {
    expect(Fmt.count(612), '612');
    expect(Fmt.count(1043), '1 043');
    expect(Fmt.count(1234567), '1 234 567');
    expect(Fmt.count(0), '0');
  });

  test('percent', () {
    expect(Fmt.percent(612, 1043), '59%');
    expect(Fmt.percent(1, 0), '0%');
  });

  test('times are 24-hour', () {
    final t = DateTime(2026, 11, 22, 19, 43, 2);
    expect(Fmt.time(t), '19:43');
    expect(Fmt.timeWithSeconds(t), '19:43:02');
    expect(Fmt.relativeDay(t, now: DateTime(2026, 11, 22, 10)), 'Today, 19:43');
  });
}
