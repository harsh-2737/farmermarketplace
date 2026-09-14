import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/products_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/orders_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/address_screen.dart';
import 'screens/settings_screen.dart';

void main() {
  runApp(const FarmerMarketplaceApp());
}

class FarmerMarketplaceApp extends StatelessWidget {
  const FarmerMarketplaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Farmer Marketplace",

      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),

      initialRoute: "/home",

      routes: {
        "/home": (context) => const HomeScreen(),
        "/products": (context) => const ProductsScreen(),
        "/cart": (context) => const CartScreen(),
        "/orders": (context) => const OrdersScreen(),
        "/profile": (context) => const ProfileScreen(),
        "/address": (context) => const AddressScreen(),
        "/settings": (context) => const SettingsScreen(),
      },
    );
  }
}