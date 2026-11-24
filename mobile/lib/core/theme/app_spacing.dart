import 'package:flutter/widgets.dart';

/// Отступы TicketTon: поля экрана 20, шаг 4.
abstract final class AppSpacing {
  static const side = 20.0;

  // Старые имена семейств экранов — все поля теперь одинаковые.
  static const sideLight = side;
  static const sideList = side;
  static const sideDark = side;
  static const sideSignIn = 24.0;
  static const sheetInset = side;

  static const tight = 4.0;
  static const related = 8.0;
  static const block = 16.0;
  static const section = 24.0;
  static const statement = 32.0;

  static const topStandard = 4.0;

  /// Отступ под нижней навигацией и кнопками.
  static const bottomClearance = 12.0;

  static const actionGap = 12.0;

  static EdgeInsets screen([double side = AppSpacing.side]) =>
      EdgeInsets.fromLTRB(side, topStandard, side, bottomClearance);
}

abstract final class AppRadius {
  static const xs = 6.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const field = 14.0;
  static const card = 16.0;
  static const button = 16.0;
  static const buttonLarge = 18.0;
  static const panel = 24.0;
  static const result = 28.0;
  static const pill = 999.0;
}

abstract final class AppSizes {
  static const minTap = 44.0;
  static const buttonLarge = 64.0;
  static const buttonResult = 64.0;
  static const buttonPrimary = 56.0;
  static const buttonSecondary = 56.0;
  static const buttonSmall = 40.0;
  static const buttonGhost = 44.0;
  static const textField = 56.0;
  static const backBox = 44.0;
  static const nav = 64.0;
  static const verdictMark = 54.0;
}
