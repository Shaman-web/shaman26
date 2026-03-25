import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// زر أساسي موحّد مع تصميم UI kit
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EdgeInsetsGeometry padding;

  const PrimaryButton({super.key, required this.label, required this.onPressed, this.padding = const EdgeInsets.symmetric(vertical: 14)});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: DesignColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(DesignSizes.radius)),
        padding: padding,
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
    );
  }
}
