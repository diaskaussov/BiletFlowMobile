import 'package:flutter/painting.dart';

import 'app_fonts.dart';

/// Типографическая шкала BiletFlow (§02 спеки).
/// Цвет намеренно не задан: одни и те же роли идут и по светлому фону,
/// и вывернутыми на поле вердикта.
abstract final class AppText {
  // — заголовки —
  static const screenTitle = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 26,
    height: 1.04,
  );

  static const headerTitle = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 17,
    height: 1.1,
  );

  static const sectionLabel = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 11,
    letterSpacing: 1.54, // .14em × 11
  );

  static const fieldLabel = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 10,
    letterSpacing: 1.4, // .14em × 10
  );

  // — кнопки —
  static const buttonPrimary = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.96, // .06em × 16
  );

  // — текст —
  static const input = TextStyle(
    fontFamily: AppFonts.bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 15,
  );

  static const body = TextStyle(
    fontFamily: AppFonts.bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    height: 1.55,
  );

  static const bodySecondary = TextStyle(
    fontFamily: AppFonts.bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.55,
  );
}