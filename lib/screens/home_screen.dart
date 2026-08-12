import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import '../widgets/category_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Farmer Marketplace'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.person),
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Text(
                'Welcome!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'Buy fresh products directly from farmers',
                style: TextStyle(
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Search products',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),

              const SizedBox(height: 25),

              const Text(
                'Categories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: const [
                    CategoryCard(
                      categoryName: 'Vegetables',
                      icon: Icons.eco,
                    ),

                    SizedBox(width: 12),

                    CategoryCard(
                      categoryName: 'Fruits',
                      icon: Icons.apple,
                    ),

                    SizedBox(width: 12),

                    CategoryCard(
                      categoryName: 'Grains',
                      icon: Icons.grass,
                    ),

                    SizedBox(width: 12),

                    CategoryCard(
                      categoryName: 'Dairy',
                      icon: Icons.water_drop,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Popular Products',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 15),
              const ProductCard(
                productName: 'Fresh Tomato',
                price: '₹40 / kg',
              ),

              const SizedBox(height: 10),

              const ProductCard(
                productName: 'Fresh Potato',
                price: '₹30 / kg',
              ),

              const SizedBox(height: 10),

              const ProductCard(
                productName: 'Fresh Onion',
                price: '₹35 / kg',
              ),


              const SizedBox(height: 10),


            ],
          ),
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Products',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),

          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}