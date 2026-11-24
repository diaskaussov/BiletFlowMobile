import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/presentation/l10n.dart';
import '../domain/entities/scan_result.dart';

/// Заголовки, иконки и цвета карточек результата (A4.1–A4.7 TicketTon.pen).
/// Цвета одинаковые в обеих темах: белый текст на насыщенной заливке.
abstract final class VerdictCopy {
  static String title(AppLocalizations l, Verdict v) => switch (v) {
        Verdict.valid => l.vValid,
        Verdict.alreadyUsed => l.vAlreadyUsed,
        Verdict.repeatScan => l.vRepeat,
        Verdict.refunded => l.vRefunded,
        Verdict.cancelled => l.vCancelled,
        Verdict.unknownCode => l.vUnknown,
        Verdict.wrongEvent => l.vWrongEvent,
        Verdict.campaignCode => l.vPromo,
      };

  static IconData icon(Verdict v) => switch (v) {
        Verdict.valid => LucideIcons.circleCheckBig,
        Verdict.alreadyUsed => LucideIcons.circleX,
        Verdict.repeatScan => LucideIcons.copyCheck,
        Verdict.refunded => LucideIcons.undo2,
        Verdict.cancelled => LucideIcons.ban,
        Verdict.unknownCode => LucideIcons.searchX,
        Verdict.wrongEvent => LucideIcons.triangleAlert,
        Verdict.campaignCode => LucideIcons.ticketPercent,
      };

  static Color fill(Verdict v) => switch (v) {
        Verdict.valid => const Color(0xFF15803D),
        Verdict.repeatScan => const Color(0xFF6D4AFF),
        Verdict.refunded => const Color(0xFF5B3BE0),
        Verdict.wrongEvent => const Color(0xFFC2410C),
        Verdict.campaignCode => const Color(0xFF1D4ED8),
        Verdict.alreadyUsed || Verdict.cancelled || Verdict.unknownCode => const Color(0xFFB91C1C),
      };
}
