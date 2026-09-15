import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../widgets/app_drawer.dart';
import '../widgets/farmer_app_drawer.dart';
import '../models/product.dart';
import '../models/user.dart';
import 'products_screen.dart';
import 'checkout_screen.dart';

class CartItemData {
  final int cartId;
  final Product product;
  int quantity;

  CartItemData({
    required this.cartId,
    required this.product,
    required this.quantity,
  });
}

class CartScreen extends StatefulWidget {
  final User user;

  const CartScreen({
    super.key,
    required this.user,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  List<CartItemData> cartItems = [];
  bool isLoading = true;

  double get subtotal {
    double total = 0;

    for (final item in cartItems) {
      total += item.product.price * item.quantity;
    }

    return total;
  }

  double get deliveryCharge {
    if (cartItems.isEmpty) {
      return 0;
    }

    return 40;
  }

  double get total {
    return subtotal + deliveryCharge;
  }

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    setState(() {
      isLoading = true;
    });

    try {
      final cartData = await DatabaseHelper.instance.getCartItems(
        widget.user.id,
      );

      final List<CartItemData> loadedItems = [];

      for (final item in cartData) {
        final int cartId = (item['id'] as num).toInt();
        final int productId = (item['productId'] as num).toInt();
        final int quantity = (item['quantity'] as num).toInt();

        final productData =
        await DatabaseHelper.instance.getProductById(productId);

        if (productData == null) {
          await DatabaseHelper.instance.removeFromCart(
            widget.user.id,
            productId,
          );
          continue;
        }

        final product = Product.fromMap(productData);

        if (product.quantity <= 0) {
          await DatabaseHelper.instance.removeFromCart(
            widget.user.id,
            productId,
          );
          continue;
        }

        int finalQuantity = quantity;

        if (finalQuantity > product.quantity) {
          finalQuantity = product.quantity.toInt();

          await DatabaseHelper.instance.updateCartQuantity(
            widget.user.id,
            productId,
            finalQuantity,
          );
        }

        loadedItems.add(
          CartItemData(
            cartId: cartId,
            product: product,
            quantity: finalQuantity,
          ),
        );
      }

      if (!mounted) {
        return;
      }

      setState(() {
        cartItems = loadedItems;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to load cart: $e",
          ),
        ),
      );
    }
  }

  Future<void> increaseQuantity(CartItemData item) async {
    final int newQuantity = item.quantity + 1;

    if (newQuantity > item.product.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Only ${item.product.quantity.toStringAsFixed(0)} ${item.product.unit} available.",
          ),
        ),
      );
      return;
    }

    try {
      await DatabaseHelper.instance.updateCartQuantity(
        widget.user.id,
        item.product.id,
        newQuantity,
      );

      await loadCart();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              "Exception: ",
              "",
            ),
          ),
        ),
      );
    }
  }

  Future<void> decreaseQuantity(CartItemData item) async {
    if (item.quantity <= 1) {
      return;
    }

    final int newQuantity = item.quantity - 1;

    try {
      await DatabaseHelper.instance.updateCartQuantity(
        widget.user.id,
        item.product.id,
        newQuantity,
      );

      await loadCart();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              "Exception: ",
              "",
            ),
          ),
        ),
      );
    }
  }

  Future<void> removeItem(CartItemData item) async {
    try {
      await DatabaseHelper.instance.removeFromCart(
        widget.user.id,
        item.product.id,
      );

      await loadCart();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Product removed from cart.",
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
            e.toString().replaceFirst(
              "Exception: ",
              "",
            ),
          ),
        ),
      );
    }
  }

  Future<void> clearCart() async {
    try {
      await DatabaseHelper.instance.clearCart(
        widget.user.id,
      );

      await loadCart();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Cart cleared.",
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
            e.toString().replaceFirst(
              "Exception: ",
              "",
            ),
          ),
        ),
      );
    }
  }

  void showClearCartDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Clear Cart",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: const Text(
            "Are you sure you want to remove all products from your cart?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                clearCart();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text(
                "Clear",
              ),
            ),
          ],
        );
      },
    );
  }

  IconData getProductIcon(String category) {
    switch (category.toLowerCase()) {
      case "vegetables":
        return Icons.eco;
      case "fruits":
        return Icons.apple;
      case "grains":
        return Icons.grass;
      case "dairy":
        return Icons.water_drop;
      case "spices":
        return Icons.local_fire_department;
      default:
        return Icons.shopping_basket;
    }
  }

  Widget buildDrawer() {
    if (widget.user.role == "Farmer") {
      return FarmerAppDrawer(
        user: widget.user,
        selectedRoute: "",
      );
    }

    return AppDrawer(
      user: widget.user,
      selectedRoute: "",
    );
  }

  Widget buildCartItem(CartItemData item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              height: 85,
              width: 85,
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                getProductIcon(
                  item.product.category,
                ),
                size: 42,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.product.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "Farmer: ${item.product.farmerName}",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    "₹${item.product.price.toStringAsFixed(2)} / ${item.product.unit}",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.green.shade300,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: item.quantity > 1
                                  ? () => decreaseQuantity(item)
                                  : null,
                              icon: const Icon(
                                Icons.remove,
                                size: 18,
                              ),
                              color: Colors.green.shade700,
                            ),
                            Text(
                              item.quantity.toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () => increaseQuantity(item),
                              icon: const Icon(
                                Icons.add,
                                size: 18,
                              ),
                              color: Colors.green.shade700,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Text(
                        "₹${(item.product.price * item.quantity).toStringAsFixed(2)}",
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () => removeItem(item),
              icon: const Icon(
                Icons.delete_outline,
              ),
              color: Colors.red,
              tooltip: "Remove",
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSummary() {
    return Card(
      elevation: 3,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Order Summary",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Subtotal",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  "₹${subtotal.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Delivery",
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                Text(
                  "₹${deliveryCharge.toStringAsFixed(2)}",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(
              height: 30,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "₹${total.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CheckoutScreen(
                        user: widget.user,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  "Proceed to Checkout",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: buildDrawer(),
      appBar: AppBar(
        title: const Text(
          "My Cart",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              onPressed: showClearCartDialog,
              icon: const Icon(
                Icons.delete_sweep,
              ),
              tooltip: "Clear Cart",
            ),
        ],
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : cartItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 90,
              color: Colors.grey.shade400,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Your cart is empty",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "Add some fresh products to your cart.",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(
              height: 25,
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductsScreen(
                      user: widget.user,
                    ),
                  ),
                );
              },
              icon: const Icon(
                Icons.shopping_basket,
              ),
              label: const Text(
                "Continue Shopping",
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 15,
                ),
              ),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "${cartItems.length} Product${cartItems.length == 1 ? '' : 's'}",
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  ProductsScreen(
                                    user: widget.user,
                                  ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                        ),
                        label: const Text(
                          "Continue Shopping",
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  ...cartItems.map(
                        (item) => buildCartItem(item),
                  ),
                ],
              ),
            ),
            const SizedBox(
              width: 25,
            ),
            SizedBox(
              width: 350,
              child: buildSummary(),
            ),
          ],
        ),
      ),
    );
  }
}