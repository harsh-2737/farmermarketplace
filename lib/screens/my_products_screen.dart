import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/product.dart';
import '../models/user.dart';
import '../widgets/farmer_app_drawer.dart';
import 'add_product_screen.dart';

class MyProductsScreen extends StatefulWidget {
  final User user;

  const MyProductsScreen({
    super.key,
    required this.user,
  });

  @override
  State<MyProductsScreen> createState() =>
      _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen> {
  List<Product> products = [];
  bool isLoading = true;

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

    final result =
    await DatabaseHelper.instance.getProductsByFarmer(
      widget.user.id,
    );

    if (!mounted) {
      return;
    }

    setState(() {
      products = result
          .map((product) => Product.fromMap(product))
          .toList();
      isLoading = false;
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

    await _loadProducts();
  }

  Future<void> _deleteProduct(Product product) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "Delete Product",
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to delete ${product.name}?",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    try {
      await DatabaseHelper.instance.deleteProduct(
        product.id,
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "${product.name} deleted successfully",
          ),
          backgroundColor: Colors.green.shade700,
        ),
      );

      await _loadProducts();
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Unable to delete product: $e",
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _editProduct(Product product) async {
    final nameController =
    TextEditingController(text: product.name);

    final priceController = TextEditingController(
      text: product.price.toString(),
    );

    final quantityController = TextEditingController(
      text: product.quantity.toString(),
    );

    final descriptionController =
    TextEditingController(
      text: product.description,
    );

    String selectedCategory = product.category;
    String selectedUnit = product.unit;

    if (!categories.contains(selectedCategory)) {
      selectedCategory = categories.first;
    }

    if (!units.contains(selectedUnit)) {
      selectedUnit = units.first;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text(
                "Update Product",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: SizedBox(
                width: 450,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: "Product Name",
                          prefixIcon: const Icon(
                            Icons.shopping_basket,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedCategory,
                        decoration: InputDecoration(
                          labelText: "Category",
                          prefixIcon: const Icon(
                            Icons.category,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                        items: categories.map((category) {
                          return DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setDialogState(() {
                            selectedCategory = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: priceController,
                        keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: "Price",
                          prefixIcon: const Icon(
                            Icons.currency_rupee,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: quantityController,
                        keyboardType:
                        const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: "Quantity",
                          prefixIcon: const Icon(
                            Icons.inventory_2,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: selectedUnit,
                        decoration: InputDecoration(
                          labelText: "Unit",
                          prefixIcon: const Icon(
                            Icons.scale,
                          ),
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                        items: units.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value == null) {
                            return;
                          }

                          setDialogState(() {
                            selectedUnit = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: "Description",
                          prefixIcon: const Icon(
                            Icons.description,
                          ),
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.green.shade700,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () async {
                    final name =
                    nameController.text.trim();

                    final price = double.tryParse(
                      priceController.text.trim(),
                    );

                    final quantity = double.tryParse(
                      quantityController.text.trim(),
                    );

                    final description =
                    descriptionController.text.trim();

                    if (name.isEmpty ||
                        price == null ||
                        price <= 0 ||
                        quantity == null ||
                        quantity <= 0 ||
                        description.isEmpty) {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please enter valid product details",
                          ),
                        ),
                      );
                      return;
                    }

                    try {
                      await DatabaseHelper.instance
                          .updateProduct(
                        product.id,
                        {
                          'name': name,
                          'category': selectedCategory,
                          'price': price,
                          'quantity': quantity,
                          'unit': selectedUnit,
                          'image': product.image,
                          'description': description,
                          'farmerId': widget.user.id,
                          'farmerName': widget.user.name,
                          'createdAt': product.createdAt
                              .toIso8601String(),
                        },
                      );

                      if (!dialogContext.mounted) {
                        return;
                      }

                      Navigator.pop(dialogContext);

                      await _loadProducts();

                      if (!mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            "$name updated successfully",
                          ),
                          backgroundColor:
                          Colors.green.shade700,
                        ),
                      );
                    } catch (e) {
                      if (!dialogContext.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        SnackBar(
                          content: Text(
                            "Unable to update product: $e",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );

    nameController.dispose();
    priceController.dispose();
    quantityController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Products",
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      drawer: FarmerAppDrawer(
        selectedRoute: "/my-products",
        user: widget.user,
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(),
      )
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              20,
              20,
              20,
              5,
            ),
            child: Row(
              mainAxisAlignment:
              MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: _openAddProduct,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Product"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: products.isEmpty
                ? _buildEmptyProducts()
                : GridView.builder(
              padding:
              const EdgeInsets.all(20),
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 1.15,
              ),
              itemCount: products.length,
              itemBuilder:
                  (context, index) {
                return _buildProductCard(
                  products[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyProducts() {
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 70,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 15),
          const Text(
            "No Products Added",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Start adding your products",
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor:
              Colors.green.shade700,
              foregroundColor: Colors.white,
              padding:
              const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 14,
              ),
              shape: RoundedRectangleBorder(
                borderRadius:
                BorderRadius.circular(10),
              ),
            ),
            onPressed: _openAddProduct,
            icon: const Icon(Icons.add),
            label: const Text("Add Product"),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(15),
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
          Container(
            height: 70,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius:
              BorderRadius.circular(12),
            ),
            child: Center(
              child: Icon(
                _getProductIcon(product.category),
                size: 40,
                color: Colors.green.shade700,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            product.name,
            maxLines: 1,
            overflow:
            TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            "₹${product.price.toStringAsFixed(2)} / ${product.unit}",
            style: TextStyle(
              color: Colors.green.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            "Stock: ${product.quantity} ${product.unit}",
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    _editProduct(product);
                  },
                  icon: const Icon(
                    Icons.edit,
                    size: 16,
                  ),
                  label: const Text("Edit"),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () {
                  _deleteProduct(product);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _getProductIcon(String category) {
    switch (category.toLowerCase()) {
      case "vegetables":
        return Icons.eco;
      case "grains":
        return Icons.grass;
      case "fruits":
        return Icons.apple;
      case "dairy":
        return Icons.local_drink;
      case "spices":
        return Icons.spa;
      default:
        return Icons.agriculture;
    }
  }
}