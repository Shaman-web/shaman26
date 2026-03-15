import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/student_profile.dart';
import '../state/student_profile_provider.dart';
import 'package:shaman/core/widgets/animated_fade_in.dart';
import 'package:shaman/core/widgets/avatar_header.dart';

class StudentProfilePage extends StatefulWidget {
  const StudentProfilePage({super.key});

  @override
  State<StudentProfilePage> createState() => _StudentProfilePageState();
}

class _StudentProfilePageState extends State<StudentProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _majorCtrl = TextEditingController();
  final _univCtrl = TextEditingController();
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProfileProvider>(context, listen: false).fetchProfile();
    });
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _majorCtrl.dispose();
    _univCtrl.dispose();
    super.dispose();
  }

  void _enterEdit() {
  final prov = Provider.of<StudentProfileProvider>(context, listen: false);
  final StudentProfile? p = prov.profile;
    _nameCtrl.text = p?.name ?? '';
    _emailCtrl.text = p?.email ?? '';
    _phoneCtrl.text = p?.phone ?? '';
    _majorCtrl.text = p?.major ?? '';
    _univCtrl.text = p?.university ?? '';
    setState(() => _editing = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي للطالب'), actions: [
        IconButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false), icon: const Icon(Icons.home)),
      ]),
      body: Consumer<StudentProfileProvider>(builder: (context, prov, _) {
        if (prov.status == StudentProfileStatus.loading && prov.profile == null) {
          return const Center(child: CircularProgressIndicator());
        }
        final p = prov.profile;
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // header with avatar and info (animated)
                AnimatedFadeIn(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: AvatarHeader(name: p?.name, subtitle: p?.email, onEdit: _enterEdit),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _editing ? _buildForm(prov) : _buildDisplay(p, prov),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildDisplay(StudentProfile? p, StudentProfileProvider prov) {
    if (p == null) return const Text('لا توجد بيانات لعرضها');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('الاسم: ${p.name ?? ''}', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text('البريد الإلكتروني: ${p.email ?? ''}', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text('الهاتف: ${p.phone ?? ''}', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text('التخصص: ${p.major ?? ''}', style: const TextStyle(fontSize: 16)),
        const SizedBox(height: 8),
        Text('الجامعة: ${p.university ?? ''}', style: const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildForm(StudentProfileProvider prov) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(controller: _nameCtrl, decoration: const InputDecoration(labelText: 'الاسم'), validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null),
          const SizedBox(height: 8),
          TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'البريد الإلكتروني'), validator: (v) => v == null || v.isEmpty ? 'مطلوب' : null),
          const SizedBox(height: 8),
          TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'الهاتف')),
          const SizedBox(height: 8),
          TextFormField(controller: _majorCtrl, decoration: const InputDecoration(labelText: 'التخصص')),
          const SizedBox(height: 8),
          TextFormField(controller: _univCtrl, decoration: const InputDecoration(labelText: 'الجامعة')),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                 child: ElevatedButton(
                onPressed: () async {
                  if (!_formKey.currentState!.validate()) return;
                  try {
                    await prov.update(name: _nameCtrl.text.trim(), email: _emailCtrl.text.trim(), phone: _phoneCtrl.text.trim(), major: _majorCtrl.text.trim(), university: _univCtrl.text.trim());
                    if (!mounted) return;
                    setState(() => _editing = false);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم حفظ البيانات')));
                  } catch (e) {
                    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                  }
                },
              child: const Text('حفظ'),
            )),
            const SizedBox(width: 8),
            Expanded(
                child: OutlinedButton(
              onPressed: () => setState(() => _editing = false),
              child: const Text('إلغاء'),
            )),
          ])
        ],
      ),
    );
  }
}
