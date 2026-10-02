import 'package:flutter/material.dart';
import '../database/firebase_database_helper.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../theme/app_theme.dart';
import '../widgets/farmer_app_drawer.dart';
import 'add_product_screen.dart';

class MyProductsScreen extends StatefulWidget {
  final User user;

  const MyProductsScreen({
    super.key,
    required this.user,
  });

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Product> products = [];
  bool isLoading = true;
  String searchText = "";

  final List<String> categories = [
    "Vegetables",
    "Grains",
    "Fruits",
    "Dairy",
    "Spices",
  ];

  final List<String> units = [
    "KG",
    "Quintal",
    "Ton",
    "Liter",
    "Piece",
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    if (mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final result = await FirebaseDatabaseHelper.instance
          .getProductsByFarmer(widget.user.id);

      if (!mounted) return;

      setState(() {
        products =
            result.map((product) => Product.fromMap(product)).toList();
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to load inventory: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Delete Product",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to remove ${product.name} from your active inventory?",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: Colors.white,
              ),
              child: const Text("Remove"),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await FirebaseDatabaseHelper.instance.deleteProduct(product.id);

      if (!mounted) return;

      await _loadProducts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Product removed from inventory"),
          backgroundColor: AppColors.primary,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to delete product: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showEditProductDialog(Product product) {
    final nameController = TextEditingController(text: product.name);
    final priceController =
        TextEditingController(text: product.price.toStringAsFixed(0));
    final quantityController =
        TextEditingController(text: product.quantity.toStringAsFixed(0));
    final imageController = TextEditingController(text: product.image);
    final descriptionController =
        TextEditingController(text: product.description);

    String selectedCat = categories.contains(product.category)
        ? product.category
        : categories.first;

    String selectedU =
        units.contains(product.unit) ? product.unit : units.first;

    bool isSubmitting = false;

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Edit Product",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close_rounded, size: 20),
                            onPressed: () => Navigator.pop(dialogCtx),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _dialogLabel("Product Name"),
                      TextField(
                        controller: nameController,
                        decoration: _dialogInputDeco("e.g. Fresh Tomatoes"),
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _dialogLabel("Category"),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedCat,
                                      isExpanded: true,
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(() {
                                            selectedCat = val;
                                          });
                                        }
                                      },
                                      items: categories
                                          .map((c) => DropdownMenuItem(
                                                value: c,
                                                child: Text(c,
                                                    style: const TextStyle(
                                                        fontSize: 13)),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _dialogLabel("Unit"),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedU,
                                      isExpanded: true,
                                      onChanged: (val) {
                                        if (val != null) {
                                          setDialogState(() {
                                            selectedU = val;
                                          });
                                        }
                                      },
                                      items: units
                                          .map((u) => DropdownMenuItem(
                                                value: u,
                                                child: Text(u,
                                                    style: const TextStyle(
                                                        fontSize: 13)),
                                              ))
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _dialogLabel("Price (₹)"),
                                TextField(
                                  controller: priceController,
                                  keyboardType: TextInputType.number,
                                  decoration: _dialogInputDeco("e.g. 60"),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _dialogLabel("Stock Available"),
                                TextField(
                                  controller: quantityController,
                                  keyboardType: TextInputType.number,
                                  decoration: _dialogInputDeco("e.g. 100"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      _dialogLabel("Description"),
                      TextField(
                        controller: descriptionController,
                        maxLines: 2,
                        decoration: _dialogInputDeco("Product notes"),
                      ),
                      const SizedBox(height: 22),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () async {
                                  final messenger = ScaffoldMessenger.of(context);
                                  final double? price = double.tryParse(
                                      priceController.text.trim());
                                  final double? qty = double.tryParse(
                                      quantityController.text.trim());

                                  if (nameController.text.trim().isEmpty ||
                                      price == null ||
                                      qty == null) {
                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Please enter valid name, price and stock."),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                    return;
                                  }

                                  setDialogState(() {
                                    isSubmitting = true;
                                  });

                                  try {
                                    await FirebaseDatabaseHelper.instance
                                        .updateProductByFields(
                                      id: product.id,
                                      name: nameController.text.trim(),
                                      category: selectedCat,
                                      price: price,
                                      quantity: qty,
                                      unit: selectedU,
                                      image: imageController.text.trim(),
                                      description:
                                          descriptionController.text.trim(),
                                    );

                                    if (!dialogCtx.mounted) return;
                                    Navigator.pop(dialogCtx);

                                    if (!mounted) return;
                                    await _loadProducts();

                                    messenger.showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Product updated successfully."),
                                        backgroundColor: AppColors.success,
                                      ),
                                    );
                                  } catch (e) {
                                    setDialogState(() {
                                      isSubmitting = false;
                                    });
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text("Update failed: $e"),
                                        backgroundColor: AppColors.error,
                                      ),
                                    );
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "Save Changes",
                                  style: TextStyle(fontWeight: FontWeight.w700),
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
      },
    );
  }

  Widget _dialogLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  InputDecoration _dialogInputDeco(String hint) {
    return InputDecoration(
      hintText: hint,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  IconData _getProductIcon(String category) {
    switch (category.toLowerCase()) {
      case "vegetables":
        return Icons.eco_rounded;
      case "grains":
        return Icons.grass_rounded;
      case "fruits":
        return Icons.apple_rounded;
      case "dairy":
        return Icons.local_drink_rounded;
      case "spices":
        return Icons.spa_rounded;
      default:
        return Icons.inventory_2_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtered = products.where((p) {
      if (searchText.trim().isEmpty) return true;
      return p.name.toLowerCase().contains(searchText.toLowerCase().trim());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "My Products",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _loadProducts,
          ),
          const SizedBox(width: 8),
        ],
      ),
      drawer: FarmerAppDrawer(
        selectedRoute: "/my-products",
        user: widget.user,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddProductScreen(user: widget.user),
            ),
          );
          _loadProducts();
        },
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
              onRefresh: _loadProducts,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    children: [
                      // Search & Count bar
                      Container(
                        padding: const EdgeInsets.all(16),
                        color: Colors.white,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceVariant,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: TextField(
                                onChanged: (val) {
                                  setState(() {
                                    searchText = val;
                                  });
                                },
                                decoration: const InputDecoration(
                                  hintText: "Search your inventory...",
                                  prefixIcon: Icon(Icons.search_rounded,
                                      color: AppColors.primary, size: 20),
                                  border: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 12),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "${filtered.length} Products Listed",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryLight,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Text(
                                    "Active in Marketplace",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // List of products
                      Expanded(
                        child: filtered.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(16),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final product = filtered[index];
                                  final bool isOutOfStock =
                                      product.quantity <= 0;

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border:
                                          Border.all(color: AppColors.border),
                                      boxShadow: AppColors.softShadow,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Row(
                                        children: [
                                          // Thumbnail
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            child: Container(
                                              width: 68,
                                              height: 68,
                                              color: AppColors.surfaceVariant,
                                              child: product.image.isNotEmpty
                                                  ? Image.network(
                                                      product.image,
                                                      fit: BoxFit.cover,
                                                      errorBuilder:
                                                          (c, e, s) =>
                                                              Center(
                                                        child: Icon(
                                                          _getProductIcon(
                                                              product.category),
                                                          color:
                                                              AppColors.primary,
                                                          size: 26,
                                                        ),
                                                      ),
                                                    )
                                                  : Center(
                                                      child: Icon(
                                                        _getProductIcon(
                                                            product.category),
                                                        color:
                                                            AppColors.primary,
                                                        size: 26,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                          const SizedBox(width: 14),

                                          // Info
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        product.name,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: AppColors
                                                              .textPrimary,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 6,
                                                          vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: isOutOfStock
                                                            ? AppColors.errorBg
                                                            : AppColors
                                                                .successBg,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(6),
                                                      ),
                                                      child: Text(
                                                        isOutOfStock
                                                            ? "Out of Stock"
                                                            : "${product.quantity.toStringAsFixed(0)} ${product.unit} left",
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color: isOutOfStock
                                                              ? AppColors.error
                                                              : AppColors
                                                                  .success,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 3),
                                                Text(
                                                  product.category,
                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        AppColors.textSecondary,
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                Text(
                                                  "₹${product.price.toStringAsFixed(0)} / ${product.unit}",
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.w800,
                                                    color: AppColors.primary,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // Actions
                                          Column(
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.edit_outlined,
                                                    size: 20,
                                                    color: AppColors.primary),
                                                tooltip: "Edit Product",
                                                onPressed: () =>
                                                    _showEditProductDialog(
                                                        product),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.delete_outline_rounded,
                                                    size: 20,
                                                    color: AppColors.error),
                                                tooltip: "Delete Product",
                                                onPressed: () =>
                                                    _deleteProduct(product),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.inventory_2_outlined,
                size: 40,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              "No Products Found",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Add fresh agricultural harvest to sell directly to local consumers.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}