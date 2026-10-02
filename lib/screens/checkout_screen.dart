import 'package:flutter/material.dart';
import '../database/firebase_database_helper.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import 'payment_screen.dart';
import 'products_screen.dart';

class CheckoutItem {
  final Product product;
  final int quantity;

  CheckoutItem({
    required this.product,
    required this.quantity,
  });
}

class CheckoutScreen extends StatefulWidget {
  final User user;

  const CheckoutScreen({
    super.key,
    required this.user,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController stateController = TextEditingController();
  final TextEditingController pincodeController = TextEditingController();

  List<CheckoutItem> checkoutItems = [];
  bool isLoading = true;
  bool hasAddress = false;

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    try {
      nameController.text = widget.user.name;
      phoneController.text = widget.user.phone;
      addressController.text = widget.user.addressLine;
      cityController.text = widget.user.city;
      stateController.text = widget.user.state;
      pincodeController.text = widget.user.pincode;

      hasAddress = widget.user.addressLine.trim().isNotEmpty &&
          widget.user.city.trim().isNotEmpty &&
          widget.user.state.trim().isNotEmpty &&
          widget.user.pincode.trim().isNotEmpty;

      final cartRows =
          await FirebaseDatabaseHelper.instance.getCartItems(widget.user.id);

      List<CheckoutItem> loadedItems = [];

      for (final cartRow in cartRows) {
        final int productId = (cartRow['productId'] as num).toInt();
        final int quantity = (cartRow['quantity'] as num).toInt();

        final productMap =
            await FirebaseDatabaseHelper.instance.getProductById(productId);

        if (productMap != null) {
          loadedItems.add(
            CheckoutItem(
              product: Product.fromMap(productMap),
              quantity: quantity,
            ),
          );
        }
      }

      if (!mounted) return;

      setState(() {
        checkoutItems = loadedItems;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load checkout data: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  double get subtotal {
    double total = 0;
    for (final item in checkoutItems) {
      total += item.product.price * item.quantity;
    }
    return total;
  }

  double get deliveryCharge {
    if (checkoutItems.isEmpty) return 0;
    return 40;
  }

  double get total => subtotal + deliveryCharge;

  Future<void> _saveAddress(BuildContext dialogContext) async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        stateController.text.trim().isEmpty ||
        pincodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all address fields."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (pincodeController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 6-digit pincode."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      await FirebaseDatabaseHelper.instance.updateUser(
        widget.user.id,
        {
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'addressLine': addressController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'pincode': pincodeController.text.trim(),
        },
      );

      widget.user.name = nameController.text.trim();
      widget.user.phone = phoneController.text.trim();
      widget.user.addressLine = addressController.text.trim();
      widget.user.city = cityController.text.trim();
      widget.user.state = stateController.text.trim();
      widget.user.pincode = pincodeController.text.trim();

      if (!dialogContext.mounted) return;
      Navigator.pop(dialogContext);

      if (!mounted) return;

      setState(() {
        hasAddress = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Delivery address saved successfully."),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update address: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showAddressDialog() {
    nameController.text = widget.user.name;
    phoneController.text = widget.user.phone;
    addressController.text = widget.user.addressLine;
    cityController.text = widget.user.city;
    stateController.text = widget.user.state;
    pincodeController.text = widget.user.pincode;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Delivery Address",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(dialogContext),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAddressField("Recipient Name", nameController, Icons.person_outline_rounded),
                  const SizedBox(height: 12),
                  _buildAddressField("Phone Number", phoneController, Icons.phone_outlined, keyboardType: TextInputType.phone),
                  const SizedBox(height: 12),
                  _buildAddressField("House / Street / Flat", addressController, Icons.home_outlined, maxLines: 2),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _buildAddressField("City", cityController, Icons.location_city_outlined),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildAddressField("State", stateController, Icons.map_outlined),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildAddressField("6-Digit Pincode", pincodeController, Icons.pin_drop_outlined, keyboardType: TextInputType.number),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () => _saveAddress(dialogContext),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Save Address",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddressField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      drawer: AppDrawer(
        selectedRoute: "/checkout",
        user: widget.user,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : checkoutItems.isEmpty
              ? _buildEmptyCart()
              : Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView(
                            padding: const EdgeInsets.all(16),
                            children: [
                              // Delivery Address Card
                              _buildSectionTitle(
                                "Delivery Address",
                                Icons.location_on_rounded,
                              ),
                              const SizedBox(height: 10),
                              hasAddress
                                  ? _buildAddressCard()
                                  : _buildAddAddressPrompt(),
                              const SizedBox(height: 24),

                              // Items in Order
                              _buildSectionTitle(
                                "Order Items (${checkoutItems.length})",
                                Icons.shopping_basket_rounded,
                              ),
                              const SizedBox(height: 10),
                              _buildItemsCard(),
                              const SizedBox(height: 24),

                              // Payment Method Card
                              _buildSectionTitle(
                                "Payment Method",
                                Icons.payment_rounded,
                              ),
                              const SizedBox(height: 10),
                              _buildPaymentMethodCard(),
                              const SizedBox(height: 24),

                              // Price Breakdown
                              _buildSectionTitle(
                                "Payment Summary",
                                Icons.receipt_long_rounded,
                              ),
                              const SizedBox(height: 10),
                              _buildPriceBreakdownCard(),
                              const SizedBox(height: 24),
                            ],
                          ),
                        ),

                        // Bottom Pay Bar
                        _buildBottomPayBar(),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.home_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        "Default",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  widget.user.phone,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${widget.user.addressLine}, ${widget.user.city}, ${widget.user.state} - ${widget.user.pincode}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _showAddressDialog,
            child: const Text(
              "Edit",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddAddressPrompt() {
    return InkWell(
      onTap: _showAddressDialog,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.secondary, style: BorderStyle.solid),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_location_alt_rounded, color: AppColors.secondary),
            SizedBox(width: 8),
            Text(
              "Add Delivery Address to Continue",
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.secondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: checkoutItems.map((item) {
          final double itemTotal = item.product.price * item.quantity;
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    width: 44,
                    height: 44,
                    color: AppColors.surfaceVariant,
                    child: item.product.image.isNotEmpty
                        ? Image.network(
                            item.product.image,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => const Icon(
                              Icons.eco_rounded,
                              color: AppColors.primary,
                              size: 20,
                            ),
                          )
                        : const Icon(
                            Icons.eco_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.product.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        "${item.quantity} ${item.product.unit} × ₹${item.product.price.toStringAsFixed(0)}",
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  "₹${itemTotal.toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentMethodCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.security_rounded,
              color: AppColors.primary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Razorpay Secure Checkout",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  "UPI, Cards, NetBanking & Wallets",
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: AppColors.primary,
            size: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceBreakdownCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _row("Items Total", "₹${subtotal.toStringAsFixed(0)}"),
          const SizedBox(height: 8),
          _row("Delivery Charges", "₹${deliveryCharge.toStringAsFixed(0)}"),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Grand Total",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                "₹${total.toStringAsFixed(0)}",
                style: const TextStyle(
                  fontSize: 18,
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

  Widget _row(String label, String value, {bool isFree = false}) {
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

  Widget _buildBottomPayBar() {
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
                  onPressed: !hasAddress
                      ? null
                      : () async {
                          final paymentSuccessful = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PaymentScreen(
                                user: widget.user,
                                amount: total,
                              ),
                            ),
                          );

                          if (paymentSuccessful == true && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Payment completed successfully."),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline_rounded, size: 18),
                      SizedBox(width: 8),
                      Text(
                        "Pay Securely",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.shopping_bag_outlined,
            size: 64,
            color: AppColors.textMuted,
          ),
          const SizedBox(height: 16),
          const Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsScreen(user: widget.user),
                ),
              );
            },
            child: const Text("Browse Harvest Products"),
          ),
        ],
      ),
    );
  }
}