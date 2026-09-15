class OrderItem {
  int id;
  int orderId;
  int productId;
  String productName;
  int quantity;
  double price;
  String unit;
  int farmerId;
  String farmerName;

  OrderItem({
    required this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.unit,
    required this.farmerId,
    required this.farmerName,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
      'unit': unit,
      'farmerId': farmerId,
      'farmerName': farmerName,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      orderId: map['orderId'],
      productId: map['productId'],
      productName: map['productName'],
      quantity: map['quantity'],
      price: (map['price'] as num).toDouble(),
      unit: map['unit'],
      farmerId: map['farmerId'],
      farmerName: map['farmerName'],
    );
  }
}