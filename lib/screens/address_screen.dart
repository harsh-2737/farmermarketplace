import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../widgets/app_drawer.dart';

class AddressScreen extends StatefulWidget {
  final User user;

  const AddressScreen({
    super.key,
    required this.user,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController pincodeController;

  @override
  void initState() {
    super.initState();

    addressController = TextEditingController(
      text: widget.user.addressLine,
    );

    cityController = TextEditingController(
      text: widget.user.city,
    );

    stateController = TextEditingController(
      text: widget.user.state,
    );

    pincodeController = TextEditingController(
      text: widget.user.pincode,
    );
  }

  @override
  void dispose() {
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (addressController.text.trim().isEmpty ||
        cityController.text.trim().isEmpty ||
        stateController.text.trim().isEmpty ||
        pincodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all address fields."),
        ),
      );
      return;
    }

    if (pincodeController.text.trim().length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter a valid 6-digit pincode."),
        ),
      );
      return;
    }

    try {
      await DatabaseHelper.instance.updateUser(
        widget.user.id,
        {
          'addressLine': addressController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'pincode': pincodeController.text.trim(),
        },
      );

      widget.user.addressLine = addressController.text.trim();
      widget.user.city = cityController.text.trim();
      widget.user.state = stateController.text.trim();
      widget.user.pincode = pincodeController.text.trim();

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Address saved successfully."),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to save address: $e"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Address",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      drawer: AppDrawer(
        selectedRoute: "/address",
        user: widget.user,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    height: 90,
                    width: 90,
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: Icon(
                      Icons.location_on_outlined,
                      size: 50,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Center(
                  child: Text(
                    "Delivery Address",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    "Add your address for order delivery",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                _buildTextField(
                  controller: addressController,
                  label: "Address",
                  icon: Icons.home_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: cityController,
                  label: "City",
                  icon: Icons.location_city_outlined,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: stateController,
                  label: "State",
                  icon: Icons.map_outlined,
                ),
                const SizedBox(height: 15),
                _buildTextField(
                  controller: pincodeController,
                  label: "Pincode",
                  icon: Icons.pin_drop_outlined,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                ),
                const SizedBox(height: 25),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _saveAddress,
                    icon: const Icon(
                      Icons.save_outlined,
                    ),
                    label: const Text(
                      "Save Address",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }
}