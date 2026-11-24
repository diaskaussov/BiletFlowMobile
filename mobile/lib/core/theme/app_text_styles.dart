import 'package:flutter/painting.dart';

import 'app_fonts.dart';

/// Типографика TicketTon: Inter 400–800. Цвет не задан — его даёт палитра
/// (`context.colors`), чтобы стили работали в светлой и тёмной теме.
abstract final class AppText {
  // — крупные —
  /// Заголовок карточки результата: «Проходите», «Билет уже использован».
  static const resultTitle = TextStyle(fontFamily: AppFonts.family, fontSize: 32, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.5);
  static const heroMetric = TextStyle(fontFamily: AppFonts.family, fontSize: 32, fontWeight: FontWeight.w700, height: 1.1, letterSpacing: -0.5, fontFeatures: AppFonts.tabular);
  static const screenTitle = TextStyle(fontFamily: AppFonts.family, fontSize: 28, fontWeight: FontWeight.w700, height: 1.15, letterSpacing: -0.3);
  static const brand = TextStyle(fontFamily: AppFonts.family, fontSize: 24, fontWeight: FontWeight.w800, height: 1.1);
  static const statNumeral = TextStyle(fontFamily: AppFonts.family, fontSize: 24, fontWeight: FontWeight.w700, height: 1.1, fontFeatures: AppFonts.tabular);
  static const personName = TextStyle(fontFamily: AppFonts.family, fontSize: 22, fontWeight: FontWeight.w700, height: 1.2);

  // — заголовки —
  static const headerTitle = TextStyle(fontFamily: AppFonts.family, fontSize: 18, fontWeight: FontWeight.w700, height: 1.25);
  static const listTitle = TextStyle(fontFamily: AppFonts.family, fontSize: 16, fontWeight: FontWeight.w600, height: 1.3);
  static const sectionLabel = TextStyle(fontFamily: AppFonts.family, fontSize: 16, fontWeight: FontWeight.w700, height: 1.3);
  static const cardTitle = TextStyle(fontFamily: AppFonts.family, fontSize: 15, fontWeight: FontWeight.w700, height: 1.3);

  // — кнопки —
  static const buttonLarge = TextStyle(fontFamily: AppFonts.family, fontSize: 18, fontWeight: FontWeight.w700);
  static const buttonPrimary = TextStyle(fontFamily: AppFonts.family, fontSize: 16, fontWeight: FontWeight.w700);
  static const buttonSecondary = TextStyle(fontFamily: AppFonts.family, fontSize: 16, fontWeight: FontWeight.w600);
  static const buttonSmall = TextStyle(fontFamily: AppFonts.family, fontSize: 14, fontWeight: FontWeight.w600);
  static const tabItem = TextStyle(fontFamily: AppFonts.family, fontSize: 10, fontWeight: FontWeight.w600);
  static const chip = TextStyle(fontFamily: AppFonts.family, fontSize: 14, fontWeight: FontWeight.w600);

  // — текст —
  static const input = TextStyle(fontFamily: AppFonts.family, fontSize: 16, fontWeight: FontWeight.w400);
  static const body = TextStyle(fontFamily: AppFonts.family, fontSize: 15, fontWeight: FontWeight.w400, height: 1.45);
  static const bodySecondary = TextStyle(fontFamily: AppFonts.family, fontSize: 14, fontWeight: FontWeight.w400, height: 1.45);
  static const bodyStrong = TextStyle(fontFamily: AppFonts.family, fontSize: 14, fontWeight: FontWeight.w600, height: 1.4);
  static const detail = TextStyle(fontFamily: AppFonts.family, fontSize: 14, fontWeight: FontWeight.w500, height: 1.35, fontFeatures: AppFonts.tabular);
  static const label = TextStyle(fontFamily: AppFonts.family, fontSize: 14, fontWeight: FontWeight.w500, height: 1.3);
  static const meta = TextStyle(fontFamily: AppFonts.family, fontSize: 13, fontWeight: FontWeight.w400, height: 1.4);
  static const caption = TextStyle(fontFamily: AppFonts.family, fontSize: 12, fontWeight: FontWeight.w500, height: 1.35);
  static const finePrint = TextStyle(fontFamily: AppFonts.family, fontSize: 12, fontWeight: FontWeight.w400, height: 1.4);
  static const badge = TextStyle(fontFamily: AppFonts.family, fontSize: 12, fontWeight: FontWeight.w600);
  static const statusStrip = TextStyle(fontFamily: AppFonts.family, fontSize: 12, fontWeight: FontWeight.w600, fontFeatures: AppFonts.tabular);

  // — старые имена ролей (до перехода на TicketTon) —
  static const verdictOneWord = resultTitle;
  static const verdictTwoLines = resultTitle;
  static const verdictLong = resultTitle;
  static const signInTitle = screenTitle;
  static const buttonResult = buttonLarge;
  static const buttonGhost = buttonSmall;
  static const fieldLabel = caption;
  static const tag = badge;

  /// Коды: билет, промокод, номер заказа.
  static const mono = TextStyle(fontFamily: AppFonts.mono, fontSize: 13, fontWeight: FontWeight.w600);
}
