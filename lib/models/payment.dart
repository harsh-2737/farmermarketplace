class Payment {
  int id;
  int orderId;
  double amount;
  String? paymentId;
  String status;
  String paymentMethod;
  DateTime paymentDate;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    this.paymentId,
    required this.status,
    required this.paymentMethod,
    required this.paymentDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'amount': amount,
      'paymentId': paymentId,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate.toIso8601String(),
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'],
      orderId: map['orderId'],
      amount: (map['amount'] as num).toDouble(),
      paymentId: map['paymentId'],
      status: map['status'],
      paymentMethod: map['paymentMethod'],
      paymentDate: DateTime.parse(map['paymentDate']),
    );
  }
}