import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/config/server_address.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/labeled_text_field.dart';
import '../view_models/sign_in_view_model.dart';

/// A1 · Sign in
class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await context.read<SignInViewModel>().submit();
  }

  void _forgotPassword() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Forgot password', style: AppText.headerTitle.copyWith(color: AppColors.ink)),
        content: Text(
          'Scanner accounts are created by the organizer. Ask them to reset '
          'the password for the email you were assigned with.',
          style: AppText.body.copyWith(color: AppColors.neutral700),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK', style: AppText.buttonGhost.copyWith(color: AppColors.accent700)),
          ),
        ],
      ),
    );
  }

  /// Адрес бэкенда: на реальном телефоне это IP компьютера в той же Wi-Fi.
  Future<void> _editServer() async {
    final server = context.read<ServerAddress>();
    final controller = TextEditingController(text: server.current);
    String? error;
    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Server address', style: AppText.headerTitle.copyWith(color: AppColors.ink)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledTextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.url,
                hintText: 'http://192.168.1.10:8080',
              ),
              const SizedBox(height: 8),
              Text(
                error ?? 'On a real phone use the computer\'s Wi-Fi IP, not localhost.',
                style: AppText.finePrint.copyWith(
                  color: error == null ? AppColors.neutral600 : AppColors.ink,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                await server.reset();
                if (context.mounted) Navigator.of(context).pop(true);
              },
              child: Text('RESET', style: AppText.buttonGhost.copyWith(color: AppColors.neutral700)),
            ),
            TextButton(
              onPressed: () async {
                final e = await server.save(controller.text);
                if (!context.mounted) return;
                if (e == null) {
                  Navigator.of(context).pop(true);
                } else {
                  setDialogState(() => error = e);
                }
              },
              child: Text('SAVE', style: AppText.buttonGhost.copyWith(color: AppColors.accent700)),
            ),
          ],
        ),
      ),
    );
    controller.dispose();
    if (saved == true && mounted) {
      context.read<SignInViewModel>().clearError();
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SignInViewModel>();
    final error = vm.error;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.sideSignIn, 20, AppSpacing.sideSignIn, AppSpacing.bottomClearance,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 28),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BILETFLOW',
                      style: AppText.sectionLabel.copyWith(
                        fontSize: 12,
                        letterSpacing: 0.22 * 12,
                        color: AppColors.accent700,
                      ),
                    ),
                    const SizedBox(height: 44),
                    Text('Scanner\nsign-in', style: AppText.signInTitle.copyWith(color: AppColors.ink)),
                    const SizedBox(height: 10),
                    Text(
                      'For event administrators authorized by an organizer.',
                      style: AppText.bodySecondary.copyWith(color: AppColors.neutral700),
                    ),
                    const SizedBox(height: 38),
                    LabeledTextField(
                      label: 'Email',
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      hintText: 'name@company.kz',
                      textInputAction: TextInputAction.next,
                      onChanged: vm.setEmail,
                    ),
                    const SizedBox(height: 18),
                    LabeledTextField(
                      label: 'Password',
                      controller: _password,
                      isObscure: vm.isPasswordHidden,
                      keyboardType: TextInputType.visiblePassword,
                      hintText: 'Password',
                      textInputAction: TextInputAction.done,
                      onChanged: vm.setPassword,
                      onSubmitted: (_) => _submit(),
                      trailing: IconButton(
                        tooltip: vm.isPasswordHidden ? 'Show password' : 'Hide password',
                        onPressed: vm.togglePasswordVisibility,
                        icon: Icon(
                          vm.isPasswordHidden ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          size: 18,
                          color: AppColors.neutral600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 26),
                    if (error != null) ...[
                      Text(error, style: AppText.bodySecondary.copyWith(color: AppColors.ink)),
                      const SizedBox(height: 10),
                    ],
                    PrimaryButton(
                      label: 'Sign in',
                      isLoading: vm.isLoading,
                      onPressed: vm.canSubmit ? _submit : null,
                    ),
                    const SizedBox(height: 6),
                    GhostButton(label: 'Forgot password', onPressed: _forgotPassword),
                    const Spacer(),
                    const SizedBox(height: 24),
                    Text(
                      'Check-in requires a connection. Offline verification is '
                      'out of scope for this release.',
                      style: AppText.finePrint.copyWith(color: AppColors.neutral600),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: _editServer,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Server: ${context.watch<ServerAddress>().current}',
                                style: AppText.finePrint.copyWith(color: AppColors.neutral700),
                              ),
                            ),
                            Text(
                              'CHANGE',
                              style: AppText.fieldLabel.copyWith(color: AppColors.accent700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
