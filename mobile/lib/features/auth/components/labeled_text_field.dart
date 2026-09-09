import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_fonts.dart';

final class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool isObscure;
  final String? hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;

  static const _border = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: AppColors.divider)
  );

  static const _focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.zero,
    borderSide: BorderSide(color: AppColors.accent, width: 2),
  );

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    this.isObscure = false,
    this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.onSubmitted,
    this.onChanged
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.bodyFamily,
            fontSize: 12,
            color: AppColors.neutral600
          )
        ),
        
        SizedBox(height: 5),

        SizedBox(
          height: 46,
          child: TextField(
            autocorrect: false,
            textCapitalization: TextCapitalization.none,
            textInputAction: textInputAction,
            controller: controller,
            obscureText: isObscure,
            onSubmitted: onSubmitted,
            onChanged: onChanged,
            keyboardType: keyboardType,
            cursorColor: AppColors.accent,
            decoration: InputDecoration(
              hintText: hintText,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: EdgeInsets.symmetric(horizontal: 12),
              border: _border,
              enabledBorder: _border,
              focusedBorder: _focusedBorder,
            ),
          )
        )
      ]
    );
  }
}