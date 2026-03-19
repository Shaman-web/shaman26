import 'features/studentprofile/data/datasources/student_profile_remote_datasource.dart';
import 'features/studentprofile/data/repositories/student_profile_repository_impl.dart';
import 'features/studentprofile/domain/usecases/get_student_profile.dart';
import 'features/studentprofile/domain/usecases/update_student_profile.dart';
import 'features/studentprofile/presentation/state/student_profile_provider.dart';
import 'features/studentprofile/presentation/pages/student_profile_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/app_theme.dart';
import 'features/app/presentation/app_shell.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/state/auth_provider.dart';
import 'features/auth/domain/usecases/login_user.dart';
import 'features/auth/domain/usecases/register_user.dart';
import 'features/auth/domain/usecases/logout_user.dart';
import 'features/auth/domain/usecases/refresh_token.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'core/network/api_client.dart';
import 'core/constants/api_constants.dart';
import 'dart:io';
import 'package:http/io_client.dart';
import 'package:http/http.dart' as http;
import 'core/utils/token_manager.dart';
// categories feature
import 'features/categories/data/datasources/categories_remote_datasource.dart';
import 'features/categories/data/repositories/categories_repository_impl.dart';
import 'features/categories/domain/usecases/get_all_categories.dart';
import 'features/categories/domain/usecases/get_category_by_id.dart';
import 'features/categories/domain/usecases/create_category.dart';
import 'features/categories/domain/usecases/update_category.dart';
import 'features/categories/domain/usecases/delete_category.dart';
import 'features/categories/presentation/state/categories_provider.dart';
// products imports
import 'features/products/data/datasources/products_remote_datasource.dart';
import 'features/products/data/repositories/products_repository_impl.dart';
import 'features/products/domain/usecases/get_all_products.dart';
import 'features/products/domain/usecases/get_product_by_id.dart';
import 'features/products/domain/usecases/get_admin_products.dart';
import 'features/products/domain/usecases/create_product.dart';
import 'features/products/domain/usecases/update_product.dart';
import 'features/products/domain/usecases/toggle_active_product.dart';
import 'features/products/domain/usecases/delete_product.dart';
import 'features/products/presentation/state/products_provider.dart';
// reviews (product reviews)
import 'features/products/data/datasources/reviews_remote_datasource.dart';
import 'features/products/data/repositories/reviews_repository_impl.dart';
import 'features/products/domain/usecases/get_reviews_by_product_id.dart';
import 'features/products/domain/usecases/create_review.dart';
import 'features/products/presentation/state/reviews_provider.dart';
// offers
import 'features/offers/data/datasources/offers_remote_datasource.dart';
import 'features/offers/data/repositories/offers_repository_impl.dart';
import 'features/offers/domain/usecases/get_public_offers.dart';
import 'features/offers/presentation/state/offers_provider.dart';
// sellershop
import 'features/sellershop/data/datasources/sellers_remote_datasource.dart';
import 'features/sellershop/data/repositories/sellers_repository_impl.dart';
import 'features/sellershop/domain/usecases/get_all_sellers.dart';
import 'features/sellershop/presentation/state/sellers_provider.dart';
// wishlist
import 'features/wishlist/data/datasources/wishlist_remote_datasource.dart';
import 'features/wishlist/data/repositories/wishlist_repository_impl.dart';
import 'features/wishlist/domain/usecases/get_my_wishlist.dart';
import 'features/wishlist/domain/usecases/add_to_wishlist.dart';
import 'features/wishlist/domain/usecases/remove_from_wishlist.dart';
import 'features/wishlist/domain/usecases/toggle_wishlist.dart';
import 'features/wishlist/presentation/state/wishlist_provider.dart';
import 'features/wishlist/presentation/pages/wishlist_page.dart';
// product images imports
import 'features/productimages/data/datasources/product_images_remote_datasource.dart';
import 'features/productimages/data/repositories/product_images_repository_impl.dart';
import 'features/productimages/domain/usecases/get_all_product_images.dart';
import 'features/productimages/domain/usecases/get_images_by_product_id.dart';
import 'features/productimages/presentation/state/product_images_provider.dart';
// cart imports
import 'features/cart/data/datasources/cart_remote_datasource.dart';
import 'features/cart/presentation/state/cart_provider.dart';
import 'features/cart/presentation/pages/cart_page.dart';
import 'features/cart/presentation/pages/checkout_page.dart';
import 'features/cart/presentation/pages/checkout_thankyou_page.dart';
import 'features/cart/presentation/state/checkout_provider.dart';
import 'features/cart/data/datasources/checkout_remote_datasource.dart';
import 'features/cart/data/repositories/checkout_repository_impl.dart';
import 'features/cart/domain/usecases/get_payment_methods.dart';
import 'features/cart/domain/usecases/complete_checkout.dart';
import 'features/cart/data/repositories/cart_repository_impl.dart';
import 'features/cart/domain/usecases/get_cart_items.dart';
import 'features/cart/domain/usecases/add_to_cart.dart';
import 'features/cart/domain/usecases/update_cart_item.dart';
import 'features/cart/domain/usecases/delete_cart_item.dart';
import 'features/cart/domain/usecases/get_cart_item_by_id.dart';
// orders imports
import 'features/orders/data/datasources/orders_remote_datasource.dart';
import 'features/orders/data/repositories/orders_repository_impl.dart';
import 'features/orders/domain/usecases/get_my_orders.dart';
import 'features/orders/presentation/state/orders_provider.dart';
import 'features/orders/presentation/pages/orders_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // token manager first
  final tokenManager = TokenManager();

  // Create an http.Client that accepts self-signed certs when using localhost (development only)
  final http.Client sharedHttpClient = ApiConstants.baseUrl.contains('localhost')
    ? IOClient(HttpClient()..badCertificateCallback = (cert, host, port) => true)
    : http.Client();

  final apiClient = ApiClient(client: sharedHttpClient, tokenManager: tokenManager);
  final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);
  final authRepository = AuthRepositoryImpl(authRemoteDataSource);
  // categories wiring (pass tokenManager to include Authorization for admin endpoints)
  final categoriesRemoteDataSource = CategoriesRemoteDataSourceImpl(
    apiClient.client,
    tokenManager: tokenManager,
  );
  final categoriesRepository = CategoriesRepositoryImpl(
    categoriesRemoteDataSource,
  );
  // products wiring
  final productsRemoteDataSource = ProductsRemoteDataSourceImpl(
    apiClient.client,
    tokenManager: tokenManager,
  );
  final productsRepository = ProductsRepositoryImpl(productsRemoteDataSource);
    // student profile wiring
    final studentProfileRemoteDataSource = StudentProfileRemoteDataSourceImpl(apiClient.client, tokenManager: tokenManager);
    final studentProfileRepository = StudentProfileRepositoryImpl(studentProfileRemoteDataSource);
  // product images wiring
  final productImagesRemoteDataSource = ProductImagesRemoteDataSourceImpl(
    apiClient.client,
    tokenManager: tokenManager,
  );
  final productImagesRepository = ProductImagesRepositoryImpl(
    productImagesRemoteDataSource,
  );
  // reviews wiring
  final reviewsRemoteDataSource = ReviewsRemoteDataSourceImpl(apiClient.client, tokenManager: tokenManager);
  final reviewsRepository = ReviewsRepositoryImpl(reviewsRemoteDataSource);
  final getReviewsByProductId = GetReviewsByProductId(reviewsRepository);
  final createReview = CreateReview(reviewsRepository);
    // offers wiring
    final offersRemoteDataSource = OffersRemoteDataSourceImpl(apiClient.client, tokenManager: tokenManager);
    final offersRepository = OffersRepositoryImpl(offersRemoteDataSource);
    final getPublicOffers = GetPublicOffers(offersRepository);
      // sellershop wiring
      final sellersRemoteDataSource = SellersRemoteDataSourceImpl(apiClient.client, tokenManager: tokenManager);
      final sellersRepository = SellersRepositoryImpl(sellersRemoteDataSource);
      final getAllSellers = GetAllSellers(sellersRepository);
  // wishlist wiring
  final wishlistRemoteDataSource = WishlistRemoteDataSourceImpl(apiClient.client, tokenManager: tokenManager);
  final wishlistRepository = WishlistRepositoryImpl(wishlistRemoteDataSource);
  final getMyWishlist = GetMyWishlist(wishlistRepository);
  final addToWishlist = AddToWishlist(wishlistRepository);
  final removeFromWishlist = RemoveFromWishlist(wishlistRepository);
  final toggleWishlist = ToggleWishlist(wishlistRepository);
  // cart wiring
  final cartRemoteDataSource = CartRemoteDataSourceImpl(
    apiClient.client,
    tokenManager: tokenManager,
  );
  final cartRepository = CartRepositoryImpl(cartRemoteDataSource);
  final getCartItems = GetCartItems(cartRepository);
  final addToCart = AddToCart(cartRepository);
  final updateCartItem = UpdateCartItem(cartRepository);
  final deleteCartItem = DeleteCartItem(cartRepository);
  final getCartItemById = GetCartItemById(cartRepository);
  // checkout wiring
  final checkoutRemoteDataSource = CheckoutRemoteDataSourceImpl(apiClient.client, tokenManager: tokenManager);
  final checkoutRepository = CheckoutRepositoryImpl(checkoutRemoteDataSource);
  final getPaymentMethods = GetPaymentMethods(checkoutRepository);
  final completeCheckout = CompleteCheckout(checkoutRepository);

  // orders wiring
  final ordersRemoteDataSource = OrdersRemoteDataSourceImpl(apiClient.client, tokenManager: tokenManager);
  final ordersRepository = OrdersRepositoryImpl(ordersRemoteDataSource);
  final getMyOrders = GetMyOrders(ordersRepository);

  // determine whether we have a valid token to skip login screen
  final bool isLoggedIn = await tokenManager.hasValidAccessToken();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            registerUser: RegisterUser(authRepository),
            loginUser: LoginUser(authRepository),
            logoutUser: LogoutUser(authRepository),
            refreshTokenUseCase: RefreshTokenUseCase(authRepository),
            tokenManager: tokenManager,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CategoriesProvider(
            getAll: GetAllCategories(categoriesRepository),
            getById: GetCategoryById(categoriesRepository),
            create: CreateCategory(categoriesRepository),
            update: UpdateCategory(categoriesRepository),
            delete: DeleteCategory(categoriesRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => ProductsProvider(
            getAll: GetAllProducts(productsRepository),
            getById: GetProductById(productsRepository),
            getAdminProducts: GetAdminProducts(productsRepository),
            create: CreateProduct(productsRepository),
            update: UpdateProduct(productsRepository),
            toggleActive: ToggleActiveProduct(productsRepository),
            delete: DeleteProduct(productsRepository),
            tokenManager: tokenManager,
          ),
        ),
          ChangeNotifierProvider(
            create: (_) => StudentProfileProvider(
              getProfile: GetStudentProfile(studentProfileRepository),
              updateProfile: UpdateStudentProfile(studentProfileRepository),
              tokenManager: tokenManager,
            ),
          ),
        ChangeNotifierProvider(
          create: (_) => ProductImagesProvider(
            getAll: GetAllProductImages(productImagesRepository),
            getByProductId: GetImagesByProductId(productImagesRepository),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CartProvider(
            getAll: getCartItems,
            add: addToCart,
            update: updateCartItem,
            delete: deleteCartItem,
            getById: getCartItemById,
            client: apiClient.client,
            tokenManager: tokenManager,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => CheckoutProvider(getMethods: getPaymentMethods, complete: completeCheckout, tokenManager: tokenManager),
        ),
        ChangeNotifierProvider(
          create: (_) => OrdersProvider(getMyOrders: getMyOrders, tokenManager: tokenManager),
        ),
        ChangeNotifierProvider(
          create: (_) => ReviewsProvider(
            getReviews: getReviewsByProductId,
            createReview: createReview,
            tokenManager: tokenManager,
          ),
        ),
        ChangeNotifierProvider(
          create: (_) => OffersProvider(getPublicOffers: getPublicOffers),
        ),
        ChangeNotifierProvider(
          create: (_) => SellersProvider(getAllSellers: getAllSellers),
        ),
        ChangeNotifierProvider(
          create: (_) => WishlistProvider(
            getMyWishlist: getMyWishlist,
            addToWishlist: addToWishlist,
            removeFromWishlist: removeFromWishlist,
            toggleWishlist: toggleWishlist,
          ),
        ),
      ],
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shaman Shop',
  debugShowCheckedModeBanner: false,
  theme: AppTheme.lightTheme(seedColor: const Color(0xFF6750A4)),
      home: isLoggedIn ? const AppShell() : const LoginPage(),
      routes: {
        '/home': (ctx) => const AppShell(),
        '/student-profile': (ctx) => const StudentProfilePage(),
        '/cart': (ctx) => const CartPage(),
        '/wishlist': (ctx) => const WishlistPage(),
        '/checkout': (ctx) => const CheckoutPage(),
        '/orders': (ctx) => const OrdersPage(),
        '/checkout/thankyou': (ctx) => const CheckoutThankYouPage(),
      },
    );
  }
}
