import 'package:flutter/material.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/farmer_app_drawer.dart';

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

  bool get isFarmer => widget.user.role == "Farmer";

  void _confirmSignOut() {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Sign Out", style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text("Are you sure you want to sign out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogCtx);
              Navigator.pushNamedAndRemoveUntil(
                context,
                "/login",
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text("Sign Out"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          isFarmer ? "Farmer Settings" : "App Settings",
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: isFarmer ? buildFarmerSettings() : buildCustomerSettings(),
          ),
        ),
      ),
    );
  }

  Widget buildFarmerSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Order & Product Alerts"),
        const SizedBox(height: 10),
        _settingsCard([
          _switchTile(
            icon: Icons.notifications_active_outlined,
            title: "Push Notifications",
            subtitle: "Receive alerts for incoming marketplace orders",
            value: notificationsEnabled,
            onChanged: (val) {
              setState(() {
                notificationsEnabled = val;
              });
            },
          ),
          const Divider(height: 1, indent: 56),
          _switchTile(
            icon: Icons.inventory_2_outlined,
            title: "Stock & Inventory Alerts",
            subtitle: "Reminders when product quantity runs low",
            value: productNotificationsEnabled,
            onChanged: notificationsEnabled
                ? (val) {
                    setState(() {
                      productNotificationsEnabled = val;
                    });
                  }
                : null,
          ),
          const Divider(height: 1, indent: 56),
          _switchTile(
            icon: Icons.local_shipping_outlined,
            title: "Customer Order Notifications",
            subtitle: "Instant notice when a customer completes payment",
            value: orderNotificationsEnabled,
            onChanged: notificationsEnabled
                ? (val) {
                    setState(() {
                      orderNotificationsEnabled = val;
                    });
                  }
                : null,
          ),
        ]),
        const SizedBox(height: 24),

        _sectionTitle("Account & Security"),
        const SizedBox(height: 10),
        _buildAccountSection(),
        const SizedBox(height: 32),

        _buildFooter(),
      ],
    );
  }

  Widget buildCustomerSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("Preferences"),
        const SizedBox(height: 10),
        _settingsCard([
          _switchTile(
            icon: Icons.notifications_none_rounded,
            title: "Order & Harvest Notifications",
            subtitle: "Updates when order is confirmed or status changes",
            value: notificationsEnabled,
            onChanged: (val) {
              setState(() {
                notificationsEnabled = val;
              });
            },
          ),
          const Divider(height: 1, indent: 56),
          _switchTile(
            icon: Icons.dark_mode_outlined,
            title: "Dark Appearance",
            subtitle: "Optimize display theme for low-light environments",
            value: darkModeEnabled,
            onChanged: (val) {
              setState(() {
                darkModeEnabled = val;
              });
            },
          ),
        ]),
        const SizedBox(height: 24),

        _sectionTitle("Account & Security"),
        const SizedBox(height: 10),
        _buildAccountSection(),
        const SizedBox(height: 32),

        _buildFooter(),
      ],
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(children: children),
    );
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.textSecondary,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeTrackColor: AppColors.primary,
      activeThumbColor: Colors.white,
    );
  }

  Widget _buildAccountSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.person_outline_rounded,
                  color: AppColors.primary, size: 20),
            ),
            title: Text(
              widget.user.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            subtitle: Text(
              widget.user.email,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ),
          const Divider(height: 1, indent: 56),
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.errorBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: AppColors.error, size: 20),
            ),
            title: const Text(
              "Sign Out",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.error,
              ),
            ),
            subtitle: const Text(
              "End your active session securely",
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            onTap: _confirmSignOut,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.storefront_rounded,
              size: 24,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Farmer Marketplace v1.0.0",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            "Direct Sustainable Farm Marketplace",
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}