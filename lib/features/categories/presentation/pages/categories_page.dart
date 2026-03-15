import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaman/core/widgets/animated_fade_in.dart';
import '../state/categories_provider.dart';
import '../widgets/category_card.dart';
import 'category_form_page.dart';
import 'category_details_page.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CategoriesProvider>(context, listen: false).fetchAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<CategoriesProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('التصنيفات'), actions: [
        IconButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false), icon: const Icon(Icons.home)),
      ]),
      body: RefreshIndicator(
        onRefresh: prov.fetchAll,
        child: Builder(builder: (context) {
          if (prov.status == CategoriesStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (prov.status == CategoriesStatus.error) {
            return Center(child: Text('خطأ: ${prov.error}'));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 3 / 4,
            ),
            itemCount: prov.items.length,
            itemBuilder: (context, index) {
              final cat = prov.items[index];
              return AnimatedFadeIn(
                child: CategoryCard(
                  category: cat,
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => CategoryDetailsPage(category: cat)));
                  },
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const CategoryFormPage()));
          prov.fetchAll();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
