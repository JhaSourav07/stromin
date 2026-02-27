// lib/main.dart
import 'package:ecommerce_app/features/admin/screens/add_product_screen.dart';
import 'package:ecommerce_app/features/admin/screens/admin_dashboard_screen.dart';
import 'package:ecommerce_app/features/admin/screens/admin_orders_screen.dart';
import 'package:ecommerce_app/features/auth/screens/sign_up_screen.dart';
import 'package:ecommerce_app/features/cart/screens/cart_screen.dart';
import 'package:ecommerce_app/features/cart/screens/checkout_screen.dart';
import 'package:ecommerce_app/features/orders/screens/orders_screen.dart';
import 'package:ecommerce_app/features/shop/screens/product_details_screen.dart';
import 'package:ecommerce_app/features/shop/screens/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:google_fonts/google_fonts.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/splash_screen.dart';
import 'features/auth/controllers/auth_controller.dart';

void main() {
  runApp(const MyApp());
}

// 1. Create the InitialBinding
class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // permanent: true means GetX will NEVER delete this controller
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

      // Force the app into Dark Mode
      themeMode: ThemeMode.dark,

      // --- PREMIUM DARK THEME ---
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF09090B), // Deep OLED Black
        colorScheme: const ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.grey,
          surface: Color(0xFF18181B), // Rich charcoal for cards
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
          elevation: 0, // Shadows look bad in dark mode. Flat is premium.
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            // A very faint border gives it that high-end structural look
            side: const BorderSide(color: Color(0xFF27272A), width: 1),
          ),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(
            color: Color(0xFFA1A1AA),
          ), // Muted text for subtitles
        ),
      ),
      // -------------------------
      initialBinding: InitialBinding(),

      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/admin-home', page: () => AdminDashboardScreen()),
        GetPage(name: '/add-product', page: () => AddProductScreen()),
        GetPage(name: '/customer-home', page: () => ShopScreen()),
        GetPage(name: '/cart', page: () => CartScreen()),
        GetPage(name: '/my-orders', page: () => OrdersScreen()),
        GetPage(name: '/admin-orders', page: () => AdminOrdersScreen()),
        GetPage(name: '/signup', page: () => SignUpScreen()),
        GetPage(
          name: '/checkout',
          page: () => CheckoutScreen(),
          transition: Transition.rightToLeftWithFade,
        ),
        GetPage(
          name: '/product-details',
          page: () => ProductDetailsScreen(),
          // We use fadeIn to make the Hero animation look buttery smooth
          transition: Transition.fadeIn,
        ),
      ],
    );
  }
}
