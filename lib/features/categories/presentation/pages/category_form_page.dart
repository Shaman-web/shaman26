import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../state/categories_provider.dart';

class CategoryFormPage extends StatefulWidget {
  final int? id; // null -> create
  const CategoryFormPage({super.key, this.id});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  XFile? _picked;
  bool _loading = false;

  Future<void> _loadIfEdit() async {
    if (widget.id == null) return;
    final prov = Provider.of<CategoriesProvider>(context, listen: false);
    try {
      final cat = await prov.fetchById(widget.id!);
      if (cat != null) {
        _nameController.text = cat.name;
        _descController.text = cat.description ?? '';
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadIfEdit());
  }

  Future<void> _pickImage() async {
    final p = ImagePicker();
    final x = await p.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (x != null) setState(() => _picked = x);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final prov = Provider.of<CategoriesProvider>(context, listen: false);
    final name = _nameController.text.trim();
    final desc = _descController.text.trim();

    setState(() => _loading = true);

    try {
      if (widget.id == null) {
        await prov.createCategory(name: name, description: desc.isEmpty ? null : desc, imageFile: _picked == null ? null : File(_picked!.path));
      } else {
        await prov.updateCategory(id: widget.id!, name: name, description: desc.isEmpty ? null : desc, imageFile: _picked == null ? null : File(_picked!.path));
      }
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: ${e.toString()}')));
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
    setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.id == null ? 'إضافة تصنيف' : 'تعديل تصنيف')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: Colors.grey[200]),
                  child: _picked == null
                      ? const Center(child: Icon(Icons.camera_alt, size: 48))
                      : Image.file(File(_picked!.path), fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'الاسم'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(labelText: 'الوصف (اختياري)'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _submit, child: _loading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)) : const Text('حفظ'))
            ],
          ),
        ),
      ),
    );
  }
}
