import 'package:flutter/material.dart';
import '../models/user.dart';
import '../database/database_helper.dart';
import '../widgets/farmer_app_drawer.dart';
import 'add_product_screen.dart';
import 'my_products_screen.dart';
import 'farmer_orders_screen.dart';
import 'farmer_profile_screen.dart';

class FarmerDashboardScreen extends StatefulWidget {
  final User user;

  const FarmerDashboardScreen({
    super.key,
    required this.user,
  });

  @override
  State<FarmerDashboardScreen> createState() =>
      _FarmerDashboardScreenState();
}

class _FarmerDashboardScreenState
    extends State<FarmerDashboardScreen> {
  int myProductCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProductCount();
  }

  Future<void> _loadProductCount() async {
    final products =
    await DatabaseHelper.instance.getProductsByFarmer(
      widget.user.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      myProductCount = products.length;
    });
  }

  Future<void> _openAddProduct() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return AddProductScreen(
            user: widget.user,
          );
        },
      ),
    );

    _loadProductCount();
  }

  Future<void> _openMyProducts() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return MyProductsScreen(
            user: widget.user,
          );
        },
      ),
    );

    _loadProductCount();
  }

  void _openOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return FarmerOrdersScreen(
            user: widget.user,
          );
        },
      ),
    );
  }

  void _openProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return FarmerProfileScreen(
            user: widget.user,
          );
        },
      ),
    );
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Farmer Dashboard",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: FarmerAppDrawer(
        selectedRoute: "/farmer-dashboard",
        user: widget.user,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _openAddProduct,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Product"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 25),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green.shade700,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.agriculture,
                      size: 35,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Welcome Farmer",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Farmer Overview",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _dashboardCard(
                    Icons.inventory_2,
                    "My Products",
                    myProductCount.toString(),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _dashboardCard(
                    Icons.shopping_bag,
                    "Orders",
                    "0",
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _dashboardCard(
                    Icons.currency_rupee,
                    "Sales",
                    "₹0",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            const Text(
              "Quick Actions",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _actionCard(
                    Icons.add_box,
                    "Add Product",
                    _openAddProduct,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _actionCard(
                    Icons.inventory,
                    "My Products",
                    _openMyProducts,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: _actionCard(
                    Icons.shopping_bag,
                    "Orders",
                    _openOrders,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: _actionCard(
                    Icons.person,
                    "My Profile",
                    _openProfile,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _dashboardCard(
      IconData icon,
      String title,
      String value,
      ) {
    return Container(
      height: 125,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: Colors.green.shade700,
            size: 30,
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionCard(
      IconData icon,
      String title,
      VoidCallback onTap,
      ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 100,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: Colors.green.shade700,
              size: 30,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}