import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaman/core/widgets/animated_fade_in.dart';
import 'package:shaman/core/widgets/app_button.dart';
import '../../domain/entities/category.dart';
import '../state/categories_provider.dart';
import 'category_form_page.dart';

class CategoryDetailsPage extends StatelessWidget {
  final Category category;
  const CategoryDetailsPage({super.key, required this.category});

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<CategoriesProvider>(context, listen: false);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(category.name),
              background: category.imageUrl != null
                  ? Hero(
                      tag: 'cat-${category.id}',
                      child: Image.network(category.imageUrl!, fit: BoxFit.cover),
                    )
                  : Container(color: Colors.grey[200]),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CategoryFormPage(id: category.id)));
                  prov.fetchAll();
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () async {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      title: const Text('تأكيد الحذف'),
                      content: const Text('هل أنت متأكد من حذف هذا التصنيف؟'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('إلغاء')),
                        ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('حذف')),
                      ],
                    ),
                  );
                  if (ok == true) {
                    try {
                      await prov.deleteCategory(category.id);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف')));
                      Navigator.of(context).pop();
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
                    }
                  }
                },
              )
              ,
              IconButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false), icon: const Icon(Icons.home))
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                AnimatedFadeIn(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text(category.description ?? '-', style: const TextStyle(fontSize: 16)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: AppButton(label: 'تعديل', onPressed: () async {
                                  await Navigator.of(context).push(MaterialPageRoute(builder: (_) => CategoryFormPage(id: category.id)));
                                  prov.fetchAll();
                                }),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 14)),
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (c) => AlertDialog(
                                        title: const Text('تأكيد الحذف'),
                                        content: const Text('هل أنت متأكد من حذف هذا التصنيف؟'),
                                        actions: [
                                          TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('إلغاء')),
                                          ElevatedButton(onPressed: () => Navigator.of(c).pop(true), child: const Text('حذف')),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      try {
                                        await prov.deleteCategory(category.id);
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم الحذف')));
                                        Navigator.of(context).pop();
                                      } catch (e) {
                                        if (!context.mounted) return;
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('خطأ: ${e.toString()}')));
                                      }
                                    }
                                  },
                                  icon: const Icon(Icons.delete),
                                  label: const Text('حذف'),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ]),
            ),
          )
        ],
      ),
    );
  }
}
