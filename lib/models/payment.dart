class Payment {
  int id;
  int orderId;
  double amount;
  String paymentId;
  String paymentMethod;
  String status;
  String paymentDate;

  Payment({
    required this.id,
    required this.orderId,
    required this.amount,
    required this.paymentId,
    required this.paymentMethod,
    required this.status,
    required this.paymentDate,
  });
}