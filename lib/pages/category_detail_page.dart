import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/item.dart';
import '../services/item_service.dart';
import '../services/user_service.dart';
import 'item_detail_page.dart';

/// Halaman detail kategori
class CategoryDetailPage extends StatefulWidget {
  final Category category;
  const CategoryDetailPage({super.key, required this.category});

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List<Item> _items = [];
  bool _loading = true;

  Future<void> _loadItems() async {
    setState(() {
      _loading = true;
    });
    final token = await UserService.getToken();
    if (token == null) return;
    final items = await ItemService().getItems(token);
    _items = items.where((i) => i.categoryId == widget.category.id).toList();
    setState(() {
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.background.withOpacity(0.97),
      appBar: AppBar(
        title: const Text('Detail Kategori'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nama: ${widget.category.name}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Text(
                  'Item dalam kategori ini:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                _loading
                    ? const CircularProgressIndicator()
                    : (_items.isEmpty
                        ? const Text('Belum ada item dalam kategori ini.')
                        : SizedBox(
                          height: 350,
                          child: ListView.builder(
                            itemCount: _items.length,
                            itemBuilder: (context, index) {
                              final item = _items[index];
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  leading:
                                      (item.imageUrl?.isNotEmpty ?? false)
                                          ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              item.imageUrl ?? '',
                                              width: 48,
                                              height: 48,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.broken_image,
                                                    color: Colors.red,
                                                  ),
                                            ),
                                          )
                                          : const Icon(
                                            Icons.inventory_2,
                                            size: 36,
                                            color: Colors.indigo,
                                          ),
                                  title: Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(
                                    (item.description?.isNotEmpty ?? false)
                                        ? item.description!
                                        : 'Qty: ${item.quantity}',
                                  ),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (_) => ItemDetailPage(item: item),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
