// lib/main.dart
import 'package:ecommerce_app/features/admin/screens/add_product_screen.dart';
import 'package:ecommerce_app/features/admin/screens/admin_dashboard_screen.dart';
import 'package:ecommerce_app/features/shop/screens/shop_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      theme: ThemeData(primarySwatch: Colors.blue),
      
      // 2. Attach the binding to the app
      initialBinding: InitialBinding(), 
      
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        GetPage(name: '/login', page: () => LoginScreen()),
        GetPage(name: '/admin-home', page: () => AdminDashboardScreen()),
        GetPage(name: '/add-product', page: () => AddProductScreen()),
        GetPage(name: '/customer-home', page: () => ShopScreen()),
      ],
    );
  }
}



