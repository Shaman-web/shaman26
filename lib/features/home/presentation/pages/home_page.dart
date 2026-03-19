import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shaman/core/widgets/animated_fade_in.dart';
import 'package:shaman/core/widgets/app_button.dart';
import 'package:shaman/core/widgets/avatar_header.dart';
import 'package:shaman/core/widgets/app_text_field.dart';
import 'package:shaman/core/widgets/rounded_card.dart';
import 'package:shaman/features/products/presentation/widgets/product_card.dart';
import 'package:shaman/features/categories/presentation/widgets/category_card.dart';
import 'package:shaman/features/products/presentation/state/products_provider.dart';
import 'package:shaman/features/categories/presentation/state/categories_provider.dart';
import 'package:shaman/features/offers/presentation/state/offers_provider.dart';
import 'package:shaman/features/offers/presentation/widgets/offer_card.dart';
import 'package:shaman/features/offers/presentation/pages/offers_page.dart';
import 'package:shaman/features/categories/presentation/pages/category_details_page.dart';
import 'package:shaman/features/products/presentation/pages/product_details_page.dart';
import 'package:shaman/features/sellershop/presentation/state/sellers_provider.dart';
import 'package:shaman/features/sellershop/presentation/widgets/seller_card.dart';
import 'package:shaman/features/sellershop/presentation/pages/seller_details_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _featuredController = PageController(viewportFraction: 0.88);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductsProvider>(context, listen: false).fetchAll();
      Provider.of<CategoriesProvider>(context, listen: false).fetchAll();
      try {
        Provider.of<SellersProvider>(context, listen: false).fetchAll();
      } catch (_) {}
      try {
        Provider.of<OffersProvider>(context, listen: false).fetchPublicOffers();
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _featuredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final productsProv = Provider.of<ProductsProvider>(context);
    final categoriesProv = Provider.of<CategoriesProvider>(context);

    final featured = productsProv.items.take(5).toList();
    final latest = productsProv.items;
    final cats = categoriesProv.items;
  final offersProv = Provider.of<OffersProvider>(context);
  final offers = offersProv.items;
  final sellersProv = Provider.of<SellersProvider>(context);
  final sellers = sellersProv.items;

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await productsProv.fetchAll();
            await categoriesProv.fetchAll();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top: avatar + search
                  AnimatedFadeIn(
                    child: Row(
                      children: [
                        const AvatarHeader(name: null, subtitle: null),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 4.0),
                            child: AppTextField(controller: TextEditingController(), label: 'ابحث عن منتج أو متجر', prefixIcon: const Icon(Icons.search)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sellers shops section — always show header; show loader/error/empty/list
                  AnimatedFadeIn(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text('متاجر البائعين', style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 200,
                        child: Builder(builder: (ctx) {
                          // show states: loading, error, empty, or list
                          if (sellersProv.status == SellersStatus.loading) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (sellersProv.status == SellersStatus.error) {
                            return Center(child: Text(sellersProv.errorMessage ?? 'فشل تحميل المتاجر'));
                          }
                          if (sellers.isEmpty) {
                            return const Center(child: Text('لا توجد متاجر متاحة حالياً'));
                          }

                          return ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (ctx, i) {
                              final s = sellers[i];
                              return SizedBox(
                                width: 160,
                                child: SellerCard(
                                  seller: s,
                                  onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => SellerDetailsPage(sellerId: s.id))),
                                ),
                              );
                            },
                            separatorBuilder: (context, index) => const SizedBox(width: 12),
                            itemCount: sellers.length,
                          );
                        }),
                      ),
                    ]),
                  ),


                  // Offers section
                  if (offers.isNotEmpty)
                    AnimatedFadeIn(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('العروض المؤقتة', style: TextStyle(fontWeight: FontWeight.bold)),
                              TextButton(
                                onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const OffersPage())),
                                child: const Text('عرض الكل'),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 220,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (ctx, i) {
                              final of = offers[i];
                              return SizedBox(width: 160, child: OfferCard(offer: of, onTap: () async {
                                // open product details
                                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailsPage(productId: of.productId)));
                                productsProv.fetchAll();
                              }));
                            },
                            separatorBuilder: (ctx2, idx) => const SizedBox(width: 12),
                            itemCount: offers.length,
                          ),
                        ),
                      ]),
                    ),


                  // Banner
                  AnimatedFadeIn(
                    child: RoundedCard(
                      padding: const EdgeInsets.all(12),
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text('تخفيضات الربيع', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                                    SizedBox(height: 8),
                                    Text('اكتشف أفضل العروض اليوم', style: TextStyle(color: Colors.white70)),
                                  ],
                                ),
                              ),
                              AppButton(label: 'تسوّق الآن', onPressed: () {}),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categories horizontal
                  AnimatedFadeIn(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Padding(padding: EdgeInsets.symmetric(vertical: 4.0), child: Text('التصنيفات', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(
                        height: 160,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (ctx, i) {
                            final c = cats[i];
                            return SizedBox(width: 140, child: CategoryCard(category: c, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => CategoryDetailsPage(category: c)))));
                          },
                          separatorBuilder: (context, index) => const SizedBox(width: 12),
                          itemCount: cats.length,
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Featured products carousel
                  AnimatedFadeIn(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Padding(padding: EdgeInsets.symmetric(vertical: 4.0), child: Text('مميزة', style: TextStyle(fontWeight: FontWeight.bold))),
                      SizedBox(
                        height: 260,
                        child: PageView.builder(
                          controller: _featuredController,
                          itemCount: featured.length,
                          itemBuilder: (ctx, i) {
                            final p = featured[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: ProductCard(product: p, onTap: () async {
                                await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailsPage(productId: p.id)));
                                productsProv.fetchAll();
                              }),
                            );
                          },
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(height: 16),

                  // Latest products grid
                  AnimatedFadeIn(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Padding(padding: EdgeInsets.symmetric(vertical: 4.0), child: Text('الأحدث', style: TextStyle(fontWeight: FontWeight.bold))),
                      const SizedBox(height: 8),
                      GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: latest.length,
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 0.7, crossAxisSpacing: 12, mainAxisSpacing: 12),
                        itemBuilder: (ctx, i) {
                          final p = latest[i];
                          return ProductCard(product: p, onTap: () async {
                            await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProductDetailsPage(productId: p.id)));
                            productsProv.fetchAll();
                          });
                        },
                      ),
                    ]),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
