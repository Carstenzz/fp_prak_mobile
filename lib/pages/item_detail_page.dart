import 'package:flutter/material.dart';
import '../services/user_service.dart';
import '../services/item_service.dart';
import '../services/category_service.dart';
import '../models/category.dart';
import '../api_endpoints.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class ItemDetailPage extends StatefulWidget {
  final String itemId;
  const ItemDetailPage({super.key, required this.itemId});

  @override
  State<ItemDetailPage> createState() => _ItemDetailPageState();
}

class _ItemDetailPageState extends State<ItemDetailPage> {
  Future<Map<String, dynamic>?> _fetchItemDetail() async {
    final token = await UserService.getToken();
    if (token == null) return null;
    final response = await ItemService().getItemById(widget.itemId, token);
    if (response == null) return null;
    final itemMap = response.toJson();

    // Fetch category if not present
    if (itemMap['category'] == null && itemMap['category_id'] != null) {
      try {
        final categories = await CategoryService().getCategories(token);
        final cat = categories.firstWhere(
          (c) => int.tryParse(c.id) == itemMap['category_id'],
          orElse: () => Category(id: '', name: '-', createdAt: ''),
        );
        itemMap['category'] = {'name': cat.name};
      } catch (_) {
        itemMap['category'] = {'name': '-'};
      }
    }
    // Fetch creator if not present
    if (itemMap['creator'] == null && itemMap['created_by'] != null) {
      try {
        final userResp = await http.get(
          Uri.parse('${ApiEndpoints.baseUrl}/user/${itemMap['created_by']}'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );
        if (userResp.statusCode == 200) {
          final userJson = jsonDecode(userResp.body);
          itemMap['creator'] = {
            'name': userJson['name'],
            'email': userJson['email'],
          };
        } else {
          itemMap['creator'] = {'name': '-', 'email': '-'};
        }
      } catch (_) {
        itemMap['creator'] = {'name': '-', 'email': '-'};
      }
    }
    // updatedAt fallback
    if (!itemMap.containsKey('updatedAt')) {
      itemMap['updatedAt'] = '-';
    }
    return itemMap;
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null || isoDate == '-') return '-';
    try {
      final dt = DateTime.parse(isoDate);
      return DateFormat('dd MMM yyyy, HH:mm').format(dt);
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Detail Item'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _fetchItemDetail(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Gagal memuat detail item.'));
          }
          final item = snapshot.data!;
          return Center(
            child: Card(
              elevation: 8,
              margin: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    if ((item['image_url'] ?? '').isNotEmpty)
                      Center(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item['image_url'] ?? '',
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => const Icon(
                                  Icons.broken_image,
                                  color: Colors.red,
                                  size: 100,
                                ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Text(
                      'Nama: ${item['name']}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Jumlah: ${item['quantity']}'),
                    const SizedBox(height: 8),
                    Text('Deskripsi: ${item['description'] ?? '-'}'),
                    const SizedBox(height: 8),
                    Text(
                      'Kategori: ${item['category'] != null ? item['category']['name'] : '-'}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Dibuat oleh: ${item['creator'] != null && item['creator']['name'] != null ? item['creator']['name'] : '-'}',
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Email pembuat: ${item['creator'] != null && item['creator']['email'] != null ? item['creator']['email'] : '-'}',
                    ),
                    const SizedBox(height: 8),
                    Text('Dibuat pada: ${_formatDate(item['createdAt'])}'),
                    const SizedBox(height: 8),
                    Text('Diupdate pada: ${_formatDate(item['updatedAt'])}'),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
