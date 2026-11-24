import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../core/error/result.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/labeled_text_field.dart';
import '../../../../core/widgets/screen_header.dart';
import '../../domain/entities/user_session.dart';
import '../../domain/usecases/sign_in.dart';
import '../controllers/session_controller.dart';
import '../../../../core/presentation/safe_notifier.dart';

class RegisterViewModel extends ChangeNotifier with SafeNotifier {
  RegisterViewModel({required this._register, required this._session});

  final Register _register;
  final SessionController _session;

  UserRole role = UserRole.attendee;
  bool isLoading = false;
  String? error;

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
        error = failure.message;
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
    final vm = context.watch<RegisterViewModel>();
    Widget roleOption(UserRole role, String title, String text) {
      final selected = vm.role == role;
      return Expanded(
        child: InkWell(
          onTap: () => vm.setRole(role),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: selected ? AppColors.accent100 : null,
              border: Border.all(color: selected ? AppColors.accent : AppColors.divider, width: selected ? 2 : 1),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.toUpperCase(), style: AppText.sectionLabel.copyWith(color: selected ? AppColors.accent800 : AppColors.ink)),
                const SizedBox(height: 4),
                Text(text, style: AppText.meta.copyWith(color: AppColors.neutral700)),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(title: 'Create an account', onBack: () => context.pop()),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(AppSpacing.sideSignIn, 24, AppSpacing.sideSignIn, 24),
                children: [
                  Text('I want to', style: AppText.meta.copyWith(color: AppColors.neutral600)),
                  const SizedBox(height: 6),
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        roleOption(UserRole.attendee, 'Attend', 'Find events, buy tickets, show the QR at the door.'),
                        const SizedBox(width: 10),
                        roleOption(UserRole.organizer, 'Organize', 'Create events, sell tickets, assign gate staff.'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(child: LabeledTextField(label: 'First name', controller: _first, textInputAction: TextInputAction.next)),
                      const SizedBox(width: 10),
                      Expanded(child: LabeledTextField(label: 'Last name', controller: _last, textInputAction: TextInputAction.next)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  LabeledTextField(
                    label: 'Email',
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  LabeledTextField(
                    label: 'Phone (optional)',
                    controller: _phone,
                    keyboardType: TextInputType.phone,
                    hintText: '+7 701 234 56 78',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 16),
                  LabeledTextField(
                    label: 'Password · at least 6 characters',
                    controller: _password,
                    isObscure: true,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(height: 22),
                  if (vm.error != null) ...[
                    Text(vm.error!, style: AppText.bodySecondary.copyWith(color: AppColors.ink)),
                    const SizedBox(height: 10),
                  ],
                  PrimaryButton(
                    label: vm.role == UserRole.organizer ? 'Create organizer account' : 'Create account',
                    isLoading: vm.isLoading,
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      vm.submit(
                        firstName: _first.text,
                        lastName: _last.text,
                        email: _email.text,
                        phone: _phone.text,
                        password: _password.text,
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'We send a confirmation link to your email. Event staff accounts are '
                    'created by organizers, not here.',
                    style: AppText.finePrint.copyWith(color: AppColors.neutral600),
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
