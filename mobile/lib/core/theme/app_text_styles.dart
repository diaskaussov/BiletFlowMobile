import 'package:flutter/painting.dart';

import 'app_fonts.dart';

/// Типографическая шкала BiletFlow (§02 спеки).
/// Цвет намеренно не задан: одни и те же роли идут и по светлому фону,
/// и вывернутыми на поле вердикта.
abstract final class AppText {
  // — вердикты —
  static const verdictOneWord = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 52,
    height: 0.92,
    letterSpacing: 0.52,
  );

  static const verdictTwoLines = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 46,
    height: 0.94,
  );

  static const verdictLong = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 42,
    height: 0.94,
  );

  // — числа —
  static const heroMetric = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 60,
    height: 0.9,
    fontFeatures: AppFonts.tabular,
  );

  static const statNumeral = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 26,
    height: 1,
    fontFeatures: AppFonts.tabular,
  );

  // — заголовки —
  static const signInTitle = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 34,
    height: 0.95,
    letterSpacing: 1.02,
  );

  static const screenTitle = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 26,
    height: 1.04,
  );

  static const personName = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 30,
    height: 1.05,
  );

  static const listTitle = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 18,
    height: 1.2,
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

  static const statusStrip = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 11,
    letterSpacing: 1.76, // .16em × 11
    fontFeatures: AppFonts.tabular,
  );

  static const fieldLabel = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 10,
    letterSpacing: 1.0, // .1em × 10
  );

  // — кнопки —
  static const buttonResult = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 17,
    letterSpacing: 1.02, // .06em × 17
  );

  static const buttonPrimary = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.96, // .06em × 16
  );

  static const buttonSecondary = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 14,
    letterSpacing: 0.84, // .06em × 14
  );

  static const buttonGhost = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 13,
    letterSpacing: 0.78,
  );

  static const tabItem = TextStyle(
    fontFamily: AppFonts.condensedFamily,
    fontWeight: FontWeight.w600,
    fontSize: 12,
    letterSpacing: 1.2, // .1em × 12
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

  static const detail = TextStyle(
    fontFamily: AppFonts.bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 13,
    height: 1.4,
    fontFeatures: AppFonts.tabular,
  );

  static const meta = TextStyle(
    fontFamily: AppFonts.bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    height: 1.5,
  );

  static const finePrint = TextStyle(
    fontFamily: AppFonts.bodyFamily,
    fontWeight: FontWeight.w400,
    fontSize: 11,
    height: 1.45,
  );

  static const tag = TextStyle(
    fontFamily: AppFonts.bodyFamily,
    fontWeight: FontWeight.w500,
    fontSize: 11,
    letterSpacing: 0.22,
    fontFeatures: AppFonts.tabular,
  );
}
