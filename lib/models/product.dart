class Product {
  int id;
  String name;
  String category;
  double price;
  double quantity;
  String unit;
  String image;
  String description;
  int farmerId;
  String farmerName;
  DateTime createdAt;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.image,
    required this.description,
    required this.farmerId,
    required this.farmerName,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'quantity': quantity,
      'unit': unit,
      'image': image,
      'description': description,
      'farmerId': farmerId,
      'farmerName': farmerName,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      category: map['category'],
      price: (map['price'] as num).toDouble(),
      quantity: (map['quantity'] as num).toDouble(),
      unit: map['unit'],
      image: map['image'],
      description: map['description'],
      farmerId: map['farmerId'],
      farmerName: map['farmerName'],
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
}