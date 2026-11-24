import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/error/result.dart';
import '../../../core/platform/document_actions.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../domain/calendar_links.dart';

/// «ADD TO CALENDAR»: Google, Outlook или файл .ics (§4.11, UC6).
Future<void> showCalendarSheet(
  BuildContext context, {
  required EventInfo event,
  required Future<Result<Uint8List>> Function() icsFile,
  DocumentActions actions = const DocumentActions(),
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: context.colors.bg,
    barrierColor: context.colors.scrim,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(AppSpacing.sheetInset, 20, AppSpacing.sheetInset, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel('Add to calendar', color: context.colors.primary),
            const SizedBox(height: 6),
            Text(event.title, style: AppText.listTitle.copyWith(color: context.colors.text)),
            const SizedBox(height: 16),
            if (CalendarLinks.google(event) case final g?) ...[
              SecondaryButton(label: 'Google Calendar', onPressed: () => actions.openUrl(g)),
              const SizedBox(height: AppSpacing.actionGap),
            ],
            if (CalendarLinks.outlook(event) case final o?) ...[
              SecondaryButton(label: 'Outlook', onPressed: () => actions.openUrl(o)),
              const SizedBox(height: AppSpacing.actionGap),
            ],
            PrimaryButton(
              label: 'Download .ics',
              onPressed: () async {
                final r = await icsFile();
                if (!sheetContext.mounted) return;
                switch (r) {
                  case Ok(:final value):
                    await actions.share(value, name: 'biletflow-event-${event.id}.ics', mimeType: 'text/calendar');
                  case Err(:final failure):
                    showMessage(sheetContext, failure.message);
                }
              },
            ),
            const SizedBox(height: 10),
            Text(
              'Includes venue address and the event\'s time. If the organizer changes the time, '
              'the updated file replaces your entry.',
              style: AppText.finePrint.copyWith(color: context.colors.textMuted),
            ),
          ],
        ),
      ),
    ),
  );
}
