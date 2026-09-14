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
  });
}