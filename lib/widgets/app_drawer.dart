import 'package:flutter/material.dart';
import '../models/user.dart';
import '../screens/home_screen.dart';
import '../screens/products_screen.dart';
import '../screens/cart_screen.dart';
import '../screens/orders_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/address_screen.dart';
import '../screens/settings_screen.dart';

class AppDrawer extends StatelessWidget {
  final String selectedRoute;
  final User user;

  const AppDrawer({
    super.key,
    required this.selectedRoute,
    required this.user,
  });

  void navigateTo(
      BuildContext context,
      String route,
      ) {
    Navigator.pop(context);

    if (selectedRoute == route) {
      return;
    }

    if (route == "/home") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(
            user: user,
          ),
        ),
      );
    } else if (route == "/products") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProductsScreen(
            user: user,
          ),
        ),
      );
    } else if (route == "/cart") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CartScreen(
            user: user,
          ),
        ),
      );
    } else if (route == "/orders") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => OrdersScreen(
            user: user,
          ),
        ),
      );
    } else if (route == "/profile") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(
            user: user,
          ),
        ),
      );
    } else if (route == "/address") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AddressScreen(
            user: user,
          ),
        ),
      );
    } else if (route == "/settings") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => SettingsScreen(
            user: user,
          ),
        ),
      );
    }
  }

  void logout(BuildContext context) {
    Navigator.pushNamedAndRemoveUntil(
      context,
      "/login",
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 290,
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.only(
              top: 55,
              bottom: 25,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              color: Colors.green.shade700,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 35,
                    color: Colors.green.shade700,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        user.role,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                buildMenuItem(
                  context,
                  icon: Icons.home_outlined,
                  selectedIcon: Icons.home,
                  title: "Home",
                  route: "/home",
                ),
                buildMenuItem(
                  context,
                  icon: Icons.agriculture_outlined,
                  selectedIcon: Icons.agriculture,
                  title: "Products",
                  route: "/products",
                ),
                buildMenuItem(
                  context,
                  icon: Icons.shopping_cart_outlined,
                  selectedIcon: Icons.shopping_cart,
                  title: "Cart",
                  route: "/cart",
                ),
                buildMenuItem(
                  context,
                  icon: Icons.inventory_2_outlined,
                  selectedIcon: Icons.inventory_2,
                  title: "My Orders",
                  route: "/orders",
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  child: Divider(),
                ),
                buildMenuItem(
                  context,
                  icon: Icons.person_outline,
                  selectedIcon: Icons.person,
                  title: "Profile",
                  route: "/profile",
                ),
                buildMenuItem(
                  context,
                  icon: Icons.location_on_outlined,
                  selectedIcon: Icons.location_on,
                  title: "Address",
                  route: "/address",
                ),
                buildMenuItem(
                  context,
                  icon: Icons.settings_outlined,
                  selectedIcon: Icons.settings,
                  title: "Settings",
                  route: "/settings",
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.only(
              left: 10,
              right: 10,
              bottom: 15,
            ),
            child: ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                "Logout",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onTap: () {
                logout(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildMenuItem(
      BuildContext context, {
        required IconData icon,
        required IconData selectedIcon,
        required String title,
        required String route,
      }) {
    bool isSelected = selectedRoute == route;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? Colors.green.shade100
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? selectedIcon : icon,
          color: isSelected
              ? Colors.green.shade800
              : Colors.grey.shade700,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected
                ? Colors.green.shade900
                : Colors.grey.shade800,
            fontWeight: isSelected
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
        trailing: isSelected
            ? Icon(
          Icons.arrow_forward_ios,
          size: 16,
          color: Colors.green.shade800,
        )
            : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          navigateTo(context, route);
        },
      ),
    );
  }
}