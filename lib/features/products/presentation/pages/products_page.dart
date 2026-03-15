import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaman/core/widgets/animated_fade_in.dart';
import '../state/products_provider.dart';
import '../widgets/product_card.dart';
import 'product_form_page.dart';
import 'product_details_page.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ProductsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('المنتجات'), actions: [
        IconButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false), icon: const Icon(Icons.home)),
      ]),
      body: _buildBody(provider),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final createdId = await Navigator.of(context).push<int?>(
            MaterialPageRoute(builder: (_) => const ProductFormPage()),
          );
          if (createdId != null) {
            // refresh list
            provider.fetchAll();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(ProductsProvider provider) {
    switch (provider.status) {
      case ProductsStatus.loading:
        return const Center(child: CircularProgressIndicator());
      case ProductsStatus.loaded:
        if (provider.items.isEmpty) return const Center(child: Text('لا توجد منتجات'));
        return RefreshIndicator(
          onRefresh: () => provider.fetchAll(),
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: provider.items.length,
            itemBuilder: (context, i) {
              final item = provider.items[i];
              return AnimatedFadeIn(
                child: ProductCard(
                  product: item,
                  onTap: () async {
                    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailsPage(productId: item.id)));
                    provider.fetchAll();
                  },
                ),
              );
            },
          ),
        );
      case ProductsStatus.error:
        return Center(child: Text(provider.error));
      default:
        return const SizedBox.shrink();
    }
  }
}
