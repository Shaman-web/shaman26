import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../wishlist/presentation/state/wishlist_provider.dart';
import 'package:shaman/features/cart/presentation/state/cart_provider.dart';
import 'package:shaman/features/auth/presentation/pages/login_page.dart';
import 'package:shaman/features/auth/presentation/state/auth_provider.dart';
import '../../home/presentation/pages/home_page.dart';
import '../../categories/presentation/pages/categories_page.dart';
import '../../dashboard/presentation/pages/dashboard_page.dart';
import '../../auth/presentation/pages/profile_page.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _badgeController;
  late final Animation<double> _badgeScale;
  int _lastCartCount = 0;
  late final CartProvider _cart; // cache to avoid using context in dispose

  final List<Widget> _pages = [
    const HomePage(),
    const CategoriesPage(),
    const DashboardPage(),
    const ProfilePage(),
  ];

  void _onItemTapped(int index) {
    // if the profile tab is tapped, open the student profile page instead of switching
    if (index == 3) {
      Navigator.pushNamed(context, '/student-profile');
      return;
    }
    setState(() => _selectedIndex = index);
  }

  void _onCartChanged() {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final count = cart.items.length;
    if (count > _lastCartCount) {
      // pulse animation on add
      _badgeController.forward(from: 0.0);
    }
    _lastCartCount = count;
  }

  @override
  void initState() {
    super.initState();
    _badgeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _badgeScale = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(parent: _badgeController, curve: Curves.easeOut));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cart = Provider.of<CartProvider>(context, listen: false);
      _lastCartCount = _cart.items.length;
      _cart.addListener(_onCartChanged);
      // fetch wishlist so badge is populated
      try {
        Provider.of<WishlistProvider>(context, listen: false).fetchMyWishlist();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    // Use cached reference instead of looking up Provider using context during dispose
    _cart.removeListener(_onCartChanged);
    _badgeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shaman Store'),
        centerTitle: true,
        elevation: 2,
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
            Consumer<WishlistProvider>(builder: (ctx, wp, _) {
              final count = wp.items.length;
              final display = count > 99 ? '99+' : '$count';
              return IconButton(
                onPressed: () => Navigator.pushNamed(context, '/wishlist'),
                icon: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.favorite_border),
                    if (count > 0)
                      Positioned(
                        right: -6,
                        top: -6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white, width: 1.5)),
                          constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                          child: Text(
                            display,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                  ],
                ),
              );
            }),
          Consumer<CartProvider>(builder: (ctx, cart, _) {
            final count = cart.items.length;
            final display = count > 99 ? '99+' : '$count';
            return IconButton(
              onPressed: () => Navigator.pushNamed(context, '/cart'),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_cart),
                  if (count > 0)
                    Positioned(
                      right: -6,
                      top: -6,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
                        child: ScaleTransition(
                          key: ValueKey(display),
                          scale: _badgeScale,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white, width: 1.5)),
                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
                            child: Text(
                              display,
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              ),
            );
          }),
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12.0),
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Column(children: const [
                      SizedBox(height: 8),
                      CircleAvatar(radius: 28, child: Icon(Icons.person)),
                      SizedBox(height: 8),
                      Text('مرحبا', style: TextStyle(fontWeight: FontWeight.bold)),
                      SizedBox(height: 4),
                      Text('user@example.com', style: TextStyle(color: Colors.grey)),
                      SizedBox(height: 8),
                    ]),
                  ),
                ),
              ),
              ListTile(leading: const Icon(Icons.store), title: const Text('المتجر'), onTap: () => Navigator.pop(context)),
              ListTile(leading: const Icon(Icons.list_alt), title: const Text('طلباتي'), onTap: () => Navigator.pushNamed(context, '/orders')),
              ListTile(leading: const Icon(Icons.dashboard), title: const Text('لوحة التحكم'), onTap: () => setState(() => _selectedIndex = 2)),
              ListTile(leading: const Icon(Icons.category), title: const Text('التصنيفات'), onTap: () => setState(() => _selectedIndex = 1)),
              ListTile(leading: const Icon(Icons.school), title: const Text('الملف الدراسي'), onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/student-profile');
              }),
              const Spacer(),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('تسجيل الخروج'),
                onTap: () async {
                  // close drawer first
                  Navigator.pop(context);

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('تأكيد'),
                      content: const Text('هل تريد تسجيل الخروج؟'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('إلغاء')),
                        TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('تسجيل الخروج')),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  final messenger = ScaffoldMessenger.of(context);
                  final auth = Provider.of<AuthProvider>(context, listen: false);

                  try {
                    await auth.logout();
                    if (!mounted) return;
                    messenger.showSnackBar(const SnackBar(content: Text('تم تسجيل الخروج')));
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  } catch (e) {
                    if (!mounted) return;
                    messenger.showSnackBar(SnackBar(content: Text('خطأ أثناء تسجيل الخروج: ${e.toString()}')));
                  }
                },
              ),
            ],
          ),
        ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          final offsetAnim = Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(animation);
          return FadeTransition(opacity: animation, child: SlideTransition(position: offsetAnim, child: child));
        },
        child: _pages[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'الأقسام'),
          BottomNavigationBarItem(icon: Icon(Icons.pie_chart), label: 'لوحة التحكم'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'الملف'),
        ],
      ),
    );
  }
}
