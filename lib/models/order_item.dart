class OrderItem {
  int productId;
  String productName;
  double price;
  int quantity;
  String unit;
  String image;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.unit,
    required this.image,
  });
}