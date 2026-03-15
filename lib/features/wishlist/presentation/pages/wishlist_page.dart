import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/wishlist_provider.dart';
import '../../../products/presentation/pages/product_details_page.dart';

class WishlistPage extends StatefulWidget {
  const WishlistPage({super.key});

  @override
  State<WishlistPage> createState() => _WishlistPageState();
}

class _WishlistPageState extends State<WishlistPage> {
  final Set<int> _removing = {};

  @override
  void initState() {
    super.initState();
    // trigger initial load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final prov = Provider.of<WishlistProvider>(context, listen: false);
      prov.fetchMyWishlist();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: Consumer<WishlistProvider>(builder: (ctx, wp, ch) {
        if (wp.status == WishlistStatus.loading && wp.items.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (wp.status == WishlistStatus.error && wp.items.isEmpty) {
          return Center(child: Text('خطأ: ${wp.error}'));
        }
        if (wp.items.isEmpty) return const Center(child: Text('لا توجد منتجات في المفضلة'));

        return GridView.builder(
          padding: const EdgeInsets.all(12),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: wp.items.length,
          itemBuilder: (ctx, i) {
            final item = wp.items[i];
            return InkWell(
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailsPage(productId: item.productId))),
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
                          AnimatedOpacity(
                            opacity: _removing.contains(item.productId) ? 0.0 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            child: AnimatedScale(
                              scale: _removing.contains(item.productId) ? 0.9 : 1.0,
                              duration: const Duration(milliseconds: 250),
                              child: item.mainImage != null
                                  ? Image.network(item.mainImage!, fit: BoxFit.cover)
                                  : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 48)),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: GestureDetector(
                              onTap: () async {
                                final messenger = ScaffoldMessenger.of(context);
                                final confirmed = await showDialog<bool>(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                    title: const Text('تأكيد'),
                                    content: const Text('هل تريد حذف هذا المنتج من المفضلة؟'),
                                    actions: [
                                      TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('لا')),
                                      TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('نعم')),
                                    ],
                                  ),
                                );
                                if (confirmed != true) return;
                                if (!mounted) return;
                                setState(() => _removing.add(item.productId));
                                await Future.delayed(const Duration(milliseconds: 250));
                                if (!mounted) return;
                                try {
                                  // Use toggle endpoint which is supported by backend and used elsewhere in the app.
                                  final added = await wp.toggle(item.productId);
                                  if (!mounted) return;
                                  // refresh authoritative list
                                  await wp.fetchMyWishlist();
                                  messenger.showSnackBar(SnackBar(content: Text(added ? 'تمت الإضافة للمفضلة' : 'تم الحذف من المفضلة')));
                                } catch (e) {
                                  if (!mounted) return;
                                  messenger.showSnackBar(SnackBar(content: Text('فشل الحذف: ${e.toString()}')));
                                  setState(() => _removing.remove(item.productId));
                                }
                              },
                              child: const CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.white70,
                                child: Icon(Icons.favorite, color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text((item.price ?? 0.0).toStringAsFixed(2), style: const TextStyle(color: Colors.green)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
