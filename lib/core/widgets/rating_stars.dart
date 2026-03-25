import 'package:flutter/material.dart';

/// واجهة نجوم تقييم قابلة لإعادة الاستخدام مع دعم نصف نجمة
class RatingStars extends StatelessWidget {
  final double rating; // 0..5
  final double size;

  const RatingStars({super.key, required this.rating, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final hasHalf = (rating - full) >= 0.5;
    final List<Widget> stars = [];
    for (var i = 0; i < full; i++) {
      stars.add(Icon(Icons.star, color: Colors.amber, size: size));
    }
    if (hasHalf) stars.add(Icon(Icons.star_half, color: Colors.amber, size: size));
    while (stars.length < 5) {
      stars.add(Icon(Icons.star_border, color: Colors.amber, size: size));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: stars);
  }
}
