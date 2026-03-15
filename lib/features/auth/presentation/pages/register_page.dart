import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaman/core/widgets/animated_fade_in.dart';
import 'package:shaman/core/widgets/app_button.dart';
import '../state/auth_provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  int _roleId = 1;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب'), actions: [
        IconButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false), icon: const Icon(Icons.home)),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: authProvider.status == AuthStatus.loading
            ? const LoadingWidget()
            : SingleChildScrollView(
                child: Column(
                  children: [
                    AnimatedFadeIn(child: TextField(controller: _nameController, decoration: const InputDecoration(labelText: 'الاسم'))),
                    AnimatedFadeIn(child: TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'البريد الإلكتروني'))),
                    AnimatedFadeIn(child: TextField(controller: _phoneController, decoration: const InputDecoration(labelText: 'رقم الهاتف'))),
                    AnimatedFadeIn(child: TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'كلمة المرور'), obscureText: true)),
                    AnimatedFadeIn(
                      child: DropdownButton<int>(
                        value: _roleId,
                        items: const [
                          DropdownMenuItem(value: 1, child: Text('Seller')),
                          DropdownMenuItem(value: 2, child: Text('Student')),
                          DropdownMenuItem(value: 3, child: Text('Admin')),
                        ],
                        onChanged: (value) {
                          setState(() => _roleId = value!);
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedFadeIn(
                      child: AppButton(
                        label: 'إنشاء حساب',
                        onPressed: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          await authProvider.register(
                            name: _nameController.text,
                            email: _emailController.text,
                            password: _passwordController.text,
                            phone: _phoneController.text,
                            roleId: _roleId,
                          );
                          if (!mounted) return;
                          if (authProvider.status == AuthStatus.authenticated) {
                            messenger.showSnackBar(const SnackBar(content: Text('تم إنشاء الحساب بنجاح')));
                            navigator.pop();
                          }
                        },
                      ),
                    ),
                    if (authProvider.status == AuthStatus.error) AnimatedFadeIn(child: AppErrorWidget(message: authProvider.errorMessage)),
                  ],
                ),
              ),
      ),
    );
  }
}