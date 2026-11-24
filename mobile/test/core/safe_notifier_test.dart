import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/presentation/safe_notifier.dart';

class _Vm extends ChangeNotifier with SafeNotifier {
  void late() => notifyListeners();
}

void main() {
  test('notifying after dispose is ignored instead of throwing', () {
    final vm = _Vm()..dispose();
    expect(vm.isDisposed, isTrue);
    expect(vm.late, returnsNormally);
  });
}
