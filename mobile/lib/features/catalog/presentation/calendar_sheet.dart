import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../../core/error/result.dart';
import '../../../core/platform/document_actions.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../domain/calendar_links.dart';
import '../../../core/presentation/failure_text.dart';

/// «ADD TO CALENDAR»: Google, Outlook или файл .ics (§4.11, UC6).
Future<void> showCalendarSheet(
  BuildContext context, {
  required EventInfo event,
  required Future<Result<Uint8List>> Function() icsFile,
  DocumentActions actions = const DocumentActions(),
}) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.l10n.addToCalendar, style: AppText.headerTitle.copyWith(color: context.colors.text, fontSize: 20)),
            const SizedBox(height: 6),
            Text(event.title, style: AppText.bodySecondary.copyWith(color: context.colors.textMuted)),
            const SizedBox(height: 16),
            if (CalendarLinks.google(event) case final g?) ...[
              SecondaryButton(label: 'Google Calendar', icon: LucideIcons.calendarPlus, onPressed: () => actions.openUrl(g)),
              const SizedBox(height: AppSpacing.actionGap),
            ],
            if (CalendarLinks.outlook(event) case final o?) ...[
              SecondaryButton(label: 'Outlook', icon: LucideIcons.calendarPlus, onPressed: () => actions.openUrl(o)),
              const SizedBox(height: AppSpacing.actionGap),
            ],
            PrimaryButton(
              label: context.l10n.downloadIcs,
              icon: LucideIcons.download,
              onPressed: () async {
                final r = await icsFile();
                if (!sheetContext.mounted) return;
                switch (r) {
                  case Ok(:final value):
                    await actions.share(value, name: 'biletflow-event-${event.id}.ics', mimeType: 'text/calendar');
                  case Err(:final failure):
                    showMessage(sheetContext, failure.text(sheetContext));
                }
              },
            ),
            const SizedBox(height: 10),
            Text(context.l10n.calendarNote, style: AppText.finePrint.copyWith(color: context.colors.textMuted)),
          ],
        ),
      ),
    ),
  );
}
