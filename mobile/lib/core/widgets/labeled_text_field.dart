import 'package:flutter/material.dart';

import '../theme/app_palette.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Поле ввода 56 pt со скруглением 14 и подписью сверху (A1).
/// [hasError] красит рамку в danger.
class LabeledTextField extends StatelessWidget {
  const LabeledTextField({
    super.key,
    this.label,
    required this.controller,
    this.isObscure = false,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged,
    this.leadingIcon,
    this.trailing,
    this.autofocus = false,
    this.maxLines = 1,
    this.focusNode,
    this.hasError = false,
    this.compact = false,
  });

  final String? label;
  final TextEditingController controller;
  final bool isObscure;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final IconData? leadingIcon;
  final Widget? trailing;
  final bool autofocus;
  final int maxLines;
  final FocusNode? focusNode;
  final bool hasError;

  /// 48 pt — поиск в списках.
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    OutlineInputBorder border(Color color, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.field),
          borderSide: BorderSide(color: color, width: w),
        );
    final field = TextField(
      autocorrect: false,
      enableSuggestions: !isObscure && keyboardType != TextInputType.emailAddress,
      autofocus: autofocus,
      focusNode: focusNode,
      textCapitalization: TextCapitalization.none,
      textInputAction: textInputAction,
      controller: controller,
      obscureText: isObscure,
      onSubmitted: onSubmitted,
      onChanged: onChanged,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: AppText.input.copyWith(color: c.text),
      cursorColor: c.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppText.input.copyWith(color: c.textMuted),
        filled: true,
        fillColor: c.surface,
        isDense: true,
        prefixIcon: leadingIcon == null ? null : Icon(leadingIcon, size: 18, color: c.textMuted),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        suffixIcon: trailing,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: maxLines > 1 ? 14 : (compact ? 13 : 17)),
        border: border(hasError ? c.dangerText : c.border),
        enabledBorder: border(hasError ? c.dangerText : c.border),
        focusedBorder: border(hasError ? c.dangerText : c.primary, 2),
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: AppText.label.copyWith(color: c.textMuted)),
        const SizedBox(height: 8),
        field,
      ],
    );
  }
}
