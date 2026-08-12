import 'package:flutter/material.dart';


class ProductCard extends StatelessWidget {
  final String productName;
  final String price;

  const ProductCard({
    super.key,
    required this.productName,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(
          Icons.shopping_basket,
          size: 35,
        ),

        title: Text(productName),

        subtitle: Text(price),

        trailing: ElevatedButton(
          onPressed: () {},
          child: const Text('Add'),
        ),
      ),
    );
  }
}