import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// شارة للخصم أو الحالة
class AppBadge extends StatelessWidget {
  final String text;
  final Color? color;
  final EdgeInsetsGeometry padding;

  const AppBadge({super.key, required this.text, this.color, this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 4)});

  @override
  Widget build(BuildContext context) {
    final bg = color ?? DesignColors.secondary;
    return Container(
      padding: padding,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}
