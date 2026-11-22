import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_text_styles.dart';

/// Поле ввода 46 pt с подписью сверху (§04). Без [label] — только поле.
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

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: AppColors.divider),
  );

  static const _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: AppColors.accent, width: 2),
  );

  @override
  Widget build(BuildContext context) {
    final field = TextField(
      autocorrect: false,
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
      style: AppText.input.copyWith(color: AppColors.ink),
      cursorColor: AppColors.accent,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppText.input.copyWith(color: AppColors.neutral500),
        filled: true,
        fillColor: AppColors.surface,
        isDense: true,
        prefixIcon: leadingIcon == null
            ? null
            : Icon(leadingIcon, size: 18, color: AppColors.neutral600),
        prefixIconConstraints: const BoxConstraints(minWidth: 38),
        suffixIcon: trailing,
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12,
          vertical: maxLines > 1 ? 12 : 14,
        ),
        border: _border,
        enabledBorder: _border,
        focusedBorder: _focusedBorder,
      ),
    );

    if (label == null) return field;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label!, style: AppText.meta.copyWith(color: AppColors.neutral600)),
        const SizedBox(height: 5),
        maxLines > 1 ? field : SizedBox(height: AppSizes.textField, child: field),
      ],
    );
  }
}
