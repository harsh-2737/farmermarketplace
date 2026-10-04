import 'product.dart';

class CartItem {
  int userId;
  int productId;
  int quantity;
  Product? product;

  CartItem({
    required this.userId,
    required this.productId,
    required this.quantity,
    this.product,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'productId': productId,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, {Product? product}) {
    return CartItem(
      userId: (map['userId'] as num?)?.toInt() ?? 0,
      productId: (map['productId'] as num?)?.toInt() ?? 0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      product: product,
    );
  }

  CartItem copyWith({
    int? userId,
    int? productId,
    int? quantity,
    Product? product,
  }) {
    return CartItem(
      userId: userId ?? this.userId,
      productId: productId ?? this.productId,
      quantity: quantity ?? this.quantity,
      product: product ?? this.product,
    );
  }
}