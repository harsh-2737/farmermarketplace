import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../widgets/app_drawer.dart';
import '../widgets/farmer_app_drawer.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'product_details_screen.dart';
import 'cart_screen.dart';

class ProductsScreen extends StatefulWidget {
  final String selectedCategory;
  final User user;

  const ProductsScreen({
    super.key,
    this.selectedCategory = "All",
    required this.user,
  });

  @override
  State<ProductsScreen> createState() =>
      _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  late String selectedCategory;

  String searchText = "";

  List<Product> products = [];
  bool isLoading = true;

  final List<String> categories = [
    "All",
    "Vegetables",
    "Grains",
    "Fruits",
    "Dairy",
    "Spices",
  ];

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    final result =
    await DatabaseHelper.instance.getAllProducts();

    if (!mounted) {
      return;
    }

    setState(() {
      products = result
          .map((product) => Product.fromMap(product))
          .toList();
      isLoading = false;
    });
  }

  List<Product> get filteredProducts {
    return products.where((product) {
      final matchesSearch = product.name
          .toLowerCase()
          .contains(searchText.toLowerCase());

      final matchesCategory =
          selectedCategory == "All" ||
              product.category.toLowerCase() ==
                  selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final displayedProducts = filteredProducts;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Products",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.shopping_cart_outlined,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CartScreen(
                    user: widget.user,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      drawer: widget.user.role == "Farmer"
          ? FarmerAppDrawer(
        selectedRoute: "/products",
        user: widget.user,
      )
          : AppDrawer(
        selectedRoute: "/products",
        user: widget.user,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : RefreshIndicator(
        onRefresh: _loadProducts,
        child: SingleChildScrollView(
          physics:
          const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search products...",
                  prefixIcon: const Icon(
                    Icons.search,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                "Categories",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),
              SingleChildScrollView(
                scrollDirection:
                Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    return _categoryButton(
                      category,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    selectedCategory == "All"
                        ? "All Products"
                        : "$selectedCategory Products",
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "${displayedProducts.length} products",
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              displayedProducts.isEmpty
                  ? _buildEmptyProducts()
                  : GridView.builder(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                itemCount:
                displayedProducts.length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.68,
                ),
                itemBuilder:
                    (context, index) {
                  return _productCard(
                    context,
                    displayedProducts[index],
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryButton(String category) {
    final bool isSelected =
        selectedCategory == category;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = category;
        });
      },
      child: Container(
        margin:
        const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 18,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.shade700
              : Colors.white,
          borderRadius:
          BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.green.shade700
                : Colors.grey.shade300,
          ),
        ),
        child: Text(
          category,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : Colors.grey.shade700,
            fontWeight: isSelected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _productCard(
      BuildContext context,
      Product product,
      ) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ProductDetailsScreen(
                  product: product,
                  user: widget.user,
                ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Icon(
                    _getProductIcon(
                      product.category,
                    ),
                    size: 40,
                    color:
                    Colors.green.shade700,
                  ),
                ),
              ),
              Text(
                product.name,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                "₹${product.price.toStringAsFixed(0)} / ${product.unit}",
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color:
                  Colors.green.shade700,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                product.farmerName,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color:
                  Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 7),
              Container(
                width: double.infinity,
                height: 28,
                decoration: BoxDecoration(
                  color:
                  Colors.green.shade50,
                  borderRadius:
                  BorderRadius.circular(7),
                ),
                child: Center(
                  child: Text(
                    "View Details",
                    style: TextStyle(
                      color:
                      Colors.green.shade700,
                      fontSize: 10,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyProducts() {
    return Center(
      child: Padding(
        padding:
        const EdgeInsets.symmetric(
          vertical: 60,
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 15),
            const Text(
              "No Products Found",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Try another category or search.",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
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
}