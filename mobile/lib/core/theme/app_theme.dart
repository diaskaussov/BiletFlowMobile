import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_fonts.dart';
import 'app_text_styles.dart';

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.accent,
      surface: AppColors.bg,
    ).copyWith(primary: AppColors.accent, onSurface: AppColors.ink);

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      fontFamily: AppFonts.bodyFamily,
      splashFactory: NoSplash.splashFactory,
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 1,
      ),
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: AppColors.accent,
        selectionColor: AppColors.accent300,
        selectionHandleColor: AppColors.accent,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: AppColors.ink,
        contentTextStyle: AppText.bodySecondary,
        shape: RoundedRectangleBorder(),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.bg,
        shape: RoundedRectangleBorder(),
      ),
    );
  }
}
