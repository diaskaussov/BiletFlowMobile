import 'package:flutter/material.dart';

import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_text_styles.dart';
import '../domain/entities/scan_log.dart';
import '../domain/entities/scan_result.dart';

/// Слова, знаки и цвета вердиктов (§06, §08). Слово — капсом, одно-два,
/// никогда не предложение.
abstract final class VerdictCopy {
  static String word(Verdict v) => switch (v) {
        Verdict.valid => 'VALID',
        Verdict.alreadyUsed => 'ALREADY\nUSED',
        Verdict.repeatScan => 'SAME TICKET\nJUST NOW',
        Verdict.refunded => 'REFUNDED\nTICKET',
        Verdict.cancelled => 'CANCELLED\nTICKET',
        Verdict.unknownCode => 'CODE NOT\nRECOGNIZED',
        Verdict.wrongEvent => 'WRONG\nEVENT',
        Verdict.campaignCode => 'PROMOTIONAL\nCODE',
      };

  static TextStyle wordStyle(Verdict v) => switch (v) {
        Verdict.valid => AppText.verdictOneWord,
        Verdict.unknownCode || Verdict.campaignCode || Verdict.repeatScan => AppText.verdictLong,
        _ => AppText.verdictTwoLines,
      };

  static IconData icon(Verdict v) => switch (v) {
        Verdict.valid => Icons.check,
        Verdict.repeatScan => Icons.copy_outlined,
        Verdict.unknownCode => Icons.help_outline,
        Verdict.campaignCode => Icons.percent,
        _ => Icons.close,
      };

  static double iconSize(Verdict v) => switch (v) {
        Verdict.valid => 34,
        Verdict.repeatScan || Verdict.campaignCode => 26,
        _ => 32,
      };

  static Color field(Verdict v, AppPalette c) => switch (v) {
        Verdict.valid => c.successStrong,
        Verdict.repeatScan => c.primary,
        Verdict.campaignCode => c.infoStrong,
        _ => c.dangerStrong,
      };

  /// Строка журнала для A4 «Recent».
  static String logLine(ScanLogEntry e) {
    final who = e.attendeeName ?? 'Ticket';
    return switch (e.verdict) {
      Verdict.valid => e.isReversed ? '$who — check-in reversed' : '$who checked in',
      Verdict.repeatScan => '$who — repeat scan',
      Verdict.alreadyUsed => 'Rejected — already used',
      Verdict.refunded => 'Rejected — refunded ticket',
      Verdict.cancelled => 'Rejected — cancelled ticket',
      Verdict.unknownCode => 'Rejected — code not recognized',
      Verdict.wrongEvent => 'Rejected — wrong event',
      Verdict.campaignCode => 'Rejected — promotional QR',
    };
  }
}
