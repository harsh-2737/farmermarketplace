import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Cart"),
      ),

      drawer: const AppDrawer(
        selectedRoute: "/cart",
      ),

      body: const Center(
        child: Text(
          "Cart Screen",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}