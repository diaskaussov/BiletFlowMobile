import 'package:flutter/material.dart';
import 'package:mobile/core/theme/app_colors.dart';
import 'package:mobile/core/theme/app_fonts.dart';

class GhostButton extends StatelessWidget {
  const GhostButton({
    super.key,
    required this.label,
    this.onPressed,
    this.height = 44,
  });

  final String label;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: TextButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor:
              const WidgetStatePropertyAll<Color>(Colors.transparent),
          foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
            if (states.contains(WidgetState.disabled)) {
              return AppColors.accent.withValues(alpha: 0.45);
            }
            return AppColors.accent;
          }),
          overlayColor: WidgetStateProperty.resolveWith<Color?>((states) {
            if (states.contains(WidgetState.pressed)) {
              return AppColors.accent.withValues(alpha: 0.18);
            }
            if (states.contains(WidgetState.hovered)) {
              return AppColors.accent.withValues(alpha: 0.10);
            }
            return null;
          }),
          shape: const WidgetStatePropertyAll<OutlinedBorder>(
            RoundedRectangleBorder(borderRadius: BorderRadius.zero),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: AppFonts.condensedFamily,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}