import 'package:meta/meta.dart';

/// Model data kategori inventaris
@immutable
class Category {
  final String id;
  final String name;
  final String createdAt;

  const Category({
    required this.id,
    required this.name,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'].toString(),
    name: json['name'],
    createdAt: json['createdAt'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt,
  };
}
