import 'package:meta/meta.dart';

/// Model data user aplikasi
@immutable
class User {
  final String id;
  final String name;
  final String email;
  final String password;
  final String createdAt;

  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'].toString(),
    name: json['name'],
    email: json['email'],
    password: json['password'],
    createdAt: json['createdAt'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'createdAt': createdAt,
  };
}
