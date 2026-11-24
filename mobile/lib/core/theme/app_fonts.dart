import 'package:flutter/painting.dart';

abstract final class AppFonts {
  static const family = 'Inter';

  /// Коды билетов, промокоды, номера заказов.
  static const mono = 'JetBrainsMono';

  static const tabular = <FontFeature>[FontFeature.tabularFigures()];
}
