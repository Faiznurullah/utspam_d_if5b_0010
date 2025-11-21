import 'dart:convert';

class User {
  final int? id;
  final String fullname;
  final String username;
  final String email;
  final String password;
  final String phone;
  final String? address;

  User({
    this.id,
    required this.fullname,
    required this.username,
    required this.email,
    required this.password,
    required this.phone,
    this.address,
  });

  // Factory constructor untuk membuat instance dari Map (database)
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      fullname: map['fullname'] ?? '',
      username: map['username'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'],
    );
  }

  // Convert instance ke Map untuk database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullname': fullname,
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
    };
  }

  // Convert ke Map tanpa field yang auto-generated untuk insert
  Map<String, dynamic> toMapForInsert() {
    final map = toMap();
    map.remove('id');
    return map;
  }

  // Factory constructor dari JSON
  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  // Convert ke JSON
  String toJson() => json.encode(toMap());

  // Copy with method untuk membuat instance baru dengan perubahan
  User copyWith({
    int? id,
    String? fullname,
    String? username,
    String? email,
    String? password,
    String? phone,
    String? address,
  }) {
    return User(
      id: id ?? this.id,
      fullname: fullname ?? this.fullname,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      address: address ?? this.address,
    );
  }

  @override
  String toString() {
    return 'User(id: $id, fullname: $fullname, username: $username, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is User && other.username == username;
  }

  @override
  int get hashCode => username.hashCode;
}