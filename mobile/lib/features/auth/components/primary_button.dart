import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_fonts.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: FilledButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.accent.withValues(alpha: 0.45);
            }
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accent700;
            } 
            if (states.contains(WidgetState.hovered)) {
              return AppColors.accent600;
            }
            return AppColors.accent;
          }),
          overlayColor: const WidgetStatePropertyAll<Color>(Colors.transparent),
          foregroundColor: const WidgetStatePropertyAll<Color>(AppColors.bg),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.condensedFamily,
            fontSize: 16,
            letterSpacing: 0.04 * 16,
          ),
        ),
      ),
    );
  }
}