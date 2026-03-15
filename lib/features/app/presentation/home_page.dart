import 'package:flutter/material.dart';
import '../../products/presentation/widgets/product_card.dart';
import '../../categories/presentation/state/categories_provider.dart';
import 'package:provider/provider.dart';
import '../../products/presentation/state/products_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).fetchAll();
      Provider.of<CategoriesProvider>(context, listen: false).fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final products = Provider.of<ProductsProvider>(context);
    final categories = Provider.of<CategoriesProvider>(context);
    return Column(
      children: [
        // hero banner
        Container(
          height: 160,
          margin: const EdgeInsets.all(12),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.blueAccent),
          child: Stack(children: [
            Positioned(left: 16, top: 24, child: Text('عروض خاصة', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.white))),
            Positioned(left: 16, bottom: 16, child: ElevatedButton(onPressed: () {}, child: const Text('تسوّق الآن'))),
          ]),
        ),
        // categories chips
        SizedBox(
          height: 56,
          child: categories.status == CategoriesStatus.loaded && categories.items.isNotEmpty
              ? ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemBuilder: (context, i) => Chip(label: Text(categories.items[i].name)),
                  separatorBuilder: (context, index) => const SizedBox(width: 8),
                  itemCount: categories.items.length,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 8),
        // products grid
        Expanded(
          child: products.status == ProductsStatus.loaded
              ? GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
                  itemCount: products.items.length,
                  itemBuilder: (context, i) => ProductCard(product: products.items[i], onTap: () {}),
                )
              : const Center(child: CircularProgressIndicator()),
        ),
      ],
    );
  }
}
