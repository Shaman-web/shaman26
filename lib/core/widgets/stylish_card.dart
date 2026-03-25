import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// بطاقة منمقة تستخدم في UI Kit
class StylishCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final BorderRadiusGeometry borderRadius;

  const StylishCard({super.key, required this.child, this.padding = const EdgeInsets.all(12), this.elevation = 2, this.borderRadius = const BorderRadius.all(Radius.circular(12))});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: DesignColors.surface,
      elevation: elevation,
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      child: Padding(padding: padding, child: child),
    );
  }
}
