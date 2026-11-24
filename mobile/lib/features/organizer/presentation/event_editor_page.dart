import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/result.dart';
import '../../../core/presentation/l10n.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/presentation/status_text.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/commerce_widgets.dart';
import '../../../core/widgets/data_blocks.dart';
import '../../../core/widgets/form_widgets.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../domain/organizer_events_domain.dart';
import '../../../core/presentation/failure_text.dart';
import '../../../core/error/failure.dart';

class EventEditorViewModel extends Loadable<EventDraft> {
  EventEditorViewModel({this.eventId, required GetManagedEvent get, required this._save})
      : super(() async {
          if (eventId == null) return const Ok(EventDraft());
          final r = await get(eventId);
          return switch (r) {
            Ok(:final value) => Ok(EventDraft.from(value)),
            Err(:final failure) => Err(failure),
          };
        });

  final int? eventId;
  final SaveEvent _save;
  Failure? error;

  void update(EventDraft Function(EventDraft) change) {
    final d = data;
    if (d != null) setData(change(d));
  }

  Future<EventInfo?> save() async {
    EventInfo? saved;
    final f = await run(() => _save(data!, eventId: eventId), onOk: (EventInfo e) => saved = e);
    error = f;
    notifyListeners();
    return saved;
  }
}

/// O2 · Create / edit event (§4.2, UC1)
class EventEditorPage extends StatefulWidget {
  const EventEditorPage({super.key});

  @override
  State<EventEditorPage> createState() => _EventEditorPageState();
}

class _EventEditorPageState extends State<EventEditorPage> {
  final _c = <String, TextEditingController>{};

  TextEditingController _field(String key, String initial) => _c.putIfAbsent(key, () => TextEditingController(text: initial));

  @override
  void dispose() {
    for (final c in _c.values) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<EventEditorViewModel>();
    final isNew = vm.eventId == null;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: isNew ? l.createEventTitle : (vm.data?.title ?? l.editEventTitle),
              subtitle: isNew ? l.draftHint : l.editEventTitle,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: LoadableView<EventDraft>(
                state: vm,
                refreshable: false,
                builder: (context, d) => ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 24),
                  children: [
                    SectionLabel(l.basics),
                    const SizedBox(height: 10),
                    LabeledTextField(
                      label: l.eventTitleLabel,
                      controller: _field('title', d.title),
                      onChanged: (v) => vm.update((x) => x.copyWith(title: v)),
                    ),
                    const SizedBox(height: 14),
                    LabeledTextField(
                      label: l.descriptionLabel,
                      controller: _field('description', d.description),
                      maxLines: 4,
                      onChanged: (v) => vm.update((x) => x.copyWith(description: v)),
                    ),
                    const SizedBox(height: 14),
                    LabeledTextField(
                      label: l.categoryLabel,
                      hintText: l.categoryHint,
                      controller: _field('category', d.category),
                      onChanged: (v) => vm.update((x) => x.copyWith(category: v)),
                    ),
                    const SizedBox(height: 14),
                    Text(l.visibilityLabel, style: AppText.label.copyWith(color: c.textMuted)),
                    const SizedBox(height: 6),
                    ChoiceChips<EventVisibility>(
                      options: EventVisibility.values,
                      selected: d.visibility,
                      label: (v) => v.text(l),
                      onSelected: (v) => vm.update((x) => x.copyWith(visibility: v)),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    SectionLabel(l.venueSection),
                    const SizedBox(height: 10),
                    LabeledTextField(
                      label: l.venueLabel,
                      controller: _field('venue', d.venueName),
                      onChanged: (v) => vm.update((x) => x.copyWith(venueName: v)),
                    ),
                    const SizedBox(height: 14),
                    LabeledTextField(
                      label: l.addressLabel,
                      controller: _field('address', d.venueAddress),
                      onChanged: (v) => vm.update((x) => x.copyWith(venueAddress: v)),
                    ),
                    const SizedBox(height: 14),
                    LabeledTextField(
                      label: l.cityLabel,
                      controller: _field('city', d.city),
                      onChanged: (v) => vm.update((x) => x.copyWith(city: v)),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    SectionLabel(l.dateSection),
                    const SizedBox(height: 10),
                    DateTimeField(label: l.startsLabel, value: d.startsAt, onChanged: (t) => vm.update((x) => x.copyWith(startsAt: t))),
                    const SizedBox(height: 14),
                    DateTimeField(label: l.endsLabel, value: d.endsAt, onChanged: (t) => vm.update((x) => x.copyWith(endsAt: t))),
                    const SizedBox(height: 14),
                    DateTimeField(
                      label: l.regOpens,
                      value: d.registrationOpensAt,
                      onChanged: (t) => vm.update((x) => x.copyWith(registrationOpensAt: t)),
                    ),
                    const SizedBox(height: 14),
                    DateTimeField(
                      label: l.regCloses,
                      value: d.registrationClosesAt,
                      onChanged: (t) => vm.update((x) => x.copyWith(registrationClosesAt: t)),
                    ),
                    const SizedBox(height: 14),
                    LabeledTextField(
                      label: l.capacityLabel,
                      controller: _field('capacity', d.capacity?.toString() ?? ''),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => vm.update((x) => x.copyWith(capacity: () => int.tryParse(v))),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    SectionLabel(l.seatingImage),
                    LabeledSwitch(
                      label: l.assignedSeating,
                      hint: l.assignedSeatingHint,
                      value: d.assignedSeating,
                      onChanged: (v) => vm.update((x) => x.copyWith(assignedSeating: v)),
                    ),
                    LabeledTextField(
                      label: l.coverUrl,
                      hintText: 'https://…',
                      keyboardType: TextInputType.url,
                      controller: _field('image', d.imageUrl),
                      onChanged: (v) => vm.update((x) => x.copyWith(imageUrl: v)),
                    ),
                    const SizedBox(height: 6),
                    Text(l.coverNote, style: AppText.finePrint.copyWith(color: c.textMuted)),
                  ],
                ),
              ),
            ),
            if (vm.data != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.side, 8, AppSpacing.side, 16),
                child: Column(
                  children: [
                    if (vm.error != null) ...[
                      InfoBanner(text: vm.error!.text(context), tone: Tone.danger),
                      const SizedBox(height: 8),
                    ],
                    PrimaryButton(
                      label: isNew ? l.saveAndContinue : l.saveChanges,
                      isLoading: vm.isBusy,
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        final saved = await vm.save();
                        if (saved == null || !context.mounted) return;
                        showMessage(context, isNew ? l.draftSaved : l.changesSaved);
                        if (isNew) {
                          context.pushReplacement(Routes.ticketTypes(saved.id));
                        } else {
                          context.pop(true);
                        }
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
