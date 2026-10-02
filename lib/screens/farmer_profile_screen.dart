import 'package:flutter/material.dart';
import '../database/firebase_database_helper.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/farmer_app_drawer.dart';

class FarmerProfileScreen extends StatefulWidget {
  final User user;

  const FarmerProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<FarmerProfileScreen> createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
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
    nameController = TextEditingController(text: widget.user.name);
    emailController = TextEditingController(text: widget.user.email);
    phoneController = TextEditingController(text: widget.user.phone);
    addressController = TextEditingController(text: widget.user.addressLine);
    cityController = TextEditingController(text: widget.user.city);
    stateController = TextEditingController(text: widget.user.state);
    pincodeController = TextEditingController(text: widget.user.pincode);
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
          content: Text("Name, email and phone number are required."),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await FirebaseDatabaseHelper.instance.updateUser(
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

      widget.user.name = nameController.text.trim();
      widget.user.email = emailController.text.trim();
      widget.user.phone = phoneController.text.trim();
      widget.user.addressLine = addressController.text.trim();
      widget.user.city = cityController.text.trim();
      widget.user.state = stateController.text.trim();
      widget.user.pincode = pincodeController.text.trim();

      if (!mounted) return;

      setState(() {
        isSaving = false;
        isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Farm profile updated successfully!"),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to update profile: $e"),
          backgroundColor: AppColors.error,
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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Farm Profile",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      drawer: FarmerAppDrawer(
        selectedRoute: "/farmer-profile",
        user: widget.user,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              children: [
                // Farmer Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.floatingShadow,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.person_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        widget.user.name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.user.email,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: 15,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              "Registered Farmer",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Form Details Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Farmer Information",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              if (isEditing) {
                                _cancelEditing();
                              } else {
                                setState(() {
                                  isEditing = true;
                                });
                              }
                            },
                            icon: Icon(
                              isEditing
                                  ? Icons.close_rounded
                                  : Icons.edit_rounded,
                              size: 16,
                            ),
                            label: Text(isEditing ? "Cancel" : "Edit"),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildField("Full Name", nameController, Icons.person_outline_rounded),
                      const SizedBox(height: 14),

                      _buildField("Email Address", emailController, Icons.mail_outline_rounded),
                      const SizedBox(height: 14),

                      _buildField("Contact Phone", phoneController, Icons.phone_outlined),
                      const SizedBox(height: 14),

                      _buildField("Farm Location / Address", addressController, Icons.home_outlined),
                      const SizedBox(height: 14),

                      Row(
                        children: [
                          Expanded(
                            child: _buildField("City / District", cityController, Icons.location_city_outlined),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildField("State", stateController, Icons.map_outlined),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      _buildField("Pincode", pincodeController, Icons.pin_drop_outlined),
                      const SizedBox(height: 24),

                      if (isEditing)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton.icon(
                            onPressed: isSaving ? null : _saveProfile,
                            icon: isSaving
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Icon(Icons.check_circle_rounded),
                            label: Text(
                              isSaving ? "Saving..." : "Save Farm Details",
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          enabled: isEditing,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: isEditing ? AppColors.primary : AppColors.textMuted,
              size: 20,
            ),
            filled: true,
            fillColor: isEditing ? Colors.white : AppColors.surfaceVariant,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isEditing ? AppColors.border : Colors.transparent,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
      ],
    );
  }
}