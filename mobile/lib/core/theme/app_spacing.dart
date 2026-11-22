import 'package:flutter/widgets.dart';

/// Отступы из §01 и §03 спеки.
abstract final class AppSpacing {
  // боковые поля по семействам экранов
  static const sideLight = 24.0; // A4 A5 B3 C3 C4
  static const sideList = 24.0; // A2 A3 C1 C2
  static const sideDark = 22.0; // B1 B2 B4–B10
  static const sideSignIn = 30.0;
  static const sheetInset = 18.0;

  // вертикальные шаги
  static const tight = 6.0;
  static const related = 10.0;
  static const block = 22.0;
  static const section = 30.0;
  static const statement = 44.0;

  /// Отступ сверху стандартного экрана под статус-баром.
  static const topStandard = 16.0;

  /// Нижний отступ 42 = 34 home indicator + 8.
  static const bottomClearance = 8.0;

  static const actionGap = 10.0;

  static EdgeInsets screen(double side) =>
      EdgeInsets.fromLTRB(side, topStandard, side, bottomClearance);
}

abstract final class AppSizes {
  static const minTap = 44.0;
  static const buttonResult = 56.0;
  static const buttonPrimary = 50.0;
  static const buttonSecondary = 48.0;
  static const buttonGhost = 44.0;
  static const textField = 46.0;
  static const backBox = 30.0;
  static const verdictMark = 54.0;
  static const tabBar = 52.0;
}
