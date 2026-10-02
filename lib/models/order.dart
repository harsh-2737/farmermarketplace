class Order {
  int id;
  int userId;
  double totalAmount;
  String status;
  DateTime orderDate;
  String addressLine;
  String city;
  String state;
  String pincode;
  String paymentMethod;
  String paymentStatus;
  String? paymentId;

  Order({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    required this.addressLine,
    required this.city,
    required this.state,
    required this.pincode,
    required this.paymentMethod,
    required this.paymentStatus,
    this.paymentId,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'pincode': pincode,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'paymentId': paymentId,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      userId: map['userId'],
      totalAmount: (map['totalAmount'] as num).toDouble(),
      status: map['status'],
      orderDate: DateTime.parse(map['orderDate']),
      addressLine: map['addressLine'],
      city: map['city'],
      state: map['state'],
      pincode: map['pincode'],
      paymentMethod: map['paymentMethod'] ?? 'COD',
      paymentStatus: map['paymentStatus'] ?? 'Pending',
      paymentId: map['paymentId'],
    );
  }
}