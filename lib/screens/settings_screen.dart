import 'package:flutter/material.dart';
import '../widgets/app_drawer.dart';
import '../widgets/farmer_app_drawer.dart';
import '../models/user.dart';

class SettingsScreen extends StatefulWidget {
  final User user;

  const SettingsScreen({
    super.key,
    required this.user,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool notificationsEnabled = true;
  bool darkModeEnabled = false;
  bool productNotificationsEnabled = true;
  bool orderNotificationsEnabled = true;

  bool get isFarmer {
    return widget.user.role == "Farmer";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isFarmer ? "Farmer Settings" : "Settings",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      drawer: isFarmer
          ? FarmerAppDrawer(
        selectedRoute: "/settings",
        user: widget.user,
      )
          : AppDrawer(
        selectedRoute: "/settings",
        user: widget.user,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(25),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 600,
            ),
            child: isFarmer
                ? buildFarmerSettings()
                : buildCustomerSettings(),
          ),
        ),
      ),
    );
  }

  Widget buildFarmerSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          "Farmer Preferences",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                leading: buildIconContainer(
                  Icons.notifications_outlined,
                ),
                title: const Text(
                  "Notifications",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  "Receive farmer marketplace notifications",
                ),
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                  activeColor: Colors.green.shade700,
                ),
              ),
              const Divider(
                height: 1,
                indent: 75,
              ),
              ListTile(
                leading: buildIconContainer(
                  Icons.inventory_2_outlined,
                ),
                title: const Text(
                  "Product Notifications",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  "Get updates about your products",
                ),
                trailing: Switch(
                  value: productNotificationsEnabled,
                  onChanged: notificationsEnabled
                      ? (value) {
                    setState(() {
                      productNotificationsEnabled = value;
                    });
                  }
                      : null,
                  activeColor: Colors.green.shade700,
                ),
              ),
              const Divider(
                height: 1,
                indent: 75,
              ),
              ListTile(
                leading: buildIconContainer(
                  Icons.shopping_bag_outlined,
                ),
                title: const Text(
                  "Order Notifications",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  "Get notified when customers place orders",
                ),
                trailing: Switch(
                  value: orderNotificationsEnabled,
                  onChanged: notificationsEnabled
                      ? (value) {
                    setState(() {
                      orderNotificationsEnabled = value;
                    });
                  }
                      : null,
                  activeColor: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          "Farmer Account",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        buildAccountSection(),
        const SizedBox(height: 30),
        buildFooter(),
      ],
    );
  }

  Widget buildCustomerSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        const Text(
          "General",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            children: [
              ListTile(
                leading: buildIconContainer(
                  Icons.notifications_outlined,
                ),
                title: const Text(
                  "Notifications",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  "Receive order and marketplace notifications",
                ),
                trailing: Switch(
                  value: notificationsEnabled,
                  onChanged: (value) {
                    setState(() {
                      notificationsEnabled = value;
                    });
                  },
                  activeColor: Colors.green.shade700,
                ),
              ),
              const Divider(
                height: 1,
                indent: 75,
              ),
              ListTile(
                leading: buildIconContainer(
                  Icons.dark_mode_outlined,
                ),
                title: const Text(
                  "Dark Mode",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: const Text(
                  "Change the appearance of the application",
                ),
                trailing: Switch(
                  value: darkModeEnabled,
                  onChanged: (value) {
                    setState(() {
                      darkModeEnabled = value;
                    });
                  },
                  activeColor: Colors.green.shade700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          "Account",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 15),
        buildAccountSection(),
        const SizedBox(height: 30),
        buildFooter(),
      ],
    );
  }

  Widget buildAccountSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            leading: buildIconContainer(
              Icons.person_outline,
            ),
            title: Text(
              isFarmer ? "Farmer Account" : "Account",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              widget.user.email,
            ),
          ),
          const Divider(
            height: 1,
            indent: 75,
          ),
          ListTile(
            leading: Container(
              height: 45,
              width: 45,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
            ),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              "Sign out from your account",
            ),
            onTap: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                    (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget buildIconContainer(IconData icon) {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon,
        color: Colors.green.shade700,
      ),
    );
  }

  Widget buildFooter() {
    return Column(
      children: [
        Center(
          child: Text(
            "Farmer Marketplace",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Center(
          child: Text(
            "Version 1.0.0",
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }
}