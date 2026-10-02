import 'package:flutter/material.dart';
import '../database/firebase_database_helper.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/farmer_app_drawer.dart';
import 'address_screen.dart';
import 'checkout_screen.dart';
import 'products_screen.dart';

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
    if (cartItems.isEmpty) return 0;
    return 40;
  }

  double get total => subtotal + deliveryCharge;

  @override
  void initState() {
    super.initState();
    loadCart();
  }

  Future<void> loadCart() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final cartData =
          await FirebaseDatabaseHelper.instance.getCartItems(widget.user.id);

      final List<CartItemData> loadedItems = [];

      for (final item in cartData) {
        final int cartId = (item['id'] as num).toInt();
        final int productId = (item['productId'] as num).toInt();
        final int quantity = (item['quantity'] as num).toInt();

        final productData =
            await FirebaseDatabaseHelper.instance.getProductById(productId);

        if (productData == null) {
          await FirebaseDatabaseHelper.instance.removeFromCart(
            widget.user.id,
            productId,
          );
          continue;
        }

        final product = Product.fromMap(productData);

        if (product.quantity <= 0) {
          await FirebaseDatabaseHelper.instance.removeFromCart(
            widget.user.id,
            productId,
          );
          continue;
        }

        int finalQuantity = quantity;

        if (finalQuantity > product.quantity) {
          finalQuantity = product.quantity.toInt();
          await FirebaseDatabaseHelper.instance.updateCartQuantity(
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

      if (!mounted) return;

      setState(() {
        cartItems = loadedItems;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load cart: $e"),
          backgroundColor: AppColors.error,
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
            "Only ${item.product.quantity.toStringAsFixed(0)} ${item.product.unit} available in farm inventory.",
          ),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    try {
      await FirebaseDatabaseHelper.instance.updateCartQuantity(
        widget.user.id,
        item.product.id,
        newQuantity,
      );

      if (!mounted) return;

      setState(() {
        item.quantity = newQuantity;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> decreaseQuantity(CartItemData item) async {
    if (item.quantity <= 1) return;

    final int newQuantity = item.quantity - 1;

    try {
      await FirebaseDatabaseHelper.instance.updateCartQuantity(
        widget.user.id,
        item.product.id,
        newQuantity,
      );

      if (!mounted) return;

      setState(() {
        item.quantity = newQuantity;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> removeItem(CartItemData item) async {
    try {
      await FirebaseDatabaseHelper.instance.removeFromCart(
        widget.user.id,
        item.product.id,
      );

      await loadCart();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> clearCart() async {
    try {
      await FirebaseDatabaseHelper.instance.clearCart(widget.user.id);
      await loadCart();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Cart cleared successfully"),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst("Exception: ", "")),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void showClearCartDialog() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Clear Cart",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          "Are you sure you want to remove all items from your cart?",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              clearCart();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text("Clear All"),
          ),
        ],
      ),
    );
  }

  IconData _getProductIcon(String category) {
    switch (category.toLowerCase()) {
      case "vegetables":
        return Icons.eco_rounded;
      case "fruits":
        return Icons.apple_rounded;
      case "grains":
        return Icons.grass_rounded;
      case "dairy":
        return Icons.local_drink_rounded;
      case "spices":
        return Icons.spa_rounded;
      default:
        return Icons.shopping_basket_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Shopping Cart",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.delete_sweep_outlined,
                color: AppColors.error,
              ),
              tooltip: "Clear Cart",
              onPressed: showClearCartDialog,
            ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: widget.user.role == "Farmer"
          ? FarmerAppDrawer(
              user: widget.user,
              selectedRoute: "/cart",
            )
          : AppDrawer(
              user: widget.user,
              selectedRoute: "/cart",
            ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : cartItems.isEmpty
              ? _buildEmptyCart(context)
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            color: AppColors.primary,
                            onRefresh: loadCart,
                            child: ListView(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                              children: [
                                // Delivery Address Quick Chip
                                _buildAddressBar(),
                                const SizedBox(height: 12),

                                // Delivery Info Banner
                                _buildDeliveryInfoBanner(),
                                const SizedBox(height: 16),

                                // Cart Items Header
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${cartItems.length} Items in Cart",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      "Subtotal: ₹${subtotal.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Cart Items List
                                ...cartItems.map((item) => _buildCartItemCard(item)),

                                const SizedBox(height: 20),

                                // Bill Breakdown Card
                                _buildBillSummary(),
                                const SizedBox(height: 24),
                              ],
                            ),
                          ),
                        ),

                        // Bottom Checkout Bar
                        _buildBottomCheckoutBar(context),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildAddressBar() {
    final bool hasAddress = widget.user.addressLine.isNotEmpty &&
        widget.user.city.isNotEmpty;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.location_on_rounded,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              hasAddress
                  ? "Deliver to: ${widget.user.addressLine}, ${widget.user.city}"
                  : "Add delivery address to complete order",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: hasAddress ? FontWeight.w600 : FontWeight.w500,
                color: hasAddress ? AppColors.textPrimary : AppColors.secondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddressScreen(user: widget.user),
                ),
              );
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              hasAddress ? "Change" : "Add",
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.local_shipping_rounded,
              size: 18,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Direct Farm Delivery • Flat ₹40",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "100% goes directly to harvest & eco-friendly packaging",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItemCard(CartItemData item) {
    final double itemTotal = item.product.price * item.quantity;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Image
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: item.product.image.isNotEmpty
                  ? Image.network(
                      item.product.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildCartImageFallback(item.product),
                    )
                  : _buildCartImageFallback(item.product),
            ),
          ),
          const SizedBox(width: 14),

          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "₹${item.product.price.toStringAsFixed(0)} / ${item.product.unit}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "₹${itemTotal.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          // Stepper & Delete
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded,
                    size: 18, color: AppColors.textMuted),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: () => removeItem(item),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => decreaseQuantity(item),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(Icons.remove, size: 16, color: AppColors.primary),
                      ),
                    ),
                    Container(
                      constraints: const BoxConstraints(minWidth: 26),
                      alignment: Alignment.center,
                      child: Text(
                        "${item.quantity}",
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () => increaseQuantity(item),
                      borderRadius: BorderRadius.circular(8),
                      child: const Padding(
                        padding: EdgeInsets.all(5),
                        child: Icon(Icons.add, size: 16, color: AppColors.primary),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCartImageFallback(Product product) {
    return Center(
      child: Icon(
        _getProductIcon(product.category),
        size: 32,
        color: AppColors.primary.withValues(alpha: 0.5),
      ),
    );
  }

  Widget _buildBillSummary() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bill Details",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          _billRow("Item Total", "₹${subtotal.toStringAsFixed(0)}"),
          const SizedBox(height: 8),
          _billRow(
            "Delivery Fee",
            deliveryCharge == 0
                ? "FREE"
                : "₹${deliveryCharge.toStringAsFixed(0)}",
            isFree: deliveryCharge == 0,
          ),
          const SizedBox(height: 8),
          _billRow("Farmer Direct Sourcing Fee", "FREE", isFree: true),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "To Pay",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "₹${total.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _billRow(String label, String value, {bool isFree = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isFree ? AppColors.success : AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomCheckoutBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.8)),
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: SafeArea(
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "TOTAL PAYABLE",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                Text(
                  "₹${total.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 24),
            Expanded(
              child: SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CheckoutScreen(user: widget.user),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Proceed to Checkout",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward_rounded, size: 18),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shopping_basket_outlined,
                size: 44,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Your Basket is Empty",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Fill it with fresh harvest directly from verified local farmers",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductsScreen(user: widget.user),
                  ),
                );
              },
              icon: const Icon(Icons.storefront_rounded),
              label: const Text("Explore Fresh Products"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}