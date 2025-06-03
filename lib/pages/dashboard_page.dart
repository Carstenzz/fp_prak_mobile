import 'package:flutter/material.dart';
import 'inventory_page.dart';
import 'category_page.dart';
import '../services/user_service.dart';
import 'login_page.dart';
import 'chatbot_page.dart';

/// Halaman dashboard utama
class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).colorScheme.background.withOpacity(0.97),
      appBar: AppBar(
        title: const Text('Dashboard'),
        foregroundColor: Colors.white,
        backgroundColor: Colors.indigo,
        elevation: 4,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await UserService.clearToken();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Inventario🤌',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 32,
                  ),
                  leading: const Icon(
                    Icons.inventory_2,
                    size: 40,
                    color: Colors.indigo,
                  ),
                  title: const Text(
                    'Manajemen Inventaris',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InventoryPage()),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 32,
                  ),
                  leading: const Icon(
                    Icons.category,
                    size: 40,
                    color: Colors.indigo,
                  ),
                  title: const Text(
                    'Manajemen Kategori',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CategoryPage()),
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
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const ChatbotPage()),
          );
        },
      ),
    );
  }
}
