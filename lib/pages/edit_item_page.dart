import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/category.dart' as model_category;
import '../models/item.dart';
import '../services/category_service.dart';
import '../services/item_service.dart';
import '../services/user_service.dart';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

/// Halaman untuk mengedit item yang sudah ada.
class EditItemPage extends StatefulWidget {
  final Item item;
  const EditItemPage({super.key, required this.item});

  @override
  State<EditItemPage> createState() => _EditItemPageState();
}

class _EditItemPageState extends State<EditItemPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _descriptionController;
  // Ganti _imageFile menjadi dynamic agar bisa menampung File (mobile) atau html.File (web)
  dynamic _imageFile;
  bool _loading = false;
  List<model_category.Category> _categories = [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.item.name);
    _quantityController = TextEditingController(
      text: widget.item.quantity.toString(),
    );
    _descriptionController = TextEditingController(
      text: widget.item.description,
    );
    _loadCategories();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    final token = await UserService.getToken();
    if (token == null) return;
    final categories = await CategoryService().getCategories(token);
    setState(() {
      _categories = categories;
      _selectedCategoryId = widget.item.categoryId.toString();
    });
  }

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final uploadInput = html.FileUploadInputElement();
      uploadInput.accept = 'image/*';
      uploadInput.click();
      uploadInput.onChange.listen((event) {
        final files = uploadInput.files;
        if (files != null && files.isNotEmpty) {
          setState(() {
            _imageFile = files.first;
          });
        }
      });
    } else {
      final source = await showDialog<ImageSource>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Pilih Sumber Gambar'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.camera_alt),
                    title: const Text('Kamera'),
                    onTap: () => Navigator.pop(context, ImageSource.camera),
                  ),
                  ListTile(
                    leading: const Icon(Icons.photo_library),
                    title: const Text('Galeri'),
                    onTap: () => Navigator.pop(context, ImageSource.gallery),
                  ),
                ],
              ),
            ),
      );
      if (source != null) {
        final picked = await ImagePicker().pickImage(source: source);
        if (picked != null) {
          setState(() {
            _imageFile = File(picked.path);
          });
        }
      }
    }
  }

  Future<void> _editItem() async {
    setState(() {
      _loading = true;
    });
    final token = await UserService.getToken();
    if (token == null) return;
    final item = Item(
      id: widget.item.id,
      name: _nameController.text,
      description: _descriptionController.text,
      imageUrl: kIsWeb ? '' : (_imageFile?.path ?? ''),
      quantity: int.tryParse(_quantityController.text) ?? 0,
      categoryId: int.tryParse(_selectedCategoryId ?? '0') ?? 0,
      createdBy: widget.item.createdBy,
      createdAt: widget.item.createdAt,
    );
    await ItemService().updateItem(item, token, imageFile: _imageFile);
    setState(() {
      _loading = false;
    });
    Navigator.pop(context);
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    bool isNumber = false,
    required String label,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
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
        title: const Text('Edit Item'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
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
                  _buildTextField(
                    _nameController,
                    'Nama Item',
                    label: 'Nama Item',
                  ),
                  DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    items:
                        _categories
                            .map(
                              (cat) => DropdownMenuItem(
                                value: cat.id,
                                child: Text(cat.name),
                              ),
                            )
                            .toList(),
                    onChanged: (val) {
                      setState(() {
                        _selectedCategoryId = val;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Kategori',
                      filled: true,
                      fillColor: Color(0xFFE8EAF6),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          color: Colors.indigo,
                          width: 1.2,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                        borderSide: BorderSide(
                          color: Colors.deepOrange,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildTextField(
                    _quantityController,
                    'Jumlah',
                    isNumber: true,
                    label: 'Jumlah',
                  ),
                  _buildTextField(
                    _descriptionController,
                    'Deskripsi',
                    label: 'Deskripsi',
                  ),
                  const SizedBox(height: 8),
                  _imageFile != null
                      ? (kIsWeb
                          ? FutureBuilder<Uint8List>(
                            future: _imageFile.arrayBuffer().then(
                              (value) => Uint8List.view(value),
                            ),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) return const SizedBox();
                              return Image.memory(
                                snapshot.data!,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(
                              _imageFile!,
                              width: 120,
                              height: 120,
                              fit: BoxFit.cover,
                            ),
                          ))
                      : ((widget.item.imageUrl?.isNotEmpty ?? false)
                          ? Center(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                widget.item.imageUrl ?? '',
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
                          )
                          : SizedBox()),
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Pilih Foto (opsional)'),
                  ),
                  const SizedBox(height: 20),
                  _loading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        onPressed: _editItem,
                        child: const Text(
                          'Simpan',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
