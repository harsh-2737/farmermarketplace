import 'address.dart';
import 'order_item.dart';

class Order {
  int id;
  int userId;
  List<OrderItem> items;
  Address address;
  double totalAmount;
  String orderDate;
  String status;

  Order({
    required this.id,
    required this.userId,
    required this.items,
    required this.address,
    required this.totalAmount,
    required this.orderDate,
    required this.status,
  });
}