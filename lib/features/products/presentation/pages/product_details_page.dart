import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaman/features/cart/presentation/state/cart_provider.dart';
import 'package:shaman/core/widgets/animated_fade_in.dart';
import 'package:shaman/core/widgets/app_button.dart';
import '../../../productimages/presentation/widgets/product_images_widget.dart';
import '../../domain/entities/product.dart';
import '../state/products_provider.dart';
import '../state/reviews_provider.dart';
import '../../domain/entities/review.dart' as review_entity;
import '../../../wishlist/presentation/state/wishlist_provider.dart';
import 'product_form_page.dart';

class ProductDetailsPage extends StatefulWidget {
  final int productId;
  const ProductDetailsPage({super.key, required this.productId});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  Product? _product;
  
  int _newRating = 5;
  final TextEditingController _reviewController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final provider = Provider.of<ProductsProvider>(context, listen: false);
    final p = await provider.fetchById(widget.productId);
    if (!mounted) return;
    setState(() => _product = p);
    // load reviews for this product
    final reviewsProv = Provider.of<ReviewsProvider>(context, listen: false);
    await reviewsProv.fetchForProduct(widget.productId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المنتج'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: _product == null
                ? null
                : () async {
                    // capture provider before awaiting navigation to avoid using context across async gaps
                    final provider = Provider.of<ProductsProvider>(
                      context,
                      listen: false,
                    );
                    final nav = Navigator.of(context);
                    await nav.push(
                      MaterialPageRoute(
                        builder: (_) =>
                            ProductFormPage(productId: _product!.id),
                      ),
                    );
                    // refresh using captured provider
                    final p = await provider.fetchById(widget.productId);
                    if (!mounted) return;
                    setState(() => _product = p);
                  },
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _product == null
                ? null
                : () async {
                    final provider = Provider.of<ProductsProvider>(
                      context,
                      listen: false,
                    );
                    final nav = Navigator.of(context);
                    final messenger = ScaffoldMessenger.of(context);
                    final ok = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('تأكيد'),
                        content: const Text('حذف المنتج؟'),
                        actions: [
                          TextButton(
                            onPressed: Navigator.of(context).pop,
                            child: const Text('لا'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text('نعم'),
                          ),
                        ],
                      ),
                    );
                    if (ok == true) {
                      try {
                        await provider.deleteProduct(_product!.id);
                        if (!mounted) return;
                        nav.pop();
                      } catch (e) {
                        messenger.showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    }
                  },
          ),
            // wishlist toggle
            Consumer<WishlistProvider>(builder: (ctx, wp, ch) {
              final inWishlist = _product == null ? false : wp.isInWishlist(_product!.id);
              return IconButton(
                icon: Icon(inWishlist ? Icons.favorite : Icons.favorite_border, color: inWishlist ? Colors.red : null),
                onPressed: _product == null
                    ? null
                    : () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final added = await wp.toggle(_product!.id);
                          messenger.showSnackBar(SnackBar(content: Text(added ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة')));
                        } catch (e) {
                          messenger.showSnackBar(SnackBar(content: Text('فشل العملية: ${e.toString()}')));
                        }
                      },
              );
            }),
          IconButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false), icon: const Icon(Icons.home)),
        ],
      ),
      body: _product == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(_product!),
    );
  }

  Future<void> _handleAddToCart() async {
    if (_product == null) return;
    final cartProv = Provider.of<CartProvider>(context, listen: false);
    final messenger = ScaffoldMessenger.of(context);
    try {
      await cartProv.addToCart(_product!.id);
      messenger.showSnackBar(const SnackBar(content: Text('تمت الإضافة إلى السلة')));
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('فشل الإضافة: ${e.toString()}')));
    }
  }

  Widget _buildBody(Product p) {
    return ListView(
      children: [
        if (p.mainImage != null)
          GestureDetector(
            onTap: () => showDialog(
              context: context,
              builder: (_) => Dialog(
                child: InteractiveViewer(
                  // Avoid wrapping the dialog image with a Hero: showing a Dialog
                  // while the original Hero is still in the widget tree can produce
                  // "multiple heroes with same tag" errors. The outer Hero on the
                  // details page is sufficient for navigations.
                  child: Image.network(p.mainImage!, fit: BoxFit.contain),
                ),
              ),
            ),
            child: Hero(
              tag: 'product-image-${p.id}',
              child: Image.network(p.mainImage!, height: 260, fit: BoxFit.cover),
            ),
          ),
        const SizedBox(height: 8),
        ProductImagesWidget(productId: p.id, height: 110),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: AnimatedFadeIn(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  title: const Text('الوصف'),
                  children: [Padding(padding: const EdgeInsets.all(8.0), child: Text(p.description ?? 'لا يوجد وصف'))],
                ),
                const SizedBox(height: 8),
                ExpansionTile(
                  title: const Text('التفاصيل'),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('الكمية: ${p.qty}'),
                        Text('التصنيف: ${p.categoryName ?? '-'}'),
                        Text('المتجر: ${p.storeName ?? '-'}'),
                        Text('السعر: ${p.price.toStringAsFixed(2)}'),
                      ]),
                    )
                  ],
                ),
                Text(
                  'السعر: ${p.price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green),
                ),
                const SizedBox(height: 8),
                Text('الكمية: ${p.qty}'),
                const SizedBox(height: 8),
                Text('التصنيف: ${p.categoryName ?? '-'}'),
                const SizedBox(height: 8),
                Text('المتجر: ${p.storeName ?? '-'}'),
                const SizedBox(height: 16),
                // rating + reviews summary
                Consumer<ReviewsProvider>(builder: (ctx, rp, ch) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRatingRow(rp.averageRating, rp.reviewsCount),
                      const SizedBox(height: 8),
                    ],
                  );
                }),

                Row(children: [
                  Expanded(
                    child: AppButton(
                      label: 'أضف إلى السلة',
                      onPressed: _product == null ? () {} : () { _handleAddToCart(); },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: AppButton(label: 'اشتري الآن', onPressed: () {})),
                ]),
                const SizedBox(height: 12),
                // reviews list
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Consumer<ReviewsProvider>(builder: (ctx, rp, ch) {
                    if (rp.status == ReviewsStatus.loading) return const Center(child: CircularProgressIndicator());
                    if (rp.status == ReviewsStatus.error) return Text('خطأ: ${rp.error}');
                    return _buildReviewsSection(rp.reviews);
                  }),
                ),
                const SizedBox(height: 12),
                // submit review form
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: _buildSubmitReviewForm(p.id),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingRow(double average, int count) {
    return Row(
      children: [
        Text('التقييم: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(children: _buildStarIcons(average)),
        const SizedBox(width: 8),
        Text('(${count.toString()})'),
      ],
    );
  }

  List<Widget> _buildStarIcons(double average) {
    final full = average.floor();
    final hasHalf = (average - full) >= 0.5;
    final stars = <Widget>[];
    for (var i = 0; i < full; i++) {
      stars.add(const Icon(Icons.star, color: Colors.amber, size: 18));
    }
    if (hasHalf) {
      stars.add(const Icon(Icons.star_half, color: Colors.amber, size: 18));
    }
    while (stars.length < 5) {
      stars.add(const Icon(Icons.star_border, color: Colors.amber, size: 18));
    }
    return stars;
  }

  Widget _buildReviewsSection(List<review_entity.Review> reviews) {
    if (reviews.isEmpty) return const Text('لا توجد تعليقات بعد');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: reviews.map((r) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.userName ?? 'مستخدم', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Row(children: List.generate(5, (i) => Icon(i < r.rating ? Icons.star : Icons.star_border, color: Colors.amber, size: 16))),
                  ],
                ),
                if (r.comment != null) const SizedBox(height: 6),
                if (r.comment != null) Text(r.comment!),
                if (r.createdAt != null) Align(alignment: Alignment.centerRight, child: Text(r.createdAt!.toLocal().toString().split('.').first, style: const TextStyle(fontSize: 10, color: Colors.grey))),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildSubmitReviewForm(int productId) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('أضف تقييمًا', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: List.generate(5, (i) {
              final idx = i + 1;
              return IconButton(
                icon: Icon(idx <= _newRating ? Icons.star : Icons.star_border, color: Colors.amber),
                onPressed: () => setState(() => _newRating = idx),
              );
            })),
            TextField(controller: _reviewController, decoration: const InputDecoration(hintText: 'اكتب رأيك هنا')),
            const SizedBox(height: 8),
            Consumer<ReviewsProvider>(builder: (ctx, rp, ch) {
              return Row(children: [
                Expanded(child: AppButton(label: 'إرسال', onPressed: rp.status == ReviewsStatus.submitting ? null : () {
                  // capture messenger to avoid using BuildContext across async gaps
                  final messenger = ScaffoldMessenger.of(context);
                  rp.submitReview(productId: productId, rating: _newRating, comment: _reviewController.text.trim()).then((_) {
                    if (!mounted) return;
                    _reviewController.clear();
                    setState(() => _newRating = 5);
                    messenger.showSnackBar(const SnackBar(content: Text('تم إرسال التقييم')));
                  }).catchError((e) {
                    messenger.showSnackBar(SnackBar(content: Text('فشل الإرسال: ${e.toString()}')));
                  });
                })),
              ]);
            }),
          ],
        ),
      ),
    );
  }
}
