import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../widgets/app_drawer.dart';
import '../models/product.dart';
import '../models/user.dart';
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
  final TextEditingController nameController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  final TextEditingController addressController =
  TextEditingController();

  final TextEditingController cityController =
  TextEditingController();

  final TextEditingController stateController =
  TextEditingController();

  final TextEditingController pincodeController =
  TextEditingController();

  List<CheckoutItem> checkoutItems = [];

  bool isLoading = true;
  bool hasAddress = false;

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    nameController.text = widget.user.name;
    phoneController.text = widget.user.phone;
    addressController.text = widget.user.addressLine;
    cityController.text = widget.user.city;
    stateController.text = widget.user.state;
    pincodeController.text = widget.user.pincode;

    hasAddress =
        widget.user.addressLine.trim().isNotEmpty &&
            widget.user.city.trim().isNotEmpty &&
            widget.user.state.trim().isNotEmpty &&
            widget.user.pincode.trim().isNotEmpty;

    final cartRows =
    await DatabaseHelper.instance.getCartItems(
      widget.user.id,
    );

    List<CheckoutItem> loadedItems = [];

    for (final cartRow in cartRows) {
      final int productId = cartRow['productId'] as int;
      final int quantity = cartRow['quantity'] as int;

      final productMap =
      await DatabaseHelper.instance.getProductById(
        productId,
      );

      if (productMap != null) {
        loadedItems.add(
          CheckoutItem(
            product: Product.fromMap(productMap),
            quantity: quantity,
          ),
        );
      }
    }

    if (!mounted) {
      return;
    }

    setState(() {
      checkoutItems = loadedItems;
      isLoading = false;
    });
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
    return checkoutItems.isEmpty ? 0 : 40;
  }

  double get total {
    return subtotal + deliveryCharge;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Checkout",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(
        selectedRoute: "/checkout",
        user: widget.user,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : checkoutItems.isEmpty
          ? _buildEmptyCart()
          : Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _buildSectionTitle(
                  "Delivery Address",
                  Icons.location_on_outlined,
                ),
                const SizedBox(height: 12),
                hasAddress
                    ? _buildAddressCard()
                    : _buildAddAddressCard(),
                const SizedBox(height: 25),
                _buildSectionTitle(
                  "Ordered Products",
                  Icons.shopping_bag_outlined,
                ),
                const SizedBox(height: 12),
                ...checkoutItems.map(
                      (item) => _buildProductCard(item),
                ),
                const SizedBox(height: 25),
                _buildPriceDetails(),
                const SizedBox(height: 25),
                _buildPaymentMethod(),
                const SizedBox(height: 20),
              ],
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.green.shade700,
          size: 25,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAddAddressCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off_outlined,
            size: 45,
            color: Colors.grey.shade500,
          ),
          const SizedBox(height: 10),
          const Text(
            "No delivery address",
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Add an address to continue",
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 15),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () {
                _showAddressDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text(
                "Add Address",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.green.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 45,
                width: 45,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.home_outlined,
                  color: Colors.green.shade700,
                  size: 25,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      widget.user.phone,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  _showAddressDialog();
                },
                child: Text(
                  "Edit",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            widget.user.addressLine,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 15,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            "${widget.user.city}, ${widget.user.state} - ${widget.user.pincode}",
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 15,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(CheckoutItem item) {
    final product = item.product;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 65,
            width: 65,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Center(
              child: Icon(
                _getProductIcon(product.category),
                size: 35,
                color: Colors.green.shade700,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.farmerName,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${item.quantity} ${product.unit} × ₹${product.price.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          Text(
            "₹${(product.price * item.quantity).toStringAsFixed(0)}",
            style: TextStyle(
              color: Colors.green.shade700,
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceDetails() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          const Text(
            "Price Details",
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPriceRow(
            "Subtotal",
            "₹${subtotal.toStringAsFixed(0)}",
          ),
          const SizedBox(height: 12),
          _buildPriceRow(
            "Delivery Charge",
            "₹${deliveryCharge.toStringAsFixed(0)}",
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 15),
            child: Divider(),
          ),
          _buildPriceRow(
            "Total",
            "₹${total.toStringAsFixed(0)}",
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
      String title,
      String amount, {
        bool isTotal = false,
      }) {
    return Row(
      mainAxisAlignment:
      MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 19 : 16,
            fontWeight: isTotal
                ? FontWeight.bold
                : FontWeight.normal,
            color: isTotal
                ? Colors.black
                : Colors.grey.shade700,
          ),
        ),
        Text(
          amount,
          style: TextStyle(
            fontSize: isTotal ? 21 : 16,
            fontWeight: FontWeight.bold,
            color: isTotal
                ? Colors.green.shade700
                : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.payment_outlined,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  "Payment Method",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Razorpay",
                  style: TextStyle(
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle,
            color: Colors.green,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        20,
        15,
        20,
        20,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Total",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "₹${total.toStringAsFixed(0)}",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 55,
            child: ElevatedButton.icon(
              onPressed: !hasAddress
                  ? null
                  : () {
                ScaffoldMessenger.of(context)
                    .showSnackBar(
                  const SnackBar(
                    content: Text(
                      "Razorpay will be connected next.",
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.payment),
              label: const Text(
                "Pay Now",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Colors.green.shade700,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddressDialog() async {
    nameController.text = widget.user.name;
    phoneController.text = widget.user.phone;
    addressController.text = widget.user.addressLine;
    cityController.text = widget.user.city;
    stateController.text = widget.user.state;
    pincodeController.text = widget.user.pincode;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            "Delivery Address",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              children: [
                _buildTextField(
                  controller: nameController,
                  label: "Name",
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: phoneController,
                  label: "Phone Number",
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: addressController,
                  label: "Address",
                  icon: Icons.home_outlined,
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: cityController,
                  label: "City",
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: stateController,
                  label: "State",
                  icon: Icons.map_outlined,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: pincodeController,
                  label: "Pincode",
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                _saveAddress(dialogContext);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor:
                Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text("Save Address"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _saveAddress(
      BuildContext dialogContext,
      ) async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        stateController.text.trim().isEmpty ||
        pincodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please fill all address fields.",
          ),
        ),
      );
      return;
    }

    if (pincodeController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Please enter a valid 6-digit pincode.",
          ),
        ),
      );
      return;
    }

    try {
      await DatabaseHelper.instance.updateUser(
        widget.user.id,
        {
          'name': nameController.text.trim(),
          'phone': phoneController.text.trim(),
          'addressLine':
          addressController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'pincode':
          pincodeController.text.trim(),
        },
      );

      widget.user.name =
          nameController.text.trim();

      widget.user.phone =
          phoneController.text.trim();

      widget.user.addressLine =
          addressController.text.trim();

      widget.user.city =
          cityController.text.trim();

      widget.user.state =
          stateController.text.trim();

      widget.user.pincode =
          pincodeController.text.trim();

      if (!mounted) {
        return;
      }

      setState(() {
        hasAddress = true;
      });

      Navigator.pop(dialogContext);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Address updated successfully.",
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
            "Failed to update address: $e",
          ),
        ),
      );
    }
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 15),
          const Text(
            "Your cart is empty",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => ProductsScreen(
                    user: widget.user,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor:
              Colors.green.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text(
              "Browse Products",
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
}