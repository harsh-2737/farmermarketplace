class User {
  int id;
  String name;
  String email;
  String phone;
  String role;
  String addressLine;
  String city;
  String state;
  String pincode;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.addressLine = "",
    this.city = "",
    this.state = "",
    this.pincode = "",
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'addressLine': addressLine,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phone: map['phone'],
      role: map['role'],
      addressLine: map['addressLine'] ?? "",
      city: map['city'] ?? "",
      state: map['state'] ?? "",
      pincode: map['pincode'] ?? "",
    );
  }
}