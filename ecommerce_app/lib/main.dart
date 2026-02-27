// lib/main.dart
import 'package:ecommerce_app/features/admin/screens/add_product_screen.dart';
import 'package:ecommerce_app/features/admin/screens/admin_dashboard_screen.dart';
import 'package:ecommerce_app/features/admin/screens/admin_orders_screen.dart';
import 'package:ecommerce_app/features/admin/screens/edit_product_screen.dart';
import 'package:ecommerce_app/features/cart/screens/cart_screen.dart';
import 'package:ecommerce_app/features/cart/screens/checkout_screen.dart';
import 'package:ecommerce_app/features/orders/screens/orders_screen.dart';
import 'package:ecommerce_app/features/shop/screens/product_details_screen.dart';
import 'package:ecommerce_app/features/shop/screens/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/sign_up_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/controllers/auth_controller.dart';

void main() {
  runApp(const MyApp());
}

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthController(), permanent: true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Ecommerce App',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090B),
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey,
          surface: Color(0xFF18181B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFF18181B),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFF27272A), width: 1),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Color(0xFFA1A1AA)),
        ),
      ),
      initialBinding: InitialBinding(),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/signup', page: () => SignUpScreen()),
        GetPage(name: '/admin-home', page: () => AdminDashboardScreen()),
        GetPage(name: '/add-product', page: () => AddProductScreen()),
        GetPage(
          name: '/edit-product',
          page: () => EditProductScreen(),
          transition: Transition.rightToLeftWithFade,
        ),
        GetPage(name: '/customer-home', page: () => ShopScreen()),
        GetPage(name: '/cart', page: () => CartScreen()),
        GetPage(name: '/my-orders', page: () => OrdersScreen()),
        GetPage(name: '/admin-orders', page: () => AdminOrdersScreen()),
        GetPage(
          name: '/checkout',
          page: () => CheckoutScreen(),
          transition: Transition.rightToLeftWithFade,
        ),
        GetPage(
          name: '/product-details',
          page: () => ProductDetailsScreen(),
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}