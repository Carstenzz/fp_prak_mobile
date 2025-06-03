import 'package:meta/meta.dart';

/// Model data item inventaris
@immutable
class Item {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final int quantity;
  final String categoryId;
  final String createdBy;
  final String createdAt;

  const Item({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.quantity,
    required this.categoryId,
    required this.createdBy,
    required this.createdAt,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'].toString(),
    name: json['name'],
    description: json['description'],
    imageUrl: json['image_url'],
    quantity: json['quantity'],
    categoryId: json['category_id'].toString(),
    createdBy: json['created_by'].toString(),
    createdAt: json['createdAt'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'image_url': imageUrl,
    'quantity': quantity,
    'category_id': categoryId,
    'created_by': createdBy,
    'createdAt': createdAt,
  };
}
