import 'package:flutter/material.dart';
import '../database/firebase_database_helper.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/farmer_app_drawer.dart';

class FarmerOrderDetailsScreen extends StatefulWidget {
  final User farmer;
  final Map<String, dynamic> data;

  const FarmerOrderDetailsScreen({
    super.key,
    required this.farmer,
    required this.data,
  });

  @override
  State<FarmerOrderDetailsScreen> createState() =>
      _FarmerOrderDetailsScreenState();
}

class _FarmerOrderDetailsScreenState extends State<FarmerOrderDetailsScreen> {
  final FirebaseDatabaseHelper _database = FirebaseDatabaseHelper.instance;
  bool isUpdating = false;

  String get customerName =>
      widget.data['customerName']?.toString() ?? 'Not available';

  String get phone => widget.data['phone']?.toString() ?? 'Not available';

  String get addressLine => widget.data['addressLine']?.toString() ?? '';

  String get city => widget.data['city']?.toString() ?? '';

  String get state => widget.data['state']?.toString() ?? '';

  String get pincode => widget.data['pincode']?.toString() ?? '';

  String get productName => widget.data['productName']?.toString() ?? 'Product';

  int get quantity => (widget.data['quantity'] as num?)?.toInt() ?? 0;

  double get price => (widget.data['price'] as num?)?.toDouble() ?? 0.0;

  double get itemTotal => price * quantity;

  String get paymentMethod =>
      widget.data['paymentMethod']?.toString() ?? 'COD';

  String get paymentStatus =>
      widget.data['paymentStatus']?.toString() ?? 'Pending';

  String get status => widget.data['status']?.toString() ?? 'Pending';

  String get fullAddress {
    final parts = [addressLine, city, state, pincode]
        .where((val) => val.isNotEmpty)
        .toList();
    return parts.join(', ');
  }

  Future<void> _confirmOrder() async {
    final rawOrderId = widget.data['orderId'];
    final orderId = rawOrderId is num
        ? rawOrderId.toInt()
        : int.tryParse(rawOrderId?.toString() ?? '');

    if (orderId == null) return;

    final rawOrderItemId = widget.data['orderItemId'];
    final orderItemId = rawOrderItemId is num
        ? rawOrderItemId.toInt()
        : int.tryParse(rawOrderItemId?.toString() ?? '');

    setState(() {
      isUpdating = true;
    });

    try {
      final result = await _database.confirmOrderAndReduceStock(
        orderId,
        farmerId: widget.farmer.id,
        orderItemId: orderItemId,
      );

      if (!mounted) return;

      if (result == 0) throw Exception('Order not found');
      if (result == 2) throw Exception('This item is already confirmed');
      if (result == 3) {
        throw Exception('Order cannot be confirmed in its current status');
      }
      if (result == 4) throw Exception('No products found for this order');

      setState(() {
        isUpdating = false;
        widget.data['status'] = 'Confirmed';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Order confirmed! Inventory stock was reduced automatically.',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isUpdating = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to confirm order: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final orderId = widget.data['orderId']?.toString() ?? '';
    final isConfirmed = status.toLowerCase() == 'confirmed';

    return Scaffold(
      backgroundColor: AppColors.background,
      drawer: FarmerAppDrawer(
        selectedRoute: "/farmer-orders",
        user: widget.farmer,
      ),
      appBar: AppBar(
        title: Text(
          'Order $orderId Details',
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    gradient: isConfirmed
                        ? AppColors.primaryGradient
                        : AppColors.orangeGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: AppColors.floatingShadow,
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Order $orderId',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isConfirmed ? 'Order Confirmed' : 'Action Required: Pending',
                          style: TextStyle(
                            color: isConfirmed
                                ? AppColors.primary
                                : AppColors.secondary,
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Customer Information Card
                _buildSectionCard(
                  title: "Customer & Destination",
                  children: [
                    _infoRow("Customer Name", customerName),
                    _infoRow("Contact Phone", phone),
                    _infoRow("Delivery Address", fullAddress.isEmpty ? 'Not specified' : fullAddress),
                  ],
                ),
                const SizedBox(height: 16),

                // Product Information Card
                _buildSectionCard(
                  title: "Product & Quantity",
                  children: [
                    _infoRow("Product Ordered", productName),
                    _infoRow("Quantity", "$quantity Units"),
                    _infoRow("Unit Price", "₹${price.toStringAsFixed(2)}"),
                    const Divider(height: 16),
                    _infoRow(
                      "Product Total",
                      "₹${itemTotal.toStringAsFixed(2)}",
                      isBold: true,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Payment Status Card
                _buildSectionCard(
                  title: "Payment Summary",
                  children: [
                    _infoRow("Payment Method", paymentMethod),
                    _infoRow("Payment Status", paymentStatus),
                  ],
                ),
                const SizedBox(height: 24),

                // Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isUpdating || isConfirmed ? null : _confirmOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                          isConfirmed ? AppColors.successBg : Colors.grey.shade300,
                      disabledForegroundColor:
                          isConfirmed ? AppColors.success : Colors.grey.shade600,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isConfirmed
                                    ? Icons.check_circle_rounded
                                    : Icons.inventory_rounded,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isConfirmed
                                    ? 'Order Confirmed & Stock Deducted'
                                    : 'Confirm Order & Deduct Stock',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
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

  Widget _buildSectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 14),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
                color: isBold ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}