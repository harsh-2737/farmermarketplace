import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';

class AddressScreen extends StatelessWidget {
  const AddressScreen({super.key});

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("My Address"),
      ),

      drawer: const AppDrawer(
        selectedRoute: "/address",
      ),

      body: const Center(
        child: Text(
          "Address Screen",
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}