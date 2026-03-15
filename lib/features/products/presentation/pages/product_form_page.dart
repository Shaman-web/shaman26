import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../../../auth/presentation/state/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import '../../../../core/constants/api_constants.dart';
import '../../presentation/state/products_provider.dart';
import '../../../categories/presentation/state/categories_provider.dart';

class ProductFormPage extends StatefulWidget {
  final int? productId; // null => create
  const ProductFormPage({super.key, this.productId});

  @override
  State<ProductFormPage> createState() => _ProductFormPageState();
}

class _ProductFormPageState extends State<ProductFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _desc = TextEditingController();
  final _price = TextEditingController();
  final _qty = TextEditingController();
  final _discount = TextEditingController(text: '0');
  String? _localImagePath;
  Uint8List? _imageBytes;
  String? _imageFilename;
  int? _selectedCategoryId;
  int? _selectedSellerId;
  List<Map<String, dynamic>> _sellers = [];
  bool _loadingSellers = false;

  @override
  void dispose() {
    _name.dispose();
    _desc.dispose();
    _price.dispose();
    _qty.dispose();
    _discount.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        _imageBytes = bytes;
        _localImagePath = picked.path;
        _imageFilename = picked.name;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // ensure categories are loaded and load sellers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoriesProv = Provider.of<CategoriesProvider>(context, listen: false);
      if (categoriesProv.status != CategoriesStatus.loaded) {
        categoriesProv.fetchAll();
      }
      _loadSellers();
    });
  }

  Future<void> _loadSellers() async {
    setState(() {
      _loadingSellers = true;
    });
    final client = http.Client();
    final candidates = ['/sellers', '/users/sellers', '/users'];
    for (final p in candidates) {
      try {
        final uri = Uri.parse('${ApiConstants.baseUrl}$p');
        final res = await client.get(uri);
        if (res.statusCode >= 200 && res.statusCode < 300) {
          final List<dynamic> json = res.body.isNotEmpty ? (jsonDecode(res.body) as List<dynamic>) : [];
          _sellers = json.map((e) {
            final map = e as Map<String, dynamic>;
            final id = map['id'] ?? map['idUser'] ?? map['idSeller'] ?? 0;
            final name = map['name'] ?? map['fullName'] ?? map['email'] ?? '';
            return {'id': id, 'name': name};
          }).toList();
          break;
        }
      } catch (_) {
        // try next candidate
      }
    }
    setState(() {
      _loadingSellers = false;
    });
  }

  @override
  Widget build(BuildContext context) {
  final provider = Provider.of<ProductsProvider>(context, listen: false);
  final authProv = Provider.of<AuthProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(title: Text(widget.productId == null ? 'إضافة منتج' : 'تعديل منتج')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              GestureDetector(
                onTap: _pickImage,
        child: _imageBytes != null
          ? Image.memory(_imageBytes!, height: 180, fit: BoxFit.cover)
          : Container(height: 180, color: Colors.grey[200], child: const Icon(Icons.add_a_photo, size: 48)),
              ),
              const SizedBox(height: 12),
              TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم'), validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null),
              const SizedBox(height: 8),
              TextFormField(controller: _desc, decoration: const InputDecoration(labelText: 'الوصف'), maxLines: 3),
              const SizedBox(height: 8),
              TextFormField(controller: _price, decoration: const InputDecoration(labelText: 'السعر'), keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null),
              const SizedBox(height: 8),
              TextFormField(controller: _qty, decoration: const InputDecoration(labelText: 'الكمية'), keyboardType: TextInputType.number, validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null),
              const SizedBox(height: 8),
              TextFormField(controller: _discount, decoration: const InputDecoration(labelText: 'الخصم'), keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              // Category dropdown (from CategoriesProvider)
              Builder(builder: (ctx) {
                final catProv = Provider.of<CategoriesProvider>(ctx);
                if (catProv.status == CategoriesStatus.loading) return const CircularProgressIndicator();
                final items = catProv.items;
                return DropdownButtonFormField<int>(
                  initialValue: _selectedCategoryId ?? (items.isNotEmpty ? items.first.id : null),
                  decoration: const InputDecoration(labelText: 'التصنيف'),
                  items: items.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                  onChanged: (v) => setState(() => _selectedCategoryId = v),
                  validator: (v) => v == null ? 'اختر التصنيف' : null,
                );
              }),
              const SizedBox(height: 12),
              // Seller dropdown (fetched from API candidates)
        _loadingSellers
                  ? const Center(child: CircularProgressIndicator())
                  : (_sellers.isEmpty
                      ? const Text('لا توجد قائمة بائعين متاحة')
            : DropdownButtonFormField<int>(
              initialValue: _selectedSellerId ?? authProv.user?.idUser ?? (_sellers.isNotEmpty ? _sellers.first['id'] as int? : null),
                          decoration: const InputDecoration(labelText: 'البائع'),
                          items: _sellers.map((s) => DropdownMenuItem(value: s['id'] as int, child: Text(s['name'] ?? ''))).toList(),
                          onChanged: (v) => setState(() => _selectedSellerId = v),
                          validator: (v) {
                            // allow empty selection if we can infer from authenticated user
                            if (v == null && authProv.user == null) return 'اختر البائع';
                            return null;
                          },
                        )),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  // capture navigator and messenger before awaits to avoid context-after-await
                  final nav = Navigator.of(context);
                  final messenger = ScaffoldMessenger.of(context);
                  try {
                    final name = _name.text.trim();
                    final desc = _desc.text.trim();
                    final price = double.tryParse(_price.text) ?? 0.0;
                    final qty = int.tryParse(_qty.text) ?? 0;
                    final discount = double.tryParse(_discount.text) ?? 0.0;
                    // use selected category and seller (fall back to authenticated user id)
                    final categoryId = _selectedCategoryId ?? 1;
                    final sellerId = _selectedSellerId ?? authProv.user?.idUser;
                    if (sellerId == null) {
                      messenger.showSnackBar(const SnackBar(content: Text('تعذر استخراج معرف المستخدم. الرجاء تسجيل الدخول أو اختيار البائع.')));
                      return;
                    }
                    if (widget.productId == null) {
                      final id = await provider.createProduct(
                        name: name,
                        description: desc.isEmpty ? null : desc,
                        price: price,
                        qty: qty,
                        discount: discount,
                        categoryId: categoryId,
                        sellerId: sellerId,
                        localImagePath: _localImagePath,
                        imageBytes: _imageBytes,
                        imageFilename: _imageFilename,
                      );
                      if (!mounted) return;
                      nav.pop(id);
                    } else {
                        await provider.updateProduct(
                          id: widget.productId!,
                          name: name,
                          description: desc.isEmpty ? null : desc,
                          price: price,
                          qty: qty,
                          discount: discount,
                          categoryId: categoryId,
                          localImagePath: _localImagePath,
                          imageBytes: _imageBytes,
                          imageFilename: _imageFilename,
                        );
                      if (!mounted) return;
                      nav.pop(null);
                    }
                  } catch (e) {
                    messenger.showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
