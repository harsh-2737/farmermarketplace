import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../database/firebase_database_helper.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import 'orders_screen.dart';

class PaymentScreen extends StatefulWidget {
  final User user;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.user,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;

  final FirebaseDatabaseHelper _database = FirebaseDatabaseHelper.instance;

  bool isProcessing = false;
  bool isCreatingOrder = false;

  @override
  void initState() {
    super.initState();

    _razorpay = Razorpay();

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_SUCCESS,
      _handlePaymentSuccess,
    );

    _razorpay.on(
      Razorpay.EVENT_PAYMENT_ERROR,
      _handlePaymentError,
    );

    _razorpay.on(
      Razorpay.EVENT_EXTERNAL_WALLET,
      _handleExternalWallet,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openRazorpay();
    });
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _openRazorpay() {
    if (widget.amount <= 0 || isProcessing || isCreatingOrder) {
      return;
    }

    setState(() {
      isProcessing = true;
    });

    final options = {
      'key': 'rzp_test_Th6XwYK4bCjlI7',
      'amount': (widget.amount * 100).round(),
      'currency': 'INR',
      'name': 'Farmer Marketplace',
      'description': 'Farmer Marketplace Order Payment',
      'prefill': {
        'name': widget.user.name,
        'contact': widget.user.phone,
        'email': widget.user.email,
      },
      'theme': {
        'color': '#0F7A43',
      },
    };

    final bool isDesktop =
        !kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS);

    if (isDesktop) {
      setState(() {
        isProcessing = false;
      });
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text("Desktop Test Mode"),
          content: const Text(
            "Razorpay native mobile SDK is designed for Android and iOS devices. Would you like to simulate a successful payment for desktop testing?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _processOrderPlacement(
                  "pay_desktop_test_${DateTime.now().millisecondsSinceEpoch}",
                );
              },
              child: const Text("Simulate Success"),
            ),
          ],
        ),
      );
      return;
    }

    try {
      _razorpay.open(options);
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to initialize Razorpay: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handlePaymentSuccess(
    PaymentSuccessResponse response,
  ) async {
    await _processOrderPlacement(response.paymentId ?? '');
  }

  Future<void> _processOrderPlacement(String paymentId) async {
    if (!mounted || isCreatingOrder) return;

    setState(() {
      isProcessing = false;
      isCreatingOrder = true;
    });

    try {
      final cartRows = await _database.getCartItems(widget.user.id);

      if (cartRows.isEmpty) {
        throw Exception('Cart is empty. Order cannot be placed.');
      }

      final orderItems = <Map<String, dynamic>>[];

      for (final cartRow in cartRows) {
        final productId = (cartRow['productId'] as num?)?.toInt();
        final quantity = (cartRow['quantity'] as num?)?.toInt();

        if (productId == null || quantity == null || quantity <= 0) {
          continue;
        }

        final productMap = await _database.getProductById(productId);

        if (productMap == null) continue;

        final product = Product.fromMap(productMap);

        orderItems.add({
          'farmerId': product.farmerId,
          'farmerName': product.farmerName,
          'productId': product.id,
          'productName': product.name,
          'quantity': quantity,
          'price': product.price,
          'unit': product.unit,
          'status': 'Pending',
        });
      }

      if (orderItems.isEmpty) {
        throw Exception('No valid items found in your cart.');
      }

      final orderData = {
        'userId': widget.user.id,
        'customerName': widget.user.name,
        'phone': widget.user.phone,
        'addressLine': widget.user.addressLine,
        'city': widget.user.city,
        'state': widget.user.state,
        'pincode': widget.user.pincode,
        'totalAmount': widget.amount,
        'status': 'Pending',
        'paymentMethod': 'Razorpay',
        'paymentStatus': 'Paid',
        'paymentId': paymentId,
        'orderDate': DateTime.now().toIso8601String(),
      };

      final paymentData = {
        'userId': widget.user.id,
        'amount': widget.amount,
        'paymentMethod': 'Razorpay',
        'paymentStatus': 'Paid',
        'paymentId': paymentId,
        'paymentDate': DateTime.now().toIso8601String(),
      };

      final orderId = await _database.createCompleteOrder(
        order: orderData,
        orderItems: orderItems,
        payment: paymentData,
        userId: widget.user.id,
      );

      if (!mounted) return;

      setState(() {
        isCreatingOrder = false;
      });

      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: AppColors.successBg,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.success,
                        size: 46,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Payment Successful!',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your order has been placed and forwarded to local farmers for harvesting.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Order Reference',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '$orderId',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Amount Paid',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '₹${widget.amount.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                          if (paymentId.isNotEmpty) ...[
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Payment ID',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    paymentId,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(dialogContext);
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OrdersScreen(
                                user: widget.user,
                              ),
                            ),
                            (route) => false,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Track My Orders',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isCreatingOrder = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment received, but order placement failed: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 6),
        ),
      );
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;

    setState(() {
      isProcessing = false;
      isCreatingOrder = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment cancelled or failed: ${response.message ?? ''}'),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;

    setState(() {
      isProcessing = false;
      isCreatingOrder = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet chosen: ${response.walletName ?? ''}'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Payment Gateway',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Gateway Shield
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                    boxShadow: AppColors.floatingShadow,
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    size: 46,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 24),

                // Amount Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Total Payable',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '₹${widget.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Razorpay Verified Merchant',
                              style: TextStyle(
                                fontSize: 11,
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
                const SizedBox(height: 28),

                // Processing / Pay Button
                if (isCreatingOrder) ...[
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 14),
                  const Text(
                    'Confirming payment & notifying farmers...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ] else if (isProcessing) ...[
                  const CircularProgressIndicator(color: AppColors.primary),
                  const SizedBox(height: 14),
                  const Text(
                    'Opening Razorpay Secure Gateway...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ] else ...[
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _openRazorpay,
                      icon: const Icon(Icons.payment_rounded, size: 20),
                      label: const Text(
                        'Launch Payment Gateway',
                        style: TextStyle(
                          fontSize: 16,
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

                const SizedBox(height: 24),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_rounded, size: 14, color: AppColors.textMuted),
                    SizedBox(width: 6),
                    Text(
                      '256-bit Bank Grade Encryption',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}