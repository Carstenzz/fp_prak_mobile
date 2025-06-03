import 'package:flutter/material.dart';
import '../models/item.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../services/user_service.dart';

class ItemDetailPage extends StatelessWidget {
  final Item item;
  const ItemDetailPage({super.key, required this.item});

  Future<Category?> _getCategory() async {
    final token = await UserService.getToken();
    if (token == null) return null;
    final categories = await CategoryService().getCategories(token);
    return categories.firstWhere(
      (c) => c.id == item.categoryId,
      orElse: () => Category(id: '', name: 'Tidak diketahui', createdAt: ''),
    );
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
      body: Center(
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
                if (item.imageUrl.isNotEmpty)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        item.imageUrl,
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
                  'Nama: ${item.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text('Jumlah: ${item.quantity}'),
                const SizedBox(height: 8),
                Text('Deskripsi: ${item.description}'),
                const SizedBox(height: 8),
                FutureBuilder<Category?>(
                  future: _getCategory(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) return const SizedBox();
                    return Text('Kategori: ${snapshot.data!.name}');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
