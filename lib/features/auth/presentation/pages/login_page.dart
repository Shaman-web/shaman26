import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaman/core/widgets/animated_fade_in.dart';
import 'package:shaman/core/widgets/app_button.dart';
import '../state/auth_provider.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/error_widget.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  List<String> _recentAccounts = [];

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    // token manager is available on the provider for saving recent accounts
    final tokenManager = authProvider.tokenManager;

    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول'), actions: [
        IconButton(onPressed: () => Navigator.pushNamedAndRemoveUntil(context, '/home', (r) => false), icon: const Icon(Icons.home)),
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: authProvider.status == AuthStatus.loading
            ? const LoadingWidget()
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnimatedFadeIn(child: TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'البريد الإلكتروني'))),
                    if (_recentAccounts.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: _recentAccounts.map((e) => ActionChip(label: Text(e), onPressed: () {
                          setState(() {
                            _emailController.text = e;
                          });
                        })).toList(),
                      ),
                    ],
                    const SizedBox(height: 8),
                    AnimatedFadeIn(child: TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'كلمة المرور'), obscureText: true)),
                    const SizedBox(height: 16),
                    AnimatedFadeIn(
                      child: AppButton(
                        label: 'تسجيل الدخول',
                        onPressed: () async {
                          // capture navigator/messenger before awaiting to avoid using BuildContext across async gaps
                          final messenger = ScaffoldMessenger.of(context);
                          final navigator = Navigator.of(context);
                          await authProvider.login(email: _emailController.text, password: _passwordController.text);
                          if (!mounted) return;
                          // safe: checked mounted above
                          final status = authProvider.status;
                          if (status == AuthStatus.authenticated) {
                            messenger.showSnackBar(const SnackBar(content: Text('تم تسجيل الدخول بنجاح')));
                            try {
                              // save this account as recently used
                              await tokenManager.saveRecentAccount(_emailController.text);
                            } catch (_) {}
                            // If this page was pushed (can pop), pop with true so caller can resume actions.
                            if (navigator.canPop()) {
                              navigator.pop(true);
                            } else {
                              // Otherwise behave as before and go to home.
                              navigator.pushReplacementNamed('/home');
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    AnimatedFadeIn(child: TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterPage())), child: const Text('إنشاء حساب جديد'))),
                    if (authProvider.status == AuthStatus.error) AnimatedFadeIn(child: AppErrorWidget(message: authProvider.errorMessage)),
                  ],
                ),
              ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final list = await authProvider.tokenManager.getRecentAccounts();
        if (!mounted) return;
        setState(() {
          _recentAccounts = list;
        });
      } catch (_) {}
    });
  }
}