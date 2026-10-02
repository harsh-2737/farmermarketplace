import 'package:flutter/material.dart';
import '../database/firebase_database_helper.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/farmer_app_drawer.dart';
import 'add_product_screen.dart';
import 'farmer_order_details_screen.dart';
import 'farmer_orders_screen.dart';
import 'farmer_profile_screen.dart';
import 'my_products_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  final User user;

  const FarmerDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<FarmerDashboardScreen> createState() => _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState extends State<FarmerDashboardScreen> {
  int myProductCount = 0;
  int myOrderCount = 0;
  double totalRevenue = 0.0;
  List<Map<String, dynamic>> recentOrders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final products = await FirebaseDatabaseHelper.instance
          .getProductsByFarmer(widget.user.id);

      final orders = await FirebaseDatabaseHelper.instance
          .getFarmerOrders(widget.user.id);

      double sales = 0;
      for (final o in orders) {
        final price = (o['price'] as num?)?.toDouble() ?? 0;
        final qty = (o['quantity'] as num?)?.toInt() ?? 0;
        sales += price * qty;
      }

      if (!mounted) return;

      setState(() {
        myProductCount = products.length;
        myOrderCount = orders.length;
        totalRevenue = sales;
        recentOrders = orders.take(3).toList();
        isLoading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _openAddProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddProductScreen(user: widget.user),
      ),
    );
    _loadDashboardData();
  }

  Future<void> _openMyProducts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MyProductsScreen(user: widget.user),
      ),
    );
    _loadDashboardData();
  }

  Future<void> _openOrders() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmerOrdersScreen(farmer: widget.user),
      ),
    );
    _loadDashboardData();
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FarmerProfileScreen(user: widget.user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Farmer Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: "Refresh Data",
            onPressed: _loadDashboardData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: FarmerAppDrawer(
        selectedRoute: "/farmer-dashboard",
        user: widget.user,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddProduct,
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          "Add Product",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadDashboardData,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  final double horizontalPadding = isWide ? 32 : 16;

                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: horizontalPadding,
                      vertical: 16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Farmer Profile Hero Banner
                            _buildHeroBanner(),
                            const SizedBox(height: 22),

                            // Metrics Overview
                            const Text(
                              "Performance Overview",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildMetricsRow(constraints.maxWidth),
                            const SizedBox(height: 26),

                            // Quick Actions Grid
                            const Text(
                              "Quick Management",
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _buildActionGrid(),
                            const SizedBox(height: 26),

                            // Recent Orders
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  "Recent Customer Orders",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                if (recentOrders.isNotEmpty)
                                  TextButton(
                                    onPressed: _openOrders,
                                    child: const Text(
                                      "View All",
                                      style: TextStyle(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            recentOrders.isEmpty
                                ? _buildEmptyOrdersCard()
                                : _buildRecentOrdersList(),
                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildHeroBanner() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColors.floatingShadow,
        image: const DecorationImage(
          image: NetworkImage(AppImages.farmerHero),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.black.withValues(alpha: 0.85),
              Colors.black.withValues(alpha: 0.55),
              Colors.black.withValues(alpha: 0.25),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppColors.softShadow,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Center(
                child: Text(
                  widget.user.name.isNotEmpty
                      ? widget.user.name.substring(0, 1).toUpperCase()
                      : "F",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "FARMER PORTAL",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.user.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.user.city.isNotEmpty
                        ? "Operating from ${widget.user.city}, ${widget.user.state}"
                        : "Verified Farmer",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricsRow(double screenWidth) {
    return Row(
      children: [
        Expanded(
          child: _metricCard(
            icon: Icons.inventory_2_rounded,
            title: "My Products",
            value: "$myProductCount",
            color: AppColors.primary,
            onTap: _openMyProducts,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            icon: Icons.local_shipping_rounded,
            title: "Orders",
            value: "$myOrderCount",
            color: AppColors.secondary,
            onTap: _openOrders,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _metricCard(
            icon: Icons.currency_rupee_rounded,
            title: "Total Revenue",
            value: "₹${totalRevenue.toStringAsFixed(0)}",
            color: AppColors.accentGreen,
            onTap: _openOrders,
          ),
        ),
      ],
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: AppColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionGrid() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _actionButton(
                icon: Icons.add_box_rounded,
                title: "Add New Product",
                subtitle: "Upload fresh harvest",
                color: AppColors.primary,
                onTap: _openAddProduct,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                icon: Icons.inventory_rounded,
                title: "Manage Inventory",
                subtitle: "Stock & prices",
                color: const Color(0xFF3B82F6),
                onTap: _openMyProducts,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _actionButton(
                icon: Icons.shopping_bag_rounded,
                title: "Customer Orders",
                subtitle: "Confirm & dispatch",
                color: AppColors.secondary,
                onTap: _openOrders,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _actionButton(
                icon: Icons.badge_rounded,
                title: "Farm Profile",
                subtitle: "Farmer details",
                color: const Color(0xFF8B5CF6),
                onTap: _openProfile,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrdersList() {
    return Column(
      children: recentOrders.map((data) {
        final orderId = (data['orderId'] as num?)?.toInt() ?? 0;
        final productName = data['productName']?.toString() ?? 'Product';
        final customerName = data['customerName']?.toString() ?? 'Customer';
        final quantity = (data['quantity'] as num?)?.toInt() ?? 0;
        final price = (data['price'] as num?)?.toDouble() ?? 0.0;
        final status = data['status']?.toString() ?? 'Pending';
        final isConfirmed = status.toLowerCase() == 'confirmed';

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),

            title: Text(
              "$productName ($quantity Units)",
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
            ),
            subtitle: Text(
              "Order $orderId • by $customerName",
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${(price * quantity).toStringAsFixed(0)}",
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                    fontSize: 14,
                  ),
                ),
                Text(
                  status,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isConfirmed ? AppColors.info : AppColors.warning,
                  ),
                ),
              ],
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FarmerOrderDetailsScreen(
                    farmer: widget.user,
                    data: data,
                  ),
                ),
              );
              _loadDashboardData();
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildEmptyOrdersCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: const Column(
        children: [
          Icon(Icons.inventory_2_outlined, color: AppColors.textMuted, size: 40),
          SizedBox(height: 10),
          Text(
            "No incoming orders yet",
            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
          ),
          SizedBox(height: 4),
          Text(
            "When consumers buy your products, orders will show up here.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}