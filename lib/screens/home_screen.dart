import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../models/product.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Product> products = [
      Product(
        id: 1,
        name: "Fresh Tomatoes",
        category: "Vegetables",
        price: 40,
        quantity: 50,
        unit: "kg",
        image: "",
        description: "Fresh tomatoes directly from the farmer.",
        farmerId: 101,
        farmerName: "Ramesh Patel",
      ),
      Product(
        id: 2,
        name: "Fresh Wheat",
        category: "Grains",
        price: 35,
        quantity: 100,
        unit: "kg",
        image: "",
        description: "Quality wheat directly from the farmer.",
        farmerId: 102,
        farmerName: "Suresh Patel",
      ),
      Product(
        id: 3,
        name: "Fresh Potatoes",
        category: "Vegetables",
        price: 30,
        quantity: 80,
        unit: "kg",
        image: "",
        description: "Fresh potatoes from local farmers.",
        farmerId: 103,
        farmerName: "Mahesh Patel",
      ),
      Product(
        id: 4,
        name: "Basmati Rice",
        category: "Grains",
        price: 60,
        quantity: 70,
        unit: "kg",
        image: "",
        description: "Premium quality basmati rice.",
        farmerId: 104,
        farmerName: "Rajesh Patel",
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Farmer Marketplace",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
            ),
            onPressed: () {
              Navigator.pushNamed(
                context,
                "/cart",
              );
            },
          ),
        ],
      ),
      drawer: const AppDrawer(
        selectedRoute: "/home",
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Welcome to Farmer Marketplace 🌾",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Fresh products directly from farmers",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                hintText: "Search products...",
                prefixIcon: const Icon(
                  Icons.search,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 28),

            const Text(
              "Categories",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _categoryCard(
                    Icons.grass,
                    "Grains",
                  ),
                  _categoryCard(
                    Icons.eco,
                    "Vegetables",
                  ),
                  _categoryCard(
                    Icons.apple,
                    "Fruits",
                  ),
                  _categoryCard(
                    Icons.local_drink,
                    "Dairy",
                  ),
                  _categoryCard(
                    Icons.spa,
                    "Spices",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Featured Products",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      "/products",
                    );
                  },
                  child: const Text(
                    "View All",
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              height: 165,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return _productCard(
                    context,
                    products[index],
                  );
                },
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Why Farmer Marketplace?",
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            _benefitCard(
              Icons.eco,
              "Fresh Products",
              "Get fresh agricultural products directly from farmers.",
            ),

            _benefitCard(
              Icons.currency_rupee,
              "Fair Prices",
              "Buy products at fair prices directly from producers.",
            ),

            _benefitCard(
              Icons.agriculture,
              "Support Farmers",
              "Help local farmers by purchasing directly from them.",
            ),

            _benefitCard(
              Icons.local_shipping_outlined,
              "Easy Delivery",
              "Get your products delivered conveniently.",
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _categoryCard(
      IconData icon,
      String title,
      ) {
    return Container(
      width: 105,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.symmetric(
        vertical: 16,
        horizontal: 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 34,
            color: Colors.green.shade700,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _productCard(
      BuildContext context,
      Product product,
      ) {
    return Container(
      width: 145,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getProductIcon(product.category),
                size: 30,
                color: Colors.green.shade700,
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            product.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            "₹${product.price.toStringAsFixed(2)} / ${product.unit}",
            style: TextStyle(
              fontSize: 12,
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            "By ${product.farmerName}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
            ),
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 30,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "${product.name} added to cart",
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.shopping_cart_outlined,
                size: 15,
              ),
              label: const Text(
                "Add",
                style: TextStyle(
                  fontSize: 12,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  IconData _getProductIcon(String category) {
    switch (category.toLowerCase()) {
      case "vegetables":
        return Icons.eco;
      case "grains":
        return Icons.grass;
      case "fruits":
        return Icons.apple;
      case "dairy":
        return Icons.local_drink;
      case "spices":
        return Icons.spa;
      default:
        return Icons.agriculture;
    }
  }

  Widget _benefitCard(
      IconData icon,
      String title,
      String description,
      ) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.green.shade700,
                size: 28,
              ),
            ),

            const SizedBox(width: 15),

            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}