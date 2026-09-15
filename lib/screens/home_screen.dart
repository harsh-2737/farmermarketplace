import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../widgets/app_drawer.dart';
import '../widgets/farmer_app_drawer.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'product_details_screen.dart';
import 'products_screen.dart';
import 'cart_screen.dart';

class HomeScreen extends StatefulWidget {
  final User user;

  const HomeScreen({
    super.key,
    required this.user,
  });

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedCategory = "All";
  String searchText = "";

  List<Product> products = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
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

  List<Product> get selectedProducts {
    List<Product> filteredProducts =
    List.from(products);

    filteredProducts.sort(
          (a, b) => b.createdAt.compareTo(
        a.createdAt,
      ),
    );

    if (selectedCategory != "All") {
      filteredProducts = filteredProducts
          .where(
            (product) =>
        product.category.toLowerCase() ==
            selectedCategory.toLowerCase(),
      )
          .toList();
    }

    if (searchText.isNotEmpty) {
      filteredProducts = filteredProducts
          .where(
            (product) => product.name
            .toLowerCase()
            .contains(
          searchText.toLowerCase(),
        ),
      )
          .toList();
    }

    return filteredProducts.take(4).toList();
  }

  @override
  Widget build(BuildContext context) {
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      CartScreen(
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
        selectedRoute:
        "/farmer-dashboard",
        user: widget.user,
      )
          : AppDrawer(
        selectedRoute: "/home",
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
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color:
                  Colors.green.shade700,
                  borderRadius:
                  BorderRadius.circular(
                    20,
                  ),
                ),
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome, ${widget.user.name} 🌾",
                      style:
                      const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    const Text(
                      "Fresh products directly from farmers",
                      style:
                      TextStyle(
                        color:
                        Colors.white70,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration:
                InputDecoration(
                  hintText:
                  "Search products...",
                  prefixIcon:
                  const Icon(
                    Icons.search,
                  ),
                  filled: true,
                  fillColor:
                  Colors.white,
                  border:
                  OutlineInputBorder(
                    borderRadius:
                    BorderRadius
                        .circular(
                      15,
                    ),
                    borderSide:
                    BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(
                height: 28,
              ),
              const Text(
                "Categories",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              SingleChildScrollView(
                scrollDirection:
                Axis.horizontal,
                child: Row(
                  children: [
                    _categoryCard(
                      Icons.apps,
                      "All",
                    ),
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
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [
                  Text(
                    selectedCategory ==
                        "All"
                        ? "Latest Products"
                        : "Latest $selectedCategory",
                    style:
                    const TextStyle(
                      fontSize: 21,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                              ProductsScreen(
                                selectedCategory:
                                selectedCategory,
                                user:
                                widget.user,
                              ),
                        ),
                      );
                    },
                    child: const Text(
                      "View All",
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 12,
              ),
              selectedProducts.isEmpty
                  ? _buildEmptyProducts()
                  : GridView.builder(
                shrinkWrap: true,
                physics:
                const NeverScrollableScrollPhysics(),
                itemCount:
                selectedProducts
                    .length,
                gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing:
                  8,
                  mainAxisSpacing:
                  10,
                  childAspectRatio:
                  0.68,
                ),
                itemBuilder:
                    (context, index) {
                  return _productCard(
                    context,
                    selectedProducts[
                    index],
                  );
                },
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Why Farmer Marketplace?",
                style: TextStyle(
                  fontSize: 21,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
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
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryCard(
      IconData icon,
      String title,
      ) {
    final isSelected =
        selectedCategory == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedCategory = title;
        });
      },
      child: Container(
        width: 105,
        margin:
        const EdgeInsets.only(right: 12),
        padding:
        const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.shade700
              : Colors.white,
          borderRadius:
          BorderRadius.circular(16),
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
              color: isSelected
                  ? Colors.white
                  : Colors.green.shade700,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight:
                FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ],
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
          padding:
          const EdgeInsets.all(8),
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
                textAlign:
                TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
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
              const SizedBox(
                height: 3,
              ),
              Text(
                product.farmerName,
                maxLines: 1,
                overflow:
                TextOverflow.ellipsis,
                textAlign:
                TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  color:
                  Colors.grey.shade600,
                ),
              ),
              const SizedBox(
                height: 7,
              ),
              Container(
                width:
                double.infinity,
                height: 28,
                decoration:
                BoxDecoration(
                  color:
                  Colors.green.shade50,
                  borderRadius:
                  BorderRadius.circular(
                    7,
                  ),
                ),
                child: Center(
                  child: Text(
                    "View Details",
                    style: TextStyle(
                      color: Colors.green
                          .shade700,
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
          vertical: 40,
        ),
        child: Column(
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            const Text(
              "No Products Available",
              style: TextStyle(
                fontSize: 19,
                fontWeight:
                FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefitCard(
      IconData icon,
      String title,
      String description,
      ) {
    return Card(
      margin:
      const EdgeInsets.only(
        bottom: 12,
      ),
      child: Padding(
        padding:
        const EdgeInsets.all(15),
        child: Row(
          children: [
            Container(
              padding:
              const EdgeInsets.all(12),
              decoration:
              BoxDecoration(
                color:
                Colors.green.shade50,
                borderRadius:
                BorderRadius.circular(
                  12,
                ),
              ),
              child: Icon(
                icon,
                color:
                Colors.green.shade700,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment
                    .start,
                children: [
                  Text(
                    title,
                    style:
                    const TextStyle(
                      fontSize: 16,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors
                          .grey.shade600,
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

  IconData _getProductIcon(
      String category,
      ) {
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