import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/design_tokens.dart';

class ShimmerLoader extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  ShimmerLoader({
    super.key,
    this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? DesignTokens.cardRadius,
        ),
      ),
    );
  }
}

class ProductShimmer extends StatelessWidget {
  ProductShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ShimmerLoader(height: 140, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerLoader(height: 16, borderRadius: BorderRadius.circular(8)),
              const SizedBox(height: 8),
              ShimmerLoader(height: 12, borderRadius: BorderRadius.circular(4)),
              const SizedBox(height: 8),
              ShimmerLoader(height: 18, borderRadius: BorderRadius.circular(4)),
            ],
          ),
        ),
      ],
    );
  }
}
