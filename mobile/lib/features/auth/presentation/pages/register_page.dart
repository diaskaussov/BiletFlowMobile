import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../core/error/failure.dart';
import '../../../../core/error/result.dart';
import '../../../../core/presentation/failure_text.dart';
import '../../../../core/presentation/l10n.dart';
import '../../../../core/presentation/safe_notifier.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/data_blocks.dart';
import '../../../../core/widgets/labeled_text_field.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/usecases/sign_in.dart';
import '../controllers/session_controller.dart';

class RegisterViewModel extends ChangeNotifier with SafeNotifier {
  RegisterViewModel({required this._register, required this._session});

  final Register _register;
  final SessionController _session;

  UserRole role = UserRole.attendee;
  bool isLoading = false;
  Failure? error;

  void setRole(UserRole r) {
    role = r;
    notifyListeners();
  }

  Future<void> submit({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
  }) async {
    isLoading = true;
    error = null;
    notifyListeners();
    final r = await _register(
      email: email,
      password: password,
      firstName: firstName,
      lastName: lastName,
      role: role,
      phone: phone,
    );
    isLoading = false;
    switch (r) {
      case Ok(:final value):
        _session.signedIn(value);
      case Err(:final failure):
        error = failure;
    }
    notifyListeners();
  }
}

/// Регистрация участника или организатора (§4.1).
class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    for (final c in [_first, _last, _email, _phone, _password]) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<RegisterViewModel>();
    Widget roleOption(UserRole role, IconData icon, String title, String text) {
      final selected = vm.role == role;
      return Expanded(
        child: AppCard(
          onTap: () => vm.setRole(role),
          color: selected ? c.primaryTint : null,
          borderColor: selected ? c.primary : null,
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 22, color: selected ? c.primary : c.textMuted),
              const SizedBox(height: 8),
              Text(title, style: AppText.cardTitle.copyWith(color: selected ? c.primary : c.text)),
              const SizedBox(height: 4),
              Text(text, style: AppText.finePrint.copyWith(color: c.textMuted)),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: l.registerTitle, onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sideSignIn, 8, AppSpacing.sideSignIn, 24),
                children: [
                  Text(l.registerIWant, style: AppText.label.copyWith(color: c.textMuted)),
                  const SizedBox(height: 8),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        roleOption(UserRole.attendee, LucideIcons.ticket, l.roleAttend, l.roleAttendHint),
                        const SizedBox(width: 10),
                        roleOption(UserRole.organizer, LucideIcons.calendarPlus, l.roleOrganize, l.roleOrganizeHint),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(children: [
                    Expanded(child: LabeledTextField(label: l.firstName, controller: _first, textInputAction: TextInputAction.next)),
                    const SizedBox(width: 10),
                    Expanded(child: LabeledTextField(label: l.lastName, controller: _last, textInputAction: TextInputAction.next)),
                  ]),
                  const SizedBox(height: 16),
                  LabeledTextField(label: l.email, controller: _email, keyboardType: TextInputType.emailAddress, textInputAction: TextInputAction.next),
                  const SizedBox(height: 16),
                  LabeledTextField(
                    label: l.phoneOptional,
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    hintText: '+7 701 234 56 78',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  LabeledTextField(label: l.passwordMin, controller: _password, isObscure: true, textInputAction: TextInputAction.done),
                  if (vm.error != null) ...[
                    const SizedBox(height: 16),
                    InfoBanner(text: vm.error!.text(context), tone: Tone.danger),
                  ],
                  const SizedBox(height: 22),
                  PrimaryButton(
                    label: vm.role == UserRole.organizer ? l.registerOrganizerButton : l.registerButton,
                    isLoading: vm.isLoading,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      vm.submit(firstName: _first.text, lastName: _last.text, email: _email.text, phone: _phone.text, password: _password.text);
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(l.registerNote, textAlign: TextAlign.center, style: AppText.finePrint.copyWith(color: c.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
