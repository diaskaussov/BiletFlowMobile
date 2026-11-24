import 'package:flutter/material.dart';

/// Цветовые токены TicketTon (`variables` в TicketTon.pen) для светлой и
/// тёмной темы. Экраны берут цвета только отсюда: `context.colors.text`.
@immutable
class AppPalette extends ThemeExtension<AppPalette> {
  const AppPalette({
    required this.bg,
    required this.surface,
    required this.border,
    required this.text,
    required this.textMuted,
    required this.primary,
    required this.primaryPressed,
    required this.onPrimary,
    required this.primarySoft,
    required this.primaryTint,
    required this.success,
    required this.successText,
    required this.successSoft,
    required this.successStrong,
    required this.warning,
    required this.warningText,
    required this.warningSoft,
    required this.warningStrong,
    required this.danger,
    required this.dangerText,
    required this.dangerSoft,
    required this.dangerStrong,
    required this.info,
    required this.infoText,
    required this.infoSoft,
    required this.infoStrong,
    required this.neutralSoft,
    required this.navBackground,
    required this.scrim,
    required this.shadow,
  });

  /// Фон экрана.
  final Color bg;

  /// Карточки, поля, кнопки второго уровня.
  final Color surface;
  final Color border;
  final Color text;
  final Color textMuted;

  final Color primary;
  final Color primaryPressed;
  final Color onPrimary;

  /// 12% акцента — фон бейджа и полосы прогресса.
  final Color primarySoft;

  /// 8% акцента — активная вкладка навигации, выделенная карточка.
  final Color primaryTint;

  final Color success;
  final Color successText;
  final Color successSoft;

  /// Заливка карточки результата «Проходите».
  final Color successStrong;

  final Color warning;
  final Color warningText;
  final Color warningSoft;
  final Color warningStrong;

  final Color danger;
  final Color dangerText;
  final Color dangerSoft;
  final Color dangerStrong;

  final Color info;
  final Color infoText;
  final Color infoSoft;
  final Color infoStrong;

  /// Серый бейдж «Черновик», «Отменено».
  final Color neutralSoft;

  /// Плавающая нижняя навигация (полупрозрачная поверх контента).
  final Color navBackground;

  /// Затемнение под шторкой и диалогом.
  final Color scrim;
  final Color shadow;

  /// Фон камеры — всегда тёмный, в обеих темах.
  static const camera = Color(0xFF14141F);
  static const onStrong = Color(0xFFFFFFFF);

