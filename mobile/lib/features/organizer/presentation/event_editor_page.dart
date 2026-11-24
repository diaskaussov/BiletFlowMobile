import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../app/routes.dart';
import '../../../core/error/result.dart';
import '../../../core/presentation/loadable.dart';
import '../../../core/theme/app_palette.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/buttons.dart';
import '../../../core/widgets/commerce_widgets.dart';
import '../../../core/widgets/form_widgets.dart';
import '../../../core/widgets/labeled_text_field.dart';
import '../../../core/widgets/loadable_view.dart';
import '../../../core/widgets/screen_header.dart';
import '../../../core/widgets/state_views.dart';
import '../../../shared/domain/entities/event_info.dart';
import '../domain/organizer_events_domain.dart';

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
  String? error;

  void update(EventDraft Function(EventDraft) change) {
    final d = data;
    if (d != null) setData(change(d));
  }

  Future<EventInfo?> save() async {
    EventInfo? saved;
    final f = await run(() => _save(data!, eventId: eventId), onOk: (EventInfo e) => saved = e);
    error = f?.message;
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
    final vm = context.watch<EventEditorViewModel>();
    final isNew = vm.eventId == null;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: isNew ? 'Create event' : 'Edit event',
              subtitle: isNew ? 'Draft — nothing is public until you publish' : vm.data?.title,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: LoadableView<EventDraft>(
                state: vm,
                refreshable: false,
                builder: (context, d) => ListView(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 20, AppSpacing.sideLight, 24),
                  children: [
                    const SectionLabel('Basics'),
                    const SizedBox(height: 10),
                    LabeledTextField(
                      label: 'Event title',
                      controller: _field('title', d.title),
                      onChanged: (v) => vm.update((x) => x.copyWith(title: v)),
                    ),
                    const SizedBox(height: 14),
                    LabeledTextField(
                      label: 'Description',
                      controller: _field('description', d.description),
                      maxLines: 4,
                      onChanged: (v) => vm.update((x) => x.copyWith(description: v)),
                    ),
                    const SizedBox(height: 14),
                    LabeledTextField(
                      label: 'Category',
                      hintText: 'Music, Tech, Student, Sport, Theatre',
                      controller: _field('category', d.category),
                      onChanged: (v) => vm.update((x) => x.copyWith(category: v)),
                    ),
                    const SizedBox(height: 14),
                    Text('Visibility', style: AppText.meta.copyWith(color: context.colors.textMuted)),
                    const SizedBox(height: 6),
                    ChoiceChips<EventVisibility>(
                      options: EventVisibility.values,
                      selected: d.visibility,
                      label: (v) => v.label,
                      onSelected: (v) => vm.update((x) => x.copyWith(visibility: v)),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    const SectionLabel('Venue'),
                    const SizedBox(height: 10),
                    LabeledTextField(
                      label: 'Venue',
                      controller: _field('venue', d.venueName),
                      onChanged: (v) => vm.update((x) => x.copyWith(venueName: v)),
                    ),
                    const SizedBox(height: 14),
                    LabeledTextField(
                      label: 'Address',
                      controller: _field('address', d.venueAddress),
                      onChanged: (v) => vm.update((x) => x.copyWith(venueAddress: v)),
                    ),
                    const SizedBox(height: 14),
                    LabeledTextField(
                      label: 'City',
                      controller: _field('city', d.city),
                      onChanged: (v) => vm.update((x) => x.copyWith(city: v)),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    const SectionLabel('Date & registration'),
                    const SizedBox(height: 10),
                    DateTimeField(label: 'Starts', value: d.startsAt, onChanged: (t) => vm.update((x) => x.copyWith(startsAt: t))),
                    const SizedBox(height: 14),
                    DateTimeField(label: 'Ends', value: d.endsAt, onChanged: (t) => vm.update((x) => x.copyWith(endsAt: t))),
                    const SizedBox(height: 14),
                    DateTimeField(
                      label: 'Registration opens',
                      value: d.registrationOpensAt,
                      onChanged: (t) => vm.update((x) => x.copyWith(registrationOpensAt: t)),
                    ),
                    const SizedBox(height: 14),
                    DateTimeField(
                      label: 'Registration closes',
                      value: d.registrationClosesAt,
                      onChanged: (t) => vm.update((x) => x.copyWith(registrationClosesAt: t)),
                    ),
                    const SizedBox(height: 14),
                    LabeledTextField(
                      label: 'Capacity',
                      controller: _field('capacity', d.capacity?.toString() ?? ''),
                      keyboardType: TextInputType.number,
                      onChanged: (v) => vm.update((x) => x.copyWith(capacity: () => int.tryParse(v))),
                    ),
                    const SizedBox(height: AppSpacing.section),
                    const SectionLabel('Seating & image'),
                    LabeledSwitch(
                      label: 'Assigned seating',
                      hint: 'Attendees pick seats on a map at checkout (§4.3.1).',
                      value: d.assignedSeating,
                      onChanged: (v) => vm.update((x) => x.copyWith(assignedSeating: v)),
                    ),
                    LabeledTextField(
                      label: 'Cover image URL (optional)',
                      hintText: 'https://…',
                      keyboardType: TextInputType.url,
                      controller: _field('image', d.imageUrl),
                      onChanged: (v) => vm.update((x) => x.copyWith(imageUrl: v)),
                    ),
                    const SizedBox(height: 6),
                    Text('Image upload is not available in this build — paste a link to a hosted image.',
                        style: AppText.finePrint.copyWith(color: context.colors.textMuted)),
                  ],
                ),
              ),
            ),
            if (vm.data != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sideLight, 8, AppSpacing.sideLight, AppSpacing.bottomClearance),
                child: Column(
                  children: [
                    if (vm.error != null) ...[
                      Text(vm.error!, style: AppText.bodySecondary.copyWith(color: context.colors.text)),
                      const SizedBox(height: 8),
                    ],
                    PrimaryButton(
                      label: isNew ? 'Save and continue' : 'Save changes',
                      isLoading: vm.isBusy,
                      onPressed: () async {
                        FocusScope.of(context).unfocus();
                        final saved = await vm.save();
                        if (saved == null || !context.mounted) return;
                        showMessage(context, isNew ? 'Draft saved. Add ticket types next.' : 'Changes saved.');
                        if (isNew) {
                          context.pushReplacement(Routes.manageEvent(saved.id));
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
