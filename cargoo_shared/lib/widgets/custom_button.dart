import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outlined;
  final bool loading;
  final IconData? icon;

  const CustomButton({super.key, required this.label, this.onPressed, this.outlined = false, this.loading = false, this.icon});

  @override
  Widget build(BuildContext context) {
    final child = loading
        ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.4, valueColor: AlwaysStoppedAnimation(Colors.white)))
        : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Text(label),
          ]);

    if (outlined) {
      return SizedBox(
        height: 54,
        child: OutlinedButton(
          onPressed: loading ? null : onPressed,
          style: OutlinedButton.styleFrom(foregroundColor: AppColors.textPrimary, side: const BorderSide(color: AppColors.divider), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          child: child,
        ),
      );
    }

    return SizedBox(height: 54, child: ElevatedButton(onPressed: loading ? null : onPressed, child: child));
  }
}