  static const light = AppPalette(
    bg: Color(0xFFF7F7FA),
    surface: Color(0xFFFFFFFF),
    border: Color(0xFFE4E4EB),
    text: Color(0xFF14141F),
    textMuted: Color(0xFF6B6B80),
    primary: Color(0xFF6D4AFF),
    primaryPressed: Color(0xFF5B3BE0),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0x1F6D4AFF),
    primaryTint: Color(0x146D4AFF),
    success: Color(0xFF16A34A),
    successText: Color(0xFF15803D),
    successSoft: Color(0x1F16A34A),
    successStrong: Color(0xFF15803D),
    warning: Color(0xFFF59E0B),
    warningText: Color(0xFFB45309),
    warningSoft: Color(0x26F59E0B),
    warningStrong: Color(0xFFD4A017),
    danger: Color(0xFFDC2626),
    dangerText: Color(0xFFB91C1C),
    dangerSoft: Color(0x1ADC2626),
    dangerStrong: Color(0xFFB91C1C),
    info: Color(0xFF2563EB),
    infoText: Color(0xFF1D4ED8),
    infoSoft: Color(0x1A2563EB),
    infoStrong: Color(0xFF2563EB),
    neutralSoft: Color(0x1F6B6B80),
    navBackground: Color(0xE6FFFFFF),
    scrim: Color(0x8014141F),
    shadow: Color(0x1A14141F),
  );

  static const dark = AppPalette(
    bg: Color(0xFF0E0E14),
    surface: Color(0xFF1A1A24),
    border: Color(0xFF2A2A38),
    text: Color(0xFFF4F4F8),
    textMuted: Color(0xFF9A9AB0),
    primary: Color(0xFF7C5CFF),
    primaryPressed: Color(0xFF6D4AFF),
    onPrimary: Color(0xFFFFFFFF),
    primarySoft: Color(0x337C5CFF),
    primaryTint: Color(0x247C5CFF),
    success: Color(0xFF22C55E),
    successText: Color(0xFF4ADE80),
    successSoft: Color(0x2622C55E),
    successStrong: Color(0xFF15803D),
    warning: Color(0xFFF59E0B),
    warningText: Color(0xFFFBBF24),
    warningSoft: Color(0x26F59E0B),
    warningStrong: Color(0xFFB7880F),
    danger: Color(0xFFEF4444),
    dangerText: Color(0xFFF87171),
    dangerSoft: Color(0x26EF4444),
    dangerStrong: Color(0xFFB91C1C),
    info: Color(0xFF3B82F6),
    infoText: Color(0xFF60A5FA),
    infoSoft: Color(0x263B82F6),
    infoStrong: Color(0xFF2563EB),
    neutralSoft: Color(0x339A9AB0),
    navBackground: Color(0xE61A1A24),
    scrim: Color(0xB3000000),
    shadow: Color(0x66000000),
  );

  @override
  AppPalette copyWith() => this;

  @override
  AppPalette lerp(AppPalette? other, double t) {
    if (other == null) return this;
    Color l(Color a, Color b) => Color.lerp(a, b, t)!;
    return AppPalette(
      bg: l(bg, other.bg),
      surface: l(surface, other.surface),
      border: l(border, other.border),
      text: l(text, other.text),
      textMuted: l(textMuted, other.textMuted),
      primary: l(primary, other.primary),
      primaryPressed: l(primaryPressed, other.primaryPressed),
      onPrimary: l(onPrimary, other.onPrimary),
      primarySoft: l(primarySoft, other.primarySoft),
      primaryTint: l(primaryTint, other.primaryTint),
      success: l(success, other.success),
      successText: l(successText, other.successText),
      successSoft: l(successSoft, other.successSoft),
      successStrong: l(successStrong, other.successStrong),
      warning: l(warning, other.warning),
      warningText: l(warningText, other.warningText),
      warningSoft: l(warningSoft, other.warningSoft),
      warningStrong: l(warningStrong, other.warningStrong),
      danger: l(danger, other.danger),
      dangerText: l(dangerText, other.dangerText),
      dangerSoft: l(dangerSoft, other.dangerSoft),
      dangerStrong: l(dangerStrong, other.dangerStrong),
      info: l(info, other.info),
      infoText: l(infoText, other.infoText),
      infoSoft: l(infoSoft, other.infoSoft),
      infoStrong: l(infoStrong, other.infoStrong),
      neutralSoft: l(neutralSoft, other.neutralSoft),
      navBackground: l(navBackground, other.navBackground),
      scrim: l(scrim, other.scrim),
      shadow: l(shadow, other.shadow),
    );
  }
}

extension PaletteContext on BuildContext {
  AppPalette get colors => Theme.of(this).extension<AppPalette>() ?? AppPalette.light;
}

/// Тон бейджа и баннера: цвет фона и текста из палитры.
enum Tone { neutral, primary, success, warning, danger, info }

extension ToneColors on AppPalette {
  ({Color bg, Color fg, Color dot}) tone(Tone t) => switch (t) {
        Tone.neutral => (bg: neutralSoft, fg: textMuted, dot: textMuted),
        Tone.primary => (bg: primarySoft, fg: primary, dot: primary),
        Tone.success => (bg: successSoft, fg: successText, dot: success),
        Tone.warning => (bg: warningSoft, fg: warningText, dot: warning),
        Tone.danger => (bg: dangerSoft, fg: dangerText, dot: danger),
        Tone.info => (bg: infoSoft, fg: infoText, dot: info),
      };
}
