import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'buttons.dart';

/// Пустое состояние / ошибка: знак 40 pt, заголовок, пояснение, действие.
class MessageView extends StatelessWidget {
  const MessageView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 40, color: AppColors.neutral600),
        const SizedBox(height: 18),
        Text(title, style: AppText.screenTitle.copyWith(color: AppColors.ink)),
        const SizedBox(height: 8),
        Text(message, style: AppText.body.copyWith(color: AppColors.neutral700)),
        if (actionLabel != null) ...[
          const SizedBox(height: 26),
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
    return const Center(
      child: SizedBox.square(
        dimension: 22,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

void showMessage(BuildContext context, String text) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(text)));
}
