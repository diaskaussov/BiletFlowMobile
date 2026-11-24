import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_text_styles.dart';
import 'buttons.dart';

/// Пустое состояние / ошибка: иконка в круге, заголовок, пояснение, действие
/// (A2 «Вас пока не назначили…», A9 «Нет подключения»).
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.tone = Tone.neutral,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Tone tone;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final t = c.tone(tone == Tone.neutral ? Tone.primary : tone);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(color: t.bg, shape: BoxShape.circle),
          child: Icon(icon, size: 32, color: t.fg),
        ),
        const SizedBox(height: 16),
        Text(title, textAlign: TextAlign.center, style: AppText.headerTitle.copyWith(color: c.text)),
        const SizedBox(height: 6),
        Text(message, textAlign: TextAlign.center, style: AppText.bodySecondary.copyWith(color: c.textMuted)),
        if (actionLabel != null) ...[
          const SizedBox(height: 20),
          SecondaryButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    );
  }
}

class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: SizedBox.square(dimension: 24, child: CircularProgressIndicator(strokeWidth: 2.4)));
  }
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
