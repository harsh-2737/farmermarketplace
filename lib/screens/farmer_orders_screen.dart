import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/user.dart';
import '../widgets/farmer_app_drawer.dart';

class FarmerOrdersScreen extends StatefulWidget {
  final User user;

  const FarmerOrdersScreen({
    super.key,
    required this.user,
  });

  @override
  State<FarmerOrdersScreen> createState() =>
      _FarmerOrdersScreenState();
}

class _FarmerOrdersScreenState
    extends State<FarmerOrdersScreen> {
  List<Map<String, dynamic>> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      isLoading = true;
    });

    final result =
    await DatabaseHelper.instance.getFarmerOrders(
      widget.user.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      orders = result;
      isLoading = false;
    });
  }

  Color _statusColor(String status) {
    if (status == "Delivered" ||
        status == "Completed") {
      return Colors.green;
    }

    if (status == "Cancelled") {
      return Colors.red;
    }

    if (status == "Shipped") {
      return Colors.blue;
    }

    return Colors.orange;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Orders",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: FarmerAppDrawer(
        selectedRoute: "/farmer-orders",
        user: widget.user,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : orders.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment:
          MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_bag_outlined,
              size: 70,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 15),
            const Text(
              "No Orders Yet",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Orders containing your products will appear here",
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];

          final status =
              order['status'] ?? "Pending";

          return Container(
            margin:
            const EdgeInsets.only(bottom: 15),
            padding:
            const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius:
              BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color:
                  Colors.grey.shade300,
                  blurRadius: 5,
                  offset:
                  const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding:
                      const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color:
                        Colors.green.shade50,
                        borderRadius:
                        BorderRadius.circular(
                            10),
                      ),
                      child: Icon(
                        Icons.shopping_bag,
                        color:
                        Colors.green.shade700,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            "Order #${order['orderId']}",
                            style:
                            const TextStyle(
                              fontSize: 17,
                              fontWeight:
                              FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Customer ID: ${order['userId']}",
                            style: TextStyle(
                              color: Colors
                                  .grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(
                          status,
                        ).withOpacity(0.1),
                        borderRadius:
                        BorderRadius.circular(
                            20),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color:
                          _statusColor(
                            status,
                          ),
                          fontWeight:
                          FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 25),
                Text(
                  order['productName'] ?? "",
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "Quantity: ${order['quantity']} ${order['unit']}",
                      ),
                    ),
                    Text(
                      "₹${((order['price'] as num) * (order['quantity'] as num)).toStringAsFixed(2)}",
                      style: TextStyle(
                        color: Colors
                            .green.shade700,
                        fontWeight:
                        FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  "Delivery Address",
                  style: const TextStyle(
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  "${order['addressLine']}, ${order['city']}, ${order['state']} - ${order['pincode']}",
                  style: TextStyle(
                    color:
                    Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "Order Date: ${order['orderDate']}",
                  style: TextStyle(
                    color:
                    Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}