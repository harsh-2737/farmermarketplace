import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../widgets/app_drawer.dart';
import '../widgets/farmer_app_drawer.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'cart_screen.dart';

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  final User user;

  const ProductDetailsScreen({
    super.key,
    required this.product,
    required this.user,
  });

  @override
  State<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState
    extends State<ProductDetailsScreen> {
  int selectedQuantity = 1;
  bool isAddingToCart = false;

  Future<void> addProductToCart() async {
    if (isAddingToCart) {
      return;
    }

    if (widget.product.quantity < 1) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "This product is out of stock",
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isAddingToCart = true;
    });

    try {
      await DatabaseHelper.instance.addToCart({
        'userId': widget.user.id,
        'productId': widget.product.id,
        'quantity': selectedQuantity,
      });

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${widget.product.name} added to cart",
          ),
          backgroundColor: Colors.green.shade700,
          duration:
          const Duration(seconds: 1),
        ),
      );

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      if (!mounted) {
        return;
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CartScreen(
            user: widget.user,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to add product: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        isAddingToCart = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Product product = widget.product;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Product Details",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor:
        Colors.green.shade700,
        foregroundColor: Colors.white,
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
        selectedRoute: "/products",
        user: widget.user,
      )
          : AppDrawer(
        selectedRoute: "/products",
        user: widget.user,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
          CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 260,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: Center(
                child: Icon(
                  _getProductIcon(
                    product.category,
                  ),
                  size: 110,
                  color:
                  Colors.green.shade700,
                ),
              ),
            ),
            const SizedBox(height: 25),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding:
              const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color:
                Colors.green.shade50,
                borderRadius:
                BorderRadius.circular(20),
              ),
              child: Text(
                product.category,
                style: TextStyle(
                  color:
                  Colors.green.shade700,
                  fontWeight:
                  FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "₹${product.price.toStringAsFixed(0)} / ${product.unit}",
              style: TextStyle(
                fontSize: 24,
                color:
                Colors.green.shade700,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(
                  Icons.inventory_2_outlined,
                  color:
                  Colors.grey.shade700,
                ),
                const SizedBox(width: 10),
                Text(
                  "Available: ${product.quantity} ${product.unit}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color:
                  Colors.grey.shade700,
                ),
                const SizedBox(width: 10),
                Text(
                  product.farmerName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight:
                    FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            const Text(
              "Description",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              product.description,
              style: TextStyle(
                fontSize: 15,
                color:
                Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Select Quantity",
              style: TextStyle(
                fontSize: 20,
                fontWeight:
                FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Container(
                  decoration:
                  BoxDecoration(
                    border: Border.all(
                      color:
                      Colors.grey.shade300,
                    ),
                    borderRadius:
                    BorderRadius.circular(
                      12,
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed:
                        selectedQuantity > 1
                            ? () {
                          setState(() {
                            selectedQuantity--;
                          });
                        }
                            : null,
                        icon: const Icon(
                          Icons.remove,
                        ),
                      ),
                      Container(
                        width: 45,
                        alignment:
                        Alignment.center,
                        child: Text(
                          "$selectedQuantity",
                          style:
                          const TextStyle(
                            fontSize: 18,
                            fontWeight:
                            FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed:
                        selectedQuantity <
                            product.quantity
                            ? () {
                          setState(() {
                            selectedQuantity++;
                          });
                        }
                            : null,
                        icon: const Icon(
                          Icons.add,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 15),
                Text(
                  product.unit,
                  style: TextStyle(
                    fontSize: 16,
                    color:
                    Colors.grey.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            Container(
              padding:
              const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color:
                Colors.green.shade50,
                borderRadius:
                BorderRadius.circular(15),
              ),
              child: Row(
                mainAxisAlignment:
                MainAxisAlignment
                    .spaceBetween,
                children: [
                  const Text(
                    "Total Price",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                  Text(
                    "₹${(product.price * selectedQuantity).toStringAsFixed(0)}",
                    style: TextStyle(
                      fontSize: 22,
                      color:
                      Colors.green.shade700,
                      fontWeight:
                      FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child:
                    OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                      ),
                      label: const Text(
                        "Back",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      style:
                      OutlinedButton
                          .styleFrom(
                        foregroundColor:
                        Colors.green
                            .shade700,
                        side: BorderSide(
                          color: Colors.green
                              .shade700,
                        ),
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 55,
                    child:
                    ElevatedButton.icon(
                      onPressed:
                      isAddingToCart
                          ? null
                          : addProductToCart,
                      icon: isAddingToCart
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child:
                        CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                          AlwaysStoppedAnimation<
                              Color>(
                            Colors.white,
                          ),
                        ),
                      )
                          : const Icon(
                        Icons
                            .shopping_cart_outlined,
                      ),
                      label: Text(
                        isAddingToCart
                            ? "Adding..."
                            : "Add to Cart",
                        style:
                        const TextStyle(
                          fontSize: 16,
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                      style:
                      ElevatedButton
                          .styleFrom(
                        backgroundColor:
                        Colors.green
                            .shade700,
                        foregroundColor:
                        Colors.white,
                        disabledBackgroundColor:
                        Colors.green
                            .shade400,
                        disabledForegroundColor:
                        Colors.white,
                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius
                              .circular(
                            12,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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