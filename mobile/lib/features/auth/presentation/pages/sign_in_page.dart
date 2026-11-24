import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../../../app/routes.dart';
import '../../../../core/config/server_address.dart';
import '../../../../core/presentation/failure_text.dart';
import '../../../../core/presentation/l10n.dart';
import '../../../../core/theme/app_palette.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/buttons.dart';
import '../../../../core/widgets/data_blocks.dart';
import '../../../../core/widgets/labeled_text_field.dart';
import '../view_models/sign_in_view_model.dart';

/// A1 · Вход — общий для всех ролей; после входа роутер открывает раздел роли.
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
    final l = context.l10n;
    showDialog<void>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: Text(l.forgotPasswordTitle),
        content: Text(l.forgotPasswordBody),
        actions: [TextButton(onPressed: () => Navigator.of(dialog).pop(), child: Text(l.actionOk))],
      ),
    );
  }

  /// Адрес бэкенда: на реальном телефоне — IP компьютера в той же Wi‑Fi.
  Future<void> _editServer() async {
    final l = context.l10n;
    final server = context.read<ServerAddress>();
    final controller = TextEditingController(text: server.current);
    String? error;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => StatefulBuilder(
        builder: (sheet, setSheet) => Padding(
          padding: EdgeInsets.fromLTRB(AppSpacing.side, 0, AppSpacing.side, 16 + MediaQuery.viewInsetsOf(sheet).bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l.serverTitle, style: AppText.headerTitle.copyWith(color: sheet.colors.text)),
              const SizedBox(height: 4),
              Text(l.serverHint, style: AppText.bodySecondary.copyWith(color: sheet.colors.textMuted)),
              const SizedBox(height: 16),
              LabeledTextField(
                controller: controller,
                autofocus: true,
                keyboardType: TextInputType.url,
                hintText: 'http://192.168.1.10:8080',
                hasError: error != null,
              ),
              if (error != null) ...[const SizedBox(height: 8), InfoBanner(text: error!, tone: Tone.danger)],
              const SizedBox(height: 16),
              PrimaryButton(
                label: l.actionSave,
                onPressed: () async {
                  final e = await server.save(controller.text);
                  if (!sheet.mounted) return;
                  if (e == null) {
                    Navigator.of(sheet).pop();
                  } else {
                    setSheet(() => error = l.serverInvalid);
                  }
                },
              ),
              GhostButton(
                label: l.actionReset,
                color: sheet.colors.textMuted,
                onPressed: () async {
                  await server.reset();
                  if (sheet.mounted) Navigator.of(sheet).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
    controller.dispose();
    if (mounted) context.read<SignInViewModel>().clearError();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final vm = context.watch<SignInViewModel>();
    final error = vm.error;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sideSignIn, 40, AppSpacing.sideSignIn, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(color: c.primary, borderRadius: BorderRadius.circular(12)),
                        child: const Icon(LucideIcons.ticket, size: 24, color: Colors.white),
                      ),
                      const SizedBox(width: 10),
                      Text(l.appName, style: AppText.brand.copyWith(color: c.text)),
                    ]),
                    const SizedBox(height: 32),
                    Text(l.signInTitle, style: AppText.screenTitle.copyWith(color: c.text)),
                    const SizedBox(height: 6),
                    Text(l.signInSubtitle, style: AppText.body.copyWith(color: c.textMuted)),
                    const SizedBox(height: 28),
                    LabeledTextField(
                      label: l.email,
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      hintText: 'name@company.kz',
                      textInputAction: TextInputAction.next,
                      hasError: error != null,
                      onChanged: vm.setEmail,
                    ),
                    const SizedBox(height: 20),
                    LabeledTextField(
                      label: l.password,
                      controller: _password,
                      isObscure: vm.isPasswordHidden,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      hasError: error != null,
                      onChanged: vm.setPassword,
                      onSubmitted: (_) => _submit(),
                      trailing: IconButton(
                        tooltip: vm.isPasswordHidden ? l.showPassword : l.hidePassword,
                        onPressed: vm.togglePasswordVisibility,
                        icon: Icon(vm.isPasswordHidden ? LucideIcons.eye : LucideIcons.eyeOff, size: 18, color: c.textMuted),
                      ),
                    ),
                    if (error != null) ...[
                      const SizedBox(height: 16),
                      InfoBanner(text: error.text(context), tone: Tone.danger),
                    ],
                    const Spacer(),
                    const SizedBox(height: 24),
                    PrimaryButton(label: l.signInButton, large: true, isLoading: vm.isLoading, onPressed: vm.canSubmit ? _submit : null),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(child: GhostButton(label: l.forgotPassword, color: c.textMuted, onPressed: _forgotPassword)),
                      Expanded(child: GhostButton(label: l.createAccount, onPressed: () => context.push(Routes.register))),
                    ]),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: _editServer,
                      borderRadius: BorderRadius.circular(8),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 44),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.server, size: 14, color: c.textMuted),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(l.serverLabel(context.watch<ServerAddress>().current),
                                  overflow: TextOverflow.ellipsis, style: AppText.finePrint.copyWith(color: c.textMuted)),
                            ),
                            const SizedBox(width: 6),
                            Text(l.actionChange, style: AppText.caption.copyWith(color: c.primary)),
                          ],
                        ),
                      ),
                    ),
                    Text(l.onlineOnlyNote, textAlign: TextAlign.center, style: AppText.finePrint.copyWith(color: c.textMuted)),
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
