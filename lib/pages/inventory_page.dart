import 'package:flutter/material.dart';
import '../services/item_service.dart';
import '../models/item.dart';
import 'add_item_page.dart';
import 'edit_item_page.dart';
import 'item_detail_page.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../services/user_service.dart';
import 'chatbot_page.dart';

/// Halaman utama inventaris
class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  List<Item> _items = [];
  List<Item> _filteredItems = [];
  List<Category> _categories = [];
  String? _selectedCategoryId;
  String _searchQuery = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
    });
    final token = await UserService.getToken();
    if (token == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
      });
      return;
    }
    final items = await ItemService().getItems(token);
    final categories = await CategoryService().getCategories(token);
    if (!mounted) return;
    setState(() {
      _items = items;
      _categories = categories;
      _selectedCategoryId = null;
      _loading = false;
    });
    _applyFilter();
  }

  void _applyFilter() {
    if (!mounted) return;
    setState(() {
      _filteredItems =
          _items.where((item) {
            final matchSearch = item.name.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            );
            final matchCategory =
                _selectedCategoryId == null ||
                item.categoryId == int.tryParse(_selectedCategoryId ?? '');
            return matchSearch && matchCategory;
          }).toList();
    });
  }

  void _refresh() async {
    await _loadAll();
  }

  Future<void> _deleteItem(String id) async {
    final token = await UserService.getToken();
    if (token == null) return;
    await ItemService().deleteItem(id, token);
    await _loadAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.background.withOpacity(0.97),
      appBar: AppBar(
        title: const Text('Inventaris'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Cari nama item...',
                                  prefixIcon: Icon(Icons.search),
                                  filled: true,
                                  fillColor: Color(0xFFE8EAF6),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.indigo,
                                      width: 1.2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(12),
                                    ),
                                    borderSide: BorderSide(
                                      color: Colors.deepOrange,
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  _searchQuery = val;
                                  _applyFilter();
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            DropdownButton<String?>(
                              value: _selectedCategoryId,
                              hint: const Text('Kategori'),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Semua'),
                                ),
                                ..._categories.map(
                                  (cat) => DropdownMenuItem(
                                    value: cat.id,
                                    child: Text(cat.name),
                                  ),
                                ),
                              ],
                              onChanged: (val) {
                                setState(() {
                                  _selectedCategoryId = val;
                                });
                                _applyFilter();
                              },
                            ),
                          ],
                        ),
                      ),
                      // Add Item shortcut at the top
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Tambah Item Baru',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[700],
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.deepPurple,
                                size: 32,
                              ),
                              tooltip: 'Tambah Item',
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const AddItemPage(),
                                  ),
                                );
                                _refresh();
                              },
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = _filteredItems[index];
                            return Card(
                              elevation: 6,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
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
                                                (context, error, stackTrace) =>
                                                    const Icon(
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
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.indigo,
                                      ),
                                      onPressed: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => EditItemPage(item: item),
                                          ),
                                        );
                                        _refresh();
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed: () async {
                                        final confirm = await showDialog<bool>(
                                          context: context,
                                          builder:
                                              (context) => AlertDialog(
                                                title: const Text('Hapus Item'),
                                                content: const Text(
                                                  'Yakin ingin menghapus item ini?',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text('Batal'),
                                                  ),
                                                  TextButton(
                                                    onPressed:
                                                        () => Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text(
                                                      'Hapus',
                                                      style: TextStyle(
                                                        color: Colors.red,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                        );
                                        if (confirm == true) {
                                          await _deleteItem(item.id);
                                        }
                                      },
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) =>
                                              ItemDetailPage(itemId: item.id),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'chatbot',
        backgroundColor: Colors.deepPurple,
        child: const Icon(Icons.chat, color: Colors.white),
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const ChatbotPage()));
        },
      ),
    );
  }
}
