import 'product.dart';

class CartItem {
  Product product;
  int quantity;

  CartItem({
    required this.product,
    required this.quantity,
  });
}

class CartManager {
  static final List<CartItem> items = [];

  static void addToCart(Product product, int quantity) {
    int index = items.indexWhere(
          (item) => item.product.id == product.id,
    );

    if (index != -1) {
      items[index].quantity += quantity;
    } else {
      items.add(
        CartItem(
          product: product,
          quantity: quantity,
        ),
      );
    }
  }

  static void increaseQuantity(int index) {
    if (items[index].quantity < items[index].product.quantity) {
      items[index].quantity++;
    }
  }

  static void decreaseQuantity(int index) {
    if (items[index].quantity > 1) {
      items[index].quantity--;
    }
  }

  static void removeItem(int index) {
    items.removeAt(index);
  }

  static void clearCart() {
    items.clear();
  }

  static double get subtotal {
    double total = 0;

    for (CartItem item in items) {
      total += item.product.price * item.quantity;
    }

    return total;
  }

  static double get deliveryCharge {
    return items.isEmpty ? 0 : 40;
  }

  static double get total {
    return subtotal + deliveryCharge;
  }
}