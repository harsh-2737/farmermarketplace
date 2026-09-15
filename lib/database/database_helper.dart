import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'farmer_marketplace.db');

    return await openDatabase(
      path,
      version: 1,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT UNIQUE NOT NULL,
            phone TEXT NOT NULL,
            password TEXT NOT NULL,
            role TEXT NOT NULL DEFAULT 'Customer',
            addressLine TEXT DEFAULT '',
            city TEXT DEFAULT '',
            state TEXT DEFAULT '',
            pincode TEXT DEFAULT ''
          )
        ''');

        await db.execute('''
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT UNIQUE NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE products (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            price REAL NOT NULL,
            quantity REAL NOT NULL,
            unit TEXT NOT NULL,
            image TEXT NOT NULL,
            description TEXT NOT NULL,
            farmerId INTEGER NOT NULL,
            farmerName TEXT NOT NULL,
            createdAt TEXT NOT NULL,
            FOREIGN KEY (farmerId) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE cart (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            productId INTEGER NOT NULL,
            quantity INTEGER NOT NULL,
            FOREIGN KEY (userId) REFERENCES users(id),
            FOREIGN KEY (productId) REFERENCES products(id),
            UNIQUE(userId, productId)
          )
        ''');

        await db.execute('''
          CREATE TABLE orders (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER NOT NULL,
            totalAmount REAL NOT NULL,
            status TEXT NOT NULL,
            orderDate TEXT NOT NULL,
            addressLine TEXT NOT NULL,
            city TEXT NOT NULL,
            state TEXT NOT NULL,
            pincode TEXT NOT NULL,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE order_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderId INTEGER NOT NULL,
            productId INTEGER NOT NULL,
            productName TEXT NOT NULL,
            quantity INTEGER NOT NULL,
            price REAL NOT NULL,
            unit TEXT NOT NULL,
            farmerId INTEGER NOT NULL,
            farmerName TEXT NOT NULL,
            FOREIGN KEY (orderId) REFERENCES orders(id) ON DELETE CASCADE,
            FOREIGN KEY (productId) REFERENCES products(id),
            FOREIGN KEY (farmerId) REFERENCES users(id)
          )
        ''');

        await db.execute('''
          CREATE TABLE payments (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            orderId INTEGER NOT NULL,
            amount REAL NOT NULL,
            paymentId TEXT,
            status TEXT NOT NULL,
            paymentMethod TEXT NOT NULL,
            paymentDate TEXT NOT NULL,
            FOREIGN KEY (orderId) REFERENCES orders(id)
          )
        ''');

        await db.insert(
          'categories',
          {'name': 'Vegetables'},
        );

        await db.insert(
          'categories',
          {'name': 'Grains'},
        );

        await db.insert(
          'categories',
          {'name': 'Fruits'},
        );

        await db.insert(
          'categories',
          {'name': 'Dairy'},
        );

        await db.insert(
          'categories',
          {'name': 'Spices'},
        );
      },
    );
  }

  Future<int> insertUser(Map<String, dynamic> user) async {
    final db = await database;
    return await db.insert('users', user);
  }

  Future<Map<String, dynamic>?> getUserByEmail(
      String email,
      ) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<Map<String, dynamic>?> loginUser(
      String email,
      String password,
      ) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<Map<String, dynamic>?> getUserById(
      int id,
      ) async {
    final db = await database;

    final result = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query(
      'users',
      orderBy: 'id DESC',
    );
  }

  Future<int> updateUser(
      int id,
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    return await db.update(
      'users',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteUser(int id) async {
    final db = await database;

    return await db.delete(
      'users',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertCategory(
      Map<String, dynamic> category,
      ) async {
    final db = await database;
    return await db.insert('categories', category);
  }

  Future<List<Map<String, dynamic>>> getAllCategories() async {
    final db = await database;
    return await db.query(
      'categories',
      orderBy: 'name ASC',
    );
  }

  Future<int> updateCategory(
      int id,
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    return await db.update(
      'categories',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;

    return await db.delete(
      'categories',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertProduct(
      Map<String, dynamic> product,
      ) async {
    final db = await database;

    return await db.insert(
      'products',
      product,
    );
  }

  Future<List<Map<String, dynamic>>> getAllProducts() async {
    final db = await database;

    return await db.query(
      'products',
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getProductsByCategory(
      String category,
      ) async {
    final db = await database;

    return await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'createdAt DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getProductsByFarmer(
      int farmerId,
      ) async {
    final db = await database;

    return await db.query(
      'products',
      where: 'farmerId = ?',
      whereArgs: [farmerId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<Map<String, dynamic>?> getProductById(
      int id,
      ) async {
    final db = await database;

    final result = await db.query(
      'products',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<int> updateProduct(
      int id,
      Map<String, dynamic> data,
      ) async {
    final db = await database;

    return await db.update(
      'products',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;

    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> addToCart(
      Map<String, dynamic> cartItem,
      ) async {
    final db = await database;

    final existing = await db.query(
      'cart',
      where: 'userId = ? AND productId = ?',
      whereArgs: [
        cartItem['userId'],
        cartItem['productId'],
      ],
      limit: 1,
    );

    if (existing.isNotEmpty) {
      final currentQuantity =
      existing.first['quantity'] as int;

      final newQuantity =
          currentQuantity + (cartItem['quantity'] as int);

      return await db.update(
        'cart',
        {
          'quantity': newQuantity,
        },
        where: 'userId = ? AND productId = ?',
        whereArgs: [
          cartItem['userId'],
          cartItem['productId'],
        ],
      );
    }

    return await db.insert(
      'cart',
      cartItem,
    );
  }

  Future<List<Map<String, dynamic>>> getCartItems(
      int userId,
      ) async {
    final db = await database;

    return await db.query(
      'cart',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }

  Future<int> updateCartQuantity(
      int userId,
      int productId,
      int quantity,
      ) async {
    final db = await database;

    return await db.update(
      'cart',
      {
        'quantity': quantity,
      },
      where: 'userId = ? AND productId = ?',
      whereArgs: [
        userId,
        productId,
      ],
    );
  }

  Future<int> removeFromCart(
      int userId,
      int productId,
      ) async {
    final db = await database;

    return await db.delete(
      'cart',
      where: 'userId = ? AND productId = ?',
      whereArgs: [
        userId,
        productId,
      ],
    );
  }

  Future<int> clearCart(int userId) async {
    final db = await database;

    return await db.delete(
      'cart',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  Future<int> insertOrder(
      Map<String, dynamic> order,
      ) async {
    final db = await database;
    return await db.insert(
      'orders',
      order,
    );
  }

  Future<List<Map<String, dynamic>>> getAllOrders() async {
    final db = await database;

    return await db.query(
      'orders',
      orderBy: 'orderDate DESC',
    );
  }

  Future<List<Map<String, dynamic>>> getUserOrders(
      int userId,
      ) async {
    final db = await database;

    return await db.query(
      'orders',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'orderDate DESC',
    );
  }

  Future<Map<String, dynamic>?> getOrderById(
      int id,
      ) async {
    final db = await database;

    final result = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<int> updateOrderStatus(
      int id,
      String status,
      ) async {
    final db = await database;

    return await db.update(
      'orders',
      {
        'status': status,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> insertOrderItem(
      Map<String, dynamic> item,
      ) async {
    final db = await database;

    return await db.insert(
      'order_items',
      item,
    );
  }

  Future<List<Map<String, dynamic>>> getOrderItems(
      int orderId,
      ) async {
    final db = await database;

    return await db.query(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
  }

  Future<int> deleteOrderItems(
      int orderId,
      ) async {
    final db = await database;

    return await db.delete(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [orderId],
    );
  }

  Future<List<Map<String, dynamic>>> getFarmerOrders(
      int farmerId,
      ) async {
    final db = await database;

    return await db.rawQuery(
      '''
      SELECT
        oi.id AS orderItemId,
        oi.orderId,
        oi.productId,
        oi.productName,
        oi.quantity,
        oi.price,
        oi.unit,
        oi.farmerId,
        oi.farmerName,
        o.userId,
        o.totalAmount,
        o.status,
        o.orderDate,
        o.addressLine,
        o.city,
        o.state,
        o.pincode
      FROM order_items oi
      INNER JOIN orders o
        ON oi.orderId = o.id
      WHERE oi.farmerId = ?
      ORDER BY o.orderDate DESC
      ''',
      [farmerId],
    );
  }

  Future<int> insertPayment(
      Map<String, dynamic> payment,
      ) async {
    final db = await database;

    return await db.insert(
      'payments',
      payment,
    );
  }

  Future<Map<String, dynamic>?> getPaymentByOrderId(
      int orderId,
      ) async {
    final db = await database;

    final result = await db.query(
      'payments',
      where: 'orderId = ?',
      whereArgs: [orderId],
      limit: 1,
    );

    if (result.isEmpty) {
      return null;
    }

    return result.first;
  }

  Future<int> updatePaymentStatus(
      int id,
      String status,
      ) async {
    final db = await database;

    return await db.update(
      'payments',
      {
        'status': status,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getAllPayments() async {
    final db = await database;

    return await db.query(
      'payments',
      orderBy: 'paymentDate DESC',
    );
  }

  Future<Map<String, dynamic>> getFarmerStatistics(
      int farmerId,
      ) async {
    final db = await database;

    final productResult = await db.rawQuery(
      '''
      SELECT COUNT(*) AS count
      FROM products
      WHERE farmerId = ?
      ''',
      [farmerId],
    );

    final orderResult = await db.rawQuery(
      '''
      SELECT COUNT(DISTINCT oi.orderId) AS count
      FROM order_items oi
      INNER JOIN orders o
        ON oi.orderId = o.id
      WHERE oi.farmerId = ?
      ''',
      [farmerId],
    );

    final salesResult = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(oi.price * oi.quantity), 0) AS total
      FROM order_items oi
      INNER JOIN orders o
        ON oi.orderId = o.id
      WHERE oi.farmerId = ?
      AND o.status != 'Cancelled'
      ''',
      [farmerId],
    );

    return {
      'productCount': productResult.first['count'] ?? 0,
      'orderCount': orderResult.first['count'] ?? 0,
      'sales': salesResult.first['total'] ?? 0,
    };
  }

  Future<void> createDefaultFarmer() async {
    final db = await database;

    final existingRishi = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['rishi@gmail.com'],
    );

    if (existingRishi.isEmpty) {
      await db.insert(
        'users',
        {
          'name': 'Rishi Patel',
          'email': 'rishi@gmail.com',
          'phone': '9876543210',
          'password': 'rishi',
          'role': 'Farmer',
          'addressLine': 'Farmer Road',
          'city': 'Vadodara',
          'state': 'Gujarat',
          'pincode': '390001',
        },
      );
    }

    final existingShiv = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: ['shiv@gmail.com'],
    );

    if (existingShiv.isEmpty) {
      await db.insert(
        'users',
        {
          'name': 'Shiv Patel',
          'email': 'shiv@gmail.com',
          'phone': '9876543211',
          'password': 'shiv',
          'role': 'Farmer',
          'addressLine': 'Farmer Road',
          'city': 'Vadodara',
          'state': 'Gujarat',
          'pincode': '390001',
        },
      );
    }
  }

  Future<void> closeDatabase() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}