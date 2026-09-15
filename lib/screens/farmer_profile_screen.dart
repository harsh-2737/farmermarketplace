import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../widgets/farmer_app_drawer.dart';

class FarmerProfileScreen extends StatefulWidget {
  final User user;

  const FarmerProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<FarmerProfileScreen> createState() =>
      _FarmerProfileScreenState();
}

class _FarmerProfileScreenState
    extends State<FarmerProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController pincodeController;

  bool isEditing = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();

    nameController =
        TextEditingController(text: widget.user.name);
    emailController =
        TextEditingController(text: widget.user.email);
    phoneController =
        TextEditingController(text: widget.user.phone);
    addressController =
        TextEditingController(text: widget.user.addressLine);
    cityController =
        TextEditingController(text: widget.user.city);
    stateController =
        TextEditingController(text: widget.user.state);
    pincodeController =
        TextEditingController(text: widget.user.pincode);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (nameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Name, email and phone are required",
          ),
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await DatabaseHelper.instance.updateUser(
        widget.user.id,
        {
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'phone': phoneController.text.trim(),
          'role': widget.user.role,
          'addressLine': addressController.text.trim(),
          'city': cityController.text.trim(),
          'state': stateController.text.trim(),
          'pincode': pincodeController.text.trim(),
        },
      );

      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Profile updated successfully",
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to update profile: $e",
          ),
        ),
      );
    }
  }

  void _cancelEditing() {
    setState(() {
      nameController.text = widget.user.name;
      emailController.text = widget.user.email;
      phoneController.text = widget.user.phone;
      addressController.text = widget.user.addressLine;
      cityController.text = widget.user.city;
      stateController.text = widget.user.state;
      pincodeController.text = widget.user.pincode;
      isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Profile",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: FarmerAppDrawer(
        selectedRoute: "/farmer-profile",
        user: widget.user,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Container(
            width: 650,
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade300,
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.green.shade100,
                  child: Icon(
                    Icons.agriculture,
                    size: 55,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  widget.user.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "Farmer",
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 25),
                _field(
                  controller: nameController,
                  label: "Name",
                  icon: Icons.person,
                ),
                const SizedBox(height: 15),
                _field(
                  controller: emailController,
                  label: "Email",
                  icon: Icons.email,
                ),
                const SizedBox(height: 15),
                _field(
                  controller: phoneController,
                  label: "Phone",
                  icon: Icons.phone,
                ),
                const SizedBox(height: 15),
                _field(
                  controller: addressController,
                  label: "Address",
                  icon: Icons.home,
                ),
                const SizedBox(height: 15),
                _field(
                  controller: cityController,
                  label: "City",
                  icon: Icons.location_city,
                ),
                const SizedBox(height: 15),
                _field(
                  controller: stateController,
                  label: "State",
                  icon: Icons.map,
                ),
                const SizedBox(height: 15),
                _field(
                  controller: pincodeController,
                  label: "Pincode",
                  icon: Icons.pin_drop,
                ),
                const SizedBox(height: 30),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed: isSaving
                              ? null
                              : () {
                            if (isEditing) {
                              _cancelEditing();
                            } else {
                              Navigator.pop(context);
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                          ),
                          label: const Text(
                            "Back",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor:
                            Colors.green.shade700,
                            side: BorderSide(
                              color: Colors.green.shade700,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: isSaving
                              ? null
                              : () {
                            if (isEditing) {
                              _saveProfile();
                            } else {
                              setState(() {
                                isEditing = true;
                              });
                            }
                          },
                          icon: Icon(
                            isEditing
                                ? Icons.save
                                : Icons.edit,
                          ),
                          label: Text(
                            isEditing
                                ? "Save Changes"
                                : "Edit Profile",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            Colors.green.shade700,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return TextField(
      controller: controller,
      enabled: isEditing,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isEditing
            ? Colors.green.shade50
            : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}