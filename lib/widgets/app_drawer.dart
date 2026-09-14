import 'package:flutter/material.dart';

class AppDrawer extends StatelessWidget {
  final String selectedRoute;

  const AppDrawer({
    super.key,
    required this.selectedRoute,
  });

  void navigateTo(
      BuildContext context,
      String route,
      ) {
    Navigator.pop(context);

    if (selectedRoute != route) {
      Navigator.pushReplacementNamed(context, route);
    }
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

                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Text(
                      "Harsh Patel",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: 4),

                    Text(
                      "Customer",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
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

                Navigator.pop(context);

                // Later we will add logout logic here.

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Logout clicked"),
                  ),
                );
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