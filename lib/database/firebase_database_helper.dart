import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class FirebaseDatabaseHelper {
  static final FirebaseDatabaseHelper instance =
  FirebaseDatabaseHelper._internal();

  FirebaseDatabaseHelper._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  CollectionReference<Map<String, dynamic>> get _categories =>
      _firestore.collection('categories');

  CollectionReference<Map<String, dynamic>> get _products =>
      _firestore.collection('products');

  CollectionReference<Map<String, dynamic>> get _cart =>
      _firestore.collection('cart');

  CollectionReference<Map<String, dynamic>> get _orders =>
      _firestore.collection('orders');

  CollectionReference<Map<String, dynamic>> get _orderItems =>
      _firestore.collection('order_items');

  CollectionReference<Map<String, dynamic>> get _payments =>
      _firestore.collection('payments');

  Future<int> _getNextId(String collection) async {
    final counterRef = _firestore.collection('_counters').doc(collection);

    return await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(counterRef);

      int currentId = 0;

      if (snapshot.exists) {
        final data = snapshot.data();
        final value = data?['value'];

        if (value is num) {
          currentId = value.toInt();
        }
      }

      final nextId = currentId + 1;

      transaction.set(
        counterRef,
        {
          'value': nextId,
        },
        SetOptions(merge: true),
      );

      return nextId;
    });
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final id = await _getNextId('users');

    user['id'] = id;

    await _users.doc(id.toString()).set(user);

    return id;
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final snapshot = await _users
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.data();
  }

  Future<Map<String, dynamic>?> loginUser(
      String email,
      String password,
      ) async {
    final snapshot = await _users
        .where('email', isEqualTo: email)
        .where('password', isEqualTo: password)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.data();
  }

  Future<Map<String, dynamic>?> getUserById(int id) async {
    final snapshot = await _users.doc(id.toString()).get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final snapshot = await _users.get();

    final users = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    users.sort((a, b) {
      final idA = (a['id'] as num?)?.toInt() ?? 0;
      final idB = (b['id'] as num?)?.toInt() ?? 0;
      return idB.compareTo(idA);
    });

    return users;
  }

  Future<int> updateUser(
      int id,
      Map<String, dynamic> data,
      ) async {
    final reference = _users.doc(id.toString());
    final snapshot = await reference.get();

    if (!snapshot.exists) {
      return 0;
    }

    await reference.update(data);

    return 1;
  }

  Future<int> deleteUser(int id) async {
    final reference = _users.doc(id.toString());
    final snapshot = await reference.get();

    if (!snapshot.exists) {
      return 0;
    }

    await reference.delete();

    return 1;
  }

  Future<int> insertCategory(
      Map<String, dynamic> category,
      ) async {
    final id = await _getNextId('categories');

    category['id'] = id;

    await _categories.doc(id.toString()).set(category);

    return id;
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final snapshot = await _categories.get();

    final categories = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    categories.sort((a, b) {
      final nameA = (a['name'] ?? '').toString().toLowerCase();
      final nameB = (b['name'] ?? '').toString().toLowerCase();
      return nameA.compareTo(nameB);
    });

    return categories;
  }

  Future<int> updateCategory(
      int id,
      Map<String, dynamic> data,
      ) async {
    final reference = _categories.doc(id.toString());
    final snapshot = await reference.get();

    if (!snapshot.exists) {
      return 0;
    }

    await reference.update(data);

    return 1;
  }

  Future<int> deleteCategory(int id) async {
    final reference = _categories.doc(id.toString());
    final snapshot = await reference.get();

    if (!snapshot.exists) {
      return 0;
    }

    await reference.delete();

    return 1;
  }

  Future<int> insertProduct(
      Map<String, dynamic> product,
      ) async {
    final id = await _getNextId('products');

    product['id'] = id;

    await _products.doc(id.toString()).set(product);

    return id;
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final snapshot = await _products.get();

    final products = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    products.sort((a, b) {
      final dateA = (a['createdAt'] ?? '').toString();
      final dateB = (b['createdAt'] ?? '').toString();
      return dateB.compareTo(dateA);
    });

    return products;
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(
      String category,
      ) async {
    final snapshot = await _products
        .where('category', isEqualTo: category)
        .get();

    final products = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    products.sort((a, b) {
      final dateA = (a['createdAt'] ?? '').toString();
      final dateB = (b['createdAt'] ?? '').toString();
      return dateB.compareTo(dateA);
    });

    return products;
  }

  Future<List<Map<String, dynamic>>> getProductsByFarmer(
      int farmerId,
      ) async {
    final snapshot = await _products
        .where('farmerId', isEqualTo: farmerId)
        .get();

    final products = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    products.sort((a, b) {
      final dateA = (a['createdAt'] ?? '').toString();
      final dateB = (b['createdAt'] ?? '').toString();
      return dateB.compareTo(dateA);
    });

    return products;
  }

  Future<Map<String, dynamic>?> getProductById(int id) async {
    final snapshot = await _products.doc(id.toString()).get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }

  Future<int> updateProduct(
      int id,
      Map<String, dynamic> data,
      ) async {
    final reference = _products.doc(id.toString());
    final snapshot = await reference.get();

    if (!snapshot.exists) {
      return 0;
    }

    await reference.update(data);

    return 1;
  }

  Future<int> updateProductByFields({
    required int id,
    required String name,
    required String category,
    required double price,
    required double quantity,
    required String unit,
    required String image,
    required String description,
  }) async {
    final reference = _products.doc(id.toString());
    final snapshot = await reference.get();

    if (!snapshot.exists) {
      return 0;
    }

    await reference.update({
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'image': image,
      'description': description,
    });

    return 1;
  }

  Future<int> deleteProduct(int id) async {
    final reference = _products.doc(id.toString());
    final snapshot = await reference.get();

    if (!snapshot.exists) {
      return 0;
    }

    await reference.delete();

    return 1;
  }

  Future<String> uploadProductImage(
      File imageFile,
      ) async {
    const cloudName = 'l46anuzk';
    const uploadPreset = 'farmer_marketplace';

    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest(
      'POST',
      url,
    );

    request.fields['upload_preset'] = uploadPreset;

    request.files.add(
      await http.MultipartFile.fromPath(
        'file',
        imageFile.path,
      ),
    );

    final streamedResponse = await request.send();

    final response = await http.Response.fromStream(
      streamedResponse,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Cloudinary upload failed: ${response.body}',
      );
    }

    final data = jsonDecode(response.body);

    final secureUrl = data['secure_url'];

    if (secureUrl == null || secureUrl.toString().isEmpty) {
      throw Exception(
        'Cloudinary did not return image URL',
      );
    }

    return secureUrl.toString();
  }

  Future<int> addToCart(
      Map<String, dynamic> cartItem,
      ) async {
    final userId = cartItem['userId'];
    final productId = cartItem['productId'];

    final existingSnapshot = await _cart
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    if (existingSnapshot.docs.isNotEmpty) {
      final existingDocument = existingSnapshot.docs.first;
      final existingData = existingDocument.data();

      final currentQuantity =
          (existingData['quantity'] as num?)?.toInt() ?? 0;

      final addedQuantity =
          (cartItem['quantity'] as num?)?.toInt() ?? 0;

      final newQuantity =
          currentQuantity + addedQuantity;

      await existingDocument.reference.update({
        'quantity': newQuantity,
      });

      return (existingData['id'] as num?)?.toInt() ?? 0;
    }

    final id = await _getNextId('cart');

    cartItem['id'] = id;

    await _cart.doc(id.toString()).set(cartItem);

    return id;
  }

  Future<List<Map<String, dynamic>>> getCartItems(
      int userId,
      ) async {
    final snapshot = await _cart
        .where('userId', isEqualTo: userId)
        .get();

    final cartItems = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    cartItems.sort((a, b) {
      final idA = (a['id'] as num?)?.toInt() ?? 0;
      final idB = (b['id'] as num?)?.toInt() ?? 0;
      return idB.compareTo(idA);
    });

    return cartItems;
  }

  Future<int> updateCartQuantity(
      int userId,
      int productId,
      int quantity,
      ) async {
    final snapshot = await _cart
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return 0;
    }

    await snapshot.docs.first.reference.update({
      'quantity': quantity,
    });

    return 1;
  }

  Future<int> removeFromCart(
      int userId,
      int productId,
      ) async {
    final snapshot = await _cart
        .where('userId', isEqualTo: userId)
        .where('productId', isEqualTo: productId)
        .get();

    if (snapshot.docs.isEmpty) {
      return 0;
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    return snapshot.docs.length;
  }

  Future<int> clearCart(int userId) async {
    final snapshot = await _cart
        .where('userId', isEqualTo: userId)
        .get();

    if (snapshot.docs.isEmpty) {
      return 0;
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    return snapshot.docs.length;
  }

  Future<int> insertOrder(
      Map<String, dynamic> order,
      ) async {
    final id = await _getNextId('orders');

    order['id'] = id;

    await _orders.doc(id.toString()).set(order);

    return id;
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final snapshot = await _orders.get();

    final orders = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    orders.sort((a, b) {
      final dateA = (a['orderDate'] ?? '').toString();
      final dateB = (b['orderDate'] ?? '').toString();
      return dateB.compareTo(dateA);
    });

    return orders;
  }

  Future<List<Map<String, dynamic>>> getUserOrders(
      int userId,
      ) async {
    final snapshot = await _orders
        .where('userId', isEqualTo: userId)
        .get();

    final orders = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    orders.sort((a, b) {
      final dateA = (a['orderDate'] ?? '').toString();
      final dateB = (b['orderDate'] ?? '').toString();
      return dateB.compareTo(dateA);
    });

    return orders;
  }

  Future<Map<String, dynamic>?> getOrderById(int id) async {
    final snapshot = await _orders.doc(id.toString()).get();

    if (!snapshot.exists) {
      return null;
    }

    return snapshot.data();
  }

  Future<int> updateOrderStatus(
      int id,
      String status,
      ) async {
    final reference = _orders.doc(id.toString());
    final snapshot = await reference.get();

    if (!snapshot.exists) {
      return 0;
    }

    await reference.update({
      'status': status,
    });

    return 1;
  }
  Future<int> confirmOrderAndReduceStock(
    int orderId, {
    int? farmerId,
    int? orderItemId,
  }) async {
    final orderReference = _orders.doc(orderId.toString());
    final orderSnapshot = await orderReference.get();

    if (!orderSnapshot.exists) {
      return 0; // Order not found
    }

    final order = orderSnapshot.data();

    if (order?['status'] == 'Cancelled') {
      return 3; // Order is cancelled
    }

    final itemSnapshot = await _orderItems
        .where('orderId', isEqualTo: orderId)
        .get();

    if (itemSnapshot.docs.isEmpty) {
      return 4; // No products found
    }

    // Identify target item documents to confirm
    final List<QueryDocumentSnapshot<Map<String, dynamic>>> targetItemDocs;
    if (orderItemId != null) {
      targetItemDocs = itemSnapshot.docs.where((d) {
        final id = (d.data()['id'] as num?)?.toInt();
        return id == orderItemId;
      }).toList();
    } else if (farmerId != null) {
      targetItemDocs = itemSnapshot.docs.where((d) {
        final fId = (d.data()['farmerId'] as num?)?.toInt();
        return fId == farmerId;
      }).toList();
    } else {
      targetItemDocs = itemSnapshot.docs;
    }

    if (targetItemDocs.isEmpty) {
      return 4; // No items found for this farmer in this order
    }

    // Filter target items that are not yet confirmed
    final pendingTargetDocs = targetItemDocs.where((d) {
      final s = d.data()['status']?.toString();
      return s != 'Confirmed';
    }).toList();

    if (pendingTargetDocs.isEmpty) {
      return 2; // Target items are already confirmed
    }

    return await _firestore.runTransaction((transaction) async {
      final productUpdates = <DocumentReference<Map<String, dynamic>>, double>{};

      for (final itemDoc in pendingTargetDocs) {
        final item = itemDoc.data();

        final productId = (item['productId'] as num?)?.toInt();
        final orderedQuantity =
            (item['quantity'] as num?)?.toDouble() ?? 0;

        if (productId == null || orderedQuantity <= 0) {
          continue;
        }

        final productReference = _products.doc(productId.toString());
        final productSnapshot = await transaction.get(productReference);

        if (!productSnapshot.exists) {
          throw Exception('Product not found (ID: $productId)');
        }

        final product = productSnapshot.data()!;
        final currentQuantity =
            (product['quantity'] as num?)?.toDouble() ?? 0;

        if (currentQuantity < orderedQuantity) {
          throw Exception(
            'Not enough stock for ${product['name'] ?? 'product'}. Available: $currentQuantity, requested: $orderedQuantity',
          );
        }

        productUpdates[productReference] =
            currentQuantity - orderedQuantity;
      }

      if (productUpdates.isEmpty) {
        throw Exception('No valid products found to deduct stock');
      }

      // Deduct inventory stock for the confirming farmer's products only
      for (final entry in productUpdates.entries) {
        transaction.update(entry.key, {
          'quantity': entry.value,
        });
      }

      // Mark the confirming farmer's order items as Confirmed
      final nowIso = DateTime.now().toIso8601String();
      for (final itemDoc in pendingTargetDocs) {
        transaction.update(itemDoc.reference, {
          'status': 'Confirmed',
          'confirmedAt': nowIso,
        });
      }

      // Determine parent order status across all order items in this order
      final pendingTargetIds = pendingTargetDocs.map((d) => d.id).toSet();
      bool allItemsConfirmed = true;
      bool anyItemConfirmed = false;

      for (final doc in itemSnapshot.docs) {
        final isConfirmed = pendingTargetIds.contains(doc.id) ||
            doc.data()['status'] == 'Confirmed';
        if (isConfirmed) {
          anyItemConfirmed = true;
        } else {
          allItemsConfirmed = false;
        }
      }

      final String newOrderStatus;
      if (allItemsConfirmed) {
        newOrderStatus = 'Confirmed';
      } else if (anyItemConfirmed) {
        newOrderStatus = 'Partially Confirmed';
      } else {
        newOrderStatus = 'Pending';
      }

      transaction.update(orderReference, {
        'status': newOrderStatus,
      });

      return 1;
    });
  }
  Future<int> insertOrderItem(
      Map<String, dynamic> item,
      ) async {
    final id = await _getNextId('order_items');

    item['id'] = id;

    await _orderItems.doc(id.toString()).set(item);

    return id;
  }

  Future<List<Map<String, dynamic>>> getOrderItems(
      int orderId,
      ) async {
    final snapshot = await _orderItems
        .where('orderId', isEqualTo: orderId)
        .get();

    final items = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    items.sort((a, b) {
      final idA = (a['id'] as num?)?.toInt() ?? 0;
      final idB = (b['id'] as num?)?.toInt() ?? 0;
      return idA.compareTo(idB);
    });

    return items;
  }

  Future<int> deleteOrderItems(
      int orderId,
      ) async {
    final snapshot = await _orderItems
        .where('orderId', isEqualTo: orderId)
        .get();

    if (snapshot.docs.isEmpty) {
      return 0;
    }

    final batch = _firestore.batch();

    for (final doc in snapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();

    return snapshot.docs.length;
  }

  Future<int> createCompleteOrder({
    required Map<String, dynamic> order,
    required List<Map<String, dynamic>> orderItems,
    required Map<String, dynamic> payment,
    required int userId,
  }) async {
    final orderId = await insertOrder(order);

    try {
      for (final item in orderItems) {
        item['orderId'] = orderId;
        item['status'] = item['status'] ?? 'Pending';
        await insertOrderItem(item);
      }

      payment['orderId'] = orderId;

      await insertPayment(payment);

      await clearCart(userId);

      return orderId;
    } catch (e) {
      await deleteOrderItems(orderId);

      final orderReference = _orders.doc(
        orderId.toString(),
      );

      final orderSnapshot = await orderReference.get();

      if (orderSnapshot.exists) {
        await orderReference.delete();
      }

      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getFarmerOrders(
      int farmerId,
      ) async {
    final snapshot = await _orderItems
        .where('farmerId', isEqualTo: farmerId)
        .get();

    final results = <Map<String, dynamic>>[];

    for (final itemDoc in snapshot.docs) {
      final item = itemDoc.data();

      final orderId =
      (item['orderId'] as num?)?.toInt();

      if (orderId == null) {
        continue;
      }

      final order = await getOrderById(orderId);

      if (order == null) {
        continue;
      }

      final itemStatus = item['status']?.toString();
      final orderStatus = order['status']?.toString() ?? 'Pending';
      final effectiveStatus = itemStatus != null && itemStatus.isNotEmpty
          ? itemStatus
          : (orderStatus == 'Confirmed' ? 'Confirmed' : 'Pending');

      results.add({
        'orderItemId': item['id'],
        'orderId': item['orderId'],
        'productId': item['productId'],
        'productName': item['productName'],
        'quantity': item['quantity'],
        'price': item['price'],
        'unit': item['unit'],
        'farmerId': item['farmerId'],
        'farmerName': item['farmerName'],
        'userId': order['userId'],
        'customerName': order['customerName'],
        'phone': order['phone'],
        'totalAmount': order['totalAmount'],
        'status': effectiveStatus,
        'orderStatus': orderStatus,
        'paymentMethod': order['paymentMethod'],
        'paymentStatus': order['paymentStatus'],
        'paymentId': order['paymentId'],
        'orderDate': order['orderDate'],
        'addressLine': order['addressLine'],
        'city': order['city'],
        'state': order['state'],
        'pincode': order['pincode'],
      });
    }

    results.sort((a, b) {
      final dateA = (a['orderDate'] ?? '').toString();
      final dateB = (b['orderDate'] ?? '').toString();
      return dateB.compareTo(dateA);
    });

    return results;
  }

  Future<int> insertPayment(
      Map<String, dynamic> payment,
      ) async {
    final id = await _getNextId('payments');

    payment['id'] = id;

    await _payments.doc(id.toString()).set(payment);

    return id;
  }

  Future<Map<String, dynamic>?> getPaymentByOrderId(
      int orderId,
      ) async {
    final snapshot = await _payments
        .where('orderId', isEqualTo: orderId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      return null;
    }

    return snapshot.docs.first.data();
  }

  Future<int> updatePaymentStatus(
      int id,
      String status,
      ) async {
    final reference = _payments.doc(id.toString());
    final snapshot = await reference.get();

    if (!snapshot.exists) {
      return 0;
    }

    await reference.update({
      'status': status,
    });

    return 1;
  }

  Future<List<Map<String, dynamic>>> getAllPayments() async {
    final snapshot = await _payments.get();

    final payments = snapshot.docs.map((doc) {
      return doc.data();
    }).toList();

    payments.sort((a, b) {
      final dateA = (a['paymentDate'] ?? '').toString();
      final dateB = (b['paymentDate'] ?? '').toString();
      return dateB.compareTo(dateA);
    });

    return payments;
  }

  Future<Map<String, dynamic>> getFarmerStatistics(
      int farmerId,
      ) async {
    final productSnapshot = await _products
        .where('farmerId', isEqualTo: farmerId)
        .get();

    final orderItemSnapshot = await _orderItems
        .where('farmerId', isEqualTo: farmerId)
        .get();

    final Set<int> orderIds = {};
    double sales = 0;

    for (final itemDoc in orderItemSnapshot.docs) {
      final item = itemDoc.data();

      final orderId =
      (item['orderId'] as num?)?.toInt();

      if (orderId == null) {
        continue;
      }

      final order = await getOrderById(orderId);

      if (order == null) {
        continue;
      }

      if (order['status'] == 'Cancelled') {
        continue;
      }

      orderIds.add(orderId);

      final price =
          (item['price'] as num?)?.toDouble() ?? 0;

      final quantity =
          (item['quantity'] as num?)?.toDouble() ?? 0;

      sales += price * quantity;
    }

    return {
      'productCount': productSnapshot.docs.length,
      'orderCount': orderIds.length,
      'sales': sales,
    };
  }

  Future<void> createDefaultCategories() async {
    final categories = [
      'Vegetables',
      'Grains',
      'Fruits',
      'Dairy',
      'Spices',
    ];

    final existingCategories = await getAllCategories();

    final existingNames = existingCategories
        .map((category) => category['name'].toString())
        .toSet();

    for (final category in categories) {
      if (!existingNames.contains(category)) {
        await insertCategory({
          'name': category,
        });
      }
    }
  }

  Future<void> createDefaultFarmer() async {
    final existingRishi =
    await getUserByEmail('rishi@gmail.com');

    if (existingRishi == null) {
      await insertUser({
        'name': 'Rishi Patel',
        'email': 'rishi@gmail.com',
        'phone': '9876543210',
        'password': 'rishi',
        'role': 'Farmer',
        'addressLine': 'Farmer Road',
        'city': 'Vadodara',
        'state': 'Gujarat',
        'pincode': '390001',
      });
    }

    final existingShiv =
    await getUserByEmail('shiv@gmail.com');

    if (existingShiv == null) {
      await insertUser({
        'name': 'Shiv Patel',
        'email': 'shiv@gmail.com',
        'phone': '9876543211',
        'password': 'shiv',
        'role': 'Farmer',
        'addressLine': 'Farmer Road',
        'city': 'Vadodara',
        'state': 'Gujarat',
        'pincode': '390001',
      });
    }
  }
}