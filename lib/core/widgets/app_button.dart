import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool outline;

  const AppButton({super.key, required this.label, this.onPressed, this.outline = false});

  @override
  Widget build(BuildContext context) {
    if (outline) {
      return OutlinedButton(onPressed: onPressed, style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)), child: Text(label));
    }
    return ElevatedButton(onPressed: onPressed, child: Text(label));
  }
}
