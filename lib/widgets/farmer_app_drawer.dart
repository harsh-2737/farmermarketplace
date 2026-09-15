import 'package:flutter/material.dart';
import '../models/user.dart';
import '../screens/farmer_dashboard_screen.dart';
import '../screens/my_products_screen.dart';
import '../screens/farmer_orders_screen.dart';
import '../screens/farmer_profile_screen.dart';
import '../screens/settings_screen.dart';
import '../screens/login_screen.dart';

class FarmerAppDrawer extends StatelessWidget {
  final String selectedRoute;
  final User user;

  const FarmerAppDrawer({
    super.key,
    required this.selectedRoute,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green.shade700,
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(
                Icons.agriculture,
                color: Colors.green.shade700,
                size: 32,
              ),
            ),
            accountName: Text(
              user.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            accountEmail: Text(
              user.email,
            ),
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _drawerItem(
                  context,
                  icon: Icons.home,
                  title: "Home",
                  route: "/farmer-dashboard",
                  onTap: () {
                    Navigator.pop(context);

                    if (selectedRoute != "/farmer-dashboard") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FarmerDashboardScreen(
                                user: user,
                              ),
                        ),
                      );
                    }
                  },
                ),

                _drawerItem(
                  context,
                  icon: Icons.inventory_2,
                  title: "My Products",
                  route: "/my-products",
                  onTap: () {
                    Navigator.pop(context);

                    if (selectedRoute != "/my-products") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              MyProductsScreen(
                                user: user,
                              ),
                        ),
                      );
                    }
                  },
                ),

                _drawerItem(
                  context,
                  icon: Icons.shopping_bag,
                  title: "Orders",
                  route: "/farmer-orders",
                  onTap: () {
                    Navigator.pop(context);

                    if (selectedRoute != "/farmer-orders") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FarmerOrdersScreen(
                                user: user,
                              ),
                        ),
                      );
                    }
                  },
                ),

                _drawerItem(
                  context,
                  icon: Icons.person,
                  title: "Profile",
                  route: "/farmer-profile",
                  onTap: () {
                    Navigator.pop(context);

                    if (selectedRoute != "/farmer-profile") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FarmerProfileScreen(
                                user: user,
                              ),
                        ),
                      );
                    }
                  },
                ),

                _drawerItem(
                  context,
                  icon: Icons.settings,
                  title: "Settings",
                  route: "/settings",
                  onTap: () {
                    Navigator.pop(context);

                    if (selectedRoute != "/settings") {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SettingsScreen(
                                user: user,
                              ),
                        ),
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          const Divider(),

          ListTile(
            leading: const Icon(
              Icons.logout,
              color: Colors.red,
            ),
            title: const Text(
              "Logout",
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                  const LoginScreen(),
                ),
                    (route) => false,
              );
            },
          ),

          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _drawerItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String route,
        required VoidCallback onTap,
      }) {
    final bool selected = selectedRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: selected
            ? Colors.green.shade100
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected
              ? Colors.green.shade700
              : Colors.grey.shade700,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected
                ? Colors.green.shade700
                : Colors.black87,
            fontWeight: selected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        trailing: selected
            ? Icon(
          Icons.arrow_forward_ios,
          size: 15,
          color: Colors.green.shade700,
        )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        onTap: onTap,
      ),
    );
  }
}