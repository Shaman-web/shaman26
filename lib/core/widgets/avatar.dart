import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

/// Avatar دائري بسيط مع ظل
class Avatar extends StatelessWidget {
  final String? imageUrl;
  final double radius;
  final Widget? fallback;

  const Avatar({super.key, this.imageUrl, this.radius = 28, this.fallback});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: DesignColors.primaryLight,
      backgroundImage: imageUrl != null ? NetworkImage(imageUrl!) : null,
      child: imageUrl == null ? (fallback ?? const Icon(Icons.person, color: Colors.white)) : null,
    );
  }
}
