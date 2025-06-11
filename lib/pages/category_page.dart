import 'package:flutter/material.dart';
import '../models/category.dart';
import '../services/category_service.dart';
import '../services/user_service.dart';
import 'package:uuid/uuid.dart';
import 'category_detail_page.dart';
import 'chatbot_page.dart';

/// Halaman untuk menampilkan dan mengelola kategori
class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  late final TextEditingController _nameController;
  List<Category> _categories = [];
  bool _loading = true;

  Future<void> _loadCategories() async {
    setState(() {
      _loading = true;
    });
    final token = await UserService.getToken();
    if (token == null) return;
    _categories = await CategoryService().getCategories(token);
    setState(() {
      _loading = false;
    });
  }

  Future<void> _addCategory() async {
    final name = _nameController.text;
    if (name.isEmpty) return;
    final token = await UserService.getToken();
    if (token == null) return;
    final category = Category(
      id: const Uuid().v4(),
      name: name,
      createdAt: DateTime.now().toIso8601String(),
    );
    await CategoryService().addCategory(category, token);
    _nameController.clear();
    _loadCategories();
  }

  Future<void> _editCategory(Category category) async {
    final result = await showDialog<Map<String, String>?>(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: category.name);
        return AlertDialog(
          title: const Text('Edit Kategori'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nama'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed:
                  () => Navigator.pop(context, {'name': nameController.text}),
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
    if (result != null && result['name']!.isNotEmpty) {
      final token = await UserService.getToken();
      if (token == null) return;
      await CategoryService().updateCategory(
        Category(
          id: category.id,
          name: result['name']!,
          createdAt: category.createdAt,
        ),
        token,
      );
      _loadCategories();
    }
  }

  Future<void> _deleteCategory(String id) async {
    final token = await UserService.getToken();
    if (token == null) return;
    try {
      await CategoryService().deleteCategory(id, token);
      _loadCategories();
    } catch (e) {
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Tidak Bisa Menghapus Kategori'),
                content: const Text(
                  'Masih ada item yang menggunakan kategori ini.',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.indigo),
          filled: true,
          fillColor: const Color(0xFFE8EAF6),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.indigo, width: 1.2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.deepOrange, width: 2),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FB),
      appBar: AppBar(
        title: const Text('Kategori'),
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
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                _nameController,
                                'Nama Kategori',
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, color: Colors.indigo),
                              onPressed: _addCategory,
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _categories.length,
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.indigo,
                                      ),
                                      onPressed: () => _editCategory(category),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _deleteCategory(category.id),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => CategoryDetailPage(
                                            category: category,
                                          ),
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
