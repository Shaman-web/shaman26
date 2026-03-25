import 'package:flutter/material.dart';
import 'package:shaman/core/widgets/animated_fade_in.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../../../wishlist/presentation/state/wishlist_provider.dart';
import 'package:shaman/core/widgets/stylish_card.dart';
import 'package:shaman/core/widgets/badge.dart';
import 'package:shaman/core/widgets/rating_stars.dart';
import 'package:shaman/core/theme/design_tokens.dart';

class ProductCard extends StatefulWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductCard({super.key, required this.product, this.onTap});

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails d) => setState(() => _scale = 0.97);
  void _onTapUp(TapUpDetails d) => setState(() => _scale = 1.0);
  void _onTapCancel() => setState(() => _scale = 1.0);

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: (d) {
        _onTapUp(d);
        widget.onTap?.call();
      },
      onTapCancel: _onTapCancel,
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: AnimatedFadeIn(
          child: StylishCard(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 140,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: product.mainImage != null
                            ? Image.network(product.mainImage!, fit: BoxFit.cover)
                            : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 48)),
                      ),
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Consumer<WishlistProvider>(builder: (ctx, wp, ch) {
                          final inWishlist = wp.isInWishlist(product.id);
                          return GestureDetector(
                            onTap: () async {
                              final messenger = ScaffoldMessenger.of(context);
                              try {
                                final added = await wp.toggle(product.id);
                                messenger.showSnackBar(SnackBar(content: Text(added ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة')));
                              } catch (e) {
                                messenger.showSnackBar(SnackBar(content: Text('فشل العملية: ${e.toString()}')));
                              }
                            },
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: DesignColors.surface.withAlpha((0.95 * 255).round()),
                              child: Icon(inWishlist ? Icons.favorite : Icons.favorite_border, color: inWishlist ? Colors.red : Colors.grey),
                            ),
                          );
                        }),
                      ),
                      if (product.discount > 0) Positioned(left: 10, top: 10, child: AppBadge(text: '-${(product.discount * 100).toStringAsFixed(0)}%')),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(product.name, style: DesignText.subheading, maxLines: 2, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Builder(builder: (ctx) {
                      double? avg;
                      int? reviewsCount;
                      try {
                        final p = product as dynamic;
                        avg = (p.averageRating == null) ? null : (p.averageRating as double?);
                        reviewsCount = (p.reviewsCount == null) ? null : (p.reviewsCount as int?);
                      } catch (_) {
                        avg = null;
                        reviewsCount = null;
                      }

                      if (avg != null && avg > 0) {
                        return Row(children: [
                          RatingStars(rating: avg, size: 14),
                          const SizedBox(width: 6),
                          Text(avg.toStringAsFixed(1), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          const SizedBox(width: 6),
                          if (reviewsCount != null) Text('($reviewsCount)', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                        ]);
                      }

                      return const Text('لا تقييم', style: TextStyle(fontSize: 12, color: Colors.grey));
                    }),
                    const SizedBox(height: 8),
                    Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Flexible(
                        fit: FlexFit.loose,
                        child: Text(
                          '${(product.discount > 0 ? (product.price * (1 - product.discount)) : product.price).toStringAsFixed(2)} ر.س',
                          style: TextStyle(color: DesignColors.primary, fontWeight: FontWeight.bold, fontSize: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (product.discount > 0)
                        Flexible(
                          fit: FlexFit.loose,
                          child: Text(
                            '${product.price.toStringAsFixed(2)} ر.س',
                            style: const TextStyle(decoration: TextDecoration.lineThrough, color: Colors.grey, fontSize: 12),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      const Spacer(),
                      if (product.qty <= 0)
                        SizedBox(width: 80, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: Colors.grey[200], borderRadius: BorderRadius.circular(12)), alignment: Alignment.center, child: const Text('غير متوفر', style: TextStyle(fontSize: 12)))),
                      if (product.qty > 0)
                        SizedBox(width: 80, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: DesignColors.accent.withAlpha((0.12 * 255).round()), borderRadius: BorderRadius.circular(12)), alignment: Alignment.center, child: const Text('متوفر', style: TextStyle(fontSize: 12)))),
                    ])
                  ]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
