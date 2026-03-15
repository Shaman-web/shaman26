import 'package:flutter/material.dart';
import 'package:shaman/core/widgets/animated_fade_in.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/product.dart';
import '../../../wishlist/presentation/state/wishlist_provider.dart';

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
          child: Card(
            clipBehavior: Clip.hardEdge,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      product.mainImage != null
                          ? Image.network(product.mainImage!, fit: BoxFit.cover)
                          : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 48)),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Consumer<WishlistProvider>(builder: (ctx, wp, ch) {
                          final inWishlist = wp.isInWishlist(product.id);
                          return GestureDetector(
                            onTap: () async {
                              // toggle wishlist and show a quick feedback
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
                              backgroundColor: Colors.white70,
                              child: Icon(inWishlist ? Icons.favorite : Icons.favorite_border, color: inWishlist ? Colors.red : Colors.grey),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text(product.price.toStringAsFixed(2), style: const TextStyle(color: Colors.green)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
